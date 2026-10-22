# fuzz.ps1 : the nightly INPUT FUZZER. A TOOL ONLY: it never edits or loads anything into the game except through the test fixture
# copy (tools\fixture-soak-fuzz.html, gitignored) and the read-only hook tools\fuzz-hook.js. ASCII only (PowerShell 5.1 reads .ps1 as ANSI).
# Born from his order of 2026-10-13/14: "do whatever you need to do to make my pc resources useful for the many hours that they are idle".
#
# RUN IT:   powershell -NoProfile -ExecutionPolicy Bypass -File tools\fuzz.ps1                       (120 minutes, port 9331, 300 s raids)
#           ... -Minutes 5 -RaidSec 60 -IgnoreFlag       a short run (-IgnoreFlag: run even if light.flag, the "he is at the PC" flag, exists)
#           ... -SelfTest                                injects setTimeout(function(){throw new Error('fuzztest')},0) once, to prove it is logged
#           ... -Mode demo1|demo2|demo2p|career -RaidSeed N     REPLAY one raid (the mode and raidSeed are in every problem record)
#           ... -P2Share 75                              percent of raids that are the REAL 2-player demo (demo2p): the default, 3 of every 4
#           ... -P2Share 0                               the old rotation: demo1, career, demo2 in turn
# WHAT ONE RAID DOES: starts a raid in its own headless Chrome (1920x1080, port 9331) from a fixture copy. 10-18, his order "75% of overnight
#   robot time on the real 2-player setup": 3 of every 4 raids are demo2p, THE REAL PARTY RIG. Player 1 is the first page, the host, on keyboard
#   and mouse (the random input below). Player 2 is a SECOND WINDOW of the same Chrome, opened with the address the game itself gives it
#   (?p2=1&mode=coop&pair=..&arc=1), paired over the game's own BroadcastChannel and WebRTC link, and played by a SIMULATED XBOX PAD:
#   tools\fuzz-pad.js replaces navigator.getGamepads in that window only with a fake standard pad on slot 0 (the first controller, which since
#   cw-p2pads, v30.70, is the one player 2 plays: netPadFor) that wanders, fires, rolls, reloads, uses the wheel, backpack and pause like a restless guest. Player 1 drops in,
#   then player 2 presses A to join. Both windows are polled for errors, NaN and stalls (player 2 problems are kind p2:error, p2:nan ...).
#   The 4th raid alternates demo1 (1 PLAYER ARCADE DEMO) and career (a CAREER raid from the Undercroft path). demo2 (the arcade with 2 player
#   rules, this window as host alone) is only the fallback when the two-window link cannot be made 3 raids in a row. Then for -RaidSec seconds it sends random but plausible
#   input as REAL CDP events (Input.dispatchKeyEvent / dispatchMouseEvent, ticks of 50 ms, from a SEEDED System.Random so a raid replays;
#   the game's own RNG is never touched): WASD bursts (+ shift sprint), aim drift, fire clicks, RMB aim, wheel, R E X G U H J Q F 1-9
#   (taps and holds), B/I M ESC P Alt SPACE CTRL C middle click Tab Enter, and random backpack drags on the real bag/belt cells.
#   Half the raids are "tough" (hp topped up under 35) so they live long enough to reach the late states. After -RaidSec the raid clock is
#   set to 2 s and the raid must END on its own within 75 s (the burn / death path), else a "noend" problem.
# WHAT IT LOGS (tools\handoff\fuzz\): fuzz.log = one line per raid (raid count, problems, unique errors); fuzz-<date>.jsonl = one record per
#   NEW problem (same message = one record, counted): build, runSeed, mode, raidSeed, raid second, kind, message, stack, the last 60 inputs.
#   Kinds: error / rejection / console.error / game-crash (JS errors), nan (non-finite player x y hp armor, or any entity), stuck (no
#   movement 20 s with movement keys held outside menus), stall (no rAF 5 s), noend (a raid that never ends after the clock), hang
#   (the page stopped answering 10+ s), start (a raid that would not start), cleanup (endRaid threw), dialog.
# STOPS EARLY when light.flag appears (he is back), closes its Chrome, and a hidden watchdog kills that Chrome if this script is killed.
param(
  [int]$Minutes=120,
  [int]$Port=9331,
  [int]$Seed=0,
  [int]$RaidSec=300,
  [int]$Srv=0,
  [string]$Mode='',
  [int]$RaidSeed=0,
  [double]$MinFreeGB=5,
  [string]$FlagFile='',
  [switch]$IgnoreFlag,
  [switch]$SelfTest,
  [switch]$Trace,
  [string]$Fixture='fixture.html',
  [int]$P2Share=75
)
$ErrorActionPreference='Stop'
$R=$(if($env:PILLAGERS_ROOT){ $env:PILLAGERS_ROOT -replace '/','\' }else{ 'C:\claudecode\dark raiders' }); $T=$R+'\tools'; $OutDir=$T+'\handoff\fuzz'   # 10-22: the main PC's idle runs set PILLAGERS_ROOT
$Flag='C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\light.flag'
if($FlagFile -ne ''){ $Flag=$FlagFile }
if($env:FUZZ_OUT_DIR){ $OutDir=$env:FUZZ_OUT_DIR }   # a hand test writes its log and records somewhere else, never into the nightly ones
$LogF=$OutDir+'\fuzz.log'; $Jsonl=$OutDir+'\fuzz-'+(Get-Date -Format 'yyyy-MM-dd')+'.jsonl'
$Enc=New-Object Text.UTF8Encoding $false
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
if($Seed -eq 0){ $Seed=[int]((Get-Date).Ticks % 2000000000) }
if($Port -in 8802,9346,9335,9345,9344){ Write-Output ('refusing port '+$Port); exit 2 }
# 2026-10-18: -Fixture NAME runs the robots on another fixture in tools\ . nightly.sh gives the second robot the corpus copy (tools\fxcorpus.html), so one exact
# version gets both the full test set and 30+ robot minutes, which is what tools\stable.sh needs. It uses its own copy name so the two robots never share a file.
if($Fixture -notmatch '^[A-Za-z0-9._-]+\.html$'){ $Fixture='fixture.html' }
$FzName = $(if($Fixture -eq 'fixture.html'){ 'fixture-soak-fuzz.html' } else { 'fixture-soak-fuzzc.html' })
# 2026-10-18 (the 2-player robots): FUZZ_COPY_NAME=name.html gives a hand test its own served copy name, so it never touches a running robot's copy
if($env:FUZZ_COPY_NAME -and $env:FUZZ_COPY_NAME -match '^[A-Za-z0-9._-]+\.html$'){ $FzName=$env:FUZZ_COPY_NAME }
if($P2Share -lt 0){ $P2Share=0 }; if($P2Share -gt 100){ $P2Share=100 }

function Stamp(){ (Get-Date).ToString('yyyy-MM-dd HH:mm:ss') }
function Clean([string]$s){ ($s -replace '[^\x20-\x7e]','?') }
function LogLine([string]$s){ [IO.File]::AppendAllText($LogF,(Clean $s)+"`n",$Enc) }
function JsonRec($o){ [IO.File]::AppendAllText($Jsonl,(($o | ConvertTo-Json -Compress -Depth 6))+"`n",$Enc) }
function JsStr([string]$s){ (ConvertTo-Json -InputObject $s -Compress) }

if((Test-Path -LiteralPath $Flag) -and -not $IgnoreFlag){ LogLine ((Stamp)+' FUZZ not started: light.flag exists (he is at the PC)'); Write-Output 'light.flag exists: not started'; exit 0 }

# ---------------------------------------------------------------- chrome, server, page
function Kill-Chrome(){
  try{
    Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match ('remote-debugging-port='+$Port+'(\s|$)') } |
      ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
  }catch{}
}
function Probe-Server([int]$p){
  try{ $rq=[Net.WebRequest]::Create('http://localhost:'+$p+'/'+$FzName); $rq.Timeout=4000; $rs=$rq.GetResponse(); $len=$rs.ContentLength; $rs.Close(); return ($len -gt 5000000) }catch{ return $false }
}
function Pick-Server(){
  $c=@(); if($Srv -gt 0){ $c+=$Srv }; $c+=@(8810,8809,8808,8807,8806,8805,8804,8803)
  foreach($p in $c){ if(Probe-Server $p){ return $p } }
  return 0
}
$script:ownSrv=$null; $script:srvPort=0
function Copy-Fixture(){
  # its own copy: a ship mid-run rebuilds fixture.html, and a half written file must never be served
  for($i=0;$i -lt 8;$i++){
    try{
      $t1=(Get-Item ($T+'\'+$Fixture)).LastWriteTimeUtc
      Copy-Item ($T+'\'+$Fixture) ($T+'\'+$FzName) -Force
      $fi=Get-Item ($T+'\'+$FzName); $s2=Get-Item ($T+'\'+$Fixture)
      $tail=[Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($fi.FullName),[int]($fi.Length-300),300)
      if($fi.Length -gt 5000000 -and $fi.Length -eq $s2.Length -and $s2.LastWriteTimeUtc -eq $t1 -and $tail -match '</script>'){ return $true }
    }catch{}
    Start-Sleep 5
  }
  return $false
}

# ---------------------------------------------------------------- CDP over one websocket
$script:ws=$null; $script:rxTask=$null; $script:rxBuf=New-Object byte[] 262144; $script:rxMs=New-Object IO.MemoryStream; $script:id=0
function NextId(){ $script:id++; return $script:id }
function Ws-Connect([string]$url){
  $w=New-Object System.Net.WebSockets.ClientWebSocket
  $w.ConnectAsync([Uri]$url,[Threading.CancellationToken]::None).Wait(8000) | Out-Null
  $script:ws=$w; $script:rxTask=$null; $script:rxMs.SetLength(0)
}
function Ws-Send([string]$s){
  $b=[Text.Encoding]::UTF8.GetBytes($s)
  $t=$script:ws.SendAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$b)),[System.Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None)
  if(-not $t.Wait(8000)){ throw 'CDP timeout (send)' }
}
function Ws-Recv([int]$ms){
  $sw=[Diagnostics.Stopwatch]::StartNew()
  while($true){
    if(-not $script:rxTask){ $script:rxTask=$script:ws.ReceiveAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$script:rxBuf)),[Threading.CancellationToken]::None) }
    $left=$ms-[int]$sw.ElapsedMilliseconds; if($left -lt 1){ $left=1 }
    if(-not $script:rxTask.Wait($left)){ return $null }
    $r=$script:rxTask.Result; $script:rxTask=$null
    if($r.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close){ throw 'CDP socket closed' }
    $script:rxMs.Write($script:rxBuf,0,$r.Count)
    if($r.EndOfMessage){ $m=[Text.Encoding]::UTF8.GetString($script:rxMs.ToArray()); $script:rxMs.SetLength(0); return $m }
  }
}
$script:dialogs=0
function Cdp([int]$id,[string]$json,[int]$ms){
  Ws-Send $json
  $sw=[Diagnostics.Stopwatch]::StartNew(); $pre='{"id":'+$id+','
  while($true){
    $left=$ms-[int]$sw.ElapsedMilliseconds
    if($left -le 0){ throw 'CDP timeout' }
    $m=Ws-Recv $left
    if($m -eq $null){ throw 'CDP timeout' }
    if($m.StartsWith($pre)){ return $m }
    if($m.StartsWith('{"method":"Page.javascriptDialogOpening"')){
      $script:dialogs++
      $d=NextId; Ws-Send ('{"id":'+$d+',"method":"Page.handleJavaScriptDialog","params":{"accept":false}}')
    }
  }
}
function Ev([string]$expr,[int]$ms=15000){
  $id=NextId
  $m=Cdp $id ('{"id":'+$id+',"method":"Runtime.evaluate","params":{"expression":'+(JsStr $expr)+',"returnByValue":true,"awaitPromise":false}}') $ms
  $o=$m | ConvertFrom-Json
  if($o.result.exceptionDetails){ $ex=$o.result.exceptionDetails; $d=''; if($ex.exception){ $d=[string]$ex.exception.description }; throw ('EVAL: '+$ex.text+' '+$d) }
  return $o.result.result.value
}
function Gx([string]$js,[int]$ms=15000){ return (Ev ('window.__gx('+(JsStr $js)+')') $ms) }
function Cmd([string]$method,[string]$params='{}'){ $id=NextId; [void](Cdp $id ('{"id":'+$id+',"method":"'+$method+'","params":'+$params+'}') 15000) }

