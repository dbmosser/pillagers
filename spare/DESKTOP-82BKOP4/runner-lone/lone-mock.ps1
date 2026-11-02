# MOCK test of the runner's lone-move change (spare PC: one lone move of the input time is not a person, a second within 10 s is), on top of FocusWatch as it landed in 77983f9b.
# Nothing here opens a window, changes focus, sends input or starts or stops a process. Part 1 proves undoing the change gives master byte for byte, outside the comment above FocusWatch. Part 2 compiles the
# runner's own FocusWatch C# with its clock and GetLastInputInfo swapped for fakes and plays timelines through Look at a 100 ms poll, and master's beside it. Part 3 runs the runner's own AwaySec,
# SoundWho, GpuGame, Save-Hold, Load-Hold, FocusHold and Arrived with the C# probes as stand-ins, and with the real C# on the fake clock. Part 4 runs master's AwaySec and the new one over the same grid. Part 5
# runs the runner's own load lines and its real thread for a few seconds, reading only. Usage: lone-mock.ps1 -File new-runner.ps1 -Master master-runner.ps1 [-Out file]
param([string]$File,[string]$Master,[string]$Out='')
[Diagnostics.Process]::GetCurrentProcess().PriorityClass='BelowNormal'
$r=New-Object Collections.ArrayList
function Check([string]$name,[bool]$ok,[string]$got=''){ [void]$r.Add([pscustomobject]@{ n=$name; ok=$ok; got=$got }) }
function Parse([string]$f){ $tok=$null; $err=$null; $a=[System.Management.Automation.Language.Parser]::ParseFile($f,[ref]$tok,[ref]$err); return ,@($a,$err) }
$pn=Parse $File; $pm=Parse $Master; $ast=$pn[0]; $astM=$pm[0]
Check 'p0 the new runner parses' ($pn[1].Count -eq 0) ("errors $($pn[1].Count)")
$bytes=[IO.File]::ReadAllBytes($File); Check 'p0b ASCII and LF only, as the repo keeps it' ((@($bytes | Where-Object { $_ -gt 127 -or $_ -eq 13 }).Count) -eq 0)
function Fns($a){ $h=@{}; foreach($d in $a.FindAll({ param($x) $x -is [System.Management.Automation.Language.FunctionDefinitionAst] },$true)){ $h[$d.Name]=$d.Extent.Text }; $h }
$fn=Fns $ast; $fm=Fns $astM

# ---- part 1: what changed, and nothing else
$tn=[IO.File]::ReadAllText($File); $tm=[IO.File]::ReadAllText($Master)
function Cut([string]$txt,[string]$from,[string]$to,[bool]$keepTo=$true){ $i=$txt.IndexOf($from); $j=$txt.IndexOf($to); if($i -lt 0 -or $j -le $i -or $txt.LastIndexOf($from) -ne $i){ return $null }; if($keepTo){ return $txt.Substring(0,$i)+$txt.Substring($j) }; return $txt.Substring(0,$i)+$txt.Substring($j+$to.Length) }
function Back([string]$new,[string]$old){ if($null -eq $script:undo){ return }; $at=$script:undo.IndexOf($new); if($at -lt 0 -or $script:undo.LastIndexOf($new) -ne $at){ $script:undo=$null; return }; $script:undo=$script:undo.Replace($new,$old) }
$cm1="  # 15 minutes. FocusWatch looks"; $cm2='  $script:noFocus=$true; $script:focusN=[uint32]0;'
$script:undo=Cut $tn $cm1 $cm2; $tmc=Cut $tm $cm1 $cm2
Back ' (not one lone move of the input time, see FocusWatch)' ''
Back '; $script:loneN=[uint32]0; $script:pairN=[uint32]0' ''
Back 'const int ReleaseMs = 1000; const int LoneMs = 10000; ' ''
Back ', haveLone = false, haveWin = false, wasLone = false;' ';'
Back ', lone0, win0, lones, pairs, pairMs;' ';'
Back '// the last five moves not counted, oldest' '// the last five window moves, oldest'
Back "// a move that is not a key or the mouse so far: true if it stays not counted, false if there have been too many, so it is a person`nstatic bool Uncounted(){`n  if ((have2 && unchecked(seen - ig2) <= (uint)BurstMs) || (n5 >= 5 && unchecked(seen - last5[n5 % 5]) <= (uint)CeilMs)) { person = seen; bursts++; return false; }`n  ig2 = ig1; have2 = have1; ig1 = seen; have1 = true; last5[n5 % 5] = seen; n5++; focus = seen; haveFocus = true;`n  return true;`n}`n" ''
Back "    win0 = seen; haveWin = true;`n    if (wasLone && unchecked(seen - lone0) <= (uint)LoneMs) { pairs++; pairMs = unchecked(seen - lone0); wasLone = false; person = seen; return; }`n    if (Uncounted()) count++;`n" "    if ((have2 && unchecked(seen - ig2) <= (uint)BurstMs) || (n5 >= 5 && unchecked(seen - last5[n5 % 5]) <= (uint)CeilMs)) { person = seen; bursts++; return; }`n    ig2 = ig1; have2 = have1; ig1 = seen; have1 = true; last5[n5 % 5] = seen; n5++; focus = seen; haveFocus = true; count++;`n"
Back "  if (Gap(now, pend0) > NearMs) {`n    pend = false; haveFg = false;`n    bool pair = haveLone && unchecked(seen - lone0) <= (uint)LoneMs, release = haveWin && unchecked(seen - win0) <= (uint)ReleaseMs;`n    if (one && pair && wasLone) { pairs++; pairMs = unchecked(seen - lone0); }`n    lone0 = seen; haveLone = true; wasLone = false;`n    if (!one || pair || release) person = seen; else if (Uncounted()) { lones++; wasLone = true; }`n  }`n" "  if (Gap(now, pend0) > NearMs) { pend = false; haveFg = false; person = seen; }`n"
Back "public static uint Lones(){ lock (K) { return lones; } }`npublic static uint Pairs(){ lock (K) { return pairs; } }`npublic static double PairSec(){ lock (K) { return pairMs / 1000.0; } }`n" ''
Back ', or that came alone, is not a key or the mouse (see FocusWatch above); it still restarts' ' is not a key or the mouse (see FocusWatch above); it still starts'
Back ('    $n=[PillagersSpare.FocusWatch]::Lones(); if($n -ne $script:loneN){ $script:loneN=$n; Say ''the input time moved once, alone, with no change of the window in front within half a second: not counted as someone at the PC unless it moves again within 10 s'' }'+"`n") ''
Back ('    $n=[PillagersSpare.FocusWatch]::Pairs(); if($n -ne $script:pairN){ $script:pairN=$n; Say (''the input time moved again ''+[Math]::Round([double][PillagersSpare.FocusWatch]::PairSec(),1)+'' s after a lone move (pair ''+$n+'' since this copy started): counted as someone at the PC'') }'+"`n") ''
Back 'the input time keeps moving with nobody seen (3 times' 'the window in front keeps changing (3 times'
Back 'a window move or a lone move may be a game' 'a window move may be a game'
Back '$n=[PillagersSpare.FocusWatch]::Count()+[PillagersSpare.FocusWatch]::Lones(); if($n -ne $script:holdN)' '$n=[PillagersSpare.FocusWatch]::Count(); if($n -ne $script:holdN)'
Back 'the input time moved with nobody seen: no new test work starts for at least 65 s' 'a window came to the front: no new test work starts for 65 s'
Back 'the input time moved with nobody seen while the test copy' 'a window came to the front while the test copy'
Check 'c1 the marks and every changed piece are there, once each' ([bool]$script:undo -and [bool]$tmc)
Check 'c2 undoing the change gives master byte for byte, outside the comment above FocusWatch' ($script:undo -ceq $tmc) ("lengths $(if($script:undo){$script:undo.Length}) $(if($tmc){$tmc.Length})")
function Zone([string]$txt){ $a0=$txt.IndexOf($cm1); $b0=$txt.IndexOf($cm2); if($a0 -lt 0 -or $b0 -le $a0){ return @('(no zone)') }; return @($txt.Substring($a0,$b0-$a0).Split("`n") | Where-Object { $_ -ne '' -and $_ -notlike '  # *' }) }
$zn=Zone $tn; Check 'c2b what c2 cuts is only comment lines, so no code can hide there' ($zn.Count -eq 0 -and (Zone $tm).Count -eq 0) (($zn | Select-Object -First 2) -join ' | ')
$diffFns=@($fm.Keys | Where-Object { $fn[$_] -cne $fm[$_] } | Sort-Object); $newFns=@($fn.Keys | Where-Object { -not $fm[$_] })
Check 'c3 only AwaySec, FocusHold and Start-Corpus differ, Arrived and Gate-Tick do not, and there is no new function' (($diffFns -join ',') -ceq 'AwaySec,FocusHold,Start-Corpus' -and $newFns.Count -eq 0) (($diffFns -join ',')+' new '+($newFns -join ','))
$add=@($ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.CommandAst] -and $x.GetCommandName() -eq 'Add-Type' -and $x.Extent.Text -match 'FocusWatch' },$true))
$up=$add[0]; $conds=@(); $tryAst=$null; while($up){ if($up -is [System.Management.Automation.Language.TryStatementAst] -and -not $tryAst){ $tryAst=$up }; if($up -is [System.Management.Automation.Language.IfStatementAst]){ $conds+=$up.Clauses[0].Item1.Extent.Text }; $up=$up.Parent }
Check 'c4 FocusWatch loads only inside if(-not $Idle -and -not $script:noIn)' ($add.Count -eq 1 -and $conds -contains '-not $Idle -and -not $script:noIn') ($conds -join ' | ')
$fnA=[System.Management.Automation.Language.Parser]::ParseInput($fn['AwaySec'],[ref]$null,[ref]$null).EndBlock.Statements[0].Body.EndBlock.Statements
$fmA=[System.Management.Automation.Language.Parser]::ParseInput($fm['AwaySec'],[ref]$null,[ref]$null).EndBlock.Statements[0].Body.EndBlock.Statements
Check 'c5 AwaySec: the IDLE MODE line and the no-check line come first and are master''s' ($fnA[0].Extent.Text -ceq $fmA[0].Extent.Text -and $fnA[1].Extent.Text -ceq $fmA[1].Extent.Text -and $fnA[0].Extent.Text -like 'if($Idle)*' -and $fnA[1].Extent.Text -like 'if($script:noIn)*')
$cs=@($ast.FindAll({ param($p1) $p1 -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $p1.StringConstantType -eq 'SingleQuotedHereString' },$true) | Where-Object { $_.Value -match 'PersonIdleSec' })[0].Value
Check 'c6 the watch reads no key, no title and no mouse position' ($cs -notmatch 'GetAsyncKeyState|GetKeyState|GetKeyboardState|SetWindowsHookEx|GetWindowText|GetCursorPos|ReadConsole')
Check 'c7 the watch does not hold the process open' ($cs -match 'IsBackground = true')
Check 'c7a the runner starts its lone and pair counts at 0, so the first look says nothing' ($tn.Contains('$script:holdN=[uint32]0; $script:loneN=[uint32]0; $script:pairN=[uint32]0'+"`n"))
Check 'c7b FocusHold is asked in exactly five places, and nothing in the loop waits or goes round on it' (([regex]::Matches($tn,'\(FocusHold\)|if\(FocusHold\)')).Count -eq 5 -and $tn -notmatch 'FocusHold\)\{[^}]*(Start-Sleep|continue)') ("$(([regex]::Matches($tn,'\(FocusHold\)|if\(FocusHold\)')).Count)")

