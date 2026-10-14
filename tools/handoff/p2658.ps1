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

# MACHINES DRAW WHERE THEY ARE ABOUT TO SHOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawWindupGlow(e,gx,gy){
'@ @'
// v26.xx (ai20), HIS YES (2026-10-14, suggestion 20): ATTACK TELEGRAPHS. A machine that winds up a shot used to show only a red glow at its
// muzzle (drawWindupGlow) and the charge sound; where the shot would go was a guess. Now a Sentry or a Warden (THE OVERSEER is a Warden)
// in its windup paints an AIM LANE on the ground: a thin red line from the machine out to where the round would stop (its reach, or the
// first wall), with a narrow lane that FILLS outward from the machine over the windup, so the last of the windup is the lane full and bright.
// The windup length, the cooldown and the damage are untouched; the lane only reads e.windup, which a linked window already receives.
// It aims at the local player when he stands in the machine reach on roughly the side it faces, else along its facing. Drawn only for a
// machine the player can see (the same rule as the scan cones). No random numbers: nothing for the seeded stream or the cosmetic stream.
function telegraphLane(e){
  var tot, f, a, ux, uy, reach, t, p, d;
  if(!e||!(e.hp>0)||e.windup===undefined||e.windup===null) return null;
  if(e.kind==='sentry') tot=0.4; else if(e.kind==='warden') tot=0.7; else return null;
  if(!(e.rng>0)||!isFinite(e.face)||!isFinite(e.x)||!isFinite(e.y)) return null;
  f=clamp(1-e.windup/tot,0,1);
  a=e.face; reach=e.rng*1.15;
  p=(typeof G!=='undefined'&&G)?G.player:null;
  if(p&&!p.downed&&isFinite(p.x)&&isFinite(p.y)){
    d=Math.sqrt((p.x-e.x)*(p.x-e.x)+(p.y-e.y)*(p.y-e.y));
    if(d<reach&&Math.abs(angDiff(Math.atan2(p.y-e.y,p.x-e.x),e.face))<1.2) a=Math.atan2(p.y-e.y,p.x-e.x);
  }
  ux=Math.cos(a); uy=Math.sin(a);
  try{ t=rayHitG(e.x,e.y,ux,uy,reach); }catch(_tl){ t=reach; }
  if(!(t>0)) return null;
  t=Math.min(t,reach);
  return {x1:e.x+ux*e.r*0.7,y1:e.y+uy*e.r*0.7,x2:e.x+ux*t,y2:e.y+uy*t,ux:ux,uy:uy,len:t,f:f,w:(e.kind==='warden')?(e.boss?12:8):4};
}
function drawWindupGlow(e,gx,gy){
'@

SubRx @'
// noise pings. v4.05: drawn AFTER the darkness now, see below; this pass
'@ @'
  // v26.xx (ai20): the aim lane of a Sentry or Warden in its windup, on the ground under the bodies (telegraphLane above).
  for(i=0;i<G.ents.length;i++){
    var _tle=G.ents[i];
    if(!_tle.seen) continue;
    var _tn=telegraphLane(_tle); if(!_tn) continue;
    if(Math.max(_tn.x1,_tn.x2)<ox||Math.min(_tn.x1,_tn.x2)>ox+VW||Math.max(_tn.y1,_tn.y2)<oy||Math.min(_tn.y1,_tn.y2)>oy+VH) continue;
    var _tnx=-_tn.uy*_tn.w, _tny=_tn.ux*_tn.w, _tfl=Math.max(0,(_tn.len-_tle.r*0.7)*_tn.f), _tex=_tn.x1+_tn.ux*_tfl, _tey=_tn.y1+_tn.uy*_tfl;
    wc.save();
    wc.fillStyle='rgba(255,36,28,'+(0.07+0.15*_tn.f).toFixed(3)+')';
    wc.beginPath(); wc.moveTo(_tn.x1+_tnx,_tn.y1+_tny); wc.lineTo(_tex+_tnx,_tey+_tny); wc.lineTo(_tex-_tnx,_tey-_tny); wc.lineTo(_tn.x1-_tnx,_tn.y1-_tny); wc.closePath(); wc.fill();
    wc.strokeStyle='rgba(255,36,28,'+(0.25+0.6*_tn.f).toFixed(3)+')'; wc.lineWidth=1+1.2*_tn.f;
    wc.beginPath(); wc.moveTo(_tn.x1,_tn.y1); wc.lineTo(_tn.x2,_tn.y2); wc.stroke();
    wc.beginPath(); wc.arc(_tn.x2,_tn.y2,2+3*_tn.f,0,6.2832); wc.stroke();
    wc.restore();
  }
// noise pings. v4.05: drawn AFTER the darkness now, see below; this pass
'@

SubRx @'
    wc.strokeStyle='rgba(255,90,60,'+(0.25+0.45*_sf).toFixed(3)+')';
'@ @'
    // v26.xx (ai20): the landing circle FILLS as the shell comes down, and its full size is marked faintly from the first frame.
    wc.fillStyle='rgba(255,70,40,'+(0.04+0.12*_sf).toFixed(3)+')';
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf*0.6,0,0,6.2832); wc.fill();
    wc.strokeStyle='rgba(255,90,60,.14)'; wc.lineWidth=1;
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3,RR3*0.6,0,0,6.2832); wc.stroke();
    wc.strokeStyle='rgba(255,90,60,'+(0.25+0.45*_sf).toFixed(3)+')';
'@

SubRx @'
var VER='26.57';
'@ @'
var VER='26.58';
'@

$pat = "(?m)^  now:'v26\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.58: A Sentry or Warden about to shoot now paints a red aim lane on the ground, and a Howler shell fills its landing circle. Check 26.58 fails on v26.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