# ---------------------------------------------------------------- the second window (demo2p): two pages, one socket each
# The functions above talk to ONE socket kept in $script:ws / rxTask / rxBuf / rxMs. Pg-Use switches those four to another page's, saving the
# current ones first, so every helper (Ev, Gx, Cmd, ...) works unchanged on whichever page is in use. 'p1' is the host page the old modes use.
$script:pgs=@{ p1=@{ ws=$null; rxTask=$null; rxBuf=$script:rxBuf; rxMs=$script:rxMs } }; $script:curPg='p1'
function Pg-Use([string]$n){
  if($n -eq $script:curPg){ return }
  $c=$script:pgs[$script:curPg]; $c.ws=$script:ws; $c.rxTask=$script:rxTask
  $t=$script:pgs[$n]; $script:ws=$t.ws; $script:rxTask=$t.rxTask; $script:rxBuf=$t.rxBuf; $script:rxMs=$t.rxMs
  $script:curPg=$n
}
function Pg-Drop2(){   # forget the player 2 page (its window is closed by Open-Page); back on the host page
  try{ if($script:curPg -ne 'p1'){ Pg-Use 'p1' } }catch{}
  if($script:pgs.ContainsKey('p2')){ try{ if($script:pgs['p2'].ws){ $script:pgs['p2'].ws.Dispose() } }catch{}; $script:pgs.Remove('p2') }
}
# One request on a throwaway socket (the browser endpoint), answered by its id 1.
function Cdp-Once([string]$wsUrl,[string]$method,[string]$params){
  $w=New-Object System.Net.WebSockets.ClientWebSocket
  try{
    $w.ConnectAsync([Uri]$wsUrl,[Threading.CancellationToken]::None).Wait(8000) | Out-Null
    $b=[Text.Encoding]::UTF8.GetBytes('{"id":1,"method":"'+$method+'","params":'+$params+'}')
    if(-not $w.SendAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$b)),[System.Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).Wait(8000)){ throw 'CDP timeout (send once)' }
    $buf=New-Object byte[] 65536; $ms=New-Object IO.MemoryStream; $sw=[Diagnostics.Stopwatch]::StartNew()
    while($sw.ElapsedMilliseconds -lt 15000){
      $t=$w.ReceiveAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$buf)),[Threading.CancellationToken]::None)
      if(-not $t.Wait(15000-[int]$sw.ElapsedMilliseconds)){ break }
      $ms.Write($buf,0,$t.Result.Count)
      if($t.Result.EndOfMessage){ $txt=[Text.Encoding]::UTF8.GetString($ms.ToArray()); $ms.SetLength(0); if($txt.StartsWith('{"id":1,')){ return $txt } }
    }
    throw 'CDP timeout (once)'
  } finally { try{ $w.Dispose() }catch{} }
}
# A page in a WINDOW of its own (a second tab of the same window would be hidden, and a hidden page gets no animation frames).
function New-WindowPage([string]$url,[int]$w,[int]$h){
  $v=Invoke-RestMethod ('http://127.0.0.1:'+$Port+'/json/version') -TimeoutSec 5
  $r=Cdp-Once ([string]$v.webSocketDebuggerUrl) 'Target.createTarget' ('{"url":'+(JsStr $url)+',"newWindow":true,"width":'+$w+',"height":'+$h+'}')
  $o=$r | ConvertFrom-Json
  if(-not $o.result.targetId){ throw ('Target.createTarget said: '+$r) }
  return ('ws://127.0.0.1:'+$Port+'/devtools/page/'+$o.result.targetId)
}
$script:PadJs=''; try{ $script:PadJs=[IO.File]::ReadAllText($T+'\fuzz-pad.js') }catch{ $script:PadJs='' }
# The other way round: a window Chrome is NOT feeding (not in front) sees no pads at all. Installed in the player 2 window when player 1's window (in front) holds the pad.
$script:BlindJs='(function(){ try{ Object.defineProperty(navigator,"getGamepads",{value:function(){ return [null,null,null,null]; },configurable:true,writable:true}); }catch(e){ try{ navigator.getGamepads=function(){ return [null,null,null,null]; }; }catch(e2){ return "failed "+e2; } } try{ document.hasFocus=function(){ return false; }; }catch(e3){} return "installed"; })()'
$script:padPage='p2'

