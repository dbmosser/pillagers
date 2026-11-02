# MOCK test of the runner's FocusWatch change (spare PC: one move of the input time that only came with a change of the window in front is not a key or the mouse).
# Nothing here opens a window, changes focus, sends input or starts or stops a process. Part 1 proves undoing the change gives master byte for byte. Part 2 compiles the
# runner's own FocusWatch C# with its clock and GetLastInputInfo swapped for fakes and plays timelines through Look at a 100 ms poll. Part 3 runs the runner's own AwaySec,
# SoundWho, GpuGame, Save-Hold, Load-Hold, FocusHold and Arrived with the C# probes as stand-ins. Part 4 runs master's AwaySec and the new one over the same grid. Part 5
# runs the runner's own load lines and its real thread for a few seconds, reading only. Usage: focus-mock.ps1 -File new-runner.ps1 -Master master-runner.ps1 [-Out file]
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
$undo=Cut $tn "  # 11-02 (CEO, job 260's finding" "  # sound: the default output's loudness meter"
if($undo){ $undo=Cut $undo "  # 11-02: a move of the input time that only came" ('  }catch{ $a=[PillagersIdle.Input]::IdleSec(); $fo=[double]1e9 } }'+"`n") $false }
if($undo){ $undo=Cut $undo "# 11-02: a window move may be a game coming up by itself." '# SPARE-PRESENCE-PAUSE: someone came to the spare PC during this round' }
if($undo){ $undo=Cut $undo "  if(FocusHold){ PutS 'tries'" "  PutS 'fx_blob' `$blob" }
if($undo){ $undo=$undo.Replace('if([Math]::Min($a,$fo) -lt $PassCapSec){','if($a -lt $PassCapSec){')
  $undo=$undo.Replace(' -and -not (FocusHold)','')
  $undo=$undo.Replace('if((-not $Idle -or (AwaySec) -ge 900)){ Start-Corpus }','if(-not $Idle -or (AwaySec) -ge 900){ Start-Corpus }') }
Check 'c1 the cut marks are all there, once each' ([bool]$undo)
Check 'c2 undoing the four insertions and five changed lines gives master, byte for byte' ($undo -ceq $tm) ("lengths $(if($undo){$undo.Length}) $($tm.Length)")
$diffFns=@($fm.Keys | Where-Object { $fn[$_] -cne $fm[$_] } | Sort-Object); $newFns=@($fn.Keys | Where-Object { -not $fm[$_] })
Check 'c3 only AwaySec, Gate-Tick and Start-Corpus differ, Arrived does not, and FocusHold is the only new function' (($diffFns -join ',') -ceq 'AwaySec,Gate-Tick,Start-Corpus' -and ($newFns -join ',') -ceq 'FocusHold') (($diffFns -join ',')+' new '+($newFns -join ','))
$add=@($ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.CommandAst] -and $x.GetCommandName() -eq 'Add-Type' -and $x.Extent.Text -match 'FocusWatch' },$true))
$up=$add[0]; $conds=@(); $tryAst=$null; while($up){ if($up -is [System.Management.Automation.Language.TryStatementAst] -and -not $tryAst){ $tryAst=$up }; if($up -is [System.Management.Automation.Language.IfStatementAst]){ $conds+=$up.Clauses[0].Item1.Extent.Text }; $up=$up.Parent }
Check 'c4 FocusWatch loads only inside if(-not $Idle -and -not $script:noIn)' ($add.Count -eq 1 -and $conds -contains '-not $Idle -and -not $script:noIn') ($conds -join ' | ')
$fnA=[System.Management.Automation.Language.Parser]::ParseInput($fn['AwaySec'],[ref]$null,[ref]$null).EndBlock.Statements[0].Body.EndBlock.Statements
$fmA=[System.Management.Automation.Language.Parser]::ParseInput($fm['AwaySec'],[ref]$null,[ref]$null).EndBlock.Statements[0].Body.EndBlock.Statements
Check 'c5 AwaySec: the IDLE MODE line and the no-check line come first and are master''s' ($fnA[0].Extent.Text -ceq $fmA[0].Extent.Text -and $fnA[1].Extent.Text -ceq $fmA[1].Extent.Text -and $fnA[0].Extent.Text -like 'if($Idle)*' -and $fnA[1].Extent.Text -like 'if($script:noIn)*')
$cs=@($ast.FindAll({ param($p1) $p1 -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $p1.StringConstantType -eq 'SingleQuotedHereString' },$true) | Where-Object { $_.Value -match 'PersonIdleSec' })[0].Value
Check 'c6 the watch reads no key, no title and no mouse position' ($cs -notmatch 'GetAsyncKeyState|GetKeyState|GetKeyboardState|SetWindowsHookEx|GetWindowText|GetCursorPos|ReadConsole')
Check 'c7 the watch does not hold the process open' ($cs -match 'IsBackground = true')
Check 'c7b FocusHold is asked in exactly five places, and nothing in the loop waits or goes round on it' (([regex]::Matches($tn,'\(FocusHold\)|if\(FocusHold\)')).Count -eq 5 -and $tn -notmatch 'FocusHold\)\{[^}]*(Start-Sleep|continue)') ("$(([regex]::Matches($tn,'\(FocusHold\)|if\(FocusHold\)')).Count)")

