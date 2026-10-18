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

# A DEAD BULWARK LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckbulwark), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Bulwark wreck:
// the shield slab fallen flat with its ochre chevron band and rust trim, the hunched body slumped beside it with its rust plate and a stompy foot, the sensor dome rolled off with a dead eye. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckBulwark(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,34,9,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; rrF(-37,-9,40,17,3);
  wc.fillStyle=P.gm[1]; rrF(-36,-8,38,15,2.4);
  wc.fillStyle=P.gm[0]; wc.fillRect(-36,3,38,3.4);
  wc.fillStyle=P.ox[1]; wc.fillRect(-36,-5,38,1.4); wc.fillRect(-36,.6,38,1.2);
  wc.fillStyle=P.och; rrF(-36,-8,7,15,2.4);
  wc.fillStyle=P.ink; for(i=0;i<3;i++){ mbPoly([-35,-5+i*4.6,-35,-2.6+i*4.6,-30,-5.2+i*4.6,-30,-7.4+i*4.6]); }
  wc.fillStyle=P.ink; rrF(-24,-5,19,3,1.2);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(-16,3.4,1.4,0,6.2832); wc.arc(-8,3.4,1.4,0,6.2832); wc.fill();
  wc.strokeStyle='#050505'; wc.lineWidth=1; wc.beginPath(); wc.moveTo(-12,-8); wc.lineTo(-10,-3); wc.lineTo(-13,1); wc.stroke();
  wc.fillStyle=P.ink; rrF(2,-25,27,22,7);
  wc.fillStyle=P.gm[2]; rrF(3,-24,25,20,6);
  wc.fillStyle=P.gm[3]; rrF(5,-24,21,4,3);
  wc.fillStyle=P.grime; rrF(3,-11,25,6,3);
  wc.fillStyle=P.ox[1]; rrF(5,-19,9,8,1.6);
  if(o){ wc.fillStyle='#0e0b09'; rrF(14,-20,12,12,2.5); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(16,-10); wc.lineTo(19,-15); wc.lineTo(17,-20); wc.moveTo(24,-9); wc.lineTo(22,-13); wc.stroke(); }
  wc.fillStyle=P.ink; rrF(13,-4,12,7,2);
  wc.fillStyle=P.gm[1]; rrF(14,-3,10,5,1.5);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(38,1,8,6,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.ellipse(38,.4,6.8,4.8,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.fillRect(34,-3,8,1.1);
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(40,1,2.2,0,6.2832); wc.fill();
  wc.restore();
  wreckSmoke(ct,24);
}
WRECKDRAW.bulwark=drawWreckBulwark;
function drawContS(ct){
'@

SubRx @'
var VER='29.19';
'@ @'
var VER='29.20';
'@

$pat = "(?m)^  now:'v29\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.20: A dead Bulwark leaves its slab and a smoking wreck. Check 29.20 fails on v29.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