$script:needReset=$true; $script:ver='?'; $script:maps=@()
$script:Hook=[IO.File]::ReadAllText($T+'\fuzz-hook.js')
function Open-Page(){
  $base='http://127.0.0.1:'+$Port
  Pg-Drop2   # a player 2 window from a demo2p raid is closed with every other page just below
  try{ (Invoke-RestMethod ($base+'/json') -TimeoutSec 5) | Where-Object { $_.type -eq 'page' } | ForEach-Object { try{ Invoke-RestMethod ($base+'/json/close/'+$_.id) -TimeoutSec 5 | Out-Null }catch{} } }catch{}
  $tab=Invoke-RestMethod -Method Put -Uri ($base+'/json/new?http://localhost:'+$script:srvPort+'/'+$FzName) -TimeoutSec 10
  Ws-Connect $tab.webSocketDebuggerUrl
  Cmd 'Page.enable'
  Cmd 'Emulation.setDeviceMetricsOverride' '{"width":1920,"height":1080,"deviceScaleFactor":1,"mobile":false}'
  Cmd 'Emulation.setFocusEmulationEnabled' '{"enabled":true}'
  Cmd 'Page.bringToFront'
  $ok=$false
  for($i=0;$i -lt 120;$i++){
    try{ if((Ev "typeof window.__gx==='function'&&typeof window.__deploy==='function'") -eq $true){ $ok=$true; break } }catch{}
    Start-Sleep 1
  }
  if(-not $ok){ throw 'the fixture page did not come up in 120 s' }
  Start-Sleep 2
  $r=Gx $script:Hook
  if($r -ne 'installed' -and $r -ne 'already'){ throw ('hook install said: '+$r) }
  [void](Gx '__runPrep()')
  $script:ver=[string](Gx 'VER')
  $mp=Gx "(function(){ var a=[],i; for(i=0;i<FIXED_MAPS.length;i++){ try{ if(mapOffered(FIXED_MAPS[i])) a.push(i); }catch(e){ a.push(i); } } return JSON.stringify(a.length?a:[0]); })()"
  $script:maps=@(); foreach($v in ($mp | ConvertFrom-Json)){ $script:maps+=[int]$v }
  $script:needReset=$false
}

# ---------------------------------------------------------------- input layer
$KM=@{}
foreach($c in 65..90){ $L=[string][char]$c; $KM['Key'+$L]=@($L.ToLower(),('Key'+$L),$c) }
foreach($d in 1..9){ $KM['Digit'+$d]=@([string]$d,('Digit'+$d),(48+$d)) }
$KM['Space']=@(' ','Space',32); $KM['Escape']=@('Escape','Escape',27); $KM['Tab']=@('Tab','Tab',9); $KM['Enter']=@('Enter','Enter',13)
$KM['ControlLeft']=@('Control','ControlLeft',17); $KM['AltLeft']=@('Alt','AltLeft',18); $KM['ShiftLeft']=@('Shift','ShiftLeft',16)
$MOVE=@('KeyW','KeyA','KeyS','KeyD'); $MODK=@('ControlLeft','AltLeft','ShiftLeft')
$script:ring=New-Object 'System.Collections.Generic.Queue[string]'
$script:held=(New-Object 'System.Collections.Generic.Dictionary[string,object]'); $script:btns=0; $script:mx=960; $script:my=540; $script:tick=0; $script:lastAct=-1000; $script:lastMmRing=-100; $script:nEv=0
function Ring([string]$s){ $script:ring.Enqueue(([string]$script:tick)+':'+$s); while($script:ring.Count -gt 60){ [void]$script:ring.Dequeue() } }
function ModBits(){ $m=0; if($script:held.ContainsKey('AltLeft')){ $m+=1 }; if($script:held.ContainsKey('ControlLeft')){ $m+=2 }; if($script:held.ContainsKey('ShiftLeft')){ $m+=8 }; return $m }
function KeyEv([string]$type,[string]$n,[bool]$rep){
  $k=$KM[$n]; $id=NextId; $script:nEv++
  $rp='false'; if($rep){ $rp='true' }
  [void](Cdp $id ('{"id":'+$id+',"method":"Input.dispatchKeyEvent","params":{"type":"'+$type+'","key":"'+$k[0]+'","code":"'+$k[1]+'","windowsVirtualKeyCode":'+$k[2]+',"nativeVirtualKeyCode":'+$k[2]+',"modifiers":'+(ModBits)+',"autoRepeat":'+$rp+'}}') 10000)
}
function Press([string]$n,[int]$ticks){
  if($script:held.ContainsKey($n)){ return }
  $script:held[$n]=@{since=$script:tick;until=($script:tick+$ticks)}
  KeyEv 'keyDown' $n $false
  Ring ('kd '+$n)
  if(-not ($MOVE -contains $n) -and -not ($MODK -contains $n)){ $script:lastAct=$script:tick }
}
function Release([string]$n){
  if(-not $script:held.ContainsKey($n)){ return }
  $script:held.Remove($n)
  KeyEv 'keyUp' $n $false
  Ring ('ku '+$n)
}
function MouseEv([string]$type,[int]$x,[int]$y,[string]$btn,[int]$buttons,[int]$cc,[int]$dy){
  $id=NextId; $script:nEv++
  [void](Cdp $id ('{"id":'+$id+',"method":"Input.dispatchMouseEvent","params":{"type":"'+$type+'","x":'+$x+',"y":'+$y+',"button":"'+$btn+'","buttons":'+$buttons+',"clickCount":'+$cc+',"modifiers":'+(ModBits)+',"deltaX":0,"deltaY":'+$dy+'}}') 10000)
}
function BtnName([int]$bit){ if($bit -eq 1){ return 'left' }; if($bit -eq 2){ return 'right' }; return 'middle' }
function MMove([int]$x,[int]$y){
  if($x -lt 0){ $x=0 }; if($y -lt 0){ $y=0 }; if($x -gt 1919){ $x=1919 }; if($y -gt 1079){ $y=1079 }
  $script:mx=$x; $script:my=$y
  $b='none'; if($script:btns -band 1){ $b='left' }elseif($script:btns -band 2){ $b='right' }elseif($script:btns -band 4){ $b='middle' }
  MouseEv 'mouseMoved' $x $y $b $script:btns 0 0
  if(($script:tick-$script:lastMmRing) -ge 6){ $script:lastMmRing=$script:tick; Ring ('mm '+$x+','+$y) }
}
function MDown([int]$bit){ $script:btns=($script:btns -bor $bit); MouseEv 'mousePressed' $script:mx $script:my (BtnName $bit) $script:btns 1 0; Ring ('md '+(BtnName $bit)+' '+$script:mx+','+$script:my) }
function MUp([int]$bit){ $script:btns=($script:btns -band (-bnot $bit)); MouseEv 'mouseReleased' $script:mx $script:my (BtnName $bit) $script:btns 1 0; Ring ('mu '+(BtnName $bit)) }
function Wheel([int]$dy){ MouseEv 'mouseWheel' $script:mx $script:my 'none' $script:btns 0 $dy; Ring ('wh '+$dy) }
function Release-All(){
  foreach($n in @($script:held.Keys)){ try{ Release $n }catch{} }
  foreach($b in 1,2,4){ if($script:btns -band $b){ try{ MUp $b }catch{} } }
}