# ---- part 2: the runner's own C#, on a fake clock
$imp='[DllImport("user32.dll")] static extern bool GetLastInputInfo(ref LII p);'
$now0='static uint Now(){ return (uint)Environment.TickCount; }'
$fg0='static IntPtr fg;'
foreach($a in $imp,$now0,$fg0,'static bool on = false,'){ if($cs.IndexOf($a) -lt 0){ throw ('C# anchor not found: '+$a) } }
$cf=$cs.Replace($imp,'public static uint FakeSt; public static bool FakeOk = true; static bool GetLastInputInfo(ref LII p){ p.dwTime = FakeSt; return FakeOk; }')
$cf=$cf.Replace($now0,'public static uint FakeNow; static uint Now(){ return FakeNow; }')
$cf=$cf.Replace($fg0,$fg0+' public static void MockReset(){ on = true; first = true; pend = false; one = false; haveFg = false; haveFocus = false; have1 = false; have2 = false; haveLone = false; haveWin = false; wasLone = false; seen = person = pend0 = fgT = polled = focus = ig1 = ig2 = count = bursts = fgPid = lone0 = win0 = lones = pairs = pairMs = 0; fg = IntPtr.Zero; n5 = 0; } public static void MockOff(){ on = false; }')
$tag='T'+[Guid]::NewGuid().ToString('N').Substring(0,8); Add-Type -Namespace ('MockFocus'+$tag) -Name W -MemberDefinition $cf -ErrorAction Stop; $T=[type]('MockFocus'+$tag+'.W')
# master's C#, the same way, to run beside the new one
$csM=@($astM.FindAll({ param($p1) $p1 -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $p1.StringConstantType -eq 'SingleQuotedHereString' },$true) | Where-Object { $_.Value -match 'PersonIdleSec' })[0].Value
$cfM=$csM.Replace($imp,'public static uint FakeSt; public static bool FakeOk = true; static bool GetLastInputInfo(ref LII p){ p.dwTime = FakeSt; return FakeOk; }').Replace($now0,'public static uint FakeNow; static uint Now(){ return FakeNow; }').Replace($fg0,$fg0+' public static void MockReset(){ on = true; first = true; pend = false; one = false; haveFg = false; haveFocus = false; have1 = false; have2 = false; seen = person = pend0 = fgT = polled = focus = ig1 = ig2 = count = bursts = fgPid = 0; fg = IntPtr.Zero; n5 = 0; }')
Add-Type -Namespace ('MockFocusM'+$tag) -Name W -MemberDefinition $cfM -ErrorAction Stop; $TM=[type]('MockFocusM'+$tag+'.W')
function U([long]$x){ [uint32]($x -band [long]4294967295) }
# one timeline: events are @(ms,'k') a key or the mouse, @(ms,'f') a focus change that moves the stamp in the same instant (what this PC showed), @(ms,'s') the stamp alone,
# @(ms,'F') the window in front alone, @(ms,'n') the stamp with the front going NULL. Polled every 100 ms from $phase, skipping any look in $skipA..$skipB (a late look). Returns when the person was last seen, and so on.
function Sim([object[]]$ev,[long]$end,[long]$base=1000000,[int]$phase=0,[long]$skipA=-1,[long]$skipB=-1,[int]$gap=100,[long]$seedAgo=600000){
  $T::MockReset(); $stamp=[long]($base-$seedAgo); $fgv=1; $i=0; $zero=$false
  $ev=@($ev | Sort-Object { $_[0] })
  for($tick=[long]$phase;$tick -le $end;$tick+=$gap){
    if($tick -gt $skipA -and $tick -lt $skipB){ continue }
    while($i -lt $ev.Count -and [long]$ev[$i][0] -le $tick){ $e=$ev[$i]; if($e[1] -cin 'k','s','f','n'){ $stamp=$base+[long]$e[0] }; if($e[1] -cin 'f','F'){ $fgv++; $zero=$false }; if($e[1] -ceq 'n'){ $zero=$true }; $i++ }
    $n=U ($base+$tick); $st=U $stamp; $T::FakeNow=$n; $T::FakeSt=$st; $T::Look($n,$st,[IntPtr]$(if($zero){ 0 }else{ $fgv }),[uint32](100+$fgv))
  }
  $T::FakeNow=U ($base+$end); $T::FakeSt=U $stamp
  return [pscustomobject]@{ at=[long][Math]::Round($end-$T::PersonIdleSec()*1000); fo=$T::FocusOnlyAgo(); n=[long]$T::Count(); b=[long]$T::Bursts(); pid=[long]$T::LastPid(); l=$(if($T.GetMethod('Lones')){ [long]$T::Lones() }else{ [long]0 }); pr=$(if($T.GetMethod('Pairs')){ [long]$T::Pairs() }else{ [long]0 }); ps=$(if($T.GetMethod('PairSec')){ [double]$T::PairSec() }else{ [double]0 }) }
}
$seed=-600000
# a real key: a press and a release 110 ms apart, so a 100 ms poll always sees two moves. The event 's' is one lone move.
function Key([long]$at,[int]$hold=110){ return @(@($at,'k'),@(($at+$hold),'k')) }
function CS([string]$name,[object[]]$ev,[long]$end,[long]$wantAt,[long]$wantN){
  foreach($ph in 0,37,99){ $x=Sim $ev $end 1000000 $ph; Check ($name+' (poll phase '+$ph+')') ($x.at -eq $wantAt -and $x.n -eq $wantN) ("person at $($x.at) want $wantAt; window moves $($x.n) want $wantN") }
}
CS 'w1 nothing happens: the first look counts as the person' @() 9000 $seed 0
CS 'w2 a program takes the front, one move: not a person, counted' @(,@(5000,'f')) 9000 $seed 1
$x=Sim @(,@(5000,'f')) 9000; Check 'w2b it starts the passive clock, at the move' ([Math]::Abs($x.fo-4.0) -lt 0.01) ("fo $($x.fo)")
CS 'w3 the input time 80 ms before the window change' @(@(5000,'s'),@(5080,'F')) 9000 $seed 1
CS 'w4 the input time 400 ms before the window change' @(@(5000,'s'),@(5400,'F')) 9000 $seed 1
CS 'w5 the window change 80 ms before the input time' @(@(5000,'F'),@(5080,'s')) 9000 $seed 1
CS 'w6 the window change 300 ms before the input time' @(@(5000,'F'),@(5300,'s')) 9000 $seed 1
$x=Sim @(,@(5000,'f')) 9000 1000000 0 4950 5950; Check 'w7 the looks stop for a second around a window move (a busy PC): still a window move, not the old false pause' ($x.at -eq $seed -and $x.n -eq 1) ("at $($x.at) n $($x.n)")
$x=Sim @(,@(5000,'f')) 9000 1000000 37 4000 8000; Check 'w8 for 4 s: the same' ($x.at -eq $seed -and $x.n -eq 1) ("at $($x.at) n $($x.n)")
CS 'k1 a real key, press and release, no window change: a person, at the release' (Key 5000) 9000 5110 0
CS 'k2 a key 2 s after a window move: a person' (@(,@(5000,'f'))+(Key 7000)) 9000 7110 1
CS 'k3 a key 2 s before a window move: a person, and the move is not' ((Key 3000)+@(,@(5000,'f'))) 9000 3110 1
CS 'k4 a key 700 ms before a window move: a person' ((Key 4300)+@(,@(5000,'f'))) 9000 4410 1
CS 'k5 a key 700 ms after a window move: a person' (@(,@(5000,'f'))+(Key 5700)) 9000 5810 1
CS 'k6 a key 300 ms after a window move: a person (one change excuses one move)' (@(,@(5000,'f'))+(Key 5300)) 9000 5410 1
CS 'k7 a key 200 ms after a window move: a person' (@(,@(5000,'f'))+(Key 5200)) 9000 5310 1
CS 'k10 a key 300 ms before a window move: a person, two moves are not one' @(@(4700,'k'),@(5000,'f')) 9000 5000 0
$alt=@(@(4800,'k'),@(4880,'k'),@(4960,'k'),@(5000,'k'),@(5010,'f'))
CS 'k11 Alt+Tab once, then reading the screen: a person' $alt 9000 5010 0
$altUp=@(@(4000,'k'),@(4900,'k'),@(5000,'f'),@(5150,'k'),@(5200,'k'))
CS 'k12 Alt held, Tab: the window changes, then the keys come up: a person' $altUp 9000 5200 0
$many=@(); foreach($o in 0,16000,32000,48000,64000){ foreach($q in 0,80,160,200){ $many+=,@((5000+$o+$q),'k') }; $many+=,@((5000+$o+210),'f') }
$x=Sim $many 70000; Check 'k13 Alt+Tab every 16 s and nothing else: a person from the first' ($x.at -ge 69000 -and $x.n -eq 0) ("person at $($x.at), window moves $($x.n)")
$x=Sim @(,@(5000,'f')) 9000; $first=$x.at; $x=Sim @(@(5000,'k'),@(5050,'f')) 9000 1000000 99; Check 'k14 the known limit: a press and release inside one look that changes the window is one move, so it is missed' ($x.at -eq $seed -and $x.n -eq 1) ("at $($x.at) n $($x.n)")
$x=Sim (@(@(5000,'k'),@(5050,'f'))+(Key 6500)) 9000 1000000 99; Check 'k14b and the next key is a person' ($x.at -eq 6610) ("at $($x.at)")
$st=@(); for($q=5000;$q -le 8000;$q+=50){ $st+=,@($q,'k') }
$x=Sim $st 8000; Check 'm1 a mouse moving non-stop is a person while it moves' ((8000-$x.at) -le 700 -and $x.n -eq 0) ("person at $($x.at) of 8000, moves $($x.n)")
$x=Sim $st 5900; Check 'm1b under 1 s after it starts' (($x.at) -ge 5000 -and $x.n -eq 0) ("person at $($x.at)")
$st2=$st+,@(6500,'F'); $x=Sim $st2 8000; Check 'm2 a click that changes the window, in a moving mouse: still a person, and no window move' ((8000-$x.at) -le 1000 -and $x.n -eq 0) ("person at $($x.at) of 8000, moves $($x.n)")
$st3=@(); for($q=5000;$q -le 7000;$q+=120){ $st3+=,@($q,'k') }; $st3+=,@(7100,'f'); $x=Sim $st3 9000; Check 'm3 mouse to an icon, click, window opens: a person, to the end of it' ($x.at -ge 7000) ("person at $($x.at), moves $($x.n)")
CS 'b1 two window moves in 30 s: neither is a person' @(@(5000,'f'),@(10000,'f')) 14000 $seed 2
CS 'b2 a third in 30 s: a person' @(@(5000,'f'),@(10000,'f'),@(15000,'f')) 19000 15000 2
$x=Sim @(@(5000,'f'),@(10000,'f'),@(15000,'f')) 19000; Check 'b2b it is counted, for the log' ($x.b -eq 1) ("bursts $($x.b)")
CS 'b3 three spread over more than 30 s: none is a person' @(@(5000,'f'),@(25000,'f'),@(45000,'f')) 49000 $seed 3
CS 'b4 five quick ones: a person from the third on' @(@(2000,'f'),@(4000,'f'),@(6000,'f'),@(8000,'f'),@(10000,'f')) 14000 10000 2
CS 'f1 a window change with no input time move, then a key 3 s later: a person' (@(,@(5000,'F'))+(Key 8000)) 9000 8110 0
CS 'f2 a window change with no move does not count as a window move' @(,@(5000,'F')) 9000 $seed 0
$x=Sim @(,@(5000,'f')) 9000; Check 'f3 it keeps the process of the new window for the log' ($x.pid -eq 102) ("pid $($x.pid)")
CS 'n1 Enter on a dialog: the front goes NULL with the press, the next window with the release: a person, not two window moves' @(@(5000,'n'),@(5100,'f')) 9000 5100 0
CS 'n2 a window closes by itself, the front NULL for a moment, then the next window: one window move' @(@(5000,'n'),@(5100,'F')) 9000 $seed 1
CS 'n3 the front goes NULL and stays there, one move: a lone move, not a person' @(,@(5000,'n')) 9000 $seed 0
$bw=[long]4294967295-5000
$x=Sim @(,@(5500,'f')) 9000 $bw; Check 'z1 the tick count wraps: a window move is still one' ($x.at -eq $seed -and $x.n -eq 1) ("at $($x.at) n $($x.n)")
$x=Sim (Key 5500) 9000 $bw; Check 'z2 the tick count wraps: a key is still a person' ($x.at -eq 5610 -and $x.n -eq 0) ("at $($x.at) n $($x.n)")
[void](Sim (Key 5000) 6000); $T::FakeNow=U (1000000+5094); $a=$T::PersonIdleSec(); Check 'z3 a clock just behind the person''s time reads as just now, not 49 days' ($a -lt 1) ("$a")
$T::MockReset(); $T::FakeNow=[uint32]1000; $T::FakeSt=[uint32]1000; $T::Look([uint32]1000,[uint32]1000,[IntPtr]1,[uint32]1); $n30=[uint32](30*86400000 % 4294967296 + 1000); $T::FakeNow=$n30; $T::FakeSt=[uint32]1000; $T::Look($n30,[uint32]1000,[IntPtr]1,[uint32]1); $a=$T::PersonIdleSec(); Check 'z4 nobody for 30 days reads as 30 days, not as someone here' ([Math]::Abs($a-2592000) -lt 2) ("$a")
function LookAt([long]$at,[long]$st,[int]$f){ $n=U $at; $s=U $st; $T::FakeNow=$n; $T::FakeSt=$s; $T::Look($n,$s,[IntPtr]$f,[uint32]1) }
$T::MockReset(); LookAt 1000 900 1; LookAt 5000 5000 2; LookAt 9000 9000 3; $d26=[long]26*86400000; LookAt ($d26+1000) ($d26+1000) 4; LookAt ($d26+2000) ($d26+2000) 4; $b0=$T::Bursts(); Check 'z5 a window move 26 days after the last two is not a burst' ($b0 -eq 0 -and $T::Count() -eq 3) ("bursts $b0 moves $($T::Count())")
function Flips([int]$count,[long]$gap){ $T::MockReset(); LookAt 1000 900 1; for($q=1;$q -le $count;$q++){ $tq=1000+$q*$gap; LookAt $tq $tq (1+$q) } }
Flips 5 100000; Check 'e1 five window moves 100 s apart: none is a person' ($T::Count() -eq 5 -and $T::Bursts() -eq 0) ("moves $($T::Count()) bursts $($T::Bursts())")
Flips 6 100000; Check 'e2 a sixth inside 10 minutes: a person, so a program that keeps taking the front gets an open pause' ($T::Count() -eq 5 -and $T::Bursts() -eq 1) ("moves $($T::Count()) bursts $($T::Bursts())")
Flips 7 100000; Check 'e2b and the next' ($T::Bursts() -eq 2) ("bursts $($T::Bursts())")
Flips 6 20000; Check 'e3 every 20 s, the crash loop that never bursts: a person at the sixth, not a hold for ever' ($T::Bursts() -eq 1) ("moves $($T::Count()) bursts $($T::Bursts())")
Flips 9 130000; Check 'e4 about 2 minutes apart, over 10 minutes for six: none is a person' ($T::Bursts() -eq 0 -and $T::Count() -eq 9) ("moves $($T::Count()) bursts $($T::Bursts())")
$T::MockReset(); $T::FakeNow=[uint32]50000; $T::FakeSt=[uint32]40000; $a=$T::PersonIdleSec(); Check 't1 no look yet: the raw input time' ([Math]::Abs($a-10) -lt 0.01) ("$a")
[void](Sim @(,@(5000,'f')) 9000); $T::FakeNow=U (1000000+9000+3100); $T::FakeSt=U (1000000+5000); $a=$T::PersonIdleSec(); Check 't2 the thread stopped looking for over 3 s and nothing has moved since: the window move stays judged, no false stop' ($a -gt 500) ("$a")
[void](Sim @(,@(5000,'f')) 9000); $T::FakeNow=U (1000000+9000+3100); $T::FakeSt=U (1000000+11000); $a=$T::PersonIdleSec(); Check 't2b it stopped and the input time moved since: the raw time, so a key still counts' ([Math]::Abs($a-1.1) -lt 0.01) ("$a")
[void](Sim @(,@(5000,'f')) 9000); $T::FakeNow=U (1000000+9000+2900); $T::FakeSt=U (1000000+5000); $a=$T::PersonIdleSec(); Check 't3 under 3 s since a look: the watch still answers' ($a -gt 500) ("$a")
$T::MockReset(); LookAt 1000000 900000 1; LookAt 1010050 1010040 1; $T::FakeNow=U 1013100; $T::FakeSt=U 1010040; $a=$T::PersonIdleSec(); Check 't2c it stopped with a move seen but not yet judged: the raw time, a person, not the old answer' ([Math]::Abs($a-3.06) -lt 0.01) ("$a")
$T::MockOff(); $T::FakeNow=U (1000000+9001); $T::FakeSt=U (1000000+5000); $a=$T::PersonIdleSec(); Check 't4 not started: the raw input time' ([Math]::Abs($a-4.001) -lt 0.01) ("$a")
$T::MockReset(); [void](Sim @() 500); $T::FakeOk=$false; $T::FakeNow=U (1000000+9000); $a=$T::PersonIdleSec(); Check 't5 stale and GetLastInputInfo fails: 0, someone here, as IdleSec says' ($a -eq 0) ("$a"); $T::FakeOk=$true
$T::MockReset(); $x=$T::FocusOnlyAgo(); Check 't6 no window move yet: the passive clock is not started' ($x -ge 1e9) ("$x")

