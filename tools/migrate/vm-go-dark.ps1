# vm-go-dark.ps1 : run IN THE VM at the cutover (his order 11-02). Plan: tools\handoff\move-to-main-pc-1102.md; how to run: tools\handoff\console\notes\move\kit.md
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-go-dark.ps1 -DryRun        says what it would do, changes nothing
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-go-dark.ps1                goes dark; the VM stays up until the main PC has shipped
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-go-dark.ps1 -ShutdownNow   only the shutdown, by hand, if the watcher did not do it
#
# Steps: STOP files; lets helpers and any ship finish (a ship is never interrupted; it stops here if one outlasts the wait); stops the runner, lanes, itch
# follower, watchers, dashboard and test browsers; the runner cannot start again (RUNNER-OFF.txt, which its guard reads, and the two tasks off if Windows lets
# a normal window do that); commits and pushes what is left under tools/handoff and exports, so the task files and notes reach the main PC through git; packs the final
# scratchpad and memory; installs the Startup entry (vm-stay-off.ps1); writes vm-dark.txt in the bridge share, which is what lets the main PC chat lift its STOP.
# It never touches the game file or tools\mkfixture.ps1, and it stops rather than say dark if the push fails.
# Exit codes: 0 done, 1 error, 2 a ship or helper is still going. ASCII only. Works in Windows PowerShell 5.1.
param([switch]$DryRun, [switch]$ShutdownNow, [switch]$SkipPack, [int]$WaitMinutes = 30)
$ErrorActionPreference = 'Continue'
if ($env:COMPUTERNAME -ieq 'JUL26') { Write-Host 'This one runs in the VM, not on the main PC.'; exit 1 }
. (Join-Path $PSScriptRoot 'host-common.ps1')
Start-MigLog -Name 'vm-go-dark'
$repo = $script:RepoRoot
$C = $repo + '\tools\handoff\console'; $X = $repo + '\tools\handoff\codex'
$hostctl = $repo + '\tools\bridge\hostctl.mjs'
$launch = 'C:\PillagersMove\launchers'; $kit = 'C:\PillagersMove\kit'
$stops = @(($C + '\STOP'), ($X + '\STOP'))

if ($ShutdownNow) {
  foreach ($s in $stops) { if (-not (Test-Path -LiteralPath $s)) { Write-Mig ('no STOP file at ' + $s + ': this VM has not gone dark, so it is not shut down') 'FAIL'; Exit-Mig 1 } }
  if ($DryRun) { Write-Mig 'would run shutdown /s /t 120' 'DRY'; Exit-Mig 0 }
  & shutdown.exe /s /t 120 /c 'Pillagers: dev moved to the main PC; this VM stays off.'
  Write-Mig 'shutting down in 2 minutes' 'DONE'; Exit-Mig 0
}

Write-MigBlank
Write-Mig '=== VM GO DARK ===' 'STEP'
if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }

# ---- 1. stop signs
Write-Mig 'Step 1: STOP files (no new helper, Codex or ship job starts)' 'STEP'
foreach ($p in $stops) {
  if (Test-Path -LiteralPath $p) { Write-Mig ('already there: ' + $p) 'SKIP'; continue }
  if ($DryRun) { Write-Mig ('would create ' + $p) 'DRY'; continue }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $p) | Out-Null
  Set-Content -LiteralPath $p -Value ('dev moved to the main PC ' + (Get-Date -Format 's')) -Encoding ASCII
  Write-Mig ('created ' + $p) 'OK'
}
if (-not $DryRun) {
  $ex = $repo + '\.git\info\exclude'; $t = ''; if (Test-Path -LiteralPath $ex) { $t = Get-Content -LiteralPath $ex -Raw }
  foreach ($l in @('tools/handoff/console/STOP', 'tools/handoff/codex/STOP')) { if ($t -notmatch [regex]::Escape($l)) { Add-Content -LiteralPath $ex -Value $l -Encoding ASCII } }
}

