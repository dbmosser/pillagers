# host-night-memory.ps1 : lends the Pillagers VM more memory at night and takes it back by morning, on the MAIN PC (JUL26).
# His answers of 2026-10-19 night: 45 a "Yes" (the VM may take more memory only at night, back to normal by morning), 44 c (keep 10 GB by day),
# and 100: "you should actively be optimizing my hardware etc to make sure we are getting max bang for our buck in terms of development".
#
# He runs it ONCE: double-click night-memory-setup.cmd (it asks Windows for administrator rights and runs this with -Install). That:
#   1. copies this file to %LOCALAPPDATA%\PillagersBridge\night-memory.ps1 (outside the repository, so the main PC's safety checks ignore it);
#   2. makes two scheduled tasks that run as SYSTEM: "VM night memory up" every day at 23:00 and "VM night memory down" every day at 06:00
#      (repeated every 15 minutes until 08:00, in case the VM cannot hand all of it back at once);
#   3. puts "Pillagers Dev (live)" on his desktop: the dashboard copy the VM sends every 30 seconds into the bridge share folder;
#   4. (10-20, his 47 a "weekly safety snapshot") "VM weekly snapshot": every Sunday at 05:00 a Hyper-V checkpoint named "Pillagers weekly DATE",
#      keeping the newest -KeepSnapshots (2); the first one is made at install;
#   5. (10-20, his 49 a "while I play, the VM goes light" and 38 b "the local AI may run any time unless I am gaming") "VM light while gaming":
#      every minute it looks at how hard each program works the graphics card. A program at -Gpu3DPct (15) or more (a game, or the game in a
#      browser) means he is playing: the VM is held to -GameCpuPct (30) percent of its processors, and gaming.txt in the share tells the VM to
#      start nothing new. Ten minutes after the last game sighting the VM gets its full processors back.
# Up: the VM gets more memory while it runs (Hyper-V runtime memory resize, no restart), up to -MaxGB, always leaving -KeepFreeGB free on this PC.
# Down: the VM goes back to its daytime size (the size it had when -Install ran, normally 10 GB). Nothing else on the VM changes.
# It never changes Defender, the firewall, UAC, Windows Update or any other security setting, and never starts or stops the VM.
# Every run writes a line to the bridge share folder (night-memory.log) so the VM can read how the night went.
#
#   -Install     set it up (needs administrator)       -Undo     remove the tasks, the copy and the shortcut; VM back to its day size
#   -Status      show what is set up (read only)       -DryRun   with -Install, -Up, -Snapshot or -GameCheck: only say what would happen
#   -Up / -Down / -Snapshot / -GameCheck  what the tasks run
#   -MaxGB N (default 16)  -KeepFreeGB N (default 4)  -VMName NAME (default Pillagers_Oct26)  -KeepSnapshots N (2)  -Gpu3DPct N (15)  -GameCpuPct N (30)
# Exit codes: 0 done, 2 refused or nothing could be done (see the log line), 3 needs an administrator window. ASCII only. PowerShell 5.1 and 7.
param(
  [switch]$Install, [switch]$Undo, [switch]$Status, [switch]$DryRun, [switch]$Up, [switch]$Down, [switch]$Snapshot, [switch]$GameCheck,
  [string]$VMName = 'Pillagers_Oct26', [int]$MaxGB = 16, [int]$KeepFreeGB = 4, [int]$DayGB = 0,
  [int]$KeepSnapshots = 2, [int]$Gpu3DPct = 15, [int]$GameCpuPct = 30,
  [string]$BaseDir = ''
)
$ErrorActionPreference = 'Continue'
if (-not $BaseDir) { $BaseDir = Join-Path $env:LOCALAPPDATA 'PillagersBridge' }
$Share = Join-Path $BaseDir 'share'
$Log = Join-Path $Share 'night-memory.log'
$Copy = Join-Path $BaseDir 'night-memory.ps1'
$StateFile = Join-Path $BaseDir 'night-memory-state.txt'
$TaskUp = 'VM night memory up'; $TaskDown = 'VM night memory down'; $TaskSnap = 'VM weekly snapshot'; $TaskGame = 'VM light while gaming'
$LinkName = 'Pillagers Dev (live).url'
$GameFile = Join-Path $Share 'gaming.txt'; $GameSeen = Join-Path $BaseDir 'gaming-last-seen.txt'; $SnapPrefix = 'Pillagers weekly '