# ---- part 2b: the lone move rule. The event 's' is one move of the input time, alone
CS 'L1 one move alone, no window change: not a person' @(,@(5000,'s')) 9000 $seed 0
$x=Sim @(,@(5000,'s')) 9000; Check 'L1b it counts as a lone move, not as a window move' ($x.l -eq 1 -and $x.n -eq 0 -and $x.b -eq 0) ("lone $($x.l) window $($x.n) bursts $($x.b)")
Check 'L1c it starts the passive clock and the hold, at the move' ([Math]::Abs($x.fo-4.0) -lt 0.01) ("fo $($x.fo)")
CS 'L2 a second move 2 s later: a person, at the second' @(@(5000,'s'),@(7000,'s')) 9000 7000 0
$x=Sim @(@(5000,'s'),@(7000,'s')) 9000; Check 'L2b the second is not counted as lone' ($x.l -eq 1) ("lone $($x.l)")
CS 'L3 a second 800 ms later, after the first was judged: a person' @(@(5000,'s'),@(5800,'s')) 9000 5800 0
CS 'L4 a second 9.9 s later: a person' @(@(5000,'s'),@(14900,'s')) 17000 14900 0
CS 'L5 a second exactly 10 s later: a person' @(@(5000,'s'),@(15000,'s')) 17000 15000 0
CS 'L6 a second 10.1 s later: not a person' @(@(5000,'s'),@(15100,'s')) 17000 $seed 0
$x=Sim @(@(5000,'s'),@(15100,'s')) 17000; Check 'L6b two lone moves, and the passive clock is at the later' ($x.l -eq 2 -and [Math]::Abs($x.fo-1.9) -lt 0.01) ("lone $($x.l) fo $($x.fo)")
CS 'L7 two moves together, under half a second: a person, as on master' @(@(5000,'s'),@(5300,'s')) 9000 5300 0
$x=Sim (Key 5000 40) 9000 1000000 99; Check 'L8 a 40 ms press and release that falls inside one look: one lone move, the known limit' ($x.at -eq $seed -and $x.l -eq 1) ("at $($x.at) lone $($x.l)")
$x=Sim (Key 5000 40) 9000 1000000 0; Check 'L8a the same press across two looks: a person' ($x.at -eq 5040 -and $x.l -eq 0) ("at $($x.at) lone $($x.l)")
$x=Sim ((Key 5000 40)+(Key 7000)) 9000 1000000 99; Check 'L8b and the next real key is a person' ($x.at -eq 7110) ("at $($x.at)")
CS 'L9 a lone move 6 s after a window move, measured here at 11:16: not a person' @(@(5000,'f'),@(11000,'s')) 14000 $seed 1
CS 'L10 A TAP THAT LAUNCHES SOMETHING, a window move 2 s after a lone move: a person, as on master' @(@(5000,'s'),@(7000,'f')) 9000 7000 0
CS 'L10b a window move exactly 10 s after a lone move: a person' @(@(5000,'s'),@(15000,'f')) 17000 15000 0
CS 'L10c a window move 10.1 s after a lone move: nobody, two moves not counted' @(@(5000,'s'),@(15100,'f')) 17000 $seed 1
$x=Sim @(@(5000,'s'),@(7000,'f')) 9000; Check 'L10d it is logged as a pair, with its gap, and not as a window move' ($x.pr -eq 1 -and [Math]::Abs($x.ps-2.0) -lt 0.01 -and $x.n -eq 0 -and $x.l -eq 1) ("pairs $($x.pr) gap $($x.ps) window $($x.n) lone $($x.l)")
$x=Sim @(@(5000,'s'),@(7000,'f'),@(14000,'f')) 17000; Check 'L10e the next window move, inside the same 10 s: not a second pair' ($x.pr -eq 1 -and $x.n -eq 1) ("pairs $($x.pr) window $($x.n)")
CS 'L11 a window move and a lone move 2 s later: neither is a person' @(@(5000,'f'),@(7000,'s')) 9000 $seed 1
CS 'L12 a window move between two lone moves 4 s apart: a person from the window move on' @(@(5000,'s'),@(7000,'f'),@(9000,'s')) 12000 9000 0
$x=Sim @(@(5000,'s'),@(7000,'f'),@(9000,'s')) 12000; Check 'L12b it is the pair that says so, not the burst rule, and once' ($x.b -eq 0 -and $x.pr -eq 1 -and [Math]::Abs($x.ps-2.0) -lt 0.01) ("bursts $($x.b) pairs $($x.pr) gap $($x.ps)")
CS 'R1 CLICK ON A BACKGROUND WINDOW, the press changes the front, the release 150 ms later: a person, as on master' @(@(5000,'f'),@(5150,'s')) 9000 5150 1
CS 'R2 the press, the window change 10 ms after it, the release: a person' @(@(5000,'s'),@(5010,'F'),@(5150,'s')) 9000 5150 1
CS 'R3 the press, the window change 100 ms after it, the release: a person' @(@(5000,'s'),@(5100,'F'),@(5200,'s')) 9000 5200 1
CS 'R4 the press, the window change 400 ms after it, the release 800 ms after the press: a person' @(@(5000,'s'),@(5400,'F'),@(5800,'s')) 9000 5800 1
CS 'R5 a release exactly 1 s after the window move: a person' @(@(5000,'f'),@(6000,'s')) 9000 6000 1
CS 'R6 a known limit: a click on a background window held 1.1 s with the pointer still, the release is a lone move' @(@(5000,'f'),@(6100,'s')) 9000 $seed 1
$x=Sim @(@(5000,'f'),@(6000,'s')) 9000; Check 'R7 a release is not called a pair of lone moves' ($x.pr -eq 0 -and $x.l -eq 0) ("pairs $($x.pr) lone $($x.l)")
$x=Sim @(@(5000,'s'),@(7000,'s')) 9000; Check 'R8 a pair is counted, with its gap, for the log' ($x.pr -eq 1 -and [Math]::Abs($x.ps-2.0) -lt 0.01) ("pairs $($x.pr) gap $($x.ps)")
$x=Sim ((Key 5000)+@(,@(13000,'s'))) 15000; Check 'R8b a person carrying on is not a pair' ($x.pr -eq 0) ("pairs $($x.pr)")
$x=Sim @(@(5000,'s'),@(13000,'s'),@(21000,'s')) 23000; Check 'R8c nor is the third of a run: one pair, then a person going on' ($x.pr -eq 1 -and $x.l -eq 1) ("pairs $($x.pr) lone $($x.l)")
$x=Sim (@(,@(5000,'s'))+(Key 7000)) 9000; Check 'R8d a lone move, then a real key: a person, and not called a pair' ($x.at -eq 7110 -and $x.pr -eq 0 -and $x.l -eq 1) ("at $($x.at) pairs $($x.pr) lone $($x.l)")
$T::MockReset(); LookAt 100 50 1; LookAt 500 500 1; LookAt 1100 500 1; Check 'R8e a lone move at tick 500, with no window move yet, has no window move to be the release of' ($T::Lones() -eq 1) ("lone $($T::Lones())")
$x=Sim @(@(5000,'f'),@(10000,'f'),@(15000,'f'),@(15500,'s')) 18000; Check 'R8f a window move that is a person by the burst rule still has its release: a person, at the release' ($x.at -eq 15500 -and $x.b -eq 1 -and $x.l -eq 0) ("at $($x.at) bursts $($x.b) lone $($x.l)")
$x=Sim @(@(5000,'s'),@(14000,'s')) 17000 1000000 0 13900 16000; Check 'R9 the looks stop as the second move comes: it is timed by the input time, so still a pair' ($x.at -eq 14000 -and $x.pr -eq 1) ("at $($x.at) pairs $($x.pr)")
$x=Sim (Key 5000) 9000 1000000 0 4950 5950; Check 'R10 a known limit: the looks stop for a second over a whole key press, so it is one lone move' ($x.at -eq $seed -and $x.l -eq 1) ("at $($x.at) lone $($x.l)")
$x=Sim @(@(5000,'s'),@(7000,'s'),@(20000,'f'),@(36000,'f')) 38000; Check 'R11 the second of a pair is not counted towards the third, and starts no hold' ($x.at -eq 7000 -and $x.n -eq 2 -and $x.b -eq 0) ("at $($x.at) window $($x.n) bursts $($x.b)")
$x=Sim @(@(5000,'s'),@(7000,'s')) 9000; Check 'R11b the passive clock stays at the first move, since the second is a person' ([Math]::Abs($x.fo-4.0) -lt 0.01) ("fo $($x.fo)")
CS 'R12 a move 4 s after a burst: a person, carrying on' @(@(16000,'s'),@(31000,'s'),@(46000,'s'),@(50000,'s')) 52000 50000 0
CS 'L16b a run of three, 8 s apart: a person at the last' @(@(5000,'s'),@(13000,'s'),@(21000,'s')) 23000 21000 0
CS 'L13 lone, window 11.1 s later, lone: a third move not counted within 30 s, a person' @(@(5000,'s'),@(16100,'f'),@(20000,'s')) 23000 20000 1
$x=Sim @(@(5000,'s'),@(16100,'f'),@(20000,'s')) 23000; Check 'L13b the burst line is due' ($x.b -eq 1) ("bursts $($x.b)")
CS 'L14 window, lone, window inside 30 s: the third is a person' @(@(5000,'f'),@(12000,'s'),@(20000,'f')) 23000 20000 1
CS 'L15 lone, then a window move and nothing else, over 11 s: nobody' @(@(5000,'s'),@(16000,'f')) 19000 $seed 1
CS 'L16 a run of lone moves 8 s apart: a person from the second to the last' @(@(5000,'s'),@(13000,'s'),@(21000,'s'),@(29000,'s')) 31000 29000 0
CS 'L17 a lone move 8 s after a real key: a person, carrying on' ((Key 5000)+@(,@(13000,'s'))) 15000 13000 0
CS 'L18 a lone move 11 s after a real key: the key stands, the move is not a person' ((Key 5000)+@(,@(16110,'s'))) 18000 5110 0
CS 'L19 a lone move long after a real key does not shorten what the key holds' ((Key 1000)+@(,@(30000,'s'))) 33000 1110 0
$st4=@(,@(5000,'s')); for($q=5200;$q -le 7000;$q+=50){ $st4+=,@($q,'k') }; $x=Sim $st4 7000; Check 'L20 one mouse report, then the mouse goes on 200 ms later: a person inside a second' ((7000-$x.at) -le 700 -and $x.at -ge 5200) ("person at $($x.at)")
foreach($ph in 0,37,99){ $x=Sim (Key 5000) 5800 1000000 $ph; Check ("L21 A REAL PERSON IS SEEN WITHIN A SECOND: a key, read 800 ms after the press (poll phase $ph)") ($x.at -eq 5110) ("person at $($x.at)"); $x=Sim @(@(5000,'s'),@(5500,'s')) 6300 1000000 $ph; Check ("L21b two moves half a second apart, read 800 ms after the second (poll phase $ph)") ($x.at -eq 5500) ("person at $($x.at)") }
$x=Sim @(@(4500,'s'),@(6000,'s')) 8000 $bw; Check 'L22 the tick count wraps between two lone moves: a person' ($x.at -eq 6000) ("at $($x.at)")
$x=Sim @(@(4500,'s'),@(15100,'s')) 17000 $bw; Check 'L22b the tick count wraps and they are over 10 s apart: nobody' ($x.at -eq $seed -and $x.l -eq 2) ("at $($x.at) lone $($x.l)")
function LoneAt([long]$at,[int]$f=1){ LookAt $at $at $f; LookAt ($at+600) $at $f }
function LoneRun([int]$cnt,[long]$gap){ $T::MockReset(); LookAt 1000 900 1; $last=[long]1000; for($q=1;$q -le $cnt;$q++){ $last=1000+$q*$gap; LoneAt $last }; $T::FakeNow=U ($last+700); $T::FakeSt=U $last }
$T::MockReset(); LookAt 1000 900 1; LoneAt 2000; LoneAt 148000; LoneAt 1186000; $T::FakeNow=U 1186700; $T::FakeSt=U 1186000; $a=$T::PersonIdleSec(); Check 'L23 TODAY''S MOVES REPLAYED, 146 s and 1038 s apart: nobody, three lone moves' ($a -gt 1000 -and $T::Lones() -eq 3 -and $T::Bursts() -eq 0) ("person $a s ago, lone $($T::Lones()), bursts $($T::Bursts())")
LoneRun 3 15000; Check 'L24 every 15 s: the third is a person' ($T::Bursts() -eq 1 -and $T::Lones() -eq 2) ("bursts $($T::Bursts()) lone $($T::Lones())")
LoneRun 5 16000; Check 'L25 every 16 s, five: none is a person' ($T::Bursts() -eq 0 -and $T::Lones() -eq 5) ("bursts $($T::Bursts()) lone $($T::Lones())")
LoneRun 6 16000; Check 'L25b the sixth inside 10 minutes is a person' ($T::Bursts() -eq 1 -and $T::Lones() -eq 5) ("bursts $($T::Bursts()) lone $($T::Lones())")
LoneRun 6 119000; Check 'L26 every 119 s: the sixth is a person' ($T::Bursts() -eq 1) ("bursts $($T::Bursts())")
LoneRun 6 120000; Check 'L26b exactly every 2 minutes: the sixth is a person' ($T::Bursts() -eq 1) ("bursts $($T::Bursts())")
LoneRun 6 120100; Check 'L26c every 2 minutes and a little: never, the cliff for the ruling' ($T::Bursts() -eq 0 -and $T::Lones() -eq 6) ("bursts $($T::Bursts()) lone $($T::Lones())")
$T::MockReset(); LookAt 1000 900 1; $fgN=1; foreach($q in 1..6){ $tq=1000+$q*40000; if($q % 2){ $fgN++; LookAt $tq $tq $fgN }else{ LoneAt $tq $fgN } }; Check 'L26d window and lone moves share the sixth: three of each at 40 s, the last is a person' ($T::Bursts() -eq 1 -and $T::Count() -eq 3 -and $T::Lones() -eq 2) ("bursts $($T::Bursts()) window $($T::Count()) lone $($T::Lones())")
LoneRun 10 125000; Check 'L27 every 125 s: none is a person, a limit for the ruling' ($T::Bursts() -eq 0 -and $T::Lones() -eq 10) ("bursts $($T::Bursts()) lone $($T::Lones())")
$T::MockReset(); LookAt 1000 900 1; LoneAt 5000; $d26=[long]26*86400000; LoneAt ($d26+5000); Check 'L28 a lone move 26 days after the last is not a second move' ($T::Lones() -eq 2) ("lone $($T::Lones())")
$T::MockReset(); LookAt 1000 900 1; LoneAt 5000; $T::FakeNow=U 9000; $T::FakeSt=U 9000; $a=$T::PersonIdleSec(); Check 'L29 the thread stopped after a lone move and the input time moved since: the raw time, so it counts' ([Math]::Abs($a) -lt 0.01) ("$a")
$T::MockReset(); LookAt 1000 900 1; LoneAt 5000; $T::FakeNow=U 9000; $T::FakeSt=U 5000; $a=$T::PersonIdleSec(); Check 'L29b the thread stopped after a lone move and nothing has moved: the lone move stays judged' ($a -gt 8) ("$a")
# a quick tap: how often both its edges fall between two looks, at poll gaps of 100 ms, 108 ms (the median measured for Sleep(100) here) and 134 ms (the longest measured). It should be what the arithmetic says
$tapBad=@(); $tapTable=@()
foreach($gp in 100,108,134){ foreach($hd in 20,50,90,110,140){ $miss=0; $tried=0; for($ph=0;$ph -lt $gp;$ph+=2){ $tried++; $x=Sim (Key 1000 $hd) 2000 1000000 $ph -1 -1 $gp; if($x.l -eq 1 -and $x.at -eq $seed){ $miss++ } }; $share=[double]$miss/$tried; $want=[Math]::Max([double]0,[double]($gp-$hd)/$gp); $tapTable+=("$gp/$hd="+[int]($share*100)+'%'); if([Math]::Abs($share-$want) -gt 0.04){ $tapBad+="$gp/$hd" } } }
Check 'L30 a quick tap is missed as often as both its edges fall between two looks, and never once it outlasts the gap (poll ms/hold ms=missed)' ($tapBad.Count -eq 0) ($tapTable -join ' ')
$rnd=New-Object Random 20261102
$bad=0; $runs=40
for($q=0;$q -lt $runs;$q++){
  $ev=@(); $cur=[long]2000; $cnt=$rnd.Next(2,9)
  for($j=0;$j -lt $cnt;$j++){ $cur+=$rnd.Next(1000,6000); $pick2=$rnd.Next(3); if($pick2 -eq 0){ $ev+=,@($cur,'f') }elseif($pick2 -eq 1){ $ev+=(Key $cur) }else{ foreach($z in 0,50,100,150,200){ $ev+=,@(($cur+$z),'k') } } }
  $ph=$rnd.Next(0,100); $fin=$cur+2000
  $a1=Sim $ev $fin 1000000 $ph; $saveT=$T; $T=$TM; $a2=Sim $ev $fin 1000000 $ph; $T=$saveT
  if($a1.at -ne $a2.at -or $a1.n -ne $a2.n -or $a1.b -ne $a2.b -or [Math]::Abs($a1.fo-$a2.fo) -gt 0.001 -or $a1.l -ne 0){ $bad++ }
}
Check ("r1 with no lone move the new C# answers exactly as master's, over $runs random timelines of real keys, a moving mouse and window moves") ($bad -eq 0) ("different $bad")
$bad=0; $runs=40
for($q=0;$q -lt $runs;$q++){ $g=$rnd.Next(150,10001); $f0=2000+$rnd.Next(2000); $x=Sim @(@($f0,'s'),@(($f0+$g),'s')) ($f0+$g+700) 1000000 $rnd.Next(0,100); if($x.at -ne ($f0+$g)){ $bad++ } }
Check ("r2 any two moves within 10 s are a person inside 700 ms of the second, over $runs random pairs and poll phases") ($bad -eq 0) ("missed $bad")
$bad=0; $runs=30
for($q=0;$q -lt $runs;$q++){ $T::MockReset(); LookAt 1000 900 1; $cur=[long]2000; $cnt=$rnd.Next(4,12); for($j=0;$j -lt $cnt;$j++){ $cur+=$rnd.Next(125000,400000); LoneAt $cur }; $T::FakeNow=U ($cur+700); $T::FakeSt=U $cur; if([Math]::Abs(($T::PersonIdleSec())-(($cur+700-900)/1000)) -gt 0.01 -or $T::Lones() -ne $cnt -or $T::Bursts() -ne 0){ $bad++ } }
Check ("r3 lone moves at least 125 s apart are never a person, over $runs random runs") ($bad -eq 0) ("off $bad")