# ---- 2. the runner first, so nothing new starts; then let helpers and ships end by themselves
Write-Mig 'Step 2: stop the runner, then let helpers and any ship finish' 'STEP'
$snap = Get-ProcSnap
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxRunner) -What 'runner (nightly.sh)' -DryRun:$DryRun)
if ($DryRun) {
  $snap = Get-ProcSnap; $lk = Get-ShipLock
  Write-Mig ('now: ' + (Select-HelperProc $snap).Count + ' helper run(s), ' + (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count + ' ship process(es), ship lock ' + $(if ($lk.Exists) { 'HELD (' + $lk.Owner + ')' } else { 'clear' })) 'DRY'
} else {
  $deadline = (Get-Date).AddMinutes($WaitMinutes)
  while ($true) {
    $snap = Get-ProcSnap
    $nh = (Select-HelperProc $snap).Count; $ns = (Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count; $lk = Get-ShipLock
    if ($nh -eq 0 -and $ns -eq 0 -and -not $lk.Exists) { Write-Mig 'no helper is working, no ship is running, the ship lock is clear' 'OK'; break }
    if ((Get-Date) -gt $deadline) {
      if ($ns -gt 0 -or $lk.Exists) { Write-Mig ('time is up and a ship is still going (' + $ns + ' process(es), lock ' + $(if ($lk.Exists) { 'held by ' + $lk.Owner } else { 'clear' }) + '). A ship is never interrupted. The STOP files stay; run this again when it ends.') 'FAIL'; Exit-Mig 2 }
      Write-Mig ('time is up: ' + $nh + ' helper run(s) still going, no ship; those helpers are stopped now and their jobs stay in tasks/') 'WARN'; break
    }
    Write-Mig ('waiting: ' + $nh + ' helper run(s), ' + $ns + ' ship process(es), lock ' + $(if ($lk.Exists) { 'held' } else { 'clear' }) + ' (' + [int]($deadline - (Get-Date)).TotalMinutes + ' min left)') 'INFO'
    Start-Sleep -Seconds 30
  }
}

# ---- 3. everything else that works on its own
Write-Mig 'Step 3: stop lanes, followers, watchers, the dashboard and test browsers' 'STEP'
$snap = Get-ProcSnap
[void](Stop-ProcList -Procs (Select-HelperProc $snap) -What 'helper runs' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') $script:RxLane) -What 'helper lanes' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('powershell.exe', 'pwsh.exe', 'bash.exe') $script:RxReview) -What 'itch follower, reviewers, nightly jobs' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('bash.exe') 'ceo-watch\.sh|dashwatch\.sh') -What 'CEO and dashboard watchers' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Select-Proc $snap @('powershell.exe', 'pwsh.exe') $script:RxServers) -What 'servers in the VM' -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Get-TestChromes $snap) -What 'hidden test Chromes (your own Chrome is not matched)' -Tree -DryRun:$DryRun)
[void](Stop-ProcList -Procs (Get-DashboardProcs $snap) -What 'dashboard (8820)' -DryRun:$DryRun)
if (-not $DryRun) {
  Start-Sleep -Seconds 3
  $snapL = Get-ProcSnap
  if (((Select-Proc $snapL @('bash.exe') $script:RxLane).Count + (Select-HelperProc $snapL).Count) -eq 0) {
    Get-ChildItem -LiteralPath $C -Directory -Filter 'lane-*.lock' -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    foreach ($d in @('pick.lock', 'start.lock')) { Remove-Item -LiteralPath (Join-Path $C $d) -Recurse -Force -ErrorAction SilentlyContinue }
  } else { Write-Mig 'a lane or helper is still running, so the lane locks stay' 'WARN' }
}

# ---- 4. the runner cannot come back here
Write-Mig 'Step 4: the runner cannot start again in this VM' 'STEP'
$off = Join-Path $launch 'RUNNER-OFF.txt'
if ($DryRun) { Write-Mig ('would write ' + $off + ' (its guard reads that every 15 minutes)') 'DRY' }
elseif (Test-Path -LiteralPath $launch) { Set-Content -LiteralPath $off -Value ('dev moved to the main PC ' + (Get-Date -Format 's')) -Encoding ASCII; Write-Mig ('wrote ' + $off) 'OK' }
else { Write-Mig ($launch + ' does not exist') 'WARN' }
foreach ($tn in @('Pillagers runner', 'Pillagers dev services')) {
  $t = Get-ScheduledTask -TaskName $tn -ErrorAction SilentlyContinue
  if (-not $t) { Write-Mig ('task "' + $tn + '": not here') 'SKIP'; continue }
  if ($t.State -eq 'Disabled') { Write-Mig ('task "' + $tn + '": already off') 'SKIP'; continue }
  if ($DryRun) { Write-Mig ('would switch off task "' + $tn + '" (' + $t.Principal.RunLevel + ')') 'DRY'; continue }
  try { Disable-ScheduledTask -TaskName $tn -ErrorAction Stop | Out-Null; Write-Mig ('task "' + $tn + '" is off') 'OK' }
  catch { Write-Mig ('task "' + $tn + '" stays on (Windows wants an administrator window for that); RUNNER-OFF.txt and the STOP files hold anyway') 'WARN' }
}

# ---- 5. what is left under tools/handoff and exports goes to master; own paths only. The STOP files stay out through .gitinfoexclude (step 1).
Write-Mig 'Step 5: commit and push the leftover job files and notes' 'STEP'
$paths = @('tools/handoff', 'exports')
if ($DryRun) {
  $w = @(& git -C $repo status --porcelain -- @paths)
  Write-Mig ('would commit ' + $w.Count + ' changed path(s) under tools/handoff and exports, leaving out STOP, and push master') 'DRY'
} else {
  & git -C $repo add -A -- @paths 2>&1 | Out-Null
  $staged = @(& git -C $repo diff --cached --name-only)
  if ($staged.Count -gt 0) {
    $msg = "move: the VM's last job files, notes and state before it goes dark (his order 11-02)`n`nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
    & git -C $repo commit -q -m $msg -- @paths 2>&1 | ForEach-Object { Write-Mig ('   ' + (Protect-Text ([string]$_))) 'INFO' }
    if ($LASTEXITCODE) { Write-Mig ('git commit returned ' + $LASTEXITCODE) 'FAIL'; Exit-Mig 1 }
    Write-Mig ('committed ' + $staged.Count + ' path(s)') 'OK'
  } else { Write-Mig 'nothing to commit' 'SKIP' }
  & git -C $repo push origin master 2>&1 | ForEach-Object { Write-Mig ('   ' + (Protect-Text ([string]$_))) 'INFO' }
  if ($LASTEXITCODE) { Write-Mig 'the push failed, so this VM is NOT called dark. Fix that and run this again.' 'FAIL'; Exit-Mig 1 }
  $dirtyGame = @(& git -C $repo status --porcelain -- dark_raiders.html tools/mkfixture.ps1)
  if ($dirtyGame.Count -gt 0) { Write-Mig 'the game file or mkfixture has uncommitted edits here; they did NOT go to the main PC' 'WARN' }
  $left = @(& git -C $repo status --porcelain | Where-Object { $_ -notmatch 'console/STOP|codex/STOP' })
  if ($left.Count -gt 0) { Write-Mig ($left.Count.ToString() + ' other changed path(s) stay in this VM only: ' + (($left | Select-Object -First 8) -join ' | ')) 'WARN' }
}

# ---- 6. the final pack
Write-Mig 'Step 6: the final scratchpad and memory' 'STEP'
if ($SkipPack) { Write-Mig 'skipped (-SkipPack)' 'SKIP' }
elseif ($DryRun) { Write-Mig 'would run vm-pack-for-main.ps1' 'DRY' }
else {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'vm-pack-for-main.ps1')
  if ($LASTEXITCODE) { Write-Mig 'the final pack failed, so this VM is NOT called dark. Fix that and run this again.' 'FAIL'; Exit-Mig 1 }
}

# ---- 7. stay off from now on
Write-Mig 'Step 7: the stay-off rule at every sign-in, and the watcher for the main PC''s word' 'STEP'
$startup = [Environment]::GetFolderPath('Startup')
$lnk = Join-Path $startup 'VM stay off.lnk'
$dst = Join-Path $kit 'vm-stay-off.ps1'
if ($DryRun) { Write-Mig ('would copy vm-stay-off.ps1 to ' + $kit + ', make ' + $lnk + ', and start its watcher hidden') 'DRY' }
else {
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'vm-stay-off.ps1') -Destination $dst -Force
  $sh = New-Object -ComObject WScript.Shell; $l = $sh.CreateShortcut($lnk)
  $l.TargetPath = 'powershell.exe'; $l.Arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $dst + '" -Mode Logon'
  $l.WorkingDirectory = $kit; $l.WindowStyle = 7; $l.Description = 'Dev moved to the main PC: shuts this VM down at sign-in unless vm-wanted.txt is in the bridge share.'; $l.Save()
  Write-Mig ('Startup entry made: ' + $lnk) 'OK'
  Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + $dst + '"'), '-Mode', 'WatchOff') | Out-Null
  Write-Mig 'the watcher is running: it shuts this VM down when vm-off-now.txt appears in the share' 'OK'
}