function Say([string]$msg, [string]$kind = 'INFO') { Write-Host ('{0,-5} {1}' -f $kind, $msg) }
function LogLine([string]$msg) {
  try { if (-not (Test-Path $Share)) { New-Item -ItemType Directory -Force -Path $Share | Out-Null }
        Add-Content -Path $Log -Value ((Get-Date).ToString('yyyy-MM-dd HH:mm') + ' ' + $msg) -Encoding ASCII } catch { }
}
function IsAdmin { try { return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { return $false } }
function HostFreeGB { try { return [math]::Round((Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).FreePhysicalMemory / 1MB, 1) } catch { return -1 } }
function ReadDayGB {
  if ($DayGB -gt 0) { return $DayGB }
  try { $m = [regex]::Match((Get-Content $StateFile -Raw -ErrorAction Stop), 'dayGB=(\d+)'); if ($m.Success) { return [int]$m.Groups[1].Value } } catch { }
  return 10
}
function GetVm { try { return Get-VM -Name $VMName -ErrorAction Stop } catch { return $null } }

# ------------------------------------------------------------------ -Up : lend memory for the night
if ($Up) {
  $vm = GetVm
  if (-not $vm) { LogLine ('up: no VM named ' + $VMName + ' (or no Hyper-V rights); nothing done'); exit 2 }
  if ($vm.State -ne 'Running') { LogLine ('up: the VM is ' + $vm.State + '; nothing done'); exit 2 }
  if ($vm.DynamicMemoryEnabled) { LogLine 'up: the VM uses dynamic memory; this script only resizes fixed memory, nothing done'; exit 2 }
  $cur = [int][math]::Round($vm.MemoryStartup / 1GB); $free = HostFreeGB
  $target = [int][math]::Min($MaxGB, [math]::Floor($cur + $free - $KeepFreeGB))
  if ($target -le $cur) { LogLine ('up: no room tonight (VM ' + $cur + ' GB, this PC has ' + $free + ' GB free and keeps ' + $KeepFreeGB + ' GB); nothing done'); exit 2 }
  if ($DryRun) { Say ('would give the VM ' + $target + ' GB (now ' + $cur + ' GB; this PC has ' + $free + ' GB free and keeps ' + $KeepFreeGB + ')') 'DRY'; exit 0 }
  try {
    Set-VMMemory -VMName $VMName -StartupBytes ([int64]$target * 1GB) -ErrorAction Stop
    Start-Sleep -Seconds 20; $vm = GetVm
    LogLine ('up: VM ' + $cur + ' -> ' + $target + ' GB (assigned now ' + [math]::Round($vm.MemoryAssigned / 1GB, 1) + ' GB; this PC had ' + $free + ' GB free)'); exit 0
  } catch { LogLine ('up: Hyper-V refused ' + $target + ' GB: ' + ($_.Exception.Message -replace '\s+', ' ')); exit 2 }
}

# ------------------------------------------------------------------ -Down : hand it back by morning
if ($Down) {
  $day = ReadDayGB; $vm = GetVm
  if (-not $vm) { LogLine ('down: no VM named ' + $VMName + '; nothing done'); exit 2 }
  $cur = [int][math]::Round($vm.MemoryStartup / 1GB); $asg = [math]::Round($vm.MemoryAssigned / 1GB, 1)
  if ($cur -le $day -and ($vm.State -ne 'Running' -or $asg -le $day + 0.5)) { exit 0 }   # already back (the 15-minute repeats end here quietly)
  try {
    Set-VMMemory -VMName $VMName -StartupBytes ([int64]$day * 1GB) -ErrorAction Stop
    Start-Sleep -Seconds 30; $vm = GetVm; $asg2 = [math]::Round($vm.MemoryAssigned / 1GB, 1)
    LogLine ('down: VM ' + $cur + ' -> ' + $day + ' GB (assigned now ' + $asg2 + ' GB' + $(if ($asg2 -gt $day + 0.5) { '; the VM is still giving it back, the next try is in 15 minutes' } else { '' }) + ')'); exit 0
  } catch { LogLine ('down: Hyper-V refused ' + $day + ' GB (tries again in 15 minutes): ' + ($_.Exception.Message -replace '\s+', ' ')); exit 2 }
}

# ------------------------------------------------------------------ -Snapshot : the weekly safety checkpoint (his 47 a)
function OurSnapshots { try { return @(Get-VMSnapshot -VMName $VMName -ErrorAction Stop | Where-Object { $_.Name -like ($SnapPrefix + '*') } | Sort-Object CreationTime -Descending) } catch { return @() } }
if ($Snapshot) {
  $vm = GetVm
  if (-not $vm) { LogLine ('snapshot: no VM named ' + $VMName + '; nothing done'); exit 2 }
  $name = $SnapPrefix + (Get-Date -Format 'yyyy-MM-dd')
  if ($DryRun) { Say ('would make the checkpoint "' + $name + '" and keep the newest ' + $KeepSnapshots + ' (there are ' + (OurSnapshots).Count + ' now)') 'DRY'; exit 0 }
  try { Checkpoint-VM -Name $VMName -SnapshotName $name -ErrorAction Stop }
  catch { LogLine ('snapshot: Hyper-V refused the checkpoint: ' + ($_.Exception.Message -replace '\s+', ' ')); exit 2 }
  LogLine ('snapshot: made "' + $name + '"')
  foreach ($s in @(OurSnapshots | Select-Object -Skip $KeepSnapshots)) {
    try { Remove-VMSnapshot -VMSnapshot $s -ErrorAction Stop; LogLine ('snapshot: removed the old checkpoint "' + $s.Name + '" (Hyper-V merges it in the background)') }
    catch { LogLine ('snapshot: could not remove "' + $s.Name + '": ' + ($_.Exception.Message -replace '\s+', ' ')) }
  }
  exit 0
}

# ------------------------------------------------------------------ -GameCheck : the VM goes light while he plays (his 49 a and 38 b)
if ($GameCheck) {
  $hit = ''; $pct = 0
  try {
    $sets = Get-Counter -Counter '\GPU Engine(*engtype_3D)\Utilization Percentage' -SampleInterval 1 -MaxSamples 5 -ErrorAction Stop
    $by = @{}
    foreach ($set in $sets) { foreach ($c in $set.CounterSamples) { if ($c.InstanceName -match 'pid_(\d+)_') { $p = [int]$Matches[1]; $by[$p] = [double]$by[$p] + $c.CookedValue } } }
    foreach ($p in @($by.Keys)) {
      $avg = $by[$p] / 5
      if ($avg -lt $Gpu3DPct) { continue }
      $n = ''; try { $n = (Get-Process -Id $p -ErrorAction Stop).ProcessName } catch { }
      if (-not $n -or $n -match '^(dwm|vmwp|vmmem|vmcompute|vmconnect|mstsc|msrdc|csrss|System|Idle|audiodg)$') { continue }
      if ($avg -gt $pct) { $pct = [int]$avg; $hit = $n }
    }
  } catch { LogLine ('game check: cannot read the graphics card counters: ' + ($_.Exception.Message -replace '\s+', ' ')); exit 2 }
  $now = Get-Date; $last = $null
  if ($hit) { $last = $now; Set-Content -Path $GameSeen -Value $now.ToString('yyyy-MM-dd HH:mm:ss') -Encoding ASCII }
  else { try { $last = [datetime]::ParseExact((Get-Content $GameSeen -Raw -ErrorAction Stop).Trim(), 'yyyy-MM-dd HH:mm:ss', $null) } catch { } }
  $gaming = ($last -ne $null) -and (($now - $last).TotalMinutes -lt 10)
  if ($DryRun) { Say ('graphics card: ' + $(if ($hit) { $hit + ' at ' + $pct + '% 3D' } else { 'no program at ' + $Gpu3DPct + '% 3D or more' }) + '; playing: ' + $gaming) 'DRY'; exit 0 }
  try { if (-not (Test-Path $Share)) { New-Item -ItemType Directory -Force -Path $Share | Out-Null }
        Set-Content -Path $GameFile -Encoding ASCII -Value @(('gaming=' + $(if ($gaming) { '1' } else { '0' })), ('checked=' + $now.ToString('yyyy-MM-dd HH:mm:ss')),
          ('last=' + $(if ($last) { $last.ToString('yyyy-MM-dd HH:mm:ss') } else { '' })), ('what=' + $(if ($hit) { $hit + ' ' + $pct + '%' } else { '' }))) } catch { }
  $vm = GetVm
  if ($vm -and $vm.State -eq 'Running') {
    try {
      $cap = (Get-VMProcessor -VMName $VMName -ErrorAction Stop).Maximum
      if ($gaming -and $cap -gt $GameCpuPct) { Set-VMProcessor -VMName $VMName -Maximum $GameCpuPct -ErrorAction Stop; LogLine ('game check: ' + $hit + ' works the graphics card (' + $pct + '% 3D): the VM is held to ' + $GameCpuPct + '% of its processors') }
      elseif (-not $gaming -and $cap -lt 100) { Set-VMProcessor -VMName $VMName -Maximum 100 -ErrorAction Stop; LogLine 'game check: no game for 10 minutes: the VM has its full processors again' }
    } catch { LogLine ('game check: Hyper-V refused the processor limit: ' + ($_.Exception.Message -replace '\s+', ' ')) }
  }
  exit 0
}

# ------------------------------------------------------------------ -Status
if ($Status -or -not ($Install -or $Undo)) {
  $vm = GetVm
  Say ('VM ' + $VMName + ': ' + $(if ($vm) { $vm.State.ToString() + ', ' + [math]::Round($vm.MemoryStartup / 1GB, 1) + ' GB set, ' + [math]::Round($vm.MemoryAssigned / 1GB, 1) + ' GB in use' + $(if ($vm.DynamicMemoryEnabled) { ' (dynamic)' } else { ' (fixed)' }) } else { 'not found (or this window has no Hyper-V rights)' }))
  Say ('this PC: ' + (HostFreeGB) + ' GB free; daytime VM size ' + (ReadDayGB) + ' GB')
  foreach ($n in $TaskUp, $TaskDown, $TaskSnap, $TaskGame) { $t = Get-ScheduledTask -TaskName $n -ErrorAction SilentlyContinue; Say ($n + ': ' + $(if ($t) { $t.State } else { 'not set up' })) $(if ($t) { 'OK' } else { 'INFO' }) }
  if ($vm) { try { Say ('VM processors: held to ' + (Get-VMProcessor -VMName $VMName -ErrorAction Stop).Maximum + '% (100 = all)') } catch { } }
  if (Test-Path $GameFile) { Say ('game check: ' + ((Get-Content $GameFile -ErrorAction SilentlyContinue) -join '; ')) }
  $snaps = @(OurSnapshots); Say ('weekly checkpoints: ' + $(if ($snaps.Count) { ($snaps | ForEach-Object { $_.Name }) -join ', ' } else { 'none yet' }))
  if (Test-Path $Log) { Say 'last night-memory lines:'; Get-Content $Log -Tail 6 | ForEach-Object { Say $_ } }
  if (-not ($Install -or $Undo)) { exit 0 }
}

if (-not (IsAdmin)) { Say 'This needs an administrator window. Double-click night-memory-setup.cmd and click Yes.' 'FAIL'; exit 3 }
$desktop = [Environment]::GetFolderPath('Desktop')

# ------------------------------------------------------------------ -Undo
if ($Undo) {
  foreach ($n in $TaskUp, $TaskDown, $TaskSnap, $TaskGame) { if (Get-ScheduledTask -TaskName $n -ErrorAction SilentlyContinue) { Unregister-ScheduledTask -TaskName $n -Confirm:$false; Say ('removed task ' + $n) 'OK' } }
  $vm = GetVm; $day = ReadDayGB
  if ($vm -and [int][math]::Round($vm.MemoryStartup / 1GB) -gt $day) { try { Set-VMMemory -VMName $VMName -StartupBytes ([int64]$day * 1GB) -ErrorAction Stop; Say ('VM back to ' + $day + ' GB') 'OK' } catch { Say ('could not set the VM back to ' + $day + ' GB now: ' + $_.Exception.Message) 'WARN' } }
  if ($vm) { try { if ((Get-VMProcessor -VMName $VMName -ErrorAction Stop).Maximum -lt 100) { Set-VMProcessor -VMName $VMName -Maximum 100 -ErrorAction Stop; Say 'VM has all its processors again' 'OK' } } catch { Say ('could not lift the processor limit: ' + $_.Exception.Message) 'WARN' } }
  foreach ($f in $Copy, $StateFile, $GameFile, $GameSeen, (Join-Path $desktop $LinkName)) { if (Test-Path $f) { Remove-Item $f -Force; Say ('removed ' + $f) 'OK' } }
  $snaps = @(OurSnapshots); if ($snaps.Count) { Say ('the weekly checkpoints stay as a safety copy (' + (($snaps | ForEach-Object { $_.Name }) -join ', ') + '); Hyper-V Manager can delete them') }
  LogLine 'undo: tasks removed, VM back to its day size and all its processors'; exit 0
}

# ------------------------------------------------------------------ -Install
$vm = GetVm
if (-not $vm) { Say ('No VM named ' + $VMName + ' on this PC.') 'FAIL'; exit 2 }
if ($vm.DynamicMemoryEnabled) { Say 'The VM uses dynamic memory; this setup only works with fixed memory. Nothing changed.' 'FAIL'; exit 2 }
$day = if ($DayGB -gt 0) { $DayGB } else { [int][math]::Round($vm.MemoryStartup / 1GB) }
$free = HostFreeGB; $tonight = [int][math]::Min($MaxGB, [math]::Floor($day + $free - $KeepFreeGB))
Say ('VM ' + $VMName + ': ' + $day + ' GB by day. At 23:00 it gets up to ' + $MaxGB + ' GB (as much as fits while this PC keeps ' + $KeepFreeGB + ' GB free; right now that would be ' + [math]::Max($day, $tonight) + ' GB), and at 06:00 it goes back to ' + $day + ' GB.')
Say ('Every Sunday at 05:00 it makes a safety checkpoint of the VM (keeps the newest ' + $KeepSnapshots + '). Every minute it checks for a game: while one works the graphics card, the VM is held to ' + $GameCpuPct + '% of its processors and starts nothing new.')
if ($DryRun) { Say ('would copy this script to ' + $Copy + ', make the tasks "' + $TaskUp + '" (23:00), "' + $TaskDown + '" (06:00, every 15 min until 08:00), "' + $TaskSnap + '" (Sunday 05:00) and "' + $TaskGame + '" (every minute) as SYSTEM, make the first checkpoint, and put "' + $LinkName + '" on the desktop') 'DRY'; exit 0 }
New-Item -ItemType Directory -Force -Path $Share | Out-Null
Copy-Item -LiteralPath $PSCommandPath -Destination $Copy -Force
Set-Content -Path $StateFile -Value ('dayGB=' + $day) -Encoding ASCII
$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$common = '-NoProfile -ExecutionPolicy Bypass -File "' + $Copy + '" -VMName "' + $VMName + '" -MaxGB ' + $MaxGB + ' -KeepFreeGB ' + $KeepFreeGB + ' -DayGB ' + $day + ' -BaseDir "' + $BaseDir + '" -KeepSnapshots ' + $KeepSnapshots + ' -Gpu3DPct ' + $Gpu3DPct + ' -GameCpuPct ' + $GameCpuPct
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
$tUp = New-ScheduledTaskTrigger -Daily -At '23:00'
$tDown = New-ScheduledTaskTrigger -Daily -At '06:00'
try {
  Register-ScheduledTask -TaskName $TaskUp -Action (New-ScheduledTaskAction -Execute $ps -Argument ($common + ' -Up')) -Trigger $tUp -Principal $principal -Settings $settings -Force -ErrorAction Stop | Out-Null
  $dt = Register-ScheduledTask -TaskName $TaskDown -Action (New-ScheduledTaskAction -Execute $ps -Argument ($common + ' -Down')) -Trigger $tDown -Principal $principal -Settings $settings -Force -ErrorAction Stop
  $dt.Triggers[0].Repetition = (New-ScheduledTaskTrigger -Once -At '06:00' -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Hours 2)).Repetition
  $dt | Set-ScheduledTask -ErrorAction Stop | Out-Null
  Say ('tasks made: "' + $TaskUp + '" at 23:00 and "' + $TaskDown + '" at 06:00 (repeats every 15 minutes until 08:00)') 'OK'
} catch { Say ('Windows refused the scheduled tasks: ' + $_.Exception.Message) 'FAIL'; exit 2 }
try {
  $sset = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
  Register-ScheduledTask -TaskName $TaskSnap -Action (New-ScheduledTaskAction -Execute $ps -Argument ($common + ' -Snapshot')) -Trigger (New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At '05:00') -Principal $principal -Settings $sset -Force -ErrorAction Stop | Out-Null
  Say ('task made: "' + $TaskSnap + '" every Sunday at 05:00') 'OK'
} catch { Say ('Windows refused the weekly checkpoint task: ' + $_.Exception.Message) 'WARN' }
try {
  $gset = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
  $gt = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1)) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 3650)
  Register-ScheduledTask -TaskName $TaskGame -Action (New-ScheduledTaskAction -Execute $ps -Argument ($common + ' -GameCheck')) -Trigger $gt -Principal $principal -Settings $gset -Force -ErrorAction Stop | Out-Null
  Say ('task made: "' + $TaskGame + '" every minute') 'OK'
} catch { Say ('Windows refused the game check task: ' + $_.Exception.Message) 'WARN' }
Say 'Making the first safety checkpoint of the VM (a few seconds to a minute)...'
& $ps -NoProfile -ExecutionPolicy Bypass -File $Copy -VMName $VMName -BaseDir $BaseDir -KeepSnapshots $KeepSnapshots -Snapshot
if (Test-Path $Log) { Get-Content $Log -Tail 1 | ForEach-Object { Say $_ } }
try {
  $u = 'file:///' + ((Join-Path $Share 'pillagers-dashboard.html') -replace '\\', '/')
  Set-Content -Path (Join-Path $desktop $LinkName) -Value ("[InternetShortcut]`r`nURL=" + $u + "`r`n") -Encoding ASCII
  Say ('desktop shortcut "' + $LinkName + '" made: the live dashboard from the VM (it refreshes itself every 30 seconds)') 'OK'
} catch { Say ('could not make the desktop shortcut: ' + $_.Exception.Message) 'WARN' }
LogLine ('install: day ' + $day + ' GB, night up to ' + $MaxGB + ' GB, this PC keeps ' + $KeepFreeGB + ' GB free')
$now = (Get-Date).Hour
if ($now -ge 23 -or $now -lt 6) { Say 'It is night now, so the VM gets its night memory right away.' ; & $ps -NoProfile -ExecutionPolicy Bypass -File $Copy -VMName $VMName -MaxGB $MaxGB -KeepFreeGB $KeepFreeGB -DayGB $day -BaseDir $BaseDir -Up; if (Test-Path $Log) { Get-Content $Log -Tail 1 | ForEach-Object { Say $_ } } }
Say 'DONE. Nothing else to do. To undo it: night-memory-setup.cmd undo' 'OK'
exit 0
