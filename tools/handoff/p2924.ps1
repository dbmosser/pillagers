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

# A DEAD CRIER LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckcrier), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Crier wreck:
// the pod cracked on its bent X frame with four dead rotor hubs and still blades, the lamp black, the loudspeaker horn broken off with its ochre ring. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckCrier(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.45)'; wc.beginPath(); wc.ellipse(0,3,22,7,0,0,6.2832); wc.fill();
  wc.lineCap='round';
  wc.strokeStyle=P.ink; wc.lineWidth=3.4; wc.beginPath(); wc.moveTo(-14,-9); wc.lineTo(-3,-4); wc.lineTo(11,-9); wc.moveTo(-10,3); wc.lineTo(-2,-3); wc.lineTo(8,2); wc.stroke();
  wc.strokeStyle=P.gm[0]; wc.lineWidth=1.8; wc.stroke(); wc.lineCap='butt';
  for(i=0;i<4;i++){
    var hx=[-14,11,-10,8][i], hy=[-9,-9,3,2][i];
    wc.fillStyle=P.ink; wc.beginPath(); wc.arc(hx,hy,3,0,6.2832); wc.fill();
    wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(hx,hy,2,0,6.2832); wc.fill();
  }
  wc.strokeStyle=P.steel; wc.lineWidth=.7; wc.beginPath(); wc.moveTo(-20,-12); wc.lineTo(-8,-6); wc.moveTo(13,-14); wc.lineTo(6,-6); wc.stroke();
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(0,-8,10.4,8,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.ellipse(0,-8,9.2,6.8,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.ellipse(-.8,-10,7.4,3.6,0,0,6.2832); wc.fill();
  wc.fillStyle=P.grime; wc.beginPath(); wc.ellipse(0,-4,8.6,2.6,0,0,6.2832); wc.fill();
  if(o){ wc.fillStyle='#0e0b09'; wc.beginPath(); wc.ellipse(1,-8,5.4,4,0,0,6.2832); wc.fill(); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-5,-5); wc.lineTo(-2,-9); wc.lineTo(-4,-12); wc.moveTo(4,-4); wc.lineTo(5,-8); wc.stroke(); }
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(-4,-13,2.6,0,6.2832); wc.fill();
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(-4,-13,1.6,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; mbPoly([14,0,30,-6,30,6,14,4]);
  wc.fillStyle=P.gm[2]; mbPoly([15,.8,29,-4.4,29,4.6,15,3]);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(30,0,3.2,6.6,0,0,6.2832); wc.fill();
  wc.fillStyle=P.och; wc.beginPath(); wc.ellipse(30,0,2,5.2,0,0,6.2832); wc.fill();
  wc.fillStyle='#2a1512'; wc.beginPath(); wc.ellipse(30.4,0,1.1,3.4,0,0,6.2832); wc.fill();
  wc.restore();
  wreckSmoke(ct,22);
}
WRECKDRAW.snitch=drawWreckCrier;
function drawContS(ct){
'@

SubRx @'
var VER='29.23';
'@ @'
var VER='29.24';
'@

$pat = "(?m)^  now:'v29\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.24: A dead Crier lies crashed and smoking. Check 29.24 fails on v29.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
