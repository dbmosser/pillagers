# host-stop.ps1 : stops Pillagers development on THIS PC so it can carry on inside the VM. -Undo puts everything back.
#
# Run it from a normal PowerShell window (an administrator window is only needed to switch off the scheduled task, if Windows says "Access is denied"):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1"
#   -DryRun            only print what it WOULD do (changes nothing)
#   -Undo              switch everything back on (uses tools\party-start.ps1 for the restart). Asks you to type RESUME (-Yes does not skip that).
#   -WaitMinutes N     how long helpers and ships may finish by themselves (default 20). A ship that is STILL running after that is never
#                      interrupted: the script stops there (exit 2), touches nothing more, and is safe to run again later.
#   -LockWaitMinutes N how long to wait for the ship lock to clear (default 30)
#   -ClearStale        if the ship lock is still there after that, ask the official tool (clearstale.sh) whether it is stale
#   -KeepPlayServers   leave the play server (:8802) and the collector (:8799) running (see the note on 8802 below)
#   -StopOllama        also stop Ollama (it is left alone by default)
#   -Yes               do not ask for confirmation (also skips the "someone is connected to :8802" question)
#   -VMName NAME       the VM (used only to tell it the host is running again, on -Undo)
#
# What it never touches: your normal Chrome, the Claude desktop app and any Claude Code session of yours (a helper run is only recognised
# when it runs in print mode, and this window and whatever started it are never stopped), Ollama (unless asked),
# Windows settings, security settings. It only stops Pillagers background work and writes the marker file the VM checks.
# The play server (:8802) is stopped on purpose by default: on party night the main PC's Chrome reaches the VM's game through :8802 here.
# If someone is connected to :8802 or :8799 right now, the script asks first.
# Scheduled tasks and startup shortcuts are only switched off when what they run points into this repository.
# Order: stop signs, scheduled task + startup shortcut, runner, wait for helpers and the ship lock, helpers/lanes/robots, test browsers
# and servers, check, marker (host-stopped.txt in this folder, with a check= line the VM verifies).
# Exit codes: 0 stopped (marker written), 2 not everything stopped (no marker), 3 needs an administrator window, 1 error.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [string]$VMName = 'Pillagers_Oct26',
  [int]$WaitMinutes = 20,
  [int]$LockWaitMinutes = 30,
  [switch]$ClearStale,
  [switch]$KeepPlayServers,
  [switch]$StopOllama,
  [switch]$DryRun,
  [switch]$Undo,
  [switch]$Yes
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'host-stop'

$R = $script:RepoRoot
$H = $R + '\tools\handoff'
$C = $H + '\console'
$X = $H + '\codex'
$stateFile = Join-Path $script:StateDir 'host-stop-state.json'
$markerPath = Get-MarkerPath
$startupDir = $script:HostProfile + '\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
$isAdmin = Test-IsAdmin
$needAdmin = $false

if (-not (Test-HostProfileOk)) { Exit-Mig 1 }
if (-not (Test-Path -LiteralPath $R)) { Write-Mig ('The Pillagers folder is not here: ' + $R) 'FAIL'; Exit-Mig 1 }

# ------------------------------------------------------------------ remembered changes (so -Undo can reverse exactly what this script did)
function Read-StopState {
  $s = [ordered]@{ time = ''; disabledTasks = @(); renamedStartup = @(); createdFiles = @(); excludeLineAdded = $false; stoppedOllama = $false; markerPushedToVm = $false }
  if (Test-Path -LiteralPath $stateFile) {
    try {
      $j = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
      if ($j.disabledTasks) { $s['disabledTasks'] = @($j.disabledTasks) }
      if ($j.createdFiles) { $s['createdFiles'] = @($j.createdFiles) }
      if ($j.renamedStartup) { $s['renamedStartup'] = @($j.renamedStartup) }
      if ($j.excludeLineAdded) { $s['excludeLineAdded'] = [bool]$j.excludeLineAdded }
      if ($j.stoppedOllama) { $s['stoppedOllama'] = [bool]$j.stoppedOllama }
      if ($j.markerPushedToVm) { $s['markerPushedToVm'] = [bool]$j.markerPushedToVm }
    } catch { Write-Mig 'The old state file could not be read; starting a fresh one.' 'WARN' }
  }
  return $s
}
function Save-StopState {
  if ($DryRun) { return }
  $st['time'] = (Get-Date).ToString('s')
  Write-AsciiFile -Path $stateFile -Text ($st | ConvertTo-Json -Depth 6)
}
function Add-StateItem {
  param([string]$Key, $Value)
  $cur = @($st[$Key])
  $st[$Key] = $cur + @($Value)
}
$st = Read-StopState

function Confirm-Plain {
  param([string]$Question)
  if ($Yes -or $DryRun) { return $true }
  $a = Read-Host ($Question + ' Type YES to go on, anything else to cancel')
  return ($a -eq 'YES')
}