# ---- part 3: the runner's own functions with stand-ins for the C#
$names='AwaySec','SoundWho','GpuGame','Save-Hold','Load-Hold','FocusHold','Arrived','Epoch','Short'   # Arrived is master's
foreach($n in $names){ if(-not $fn[$n]){ throw ('missing '+$n) }; $code=$fn[$n].Replace('[PillagersIdle.Input]::','$MIn.').Replace('[PillagersSpare.Presence]::','$MPre.').Replace('[PillagersSpare.Sound]::','$MSnd.').Replace('[PillagersSpare.FocusWatch]::','$MFw.'); if($code -match 'Pillagers(Idle|Spare)\.|Stop-Process|Start-Process|\.Kill\(|WriteAllText|AppendAllText'){ throw ('mock not safe: '+$n) }; Invoke-Expression $code }
Invoke-Expression ($fm['AwaySec'].Replace('[PillagersIdle.Input]::','$MIn.').Replace('[PillagersSpare.Presence]::','$MPre.').Replace('[PillagersSpare.Sound]::','$MSnd.').Replace('[PillagersSpare.FocusWatch]::','$MFw.').Replace('function AwaySec(','function AwaySecM('))
$init=@(Get-Content -LiteralPath $File | Where-Object { $_ -like '$script:padT=*' -or $_ -like '$script:conT=*' -or $_ -like '$script:gpuOn=*' -or $_ -like '$PassCapSec=*' -or $_ -like '$script:capSaid=*' })
if($init.Count -ne 5){ throw 'the start values were not found' }
$Idle=$false; foreach($l in $init){ Invoke-Expression $l }
$script:Log=@(); function Say([string]$s){ $script:Log+=$s }; function PadNote(){ $script:padNotes++ }
$script:St=@{}; function GetS([string]$k){ [string]$script:St[$k] }; function PutS([string]$k,[string]$v){ $script:St[$k]=$v }
$MIn=[pscustomobject]@{}; $MIn | Add-Member ScriptMethod IdleSec { $script:rawCalls++; $script:kbIdle }; $MIn | Add-Member ScriptMethod PadInUse { $script:padIn }
$MPre=[pscustomobject]@{}
$MPre | Add-Member ScriptMethod PadMoved { $script:presCalls++; $script:padMv }
$MPre | Add-Member ScriptMethod OtherAtScreen { param($s) $script:presCalls++; $script:other }
$MPre | Add-Member ScriptMethod MineAtScreen { param($s) $script:presCalls++; $script:mine }
$MPre | Add-Member ScriptMethod Quns { $script:presCalls++; $script:quns }
$MSnd=[pscustomobject]@{}; $MSnd | Add-Member ScriptMethod SoundPids { param($m) $script:snd }
$MFw=[pscustomobject]@{}
$MFw | Add-Member ScriptMethod PersonIdleSec { $script:fwCalls++; if($script:fwThrow){ throw 'no watch' }; if($script:fwReal){ return $script:T::PersonIdleSec() }; $script:fwPerson }
$MFw | Add-Member ScriptMethod FocusOnlyAgo { if($script:fwThrow){ throw 'no watch' }; if($script:fwReal){ return $script:T::FocusOnlyAgo() }; $script:fwFo }
$MFw | Add-Member ScriptMethod Count { if($script:fwReal){ return $script:T::Count() }; [uint32]$script:fwN }
$MFw | Add-Member ScriptMethod Bursts { if($script:fwReal){ return $script:T::Bursts() }; [uint32]$script:fwB }
$MFw | Add-Member ScriptMethod Lones { if($script:fwReal){ return $script:T::Lones() }; [uint32]$script:fwL }
$MFw | Add-Member ScriptMethod Pairs { if($script:fwReal){ return $script:T::Pairs() }; [uint32]$script:fwPr }
$MFw | Add-Member ScriptMethod PairSec { if($script:fwReal){ return $script:T::PairSec() }; [double]$script:fwPs }
$MFw | Add-Member ScriptMethod LastPid { if($script:fwReal){ return $script:T::LastPid() }; [uint32]$script:fwPid }
$names2=@{ 6000='FortniteClient-Win64-Shipping'; 8100='chrome'; 8300='vlc'; 4242='SomeUpdater' }
$cims=@{ 8100=[pscustomobject]@{ Name='chrome.exe'; CommandLine='chrome.exe --type=utility --user-data-dir=C:\t\pillagers-cdp9331' }; 8300=[pscustomobject]@{ Name='vlc.exe'; CommandLine='vlc.exe film.mkv' } }
$script:gpu=@{}; $script:Reads=0
function Get-Counter { $script:Reads++; $s=@(); foreach($k in $script:gpu.Keys){ $s+=[pscustomobject]@{ Status=0; InstanceName=('pid_'+$k+'_luid_0x0_phys_0_eng_0_engtype_3D'); CookedValue=[double]$script:gpu[$k] } }; return [pscustomobject]@{ CounterSamples=$s } }
function Get-Process { param([int]$Id,[string]$ErrorAction) if($names2.ContainsKey($Id)){ return [pscustomobject]@{ ProcessName=$names2[$Id] } }; throw 'no such process' }
function Get-CimInstance { param([string]$ClassName,[string]$Filter,[string]$ErrorAction) $i=[int]($Filter -replace '\D',''); return $cims[$i] }
$MySid=[uint32]3; $big=80000
function Reset([bool]$idleMode=$false){
  Set-Variable -Name Idle -Value $idleMode -Scope Script
  foreach($l in $init){ Invoke-Expression $l }
  $script:noFocus=$false; $script:focusN=[uint32]0; $script:burstN=[uint32]0; $script:holdN=[uint32]0; $script:loneN=[uint32]0; $script:pairN=[uint32]0; $script:fwL=0; $script:fwPr=0; $script:fwPs=0.0; $script:fwReal=$false; $script:noIn=$false; $script:noPres=$false; $script:noSnd=$false; $script:sndSaid=$false; $script:sndCache=@{}
  $script:kbIdle=5000.0; $script:padIn=$false; $script:padMv=$false; $script:other=$false; $script:mine=$true; $script:quns=5; $script:snd=''; $script:gpu=@{}
  $script:fwPerson=5000.0; $script:fwFo=[double]1e9; $script:fwN=0; $script:fwB=0; $script:fwPid=0; $script:fwThrow=$false; $script:fwCalls=0; $script:presCalls=0; $script:rawCalls=0; $script:Reads=0; $script:padNotes=0
  $script:holdE=[long]0; $script:holdH=[long]0; $script:gpuChk=(Get-Date).AddDays(-1); $script:Log=@(); $script:St=@{}
}
function A(){ $v=AwaySec; return [pscustomobject]@{ a=[double]$v; w=$script:awayWhy } }
function FocusOnly([double]$ago=5.0,[double]$person=99999.0){ $script:kbIdle=$ago; $script:fwPerson=$person; $script:fwFo=$ago; $script:fwN=1; $script:fwPid=4242 }
function LoneOnly([double]$ago=5.0,[double]$person=99999.0){ $script:kbIdle=$ago; $script:fwPerson=$person; $script:fwFo=$ago; $script:fwL=1 }
Reset; FocusOnly; $x=A; Check 'a1 a program takes the front, nobody here: no stop, no pause' ($x.a -gt $big) ("$($x.a) $($x.w)")
$nl=@($script:Log | Where-Object { $_ -like 'the input time moved as the window in front changed to SomeUpdater*' }).Count; Check 'a1b it says so once, naming the program' ($nl -eq 1) ($script:Log -join ' | ')
[void](A); $nl=@($script:Log | Where-Object { $_ -like 'the input time moved*' }).Count; Check 'a1c not again at the next look' ($nl -eq 1) ("lines $nl")
$script:fwN=2; [void](A); $nl=@($script:Log | Where-Object { $_ -like 'the input time moved*' }).Count; Check 'a1d a new move is said too' ($nl -eq 2) ("lines $nl")
Reset; FocusOnly; $script:fwPid=0; [void](A); Check 'a1e no process: says a program' ($script:Log -contains 'the input time moved as the window in front changed to a program: not counted as someone at the PC') ($script:Log -join ' | ')
Reset; FocusOnly; $script:fwPid=7777; [void](A); Check 'a1f a process already gone: says a program' ($script:Log -contains 'the input time moved as the window in front changed to a program: not counted as someone at the PC') ($script:Log -join ' | ')
Reset; $script:fwB=1; $script:kbIdle=1; $script:fwPerson=1; [void](A); $nb=@($script:Log | Where-Object { $_ -like 'the input time keeps moving*' }).Count; [void](A); $nb2=@($script:Log | Where-Object { $_ -like 'the input time keeps moving*' }).Count; Check 'a1g a burst is said once, so it can be told from a real key' ($nb -eq 1 -and $nb2 -eq 1) ("$nb $nb2")
Reset; $script:kbIdle=5; $script:fwPerson=5; $x=A; Check 'a2 a real key or mouse 5 s ago: someone, stops at once' ($x.a -lt 30 -and $x.w -eq 'keyboard or mouse') ("$($x.a) $($x.w)")
Reset; $script:kbIdle=800; $script:fwPerson=800; $x=A; Check 'a2b 800 s ago: the 15 minutes still hold the tests' ($x.a -lt 900 -and $x.w -eq 'keyboard or mouse') ("$($x.a) $($x.w)")
Reset; $script:kbIdle=2; $script:fwPerson=800; $script:fwFo=2; $script:fwN=1; $x=A; Check 'a2c a window move does not shorten what a real key still holds' ([Math]::Abs($x.a-800) -lt 2) ("$($x.a) $($x.w)")
foreach($q in 2,3,4){ Reset; FocusOnly; $script:quns=$q; $x=A; Check ('g1 A GAME THAT CAME TO THE FRONT with no key: full screen state '+$q+' pauses at once') ($x.a -lt 2 -and $x.w -eq 'a full-screen program') ("$($x.a) $($x.w)") }
Reset; FocusOnly; $script:snd='8300'; $x=A; Check 'g2 with no key: sound from a program pauses at once' ($x.a -lt 2 -and $x.w -like 'sound from vlc.exe*') ("$($x.a) $($x.w)")
Reset; FocusOnly; $script:gpu=@{6000=40}; [void](A); $a1=FocusHold; $f1=$script:gpuOn; $script:fwFo=36; $script:gpuChk=(Get-Date).AddSeconds(-31); $a2=FocusHold; $x=A; Check 'g3 with no key: a game on the graphics card, nothing starts from the first look and it pauses at the second read' ($a1 -and -not $f1 -and $a2 -and $x.a -lt 2 -and $x.w -like 'a game on the graphics card: Fortnite*') ("arrived $a1 $a2 first=$f1 $($x.a) $($x.w)")
Reset; FocusOnly; $script:snd='8100'; $script:gpu=@{8100=40}; $x=A; $script:gpuChk=(Get-Date).AddSeconds(-31); $x=A; Check 'g3b the runner''s own test browser taking the front is not a game' ($x.a -gt $big) ("$($x.a) $($x.w)")
Reset; FocusOnly 7100; $script:quns=3; $x=A; Check 'g4 118 minutes after a window move: full screen still counts' ($x.a -lt 2) ("$($x.a) $($x.w)")
Reset; FocusOnly 7300; $script:quns=3; $x=A; Check 'g5 122 minutes after it, no key since: the 2-hour cap, as for any input on master' ($x.a -gt $big) ("$($x.a) $($x.w)")
Reset; FocusOnly 100 99999; $script:quns=3; $x=A; Check 'g5b a window move restarts the passive 2 hours when the person is older than that' ($x.a -lt 2) ("$($x.a) $($x.w)")
Reset; $script:padMv=$true; $script:kbIdle=99999; $script:fwPerson=99999; $x=A; Check 'g6 a pad that changed still counts' ($x.a -lt 2 -and $x.w -eq 'game pad') ("$($x.a) $($x.w)")
Reset; $script:other=$true; $script:kbIdle=99999; $script:fwPerson=99999; $x=A; Check 'g7 another account at the screen still counts' ($x.a -lt 2 -and $x.w -eq 'another account at the screen') ("$($x.a) $($x.w)")
Reset; FocusOnly; $script:mine=$false; $script:quns=3; $x=A; Check 'g8 this account not at the screen: the passive signs do not count, as on master' ($x.a -gt $big) ("$($x.a) $($x.w)")
Reset; $script:quns=3; $script:kbIdle=600; $script:fwPerson=600; $x=A; Check 'g9 a real key 10 minutes ago with a full-screen game: pauses, as on master' ($x.a -lt 2) ("$($x.a) $($x.w)")
Reset; $script:quns=3; $script:kbIdle=30; $script:fwPerson=30; $x=A; Check 'g10 inside 60 s of a real key the slower looks wait, as on master' ($x.w -eq 'keyboard or mouse') ("$($x.a) $($x.w)")
Reset; FocusOnly 5; $h1=FocusHold; $a1=Arrived
Check 'h1 a window move holds new starts but nobody has arrived, so the round goes on' ($h1 -and -not $a1) ("$h1 $a1")
$nh=@($script:Log | Where-Object { $_ -like 'the input time moved with nobody seen: no new test work*' }).Count; [void](FocusHold); $nh2=@($script:Log | Where-Object { $_ -like 'the input time moved with nobody seen: no new test work*' }).Count; $script:fwN=2; [void](FocusHold); $nh3=@($script:Log | Where-Object { $_ -like 'the input time moved with nobody seen: no new test work*' }).Count; Check 'h1i it says a start is held, once per move' ($nh -eq 1 -and $nh2 -eq 1 -and $nh3 -eq 2) ("$nh $nh2 $nh3")
Reset; FocusOnly 64; $h1=FocusHold; Check 'h1b for 65 s' ($h1) ("$h1")
Reset; FocusOnly 66; $h1=FocusHold; $a1=Arrived; Check 'h1c not after 65 s' (-not $h1 -and -not $a1) ("$h1 $a1")
Reset; FocusOnly 5; $x=A; Check 'h1d a hold is not a stop: what is running goes on' ($x.a -ge 30) ("$($x.a)")
Reset; $script:fwPerson=10; $script:kbIdle=10; $a2=Arrived; Check 'h1e a real key has arrived, with its own reason' ($a2 -and $script:awayWhy -eq 'keyboard or mouse') ("$a2 $script:awayWhy")
Reset; $script:noFocus=$true; $script:fwFo=5; Check 'h1f the watch did not load: no hold' (-not (FocusHold)) ''
Reset; Remove-Variable -Name noFocus -Scope Script -ErrorAction SilentlyContinue; Check 'h1g the flag never set (no presence check loaded): no hold and no error' (-not (FocusHold)) ''
Reset; $script:fwThrow=$true; Check 'h1h the watch throws: no hold' (-not (FocusHold)) ''
Reset; FocusOnly 5 3000; $script:St=@{}; [void](A); $e=Epoch; Save-Hold 120; Check 'h2 a restart carries the person''s time, not the window move' ([Math]::Abs(([long]$script:St['human_t'])-($e-3000)) -le 2) ("human_t $($script:St['human_t']) want about $($e-3000)")
$saved=$script:St.Clone(); Reset; $script:St=$saved; Load-Hold; $script:kbIdle=99999; $script:fwPerson=99999; $x=A; Check 'h2b the new copy goes on from that person''s time' ([Math]::Abs($script:humanAgo-3000) -le 2) ("$script:humanAgo")
Reset; FocusOnly 5 3000; [void](A); Check 'h3 humanAgo is the person''s time' ([Math]::Abs($script:humanAgo-3000) -lt 2) ("$script:humanAgo")
Reset; $script:noFocus=$true; $script:kbIdle=5; $script:fwPerson=99999; $x=A; Check 's1 the watch did not load: every move counts, as on master' ($x.a -lt 30 -and $script:fwCalls -eq 0) ("$($x.a) calls $script:fwCalls")
Reset; FocusOnly; $script:fwThrow=$true; $x=A; Check 's2 the watch throws: every move counts, as on master' ([Math]::Abs($x.a-5) -lt 1) ("$($x.a) $($x.w)")
Reset; $script:noIn=$true; $x=A; Check 's3 no presence check loaded: nobody, and the watch is not asked' ($x.a -ge 1e9 -and $script:fwCalls -eq 0) ("$($x.a) calls $script:fwCalls")
# the lone move in AwaySec and FocusHold
$loneLine='the input time moved once, alone, with no change of the window in front within half a second: not counted as someone at the PC unless it moves again within 10 s'
Reset; LoneOnly; $x=A; Check 'al1 a lone move, nobody here: no stop, no pause' ($x.a -gt $big) ("$($x.a) $($x.w)")
$nl=@($script:Log | Where-Object { $_ -ceq $loneLine }).Count; Check 'al1b it says so once, and names no program' ($nl -eq 1) ($script:Log -join ' | ')
[void](A); $nl=@($script:Log | Where-Object { $_ -ceq $loneLine }).Count; Check 'al1c not again at the next look' ($nl -eq 1) ("lines $nl")
$script:fwL=2; [void](A); $nl=@($script:Log | Where-Object { $_ -ceq $loneLine }).Count; Check 'al1d a new one is said too' ($nl -eq 2) ("lines $nl")
Reset; LoneOnly; [void](A); Check 'al1e it is not said as a window move' (@($script:Log | Where-Object { $_ -like 'the input time moved as the window*' }).Count -eq 0) ($script:Log -join ' | ')
Reset; $script:fwB=1; LoneOnly 1 1; [void](A); Check 'al1f the burst line says keeps moving, not a window, since lone moves count towards it' (@($script:Log | Where-Object { $_ -ceq 'the input time keeps moving with nobody seen (3 times in 30 s or 6 in 10 minutes): counted as someone at the PC' }).Count -eq 1) ($script:Log -join ' | ')
foreach($q in 2,3,4){ Reset; LoneOnly; $script:quns=$q; $x=A; Check ('al2 A GAME AFTER A LONE MOVE: full screen state '+$q+' pauses at once') ($x.a -lt 2 -and $x.w -eq 'a full-screen program') ("$($x.a) $($x.w)") }
Reset; LoneOnly; $script:snd='8300'; $x=A; Check 'al3 after a lone move: sound from a program pauses at once' ($x.a -lt 2 -and $x.w -like 'sound from vlc.exe*') ("$($x.a) $($x.w)")
Reset; LoneOnly; $script:gpu=@{6000=40}; [void](A); $a1=FocusHold; $script:fwFo=36; $script:gpuChk=(Get-Date).AddSeconds(-31); $a2=FocusHold; $x=A; Check 'al4 after a lone move: a game on the graphics card, nothing starts from the first look and it pauses at the second read' ($a1 -and $a2 -and $x.a -lt 2 -and $x.w -like 'a game on the graphics card: Fortnite*') ("$a1 $a2 $($x.a) $($x.w)")
Reset; LoneOnly 7100; $script:quns=3; $x=A; Check 'al5 118 minutes after a lone move: full screen still counts' ($x.a -lt 2) ("$($x.a) $($x.w)")
Reset; LoneOnly 7300; $script:quns=3; $x=A; Check 'al5b 122 minutes after it: the 2-hour cap' ($x.a -gt $big) ("$($x.a) $($x.w)")
Reset; LoneOnly; $script:padMv=$true; $x=A; Check 'al6 a pad that changed still counts, at once' ($x.a -lt 2 -and $x.w -eq 'game pad') ("$($x.a) $($x.w)")
Reset; LoneOnly; $script:other=$true; $x=A; Check 'al6b another account at the screen still counts, at once' ($x.a -lt 2 -and $x.w -eq 'another account at the screen') ("$($x.a) $($x.w)")
Reset; LoneOnly; $h1=FocusHold; $a1=Arrived; Check 'al7 a lone move holds new starts but nobody has arrived, so what is running goes on' ($h1 -and -not $a1) ("$h1 $a1")
$hl='the input time moved with nobody seen: no new test work starts for at least 65 s, what is running goes on'
$nh=@($script:Log | Where-Object { $_ -ceq $hl }).Count; [void](FocusHold); $nh2=@($script:Log | Where-Object { $_ -ceq $hl }).Count; $script:fwL=2; [void](FocusHold); $nh3=@($script:Log | Where-Object { $_ -ceq $hl }).Count; $script:fwN=1; [void](FocusHold); $nh4=@($script:Log | Where-Object { $_ -ceq $hl }).Count; Check 'al7b it says a start is held, once per move of either kind' ($nh -eq 1 -and $nh2 -eq 1 -and $nh3 -eq 2 -and $nh4 -eq 3) ("$nh $nh2 $nh3 $nh4")
Reset; $script:fwPr=1; $script:fwPs=4.04; $script:fwPerson=1; $script:kbIdle=1; [void](A); [void](A); $np=@($script:Log | Where-Object { $_ -ceq 'the input time moved again 4 s after a lone move (pair 1 since this copy started): counted as someone at the PC' }).Count; Check 'al7e a pair is said once, with its gap, so a stop can be told from a real key' ($np -eq 1) ($script:Log -join ' | ')
Reset; LoneOnly 64; Check 'al7c for 65 s' (FocusHold) ''
Reset; LoneOnly 66; Check 'al7d not after 65 s' (-not (FocusHold)) ''
Reset; LoneOnly 5 3000; [void](A); Check 'al8 humanAgo is the person''s time, so a restart carries that and not the lone move' ([Math]::Abs($script:humanAgo-3000) -lt 2) ("$script:humanAgo")
Reset $true; $script:noFocus=$false; $script:kbIdle=1; $script:fwPerson=99999; $script:fwL=1; $script:fwFo=1; $v=[double](AwaySec); Check 'al9 IDLE MODE: a lone move counts as he is here, as on master, and the watch is not asked' ($v -lt 2 -and $script:fwCalls -eq 0) ("$v calls $script:fwCalls")
Reset $true; $script:noFocus=$false; $script:fwL=1; $script:fwFo=1; Check 'al9b IDLE MODE: no hold' (-not (FocusHold)) ''
# the same, with the runner's real C# on the fake clock behind AwaySec, Arrived and FocusHold: the raw input time says someone is here, so an answer that fell back to it would show
function Wired([object[]]$ev,[long]$end,[long]$seedAgo=600000){ [void](Sim $ev $end 1000000 0 -1 -1 100 $seedAgo); Reset; $script:fwReal=$true; $script:kbIdle=0 }
Wired @(,@(5000,'s')) 9000; $a1=Arrived; $h1=FocusHold; $x=A; Check 'e1 ALL WIRED, one lone move: nobody has arrived, new work is held, and the log says so' (-not $a1 -and $h1 -and $x.a -gt 600 -and ($script:Log -ccontains $loneLine)) ("$a1 $h1 $($x.a) $($script:Log -join ' | ')")
Wired (Key 5000) 5800; $a1=Arrived; $x=A; Check 'e2 ALL WIRED, A REAL KEY: arrived, read 800 ms after the press, for keyboard or mouse' ($a1 -and $x.a -lt 1 -and $x.w -eq 'keyboard or mouse') ("$a1 $($x.a) $($x.w)")
Wired @(@(5000,'s'),@(9000,'s')) 9700; $a1=Arrived; $x=A; Check 'e3 ALL WIRED, a second move 4 s after the first: arrived 700 ms after it' ($a1 -and $x.a -lt 1 -and $x.w -eq 'keyboard or mouse') ("$a1 $($x.a) $($x.w)")
Wired @(,@(5000,'s')) 9000 10800000; $script:quns=3; $x=A; Check 'e4 ALL WIRED, nobody for 3 hours, then a full-screen game after one lone move: the lone move restarts the passive 2 hours, so it pauses for the game' ($x.a -lt 2 -and $x.w -eq 'a full-screen program') ("$($x.a) $($x.w)")
Wired @() 9000 10800000; $script:quns=3; $x=A; Check 'e4b the same with no lone move: past the 2 hours, so no pause, which is what e4 turns on' ($x.a -gt 7200) ("$($x.a) $($x.w)")
Wired @(,@(5000,'s')) 9000 10800000; $script:padMv=$true; $x=A; Check 'e5 ALL WIRED, a pad after one lone move: pauses for the pad' ($x.a -lt 2 -and $x.w -eq 'game pad') ("$($x.a) $($x.w)")
Wired @(@(5000,'s'),@(16000,'f'),@(20000,'s')) 23000; $a1=Arrived; Check 'e7 ALL WIRED, a third move not counted within 30 s: arrived, and the log says why' ($a1 -and ($script:Log -ccontains 'the input time keeps moving with nobody seen (3 times in 30 s or 6 in 10 minutes): counted as someone at the PC')) ("$a1 $($script:Log -join ' | ')")
Wired @(@(5000,'s'),@(9000,'s')) 9700; $a1=Arrived; Check 'e8 ALL WIRED, a pair: the log gives its gap' ($a1 -and ($script:Log -ccontains 'the input time moved again 4 s after a lone move (pair 1 since this copy started): counted as someone at the PC')) ("$a1 $($script:Log -join ' | ')")
Wired @(@(5000,'f'),@(5150,'s')) 5900; $a1=Arrived; $x=A; Check 'e9 ALL WIRED, a click on a background window with the pointer still: arrived, for keyboard or mouse' ($a1 -and $x.w -eq 'keyboard or mouse') ("$a1 $($x.w)")
Wired @(,@(5000,'f')) 9000; $a1=Arrived; $h1=FocusHold; Check 'e6 ALL WIRED, a window move: as it landed, nobody has arrived and new work is held' (-not $a1 -and $h1) ("$a1 $h1")

