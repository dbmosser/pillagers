# push-pack.ps1 : sends the session pack (built by build-pack.ps1) into the VM with Hyper-V's own file copy.
# No clipboard or drive sharing is needed. The files land in C:\PillagersMove\ inside the VM.
#
# Run it in an ADMINISTRATOR PowerShell window (elevated-runner.ps1 can run it for you too):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\push-pack.ps1" -DryRun    (look first: checks the pack, touches nothing)
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\push-pack.ps1"
#   -VMName NAME   the VM (default Pillagers_Oct26)
#
# The pack is read from C:\Users\User1\AppData\Local\PillagersMove\out\pack (outside the repository; build-pack.ps1 writes it there).
# Before anything is sent, the zip and unpack-session.ps1 are checked against pack-manifest.json (size and sha256). A pack that does not match is refused.
# The only change to the VM itself: it turns on the VM's "Guest Service Interface" integration service (needed for the file copy) if it is off.
# Sent: unpack-session.ps1, pack-manifest.json, pillagers-session-pack.zip (the zip last, so a cut-off copy can never look complete).
# Exit codes: 0 done, 1 error, 2 refused, 3 needs an administrator window.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [string]$VMName = 'Pillagers_Oct26',
  [switch]$DryRun
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'push-pack'

$packDir  = Join-Path $script:HostStage 'pack'
$zipPath  = Join-Path $packDir 'pillagers-session-pack.zip'
$manPath  = Join-Path $packDir 'pack-manifest.json'
$unpPath  = Join-Path $packDir 'unpack-session.ps1'
$oldZip   = Join-Path $script:MigRoot 'out\pillagers-session-pack.zip'

Write-MigBlank
Write-Mig '=== PUSH PACK: send the session pack into the VM ===' 'STEP'
if ($DryRun) { Write-Mig '(dry run: the pack is checked, nothing is sent and the VM is not touched)' 'DRY' }
if (-not (Test-HostProfileOk)) { Exit-Mig 1 }
if (-not $DryRun -and -not (Test-IsAdmin)) {
  Write-Mig 'This step talks to Hyper-V, so it needs an administrator window.' 'FAIL'
  Write-Mig 'Right-click the PowerShell icon, choose "Run as administrator", and run the same command again. (You can look first without one: add -DryRun.)' 'FAIL'
  Exit-Mig 3
}