function Confirm-Typed {
  # Always asks, even with -Yes (only -DryRun skips it). Used where a wrong answer could leave two machines shipping at once.
  param([string]$Question, [string]$Word)
  if ($DryRun) { return $true }
  $a = Read-Host ($Question + ' Type ' + $Word + ' (in capitals) to go on, anything else to cancel')
  return ($a -ceq $Word)
}

function Get-StartupLinks {
  # Startup shortcuts that start THIS repository: the name mentions Pillagers or Dark Raiders AND the shortcut points into the repository.
  # A shortcut whose target cannot be read is counted (stopping it is reversible with -Undo).
  param([switch]$Report)
  $out = @()
  if (-not (Test-Path -LiteralPath $startupDir)) { return @() }
  $sh = $null
  try { $sh = New-Object -ComObject WScript.Shell } catch { }
  foreach ($f in (Get-ChildItem -LiteralPath $startupDir -File -Force -ErrorAction SilentlyContinue)) {
    if ($f.Name -notmatch '(?i)pillagers|dark.?raiders') { continue }
    $txt = ''
    if ($sh -and $f.Extension -ieq '.lnk') {
      try { $lnk = $sh.CreateShortcut($f.FullName); $txt = [string]$lnk.TargetPath + ' ' + [string]$lnk.Arguments + ' ' + [string]$lnk.WorkingDirectory } catch { }
    }
    if ((-not $txt.Trim()) -or ($txt -match $script:RepoTaskRx)) { $out += $f }
    elseif ($Report) { Write-Mig ('startup shortcut "' + $f.Name + '" has a Pillagers-like name but does not start this repository, so it is left alone.') 'WARN' }
  }
  return @($out)
}