# ---- part 2: the runner's own C#, on a fake clock
$imp='[DllImport("user32.dll")] static extern bool GetLastInputInfo(ref LII p);'
$now0='static uint Now(){ return (uint)Environment.TickCount; }'
$fg0='static IntPtr fg;'
foreach($a in $imp,$now0,$fg0,'static bool on = false,'){ if($cs.IndexOf($a) -lt 0){ throw ('C# anchor not found: '+$a) } }
$cf=$cs.Replace($imp,'public static uint FakeSt; public static bool FakeOk = true; static bool GetLastInputInfo(ref LII p){ p.dwTime = FakeSt; return FakeOk; }')
$cf=$cf.Replace($now0,'public static uint FakeNow; static uint Now(){ return FakeNow; }')
$cf=$cf.Replace($fg0,$fg0+' public static void MockReset(){ on = true; first = true; pend = false; one = false; haveFg = false; haveFocus = false; have1 = false; have2 = false; seen = person = pend0 = fgT = polled = focus = ig1 = ig2 = count = bursts = fgPid = 0; fg = IntPtr.Zero; n5 = 0; } public static void MockOff(){ on = false; }')
$tag='T'+[Guid]::NewGuid().ToString('N').Substring(0,8); Add-Type -Namespace ('MockFocus'+$tag) -Name W -MemberDefinition $cf; $T=[type]('MockFocus'+$tag+'.W')
function U([long]$x){ [uint32]($x -band [long]4294967295) }
# one timeline: events are @(ms,'k') a key or the mouse, @(ms,'f') a focus change that moves the stamp in the same instant (what this PC showed), @(ms,'s') the stamp alone,
# @(ms,'F') the window in front alone, @(ms,'n') the stamp with the front going NULL. Polled every 100 ms from $phase, skipping any look in $skipA..$skipB (a late look). Returns when the person was last seen, and so on.
function Sim([object[]]$ev,[long]$end,[long]$base=1000000,[int]$phase=0,[long]$skipA=-1,[long]$skipB=-1){
  $T::MockReset(); $stamp=[long]($base-600000); $fgv=1; $i=0; $zero=$false
  $ev=@($ev | Sort-Object { $_[0] })
  for($tick=[long]$phase;$tick -le $end;$tick+=100){
    if($tick -gt $skipA -and $tick -lt $skipB){ continue }
    while($i -lt $ev.Count -and [long]$ev[$i][0] -le $tick){ $e=$ev[$i]; if($e[1] -cin 'k','s','f','n'){ $stamp=$base+[long]$e[0] }; if($e[1] -cin 'f','F'){ $fgv++; $zero=$false }; if($e[1] -ceq 'n'){ $zero=$true }; $i++ }
    $n=U ($base+$tick); $st=U $stamp; $T::FakeNow=$n; $T::FakeSt=$st; $T::Look($n,$st,[IntPtr]$(if($zero){ 0 }else{ $fgv }),[uint32](100+$fgv))
  }
  $T::FakeNow=U ($base+$end); $T::FakeSt=U $stamp
  return [pscustomobject]@{ at=[long][Math]::Round($end-$T::PersonIdleSec()*1000); fo=$T::FocusOnlyAgo(); n=[long]$T::Count(); b=[long]$T::Bursts(); pid=[long]$T::LastPid() }
}
$seed=-600000
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
CS 'k1 one key with no window change: a person, at the key' @(,@(5000,'k')) 9000 5000 0
CS 'k2 a key 2 s after a window move: a person' @(@(5000,'f'),@(7000,'k')) 9000 7000 1
CS 'k3 a key 2 s before a window move: a person, and the move is not' @(@(3000,'k'),@(5000,'f')) 9000 3000 1
CS 'k4 a key 700 ms before a window move: a person' @(@(4300,'k'),@(5000,'f')) 9000 4300 1
CS 'k5 a key 700 ms after a window move: a person' @(@(5000,'f'),@(5700,'k')) 9000 5700 1
CS 'k6 a key 300 ms after a window move: a person (one change excuses one move)' @(@(5000,'f'),@(5300,'k')) 9000 5300 1
CS 'k7 a key 200 ms after a window move: a person' @(@(5000,'f'),@(5200,'k')) 9000 5200 1
CS 'k10 a key 300 ms before a window move: a person, two moves are not one' @(@(4700,'k'),@(5000,'f')) 9000 5000 0
$alt=@(@(4800,'k'),@(4880,'k'),@(4960,'k'),@(5000,'k'),@(5010,'f'))
CS 'k11 Alt+Tab once, then reading the screen: a person' $alt 9000 5010 0
$altUp=@(@(5000,'f'),@(5150,'k'))
CS 'k12 Alt held, Tab: the window changes, then the keys come up: a person' $altUp 9000 5150 1
$many=@(); foreach($o in 0,16000,32000,48000,64000){ foreach($q in 0,80,160,200){ $many+=,@((5000+$o+$q),'k') }; $many+=,@((5000+$o+210),'f') }
$x=Sim $many 70000; Check 'k13 Alt+Tab every 16 s and nothing else: a person from the first' ($x.at -ge 69000 -and $x.n -eq 0) ("person at $($x.at), window moves $($x.n)")
$x=Sim @(,@(5000,'f')) 9000; $first=$x.at; $x=Sim @(@(5000,'k'),@(5050,'f')) 9000 1000000 99; Check 'k14 the known limit: a press and release inside one look that changes the window is one move, so it is missed' ($x.at -eq $seed -and $x.n -eq 1) ("at $($x.at) n $($x.n)")
$x=Sim @(@(5000,'k'),@(5050,'f'),@(6500,'k')) 9000 1000000 99; Check 'k14b and the next input is a person' ($x.at -eq 6500) ("at $($x.at)")
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
CS 'f1 a window change with no input time move, then a key 3 s later: a person' @(@(5000,'F'),@(8000,'k')) 9000 8000 0
CS 'f2 a window change with no move does not count as a window move' @(,@(5000,'F')) 9000 $seed 0
$x=Sim @(,@(5000,'f')) 9000; Check 'f3 it keeps the process of the new window for the log' ($x.pid -eq 102) ("pid $($x.pid)")
CS 'n1 Enter on a dialog: the front goes NULL with the press, the next window with the release: a person, not two window moves' @(@(5000,'n'),@(5100,'f')) 9000 5100 0
CS 'n2 a window closes by itself, the front NULL for a moment, then the next window: one window move' @(@(5000,'n'),@(5100,'F')) 9000 $seed 1
CS 'n3 the front goes NULL and stays there: a person, as on master' @(,@(5000,'n')) 9000 5000 0
$bw=[long]4294967295-5000
$x=Sim @(,@(5500,'f')) 9000 $bw; Check 'z1 the tick count wraps: a window move is still one' ($x.at -eq $seed -and $x.n -eq 1) ("at $($x.at) n $($x.n)")
$x=Sim @(,@(5500,'k')) 9000 $bw; Check 'z2 the tick count wraps: a key is still a person' ($x.at -eq 5500 -and $x.n -eq 0) ("at $($x.at) n $($x.n)")
[void](Sim @(,@(5000,'k')) 6000); $T::FakeNow=U (1000000+4984); $a=$T::PersonIdleSec(); Check 'z3 a clock just behind the person''s time reads as just now, not 49 days' ($a -lt 1) ("$a")
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