# ------------------------------------------------------------------ the pack must exist and match its manifest
Write-Mig 'Checking the pack' 'STEP'
foreach ($p in @($zipPath, $manPath, $unpPath)) {
  if (-not (Test-Path -LiteralPath $p)) {
    Write-Mig ('missing: ' + $p) 'FAIL'
    Write-Mig 'Run build-pack.ps1 first (a normal window is enough). It builds the pack outside the repository and writes the manifest.' 'FAIL'
    Exit-Mig 2
  }
}
if (Test-Path -LiteralPath $oldZip) { Write-Mig ('An old pack sits in ' + $oldZip + '. It is NOT used (it was never scanned and its kit files are old). You can delete it yourself.') 'WARN' }
$man = $null
try { $man = Get-Content -LiteralPath $manPath -Raw | ConvertFrom-Json } catch { }
if ($null -eq $man -or $null -eq $man.zip -or -not $man.zip.sha256) { Write-Mig 'pack-manifest.json cannot be read. Run build-pack.ps1 again.' 'FAIL'; Exit-Mig 2 }
$zipLen = (Get-Item -LiteralPath $zipPath).Length
Write-Mig ('hashing the zip (' + (Format-Bytes $zipLen) + ') ...') 'INFO'
$zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ([int64]$man.zip.size -ne [int64]$zipLen -or ([string]$man.zip.sha256).ToLowerInvariant() -ne $zipHash) {
  Write-Mig 'The zip does not match pack-manifest.json (it changed or was cut short after it was built). Run build-pack.ps1 again.' 'FAIL'
  Exit-Mig 2
}
$unpHash = (Get-FileHash -LiteralPath $unpPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($man.unpack -and $man.unpack.sha256 -and ([string]$man.unpack.sha256).ToLowerInvariant() -ne $unpHash) {
  Write-Mig 'unpack-session.ps1 in the pack folder does not match pack-manifest.json. Run build-pack.ps1 again.' 'FAIL'
  Exit-Mig 2
}
Write-Mig ('pack is intact: ' + $man.entries + ' file(s), ' + (Format-Bytes $zipLen) + ', sha256 ' + $zipHash.Substring(0, 12) + '..., built ' + $man.created) 'OK'
try {
  $ageH = ((Get-Date) - [datetime]$man.created).TotalHours
  if ($ageH -gt 12) { Write-Mig ('The pack is ' + [int]$ageH + ' hours old. The conversation and memory inside it stop at that time. Run build-pack.ps1 again if you want the newest.') 'WARN' }
} catch { }
$nLeft = 0
try { $nLeft = @($man.leftOut).Count } catch { }
if ($nLeft -gt 0) { Write-Mig ($nLeft.ToString() + ' file(s) were left out of the pack by the secret rules (names are in pack-manifest.json).') 'WARN' }

if ($DryRun) {
  Write-Mig ('would send unpack-session.ps1, pack-manifest.json and pillagers-session-pack.zip to ' + $script:GuestStage + ' in the VM ' + $VMName) 'DRY'
  Write-Mig 'would turn on the Guest Service Interface of the VM if it is off' 'DRY'
  Write-Mig 'Dry run finished. Nothing was sent.' 'DONE'
  Exit-Mig 0
}

# ------------------------------------------------------------------ the VM
Write-Mig ('Talking to the VM ' + $VMName) 'STEP'
$vm = $null
try { $vm = Get-VM -Name $VMName -ErrorAction Stop } catch { Write-Mig ('VM not found: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
if ($vm.State -ne 'Running') { Write-Mig ('The VM is ' + $vm.State + '. Start it first.') 'FAIL'; Exit-Mig 2 }
$gsi = Get-VMIntegrationService -VMName $VMName | Where-Object { $_.Name -like 'Guest Service*' } | Select-Object -First 1
if (-not $gsi) { Write-Mig 'The Guest Service Interface integration service was not found on this VM.' 'FAIL'; Exit-Mig 2 }
if (-not $gsi.Enabled) {
  Enable-VMIntegrationService -VMName $VMName -Name $gsi.Name
  Write-Mig ('turned on the VM integration service: ' + $gsi.Name) 'OK'
  Start-Sleep -Seconds 8
}

$sent = 0
$failedNames = @()
$send = @(
  @{ Src = $unpPath; Dest = ($script:GuestStage + '\unpack-session.ps1') },
  @{ Src = $manPath; Dest = ($script:GuestStage + '\pack-manifest.json') },
  @{ Src = $zipPath; Dest = ($script:GuestStage + '\pillagers-session-pack.zip') }
)
foreach ($s in $send) {
  $nm = Split-Path -Path $s.Src -Leaf
  Write-Mig ('copying ' + $nm + ' (' + (Format-Bytes ((Get-Item -LiteralPath $s.Src).Length)) + ')') 'INFO'
  if (Copy-ToGuest -VMName $VMName -Source $s.Src -GuestPath $s.Dest) { $sent++ } else { $failedNames += $nm }
}
Write-MigBlank
if ($failedNames.Count -eq 0) {
  Write-Mig ('sent ' + $sent + ' file(s) to ' + $script:GuestStage + ' in the VM') 'OK'
  Write-Mig 'NEXT, inside the VM: open C:\PillagersMove, right-click unpack-session.ps1 and choose "Run with PowerShell". (Add -DryRun first if you want to look.)' 'DONE'
  $code = 0
} else {
  Write-Mig ('FAILED to send: ' + ($failedNames -join ', ')) 'FAIL'
  $code = 1
}
Start-Sleep -Seconds 6
Exit-Mig $code