# ------------------------------------------------------------------ UNDO
if ($Undo) {
  Write-MigBlank
  Write-Mig '=== HOST STOP: UNDO (switch Pillagers back on, on this PC) ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  Write-Mig 'WARNING: two machines must never ship Pillagers at the same time. Do this only if the VM has NOT started its runner or helpers.' 'WARN'
  if ($st['markerPushedToVm']) { Write-Mig 'The VM was told the host was stopped. After this undo, do not start the runner in the VM.' 'WARN' }
  $undoVmRunning = $false
  $revokeOk = $false
  try {
    $vmNow = Get-VM -Name $VMName -ErrorAction Stop
    if ($vmNow.State -eq 'Running') { $undoVmRunning = $true; Write-Mig ('The VM "' + $VMName + '" is RUNNING right now. If its runner or helpers are on, switching this PC on as well makes two shippers. Check inside the VM first.') 'WARN' }
  } catch { }
  if (-not (Confirm-Typed 'Switch Pillagers back on here? (-Yes does not skip this question.)' 'RESUME')) { Write-Mig 'Cancelled. Nothing changed.' 'INFO'; Exit-Mig 0 }

  Write-Mig 'Step 1: scheduled tasks' 'STEP'
  $names = @($st['disabledTasks'])
  $enableUnrecorded = $false
  if ($names.Count -eq 0) {
    # No record of what this script switched off. Tasks that are off now may have been off long before (your own choice), so never switch them on silently.
    $offNow = @(Get-PillagersTasks -Report | Where-Object { $_.State -eq 'Disabled' })
    if ($offNow.Count -gt 0) {
      Write-Mig ('There is no record of what this script switched off. These Pillagers tasks are off now: ' + (($offNow | ForEach-Object { $_.TaskName }) -join ', ')) 'WARN'
      if (Confirm-Typed 'They may have been off before this script ran. Switch them all on?' 'ENABLE') {
        $enableUnrecorded = $true
        foreach ($t in $offNow) { $names += $t.TaskName }
      } else { Write-Mig 'left off. Switch on any you want by hand in Task Scheduler.' 'SKIP' }
    }
  }
  foreach ($n in $names) {
    $t = Get-PillagersTasks | Where-Object { $_.TaskName -eq $n } | Select-Object -First 1
    if (-not $t) { Write-Mig ('task "' + $n + '" is not there any more') 'SKIP'; continue }
    if ($DryRun) { Write-Mig ('would enable task "' + $n + '"') 'DRY'; continue }
    try { Enable-ScheduledTask -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction Stop | Out-Null; Write-Mig ('task "' + $n + '" is enabled again') 'OK' }
    catch { Write-Mig ('could not enable "' + $n + '": ' + $_.Exception.Message + ' (run this again in an administrator window)') 'WARN'; $needAdmin = $true }
  }

  Write-Mig 'Step 2: startup shortcut' 'STEP'
  foreach ($r in @($st['renamedStartup'])) {
    if ($r.to -and (Test-Path -LiteralPath $r.to)) {
      if ($DryRun) { Write-Mig ('would rename back: ' + $r.to) 'DRY' }
      else { try { Move-Item -LiteralPath $r.to -Destination $r.from -Force -ErrorAction Stop; Write-Mig ('restored ' + $r.from) 'OK' } catch { Write-Mig ('could not restore ' + $r.from + ': ' + $_.Exception.Message) 'WARN' } }
    } else { Write-Mig ('nothing to restore for ' + $r.from) 'SKIP' }
  }
  foreach ($f in (Get-ChildItem -LiteralPath $startupDir -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '(?i)(pillagers|dark.?raiders).*\.lnk\.disabled$' })) {
    $back = $f.FullName.Substring(0, $f.FullName.Length - '.disabled'.Length)
    $recorded = $false
    foreach ($r in @($st['renamedStartup'])) { if ($r.to -and ($r.to -ieq $f.FullName)) { $recorded = $true } }
    if (-not $recorded -and -not $enableUnrecorded) { Write-Mig ('left off (not switched off by this script): ' + $f.Name) 'SKIP'; continue }
    if (-not (Test-Path -LiteralPath $back)) {
      if ($DryRun) { Write-Mig ('would rename back: ' + $f.Name) 'DRY' }
      else { try { Move-Item -LiteralPath $f.FullName -Destination $back -Force -ErrorAction Stop; Write-Mig ('restored ' + $back) 'OK' } catch { } }
    }
  }

  Write-Mig 'Step 3: stop signs and the marker' 'STEP'
  foreach ($p in @($st['createdFiles'])) {
    if (Test-Path -LiteralPath $p) {
      if ($DryRun) { Write-Mig ('would remove ' + $p) 'DRY' } else { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue; Write-Mig ('removed ' + $p) 'OK' }
    }
  }
  foreach ($p in @($markerPath, ((Get-GitDir) + '\PILLAGERS_MOVED_TO_VM.txt'))) {
    if (Test-Path -LiteralPath $p) {
      if ($DryRun) { Write-Mig ('would remove ' + $p) 'DRY' } else { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue; Write-Mig ('removed ' + $p) 'OK' }
    }
  }

  Write-Mig 'Step 4: tell the VM the host is running again (best effort)' 'STEP'
  if ($DryRun) { Write-Mig 'would overwrite C:\PillagersMove\kit\host-stopped.txt in the VM with a "revoked" note' 'DRY' }
  elseif (-not $isAdmin) { Write-Mig ('Not an administrator window, so the VM was not told. If the VM already has the marker, delete ' + $script:GuestStage + '\kit\host-stopped.txt inside the VM (or run host-push-files.ps1 as administrator).') 'WARN' }
  else {
    try {
      $vm = Get-VM -Name $VMName -ErrorAction Stop
      if ($vm.State -ne 'Running') { Write-Mig ('The VM is not running. If it holds the marker, delete ' + $script:GuestStage + '\kit\host-stopped.txt inside the VM before using it.') 'WARN' }
      else {
        $tmp = Join-Path $env:TEMP 'host-stopped.txt'
        Write-AsciiFile -Path $tmp -Text ("PILLAGERS HOST RUNNING AGAIN`nstatus=revoked`ncomputer=" + $env:COMPUTERNAME + "`ntime=" + (Get-Date).ToString('s') + "`nNote=the host Pillagers is switched back on; the VM must not run the runner or helpers.`n")
        if (Copy-ToGuest -VMName $VMName -Source $tmp -GuestPath ($script:GuestStage + '\kit\host-stopped.txt')) { $revokeOk = $true; Write-Mig 'The VM now holds a "revoked" marker (its runner guard stops starting the runner at the next 15-minute tick).' 'OK' }
        else { Write-Mig ('Could not reach the VM. Delete ' + $script:GuestStage + '\kit\host-stopped.txt inside the VM.') 'WARN' }
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
      }
    } catch { Write-Mig ('Could not check the VM (' + $_.Exception.Message + '). Delete ' + $script:GuestStage + '\kit\host-stopped.txt inside the VM if it is there.') 'WARN' }
  }

  Write-Mig 'Step 5: start everything again (tools\party-start.ps1: servers, runner, dashboard, Ollama if needed)' 'STEP'
  $ps = $R + '\tools\party-start.ps1'
  if (-not (Test-Path -LiteralPath $ps)) { Write-Mig ('party-start.ps1 is missing: ' + $ps + '. Start the servers with tools\start-servers.ps1 and the runner with tools\runner-start.vbs.') 'WARN' }
  elseif ($DryRun) { Write-Mig 'would run tools\party-start.ps1' 'DRY' }
  elseif ($undoVmRunning -and -not $revokeOk -and -not (Confirm-Typed 'The VM is RUNNING and was NOT told to stop (the "revoked" marker did not arrive). Starting Pillagers here now could make TWO shippers. Start it anyway?' 'START ANYWAY')) {
    Write-Mig 'Pillagers was NOT started on this PC. First stop the runner inside the VM (Disable-ScheduledTask -TaskName "Pillagers runner") and delete C:\PillagersMove\kit\host-stopped.txt there; then start it here with tools\party-start.ps1.' 'WARN'
  }
  else {
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps 2>&1
    foreach ($l in @($out)) { Write-Mig ('   ' + [string]$l) 'INFO' }
  }
  if (-not $DryRun) { Remove-Item -LiteralPath $stateFile -Force -ErrorAction SilentlyContinue }
  Write-MigBlank
  if ($needAdmin) { Write-Mig 'Some steps need an administrator window. Right-click PowerShell, "Run as administrator", and run this again with -Undo.' 'WARN'; Exit-Mig 3 }
  Write-Mig 'Undo finished. The robots, helpers and tests come back by themselves within about 10 minutes.' 'DONE'
  Write-Mig 'tools\migrate\.gitignore stays in place (on purpose, so the move kit''s big and personal files are never committed by a ship).' 'INFO'
  Exit-Mig 0
}

