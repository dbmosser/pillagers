# host-stop.ps1 : stops Pillagers development on THIS PC so it can carry on inside the VM. -Undo puts everything back.
#
# Run it from a normal PowerShell window (an administrator window is only needed to switch off the scheduled task, if Windows says "Access is denied"):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1"
#   -DryRun            only print what it WOULD do (changes nothing)
#   -Undo              switch everything back on (uses tools\party-start.ps1 for the restart)
#   -WaitMinutes N     how long helpers and ships may finish by themselves before the helpers are stopped (default 20)
#   -LockWaitMinutes N how long to wait for the ship lock to clear (default 30)
#   -ClearStale        if the ship lock is still there after that, ask the official tool (clearstale.sh) whether it is stale
#   -KeepPlayServers   leave the play server (:8802) and the collector (:8799) running
#   -StopOllama        also stop Ollama (it is left alone by default)
#   -Yes               do not ask for confirmation
#   -VMName NAME       the VM (used only to tell it the host is running again, on -Undo)
#
# What it never touches: your normal Chrome, the Claude desktop app and any Claude Code session of yours, Ollama (unless asked),
# Windows settings, security settings. It only stops Pillagers background work and writes the marker file the VM checks.
# Order: stop signs, scheduled task + startup shortcut, runner, wait for helpers and the ship lock, helpers/lanes/robots, test browsers
# and servers, check, marker (host-stopped.txt in this folder).
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

function Get-StartupLinks {
  $out = @()
  if (-not (Test-Path -LiteralPath $startupDir)) { return @() }
  foreach ($f in (Get-ChildItem -LiteralPath $startupDir -File -Force -ErrorAction SilentlyContinue)) {
    if ($f.Name -match '(?i)pillagers|dark.?raiders') { $out += $f }
  }
  return @($out)
}

function Get-PillagersTasks {
  return @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match '(?i)pillagers|dark.?raiders' })
}