# ---- 8. say so
Write-Mig 'Step 8: tell the main PC' 'STEP'
if ($DryRun) { Write-Mig 'would put vm-dark.txt in the bridge share' 'DRY'; Write-Mig 'Dry run finished. Nothing was changed.' 'DONE'; Exit-Mig 0 }
$head = ((& git -C $repo rev-parse HEAD) | Out-String).Trim()
$snapEnd = Get-ProcSnap; $ship = (Select-Proc $snapEnd @('bash.exe', 'powershell.exe') $script:RxShip).Count; $run = (Select-Proc $snapEnd @('bash.exe') $script:RxRunner).Count; $hl = (Select-HelperProc $snapEnd).Count
if ($ship -gt 0 -or $run -gt 0 -or $hl -gt 0 -or (Get-ShipLock).Exists) { Write-Mig ('something started again: ' + $run + ' runner, ' + $hl + ' helper, ' + $ship + ' ship. NOT called dark; run this again.') 'FAIL'; Exit-Mig 1 }
$tf = Join-Path $env:TEMP 'vm-dark.txt'
Write-AsciiFile -Path $tf -Text ("status=dark`ncomputer=" + $env:COMPUTERNAME + "`ntime=" + (Get-Date).ToString('s') + "`ngitHead=" + $head + "`n")
$o = & node $hostctl share-put name=vm-dark.txt --file $tf 2>&1
Remove-Item -LiteralPath $tf -Force -ErrorAction SilentlyContinue
$j = $null; try { $j = ($o | Out-String) | ConvertFrom-Json } catch { }
if (-not ($j -and $j.ok)) { Write-Mig 'vm-dark.txt did not reach the share; run this again' 'FAIL'; Exit-Mig 1 }
Write-Mig ('Dark. Head ' + $head.Substring(0, 8) + '. The main PC chat may lift its STOP now; it writes vm-off-now.txt after its first ship and this VM shuts down.') 'DONE'
Exit-Mig 0