# ------------------------------------------------------------------ STOP
Write-MigBlank
Write-Mig '=== HOST STOP: stop Pillagers on this PC (it moves into the VM) ===' 'STEP'
if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
Write-Mig 'This will: put up stop signs, switch off the "Pillagers runner" scheduled task and the startup shortcut, wait for any ship to finish,' 'INFO'
Write-Mig 'then stop the runner, helpers, robots, test browsers and test servers, and finally write host-stopped.txt.' 'INFO'
Write-Mig 'It will NOT touch: your normal Chrome, the Claude app or your Claude Code sessions, Windows or security settings.' 'INFO'
if ($KeepPlayServers) { Write-Mig 'The play server (:8802) and collector (:8799) will be left running (-KeepPlayServers).' 'INFO' } else { Write-Mig 'The play server (:8802) and collector (:8799) WILL be stopped too (use -KeepPlayServers to keep them).' 'INFO' }
if ($StopOllama) { Write-Mig 'Ollama will be stopped (-StopOllama).' 'INFO' } else { Write-Mig 'Ollama is left running (add -StopOllama to stop it).' 'INFO' }
if (-not (Confirm-Plain 'Stop Pillagers on this PC now?')) { Write-Mig 'Cancelled. Nothing changed.' 'INFO'; Exit-Mig 0 }

$snap = Get-ProcSnap
$git = Get-GitExe
if (-not $git) { Write-Mig 'git.exe was not found, so the repository state cannot be recorded.' 'FAIL'; Exit-Mig 1 }
$ancJobs = @(Get-AncestorJobNames $snap)
if ($ancJobs.Count -gt 0) {
  Write-Mig ('This window was started by a Pillagers job (' + ($ancJobs -join ', ') + '). That job is left running (stopping it would stop this script), so the final check will fail.') 'WARN'
  Write-Mig 'Open a normal PowerShell window from your own desktop (not from a helper or the runner) and run this again.' 'WARN'
}

# ---- step 1: stop signs
Write-MigBlank
Write-Mig 'Step 1 of 8: stop signs (no new work starts)' 'STEP'
foreach ($p in @(($C + '\STOP'), ($X + '\STOP'), ($H + '\stable.freeze'))) {
  if (Test-Path -LiteralPath $p) { Write-Mig ('already there: ' + $p) 'SKIP'; continue }
  if ($DryRun) { Write-Mig ('would create ' + $p) 'DRY'; continue }
  $dir = Split-Path -Path $p -Parent
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Set-Content -LiteralPath $p -Value ('stopped for the VM move ' + (Get-Date -Format 's')) -Encoding ASCII
  Add-StateItem 'createdFiles' $p
  Write-Mig ('created ' + $p) 'OK'
}
# keep the kit folder out of every ship (tools/migrate holds your wallpaper and Start layout)
[void](Ensure-KitExcluded -DryRun:$DryRun)
Save-StopState

# ---- step 2: scheduled task and startup shortcut
Write-MigBlank
Write-Mig 'Step 2 of 8: switch off the scheduled task and the startup shortcut' 'STEP'
$tasks = @(Get-PillagersTasks -Report)
if ($tasks.Count -eq 0) { Write-Mig 'no Pillagers scheduled task found' 'SKIP' }
foreach ($t in $tasks) {
  if ($t.State -eq 'Disabled') { Write-Mig ('task "' + $t.TaskName + '" is already off') 'SKIP'; continue }
  if ($DryRun) { Write-Mig ('would disable task "' + $t.TaskName + '"') 'DRY'; continue }
  try {
    Disable-ScheduledTask -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction Stop | Out-Null
    $chk = Get-ScheduledTask -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction Stop
    if ($chk.State -eq 'Disabled') { Add-StateItem 'disabledTasks' $t.TaskName; Write-Mig ('task "' + $t.TaskName + '" is switched off') 'OK' }
    else { Write-Mig ('task "' + $t.TaskName + '" is still ' + $chk.State) 'WARN'; $needAdmin = $true }
  } catch {
    Write-Mig ('could not switch off task "' + $t.TaskName + '": ' + $_.Exception.Message) 'WARN'
    $needAdmin = $true
  }
}
foreach ($f in (Get-StartupLinks -Report)) {
  if ($f.Name -match '\.disabled$') { continue }
  if ($f.Extension -ine '.lnk') { continue }
  $to = $f.FullName + '.disabled'
  if ($DryRun) { Write-Mig ('would rename startup shortcut "' + $f.Name + '" to "' + $f.Name + '.disabled"') 'DRY'; continue }
  try {
    Move-Item -LiteralPath $f.FullName -Destination $to -Force -ErrorAction Stop
    Add-StateItem 'renamedStartup' ([pscustomobject]@{ from = $f.FullName; to = $to })
    Write-Mig ('startup shortcut renamed: ' + $f.Name + ' -> ' + $f.Name + '.disabled') 'OK'
  } catch { Write-Mig ('could not rename ' + $f.Name + ': ' + $_.Exception.Message) 'WARN' }
}
if ($needAdmin -and -not $isAdmin) { Write-Mig 'Windows refused to switch the task off from a normal window. After this run, open PowerShell with "Run as administrator" and run this script again.' 'WARN' }
Save-StopState