# ---------------------------------------------------------------- problems
$script:uniq=@{}; $script:dups=@{}; $script:raidProblems=0; $script:newUniq=0; $script:curMode=''; $script:curSeed=0; $script:raidNo=0; $script:raidSw=$null
function Norm-Key([string]$kind,[string]$msg){
  $m=($msg -replace '^Uncaught\s+','' -replace '\d+','#')
  if(@('error','rejection','console.error','game-crash') -contains $kind){ return 'js|'+$m }
  return $kind+'|'+$m
}
function Add-Problem([string]$kind,[string]$msg,[string]$where){
  $key=Norm-Key $kind $msg
  # the game's own crash list repeats what the error hook already saw: not a second problem
  if($kind -eq 'game-crash' -and $script:uniq.ContainsKey($key)){ return }
  $script:raidProblems++
  if($script:uniq.ContainsKey($key)){ $script:uniq[$key]++; $script:dups[$key]=$script:uniq[$key]; return }
  $script:uniq[$key]=1; $script:newUniq++
  $sec=0; if($script:raidSw){ $sec=[int]$script:raidSw.Elapsed.TotalSeconds }
  JsonRec ([ordered]@{ ts=(Stamp); build=$script:ver; runSeed=$Seed; raidNo=$script:raidNo; mode=$script:curMode; raidSeed=$script:curSeed; raidSec=$sec; kind=$kind; msg=$msg; where=$where; last60=@($script:ring.ToArray()) })
}

# ---------------------------------------------------------------- one raid
$POLLX='JSON.stringify(window.__fz.poll())'

