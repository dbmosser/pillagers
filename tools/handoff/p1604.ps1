$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# PAUSE, SUPERHOT AND THE DEATH SLOW-DOWN IN CO-OP. Multiplayer, tools/multiplayer/plan.md phase 2 rules.

SubRx @'
  if(CFG.superhot&&G.player&&!G.over&&!G.paused){
'@ @'
  if(CFG.superhot&&G.player&&!G.over&&!G.paused&&!netUpShared()){   // v16.04: Superhot is off in a shared co-op raid (one world cannot stop for one player)
'@

SubRx @'
  if(!G.paused&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
'@ @'
  if((!G.paused||netUpShared())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
'@

SubRx @'
    var bdt=dt*0.25;
'@ @'
    var bdt=netUpShared()?dt:dt*0.25;   // v16.04: in a shared co-op raid the slow-down is not put on the world the party is still playing in
'@

SubRx @'
  else if(!G.paused&&!G.over){
'@ @'
  else if((!G.paused||netUpShared())&&!G.over){   // v16.04: in a shared co-op raid pause is an overlay: the world and the clock run on
'@

SubRx @'
      updatePlayer(dt);
'@ @'
      if(G.paused&&netUpShared()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on
      else updatePlayer(dt);
'@

SubRx @'
function netEntsHost(){
'@ @'
// v16.04, MULTIPLAYER: PAUSE, SUPERHOT AND THE DEATH SLOW-DOWN IN CO-OP (tools/multiplayer/plan.md phase 2: Superhot is off, pause
// becomes an overlay, and the death slow-down is local to the dying player). One world is shared by the party, so no one window
// can stop or slow it: in a shared raid (this window on the party seed with someone linked) Superhot never freezes time, the
// pause menu and the tuning console open over a world that keeps running (the raid clock included), and the death beat plays at
// full speed. Paused, his player takes no input: keys, the mouse button and the pad stick are held off for his own step only,
// so bleeding, regen and every timer on him still run. Solo play is untouched: netUpShared is false without a party.
function netUpShared(){ return !!((netEntsHost()||netEntsPeer())&&netInCount()>0); }
function netPausedStep(dt){
  var k=keys, md=(typeof mouse!=='undefined'&&mouse)?mouse.down:false, pm=(typeof PAD!=='undefined'&&PAD)?[PAD.mx,PAD.my]:null;
  keys={}; if(md) mouse.down=false; if(pm){ PAD.mx=0; PAD.my=0; }
  try{ updatePlayer(dt); }
  finally{ keys=k; if(md) mouse.down=md; if(pm){ PAD.mx=pm[0]; PAD.my=pm[1]; } }
}
function netEntsHost(){
'@

SubRx @'
var VER='16.03';
'@ @'
var VER='16.04';
'@

$pat = "(?m)^  now:'v16\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.04: PAUSE, SUPERHOT AND THE DEATH SLOW-DOWN IN CO-OP. Multiplayer, the plan phase 2 rules. In a shared co-op raid Superhot never freezes time, the pause menu opens over a world that keeps running with the raid clock, your player stands still while paused, and the death slow-down does not slow the world the party plays in. Solo play untouched. No number moved. Check 16.04 fails on v16.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