# ---- part 4: master's AwaySec against the new one
function Same([string]$name,[scriptblock]$setup,[bool]$idle=$false){
  Reset $idle; & $setup; $script:fwPerson=$script:kbIdle; $v1=[double](AwaySec); $w1=$script:awayWhy; $h1=$script:humanAgo; $l1=$script:Log -join '|'; $c1=$script:fwCalls
  Reset $idle; & $setup; $script:fwPerson=$script:kbIdle; $v2=[double](AwaySecM); $w2=$script:awayWhy; $h2=$script:humanAgo; $l2=$script:Log -join '|'
  $ok=([Math]::Abs($v1-$v2) -lt 1 -and $w1 -ceq $w2 -and ([Math]::Abs($h1-$h2) -lt 1) -and $l1 -ceq $l2)
  if($idle -and $c1 -ne 0){ $ok=$false }
  return $ok
}
$n=0; $bad=@()
foreach($k in 0,5,29,30,59,60,600,899,900,7100,7300){ foreach($pm2 in $false,$true){ foreach($ot in $false,$true){ foreach($mi in $true,$false){ foreach($q in 5,3){ foreach($sn in '','8300'){
  $n++; $sb=[scriptblock]::Create("`$script:kbIdle=$k; `$script:padMv=`$$pm2; `$script:other=`$$ot; `$script:mine=`$$mi; `$script:quns=$q; `$script:snd='$sn'")
  if(-not (Same 'grid' $sb)){ $bad+="k=$k pad=$pm2 other=$ot mine=$mi q=$q snd=$sn" }
} } } } } }
Check ("d1 no lone move: the same answer, reason, person time and log as master over $n spare cases") ($bad.Count -eq 0) (($bad | Select-Object -First 3) -join '; ')
$n=0; $bad=@()
foreach($k in 5,600,7100,7300,80000){ foreach($foAgo in 1,100,7100,7300){ foreach($q in 5,3){ foreach($pm2 in $false,$true){
  $n++; $sb=[scriptblock]::Create("`$script:kbIdle=$k; `$script:fwFo=$foAgo; `$script:fwN=1; `$script:fwPid=4242; `$script:quns=$q; `$script:padMv=`$$pm2")
  if(-not (Same 'window' $sb)){ $bad+="k=$k fo=$foAgo q=$q pad=$pm2" }
} } } }
Check ("d1b a window move: the same as master over $n cases") ($bad.Count -eq 0) (($bad | Select-Object -First 3) -join '; ')
$n=0; $bad=@()
foreach($k in 0,5,600,900,5000){ foreach($pin in $false,$true){ foreach($pAgo in 0,500,86400){
  $n++; $sb=[scriptblock]::Create("`$script:kbIdle=$k; `$script:padIn=`$$pin; `$script:padT=(Get-Date).AddSeconds(-$pAgo); `$script:fwPerson=99999; `$script:fwFo=1; `$script:fwN=9; `$script:other=`$true; `$script:quns=3")
  if(-not (Same 'idle' $sb $true)){ $bad+="k=$k pad=$pin padAgo=$pAgo" }
} } }
Check ("d2 IDLE MODE: the same as master over $n cases, and the watch is never asked") ($bad.Count -eq 0) (($bad | Select-Object -First 3) -join '; ')
Reset $true; $script:noFocus=$false; $script:kbIdle=1; $script:fwPerson=99999; $v=[double](AwaySec); Check 'd3 IDLE MODE: a window move counts as he is here, as on master' ($v -lt 2 -and $script:fwCalls -eq 0) ("$v calls $script:fwCalls")
Reset $true; $script:fwFo=1; $a1=Arrived; Check 'd4 IDLE MODE: Arrived is still false and looks at nothing' (-not $a1 -and $script:fwCalls -eq 0 -and $script:rawCalls -eq 0) ("$a1")
Reset $true; $script:noFocus=$false; $script:fwFo=1; Check 'd5 IDLE MODE: FocusHold is false even with a window move' (-not (FocusHold)) ''

