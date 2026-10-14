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

# LMG SPIN UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function nextGun(){
'@ @'
// v26.xx (feel13), HIS ORDER (2026-10-14): "add lmg spin up". THE SUPPORT MG SPINS UP. Hold the trigger and the barrels wind: nothing fires for the
// first LMG_SPIN_GO of the spin (0.15 s), then the shots come slowly (LMG_SLOW times the gun's own gap, 2.2x) and the gap closes to the gun's own as
// the spin reaches full at LMG_SPIN_T (0.75 s). Let go and it winds down over LMG_SPIN_DOWN (0.6 s), so a short pause keeps most of the speed.
// A rising whirr plays while it winds, and is cut when you let go. The Support MG only; every other gun is untouched. Live play only: G.sim never
// spins (spinMul is 1 and spinGo is true), and nothing here draws from the seeded stream.
var LMG_SPIN_T=0.75, LMG_SPIN_DOWN=0.6, LMG_SPIN_GO=0.2, LMG_SLOW=2.2, LMGSPIN={hum:null};
function lmgUp(p){ return !!(p&&p.wep&&p.wep.mag>0&&!p.hand&&gunBase(p.wep.id)==='lmg'); }
function spinMul(p){
  if(!G||G.sim||!lmgUp(p)) return 1;
  var s=clamp(((p.spin||0)-LMG_SPIN_GO)/(1-LMG_SPIN_GO),0,1);
  return 1+(LMG_SLOW-1)*(1-s);
}
function spinGo(p){ return (!G||G.sim||!lmgUp(p))?true:((p.spin||0)>=LMG_SPIN_GO); }
function lmgWhirrStop(){
  var h=LMGSPIN.hum, a, t;
  LMGSPIN.hum=null;
  if(!h) return;
  try{ a=ac(); t=a?a.currentTime:0; h.g.gain.cancelScheduledValues(t); h.g.gain.setValueAtTime(h.g.gain.value,t); h.g.gain.linearRampToValueAtTime(0.0001,t+0.05); h.o.stop(t+0.07); }catch(e){}
}
function lmgWhirr(){
  var a, out, t, o, f, g;
  if((G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return;
  a=ac(); if(!a) return; out=sndBus('gun'); if(!out) return;
  lmgWhirrStop();
  try{
    t=a.currentTime; o=a.createOscillator(); f=a.createBiquadFilter(); g=a.createGain();
    o.type='sawtooth'; o.frequency.setValueAtTime(70,t); o.frequency.exponentialRampToValueAtTime(260,t+LMG_SPIN_T);
    f.type='lowpass'; f.frequency.value=900; f.Q.value=0.9;
    g.gain.setValueAtTime(0.0001,t); g.gain.linearRampToValueAtTime(0.05,t+LMG_SPIN_T*0.6); g.gain.linearRampToValueAtTime(0.0001,t+LMG_SPIN_T+0.05);
    o.connect(f); f.connect(g); g.connect(out); o.start(t); o.stop(t+LMG_SPIN_T+0.08);
    LMGSPIN.hum={o:o,g:g};
  }catch(e){}
}
function spinTick(p,dt){
  var want, was;
  if(!G||G.sim||!p) return 0;
  if(!lmgUp(p)){ if(p.spin){ p.spin=0; lmgWhirrStop(); } return 0; }
  want=!!(mouse.down&&p.ammo>0&&p.reloading<=0&&!(p.drawT>0)&&p.jam<=0&&!p.downed&&!p.cooking);
  was=p.spin||0;
  p.spin=clamp(was+(want?dt/LMG_SPIN_T:-dt/LMG_SPIN_DOWN),0,1);
  if(want&&was<=0&&p.spin>0) lmgWhirr();
  else if(!want&&LMGSPIN.hum) lmgWhirrStop();
  return p.spin;
}
function nextGun(){
'@

SubRx @'
  activeReloadTick(p);   // v26.xx (feel11): a second R in the sweet spot finishes the reload
'@ @'
  activeReloadTick(p);   // v26.xx (feel11): a second R in the sweet spot finishes the reload
  spinTick(p,dt);   // v26.xx (feel13): the Support MG winds up while the trigger is held
'@

SubRx @'
p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){
'@ @'
p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof*spinMul(p)&&spinGo(p)){   // v26.xx (feel13): the Support MG spins up first
'@

SubRx @'
var VER='26.59';
'@ @'
var VER='26.60';
'@

$pat = "(?m)^  now:'v26\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.60: The Support MG spins up: a short wind, slow first shots, then its full rate. Check 26.60 fails on v26.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
