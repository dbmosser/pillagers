# Breaks the new runner on purpose, one edit at a time, and says which mock checks catch each break. Checks c1 and c2 (undo gives master) always fail on a broken copy, so a
# break counts as caught only by another check. A break that stops the mock (one that does not compile, say) counts as missed, not caught. The unbroken runner must pass first.
# Nothing here opens a window. Usage: lone-mutants.ps1 -File new-runner.ps1 -Master master-runner.ps1 [-From n] [-To n] [-Tmp name]
param([string]$File,[string]$Master,[int]$From=1,[int]$To=999,[string]$Tmp='mutant')
[Diagnostics.Process]::GetCurrentProcess().PriorityClass='BelowNormal'
$here=Split-Path -Parent $MyInvocation.MyCommand.Path
$src=[IO.File]::ReadAllText($File)
$tail='if (!one || pair || release) person = seen; else if (Uncounted()) { lones++; wasLone = true; }'
$pairLine='bool pair = haveLone && unchecked(seen - lone0) <= (uint)LoneMs, release = haveWin && unchecked(seen - win0) <= (uint)ReleaseMs;'
$keep='lone0 = seen; haveLone = true; wasLone = false;'
$m=@(
  @('near window 500 to 5000 ms','const int NearMs = 500;','const int NearMs = 5000;'),
  @('one change excuses many moves',"pend = false; haveFg = false;`n    win0 = seen;","pend = false;`n    win0 = seen;"),
  @('two moves together excused','if (one && haveFg && Dist','if (haveFg && Dist'),
  @('the burst rule gone','(have2 && unchecked(seen - ig2) <= (uint)BurstMs) || ',''),
  @('late looks part the move from the change','pend = true; one = true; pend0 = now;','pend = true; one = true; pend0 = stamp;'),
  @('a window move sets the person','if (Uncounted()) count++;','if (Uncounted()) { count++; person = seen; }'),
  @('a real move never sets the person',$tail,'if (!one || pair || release) { } else if (Uncounted()) { lones++; wasLone = true; }'),
  @('the person is the first move, not the last','if (!one || pair || release) person = seen;','if (!one || pair || release) person = pend0;'),
  @('always the raw input time','if (!on || first || (Dist(now, polled) > StaleMs && !(ok && st == seen && !pend))) return','if (Dist(now, polled) >= 0) return'),
  @('the stale fallback gone','if (!on || first || (Dist(now, polled) > StaleMs && !(ok && st == seen && !pend)))','if (!on || first)'),
  @('the wrap guard gone','int g = Gap(now, person); if (g < 0 && g > -60000) return 0;',''),
  @('the guard too wide, 30 days reads as here','if (g < 0 && g > -60000) return 0;','if (g < 0) return 0;'),
  @('the first look does not seed the person','first = false; seen = stamp; person = stamp; fg = f; return;','first = false; seen = stamp; fg = f; return;'),
  @('the thread never starts','[PillagersSpare.FocusWatch]::Start(); $script:noFocus=$false','$script:noFocus=$false'),
  @('the flag stays up, so the watch is never used','[PillagersSpare.FocusWatch]::Start(); $script:noFocus=$false','[PillagersSpare.FocusWatch]::Start()'),
  @('the thread looks 2 times a second','System.Threading.Thread.Sleep(100);','System.Threading.Thread.Sleep(500);'),
  @('the passive signs ignore a window or lone move','if([Math]::Min($a,$fo) -lt $PassCapSec){','if($a -lt $PassCapSec){'),
  @('no hold on a gate job','-not (Arrived) -and -not (FocusHold)){ Gate-Start','-not (Arrived)){ Gate-Start'),
  @('no hold on a stopped run going on','-not (Arrived) -and -not (FocusHold) -and (Resume-Corpus)','-not (Arrived) -and (Resume-Corpus)'),
  @('no hold on a new full run','-ge 900) -and -not (FocusHold)){ Start-Corpus','-ge 900)){ Start-Corpus'),
  @('no hold on the robot','(GetS ''gate_id'') -and -not (FocusHold)){ Start-Robot','(GetS ''gate_id'')){ Start-Robot'),
  @('no hold after the build',('  if(FocusHold){ PutS ''tries'' ([string]$tries); Say ''the input time moved with nobody seen while the test copy was built: the full run waits for the next round, its try is given back''; return }'+"`n"),''),
  @('the hold reaches IDLE MODE','if($Idle -or $script:noFocus -ne $false){ return $false }','if($script:noFocus -ne $false){ return $false }'),
  @('a NULL front counts as a change','if (f != IntPtr.Zero && f != fg)','if (f != fg)'),
  @('the burst test wraps','(have2 && unchecked(seen - ig2) <= (uint)BurstMs)','(have2 && Gap(seen, ig2) <= BurstMs)'),
  @('stale always raw','(Dist(now, polled) > StaleMs && !(ok && st == seen && !pend))','Dist(now, polled) > StaleMs'),
  @('stale hides a move not yet judged','!(ok && st == seen && !pend)','!(ok && st == seen)'),
  @('no ceiling',' || (n5 >= 5 && unchecked(seen - last5[n5 % 5]) <= (uint)CeilMs)',''),
  @('the ceiling looks at the newest, not the oldest','last5[n5 % 5]) <= (uint)CeilMs','last5[(n5 + 4) % 5]) <= (uint)CeilMs'),
  @('a held start is not logged','Say ''the input time moved with nobody seen: no new test work starts for at least 65 s, what is running goes on''','$null=$n'),
  @('the hold is too short for two graphics looks','FocusOnlyAgo() -ge 65)','FocusOnlyAgo() -ge 20)'),
  @('the watch loads in IDLE MODE too','if(-not $Idle -and -not $script:noIn){','if(-not $script:noIn){'),
  @('a window move is logged as nothing','Say (''the input time moved as the window in front changed to ''+$pn+'': not counted as someone at the PC'')','$null=$pn'),
  @('a burst is not logged','Say ''the input time keeps moving with nobody seen (3 times in 30 s or 6 in 10 minutes): counted as someone at the PC''','$null=$n'),
  @('the window 10 s to 100 s','const int LoneMs = 10000;','const int LoneMs = 100000;'),
  @('the window 10 s to 1 s','const int LoneMs = 10000;','const int LoneMs = 1000;'),
  @('exactly 10 s is outside','<= (uint)LoneMs','< (uint)LoneMs'),
  @('a lone move is a person again, as on master',$tail,'person = seen; if (one && !pair && !release) wasLone = true;'),
  @('a second move does not count',$tail,'if (!one || release) person = seen; else if (Uncounted()) { lones++; wasLone = true; }'),
  @('two moves together no longer count',$tail,'if (pair || release) person = seen; else if (Uncounted()) { lones++; wasLone = true; }'),
  @('the first lone move pairs with tick 0','bool pair = haveLone && unchecked','bool pair = (haveLone || true) && unchecked'),
  @('the pair test wraps','unchecked(seen - lone0) <= (uint)LoneMs','Gap(seen, lone0) <= LoneMs'),
  @('the pair is timed by the look, not the input time','unchecked(seen - lone0) <= (uint)LoneMs','unchecked(now - lone0) <= (uint)LoneMs'),
  @('every move pairs with itself',$keep,'wasLone = false;'),
  @('a person''s move does not carry on into the next lone move',$keep,'if (one && !pair && !release) { lone0 = seen; haveLone = true; } else { haveLone = false; } wasLone = false;'),
  @('a pair falls back to lone at the third',$keep,'if (!pair) lone0 = seen; haveLone = true; wasLone = false;'),
  @('a window move is the first of a pair','win0 = seen; haveWin = true;','win0 = seen; haveWin = true; lone0 = seen; haveLone = true;'),
  @('a window after a lone move is not a person',"    if (wasLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++; pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }`n",''),
  @('a window after a person''s move is a person','if (wasLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++;','if (haveLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++;'),
  @('a window after a lone move is a person at any gap','if (wasLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++;','if (wasLone) { pairs++;'),
  @('a window after a lone move pairs twice','pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }','pairMs = unchecked(seen - lone0); person = seen; return; }'),
  @('a window after a lone move is not logged as a pair','{ pairs++; pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }','{ wasLone = false; person = seen; return; }'),
  @('a window after a lone move does not set the person','pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }','pairMs = unchecked(seen - lone0); wasLone = false; return; }'),
  @('a lone move skips the burst and the ceiling','else if (Uncounted()) { lones++; wasLone = true; }','else { lones++; wasLone = true; focus = seen; haveFocus = true; }'),
  @('a lone move does not start the passive clock or the hold','else if (Uncounted()) { lones++; wasLone = true; }','else { uint f0 = focus; bool h0 = haveFocus; if (Uncounted()) { lones++; wasLone = true; focus = f0; haveFocus = h0; } }'),
  @('a lone move is not counted for the log','else if (Uncounted()) { lones++; wasLone = true; }','else if (Uncounted()) { wasLone = true; }'),
  @('the second of a pair also counts towards the third and the sixth','if (!one || pair || release) person = seen;','if (!one || pair || release) { person = seen; if (one) Uncounted(); }'),
  @('Lones gives the window moves','return lones;','return count;'),
  @('the lone line is not logged','Say ''the input time moved once, alone, with no change of the window in front within half a second: not counted as someone at the PC unless it moves again within 10 s''','$null=$n'),
  @('the lone line comes at every look','$script:loneN=$n; Say ''the input time moved once','Say ''the input time moved once'),
  @('the hold line ignores lone moves','Count()+[PillagersSpare.FocusWatch]::Lones(); if($n -ne $script:holdN)','Count(); if($n -ne $script:holdN)'),
  @('the counts do not start at 0','; $script:loneN=[uint32]0; $script:pairN=[uint32]0',''),
  @('a call the type does not have, which the catch would hide','[PillagersSpare.FocusWatch]::Lones(); if($n -ne $script:loneN)','[PillagersSpare.FocusWatch]::LoneCount(); if($n -ne $script:loneN)'),
  @('a release after a window move is not a person',$tail,'if (!one || pair) person = seen; else if (Uncounted()) { lones++; wasLone = true; }'),
  @('the release window 1 s to 10 s','const int ReleaseMs = 1000;','const int ReleaseMs = 10000;'),
  @('the release window 1 s to 200 ms','const int ReleaseMs = 1000;','const int ReleaseMs = 200;'),
  @('exactly 1 s is outside','<= (uint)ReleaseMs','< (uint)ReleaseMs'),
  @('the release is timed from tick 0','release = haveWin && unchecked','release = (haveWin || true) && unchecked'),
  @('a window move does not arm the release at all',"win0 = seen; haveWin = true;`n    if (wasLone && ","if (wasLone && "),
  @('a burst window move does not arm the release',"win0 = seen; haveWin = true;`n    if (wasLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++; pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }`n    if (Uncounted()) count++;","if (wasLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++; pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }`n    if (Uncounted()) { count++; win0 = seen; haveWin = true; }"),
  @('a person carrying on is called a pair','if (one && pair && wasLone)','if (one && pair && (wasLone || true))'),
  @('two moves together are called a pair','if (one && pair && wasLone)','if (pair && wasLone)'),
  @('a pair of lone moves is not counted','if (one && pair && wasLone) { pairs++; pairMs','if (one && pair && wasLone) { pairMs'),
  @('the gap of a pair of lone moves is wrong','if (one && pair && wasLone) { pairs++; pairMs = unchecked(seen - lone0);','if (one && pair && wasLone) { pairs++; pairMs = unchecked(seen - pend0);'),
  @('the pair line is not logged','Say (''the input time moved again ''+[Math]::Round([double][PillagersSpare.FocusWatch]::PairSec(),1)+'' s after a lone move (pair ''+$n+'' since this copy started): counted as someone at the PC'')','$null=$n'),
  @('the pair line comes at every look','$script:pairN=$n; Say (','Say ('),
  @('a code line hidden in the comment zone',"  # never loads it.`n","  # never loads it.`n  `$script:noFocus=`$true`n")
)
$tmp=Join-Path $here $Tmp; New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$runMock={ param($f,$o) & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'lone-mock.ps1') -File $f -Master $Master -Out $o 2>&1 | ForEach-Object { "$_" } }
$o0=Join-Path $tmp 'base.txt'; Remove-Item -LiteralPath $o0 -Force -ErrorAction SilentlyContinue; $res0=& $runMock $File $o0
if(-not (@($res0) -ccontains 'RESULT PASS')){ 'THE UNBROKEN RUNNER DOES NOT PASS, so this says nothing: '+(($res0 | Select-Object -Last 3) -join ' / '); exit 1 }
'the unbroken runner passes: '+(@($res0) | Where-Object { $_ -like 'checks *' })
$bad3=@($m | Where-Object { $_.Count -ne 3 }); if($bad3.Count){ 'A BREAK IS NOT THREE STRINGS: '+$bad3[0][0]; exit 1 }
$caught=0; $missed=@(); $i=0; $ran=0
foreach($x in $m){
  $i++; $name=$x[0]; if($i -lt $From -or $i -gt $To){ continue }; $ran++
  if($src.IndexOf([string]$x[1]) -lt 0){ ('{0,2} {1,-58} ANCHOR NOT FOUND' -f $i,$name); $missed+=$name; continue }
  $f=Join-Path $tmp 'spare-runner.ps1'; $o=Join-Path $tmp 'out.txt'; Remove-Item -LiteralPath $o -Force -ErrorAction SilentlyContinue
  [IO.File]::WriteAllText($f,$src.Replace([string]$x[1],[string]$x[2]),(New-Object Text.UTF8Encoding($false)))
  $res=& $runMock $f $o
  if(-not (Test-Path -LiteralPath $o)){ $missed+=$name; ('{0,2} {1,-58} MOCK STOPPED: {2}' -f $i,$name,((@($res) -join ' ') -replace '\s+',' ').Substring(0,[Math]::Min(140,((@($res) -join ' ') -replace '\s+',' ').Length))); continue }
  $wrong=@(Get-Content -LiteralPath $o | Where-Object { $_ -cmatch '\bWRONG\b' } | ForEach-Object { ($_ -split '\s{2,}')[0] } | Where-Object { $_ -notmatch '^(c1|c2) ' })
  if($wrong.Count){ $caught++; ('{0,2} {1,-58} caught by {2,3}: {3}' -f $i,$name,$wrong.Count,(($wrong | Select-Object -First 3 | ForEach-Object { $_.Substring(0,[Math]::Min(46,$_.Length)) }) -join ' / ')) }
  else { $missed+=$name; ('{0,2} {1,-58} NOT CAUGHT' -f $i,$name) }
}
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
"breaks $($m.Count), ran $ran, caught $caught, missed $($missed.Count)"
if($missed.Count){ 'missed: '+($missed -join '; ') }