# ---- part 3: the runner's own functions with stand-ins for the C#
$names='AwaySec','SoundWho','GpuGame','Save-Hold','Load-Hold','FocusHold','Arrived','Epoch','Short'   # Arrived is master's
foreach($n in $names){ if(-not $fn[$n]){ throw ('missing '+$n) }; $code=$fn[$n].Replace('[PillagersIdle.Input]::','$MIn.').Replace('[PillagersSpare.Presence]::','$MPre.').Replace('[PillagersSpare.Sound]::','$MSnd.').Replace('[PillagersSpare.FocusWatch]::','$MFw.'); if($code -match 'Pillagers(Idle|Spare)\.|Stop-Process|Start-Process|\.Kill\(|WriteAllText|AppendAllText'){ throw ('mock not safe: '+$n) }; Invoke-Expression $code }
Invoke-Expression ($fm['AwaySec'].Replace('[PillagersIdle.Input]::','$MIn.').Replace('[PillagersSpare.Presence]::','$MPre.').Replace('[PillagersSpare.Sound]::','$MSnd.').Replace('function AwaySec(','function AwaySecM('))
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
$MFw | Add-Member ScriptMethod PersonIdleSec { $script:fwCalls++; if($script:fwThrow){ throw 'no watch' }; $script:fwPerson }
$MFw | Add-Member ScriptMethod FocusOnlyAgo { if($script:fwThrow){ throw 'no watch' }; $script:fwFo }
$MFw | Add-Member ScriptMethod Count { [uint32]$script:fwN }
$MFw | Add-Member ScriptMethod Bursts { [uint32]$script:fwB }
$MFw | Add-Member ScriptMethod LastPid { [uint32]$script:fwPid }
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
  $script:noFocus=$false; $script:focusN=[uint32]0; $script:burstN=[uint32]0; $script:holdN=[uint32]0; $script:noIn=$false; $script:noPres=$false; $script:noSnd=$false; $script:sndSaid=$false; $script:sndCache=@{}
  $script:kbIdle=5000.0; $script:padIn=$false; $script:padMv=$false; $script:other=$false; $script:mine=$true; $script:quns=5; $script:snd=''; $script:gpu=@{}
  $script:fwPerson=5000.0; $script:fwFo=[double]1e9; $script:fwN=0; $script:fwB=0; $script:fwPid=0; $script:fwThrow=$false; $script:fwCalls=0; $script:presCalls=0; $script:rawCalls=0; $script:Reads=0; $script:padNotes=0
  $script:holdE=[long]0; $script:holdH=[long]0; $script:gpuChk=(Get-Date).AddDays(-1); $script:Log=@(); $script:St=@{}
}
function A(){ $v=AwaySec; return [pscustomobject]@{ a=[double]$v; w=$script:awayWhy } }
function FocusOnly([double]$ago=5.0,[double]$person=99999.0){ $script:kbIdle=$ago; $script:fwPerson=$person; $script:fwFo=$ago; $script:fwN=1; $script:fwPid=4242 }
Reset; FocusOnly; $x=A; Check 'a1 a program takes the front, nobody here: no stop, no pause' ($x.a -gt $big) ("$($x.a) $($x.w)")
$nl=@($script:Log | Where-Object { $_ -like 'the input time moved as the window in front changed to SomeUpdater*' }).Count; Check 'a1b it says so once, naming the program' ($nl -eq 1) ($script:Log -join ' | ')
[void](A); $nl=@($script:Log | Where-Object { $_ -like 'the input time moved*' }).Count; Check 'a1c not again at the next look' ($nl -eq 1) ("lines $nl")
$script:fwN=2; [void](A); $nl=@($script:Log | Where-Object { $_ -like 'the input time moved*' }).Count; Check 'a1d a new move is said too' ($nl -eq 2) ("lines $nl")
Reset; FocusOnly; $script:fwPid=0; [void](A); Check 'a1e no process: says a program' ($script:Log -contains 'the input time moved as the window in front changed to a program: not counted as someone at the PC') ($script:Log -join ' | ')
Reset; FocusOnly; $script:fwPid=7777; [void](A); Check 'a1f a process already gone: says a program' ($script:Log -contains 'the input time moved as the window in front changed to a program: not counted as someone at the PC') ($script:Log -join ' | ')
Reset; $script:fwB=1; $script:kbIdle=1; $script:fwPerson=1; [void](A); $nb=@($script:Log | Where-Object { $_ -like 'the window in front keeps changing*' }).Count; [void](A); $nb2=@($script:Log | Where-Object { $_ -like 'the window in front keeps changing*' }).Count; Check 'a1g a burst is said once, so it can be told from a real key' ($nb -eq 1 -and $nb2 -eq 1) ("$nb $nb2")
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
$nh=@($script:Log | Where-Object { $_ -like 'a window came to the front: no new test work*' }).Count; [void](FocusHold); $nh2=@($script:Log | Where-Object { $_ -like 'a window came to the front: no new test work*' }).Count; $script:fwN=2; [void](FocusHold); $nh3=@($script:Log | Where-Object { $_ -like 'a window came to the front: no new test work*' }).Count; Check 'h1i it says a start is held, once per move' ($nh -eq 1 -and $nh2 -eq 1 -and $nh3 -eq 2) ("$nh $nh2 $nh3")
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

