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

# A DEAD LISTENER LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cl2.time=1.3; G.containers.push(cl2);
'@ @'
cl2.time=1.3; G.containers.push(cl2); cl2.bot='listener';   // v28.xx (cw-wrecklistener), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths". The Listener cache is drawn by drawWreckListener, not the purple box
'@

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wrecklistener), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Listener wreck:
// the tall thin machine fallen on its side in its own slate colours, the long arms sprawled, the legs bent, the dish torn off and lying beside it
// with its red eye dead. Unsearched it smokes from the dish; searched the torso panel is open on a black cavity. grit(x,y) gives the facing.
function drawWreckListener(ct){
  var fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, bd='#3b4250', ed='#5d6878';
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,2,24,7,0,0,6.2832); wc.fill();
  wc.lineCap='round';
  wc.strokeStyle=INK; wc.lineWidth=4.8; wc.beginPath(); wc.moveTo(8,-3); wc.lineTo(15,-7); wc.lineTo(23,-3); wc.moveTo(8,0); wc.lineTo(17,3); wc.lineTo(20,8); wc.stroke();
  wc.strokeStyle=bd; wc.lineWidth=3.2; wc.stroke();
  wc.fillStyle=INK; rrF(-7,-10,18,11,3);
  wc.fillStyle=bd; rrF(-6.2,-9.2,16.4,9.4,2.6);
  wc.fillStyle=ed; wc.fillRect(-5.8,-9,15.6,1.8);
  if(o){ wc.fillStyle='#0e0b09'; rrF(-2,-7,9,6,2); }
  wc.strokeStyle=INK; wc.lineWidth=3.6; wc.beginPath(); wc.moveTo(-6,-6); wc.lineTo(-15,-2); wc.lineTo(-23,-5); wc.moveTo(-5,-1); wc.lineTo(-13,4); wc.lineTo(-16,9); wc.stroke();
  wc.strokeStyle=bd; wc.lineWidth=2.2; wc.stroke(); wc.lineCap='butt';
  wc.save(); wc.translate(-24,-5); wc.rotate(.45);
  wc.fillStyle=INK; wc.beginPath(); wc.ellipse(0,0,9.4,6.2,0,0,6.2832); wc.fill();
  wc.fillStyle='#4a5364'; wc.beginPath(); wc.ellipse(0,0,8.2,5.2,0,0,6.2832); wc.fill();
  wc.fillStyle='#2b3240'; wc.beginPath(); wc.ellipse(0,.6,5.2,3.2,0,0,6.2832); wc.fill();
  wc.fillStyle='#4a2620'; wc.fillRect(-1.4,-1.2,2.8,2.4);
  wc.restore();
  wc.restore();
  wreckSmoke(ct,9);
}
WRECKDRAW.listener=drawWreckListener;
function drawContS(ct){
'@

SubRx @'
var VER='29.15';
'@ @'
var VER='29.16';
'@

$pat = "(?m)^  now:'v29\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.16: A dead Listener leaves a smoking wreck, not a box. Check 29.16 fails on v29.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
