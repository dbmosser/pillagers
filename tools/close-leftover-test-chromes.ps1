# close-leftover-test-chromes.ps1 : closes LEFTOVER test Chromes; the lanes run it before they wait for RAM (10-28). At 09:47 the Codex lane
# sat at "waiting for RAM: 0 GB free, need 3" while a test Chrome on 9358 (started 08:17 by a preflight whose process had ended, still
# holding two game pages from :8806) held 2.9 GB and six idle ones sat on 9344, 9346, 9351, 9354, 9356 and 9359; closing them freed 3.3 GB.
# A test Chrome is LEFTOVER only if ALL of these hold:
#   1. its root chrome.exe has --remote-debugging-port in 9331..9399 AND a --user-data-dir that is a pillagers-cdp folder (pillagers-cdp or
#      pillagers-cdpNNNN) right in this user's temp folder. Every other Chrome (his own, the app's browser pane, Claude in Chrome, the
#      uishots camera with its pillagers-uishots profile) is never touched.
#   2. it started more than -MinAgeMin minutes ago (45).
#   3. nothing live uses its port: no running bash, sh, powershell or pwsh whose command line holds preflight*.sh, gate.ps1, uishots.ps1,
#      cdp.ps1, fuzz.ps1, shipq.sh, fixq.sh or shipone.sh (also shipdraft.sh, runchk.sh, slicechk.sh, corpus-slices.sh, corpq.sh) with
#      that port or that port's lane letter (a..i = 9351..9359, o = 9359). Also held: 9331..9340 while any fuzz.ps1 runs (the VM robot);
#      the gate Chromes 9344 and 9346 while a ship or check script runs or the ship lock (S\shipq.lock) exists; a script named with no
#      port holds its default (gate.ps1 and cdp.ps1 9333, uishots.ps1 9339, corpus-slices.sh and corpq.sh 9344, slicechk.sh 9351..9353,
#      a preflight with no lane letter 9351..9359).
#   The launcher (cdp.ps1 -Start) exits right after it starts Chrome, so a missing parent process means nothing; only live users count.
#   The live users are read again just before each close.
# A close is the same as tools/close-test-chromes.ps1: taskkill /T /F on the root pid (the whole Chrome tree). Prints one line per close
# ("closed leftover test Chrome PORT (...)"), which the lane writes to its log, then "freed about N GB" or "nothing to close".
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\close-leftover-test-chromes.ps1 -List   (each test Chrome and why it stays; closes nothing)
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\close-leftover-test-chromes.ps1         (close the leftovers)
#   -MinAgeMin 0 is for tests only; -Port 9359 (or a list) looks at those ports only, so a test never closes anyone else's browser.
param([int]$MinAgeMin = 45, [switch]$List, [string[]]$Port = @(),
      [string]$ShipLock = 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\shipq.lock')
$ErrorActionPreference = 'Continue'
$fso = $null; try { $fso = New-Object -ComObject Scripting.FileSystemObject } catch { }
function Norm([string]$p) {   # one spelling for a folder: its 8.3 short path, upper case (TEMP is VMOCT2~1 in one place and the long name in another)
  $p = ([string]$p).Trim().Trim('"').Replace('/', '\').TrimEnd('\')
  if ($fso) { try { if ($fso.FolderExists($p)) { return ([string]$fso.GetFolder($p).ShortPath).ToUpperInvariant() } } catch { } }
  return $p.ToUpperInvariant()
}
$temps = @(@($env:TEMP, $env:TMP, [IO.Path]::GetTempPath()) | Where-Object { $_ } | ForEach-Object { Norm $_ } | Select-Object -Unique)
$laneN = @{ a = 1; b = 2; c = 3; d = 4; e = 5; f = 6; g = 7; h = 8; i = 9; o = 9 }
$scriptRx = '(?i)(?<![\w.-])(preflight[\w-]*\.sh|gate\.ps1|uishots\.ps1|cdp\.ps1|fuzz\.ps1|shipq\.sh|fixq\.sh|shipone\.sh|shipdraft\.sh|runchk\.sh|slicechk\.sh|corpus-slices\.sh|corpq\.sh)'

# LivePorts : port -> what holds it, from every running bash, sh, powershell and pwsh (this script itself excluded)
function LivePorts {
  $h = @{}
  function Hold([int]$p, [string]$why) { if (-not $h.ContainsKey($p)) { $h[$p] = $why } elseif (-not $h[$p].Contains($why)) { $h[$p] += ', ' + $why } }
  $sh = @(Get-CimInstance Win32_Process -Filter "Name='bash.exe' OR Name='sh.exe' OR Name='powershell.exe' OR Name='pwsh.exe'" -ErrorAction SilentlyContinue)
  foreach ($pr in $sh) {
    if ($pr.ProcessId -eq $PID) { continue }
    $c = [string]$pr.CommandLine; if (-not $c) { continue }
    $ms = [regex]::Matches($c, $scriptRx); if ($ms.Count -eq 0) { continue }
    $names = @($ms | ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() } | Select-Object -Unique)
    $who = ($names -join '+') + ' (pid ' + $pr.ProcessId + ')'
    $got = 0
    foreach ($m in [regex]::Matches($c, '(?<!\d)(93(?:3[1-9]|[4-9]\d))(?!\d)')) { Hold ([int]$m.Groups[1].Value) $who; $got++ }
    foreach ($m in [regex]::Matches($c, '(?i)preflight[\w-]*\.sh[''"]?\s+[''"]?([a-io])(?![\w-])')) { Hold (9350 + $laneN[$m.Groups[1].Value.ToLowerInvariant()]) $who; $got++ }
    foreach ($m in [regex]::Matches($c, '(?i)pf([a-io])(?![a-z0-9])')) { Hold (9350 + $laneN[$m.Groups[1].Value.ToLowerInvariant()]) $who; $got++ }
    foreach ($n in $names) {
      if ($n -eq 'fuzz.ps1') { 9331..9340 | ForEach-Object { Hold $_ $who } }
      if ($n -in @('shipq.sh', 'fixq.sh', 'shipone.sh', 'shipdraft.sh', 'runchk.sh', 'slicechk.sh')) { Hold 9344 $who; Hold 9346 $who }
      if ($n -eq 'slicechk.sh') { 9351..9353 | ForEach-Object { Hold $_ $who } }
      if ($got -eq 0) {
        if ($n -in @('gate.ps1', 'cdp.ps1')) { Hold 9333 $who }
        elseif ($n -eq 'uishots.ps1') { Hold 9339 $who }
        elseif ($n -in @('corpus-slices.sh', 'corpq.sh')) { Hold 9344 $who }
        elseif ($n -like 'preflight*') { 9351..9359 | ForEach-Object { Hold $_ $who } }
      }
    }
  }
  if ($ShipLock -and (Test-Path -LiteralPath $ShipLock)) { Hold 9344 'the ship lock'; Hold 9346 'the ship lock' }
  return $h
}

$all = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
$kids = @{}; foreach ($pr in $all) { $pp = [int]$pr.ParentProcessId; if (-not $kids.ContainsKey($pp)) { $kids[$pp] = New-Object System.Collections.ArrayList }; [void]$kids[$pp].Add($pr) }
function TreeMB($root) { $t = 0; $st = New-Object System.Collections.Stack; $st.Push($root); $seen = @{}
  while ($st.Count) { $x = $st.Pop(); if ($seen.ContainsKey([int]$x.ProcessId)) { continue }; $seen[[int]$x.ProcessId] = 1; $t += [double]$x.WorkingSetSize
    if ($kids.ContainsKey([int]$x.ProcessId)) { foreach ($k in $kids[[int]$x.ProcessId]) { if ($k.Name -ieq 'chrome.exe') { $st.Push($k) } } } }
  return [int]($t / 1MB) }
$now = Get-Date
$tests = @($all | Where-Object { $_.Name -ieq 'chrome.exe' -and ([string]$_.CommandLine) -notmatch '--type=' -and ([string]$_.CommandLine) -match '--remote-debugging-port=(\d+)' } | ForEach-Object {
  $c = [string]$_.CommandLine
  $dp = [int]([regex]::Match($c, '--remote-debugging-port=(\d+)').Groups[1].Value)
  $um = [regex]::Match($c, '--user-data-dir=(?:"([^"]*)"|(\S+))')
  $ud = if ($um.Success) { if ($um.Groups[1].Success) { $um.Groups[1].Value } else { $um.Groups[2].Value } } else { '' }
  $ud = $ud.Replace('/', '\').TrimEnd('\')
  $leaf = if ($ud) { Split-Path -Leaf $ud } else { '' }
  $par = if ($ud) { Split-Path -Parent $ud } else { '' }
  $ok = ($dp -ge 9331 -and $dp -le 9399 -and $leaf -match '^(?i)pillagers-cdp\d*$' -and $par -and ($temps -contains (Norm $par)))
  $mins = if ($_.CreationDate) { ($now - $_.CreationDate).TotalMinutes } else { -1 }
  [PSCustomObject]@{ Pid = [int]$_.ProcessId; Port = $dp; Ours = $ok; Mins = $mins; Age = [int][Math]::Floor($mins); Start = $_.CreationDate; MB = (TreeMB $_); Profile = $leaf; Proc = $_ }
} | Sort-Object Port)
$want = @($Port | ForEach-Object { $_ -split '[,\s]+' } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ })   # -Port 9357,9359 arrives as one string under -File
if ($Port.Count) { $tests = @($tests | Where-Object { $want -contains $_.Port }) }

$live = LivePorts
if ($List) {
  if ($tests.Count -eq 0) { 'no Chrome with a debugging port is running'; return }
  foreach ($t in $tests) {
    $why = if (-not $t.Ours) { 'not a test Chrome of ours (port outside 9331-9399 or no pillagers-cdp temp profile): never touched' }
           elseif ($t.Mins -lt 0 -or $t.Mins -le $MinAgeMin) { "kept: $($t.Age) min old (closes after $MinAgeMin)" }
           elseif ($live.ContainsKey($t.Port)) { 'kept: in use by ' + $live[$t.Port] }
           else { 'LEFTOVER (would close)' }
    "Chrome $($t.Port) pid $($t.Pid) $($t.MB) MB up $($t.Age) min profile $($t.Profile): $why"
  }
  return
}
$freed = 0; $n = 0
foreach ($t in @($tests | Where-Object { $_.Ours -and $_.Mins -gt $MinAgeMin })) {
  if ($live.ContainsKey($t.Port)) { continue }
  $live = LivePorts                                  # read again right before the close: a gate may have just started on it
  if ($live.ContainsKey($t.Port)) { continue }
  $still = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $t.Pid) -ErrorAction SilentlyContinue
  if (-not $still -or [string]$still.CommandLine -ne [string]$t.Proc.CommandLine) { continue }   # gone, or the pid now belongs to something else
  $pages = ''
  try { $js = Invoke-RestMethod ("http://127.0.0.1:" + $t.Port + "/json") -TimeoutSec 2; $pg = @($js | Where-Object { $_.type -eq 'page' })
    $nm = @($pg | ForEach-Object { $u = [string]$_.url; if ($u -eq '' -or $u -like 'about:*') { 'blank' } else { (($u -split '[?#]')[0] -split '/')[-1] } })
    $pages = if ($nm.Count) { ', pages ' + (($nm | Select-Object -First 4) -join ' ') + $(if ($nm.Count -gt 4) { ' +' + ($nm.Count - 4) } else { '' }) } else { ', no pages' } } catch { }
  & taskkill.exe /PID $t.Pid /T /F 2>&1 | Out-Null
  Start-Sleep -Milliseconds 400
  $st = if ($t.Start) { $t.Start.ToString('HH:mm') } else { '?' }
  if (Get-Process -Id $t.Pid -ErrorAction SilentlyContinue) { "could not close test Chrome $($t.Port) (pid $($t.Pid) still running)" }
  else { "closed leftover test Chrome $($t.Port) (pid $($t.Pid), $([Math]::Round($t.MB / 1024, 1)) GB, started $st, $($t.Age) min old, no gate or test on its port$pages)"; $freed += $t.MB; $n++ }
}
if ($n -eq 0) { 'nothing to close' } else { 'freed about ' + [Math]::Round($freed / 1024, 1) + ' GB (' + $n + ' test Chrome' + $(if ($n -gt 1) { 's' } else { '' }) + ')' }
