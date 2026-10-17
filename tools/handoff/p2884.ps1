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

# A DEAD DEER IS A DEER, NOT A MAN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var cc2=setLoot(mkContainer(CW.x,CW.y,'body'),['meat']);
'@ @'
var cc2=setLoot(mkContainer(CW.x,CW.y,'body'),['meat']); cc2.carcass='deer'; CW.crc=1;   // v28.xx (cw-deercarcass), HIS NOTE (2026-10-15): "deer becomes a human body: fix it". The meat container is tagged a deer carcass, drawn by drawDeerCarcass, not the prone man
'@

SubRx @'
  } else if(ct.type==='body'){
    // A BODY IS A BODY, v3.65.
'@ @'
  } else if(ct.carcass==='deer'){
    drawDeerCarcass(ct);   // v28.xx (cw-deercarcass): a dead deer is a deer on its side, never the human body below
  } else if(ct.type==='body'){
    // A BODY IS A BODY, v3.65.
'@

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-deercarcass), HIS NOTE (2026-10-15): "deer becomes a human body: fix it". A shot deer leaves a meat container of type body, and
// that type drew the prone man. This draws the deer lying on its side in the live deer palette: stiff legs out, head down, antlers on some,
// blood under it. Facing and antlers come from grit(x,y), the positional hash: no random stream touched, nothing shimmers.
function drawDeerCarcass(ct){
  var fl=grit(ct.x,ct.y)>0.5?1:-1, ant=grit(ct.x+7,ct.y+3)>0.55;
  wc.save(); wc.translate(ct.x,ct.y-3); wc.scale(fl,1);
  wc.fillStyle='rgba(90,24,16,.55)'; wc.beginPath(); wc.ellipse(2,5,13,4,0,0,6.2832); wc.fill();
  wc.strokeStyle=INK; wc.lineWidth=2.8; wc.beginPath();
  wc.moveTo(-8,3); wc.lineTo(-12,9); wc.moveTo(-3,4); wc.lineTo(-5,11); wc.moveTo(4,4); wc.lineTo(7,11); wc.moveTo(8,3); wc.lineTo(13,8);
  wc.stroke();
  wc.strokeStyle='#6b563f'; wc.lineWidth=1.4; wc.beginPath();
  wc.moveTo(-8,3); wc.lineTo(-12,9); wc.moveTo(-3,4); wc.lineTo(-5,11); wc.moveTo(4,4); wc.lineTo(7,11); wc.moveTo(8,3); wc.lineTo(13,8);
  wc.stroke();
  wc.fillStyle=INK; rrF(-13,-7,26,14,6);
  wc.fillStyle='#6b563f'; rrF(-12,-6,24,12,5);
  wc.fillStyle='#7d6749'; rrF(-12,-6,24,4.5,4);
  wc.fillStyle='rgba(232,226,214,.55)'; rrF(-8,2.5,14,3,1.5); wc.fillRect(-13,-3,3,4);
  wc.strokeStyle=INK; wc.lineWidth=5; wc.beginPath(); wc.moveTo(10,-2); wc.lineTo(19,3); wc.stroke();
  wc.strokeStyle='#6b563f'; wc.lineWidth=3; wc.beginPath(); wc.moveTo(10,-2); wc.lineTo(19,3); wc.stroke();
  wc.fillStyle=INK; rrF(17,0,8,7,2.5);
  wc.fillStyle='#7d6749'; rrF(17.5,0.5,7,6,2);
  wc.strokeStyle=INK; wc.lineWidth=1; wc.beginPath(); wc.moveTo(21,2); wc.lineTo(23,4); wc.moveTo(23,2); wc.lineTo(21,4); wc.stroke();
  if(ant){
    wc.strokeStyle='#4a3f30'; wc.lineWidth=1.5; wc.beginPath();
    wc.moveTo(21,0); wc.lineTo(23,-6); wc.lineTo(27,-8); wc.moveTo(23,-6); wc.lineTo(21,-9);
    wc.stroke();
  }
  wc.restore();
}
function drawContS(ct){
'@

SubRx @'
      if(CT.dead){
        shadowE(CT.x,CT.y+1,
'@ @'
      if(CT.dead&&CT.crc){
        // v28.xx (cw-deercarcass): a deer with its carcass container is drawn by the container (drawDeerCarcass), not twice
      } else
      if(CT.dead){
        shadowE(CT.x,CT.y+1,
'@

SubRx @'
var VER='28.83';
'@ @'
var VER='28.84';
'@

$pat = "(?m)^  now:'v28\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.84: A dead deer lies as a deer on its side instead of a human body. Check 28.84 fails on v28.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