# ---------------------------------------------------------------- demo2p: the real 2-player party rig (10-18)
$script:p2Info=''; $script:p2Dead=$false; $script:p2StallAt=-99999.0; $script:scMis=0; $script:scRep=$false
$SCJS='JSON.stringify({m:(ARCADE.mine|0),t:(ARCADE.mate|0),r:(state==="raid"&&G&&G.arcade&&!G.over)?1:0})'
$P1PROBE='(function(){ try{ window.__fz.lastPoll=performance.now(); return JSON.stringify({inn:netInCount(),same:NET.same,arc:ARCADE.on?1:0,raid:(state==="raid"&&G)?1:0,garc:(G&&G.arcade)?1:0,err:NET.err||"",st:NET.status||""}); }catch(e){ return "ERR "+e; } })()'
$P2PROBE='(function(){ try{ window.__fz.lastPoll=performance.now(); return JSON.stringify({inn:netInCount(),same:NET.same,role:NET.role,arc:ARCADE.on?1:0,arole:ARCADE.role,raid:(state==="raid"&&G)?1:0,garc:(G&&G.arcade)?1:0,wantIn:ARCADE.wantIn?1:0,err:NET.err||"",st:NET.status||"",padIx:NET.padIx,padOther:NET.padOther,pads:(navigator.getGamepads?navigator.getGamepads().length:-1),pcalls:(window.__fzpad?window.__fzpad.calls:-1)}); }catch(e){ return "ERR "+e; } })()'
function P2-Probe(){ try{ Pg-Use 'p2'; return [string](Gx $P2PROBE 20000) }catch{ return 'ERR '+$_.Exception.Message }finally{ try{ Pg-Use 'p1' }catch{} } }
function Pad-Press(){ try{ Pg-Use $script:padPage; [void](Gx 'window.__fzpad.press(0,300)' 8000) }catch{}finally{ try{ Pg-Use 'p1' }catch{} } }
function P2-PadLog(){ try{ Pg-Use $script:padPage; return [string](Gx 'window.__fzpad?window.__fzpad.logText():""' 8000) }catch{ return '' }finally{ try{ Pg-Use 'p1' }catch{} } }
# Starts the 2-player demo as the title row does it, then opens player 2 in a window of its own and gets both into one raid.
# Returns a string with "ok":true, or ERR text saying where it stopped (that text is the start problem).
function Start-2P([int]$mapIx,[int]$rseed){
  $script:p2Info=''; $script:p2Dead=$false; $script:p2StallAt=-99999.0; $script:scMis=0; $script:scRep=$false
  if($script:PadJs -eq ''){ return 'ERR tools\fuzz-pad.js is missing' }
  $pair='fz'+$rseed.ToString('x')
  # Two ways the pad reaches player 2, as in a real party: even raid seeds, the player 2 window reads the pad itself; odd raid seeds, Chrome feeds only the window
  # in front (player 1's), which reads the pad and HANDS it over the pair channel (the game's netPadSend / netPadRecv path), and player 2's window sees no pad.
  $padMode='own'; if(($rseed -band 1) -eq 1){ $padMode='fwd' }
  $script:padPage=$(if($padMode -eq 'fwd'){ 'p1' } else { 'p2' })
  $t0=[Diagnostics.Stopwatch]::StartNew()
  # 1. player 1 picks 2 PLAYER ARCADE DEMO (window.open stubbed: a headless page has no click to open a window with; the address is the game's own)
  #    The two localStorage marks removed first are the game's "player 2 is still in a raid in the other window" guard (p2RaidNow, 75 s). A player 2
  #    window closed by this robot mid raid never runs its pagehide cleanup, so the mark of the raid before would refuse the next pick for 75 s
  #    ("p2raid"). No real player 2 window can be open here: every page is closed between raids.
  $js1='(function(){ try{ __topClear(); __runPrep(); CAREER_ON=0; NET.sess="'+$pair+'"; try{ localStorage.removeItem("salvagerun:p2raid"); localStorage.removeItem("salvagerun:p2live"); }catch(_lk){} window.__p2url=""; window.open=function(u){ window.__p2url=String(u); return {closed:false,focus:function(){}}; }; var r=arcadePick(); return JSON.stringify({ok:(r==="opened"&&NET.same==="host"&&!!ARCADE.on&&!!window.__p2url),r:r,url:window.__p2url,pair:NET.pair}); }catch(e){ return "ERR "+e+" "+String(e&&e.stack||"").slice(0,200); } })()'
  $r1=[string](Gx $js1 60000)
  if($r1 -notmatch '"ok":true'){ return 'ERR the 2 player pick: '+$r1 }
  $url=[string](($r1 | ConvertFrom-Json).url)
  # 2. the player 2 window, with its own socket, the hook and the simulated pad
  $ws2=New-WindowPage $url 1280 720
  $script:pgs['p2']=@{ ws=$null; rxTask=$null; rxBuf=(New-Object byte[] 262144); rxMs=(New-Object IO.MemoryStream) }
  try{
    Pg-Use 'p2'
    Ws-Connect $ws2
    Cmd 'Page.enable'
    Cmd 'Emulation.setDeviceMetricsOverride' '{"width":1280,"height":720,"deviceScaleFactor":1,"mobile":false}'
    Cmd 'Emulation.setFocusEmulationEnabled' '{"enabled":true}'
    $ok=$false
    for($i=0;$i -lt 90;$i++){
      try{ if((Ev "typeof window.__gx==='function'&&typeof window.__deploy==='function'") -eq $true){ $ok=$true; break } }catch{}
      Start-Sleep 1
    }
    if(-not $ok){ return 'ERR the player 2 page did not come up in 90 s' }
    Start-Sleep 1
    $r=Gx $script:Hook
    if($r -ne 'installed' -and $r -ne 'already'){ return ('ERR player 2 hook install said: '+$r) }
    $padSeed=[int]($rseed -bxor 1540483477)
    if($padMode -eq 'own'){ $r=Gx ($script:PadJs.Replace('__SEED__',[string]$padSeed)) } else { $r=Gx $script:BlindJs }
    if($r -ne 'installed' -and $r -ne 'already'){ return ('ERR the simulated pad install (player 2 window, '+$padMode+') said: '+$r) }
  }catch{ return 'ERR the player 2 window setup: '+$_.Exception.Message }
  finally{ try{ Pg-Use 'p1' }catch{} }
  if($padMode -eq 'fwd'){
    try{ $r=Gx ($script:PadJs.Replace('__SEED__',[string]$padSeed)) }catch{ $r='threw '+$_.Exception.Message }
    if($r -ne 'installed' -and $r -ne 'already'){ return ('ERR the simulated pad install (player 1 window, fwd) said: '+$r) }
  }
  # 3. the link: the host sees player 2 in (a WebRTC channel over the pair channel) and player 2 is in the arcade
  $linked=$false; $h=''; $p=''
  for($i=0;$i -lt 60;$i++){
    $h=[string](Gx $P1PROBE 20000); $p=P2-Probe
    if($h -match '"inn":[1-9]' -and $p -match '"arc":1'){ $linked=$true; break }
    Start-Sleep -Milliseconds 750
  }
  if(-not $linked){ return ('ERR the two windows did not link in 45 s. host='+$h+' p2='+$p) }
  $tLink=[int]$t0.Elapsed.TotalSeconds
  # 4. player 1 drops in (the sector and seed are fixed so the raid replays); the arcade is then up on the host
  $js3='(function(){ try{ try{ attStop(); }catch(_a){} var ok=arcadeDeploy({role:"host",mapIx:'+$mapIx+',seed:'+$rseed+'}); return JSON.stringify({ok:!!(ok&&G&&G.arcade&&!ARCADE.solo&&NET.on),arc:!!(G&&G.arcade),inn:netInCount()}); }catch(e){ return "ERR "+e+" "+String(e&&e.stack||"").slice(0,200); } })()'
  $r3=[string](Gx $js3 60000)
  if($r3 -notmatch '"ok":true'){ return 'ERR player 1 could not drop in: '+$r3 }
  # 5. player 2 presses A on its pad (and again every 4 s) until it is in the raid
  $joined=$false; $nA=0
  for($i=0;$i -lt 60;$i++){
    if(($i % 5) -eq 1){
      Pad-Press; $nA++
    }
    Start-Sleep -Milliseconds 800
    $h=[string](Gx $P1PROBE 20000); $p=P2-Probe
    if($p -match '"raid":1' -and $p -match '"garc":1'){ $joined=$true; break }
  }
  if(-not $joined){ return ('ERR player 2 did not join the raid in 48 s after '+$nA+' presses of A. host='+$h+' p2='+$p+' padlog='+(P2-PadLog)) }
  $script:p2Info='link '+$tLink+'s join '+[int]$t0.Elapsed.TotalSeconds+'s pad '+$padMode
  $script:raidSw=[Diagnostics.Stopwatch]::StartNew()   # the raid clock for -RaidSec starts when both are in
  return '{"ok":true,"p2":"'+$script:p2Info+'"}'
}
# One poll of the player 2 page: its errors, non-finite numbers and stalls are problems of kind p2:...
function P2-Poll([string]$mode){
  if($script:p2Dead){ return }
  $q=$null; $err=''
  try{ Pg-Use 'p2'; $q=(Ev $POLLX 20000) | ConvertFrom-Json }catch{ $err=$_.Exception.Message }
  finally{ try{ Pg-Use 'p1' }catch{} }
  if($err -ne ''){
    $script:p2Dead=$true
    if($err -like 'CDP timeout*'){ Add-Problem 'p2:hang' ('the player 2 page stopped answering for 10+ s ('+$mode+')') ('padlog='+(P2-PadLog)) }
    else { Add-Problem 'p2:poll' $err '' }
    return
  }
  if($Trace -and ($script:tick % 40) -eq 3){   # -Trace: what the simulated pad is doing to player 2, every 2 s
    $tr=''
    try{ Pg-Use 'p2'; $tr=[string](Gx 'JSON.stringify({pr:window.__fzpad?window.__fzpad.presses:-1,ax:window.__fzpad?window.__fzpad.pad.axes.map(function(v){return Math.round(v*100)/100}):null,x:(G&&G.player)?Math.round(G.player.x):null,y:(G&&G.player)?Math.round(G.player.y):null,hp:(G&&G.player)?Math.round(G.player.hp):null,am:(G&&G.player)?G.player.ammo:null,menu:(pauseOpen?1:0),ents:(G&&G.ents)?G.ents.length:-1,mine:ARCADE.mine,mate:ARCADE.mate,up:(NET.up||[]).length,padFwd:NET.padFwd?1:0})' 8000) }catch{ $tr='ERR '+$_.Exception.Message }finally{ try{ Pg-Use 'p1' }catch{} }
    [IO.File]::AppendAllText(($OutDir+"\fuzz-trace.txt"),("p2 t"+$script:tick+" "+$tr+"`n"),$Enc)
  }
  $pl=''
  foreach($e in @($q.errs)){ if($e){ if($pl -eq ''){ $pl='padlog='+(P2-PadLog) }; Add-Problem ('p2:'+[string]$e.k) ([string]$e.m) (([string]$e.w)+' '+$pl) } }
  $el=0.0; if($script:raidSw){ $el=$script:raidSw.Elapsed.TotalSeconds }
  if($q.raf -gt 5000 -or ($q.raid -eq 1 -and $q.gl -gt 5000)){
    if(($el-$script:p2StallAt) -gt 30){ $script:p2StallAt=$el; Add-Problem 'p2:stall' ('no animation frame for '+[Math]::Max($q.raf,$q.gl)+' ms in the player 2 window ('+$mode+')') ('raf='+$q.raf+' gameloop='+$q.gl) }
  }
  # the team score: the host's own score is what player 2 hears as its mate's, and the other way round; a mismatch that lasts 12 s is a desync
  if(($script:tick % 40) -eq 23 -and -not $script:scRep){
    $sa=$null; $sb=$null
    try{ $sa=(Gx $SCJS 8000) | ConvertFrom-Json }catch{}
    try{ Pg-Use 'p2'; $sb=(Gx $SCJS 8000) | ConvertFrom-Json }catch{}finally{ try{ Pg-Use 'p1' }catch{} }
    if($sa -and $sb -and $sa.r -eq 1 -and $sb.r -eq 1){
      if(($sa.m -ne $sb.t) -or ($sa.t -ne $sb.m)){ $script:scMis++ } else { $script:scMis=0 }
      if($script:scMis -ge 6){ $script:scRep=$true; Add-Problem 'p2:score-desync' ('the two windows disagreed on the score for 12 s: player 1 mine/mate '+$sa.m+'/'+$sa.t+', player 2 mine/mate '+$sb.m+'/'+$sb.t) '' }
    } else { $script:scMis=0 }
  }
  foreach($b in @($q.bad)){ if($b){ Add-Problem 'p2:nan' ('non-finite '+([string]$b -replace '\d+','#')+' in the player 2 window') ('raw='+$b+' x='+$q.x+' y='+$q.y+' hp='+$q.hp) } }
}