# ---- step 3: the runner
Write-MigBlank
Write-Mig 'Step 3 of 8: stop the always-on runner (nightly.sh), so nothing new starts' 'STEP'
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxRunner) -What 'runner (nightly.sh)' -DryRun:$DryRun)

# ---- step 4: let helpers and ships finish, then stop helpers
Write-MigBlank
Write-Mig ('Step 4 of 8: let helpers and any ship finish by themselves (up to ' + $WaitMinutes + ' minutes)') 'STEP'
if ($DryRun) {
  $snap = Get-ProcSnap
  $nh = (Select-HelperProc $snap).Count
  $ns = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count
  $lk = Get-ShipLock
  Write-Mig ('now: ' + $nh + ' helper run(s), ' + $ns + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'HELD (' + $lk.Owner + ')' } else { 'clear' })) 'DRY'
} else {
  $deadline = (Get-Date).AddMinutes($WaitMinutes)
  while ($true) {
    $snap = Get-ProcSnap
    $nh = (Select-HelperProc $snap).Count
    $ns = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count
    $lk = Get-ShipLock
    if ($nh -eq 0 -and $ns -eq 0 -and -not $lk.Exists) { Write-Mig 'no helper is working, no ship is running, the ship lock is clear' 'OK'; break }
    if ((Get-Date) -gt $deadline) {
      if (($ns -gt 0) -or ($lk.Exists -and -not $ClearStale)) {
        # A ship is mid-way (or holds the ship lock). Stopping its helpers, test browsers or servers now could leave the public repository half updated.
        # Stop here and change nothing more. (With -ClearStale a held lock with no ship process is left to step 7 and the official clearstale.sh.)
        Save-StopState
        Write-MigBlank
        Write-Mig ('time is up and a ship is STILL going (' + $ns + ' process(es), ship lock ' + $(if ($lk.Exists) { 'HELD by "' + $lk.Owner + '"' } else { 'clear' }) + '). It is never interrupted, and nothing else was stopped after this point.') 'FAIL'
        Write-Mig 'Already done: stop signs are up, the scheduled task and startup shortcut are off, the runner is stopped. No marker was written, so the VM will refuse to start.' 'FAIL'
        Write-Mig 'Wait for the ship to finish (look at tools\handoff\console for its status), then run this script again. It is safe to repeat. Add -WaitMinutes 60 to wait longer.' 'FAIL'
        Exit-Mig 2
      }
      Write-Mig ('time is up: ' + $nh + ' helper run(s) still going and no ship is running; the helpers will be stopped now') 'WARN'
      break
    }
    $left = [int](($deadline - (Get-Date)).TotalMinutes)
    Write-Mig ('waiting: ' + $nh + ' helper run(s), ' + $ns + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'held' } else { 'clear' }) + ' (' + $left + ' min left)') 'INFO'
    Start-Sleep -Seconds 30
  }
}

