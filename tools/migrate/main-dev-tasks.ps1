# main-dev-tasks.ps1 : run ON THE MAIN PC (JUL26) after main-dev-setup.ps1, in a normal window. Creates or takes over the user-level scheduled tasks
# for the dev runner and the dashboard (his order 11-02). Plan: tools\handoff\move-to-main-pc-1102.md; how to run: tools\handoff\console\notes\move\kit.md
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\main-dev-tasks.ps1" -DryRun
#   powershell -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\main-dev-tasks.ps1"
#
# Admin: none needed for this. Tasks run as him, only while he is signed in, not elevated. If an old task of the same name was made from an
# administrator window and Windows refuses to change it, this one leaves that old task off and makes the new one under another name, and says so.
#
# Tasks: "Pillagers runner", every 15 minutes and at sign-in: tools\runner-start.vbs, which starts tools\nightly.sh hidden; a live copy makes a new one
# exit. nightly.sh itself starts itch-follow.sh (its step 4b), spare-import.mjs (1c) and the dashboard on 8820 (10), so they need no task of their own.
# "Pillagers dev services", at sign-in: tools\migrate\main-dev-services.vbs, the dashboard only. The old action ran tools\start-servers.ps1, which must
# never run here: 8802 and the collector belong to the party copy and the runner there. So an old task that runs start-servers is replaced, never enabled.
# Lanes are started by nightly.sh. On this PC nightly.sh exits at once while console\STOP is up, so turning the tasks on before the cutover starts nothing.
# It never touches the main PC's own tasks that do not point at the dev folder (the idle runner, the memory tasks, the bridge).
# Exit codes: 0 done, 1 error. ASCII only. Works in Windows PowerShell 5.1.
param([switch]$DryRun)
$ErrorActionPreference = 'Continue'
$Repo = 'C:\claudecode\dark raiders'
$onMain = ($env:COMPUTERNAME -ieq 'JUL26')
function Say([string]$t, [string]$lv = 'INFO') {
  $c = @{ INFO = 'Gray'; STEP = 'Cyan'; OK = 'Green'; WARN = 'Yellow'; FAIL = 'Red'; DRY = 'DarkYellow'; DONE = 'Green' }[$lv]
  Write-Host ('[' + $lv + '] ' + $t) -ForegroundColor $c
}
function Esc([string]$s) { return [System.Security.SecurityElement]::Escape($s) }
function Task-Xml([string]$Desc, [string]$Triggers, [string]$Script, [string]$User) {
  return '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><RegistrationInfo><Description>' + (Esc $Desc) + '</Description></RegistrationInfo><Triggers>' + $Triggers +
    '</Triggers><Principals><Principal id="Author"><UserId>' + (Esc $User) + '</UserId><LogonType>InteractiveToken</LogonType><RunLevel>LeastPrivilege</RunLevel></Principal></Principals>' +
    '<Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><StartWhenAvailable>true</StartWhenAvailable><Enabled>true</Enabled><Hidden>false</Hidden><ExecutionTimeLimit>PT10M</ExecutionTimeLimit></Settings>' +
    '<Actions Context="Author"><Exec><Command>wscript.exe</Command><Arguments>' + (Esc ('"' + $Script + '"')) + '</Arguments></Exec></Actions></Task>'
}
function Show-Task([string]$Name) {
  $t = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
  if (-not $t) { return $null }
  $acts = ''; try { $acts = (@($t.Actions) | ForEach-Object { [string]$_.Execute + ' ' + [string]$_.Arguments }) -join '; ' } catch { }
  Say ('found "' + $Name + '": ' + $t.State + ', runs ' + $acts) 'INFO'
  return $t
}
# Registers Name; on a refusal tries without the sign-in trigger, then under FallbackName. Returns the name it ended up with, or ''.
function Put-Task([string]$Name, [string]$FallbackName, [string]$Desc, [string]$TimeTrig, [string]$LogonTrig, [string]$Script, [string]$User) {
  if ($DryRun) { Say ('would create or replace task "' + $Name + '" (user level, not elevated) to run ' + $Script) 'DRY'; return $Name }
  foreach ($nm in @($Name, $FallbackName)) {
    foreach ($tr in @(($TimeTrig + $LogonTrig), $TimeTrig)) {
      if (-not $tr) { continue }
      try {
        Register-ScheduledTask -TaskName $nm -Xml (Task-Xml $Desc $tr $Script $User) -Force -ErrorAction Stop | Out-Null
        if ($nm -ne $Name) { Say ('Windows would not change the old "' + $Name + '" (made from an administrator window); it stays off, and the new task is "' + $nm + '"') 'WARN' }
        if ($tr -eq $TimeTrig -and $LogonTrig) { Say ('"' + $nm + '" has no sign-in start (Windows refused that part without administrator); its 15 minute start covers it') 'WARN' }
        Say ('task "' + $nm + '" is on') 'OK'
        return $nm
      } catch { Say ('"' + $nm + '": ' + $_.Exception.Message) 'WARN' }
    }
  }
  return ''
}