# ---- part 4b: the runner's own lines where work starts, run with recorders: a hold stops them, nothing else does
function Stmt([string]$rx){ @($ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.IfStatementAst] -and $x.Extent.Text -match $rx -and $x.Extent.Text.Length -lt 400 },$true))[0].Extent.Text }
$gateLine=Stmt 'Gate-Start \$pick'; $robotLine=Stmt "Start-Robot 9331"; $buildLine=Stmt "if\(FocusHold\)\{ PutS 'tries'"
$mainBlock=@($ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.IfStatementAst] -and $x.Clauses[0].Item1.Extent.Text -match '^\$cr -eq 0\b' },$true))[0].Extent.Text
foreach($q in 'gate','robot','build','main'){ $v=@{gate=$gateLine;robot=$robotLine;build=$buildLine;main=$mainBlock}[$q]; Check ("s0 found the runner's own $q line") ([bool]$v) '' }
function Gate-Start($j){ $script:Calls+='gate' }; function Start-Robot { $script:Calls+='robot' }; function Resume-Corpus(){ $script:Calls+='resume'; $true }; function Start-Corpus(){ $script:Calls+='full' }
function Running([string]$p){ 0 }; function Update-Game(){ $script:ug }; function NewRunnerOK(){ $false }
$script:Calls=@(); $RxPartial='no result'; function RunText([string]$t){ $script:Calls=@(); foreach($once in 1){ Invoke-Expression $t }; ($script:Calls -join ',') }
foreach($h in $true,$false){
  $w=$(if($h){''}else{'gate'}); Reset; if($h){ FocusOnly 5 }; $pick=@('job'); $g=RunText $gateLine; Check ("s1 a gate job with hold $h") ($g -ceq $w) ("called [$g]")
  $w=$(if($h){''}else{'robot'}); Reset; if($h){ FocusOnly 5 }; $g=RunText $robotLine; Check ("s2 the robot with hold $h") ($g -ceq $w) ("called [$g]")
  $w=$(if($h){''}else{'resume'}); Reset; if($h){ FocusOnly 5 }; $script:St=@{ resume_file='x' }; $script:ug=$false; $cr=0; $g=RunText $mainBlock; Check ("s3 a stopped run going on with hold $h") ($g -ceq $w) ("called [$g]")
  $w=$(if($h){''}else{'full'}); Reset; if($h){ FocusOnly 5 }; $script:ug=$true; $cr=0; $g=RunText $mainBlock; Check ("s4 a new full run with hold $h") ($g -ceq $w) ("called [$g]")
}
Reset; LoneOnly 5; $pick=@('job'); $g=RunText $gateLine; Check 's1b a gate job waits out a lone move' ($g -ceq '') ("called [$g]")
Reset; LoneOnly 5; $g=RunText $robotLine; Check 's2b the robot waits out a lone move' ($g -ceq '') ("called [$g]")
Reset; LoneOnly 5; $script:St=@{ resume_file='x' }; $script:ug=$false; $cr=0; $g=RunText $mainBlock; Check 's3b a stopped run going on waits out a lone move' ($g -ceq '') ("called [$g]")
Reset; LoneOnly 5; $script:ug=$true; $cr=0; $g=RunText $mainBlock; Check 's4b a new full run waits out a lone move' ($g -ceq '') ("called [$g]")
Reset; LoneOnly 66; $pick=@('job'); $g=RunText $gateLine; Check 's1c and starts 66 s after it' ($g -ceq 'gate') ("called [$g]")
Reset $true; $script:noFocus=$false; $script:padT=(Get-Date).AddDays(-1); $script:kbIdle=1000; $script:ug=$true; $cr=0; $script:fwFo=1; $g=RunText $mainBlock; Check 's5 IDLE MODE: a full run is not held, as on master' ($g -ceq 'full') ("called [$g]")
Invoke-Expression ('function BuildHold(){ '+$buildLine+"; 'went on' }"); Reset; FocusOnly 5; $tries=1; $g=BuildHold; Check 's6 a window move during the build: its try is given back and it says why, with no claim that anyone came' ($g -ne 'went on' -and $script:St['tries'] -eq '1' -and ($script:Log -join ' ') -like '*the input time moved with nobody seen while the test copy was built*' -and ($script:Log -join ' ') -notlike '*someone*') ("[$g] tries $($script:St['tries']) $($script:Log -join ' | ')")
Reset; LoneOnly 5; $tries=1; $g=BuildHold; Check 's6c a lone move during the build: the same' ($g -ne 'went on' -and $script:St['tries'] -eq '1') ("[$g] tries $($script:St['tries'])")
Reset; $tries=1; $g=BuildHold; Check 's6b no window move: the build goes on' ($g -eq 'went on') ("[$g]")

