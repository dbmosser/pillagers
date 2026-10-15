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

# HALO REACH BLOOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BLOOM_PX=14, BLOOM_SPREAD=0.35;
function bloomTick(p,dt){
  var sp, base, tgt, b0;
  if(!G||G.sim||!p) return 0;
  if(!isFinite(dt)||dt<=0) return p.bloom||0;
  sp=(p.blmX===undefined)?0:Math.min(400,Math.sqrt((p.x-p.blmX)*(p.x-p.blmX)+(p.y-p.blmY)*(p.y-p.blmY))/dt);
  p.blmX=p.x; p.blmY=p.y;
  base=(sp<12)?0:((G.sprinting||p.roll>0)?0.9:0.45);
  if(G.pCrouch) base=(sp<12)?-0.3:0.1;
  if(p.ads) base*=0.4;
  p.bloomK=Math.max(0,(p.bloomK||0)-dt*0.9);
  tgt=base+p.bloomK; b0=p.bloom||0;
  p.bloom=b0+(tgt-b0)*Math.min(1,dt*((tgt>b0)?8:4));
  return p.bloom;
}
function bloomShot(p){ if(G&&!G.sim&&p) p.bloomK=Math.min(0.4,(p.bloomK||0)+0.1); }
function bloomMul(p){ return (G&&!G.sim&&p)?(1+BLOOM_SPREAD*Math.max(-0.3,Math.min(1.2,p.bloom||0))):1; }
function bloomPx(p){ return Math.max(-0.3,Math.min(1.2,(p&&p.bloom)||0))*BLOOM_PX; }
'@ @'
var BLOOM_PX=14, BLOOM_SPREAD=0.35;
// v27.xx (feel2a), HIS YES (2026-10-14): "keep -- research halo reach dmr to see some interesting spread/bloom techniques (realize its Fps tho)". HALO REACH BLOOM, ADAPTED
// TO THE TOP-DOWN RING. In Reach every shot opens the reticle a little, the reticle closes again over a short recovery, the next round lands at random inside the
// reticle as it is NOW, so a fully closed reticle is a pinpoint shot and a player who spams widens the spread: skilled players PACE their shots, and the reticle size is
// the honest readout. Here the same idea sits on the ring on the cursor (v26.67). Every gun has its own SHOT BLOOM in BLM: add is how far one round opens it (1.0 is
// full), rec is how fast it closes again (per second) once dly seconds have passed with no round, and cone is the extra half-angle in radians a full bloom adds to the
// gun's own spread. The semi-autos (pistol, Magnum, Marksman Rifle, Longshot, Burst Carbine, Riot Scattergun, Whisper, Lance) open wide on one round and close in a
// second or so, set so that the fastest trigger finger leaves a little bloom while a beat of patience gives the pinpoint round back; the autos (SMG, Auto Rifle, Support MG)
// open a hair per round and fill over about two seconds of held fire, which is what a burst is for. BLM_UNITS of that bloom (1.3) also drives the ring and the old
// movement bloom's own spread multiplier, so the ring still tells the truth. A round is counted when it leaves and applied on the next step (bloomPend), so the round
// that opens the bloom is not the round it hurts. Live play only: G.sim never ticks it (the cone is 0), and nothing here draws from the seeded stream.
var BLM={
  pistol: {add:0.45,rec:1.30,dly:0.10,cone:0.050},
  magnum: {add:0.70,rec:1.00,dly:0.15,cone:0.040},
  dmr:    {add:0.70,rec:0.95,dly:0.15,cone:0.035},
  sniper: {add:1.00,rec:0.70,dly:0.20,cone:0.025},
  carbine:{add:0.55,rec:1.00,dly:0.15,cone:0.040},
  shotgun:{add:0.50,rec:0.90,dly:0.20,cone:0.030},
  whisper:{add:0.40,rec:1.10,dly:0.10,cone:0.040},
  lance:  {add:0.60,rec:0.90,dly:0.20,cone:0.025},
  smg:    {add:0.040,rec:0.60,dly:0.25,cone:0.030},
  rifle:  {add:0.060,rec:0.80,dly:0.20,cone:0.040},
  lmg:    {add:0.035,rec:0.55,dly:0.30,cone:0.040}
};
var BLM_UNITS=1.3;
function blmOf(w){ return (w&&w.id&&BLM[gunBase(w.id)])||null; }
function bloomTick(p,dt){
  var sp, base, tgt, b0, t;
  if(!G||G.sim||!p) return 0;
  if(!isFinite(dt)||dt<=0) return p.bloom||0;
  sp=(p.blmX===undefined)?0:Math.min(400,Math.sqrt((p.x-p.blmX)*(p.x-p.blmX)+(p.y-p.blmY)*(p.y-p.blmY))/dt);
  p.blmX=p.x; p.blmY=p.y;
  base=(sp<12)?0:((G.sprinting||p.roll>0)?0.9:0.45);
  if(G.pCrouch) base=(sp<12)?-0.3:0.1;
  if(p.ads) base*=0.4;
  t=blmOf(p.wep)||BLM.pistol;
  if(p.bloomPend>0){ p.bloomK=Math.min(1,(p.bloomK||0)+p.bloomPend); p.bloomPend=0; p.bloomQ=0; }   // the rounds since the last step open the bloom
  p.bloomQ=((p.bloomQ===undefined)?9:p.bloomQ)+dt;
  if(p.bloomQ>t.dly) p.bloomK=Math.max(0,(p.bloomK||0)-dt*t.rec);   // and it closes again once the gun has been quiet for dly
  tgt=base+BLM_UNITS*(p.bloomK||0); b0=p.bloom||0;
  p.bloom=b0+(tgt-b0)*Math.min(1,dt*((tgt>b0)?8:4));
  return p.bloom;
}
function bloomShot(p,w){
  var t;
  if(!G||G.sim||!p) return;
  t=blmOf(w||p.wep); if(!t) return;
  p.bloomPend=Math.min(2,(p.bloomPend||0)+t.add);
}
function bloomCone(p,w){
  var t;
  if(!G||G.sim||!p) return 0;
  t=blmOf(w); if(!t) return 0;
  return t.cone*Math.max(0,Math.min(1,p.bloomK||0))*(p.ads?0.5:1);
}
function bloomMul(p){ return (G&&!G.sim&&p)?(1+BLOOM_SPREAD*Math.max(-0.3,Math.min(2.0,p.bloom||0))):1; }
function bloomPx(p){ return Math.max(-0.3,Math.min(2.0,(p&&p.bloom)||0))*BLOOM_PX; }
'@

SubRx @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1)*(fromPlayer?bloomMul(G.player):1);   // v26.xx (feel19): and it is true, the spread follows the ring
'@ @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1)*(fromPlayer?bloomMul(G.player):1)+(fromPlayer?bloomCone(G.player,wep):0);   // v26.xx (feel19): and it is true, the spread follows the ring
'@

SubRx @'
    if(!wep._echo) bloomShot(G.player);   // v26.xx (feel19): every shot loosens the aim a little
'@ @'
    if(!wep._echo) bloomShot(G.player,wep);   // v27.xx (feel2a): every round opens the bloom of its own gun
'@

SubRx @'
var VER='27.78';
'@ @'
var VER='27.79';
'@

$pat = "(?m)^  now:'v27\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.79: Every gun blooms its own way: spam a semi-auto and the spread opens, pace your shots and the pinpoint round comes back. Check 27.79 fails on v27.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
