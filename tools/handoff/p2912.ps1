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

# A DEAD WARDEN LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cw.cache=1; cw.time=2.0; cw.tag='WARDEN WRECK'; G.containers.push(cw);
'@ @'
cw.cache=1; cw.time=2.0; cw.tag='WARDEN WRECK'; G.containers.push(cw); cw.bot='warden'; cw.ov=(e.boss||e.name===BOSS_NAME)?1:0;   // v28.xx (cw-wreckwarden), HIS NOTE (2026-10-18): "Warden wreck drops a box. it would be cool if it showed wreckage instead". The cache is tagged a Warden wreck and drawn by drawWreckWarden, not the purple box
'@

SubRx @'
if(ct.type==='botwreck'){
'@ @'
if(ct.bot&&WRECKDRAW[ct.bot]){
    WRECKDRAW[ct.bot](ct);   // v28.xx (cw-wreckwarden), HIS NOTE (2026-10-18): a dead enemy's loot looks like what died: each machine kind registers its own wreck in WRECKDRAW
  } else if(ct.type==='botwreck'){
'@

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckwarden), HIS NOTE (2026-10-18): "Warden wreck drops a box. it would be cool if it showed wreckage instead. same for other enemy
// deaths." A dead enemy's loot has to look like what died. WRECKDRAW maps a container's bot kind to the function that draws that machine's
// wreck; drawContS calls it ahead of the old generic botwreck. Looting is untouched: the container keeps its type, loot and time, only the look
// changes. Every wreck is a pure function of the container (grit(x,y) is the positional hash, no random stream, no per-frame dice).
var WRECKDRAW={};
// Smoke curling off a wreck until it is searched: three grey puffs rising on the raid clock, phase from the position. Drawn after the wreck.
function wreckSmoke(ct,h){
  if(ct.opened||!G) return;
  var ph=grit(ct.x+3,ct.y+5)*6.2832, k, t;
  wc.fillStyle='#2a2623';
  for(k=0;k<3;k++){
    t=(G.t*.32+k/3+ph)%1;
    wc.globalAlpha=.36*(1-t);
    wc.beginPath(); wc.arc(ct.x+Math.sin(t*5+ph+k)*3.2,ct.y-h-t*17,2.2+t*3.8,0,6.2832); wc.fill();
  }
  wc.globalAlpha=1;
}
// The Warden wreck, in the Warden palette (the Overseer wreck in the Overseer black and brass at its bigger scale): tracks with one slipped off,
// a slumped chassis, the hunched torso toppled low with a dead visor, the cannon fallen out on the ground, the shoulder pod torn off, a bent
// exhaust stack. Unsearched it shows ember cracks and smokes; searched, the torso panel is open on a black cavity and the smoke is gone.
function drawWreckWarden(ct){
  var P=ct.ov?MBPAL_OV:MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, s=ct.ov?1.45:1;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl*s,s);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,2,31,9,0,0,6.2832); wc.fill();
  wc.strokeStyle=P.ink; wc.lineWidth=5; wc.lineCap='round'; wc.beginPath(); wc.moveTo(-20,-3); wc.lineTo(-27,2); wc.lineTo(-33,1); wc.stroke();
  wc.strokeStyle=P.rub; wc.lineWidth=3; wc.stroke(); wc.lineCap='butt';
  wc.fillStyle=P.ink; rrF(-22,-10,41,11,5);
  wc.fillStyle=P.rub; rrF(-20.8,-8.8,38.6,8.6,4);
  wc.fillStyle=P.tooth; wc.fillRect(-17,-8.8,2.2,1.5); wc.fillRect(-9,-8.8,2.2,1.5); wc.fillRect(-1,-8.8,2.2,1.5); wc.fillRect(7,-8.8,2.2,1.5);
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(-12,-4.6,3.4,0,6.2832); wc.moveTo(8.4,-4.6); wc.arc(5,-4.6,3.4,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(-12,-4.6,1.5,0,6.2832); wc.moveTo(6.5,-4.6); wc.arc(5,-4.6,1.5,0,6.2832); wc.fill();
  wc.save(); wc.rotate(-.07);
  wc.fillStyle=P.ink; mbPoly([-19,-8,19,-8,16,-17,-16,-17]);
  wc.fillStyle=P.gm[1]; mbPoly([-17.8,-9,17.8,-9,15.2,-16,-15.2,-16]);
  wc.fillStyle=P.ox[1]; wc.fillRect(-17.8,-10.6,35.6,2.2);
  wc.fillStyle=P.och; mbPoly([-13,-10.6,-10.6,-10.6,-12,-8.4,-14.4,-8.4]);
  wc.fillStyle=P.ink; mbPoly([-16,-15,-16,-25,-10,-32,3,-33,12,-29,16,-21,15,-15]);
  wc.fillStyle=P.gm[2]; mbPoly([-14.8,-16,-14.8,-24.6,-9.4,-31,3,-32,11.2,-28.2,14.8,-21,13.8,-16]);
  wc.fillStyle=P.gm[3]; mbPoly([-9.4,-31,3,-32,11.2,-28.2,9,-26.6,-8,-27.2]);
  wc.fillStyle=P.gm[1]; mbPoly([11.2,-28.2,14.8,-21,13.8,-16,10.6,-16,12,-21.4,9,-26.6]);
  wc.fillStyle='rgba(10,8,6,.5)'; mbPoly([-14.8,-16,-14.8,-24.6,-9.4,-31,-3,-31.6,-5,-16]);
  wc.fillStyle=P.ink; rrF(2.4,-30,11,5,1.8);
  wc.fillStyle='#2a1512'; wc.fillRect(3.4,-29,9,2.6);
  if(o){
    wc.fillStyle=P.ink; rrF(-11,-25,15,9.6,2);
    wc.fillStyle='#0e0b09'; rrF(-10,-24,13,7.6,1.6);
    wc.fillStyle=P.ox[1]; mbPoly([-12,-26,-4,-29,-2,-25.6,-10.4,-24]);
  } else {
    wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-9,-17); wc.lineTo(-6,-21); wc.lineTo(-8,-24); wc.lineTo(-4,-27);
    wc.moveTo(1,-17); wc.lineTo(3,-21.6); wc.lineTo(7,-23); wc.stroke();
  }
  wc.restore();
  wc.fillStyle=P.ink; rrF(13,-6.4,22,6.6,2); rrF(32,-7.6,6.4,9,1.6);
  wc.fillStyle=P.gm[1]; wc.fillRect(14,-5.4,16,4.2);
  wc.fillStyle=P.steel; wc.fillRect(14,-5.4,16,1);
  wc.fillStyle=P.gm[0]; wc.fillRect(33,-6.6,4.4,7);
  wc.fillStyle=P.ink; rrF(-31,-9,12,9.6,2.2);
  wc.fillStyle=P.gm[1]; rrF(-29.8,-7.8,9.6,7.2,1.6);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(-27.2,-4.2,1.5,0,6.2832); wc.moveTo(-21.6,-4.2); wc.arc(-23,-4.2,1.5,0,6.2832); wc.fill();
  wc.strokeStyle=P.ink; wc.lineWidth=4.4; wc.lineCap='round'; wc.beginPath(); wc.moveTo(-9,-30); wc.lineTo(-12,-39); wc.lineTo(-8,-45); wc.stroke();
  wc.strokeStyle=P.gm[1]; wc.lineWidth=2.4; wc.stroke(); wc.lineCap='butt';
  wc.restore();
  wreckSmoke(ct,28*s);
}
WRECKDRAW.warden=drawWreckWarden;
function drawContS(ct){
'@

SubRx @'
var VER='29.11';
'@ @'
var VER='29.12';
'@

$pat = "(?m)^  now:'v29\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.12: A dead Warden leaves a smoking wreck, not a box. Check 29.12 fails on v29.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