Say ('=== MAIN PC DEV TASKS on ' + $env:COMPUTERNAME + ' ===') 'STEP'
if ($DryRun) { Say 'dry run: nothing is changed' 'DRY' }
if (-not $onMain) { if ($DryRun) { Say 'this is not JUL26; a real run would refuse here' 'WARN' } else { Say 'This runs only on the main PC (JUL26).' 'FAIL'; exit 1 } }
$marker = $Repo + '\tools\migrate\host-stopped.txt'
$moved = (Test-Path -LiteralPath $marker) -and (Select-String -LiteralPath $marker -Pattern '^devMovedHere=yes' -Quiet)
if (-not $moved) { if ($DryRun) { Say 'main-dev-setup.ps1 has not run here yet; a real run would refuse here' 'WARN' } else { Say 'Run main-dev-setup.ps1 first: this folder has no dev-moved marker.' 'FAIL'; exit 1 } }
if (-not $DryRun -and -not (Test-Path -LiteralPath ($Repo + '\tools\handoff\console\STOP'))) { Say 'console\STOP is not up. That is fine only once the VM is dark.' 'WARN' }

$user = $env:USERDOMAIN + '\' + $env:USERNAME
$start = (Get-Date).AddMinutes(2).ToString('s')
$every15 = '<TimeTrigger><Repetition><Interval>PT15M</Interval></Repetition><StartBoundary>' + $start + '</StartBoundary><Enabled>true</Enabled></TimeTrigger>'
$logon = '<LogonTrigger><Enabled>true</Enabled><UserId>' + (Esc $user) + '</UserId><Delay>PT1M</Delay></LogonTrigger>'

$null = Show-Task 'Pillagers runner'
$old = Show-Task 'Pillagers dev services'
if ($old -and $old.State -ne 'Disabled') { try { if (@($old.Actions | Where-Object { ([string]$_.Arguments + [string]$_.Execute) -match 'start-servers|party-start|dev-services' }).Count -gt 0 -and -not $DryRun) { Disable-ScheduledTask -TaskName 'Pillagers dev services' -ErrorAction SilentlyContinue | Out-Null; Say 'the old dev services task is off' 'OK' } } catch { } }

$r = Put-Task 'Pillagers runner' 'Pillagers dev runner' 'PILLAGERS always-on runner on the main PC since 11-02: tools\runner-start.vbs starts tools\nightly.sh hidden. Exits at once while console\STOP is up.' $every15 $logon ($Repo + '\tools\runner-start.vbs') $user
$d = Put-Task 'Pillagers dev services' 'Pillagers dashboard' 'PILLAGERS dashboard 8820 at sign-in, on the main PC since 11-02. Never the play servers.' '' $logon ($Repo + '\tools\migrate\main-dev-services.vbs') $user
if (-not $r) { Say 'the runner task could not be made. Tell the coordinator; this is the one that needs a look.' 'FAIL'; exit 1 }
if (-not $d) { Say 'no dashboard task: nightly.sh starts the dashboard within 5 minutes of running anyway, so this only costs that wait' 'WARN' }
if (-not $DryRun) {
  foreach ($n in @($r, $d)) { if ($n) { $t = Get-ScheduledTask -TaskName $n -ErrorAction SilentlyContinue; Say ('check: "' + $n + '" is ' + $t.State + ', runs ' + (@($t.Actions) | ForEach-Object { [string]$_.Execute + ' ' + [string]$_.Arguments })) 'INFO' } }
}
Say 'Done. Nothing here needed administrator. The runner does nothing until the new chat lifts console\STOP.' 'DONE'
exit 0
