# Breaks the new runner on purpose, one edit at a time, and says which mock checks catch each break. Checks c1 and c2 (undo gives master) always fail on a broken copy, so a
# break counts as caught only by another check. Nothing here opens a window. Usage: focus-mutants.ps1 -File new-runner.ps1 -Master master-runner.ps1
param([string]$File,[string]$Master,[int[]]$Only=@())
[Diagnostics.Process]::GetCurrentProcess().PriorityClass='BelowNormal'
$here=Split-Path -Parent $MyInvocation.MyCommand.Path
$src=[IO.File]::ReadAllText($File)
$m=@(
  @('near window 500 to 5000 ms','const int NearMs = 500;','const int NearMs = 5000;'),
  @('one change excuses many moves','pend = false; haveFg = false;'+"`n",'pend = false;'+"`n"),
  @('two moves together excused','if (one && haveFg && Dist','if (haveFg && Dist'),
  @('the burst rule gone','(have2 && unchecked(seen - ig2) <= (uint)BurstMs) || ',''),
  @('late looks part the move from the change','pend = true; one = true; pend0 = now;','pend = true; one = true; pend0 = stamp;'),
  @('a window move sets the person','focus = seen; haveFocus = true; count++;','focus = seen; person = seen; haveFocus = true; count++;'),
  @('a real move never sets the person','if (Gap(now, pend0) > NearMs) { pend = false; haveFg = false; person = seen; }','if (Gap(now, pend0) > NearMs) { pend = false; haveFg = false; }'),
  @('the person is the first move, not the last','haveFg = false; person = seen; }','haveFg = false; person = pend0; }'),
  @('always the raw input time','if (!on || first || (Dist(now, polled) > StaleMs && !(ok && st == seen && !pend))) return','if (true) return'),
  @('the stale fallback gone','if (!on || first || (Dist(now, polled) > StaleMs && !(ok && st == seen && !pend)))','if (!on || first)'),
  @('the wrap guard gone','int g = Gap(now, person); if (g < 0 && g > -60000) return 0;',''),
  @('the guard too wide, 30 days reads as here','if (g < 0 && g > -60000) return 0;','if (g < 0) return 0;'),
  @('the first look does not seed the person','first = false; seen = stamp; person = stamp; fg = f; return;','first = false; seen = stamp; fg = f; return;'),
  @('the thread never starts','[PillagersSpare.FocusWatch]::Start(); $script:noFocus=$false','$script:noFocus=$false'),
  @('the flag stays up, so the watch is never used','[PillagersSpare.FocusWatch]::Start(); $script:noFocus=$false','[PillagersSpare.FocusWatch]::Start()'),
  @('the thread looks 2 times a second','System.Threading.Thread.Sleep(100);','System.Threading.Thread.Sleep(500);'),
  @('the passive signs ignore a window move','if([Math]::Min($a,$fo) -lt $PassCapSec){','if($a -lt $PassCapSec){'),
  @('no hold on a gate job','-not (Arrived) -and -not (FocusHold)){ Gate-Start','-not (Arrived)){ Gate-Start'),
  @('no hold on a stopped run going on','-not (Arrived) -and -not (FocusHold) -and (Resume-Corpus)','-not (Arrived) -and (Resume-Corpus)'),
  @('no hold on a new full run','-ge 900) -and -not (FocusHold)){ Start-Corpus','-ge 900)){ Start-Corpus'),
  @('no hold on the robot','(GetS ''gate_id'') -and -not (FocusHold)){ Start-Robot','(GetS ''gate_id'')){ Start-Robot'),
  @('no hold after the build','  if(FocusHold){ PutS ''tries'' ([string]$tries); Say ''a window came to the front while the test copy was built: the full run waits for the next round, its try is given back''; return }'+"`n",''),
  @('the hold reaches IDLE MODE','if($Idle -or $script:noFocus -ne $false){ return $false }','if($script:noFocus -ne $false){ return $false }'),
  @('a NULL front counts as a change','if (f != IntPtr.Zero && f != fg)','if (f != fg)'),
  @('the burst test wraps','(have2 && unchecked(seen - ig2) <= (uint)BurstMs)','(have2 && Gap(seen, ig2) <= BurstMs)'),
  @('stale always raw','(Dist(now, polled) > StaleMs && !(ok && st == seen && !pend))','Dist(now, polled) > StaleMs'),
  @('stale hides a move not yet judged','!(ok && st == seen && !pend)','!(ok && st == seen)'),
  @('no ceiling on window moves',' || (n5 >= 5 && unchecked(seen - last5[n5 % 5]) <= (uint)CeilMs)',''),
  @('the ceiling looks at the newest, not the oldest','last5[n5 % 5]) <= (uint)CeilMs','last5[(n5 + 4) % 5]) <= (uint)CeilMs'),
  @('a held start is not logged','Say ''a window came to the front: no new test work starts for 65 s, what is running goes on''','$null=$n'),
  @('the hold is too short for two graphics looks','FocusOnlyAgo() -ge 65)','FocusOnlyAgo() -ge 20)'),
  @('the watch loads in IDLE MODE too','if(-not $Idle -and -not $script:noIn){','if(-not $script:noIn){'),
  @('a window move is logged as nothing','Say (''the input time moved as the window in front changed to ''+$pn+'': not counted as someone at the PC'')','$null=$pn'),
  @('a burst is not logged','Say ''the window in front keeps changing (3 times in 30 s or 6 in 10 minutes): counted as someone at the PC''','$null=$n')
)
$tmp=Join-Path $here 'mutant'; New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$caught=0; $missed=@(); $i=0
foreach($x in $m){
  $i++; $name=$x[0]; if($Only.Count -and $Only -notcontains $i){ continue }
  if($src.IndexOf([string]$x[1]) -lt 0){ ('{0,2} {1,-52} ANCHOR NOT FOUND' -f $i,$name); $missed+=$name; continue }
  $f=Join-Path $tmp 'spare-runner.ps1'; $o=Join-Path $tmp 'out.txt'; Remove-Item -LiteralPath $o -Force -ErrorAction SilentlyContinue
  [IO.File]::WriteAllText($f,$src.Replace([string]$x[1],[string]$x[2]),(New-Object Text.UTF8Encoding($false)))
  $res=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'focus-mock.ps1') -File $f -Master $Master -Out $o 2>&1 | ForEach-Object { "$_" }
  $wrong=@(); if(Test-Path -LiteralPath $o){ $wrong=@(Get-Content -LiteralPath $o | Where-Object { $_ -match '\bWRONG\b' } | ForEach-Object { ($_ -split '\s{2,}')[0] } | Where-Object { $_ -notmatch '^(c1|c2) ' }) } else { $wrong=@('(the mock itself stopped: '+(($res | Select-Object -Last 1)).Substring(0,[Math]::Min(70,(($res | Select-Object -Last 1)).Length))+')') }
  if($wrong.Count){ $caught++; ('{0,2} {1,-52} caught by {2,3}: {3}' -f $i,$name,$wrong.Count,(($wrong | Select-Object -First 3 | ForEach-Object { $_.Substring(0,[Math]::Min(46,$_.Length)) }) -join ' / ')) }
  else { $missed+=$name; ('{0,2} {1,-52} NOT CAUGHT' -f $i,$name) }
}
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
"breaks $($m.Count), caught $caught, missed $($missed.Count)"
if($missed.Count){ 'missed: '+($missed -join '; ') }
