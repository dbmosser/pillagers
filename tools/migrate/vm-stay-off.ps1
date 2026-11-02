# vm-stay-off.ps1 : the rule that keeps the VM off now that dev moved to the main PC (his order 11-02, "shut down the VM (for now)"). The VM starts when the main
# PC boots and changing that needs administrator, so instead it shuts itself down. vm-go-dark.ps1 copies this to C:\PillagersMove\kit and puts a Startup entry on it.
#   -Mode Logon (the Startup entry): asks the bridge share at sign-in. vm-wanted.txt there: stay up. No vm-wanted.txt: shutdown /s /t 120. The bridge cannot be
#     read: stay up with STOP in place, and keep asking (the main PC's bridge starts only when he signs in there), for 12 hours.
#   -Mode WatchOff (started once by vm-go-dark.ps1): waits for vm-off-now.txt in the share, which the new main PC chat writes after its first ship, then shuts down.
# To bring the VM back for a while: put a file named vm-wanted.txt in %LOCALAPPDATA%\PillagersBridge\share on the main PC, then press Start in his VM window.
# It reads only the list of names in the share. ASCII only.
param([ValidateSet('Logon', 'WatchOff')][string]$Mode = 'Logon', [switch]$DryRun)
$repo = 'C:\claudecode\dark raiders'
$log = 'C:\PillagersMove\launchers\vm-stay-off.log'
function Log([string]$t) { try { Add-Content -LiteralPath $log -Value ((Get-Date).ToString('s') + ' ' + $Mode + ' ' + $t) -Encoding ASCII } catch { }; if ($DryRun) { Write-Host $t } }
function Share-Names {
  try {
    $o = & node (Join-Path $repo 'tools\bridge\hostctl.mjs') share-list 2>$null | Out-String
    $j = $o | ConvertFrom-Json
    if ($j.ok -and $null -ne $j.files) { return ,@(@($j.files) | ForEach-Object { [string]$_.name }) }
  } catch { }
  return $null
}
function Off([string]$Why) {
  Log ('shutting down in 2 minutes: ' + $Why)
  if ($DryRun) { Write-Host 'dry run: would run shutdown /s /t 120'; exit 0 }
  & shutdown.exe /s /t 120 /c ('Pillagers: dev moved to the main PC, so this VM stays off (' + $Why + '). To keep it up: shutdown /a, and put vm-wanted.txt in the bridge share.')
  exit 0
}
$end = (Get-Date).AddHours(12); $n = 0
while ((Get-Date) -lt $end) {
  $names = Share-Names
  if ($null -ne $names) {
    if ($Mode -eq 'Logon') {
      if ($names -contains 'vm-wanted.txt') { Log 'vm-wanted.txt is in the share: staying up'; exit 0 }
      Off 'no vm-wanted.txt in the bridge share'
    } elseif ($names -contains 'vm-off-now.txt') { Off 'the main PC has shipped' }
  } elseif ($Mode -eq 'Logon' -and $n -eq 0) { Log 'the bridge does not answer: staying up with STOP in place, asking again' }
  $n++
  if ($DryRun) { Write-Host 'dry run: one look only'; exit 0 }
  if ($Mode -eq 'Logon' -and $n -le 20) { Start-Sleep -Seconds 60 } else { Start-Sleep -Seconds 300 }
}
Log 'gave up after 12 hours: staying up with STOP in place'
exit 0