function Run-Raid([string]$mode,[int]$rseed,[int]$secs){
  $script:curMode=$mode; $script:curSeed=$rseed; $script:raidProblems=0; $script:newUniq=0
  $script:ring.Clear(); $script:held=(New-Object 'System.Collections.Generic.Dictionary[string,object]'); $script:btns=0; $script:mx=960; $script:my=540; $script:tick=0; $script:lastAct=-1000; $script:nEv=0
  $rng=New-Object System.Random($rseed)
  $mapIx=0; if($script:maps.Count -gt 0){ $mapIx=[int]$script:maps[$rseed % $script:maps.Count] }
  $god=($rng.NextDouble() -lt 0.5)
  $kit='[]'
  if($mode -eq 'career'){
    $pool=@('bandage','medkit','plate','frag','gun_smg','gun_carbine'); $n=2+$rng.Next(0,4); $ks=@()
    for($i=0;$i -lt $n;$i++){ $ks+=("'"+$pool[$rng.Next(0,$pool.Count)]+"'") }
    $kit='['+($ks -join ',')+']'
  }
  $res=[ordered]@{ mode=$mode; seed=$rseed; map=$mapIx; god=[int]$god; sec=0; end=''; ticks=0; events=0; heap=0; score=0; ents=0; travel=0; fires=0; menuPct=0; p2='' }
  $script:raidSw=[Diagnostics.Stopwatch]::StartNew()
  if($mode -eq 'demo1'){ $js='(function(){ try{ __topClear(); __runPrep(); CAREER_ON=0; var r=arcadeSoloPick(); var ok=arcadeDeploy({mapIx:'+$mapIx+',seed:'+$rseed+'}); return JSON.stringify({ok:!!(ok&&G&&G.arcade&&ARCADE.solo),r:r,arc:!!(G&&G.arcade)}); }catch(e){ return "ERR "+e+" "+String(e&&e.stack||"").slice(0,200); } })()' }
  elseif($mode -eq 'demo2'){ $js='(function(){ try{ __topClear(); __runPrep(); CAREER_ON=0; var ok=arcadeDeploy({mapIx:'+$mapIx+',seed:'+$rseed+'}); return JSON.stringify({ok:!!(ok&&G&&G.arcade&&!ARCADE.solo),arc:!!(G&&G.arcade)}); }catch(e){ return "ERR "+e+" "+String(e&&e.stack||"").slice(0,200); } })()' }
  elseif($mode -eq 'demo2p'){ $js='' }
  else { $js='(function(){ try{ __topClear(); __runPrep(); CAREER_ON=1; var r=__deploy({kit:'+$kit+',mapIx:'+$mapIx+',seed:'+$rseed+'}); return JSON.stringify({ok:!!(G&&G.career&&!G.arcade),err:(r&&r.error)||null}); }catch(e){ return "ERR "+e+" "+String(e&&e.stack||"").slice(0,200); } })()' }
  $sr=''
  try{ if($mode -eq 'demo2p'){ $sr=[string](Start-2P $mapIx $rseed) } else { $sr=[string](Gx $js 60000) } }catch{ $sr='ERR '+$_.Exception.Message }
  if($mode -eq 'demo2p'){ $res.p2=$script:p2Info }
  if($sr -notmatch '"ok":true'){
    Add-Problem 'start' ($mode+' raid did not start: '+$sr) ''
    $res.end='nostart'; $res.sec=[int]$script:raidSw.Elapsed.TotalSeconds
    return $res
  }
  $endPhase=$false; $endAt=0.0; $reason=''; $stuckAcc=0.0; $lastX=$null; $lastY=$null; $menuTicks=0; $dragPts=$null; $dragI=0
  $lUntil=0; $rUntil=0; $tx=960; $ty=540; $bagC=@(); $hotC=@(); $baseGb=@(); $baseSet=$false; $stallAt=-99999.0; $stuckRep=$false; $o=$null
  $a=New-Object double[] 24; $next=0; $selfDone=(-not $SelfTest -or $script:selfRan); $noPoll=0; $lastAm=$null; $menuPolls=0; $polls=0
  $dirs=@(@('KeyW'),@('KeyW','KeyD'),@('KeyD'),@('KeyS','KeyD'),@('KeyS'),@('KeyS','KeyA'),@('KeyA'),@('KeyW','KeyA'))
  $taps=@('KeyR','KeyE','KeyX','KeyG','KeyU','KeyH','KeyJ','KeyQ','KeyF','Digit1','Digit2','Digit3','Digit4','Digit5','Digit6','Digit7','Digit8','Digit9')
  $sw=$script:raidSw
  try{
    while($true){
      $script:tick++; $tk=$script:tick
      if(($tk % 20) -eq 0 -and -not $IgnoreFlag -and (Test-Path -LiteralPath $Flag)){ $reason='lightflag'; break }
      $el=$sw.Elapsed.TotalSeconds
      if(-not $endPhase -and $el -ge $secs){
        $endPhase=$true; $endAt=$el+75
        if($o -and $o.clk -eq 1){ [void](Gx '(function(){ try{ if(G&&!G.over&&raidClockOn()) G.timeLeft=Math.min(G.timeLeft,2); }catch(e){} })()') }
        else { $reason='time'; break }
      }
      if($endPhase -and $el -ge $endAt){ Add-Problem 'noend' ('raid still running 75 s after its clock ran out ('+$mode+')') ('tl='+$o.tl+' menu='+$o.menu); $reason='noend'; break }
      if(-not $selfDone -and $tk -ge 40){ $selfDone=$true; $script:selfRan=$true; [void](Ev "setTimeout(function(){ throw new Error('fuzztest') },0)") }
      # ---- releases
      foreach($n in @($script:held.Keys)){
        $h=$script:held[$n]
        if($tk -ge $h.until){ Release $n }
        elseif(($tk-$h.since) -ge 10 -and ($tk % 2) -eq 0 -and -not ($MODK -contains $n)){ KeyEv 'keyDown' $n $true }
      }
      if(($script:btns -band 1) -and $null -eq $dragPts -and $tk -ge $lUntil){ MUp 1 }
      if(($script:btns -band 2) -and $tk -ge $rUntil){ MUp 2 }
      # ---- the dice: 24 draws a tick, always, so a raid seed replays the same inputs
      for($i=0;$i -lt 24;$i++){ $a[$i]=$rng.NextDouble() }
      $menu=0; if($o){ $menu=[int]$o.menu }
      $bagOpen=(($menu -band 8) -ne 0)
      # movement bursts
      $mv=0; foreach($m in $MOVE){ if($script:held.ContainsKey($m)){ $mv++ } }
      if($mv -eq 0 -and $a[0] -lt 0.15){
        $dd=$dirs[[int][Math]::Floor($a[1]*8)]; $hl=6+[int][Math]::Floor($a[2]*30)
        foreach($k in $dd){ Press $k $hl }
      }
      if($a[3] -lt 0.008){ Press 'ShiftLeft' (10+[int][Math]::Floor($a[4]*50)) }
      # fire and aim buttons (not while a drag owns the left button)
      if($null -eq $dragPts){
        if(-not ($script:btns -band 1) -and $a[5] -lt 0.05){ MDown 1; $lUntil=$tk+2+[int][Math]::Floor($a[6]*38) }
      }
      if(-not ($script:btns -band 2) -and $a[7] -lt 0.012){ MDown 2; $rUntil=$tk+10+[int][Math]::Floor($a[8]*50) }
      if($a[9] -lt 0.02){ $w=50+[int][Math]::Floor($a[10]*200); if($a[11] -lt 0.5){ $w=-$w }; Wheel $w }
      # key taps and holds
      if($a[12] -lt 0.03){
        $tn=$taps[[int][Math]::Floor($a[13]*$taps.Count)]; $hl=1+[int][Math]::Floor($a[14]*2)
        if(@('KeyH','KeyE','KeyR') -contains $tn -and $a[15] -lt 0.3){ $hl=8+[int][Math]::Floor($a[14]*32) }
        Press $tn $hl
      }
      if($a[16] -lt 0.012){ Press 'Space' 2 }
      $u=$a[17]
      if($u -lt 0.0015){ Press 'KeyB' 2 }
      elseif($u -lt 0.0025){ Press 'KeyI' 2 }
      elseif($u -lt 0.0033){ Press 'KeyM' 2 }
      elseif($u -lt 0.0039){ Press 'Escape' 2 }
      elseif($u -lt 0.0043){ Press 'KeyP' 2 }
      elseif($u -lt 0.0073){ Press 'AltLeft' (5+[int][Math]::Floor($a[18]*35)) }
      elseif($u -lt 0.0098){ Press 'ControlLeft' 2 }
      elseif($u -lt 0.0123){ Press 'KeyC' 2 }
      elseif($u -lt 0.0138){ MDown 4; MUp 4 }
      elseif($u -lt 0.0143){ Press 'Tab' 2 }
      elseif($u -lt 0.0148){ Press 'Enter' 2 }
      # a menu left open for 5 s is closed, as a player would
      if(($menu -band 15) -ne 0){ $menuTicks++ } else { $menuTicks=0 }
      if($menuTicks -gt 40 -and $a[19] -lt 0.12){ Press 'Escape' 2; $menuTicks=0 }
      # ---- the mouse: a drag when the backpack is open, else aim drift
      if($null -ne $dragPts){
        if($dragI -lt $dragPts.Count){ $pt=$dragPts[$dragI]; MMove ([int]$pt[0]) ([int]$pt[1]); $dragI++ }
        else { MUp 1; $dragPts=$null }
      }
      elseif($bagOpen -and $a[20] -lt 0.08){
        if($bagC.Count -gt 0){ $sp=$bagC[[int][Math]::Floor($a[21]*$bagC.Count)] } else { $sp=@((600+[int]($a[21]*700)),(300+[int]($a[22]*400))) }
        $all=@(); $all+=$bagC; $all+=$hotC
        if($all.Count -gt 0){ $ep=$all[[int][Math]::Floor($a[22]*$all.Count)] } else { $ep=@((400+[int]($a[22]*1100)),(200+[int]($a[21]*600))) }
        MMove ([int]$sp[0]) ([int]$sp[1]); MDown 1
        $n=5+[int][Math]::Floor($a[23]*5); $dragPts=@()
        for($s=1;$s -le $n;$s++){ $dragPts+=,@((([int]$sp[0])+([int]$ep[0]-[int]$sp[0])*$s/$n),(([int]$sp[1])+([int]$ep[1]-[int]$sp[1])*$s/$n)) }
        $dragI=0
      }
      else {
        if($a[20] -lt 0.06){
          if($a[21] -lt 0.75){ $ang=$a[22]*6.2832; $rr=100+$a[23]*400; $tx=960+[Math]::Cos($ang)*$rr; $ty=540+[Math]::Sin($ang)*$rr }
          else { $tx=5+$a[22]*1909; $ty=5+$a[23]*1069 }
        }
        $dx=($tx-$script:mx)*0.3+($a[18]-0.5)*6; $dy=($ty-$script:my)*0.3+($a[19]-0.5)*6
        if([Math]::Abs($dx)+[Math]::Abs($dy) -ge 2){ MMove ([int]($script:mx+$dx)) ([int]($script:my+$dy)) }
      }
      # ---- the player 2 window (demo2p): polled every 10th tick, its problems are kind p2:...
      if($mode -eq 'demo2p' -and ($tk % 10) -eq 3){ P2-Poll $mode }
      # ---- the poll, every 5th tick
      if(($tk % 5) -eq 0){
        try{ $o=(Ev $POLLX 20000) | ConvertFrom-Json }
        catch{
          if($_.Exception.Message -like 'EVAL:*'){ Add-Problem 'poll' $_.Exception.Message ''; $reason='poll'; $script:needReset=$true; break }
          throw
        }
        foreach($e in @($o.errs)){ if($e){ Add-Problem ([string]$e.k) ([string]$e.m) ([string]$e.w) } }
        if($o.heap -gt $res.heap){ $res.heap=[int]$o.heap }
        if($o.ents -gt $res.ents){ $res.ents=[int]$o.ents }
        if($o.raf -gt 5000 -or ($o.raid -eq 1 -and $o.gl -gt 5000)){
          if(($el-$stallAt) -gt 30){ $stallAt=$el; Add-Problem 'stall' ('no animation frame for '+[Math]::Max($o.raf,$o.gl)+' ms ('+$mode+')') ('raf='+$o.raf+' gameloop='+$o.gl) }
        }
        if($o.raid -ne 1 -or $o.over -eq 1 -or ($o.arc -eq 1 -and $o.ae -eq 1)){ $res.score=[int]$o.sc; $reason='ended'; if($endPhase){ $reason='clock-end' }; break }
        $res.score=[int]$o.sc
        $polls++; if(($o.menu -band 15) -ne 0){ $menuPolls++ }
        if($Trace){ [IO.File]::AppendAllText(($OutDir+"/fuzz-trace.txt"),("t"+$tk+" menu="+$o.menu+" x="+$o.x+" y="+$o.y+" hp="+$o.hp+" held="+(($script:held.Keys) -join ",")+" last="+(@($script:ring.ToArray())[-1])+"`n"),$Enc) }
        if($lastAm -ne $null -and $o.am -ne $null -and $o.am -lt $lastAm){ $res.fires++ }
        $lastAm=$o.am; $res.menuPct=[int](100*$menuPolls/$polls)
        # non-finite numbers: the four named fields always, the rest only if they were finite at the raid start
        $bd=@(); foreach($b in @($o.bad)){ if($b){ $bd+=[string]$b } }
        if($baseSet){ foreach($gnm in @($o.gb)){ if($gnm -and -not ($baseGb -contains [string]$gnm)){ $bd+=[string]$gnm } } }
        else { $baseSet=$true; $baseGb=@(); foreach($gnm in @($o.gb)){ if($gnm){ $baseGb+=[string]$gnm } } }
        foreach($b in $bd){ Add-Problem 'nan' ('non-finite '+($b -replace '\d+','#')) ('raw='+$b+' x='+$o.x+' y='+$o.y+' hp='+$o.hp) }
        # stuck: movement keys held, no menu, no action key for 2 s, and the player has not moved
        $moved=$true; if($lastX -ne $null){ $moved=(([Math]::Abs([double]$o.x-$lastX)+[Math]::Abs([double]$o.y-$lastY)) -gt 1.5) }
        if($lastX -ne $null -and $o.x -ne $null){ $stp=[Math]::Abs([double]$o.x-$lastX)+[Math]::Abs([double]$o.y-$lastY); if($stp -lt 400){ $res.travel=[int]($res.travel+$stp) } }
        $lastX=[double]$o.x; $lastY=[double]$o.y
        $mvk=0; foreach($m in $MOVE){ if($script:held.ContainsKey($m)){ $mvk++ } }
        if($o.menu -ne 0 -or $moved -or $o.x -eq $null){ $stuckAcc=0.0 }
        elseif($mvk -gt 0 -and ($tk-$script:lastAct) -gt 40){ $stuckAcc+=0.25 }
        if($stuckAcc -ge 20 -and -not $stuckRep){ $stuckRep=$true; Add-Problem 'stuck' ('player did not move for 20 s with movement keys held ('+$mode+')') ('x='+$o.x+' y='+$o.y+' hp='+$o.hp) }
        if($o.bc){ $bagC=@(); foreach($c in $o.bc){ $bagC+=,@([int]$c[0],[int]$c[1]) } } else { $bagC=@() }
        if($o.hc){ $hotC=@(); foreach($c in $o.hc){ $hotC+=,@([int]$c[0],[int]$c[1]) } } else { $hotC=@() }
        # tough raids: hp topped up below 35, but never in the clock-out phase (the burn must be able to end the raid)
        if($god -and -not $endPhase -and $o.hp -ne $null -and $o.hp -gt 0 -and $o.hp -lt 35 -and $o.dn -ne 1){ [void](Gx '(function(){ try{ var p=G.player; if(isFinite(p.hp)&&p.hp>0&&p.hp<35) p.hp=p.maxhp; }catch(e){} })()') }
      }
      $next+=50
      $d=$next-[int]$sw.ElapsedMilliseconds
      if($d -gt 0){ Start-Sleep -Milliseconds $d }
      elseif($d -lt -200){ $next=[int]$sw.ElapsedMilliseconds }
    }
  }
  catch{
    try{ Pg-Use 'p1' }catch{}   # never stay on the player 2 socket after a failure
    $em=$_.Exception.Message
    if($em -like 'CDP timeout*'){ Add-Problem 'hang' ('the page stopped answering for 10+ s ('+$mode+')') $em; $reason='hang' }
    else { Add-Problem 'cdp' $em ''; $reason='cdp' }
    $script:needReset=$true
  }
  $res.sec=[int]$sw.Elapsed.TotalSeconds; $res.ticks=$script:tick; $res.events=$script:nEv; $res.end=$reason
  if($mode -eq 'demo2p'){ $res.p2=$script:p2Info; if($script:p2Dead){ $res.p2+=' DEAD' } }
  if(-not $script:needReset){
    try{
      Release-All
      $cr=[string](Gx "(function(){ try{ if(G&&!G.over&&state==='raid') endRaid('abandon'); }catch(e){ return 'endRaid threw: '+e+' '+String(e&&e.stack||'').slice(0,240); } try{ __topClear(); }catch(e){ return '__topClear threw: '+e; } return 'ok'; })()" 30000)
      if($cr -ne 'ok'){ Add-Problem 'cleanup' $cr '' }
    }catch{ Add-Problem 'hang' ('cleanup: '+$_.Exception.Message) ''; $script:needReset=$true }
  }
  return $res
}