# ---- part 4: master's AwaySec against the new one
function Same([string]$name,[scriptblock]$setup,[bool]$idle=$false){
  Reset $idle; & $setup; $script:fwPerson=$script:kbIdle; $v1=[double](AwaySec); $w1=$script:awayWhy; $h1=$script:humanAgo; $l1=$script:Log -join '|'; $c1=$script:fwCalls
  Reset $idle; & $setup; $v2=[double](AwaySecM); $w2=$script:awayWhy; $h2=$script:humanAgo; $l2=$script:Log -join '|'
  $ok=([Math]::Abs($v1-$v2) -lt 1 -and $w1 -ceq $w2 -and ([Math]::Abs($h1-$h2) -lt 1) -and $l1 -ceq $l2)
  if($idle -and $c1 -ne 0){ $ok=$false }
  return $ok
}
$n=0; $bad=@()
foreach($k in 0,5,29,30,59,60,600,899,900,7100,7300){ foreach($pm2 in $false,$true){ foreach($ot in $false,$true){ foreach($mi in $true,$false){ foreach($q in 5,3){ foreach($sn in '','8300'){
  $n++; $sb=[scriptblock]::Create("`$script:kbIdle=$k; `$script:padMv=`$$pm2; `$script:other=`$$ot; `$script:mine=`$$mi; `$script:quns=$q; `$script:snd='$sn'")
  if(-not (Same 'grid' $sb)){ $bad+="k=$k pad=$pm2 other=$ot mine=$mi q=$q snd=$sn" }
} } } } } }
Check ("d1 no window move: the same answer, reason, person time and log as master over $n spare cases") ($bad.Count -eq 0) (($bad | Select-Object -First 3) -join '; ')
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
Reset $true; $script:noFocus=$false; $script:padT=(Get-Date).AddDays(-1); $script:kbIdle=1000; $script:ug=$true; $cr=0; $script:fwFo=1; $g=RunText $mainBlock; Check 's5 IDLE MODE: a full run is not held, as on master' ($g -ceq 'full') ("called [$g]")
Invoke-Expression ('function BuildHold(){ '+$buildLine+"; 'went on' }"); Reset; FocusOnly 5; $tries=1; $g=BuildHold; Check 's6 a window move during the build: its try is given back and it says why, with no claim that anyone came' ($g -ne 'went on' -and $script:St['tries'] -eq '1' -and ($script:Log -join ' ') -like '*a window came to the front while the test copy was built*' -and ($script:Log -join ' ') -notlike '*someone*') ("[$g] tries $($script:St['tries']) $($script:Log -join ' | ')")
Reset; $tries=1; $g=BuildHold; Check 's6b no window move: the build goes on' ($g -eq 'went on') ("[$g]")

