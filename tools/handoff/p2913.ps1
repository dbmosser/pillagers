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

# A DEAD PILLBOX LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cq.cache=1; cq.time=2.4; cq.tag='PILLBOX WRECK'; G.containers.push(cq);
'@ @'
cq.cache=1; cq.time=2.4; cq.tag='PILLBOX WRECK'; G.containers.push(cq); cq.bot='choir';   // v28.xx (cw-wreckpillbox), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths". The Pillbox wreck is drawn by drawWreckChoir, not the purple box
'@

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckpillbox), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Pillbox wreck:
// the bolted plinth cracked with its sandbag lumps, the drum burst and squashed low with its rust band, the dead port, three brass pipes bent over
// and two lying on the ground. Same palette as the live Pillbox (MBPAL). Unsearched it shows ember cracks and smokes; searched the drum is an open
// black cavity. A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckChoir(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i, B=[[-9,-21,-3,9],[3,-22,4,11],[12,-19,-5,7]];
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,35,10,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; rrF(-26,-8,52,12,4);
  wc.fillStyle=P.gm[1]; rrF(-25,-7,50,10,3);
  wc.fillStyle=P.gm[2]; wc.fillRect(-24,-7,48,2);
  wc.fillStyle=P.grime; wc.fillRect(-24,0,48,3);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(-22,1.5,5.6,4,0,0,6.2832); wc.moveTo(27.6,1.5); wc.ellipse(22,1.5,5.6,4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[0]; wc.beginPath(); wc.ellipse(-22,1.5,4.6,3,0,0,6.2832); wc.moveTo(26.6,1.5); wc.ellipse(22,1.5,4.6,3,0,0,6.2832); wc.fill();
  wc.strokeStyle=P.ink; wc.lineWidth=1.3; wc.beginPath(); wc.moveTo(-7,-7); wc.lineTo(-3,-3); wc.lineTo(-8,1); wc.stroke();
  wc.fillStyle=P.ink; rrF(-18,-23,36,17,6);
  wc.fillStyle=P.gm[1]; rrF(-17,-22,34,15,5);
  wc.fillStyle=P.gm[2]; rrF(-17,-22,27,9,5);
  wc.fillStyle=P.ox[1]; wc.fillRect(-17,-13,34,4);
  wc.fillStyle=P.grime; rrF(-17,-9,34,3,2);
  wc.fillStyle='#0e0b09'; mbPoly([-13,-22,-7,-26,-3,-21,3,-27,9,-21,13,-24,15,-20,-15,-19]);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(9,-12,6.4,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(9,-12,5.2,0,6.2832); wc.fill();
  wc.fillStyle='#2a1512'; wc.beginPath(); wc.arc(9,-12,2.4,0,6.2832); wc.fill();
  if(o){ wc.fillStyle='#0e0b09'; rrF(-12,-19,17,9,2); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-12,-8); wc.lineTo(-9,-12); wc.lineTo(-11,-16); wc.moveTo(0,-9); wc.lineTo(2,-13); wc.lineTo(-1,-17); wc.stroke(); }
  wc.lineCap='round';
  for(i=0;i<3;i++){
    wc.strokeStyle=P.ink; wc.lineWidth=6; wc.beginPath(); wc.moveTo(B[i][0],B[i][1]); wc.lineTo(B[i][0]+B[i][2],B[i][1]-B[i][3]); wc.stroke();
    wc.strokeStyle=P.brass[0]; wc.lineWidth=3.8; wc.stroke();
    wc.strokeStyle=P.brass[1]; wc.lineWidth=1.1; wc.beginPath(); wc.moveTo(B[i][0]-1,B[i][1]); wc.lineTo(B[i][0]+B[i][2]-1,B[i][1]-B[i][3]); wc.stroke();
  }
  wc.strokeStyle=P.ink; wc.lineWidth=6; wc.beginPath(); wc.moveTo(14,7); wc.lineTo(31,10); wc.moveTo(-36,8); wc.lineTo(-22,5); wc.stroke();
  wc.strokeStyle=P.brass[0]; wc.lineWidth=3.8; wc.stroke(); wc.lineCap='butt';
  wc.restore();
  wreckSmoke(ct,22);
}
WRECKDRAW.choir=drawWreckChoir;
function drawContS(ct){
'@

SubRx @'
var VER='29.12';
'@ @'
var VER='29.13';
'@

$pat = "(?m)^  now:'v29\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.13: A dead Pillbox leaves a smoking wreck, not a box. Check 29.13 fails on v29.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
