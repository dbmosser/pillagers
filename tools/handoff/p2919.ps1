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

# A DEAD CRAWLER LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckcrawler), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Crawler wreck:
// the three rust shell segments cracked open, six legs curled up in the air and two snapped off on the ground, the gunmetal sensor head fallen off with three dead eyes and a mandible blade. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckCrawler(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  var SG=[[-10,12,10],[0,13,12],[10,11,10]];
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,28,8,0,0,6.2832); wc.fill();
  wc.lineCap='round'; wc.lineJoin='round';
  var LG=[[-8,-8,-17,-24,-23,-15],[-2,-9,-6,-26,2,-22],[6,-8,12,-25,19,-19]];
  for(i=0;i<3;i++){
    wc.strokeStyle=P.ink; wc.lineWidth=3.8; wc.beginPath(); wc.moveTo(LG[i][0],LG[i][1]); wc.lineTo(LG[i][2],LG[i][3]); wc.lineTo(LG[i][4],LG[i][5]); wc.stroke();
    wc.strokeStyle=P.gm[2]; wc.lineWidth=2.1; wc.stroke();
    wc.fillStyle=P.steel; wc.fillRect(LG[i][2]-.8,LG[i][3]-.8,1.6,1.6);
  }
  wc.strokeStyle=P.ink; wc.lineWidth=3.8; wc.beginPath(); wc.moveTo(-14,-3); wc.lineTo(-25,2); wc.lineTo(-33,6); wc.moveTo(13,-2); wc.lineTo(24,4); wc.stroke();
  wc.strokeStyle=P.gm[1]; wc.lineWidth=2.1; wc.stroke(); wc.lineCap='butt'; wc.lineJoin='miter';
  for(i=0;i<3;i++){
    wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(SG[i][0],-7,SG[i][1]/2+1.2,SG[i][2]/2+1.2,0,0,6.2832); wc.fill();
    wc.fillStyle=P.ox[0]; wc.beginPath(); wc.ellipse(SG[i][0],-7,SG[i][1]/2,SG[i][2]/2,0,0,6.2832); wc.fill();
    wc.fillStyle=P.ox[1]; wc.beginPath(); wc.ellipse(SG[i][0]-.3,-8,SG[i][1]/2-.8,SG[i][2]/2-1.6,0,0,6.2832); wc.fill();
  }
  wc.fillStyle=P.grime; wc.beginPath(); wc.ellipse(0,-3,16,3,0,0,6.2832); wc.fill();
  if(o){ wc.fillStyle='#0e0b09'; wc.beginPath(); wc.ellipse(0,-7,7,4.6,0,0,6.2832); wc.fill(); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-6,-5); wc.lineTo(-3,-9); wc.lineTo(-5,-12); wc.moveTo(7,-4); wc.lineTo(9,-8); wc.lineTo(6,-11); wc.stroke(); }
  wc.fillStyle=P.ink; mbPoly([22,-6,29,-6,32,-2,32,3,22,4]);
  wc.fillStyle=P.gm[1]; mbPoly([23,-5,28,-5,31,-1.6,31,2,23,3]);
  wc.fillStyle=P.gm[2]; wc.fillRect(23,-5,5,1.3);
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(28,-1.5,1.7,0,6.2832); wc.arc(25,-3,1.1,0,6.2832); wc.arc(25.6,.4,1.1,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; mbPoly([28,1,35,1.6,36,3.8,33,3.2,28,3.6]);
  wc.restore();
  wreckSmoke(ct,18);
}
WRECKDRAW.crawler=drawWreckCrawler;
function drawContS(ct){
'@

SubRx @'
var VER='29.18';
'@ @'
var VER='29.19';
'@

$pat = "(?m)^  now:'v29\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.19: A dead Crawler lies on its back, smoking. Check 29.19 fails on v29.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