# ---- step 5: helpers, lanes, robots, reviewers
Write-MigBlank
Write-Mig 'Step 5 of 8: stop helpers, lanes, robots, the full test run and reviewers' 'STEP'
$snap = Get-ProcSnap
[void](Stop-ProcList -Procs (Select-HelperProc $snap) -What 'helper runs (Claude, Codex or Gemini working on a job)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxLane) -What 'helper lanes (console-lane.sh, codex-lane.sh)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('powershell.exe', 'pwsh.exe') $script:RxFuzz) -What 'crash-hunting robots (fuzz.ps1)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxCorpus) -What 'full test run (corpus)' -DryRun:$DryRun)
if (-not $DryRun) {
  # Leftover lock folders are removed only when nothing that could own them is running any more. The pid inside a lane lock is a Git-Bash pid,
  # not a Windows pid, so "is that pid alive?" cannot be asked; the process command lines are the only reliable test.
  Start-Sleep -Seconds 3
  $snapL = Get-ProcSnap
  $laneLeft = (Select-Proc $snapL @('bash.exe') $script:RxLane).Count + (Select-HelperProc $snapL).Count
  $corpLeft = (Select-Proc $snapL @('bash.exe') $script:RxCorpus).Count
  if ($laneLeft -eq 0) {
    Get-ChildItem -LiteralPath $C -Directory -Filter 'lane-*.lock' -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath ($C + '\pick.lock') -Recurse -Force -ErrorAction SilentlyContinue
    Write-Mig 'old lane locks removed (no lane or helper is running)' 'OK'
  } else { Write-Mig ([string]$laneLeft + ' lane or helper process(es) are still running, so the lane locks were left in place') 'WARN' }
  if ($corpLeft -eq 0) { Remove-Item -LiteralPath ($script:ScratchPad + '\corpus.lock') -Recurse -Force -ErrorAction SilentlyContinue }
  else { Write-Mig 'the full test run is still going, so corpus.lock was left in place' 'WARN' }
}
[void](Stop-ProcList -Procs (Select-Proc $snap @('powershell.exe', 'pwsh.exe', 'bash.exe') $script:RxReview) -What 'reviewers and nightly jobs (ship-review, llm-night, review-nightly, itch-daily, stable)' -DryRun:$DryRun)
if ($StopOllama) {
  $ol = @($snap | Where-Object { $_.Name -match '^(ollama|ollama app|ollama_llama_server)\.exe$' })
  $n = Stop-ProcList -Procs $ol -What 'Ollama' -DryRun:$DryRun
  if ($n -gt 0 -and -not $DryRun) { $st['stoppedOllama'] = $true }
}

# ---- step 6: test browsers and servers
Write-MigBlank
Write-Mig 'Step 6 of 8: stop the hidden test browsers and the servers' 'STEP'
Start-Sleep -Seconds 1
$snap = Get-ProcSnap
if (-not $KeepPlayServers) {
  # The play server (:8802) is stopped on purpose (the party route later needs that port on this PC), but never under somebody's hands.
  $playConns = 0
  try { $playConns = @(Get-NetTCPConnection -State Established -LocalPort 8802, 8799 -ErrorAction Stop).Count } catch { }
  if ($playConns -gt 0) {
    Write-Mig ($playConns.ToString() + ' connection(s) are open to the play server (:8802) or the collector (:8799) right now - a browser tab, a party screen or a test is using them.') 'WARN'
    if (-not (Confirm-Plain 'Stop the play server and collector anyway?')) {
      $KeepPlayServers = $true
      Write-Mig 'Kept running (as if -KeepPlayServers). Stop them yourself before the party route, which needs port 8802 on this PC.' 'INFO'
    }
  }
}
[void](Stop-ProcList -Procs (Get-TestChromes $snap) -What 'hidden test Chromes (ports 93xx / pillagers-cdp profiles; your own Chrome is not matched)' -Tree -DryRun:$DryRun)
function Get-ServerProcsToStop {
  param([object[]]$Snap)
  $all = Select-Proc $Snap @('powershell.exe', 'pwsh.exe') $script:RxServers
  $out = @()
  foreach ($p in $all) {
    $keep = $false
    if ($KeepPlayServers) {
      if ($p.CommandLine -match 'collector\.ps1') { $keep = $true }
      elseif ($p.CommandLine -match 'serve\.ps1') {
        $port = 8802
        if ($p.CommandLine -match '-Port\s+"?(\d+)') { $port = [int]$Matches[1] }
        if ($port -eq 8802) { $keep = $true }
      }
    }
    if (-not $keep) { $out += $p }
  }
  return @($out)
}
[void](Stop-ProcList -Procs (Get-ServerProcsToStop $snap) -What 'servers (serve.ps1, collector.ps1, capture.ps1)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Get-DashboardProcs $snap) -What 'Pillagers Dev Console (dashboard, port 8820)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('python.exe', 'pythonw.exe', 'py.exe') $script:RxPyPages) -What 'survey page servers (ports 8871, 8872)' -DryRun:$DryRun)
Save-StopState