# ---- part 5: the runner's own load lines and the real thread, reading only (no window, no focus change, no input)
$script:noFocus=$true; $body=$tryAst.Body.Extent.Text; $body=$body.Substring(1,$body.Length-2)
try{ Invoke-Expression $body; $loaded=$true; $lerr='' }catch{ $loaded=$false; $lerr="$_" }
Check 'c8 the load lines run, start the watch and clear the flag' ($loaded -and $script:noFocus -eq $false) ("loaded $loaded flag $script:noFocus $lerr")
if($loaded){
  $L=[type]'PillagersSpare.FocusWatch'   # not started here: the load lines must have done it
  Start-Sleep -Milliseconds 700
  $fl=[Reflection.BindingFlags]'NonPublic,Static'; $pf=$L.GetField('polled',$fl); $ff=$L.GetField('first',$fl)
  $seenP=@{}; $sw=[Diagnostics.Stopwatch]::StartNew(); for($q=0;$q -lt 40;$q++){ $seenP[[string]$pf.GetValue($null)]=1; Start-Sleep -Milliseconds 25 }; $sw.Stop(); $perSec=($seenP.Count-1)/$sw.Elapsed.TotalSeconds
  Check 'l1 the real thread looks at least 6 times a second, timed, so a busy PC cannot flatter it' (-not [bool]$ff.GetValue($null) -and $perSec -ge 6) ("distinct looks $($seenP.Count) in $([Math]::Round($sw.Elapsed.TotalSeconds,1)) s")
  $pc=[Diagnostics.Process]::GetCurrentProcess(); $t0=$pc.TotalProcessorTime; Start-Sleep -Seconds 3; $pc.Refresh(); $used=($pc.TotalProcessorTime-$t0).TotalMilliseconds
  Check 'l2 it does not spin: under 3 percent of one thread over 3 s' ($used -lt 90) ("$([int]$used) ms")
  $pAge=$L::PersonIdleSec(); Check 'l3 the real answer is a real time' ($pAge -gt 0 -and $pAge -lt 1e9) ("$pAge s")
  $asked=@([regex]::Matches($tn,'\[PillagersSpare\.FocusWatch\]::(\w+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique); $gone=@($asked | Where-Object { -not $L.GetMethod($_) })
  Check 'l4 every call the runner makes on the watch is there, since a missing one would quietly fall back to the raw time' ($asked.Count -ge 6 -and $asked -ccontains 'Lones' -and $gone.Count -eq 0) ("asked $($asked -join ',') gone $($gone -join ',')")
}
$WantChecks=353   # the full count: a check whose own arguments throw records nothing, and this is what would show it
Check 'zz every check ran, so none vanished' ($r.Count+1 -eq $WantChecks) ("checks $($r.Count+1) want $WantChecks")
$ok=$true; foreach($c in $r){ if(-not $c.ok){ $ok=$false } }
$lines=$r | ForEach-Object { ('{0,-112} {1,-6} {2}' -f $_.n,$(if($_.ok){'ok'}else{'WRONG'}),$_.got) }
$dest=$(if($Out){ $Out }else{ Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'focus-mock-last.txt' }); $lines | Out-File -LiteralPath $dest -Encoding ascii
$lines | Where-Object { $_ -match '\bWRONG\b' } | ForEach-Object { $_.Substring(0,[Math]::Min(230,$_.Length)) }
('checks {0}, wrong {1}' -f $r.Count,@($r | Where-Object { -not $_.ok }).Count)
'RESULT '+$(if($ok){'PASS'}else{'FAIL'})