# ---------------------------------------------------------------- main
$t0=Get-Date; $deadline=$t0.AddMinutes($Minutes); $stopWhy='time'; $raids=0; $totProb=0; $status=0
try{
  Kill-Chrome
  # a hidden watchdog, so a killed fuzz.ps1 (he is back) cannot leave this Chrome burning CPU: it waits for this process, then ends the Chrome
  $wdScript='Wait-Process -Id '+$PID+' -ErrorAction SilentlyContinue; Get-CimInstance Win32_Process -Filter "Name=''chrome.exe''" | Where-Object { $_.CommandLine -match ''remote-debugging-port='+$Port+'(\s|$)'' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }'
  Start-Process -FilePath powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($wdScript))) | Out-Null
  if(-not (Copy-Fixture)){ throw ('could not copy tools\'+$Fixture+' (missing or half written)') }
  $script:srvPort=Pick-Server
  if($script:srvPort -eq 0){
    $script:ownSrv=Start-Process -FilePath powershell.exe -WindowStyle Hidden -PassThru -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "'+$T+'\serve.ps1" -Root "'+$T+'" -Port 8811')
    for($i=0;$i -lt 20;$i++){ Start-Sleep 1; if(Probe-Server 8811){ $script:srvPort=8811; break } }
    if($script:srvPort -eq 0){ throw 'no static server answers and serve.ps1 on 8811 did not start' }
  }
  $prof=$env:TEMP+'\pillagers-cdp'+$Port
  try{ if(Test-Path $prof){ Remove-Item -Recurse -Force $prof -ErrorAction SilentlyContinue } }catch{}
  $so=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($T+'\cdp.ps1') -Start -Port $Port -Profile $prof
  if(($so | Out-String) -notmatch 'browser up'){ throw ('chrome did not start on '+$Port+': '+($so | Out-String)) }
  Open-Page
  LogLine ((Stamp)+' FUZZ START seed='+$Seed+' minutes='+$Minutes+' raidsec='+$RaidSec+' port='+$Port+' srv='+$script:srvPort+' build='+$script:ver+' maps='+($script:maps -join ','))
  $modes=@('demo1','career','demo2'); $master=New-Object System.Random($Seed)
  $others=@('demo1','career'); $script:otherNo=0; $script:p2Off=$false; $script:p2Fails=0; $script:dirty=$false
  while($true){
    if(-not $IgnoreFlag -and (Test-Path -LiteralPath $Flag)){ $stopWhy='light.flag (he is back)'; break }
    $left=($deadline-(Get-Date)).TotalSeconds
    if($Mode -eq '' -and $left -lt 70){ break }
    # 10-21: the smaller of free RAM and free virtual memory (Windows ran out of virtual memory at 02:19 with 4 GB of RAM free; both robots hung)
    $osm=Get-CimInstance Win32_OperatingSystem; $freeGB=[Math]::Min($osm.FreePhysicalMemory,$osm.FreeVirtualMemory)/1MB
    if($freeGB -lt $MinFreeGB){ $stopWhy=('low memory '+[Math]::Round($freeGB,1)+' GB free (RAM or virtual)'); break }
    $script:raidNo++
    $m=$modes[($script:raidNo-1) % 3]; $rs=$master.Next(1,2147483000)
    if($P2Share -gt 0){   # 10-18, his order: 3 of every 4 raids are the real 2-player demo (-P2Share 75); the 4th alternates demo1 and career
      $n=$script:raidNo
      if([Math]::Ceiling($n*$P2Share/100.0) -gt [Math]::Ceiling(($n-1)*$P2Share/100.0)){ if($script:p2Off){ $m='demo2' } else { $m='demo2p' } }
      else { $m=$others[$script:otherNo % 2]; $script:otherNo++ }
    }
    if($Mode -ne ''){ $m=$Mode; $rs=$RaidSeed }
    $secs=$RaidSec; if($Mode -eq '' -and $secs -gt ($left-60)){ $secs=[int]($left-60) }
    if($script:dirty){ $script:dirty=$false; if(-not $script:needReset){ try{ Open-Page }catch{ $script:needReset=$true } } }   # after a 2-window raid: a fresh host page, the player 2 window closed
    if($script:needReset){ Kill-Chrome; Start-Sleep 2; $so=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($T+'\cdp.ps1') -Start -Port $Port -Profile $prof; Open-Page }
    $rres=Run-Raid $m $rs $secs; if($rres -is [array]){ $rres=$rres[-1] }
    $raids++; $totProb+=$script:raidProblems
    if($m -eq 'demo2p'){
      $script:dirty=$true
      if($rres.end -eq 'nostart'){
        $script:p2Fails++
        if($script:p2Fails -ge 3 -and -not $script:p2Off){ $script:p2Off=$true; LogLine ((Stamp)+' FUZZ 2P ROBOTS OFF: three 2-window starts in a row failed, so the 2-player share runs as demo2 (this window as host alone) for the rest of this run') }
      } else { $script:p2Fails=0 }
    }
    LogLine ((Stamp)+' raid '+$script:raidNo+' '+$m+' raidSeed='+$rs+' map='+$rres.map+' god='+$rres.god+' sec='+$rres.sec+' end='+$rres.end+' problems='+$script:raidProblems+' newUnique='+$script:newUniq+' totalUnique='+$script:uniq.Count+' totalProblems='+$totProb+' events='+$rres.events+' score='+$rres.score+' ents='+$rres.ents+' travelPx='+$rres.travel+' fires='+$rres.fires+' menuPct='+$rres.menuPct+' heapMB='+$rres.heap+' p2='+(([string]$rres.p2) -replace '\s','_')+' build='+$script:ver)   # build= stays LAST: tools\stable.mjs counts robot minutes per version with endsWith(' build='+ver)
    if($rres.end -eq 'lightflag'){ $stopWhy='light.flag (he is back)'; break }
    if($Mode -ne ''){ $stopWhy='replay done'; break }
  }
}
catch{
  $stopWhy='ERROR: '+$_.Exception.Message; $status=1
  LogLine ((Stamp)+' FUZZ ERROR '+$_.Exception.Message+' at '+$_.InvocationInfo.ScriptLineNumber)
}
finally{
  try{ if($script:ws){ $script:ws.Dispose() } }catch{}
  Kill-Chrome
  if($script:ownSrv){ try{ Stop-Process -Id $script:ownSrv.Id -Force -ErrorAction SilentlyContinue }catch{} }
  if($script:dups.Count -gt 0){ JsonRec ([ordered]@{ ts=(Stamp); kind='dup-counts'; runSeed=$Seed; counts=$script:dups }) }
  LogLine ((Stamp)+' FUZZ END raids='+$raids+' problems='+$totProb+' unique='+$script:uniq.Count+' reason='+$stopWhy+' minutes='+[Math]::Round(((Get-Date)-$t0).TotalMinutes,1))
}
Write-Output ('fuzz done: raids='+$raids+' problems='+$totProb+' unique='+$script:uniq.Count+' reason='+$stopWhy+' log='+$LogF)
exit $status
