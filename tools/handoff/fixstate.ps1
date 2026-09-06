param([string]$HeadV, [string]$HeadSha, [string]$FlightN, [string]$FlightV, [string]$PrevN, [string]$NextN)
$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Rewrites the STATE block at the top of START-HERE.md to the current head and
# the build in flight. Run as: powershell -File tools/handoff/fixstate.ps1 -HeadV 11.77 -HeadSha 3dd0fcb -FlightN 1178 -FlightV 11.78 -PrevN 1177 -NextN 1179
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$start = $s.IndexOf('**STATE')
$end = $s.IndexOf('**THE QUEUE, ALL DRAFTED')
if ($start -lt 0 -or $end -lt 0 -or $end -le $start) { throw 'STATE block anchors not found' }
$nl = if ($s.IndexOf("`r`n") -ge 0) { "`r`n" } else { "`n" }
$block = '**STATE (kept current by fixstate.ps1):** HEAD is v' + $HeadV + ' (' + $HeadSha + '). The tree has **v' + $FlightV + ' APPLIED** and' + $nl +
  'verified on all four gates; its FULL CORPUS is running on the Browser pane tab "tab-2" (the tab named seed hung on 2026-09-06 12:40 and was closed).' + $nl +
  'When `window.__PROG` is finished, pass true, fail [] and only the two known skips' + $nl +
  '(v8.88, v11.24):' + $nl +
  '    bash tools/handoff/ship.sh commit ' + $FlightN + ' cm' + $FlightN + '.txt' + $nl +
  'then bump the HEAD line in memory dark-raiders-handoff-state.md, then' + $nl +
  '    bash tools/handoff/ship.sh start ' + $FlightN + ' ' + $NextN + $nl +
  'and carry on down the list. Cron 35be6fe2 is armed every minute; re-arm if' + $nl +
  'CronList shows nothing. Resize the pane to 1920x1080 after any restart. Leave the' + $nl +
  'pane and the CPU alone while a corpus runs (a second-tab resize and heavy builds' + $nl +
  'each turned one unrelated check red). If one unrelated check goes red, re-run it' + $nl +
  'alone and straight after the new check; a bare profile left by a check is the' + $nl +
  'usual cause (see memory dark-raiders-loader-replaces-the-profile).' + $nl + $nl
$s = $s.Substring(0, $start) + $block + $s.Substring($end)
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output ('STATE block: HEAD v' + $HeadV + ', in flight v' + $FlightV)