# ---- part 5: the runner's own load lines and the real thread, reading only (no window, no focus change, no input)
$script:noFocus=$true; $body=$tryAst.Body.Extent.Text; $body=$body.Substring(1,$body.Length-2)
try{ Invoke-Expression $body; $loaded=$true; $lerr='' }catch{ $loaded=$false; $lerr="$_" }
Check 'c8 the load lines run, start the watch and clear the flag' ($loaded -and $script:noFocus -eq $false) ("loaded $loaded flag $script:noFocus $lerr")
if($loaded){
  $L=[type]'PillagersSpare.FocusWatch'   # not started here: the load lines must have done it
  Start-Sleep -Milliseconds 700
  $fl=[Reflection.BindingFlags]'NonPublic,Static'; $pf=$L.GetField('polled',$fl); $ff=$L.GetField('first',$fl)
  $seenP=@{}; for($q=0;$q -lt 40;$q++){ $seenP[[string]$pf.GetValue($null)]=1; Start-Sleep -Milliseconds 25 }
  Check 'l1 the real thread looks, at least 7 times in a second' (-not [bool]$ff.GetValue($null) -and $seenP.Count -ge 7) ("distinct looks $($seenP.Count)")
  $pc=[Diagnostics.Process]::GetCurrentProcess(); $t0=$pc.TotalProcessorTime; Start-Sleep -Seconds 3; $pc.Refresh(); $used=($pc.TotalProcessorTime-$t0).TotalMilliseconds
  Check 'l2 it does not spin: under 3 percent of one thread over 3 s' ($used -lt 90) ("$([int]$used) ms")
  $pAge=$L::PersonIdleSec(); Check 'l3 the real answer is a real time, and it is not the fallback' ($pAge -gt 0 -and $pAge -lt 1e9) ("$pAge s")
}
$ok=$true; foreach($c in $r){ if(-not $c.ok){ $ok=$false } }
$lines=$r | ForEach-Object { ('{0,-112} {1,-6} {2}' -f $_.n,$(if($_.ok){'ok'}else{'WRONG'}),$_.got) }
$dest=$(if($Out){ $Out }else{ Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'focus-mock-last.txt' }); $lines | Out-File -LiteralPath $dest -Encoding ascii
$lines | Where-Object { $_ -match '\bWRONG\b' } | ForEach-Object { $_.Substring(0,[Math]::Min(230,$_.Length)) }
('checks {0}, wrong {1}' -f $r.Count,@($r | Where-Object { -not $_.ok }).Count)
'RESULT '+$(if($ok){'PASS'}else{'FAIL'})
