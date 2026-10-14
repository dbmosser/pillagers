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

# BLOOM RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ACC_NEAR=350, ACC_SPAN=600, ACC_FALL=0.8;
'@ @'
// v26.xx (feel19), HIS ORDER (2026-10-14): "bloom ring ok". THE OUTER RING TELLS THE TRUTH ABOUT YOUR AIM. p.bloom is how loose your aim is right now,
// from -0.3 (crouched and still) through 0 (standing still) to 1.2: walking holds it at 0.45, sprinting or rolling at 0.9, crouched and moving
// at 0.1, held to aim it is 0.4 times those, and every shot adds up to 0.4 more that fades at 0.9 a second. It eases out fast (8 a second) and
// back in slower (4 a second). The cursor's outer rings (the magazine ring, the reload ring and the draw ring) sit BLOOM_PX (14, times the
// screen and crosshair size) further out for every 1.0 of bloom, so the ring widens when you move, sprint or shoot and tightens when you stop
// or crouch, and the crosshair colour and style rows still rule the look. AND IT IS TRUE: the spread of every round you fire is multiplied by
// bloomMul, 1 + BLOOM_SPREAD x bloom (0.35), so a still shot is exactly as accurate as it was, a crouched one is a tenth tighter, a walking
// one a sixth looser and a sprint-and-shoot a third. A balance change, allowed since 2026-10-02. The roll of the spread is the same one draw as
// before, so the seeded stream does not move; live play only (G.sim never ticks it, so the bot raids are untouched).
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
var ACC_NEAR=350, ACC_SPAN=600, ACC_FALL=0.8;
'@

SubRx @'
  if(p.kickT>0){ var _lkd=Math.min(dt,p.kickT); p.kickT-=dt; p.x+=(p.kickVx||0)*_lkd; p.y+=(p.kickVy||0)*_lkd; collide(p,G.map.walls); }   // v26.xx (feel10): the Lance kick
'@ @'
  if(p.kickT>0){ var _lkd=Math.min(dt,p.kickT); p.kickT-=dt; p.x+=(p.kickVx||0)*_lkd; p.y+=(p.kickVy||0)*_lkd; collide(p,G.map.walls); }   // v26.xx (feel10): the Lance kick
  bloomTick(p,dt);   // v26.xx (feel19): how loose the aim is right now
'@

SubRx @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1);
'@ @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1)*(fromPlayer?bloomMul(G.player):1);   // v26.xx (feel19): and it is true, the spread follows the ring
'@

SubRx @'
    if(gunBase(wep.id)==='lance'&&!G.sim) lanceKick(G.player,ang);   // v26.xx (feel10): the Meridian Lance shoves you back a step
'@ @'
    if(gunBase(wep.id)==='lance'&&!G.sim) lanceKick(G.player,ang);   // v26.xx (feel10): the Meridian Lance shoves you back a step
    if(!wep._echo) bloomShot(G.player);   // v26.xx (feel19): every shot loosens the aim a little
'@

SubRx @'
var _mr=gap+len+4*_rz;
'@ @'
var _mr=gap+len+4*_rz+bloomPx(p)*_rz*xhSize();   // v26.xx (feel19): the bloom ring
'@

SubRx @'
_drr=gap+len+4*_wz;
'@ @'
_drr=gap+len+4*_wz+bloomPx(p)*_wz*xhSize();
'@

SubRx @'
var _rlr=gap+len+4*_wz;
'@ @'
var _rlr=gap+len+4*_wz+bloomPx(p)*_wz*xhSize();
'@

SubRx @'
var VER='26.66';
'@ @'
var VER='26.67';
'@

$pat = "(?m)^  now:'v26\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.67: The cursor outer ring widens when you move, sprint or shoot and tightens when you stand or crouch, and your spread follows it. Check 26.67 fails on v26.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