# ---- step 7: wait for the ship lock and check everything
Write-MigBlank
Write-Mig ('Step 7 of 8: wait for the ship lock (up to ' + $LockWaitMinutes + ' minutes) and check') 'STEP'
$clearTried = $false
if (-not $DryRun) {
  $deadline2 = (Get-Date).AddMinutes($LockWaitMinutes)
  while ($true) {
    $snap = Get-ProcSnap
    $ns = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count
    $lk = Get-ShipLock
    if ($ns -eq 0 -and -not $lk.Exists) { Write-Mig 'ship lock is clear and no ship is running' 'OK'; break }
    if ((Get-Date) -gt $deadline2) {
      if ($ClearStale -and -not $clearTried -and $lk.Exists -and $ns -eq 0) {
        $clearTried = $true
        Write-Mig 'time is up; asking the official tool (clearstale.sh) whether the lock is stale ...' 'WARN'
        $cs = $script:ScratchPad + '\clearstale.sh'
        if (-not (Test-Path -LiteralPath $cs)) { $cs = $R + '\tools\handoff\shipkit\clearstale.sh' }
        if (Test-Path -LiteralPath $cs) {
          $out = & $script:GitBash ($cs.Replace('\', '/')) 2>&1
          foreach ($l in @($out)) { Write-Mig ('   ' + [string]$l) 'INFO' }
        } else { Write-Mig 'clearstale.sh was not found' 'WARN' }
        $deadline2 = (Get-Date).AddSeconds(20)
        continue
      }
      Write-Mig ('time is up: ' + $ns + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'HELD by "' + $lk.Owner + '" for ' + $lk.AgeMin + ' min' } else { 'clear' })) 'FAIL'
      break
    }
    Write-Mig ('waiting: ' + $ns + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'held (' + $lk.Owner + ')' } else { 'clear' })) 'INFO'
    Start-Sleep -Seconds 15
  }
  Start-Sleep -Seconds 2
}
$snap = Get-ProcSnap
$rows = [ordered]@{}
$rows['runner (nightly.sh)']         = (Select-Proc $snap @('bash.exe') $script:RxRunner).Count
$rows['helper lanes']                = (Select-Proc $snap @('bash.exe') $script:RxLane).Count
$rows['helper runs']                 = (Select-HelperProc $snap).Count
$rows['ships in progress']           = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count
$rows['robots (fuzz)']               = (Select-Proc $snap @('powershell.exe', 'pwsh.exe') $script:RxFuzz).Count
$rows['full test run']               = (Select-Proc $snap @('bash.exe') $script:RxCorpus).Count
$rows['reviewers / nightly jobs']    = (Select-Proc $snap @('powershell.exe', 'pwsh.exe', 'bash.exe') $script:RxReview).Count
$rows['hidden test Chromes']         = (Get-TestChromes $snap).Count
$rows['servers']                     = (Get-ServerProcsToStop $snap).Count
$rows['dashboard (8820)']            = (Get-DashboardProcs $snap).Count
if ($StopOllama) { $rows['Ollama'] = @($snap | Where-Object { $_.Name -match '^(ollama|ollama app|ollama_llama_server)\.exe$' }).Count }
$allOk = $true
foreach ($k in $rows.Keys) {
  if ($rows[$k] -eq 0) { Write-Mig ('STOPPED        ' + $k) 'OK' }
  else { Write-Mig ('STILL RUNNING  ' + $k + ' (' + $rows[$k] + ')') $(if ($DryRun) { 'DRY' } else { 'FAIL' }); $allOk = $false }
}
$lk = Get-ShipLock
if ($lk.Exists) { Write-Mig ('SHIP LOCK HELD ' + $lk.Owner) $(if ($DryRun) { 'DRY' } else { 'FAIL' }); $allOk = $false } else { Write-Mig 'ship lock is clear' 'OK' }
$tasksNow = @(Get-PillagersTasks)
$taskOn = @($tasksNow | Where-Object { $_.State -ne 'Disabled' })
if ($ancJobs.Count -gt 0) { Write-Mig ('STILL RUNNING  the Pillagers job that started this window (' + ($ancJobs -join ', ') + ')') $(if ($DryRun) { 'DRY' } else { 'FAIL' }); $allOk = $false }
if ($taskOn.Count -gt 0) { Write-Mig ('SCHEDULED TASK STILL ON: ' + (($taskOn | ForEach-Object { $_.TaskName }) -join ', ')) $(if ($DryRun) { 'DRY' } else { 'FAIL' }); $allOk = $false } else { Write-Mig 'scheduled task is off (or there is none)' 'OK' }
foreach ($p in @(($C + '\STOP'), ($X + '\STOP'), ($H + '\stable.freeze'))) {
  if (-not (Test-Path -LiteralPath $p)) { if (-not $DryRun) { Write-Mig ('stop sign missing: ' + $p) 'FAIL'; $allOk = $false } }
}
$ollamaRunning = @($snap | Where-Object { $_.Name -match '^(ollama|ollama app|ollama_llama_server)\.exe$' }).Count
if (-not $StopOllama -and $ollamaRunning -gt 0) { Write-Mig 'Ollama is still running (left alone on purpose)' 'INFO' }
if ($KeepPlayServers) { Write-Mig 'play server (:8802) and collector (:8799) kept running on purpose' 'INFO' }

