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

# A DEAD PEDDLER LEAVES HIS REMAINS, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckpeddler), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Peddler wreck:
// the trader fallen in his leather duster with the wide hat knocked off, his pack frame and bedroll toppled beside him, a satchel, the stock spilled, the lantern knocked out. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckPeddler(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.45)'; wc.beginPath(); wc.ellipse(0,3,38,9,0,0,6.2832); wc.fill();
  wc.fillStyle=INK; wc.fillRect(-42,-7,32,4); wc.fillRect(-42,-1,32,4); wc.fillRect(-26,-8,3.4,13);
  wc.fillStyle='#6a4e32'; wc.fillRect(-41,-6,30,2.2); wc.fillRect(-41,0,30,2.2); wc.fillRect(-25.4,-7,2.2,11);
  wc.fillStyle='#8a6a46'; wc.fillRect(-41,-6,30,.8);
  wc.fillStyle=INK; rrF(-47,-11,10,14,4); wc.fillStyle='#7a6a4a'; rrF(-46,-10,8,12,3.4); wc.fillStyle='#5a4a30'; wc.fillRect(-46,-5,8,1.2);
  wc.fillStyle=INK; wc.beginPath(); wc.arc(-20,-10,4.1,0,6.2832); wc.fill(); wc.fillStyle='#3e454c'; wc.beginPath(); wc.arc(-20,-10,3.3,0,6.2832); wc.fill();
  wc.fillStyle='#7c868f'; wc.fillRect(-22,-12,3.2,1);
  wc.fillStyle=INK; rrF(-6,-12,32,15,6);
  wc.fillStyle='#5a4530'; rrF(-5,-11,30,13,5);
  wc.fillStyle='#7a5f40'; rrF(-5,-11,30,4,3);
  wc.fillStyle='#3a2c1e'; wc.fillRect(-5,-3,30,1.6);
  wc.fillStyle=INK; rrF(24,-7,10,5,2); rrF(24,-1,10,5,2);
  wc.fillStyle='#2a1c12'; rrF(25,-6,8,3,1.4); rrF(25,0,8,3,1.4);
  wc.fillStyle=INK; wc.beginPath(); wc.arc(-9,-4,5.4,0,6.2832); wc.fill();
  wc.fillStyle='#d2a77e'; wc.beginPath(); wc.arc(-9,-4,4.4,0,6.2832); wc.fill();
  wc.fillStyle='#8a6a46'; wc.fillRect(-12,-7,6,1.6);
  wc.fillStyle=INK; wc.beginPath(); wc.ellipse(-15,5,11,4.4,-.15,0,6.2832); wc.fill();
  wc.fillStyle='#55654a'; wc.beginPath(); wc.ellipse(-15,4.6,9.8,3.4,-.15,0,6.2832); wc.fill();
  wc.fillStyle='#71836a'; wc.fillRect(-21,3,9,1);
  wc.fillStyle=INK; rrF(4,-10,12,8,2);
  if(o){ wc.fillStyle='#0e0b09'; rrF(5,-9,10,6,1.6); }
  else { wc.fillStyle='#3a2c1e'; rrF(5,-9,10,6,1.6); wc.fillStyle='#c9a24a'; wc.fillRect(9.4,-7,1.8,2.4); }
  wc.fillStyle=INK; rrF(4.6,6,11,8,3); wc.fillStyle='#c9b458'; rrF(5.4,6.8,9.4,6.4,2.4); wc.fillStyle='rgba(255,255,255,.28)'; wc.fillRect(6.6,7.2,6,1);
  wc.fillStyle=INK; rrF(20,7,8,9,1.6); wc.fillStyle='#8a8f98'; wc.fillRect(20.8,7.8,6.4,7.4); wc.fillStyle='rgba(0,0,0,.3)'; wc.fillRect(20.8,12,6.4,1);
  wc.fillStyle=INK; wc.fillRect(35,2,8,6); wc.fillStyle='#a8742a'; wc.fillRect(36,3,6,4); wc.fillStyle='#d8651f'; wc.fillRect(38,4.4,2,1.6);
  wc.restore();
  wreckSmoke(ct,10);
}
WRECKDRAW.peddler=drawWreckPeddler;
function drawContS(ct){
'@

SubRx @'
cpd.cache=1; cpd.time=1.4; cpd.tag='PEDDLER STOCK'; G.containers.push(cpd);
'@ @'
cpd.cache=1; cpd.time=1.4; cpd.tag='PEDDLER STOCK'; G.containers.push(cpd); cpd.bot='peddler';   // v28.xx (cw-wreckpeddler), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths". The Peddler remains are drawn by drawWreckPeddler, not the purple box
'@

SubRx @'
var VER='29.24';
'@ @'
var VER='29.25';
'@

$pat = "(?m)^  now:'v29\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.25: A dead Peddler leaves his pack and spilled stock. Check 29.25 fails on v29.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
