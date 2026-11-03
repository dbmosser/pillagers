# Breaks the new runner on purpose, one edit at a time, and says which mock checks catch each break. Checks c1 and c2 (undo gives master) always fail on a broken copy, so a
# break counts as caught only by another check. A break that stops the mock (one that does not compile, say) counts as missed, not caught. The unbroken runner must pass first.
# Only the lines this diff adds are broken here: c1 and c2 prove every other line is master's, whose own breaks ran on the lone-move diff. Nothing here opens a window.
# Usage: stray-mutants.ps1 -File new-runner.ps1 -Master master-runner.ps1 [-From n] [-To n] [-Tmp name] [-SkipBase]
param([string]$File,[string]$Master,[int]$From=1,[int]$To=999,[string]$Tmp='mutant',[switch]$SkipBase)
$here=Split-Path -Parent $MyInvocation.MyCommand.Path
$src=[IO.File]::ReadAllText($File)
$strayLine='if (mouse && !counted && !win && !release && (!pair || wasStray)) { lone0 = seen; haveLone = true; wasLone = unchecked(mouseT - mousePrev) >= 40 && unchecked(mouseT - mousePrev) <= (uint)NearMs; wasStray = true; strays++; return; }'
$m=@(
  @('the threshold 5 to 3','const int MouseN = 5;','const int MouseN = 3;'),
  @('the threshold 5 to 6','const int MouseN = 5;','const int MouseN = 6;'),
  @('the threshold 5 to 50','const int MouseN = 5;','const int MouseN = 50;'),
  @('the 10 s to 2 s','const int MouseMs = 10000;','const int MouseMs = 2000;'),
  @('the 10 s to 11 s','const int MouseMs = 10000;','const int MouseMs = 11000;'),
  @('exactly 10 s is outside','<= (uint)MouseMs','< (uint)MouseMs'),
  @('the count wraps','unchecked(t - mr[nm]) <= (uint)MouseMs','Gap(t, mr[nm]) <= MouseMs'),
  @('the ring looks at the newest','unchecked(t - mr[nm]) <= (uint)MouseMs','unchecked(t - mr[(nm + MouseN - 1) % MouseN]) <= (uint)MouseMs'),
  @('five reports does not need five','inUse = mc == MouseN && unchecked','inUse = unchecked'),
  @('the mouse never sets the person','{ person = t; why = 2; whyAt = t; }','{ why = 2; whyAt = t; }'),
  @('the mouse is not named','{ person = t; why = 2; whyAt = t; }','{ person = t; }'),
  @('a key is not a person','keys++; person = t; why = 1;','keys++; why = 1;'),
  @('a key is not named','keys++; person = t; why = 1; whyAt = t; return;','keys++; person = t; return;'),
  @('a key is taken for the mouse','if (kind == 1) {','if (kind == 9) {'),
  @('the mouse is taken for a key','if (kind == 1) {','if (kind == 0) {'),
  @('another kind counts as the mouse','if (kind != 0) return;',''),
  @('a key does not stop the stray','bool key = haveKey && Dist(keyT, seen) <= NearMs,','bool key = false && Dist(keyT, seen) <= NearMs,'),
  @('a key report near is timed from tick 0','bool key = haveKey && Dist','bool key = Dist'),
  @('a mouse report at any distance explains a move','mouse = haveMouse && Dist(mouseT, seen) <= NearMs;','mouse = haveMouse;'),
  @('a mouse report near is timed from tick 0','mouse = haveMouse && Dist','mouse = Dist'),
  @('the near window 500 ms to 100 ms','Dist(mouseT, seen) <= NearMs;','Dist(mouseT, seen) <= 100;'),
  @('only a report before the move explains it','Dist(mouseT, seen) <= NearMs;','Dist(mouseT, seen) <= NearMs && Gap(seen, mouseT) >= 0;'),
  @('no strays at all: the old rules',$strayLine,''),
  @('a stray ignores the window','if (mouse && !counted && !win && ','if (mouse && !counted && '),
  @('a stray ignores the release','&& !win && !release && ','&& !win && '),
  @('a stray ignores a person just before','&& (!pair || wasStray)) {',') {'),
  @('strays pair with strays','(!pair || wasStray)','(!pair)'),
  @('a key inside a stray still counts as a stray','bool counted = key || (mouse && person == mouseT);','bool counted = (mouse && person == mouseT);'),
  @('sustained use reads as a stray too','bool counted = key || (mouse && person == mouseT);','bool counted = key;'),
  @('a stray is not counted','wasStray = true; strays++; return;','wasStray = true; return;'),
  @('a stray does not mark itself','wasStray = true; strays++;','strays++;'),
  @('a stray moves the person','strays++; return; }','strays++; person = seen; return; }'),
  @('a stray starts the hold','strays++; return; }','strays++; focus = seen; haveFocus = true; return; }'),
  @('a stray counts towards the burst','strays++; return; }','Uncounted(); strays++; return; }'),
  @('a stray is not kept for a pair with a real move','{ lone0 = seen; haveLone = true; wasLone = unchecked','{ wasLone = unchecked'),
  @('any stray arms the window rule','wasLone = unchecked(mouseT - mousePrev) >= 40 && unchecked(mouseT - mousePrev) <= (uint)NearMs;','wasLone = true;'),
  @('no stray arms the window rule','wasLone = unchecked(mouseT - mousePrev) >= 40 && unchecked(mouseT - mousePrev) <= (uint)NearMs;','wasLone = false;'),
  @('a click may be 26 ms','unchecked(mouseT - mousePrev) >= 40','unchecked(mouseT - mousePrev) >= 20'),
  @('a click must be 50 ms','unchecked(mouseT - mousePrev) >= 40','unchecked(mouseT - mousePrev) >= 50'),
  @('a click may be any length',' && unchecked(mouseT - mousePrev) <= (uint)NearMs',''),
  @('the last report is not kept for the click','mousePrev = mouseT; mouseT = t;','mouseT = t;'),
  @('every report counts towards the five, so a jolt is a person','if (mc == 0 || unchecked(t - mr[(nm + MouseN - 1) % MouseN]) >= (uint)MouseGapMs) {','if (true) {'),
  @('the gap to 50 ms','const int MouseGapMs = 100;','const int MouseGapMs = 50;'),
  @('the gap to 200 ms','const int MouseGapMs = 100;','const int MouseGapMs = 200;'),
  @('exactly the gap is too close','>= (uint)MouseGapMs','> (uint)MouseGapMs'),
  @('the gap test wraps','unchecked(t - mr[(nm + MouseN - 1) % MouseN]) >= (uint)MouseGapMs','Gap(t, mr[(nm + MouseN - 1) % MouseN]) >= MouseGapMs'),
  @('the gap is from the oldest','mr[(nm + MouseN - 1) % MouseN]','mr[nm]'),
  @('in use only at the reports it keeps','  if (inUse) { person = t; why = 2; whyAt = t; }','  if (inUse && mouseT == mr[(nm + MouseN - 1) % MouseN]) { person = t; why = 2; whyAt = t; }'),
  @('in use never ends','inUse = mc == MouseN && unchecked(t - mr[nm]) <= (uint)MouseMs;','inUse = inUse || (mc == MouseN && unchecked(t - mr[nm]) <= (uint)MouseMs);'),
  @('the pair line counts a key','if (one && pair && wasLone && !key && !mouse)','if (one && pair && wasLone && !mouse)'),
  @('the pair line counts the mouse','if (one && pair && wasLone && !key && !mouse)','if (one && pair && wasLone && !key)'),
  @('a real move after a stray keeps the flag','wasLone = false; wasStray = false;','wasLone = false;'),
  @('a counted move goes on to the old rules',"    if (counted) return;`n",''),
  @('a click after a person is not a person',"    if (counted) return;`n    if (mouse) { person = seen; why = 2; whyAt = seen; return; }`n","    if (counted) return;`n"),
  @('a window with a key is a window move',"    if (key) return;`n",''),
  @('a click that changes the window is a window move',"    if (mouse) { person = seen; why = 2; whyAt = seen; return; }   // a click that changed the window`n",''),
  @('the reason ignores who is the person','return person == whyAt ? why : 0;','return why;'),
  @('Strays gives the lone moves','return strays;','return lones;'),
  @('the reports never open','try { RawOpen(); } catch { rawState = -1; }','rawState = -1;'),
  @('the reports never pump','try { if (rawState == 1) Pump(); } catch { }',''),
  @('a failed open pumps anyway','try { if (rawState == 1) Pump(); } catch { }','try { Pump(); } catch { }'),
  @('a pump failure stops the look','try { if (rawState == 1) Pump(); } catch { }','if (rawState == 1) Pump();'),
  @('the input command, which reads the key or position','GetRawInputData(m.l, 0x10000005, b, ref z, hs)','GetRawInputData(m.l, 0x10000003, b, ref z, hs)'),
  @('the keyboard is not asked for','d[1].page = 1; d[1].usage = 6;','d[1].page = 1; d[1].usage = 2;'),
  @('the mouse is not asked for','d[0].page = 1; d[0].usage = 2;','d[0].page = 1; d[0].usage = 6;'),
  @('only with a window in front: the keyboard','d[1].usage = 6; d[1].flags = 0x100;','d[1].usage = 6; d[1].flags = 0;'),
  @('only with a window in front: the mouse','d[0].usage = 2; d[0].flags = 0x100;','d[0].usage = 2; d[0].flags = 0;'),
  @('the queue is not dispatched',"    DispatchMessage(ref m);`n",''),
  @('it asks for the wrong message','if (m.m == 0xFF)','if (m.m == 0xFE)'),
  @('the time is the clock, not the report','Report(BitConverter.ToUInt32(b, 0), m.t);','Report(BitConverter.ToUInt32(b, 0), Now());'),
  @('the reason line is not asked',"    `$n=[PillagersSpare.FocusWatch]::PersonWhy(); if(`$n -eq 1){ `$w='a key press' }elseif(`$n -eq 2){ `$w='the mouse in use' }`n",''),
  @('the reasons are swapped',"if(`$n -eq 1){ `$w='a key press' }elseif(`$n -eq 2){ `$w='the mouse in use' }","if(`$n -eq 2){ `$w='a key press' }elseif(`$n -eq 1){ `$w='the mouse in use' }"),
  @('the stale reason stays when the watch throws',"`$fo=[double]1e9; `$w='keyboard or mouse' } }",'$fo=[double]1e9 } }'),
  @('a stray line with no 60 s limit',' -and ($e-$script:strayT) -ge 60',''),
  @('the reports line comes at every look','$script:rawSaid=$true; Say $(if','Say $(if'),
  @('a failed open says it is on','if($n -gt 0){ ''key and mouse reports are on','if($n -ne 0){ ''key and mouse reports are on'),
  @('the seed works with a person this copy saw','person == first0 && agoSec','agoSec'),
  @('the seed takes an age below 0',' && agoSec >= 0',''),
  @('the first look is not kept','person = stamp; first0 = stamp;','person = stamp;'),
  @('Load-Hold gives nothing back',"[PillagersSpare.FocusWatch]::Seed([double](`$e-[long]`$k))",'$null=$v'),
  @('Load-Hold gives the time, not the age',"Seed([double](`$e-[long]`$k))","Seed([double]`$k)"),
  @('Load-Hold takes anything','if($v -match ''^\d{9,11}$'' -and $k -match ''^\d{9,11}$'' -and ($e-[long]$v) -ge 0','if(($e-[long]$v) -ge 0'),
  @('Load-Hold takes it at any age',' -and ($e-[long]$v) -lt 300',''),
  @('Load-Hold takes it 10 minutes old','($e-[long]$v) -lt 300','($e-[long]$v) -lt 600'),
  @('Load-Hold takes a time ahead of the clock',' -and ($e-[long]$v) -ge 0',''),
  @('Load-Hold has no catch',"try{ [PillagersSpare.FocusWatch]::Seed([double](`$e-[long]`$k)) }catch{}","[PillagersSpare.FocusWatch]::Seed([double](`$e-[long]`$k))"),
  @('a code line hidden in the comment zone',"still counts what it finds.`n","still counts what it finds.`n  `$script:noFocus=`$true`n"),
  @('the seed does nothing','person = unchecked(Now() - (uint)(agoSec * 1000));',';'),
  @('the seed takes an age over the limit',' && agoSec <= 864300',''),
  @('the seed refuses the oldest','agoSec <= 864300','agoSec <= 864000'),
  @('the first look does not restart the passive signs',' if (Gap(first0, person) > 0) { focus = first0; haveFocus = true; }',''),
  @('the first look always restarts them','if (Gap(first0, person) > 0) { focus','{ focus'),
  @('the window is judged after the flag is dropped',"    bool win = haveFg && Gap(fgT, pend0) >= -NearMs;`n    pend = false; haveFg = false;`n","    pend = false; haveFg = false;`n    bool win = haveFg && Gap(fgT, pend0) >= -NearMs;`n"),
  @('any old window counts','bool win = haveFg && Gap(fgT, pend0) >= -NearMs;','bool win = haveFg;'),
  @('a window on the judging look is missed','bool win = haveFg && Gap(fgT, pend0) >= -NearMs;','bool win = haveFg && Dist(fgT, pend0) <= NearMs;'),
  @('a program counts as hardware',' && (IntPtr.Size == 8 ? BitConverter.ToInt64(b, 8) : BitConverter.ToInt32(b, 8)) != 0',''),
  @('a stray line at every look','$script:strayN=$n; $script:strayT=$e; Say','$script:strayT=$e; Say'),
  @('no stray line','Say (''stray mouse input, ''+$k+'' since the last such line: not counted as someone at the PC'')','$null=$k'),
  @('the new counts do not start at 0','; $script:strayN=[uint32]0; $script:strayT=[long]0; $script:rawSaid=$false',''),
  @('a restart leaves nothing','Save-Watch; Say ''a new copy','Say ''a new copy'),
  @('Save-Watch runs in IDLE MODE','if($Idle -or $script:noFocus -ne $false){ return }; try{ [void](AwaySec)','if($script:noFocus -ne $false){ return }; try{ [void](AwaySec)'),
  @('Save-Watch runs with no watch','if($Idle -or $script:noFocus -ne $false){ return }; try{ [void](AwaySec)','if($Idle){ return }; try{ [void](AwaySec)'),
  @('Save-Watch does not look first','try{ [void](AwaySec); $e=Epoch;','try{ $e=Epoch;'),
  @('Save-Watch writes the time for the age','([string]($e-[long][Math]::Min([Math]::Max($script:humanAgo,0),864000)))','([string]([long]$script:humanAgo))'),
  @('Save-Watch does not write when','PutS ''watch_t'' ([string]$e); ',''),
  @('a look writes it too',('  $script:humanAgo=$a'+"`n"),('  $script:humanAgo=$a; PutS ''watch_t'' ([string]$e)'+"`n")),
  @('Load-Hold asks with no watch','if($script:noFocus -eq $false -and -not $HbOld){ $v=GetS ''watch_t''','if(-not $HbOld){ $v=GetS ''watch_t'''),
  @('Load-Hold takes it after a reboot',' -and -not $HbOld){ $v=GetS ''watch_t''','){ $v=GetS ''watch_t'''),
  @('a call the type does not have, which the catch would hide','[PillagersSpare.FocusWatch]::Strays();','[PillagersSpare.FocusWatch]::StrayCount();')
)
$tmp=Join-Path $here $Tmp; New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$runMock={ param($f,$o,$real) $ar=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $here 'stray-mock.ps1'),'-File',$f,'-Master',$Master,'-Out',$o,'-Fast'); if(-not $real){ $ar+='-NoReal' }; & powershell.exe @ar 2>&1 | ForEach-Object { "$_" } }
if(-not $SkipBase){
  $o0=Join-Path $tmp 'base.txt'; Remove-Item -LiteralPath $o0 -Force -ErrorAction SilentlyContinue; $res0=& $runMock $File $o0 $true
  if(-not (@($res0) -ccontains 'RESULT PASS')){ 'THE UNBROKEN RUNNER DOES NOT PASS, so this says nothing: '+(($res0 | Select-Object -Last 3) -join ' / '); exit 1 }
  'the unbroken runner passes: '+(@($res0) | Where-Object { $_ -like 'checks *' })
}
$bad3=@($m | Where-Object { $_.Count -ne 3 }); if($bad3.Count){ 'A BREAK IS NOT THREE STRINGS: '+$bad3[0][0]; exit 1 }
$caught=0; $missed=@(); $i=0; $ran=0
foreach($x in $m){
  $i++; $name=$x[0]; if($i -lt $From -or $i -gt $To){ continue }; $ran++
  while(@(Get-Content 'C:\PillagersSpare\state.txt' | Where-Object { $_ -cmatch '^gate_id=.' }).Count -or ((Get-Date)-(Get-Item 'C:\PillagersSpare\runner.heartbeat').LastWriteTime).TotalSeconds -gt 240){ Start-Sleep -Seconds 20 }   # a gate job goes first, and a late heartbeat means this PC is short of processor: a runner 10 minutes late gets a second copy
  if($src.IndexOf([string]$x[1]) -lt 0){ ('{0,2} {1,-58} ANCHOR NOT FOUND' -f $i,$name); $missed+=$name; continue }
  $f=Join-Path $tmp 'spare-runner.ps1'; $o=Join-Path $tmp 'out.txt'; Remove-Item -LiteralPath $o -Force -ErrorAction SilentlyContinue
  [IO.File]::WriteAllText($f,$src.Replace([string]$x[1],[string]$x[2]),(New-Object Text.UTF8Encoding($false)))
  $res=& $runMock $f $o ($name -match 'reports never open|a call the type does not have|the thread|the flag')
  if(-not (Test-Path -LiteralPath $o)){ $missed+=$name; ('{0,2} {1,-58} MOCK STOPPED: {2}' -f $i,$name,((@($res) -join ' ') -replace '\s+',' ').Substring(0,[Math]::Min(140,((@($res) -join ' ') -replace '\s+',' ').Length))); continue }
  $wrong=@(Get-Content -LiteralPath $o | Where-Object { $_ -cmatch '\bWRONG\b' } | ForEach-Object { ($_ -split '\s{2,}')[0] } | Where-Object { $_ -notmatch '^(c1|c2) ' })
  if($wrong.Count){ $caught++; ('{0,2} {1,-58} caught by {2,3}: {3}' -f $i,$name,$wrong.Count,(($wrong | Select-Object -First 3 | ForEach-Object { $_.Substring(0,[Math]::Min(46,$_.Length)) }) -join ' / ')) }
  else { $missed+=$name; ('{0,2} {1,-58} NOT CAUGHT' -f $i,$name) }
}
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
"breaks $($m.Count), ran $ran, caught $caught, missed $($missed.Count)"
if($missed.Count){ 'missed: '+($missed -join '; ') }