# The two hourly Claude watchdogs (Claude scheduled tasks, not Windows tasks) restart servers and resume the queue when nobody works.
$wd = @()
foreach ($n in @('pillagers-watchdog', 'dark-raiders-watchdog')) { if (Test-Path -LiteralPath ($script:HostProfile + '\.claude\scheduled-tasks\' + $n + '\SKILL.md')) { $wd += $n } }
if ($wd.Count -gt 0) { Write-Mig ('Claude scheduled tasks that could restart Pillagers here: ' + ($wd -join ', ') + '. In the Claude app, Scheduled tasks, make sure they are OFF (this script cannot see or change them).') 'WARN' }

$repo = Get-RepoState
$gf = Get-GpuHostFacts
$drift = ''
if ($gf.Ok) { $drift = Compare-GpuDrift $gf } else { $drift = 'unknown (' + $gf.Error + ')' }
if ($repo.Ok) {
  Write-Mig ('repository: HEAD ' + $repo.Head.Substring(0, 8) + ' on ' + $repo.Branch + ', ' + $(if ($repo.Ahead -gt 0) { $repo.Ahead.ToString() + ' commit(s) not pushed to GitHub yet (they travel inside the copied .git)' } elseif ($repo.Ahead -eq 0) { 'same as origin/master' } else { 'origin/master not known' }) + ', ' + $repo.DirtyCount + ' changed file(s)') 'INFO'
} else { Write-Mig 'could not read the repository state' 'WARN'; $allOk = $false }
if ($drift) { Write-Mig ('GPU driver pack: ' + $drift) 'WARN' } else { Write-Mig 'GPU driver pack matches this PC' 'OK' }

# ---- step 8: marker
Write-MigBlank
Write-Mig 'Step 8 of 8: marker for the VM' 'STEP'
if ($DryRun) {
  Write-Mig ('would write ' + $markerPath + ' (with a check= line, and .git\PILLAGERS_MOVED_TO_VM.txt) when every line above says STOPPED') 'DRY'
  Exit-Mig 0
}
if (-not $allOk) {
  Remove-Item -LiteralPath $markerPath -Force -ErrorAction SilentlyContinue
  Save-StopState
  Write-MigBlank
  if ($needAdmin -and -not $isAdmin) { Write-Mig 'NOT FINISHED: the scheduled task could not be switched off from this window. Run this script again in an administrator PowerShell window.' 'FAIL'; Exit-Mig 3 }
  Write-Mig 'NOT FINISHED: something above is still running or locked. No marker was written, so the VM will refuse to start. Fix it (or wait) and run this script again - it is safe to repeat.' 'FAIL'
  Exit-Mig 2
}
$now = Get-Date
$lines = @(
  'PILLAGERS HOST STOPPED',
  'status=stopped',
  ('computer=' + $env:COMPUTERNAME),
  ('user=' + $env:USERNAME),
  ('time=' + $now.ToString('s')),
  ('timeUtc=' + $now.ToUniversalTime().ToString('s') + 'Z'),
  ('epoch=' + [DateTimeOffset]::Now.ToUnixTimeSeconds()),
  ('gitHead=' + $repo.Head),
  ('originMaster=' + $repo.Origin),
  ('unpushedCommits=' + $repo.Ahead),
  ('changedFiles=' + $repo.DirtyCount),
  'shipLockClear=yes',
  'runnerTaskDisabled=yes',
  'lanesRunning=0',
  ('playServersKept=' + $(if ($KeepPlayServers) { 'yes' } else { 'no' })),
  ('gpuPack=' + $(if ($drift) { $drift } else { 'ok' })),
  'note=The VM may start the runner and helpers only while this file says status=stopped.'
)
# check= is a SHA-256 over every line above (see Get-MarkerCheck in host-common.ps1). The VM refuses a marker whose check does not match,
# so a hand-edited, half-written or glued-together file cannot unlock the runner. Written to a temp name first, then renamed in one step.
$lines += ('check=' + (Get-MarkerCheck $lines))
$markerTmp = $markerPath + '.tmp'
Write-AsciiFile -Path $markerTmp -Text (($lines -join "`n") + "`n")
Move-Item -LiteralPath $markerTmp -Destination $markerPath -Force
Write-Mig ('wrote ' + $markerPath) 'OK'
try {
  $gm = (Get-GitDir) + '\PILLAGERS_MOVED_TO_VM.txt'
  Write-AsciiFile -Path $gm -Text ("Pillagers development moved to the VM " + $VMName + " on " + $now.ToString('s') + ".`nDo not run the runner, helpers or ships on this PC while the VM is the shipper.`nUndo: tools\migrate\host-stop.ps1 -Undo`n")
  Write-Mig 'wrote .git\PILLAGERS_MOVED_TO_VM.txt (a reminder inside .git; it is never committed or copied)' 'OK'
} catch { Write-Mig 'could not write the reminder inside .git' 'WARN' }
Save-StopState

Write-MigBlank
Write-Mig 'DONE. Pillagers is stopped on this PC.' 'DONE'
Write-Mig 'Next: send the final copy of your files to the VM with' 'INFO'
Write-Mig '   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -Final    (run it in an administrator window)' 'INFO'
Write-Mig 'Then, inside the VM, run vm-setup.ps1 for the files, services and health stages. To go back to this PC: host-stop.ps1 -Undo' 'INFO'
Exit-Mig 0
