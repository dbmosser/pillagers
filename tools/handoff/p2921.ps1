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

# A DEAD HOWLER LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wreckhowler), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Howler wreck:
// the splayed legs buckled under a cracked hull, the turret ring knocked askew, the fat mortar tube snapped off on the ground with its ochre muzzle ring, the ammo drum rolled clear. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckHowler(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,34,9,0,0,6.2832); wc.fill();
  wc.lineCap='round'; wc.lineJoin='round';
  var LG=[[-8,-8,-18,-12,-22,2],[8,-8,15,-3,24,-1],[-7,-6,-15,3,-20,7]];
  for(i=0;i<3;i++){
    wc.strokeStyle=P.ink; wc.lineWidth=4.6; wc.beginPath(); wc.moveTo(LG[i][0],LG[i][1]); wc.lineTo(LG[i][2],LG[i][3]); wc.lineTo(LG[i][4],LG[i][5]); wc.stroke();
    wc.strokeStyle=P.gm[1]; wc.lineWidth=2.6; wc.stroke();
  }
  wc.lineCap='butt'; wc.lineJoin='miter';
  wc.fillStyle=P.ink; rrF(-15,-17,30,15,5);
  wc.fillStyle=P.gm[1]; rrF(-13.8,-15.8,27.6,12.6,4);
  wc.fillStyle=P.grime; rrF(-13.8,-8,27.6,4.8,3);
  wc.fillStyle=P.ox[1]; wc.fillRect(-13.8,-11,27.6,1.6);
  if(o){ wc.fillStyle='#0e0b09'; rrF(-9,-15,15,9,2); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-8,-4); wc.lineTo(-5,-9); wc.lineTo(-7,-14); wc.moveTo(5,-4); wc.lineTo(7,-8); wc.lineTo(4,-12); wc.stroke(); }
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(7,-17,13.4,6.4,.35,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.ellipse(7,-17.6,12.2,5.2,.35,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.ellipse(6.4,-19,10,3,.35,0,6.2832); wc.fill();
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(14,-16,2,0,6.2832); wc.fill();
  wc.lineCap='round';
  wc.strokeStyle=P.ink; wc.lineWidth=11.4; wc.beginPath(); wc.moveTo(-14,9); wc.lineTo(-40,5); wc.stroke();
  wc.strokeStyle=P.gm[2]; wc.lineWidth=8.8; wc.stroke();
  wc.strokeStyle=P.gm[3]; wc.lineWidth=1.6; wc.beginPath(); wc.moveTo(-17,6.4); wc.lineTo(-37,3); wc.stroke();
  wc.strokeStyle=P.och; wc.lineWidth=8.8; wc.beginPath(); wc.moveTo(-38,5.2); wc.lineTo(-40.4,4.8); wc.stroke();
  wc.strokeStyle=P.ink; wc.lineWidth=2; wc.beginPath(); wc.moveTo(-14,3.4); wc.lineTo(-17,9); wc.stroke(); wc.lineCap='butt';
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(27,7,6,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(27,7,4.8,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[1]; wc.fillRect(22.2,6,9.6,2);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(27,7,1.6,0,6.2832); wc.fill();
  wc.restore();
  wreckSmoke(ct,20);
}
WRECKDRAW.howler=drawWreckHowler;
function drawContS(ct){
'@

SubRx @'
var VER='29.20';
'@ @'
var VER='29.21';
'@

$pat = "(?m)^  now:'v29\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.21: A dead Howler leaves a smoking mortar wreck. Check 29.21 fails on v29.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