# ------------------------------------------------------------------ UNDO
if ($Undo) {
  Write-MigBlank
  Write-Mig '=== HOST STOP: UNDO (switch Pillagers back on, on this PC) ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  Write-Mig 'WARNING: two machines must never ship Pillagers at the same time. Do this only if the VM has NOT started its runner or helpers.' 'WARN'
  if ($st['markerPushedToVm']) { Write-Mig 'The VM was told the host was stopped. After this undo, do not start the runner in the VM.' 'WARN' }
  if (-not (Confirm-Plain 'Switch Pillagers back on here?')) { Write-Mig 'Cancelled. Nothing changed.' 'INFO'; Exit-Mig 0 }

  Write-Mig 'Step 1: scheduled tasks' 'STEP'
  $names = @($st['disabledTasks'])
  if ($names.Count -eq 0) {
    foreach ($t in (Get-PillagersTasks)) { if ($t.State -eq 'Disabled') { $names += $t.TaskName } }
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
        if (Copy-ToGuest -VMName $VMName -Source $tmp -GuestPath ($script:GuestStage + '\kit\host-stopped.txt')) { Write-Mig 'The VM now holds a "revoked" marker.' 'OK' }
        else { Write-Mig ('Could not reach the VM. Delete ' + $script:GuestStage + '\kit\host-stopped.txt inside the VM.') 'WARN' }
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
      }
    } catch { Write-Mig ('Could not check the VM (' + $_.Exception.Message + '). Delete ' + $script:GuestStage + '\kit\host-stopped.txt inside the VM if it is there.') 'WARN' }
  }

  Write-Mig 'Step 5: start everything again (tools\party-start.ps1: servers, runner, dashboard, Ollama if needed)' 'STEP'
  $ps = $R + '\tools\party-start.ps1'
  if (-not (Test-Path -LiteralPath $ps)) { Write-Mig ('party-start.ps1 is missing: ' + $ps + '. Start the servers with tools\start-servers.ps1 and the runner with tools\runner-start.vbs.') 'WARN' }
  elseif ($DryRun) { Write-Mig 'would run tools\party-start.ps1' 'DRY' }
  else {
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ps 2>&1
    foreach ($l in @($out)) { Write-Mig ('   ' + [string]$l) 'INFO' }
  }
  if (-not $DryRun) { Remove-Item -LiteralPath $stateFile -Force -ErrorAction SilentlyContinue }
  Write-MigBlank
  if ($needAdmin) { Write-Mig 'Some steps need an administrator window. Right-click PowerShell, "Run as administrator", and run this again with -Undo.' 'WARN'; Exit-Mig 3 }
  Write-Mig 'Undo finished. The robots, helpers and tests come back by themselves within about 10 minutes.' 'DONE'
  Write-Mig '.git\info\exclude still lists tools/migrate/ (on purpose, so your wallpaper and Start layout are never committed).' 'INFO'
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
$tasks = @(Get-PillagersTasks)
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
foreach ($f in (Get-StartupLinks)) {
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
  $nh = (Select-Proc $snap @('node.exe', 'claude.exe') $script:RxHelper).Count
  $ns = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count
  $lk = Get-ShipLock
  Write-Mig ('now: ' + $nh + ' helper run(s), ' + $ns + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'HELD (' + $lk.Owner + ')' } else { 'clear' })) 'DRY'
} else {
  $deadline = (Get-Date).AddMinutes($WaitMinutes)
  while ($true) {
    $snap = Get-ProcSnap
    $nh = (Select-Proc $snap @('node.exe', 'claude.exe') $script:RxHelper).Count
    $ns = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count
    $lk = Get-ShipLock
    if ($nh -eq 0 -and $ns -eq 0 -and -not $lk.Exists) { Write-Mig 'no helper is working, no ship is running, the ship lock is clear' 'OK'; break }
    if ((Get-Date) -gt $deadline) { Write-Mig ('time is up: ' + $nh + ' helper run(s) and ' + $ns + ' ship process(es) still going; helpers will be stopped, ships are never stopped') 'WARN'; break }
    $left = [int](($deadline - (Get-Date)).TotalMinutes)
    Write-Mig ('waiting: ' + $nh + ' helper run(s), ' + $ns + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'held' } else { 'clear' }) + ' (' + $left + ' min left)') 'INFO'
    Start-Sleep -Seconds 30
  }
}

# ---- step 5: helpers, lanes, robots, reviewers
Write-MigBlank
Write-Mig 'Step 5 of 8: stop helpers, lanes, robots, the full test run and reviewers' 'STEP'
$snap = Get-ProcSnap
[void](Stop-ProcList -Procs (Select-Proc $snap @('node.exe', 'claude.exe') $script:RxHelper) -What 'helper runs (Claude, Codex or Gemini working on a job)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxLane) -What 'helper lanes (console-lane.sh, codex-lane.sh)' -DryRun:$DryRun)
if (-not $DryRun) {
  Start-Sleep -Seconds 2
  Get-ChildItem -LiteralPath $C -Directory -Filter 'lane-*.lock' -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
  Remove-Item -LiteralPath ($C + '\pick.lock') -Recurse -Force -ErrorAction SilentlyContinue
  Write-Mig 'old lane locks removed' 'OK'
}
[void](Stop-ProcList -Procs (Select-Proc $snap @('powershell.exe', 'pwsh.exe') $script:RxFuzz) -What 'crash-hunting robots (fuzz.ps1)' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxCorpus) -What 'full test run (corpus)' -DryRun:$DryRun)
if (-not $DryRun) { Remove-Item -LiteralPath ($script:ScratchPad + '\corpus.lock') -Recurse -Force -ErrorAction SilentlyContinue }
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
$rows['helper runs']                 = (Select-Proc $snap @('node.exe', 'claude.exe') $script:RxHelper).Count
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
  Write-Mig ('would write ' + $markerPath + ' (and .git\PILLAGERS_MOVED_TO_VM.txt) when every line above says STOPPED') 'DRY'
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
Write-AsciiFile -Path $markerPath -Text (($lines -join "`n") + "`n")
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
