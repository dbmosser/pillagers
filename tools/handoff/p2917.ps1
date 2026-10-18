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

# A DEAD SENTRY LEAVES WRECKAGE, NOT A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawContS(ct){
'@ @'
// v28.xx (cw-wrecksentry), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Sentry wreck:
// the scorched tread with its wheel row, the slumped grey hull with its ochre chevrons, the camera head snapped off with a dead black lens, the twin gun fallen on the ground, a bent mast. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckSentry(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,30,9,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; rrF(-23,-9,46,13,4);
  wc.fillStyle=P.rub; rrF(-22,-8,44,11,3);
  wc.fillStyle=P.tooth; for(i=0;i<6;i++) wc.fillRect(-20+i*7,-8,3,1.6);
  for(i=-1;i<=1;i++){ wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(i*12,-2.5,3.4,0,6.2832); wc.fill(); wc.fillStyle=P.gm[3]; wc.beginPath(); wc.arc(i*12-.7,-3.2,1.2,0,6.2832); wc.fill(); }
  wc.fillStyle=P.ink; rrF(-18,-24,36,17,5);
  wc.fillStyle=P.gm[2]; rrF(-17,-23,34,15,4);
  wc.fillStyle=P.gm[3]; rrF(-17,-23,34,3,2);
  wc.fillStyle=P.ox[0]; wc.fillRect(-17,-13,34,2);
  wc.fillStyle=P.grime; wc.fillRect(-17,-12,34,4);
  wc.fillStyle=P.och; mbPoly([-12,-19,-9.4,-19,-7,-16.6,-9.4,-14.2,-12,-14.2,-9.6,-16.6]); mbPoly([-6,-19,-3.4,-19,-1,-16.6,-3.4,-14.2,-6,-14.2,-3.6,-16.6]);
  wc.fillStyle=P.ink; mbPoly([8,-24,13,-24,17,-20,10,-17]);
  if(o){ wc.fillStyle='#0e0b09'; rrF(0,-21,13,9,2); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(2,-12); wc.lineTo(5,-17); wc.lineTo(3,-21); wc.moveTo(10,-12); wc.lineTo(8,-16); wc.stroke(); }
  wc.fillStyle=P.ink; rrF(-3,-30,7,8,1.5); wc.fillStyle=P.gm[1]; rrF(-2,-29,5,6,1);
  wc.strokeStyle=P.ink; wc.lineWidth=1.3; wc.beginPath(); wc.moveTo(2,-30); wc.lineTo(8,-36); wc.lineTo(5,-41); wc.stroke();
  wc.fillStyle=P.ink; rrF(18,-6,19,13,4);
  wc.fillStyle=P.gm[1]; rrF(19,-5,17,11,3);
  wc.fillStyle=P.gm[3]; wc.fillRect(20,-5,15,1.6);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(31,1,3.6,0,6.2832); wc.fill();
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(31,1,2.3,0,6.2832); wc.fill();
  wc.lineCap='round';
  wc.strokeStyle=P.ink; wc.lineWidth=8; wc.beginPath(); wc.moveTo(-40,7); wc.lineTo(-21,4); wc.stroke();
  wc.strokeStyle=P.gm[1]; wc.lineWidth=5.4; wc.stroke();
  wc.strokeStyle=P.steel; wc.lineWidth=1.1; wc.beginPath(); wc.moveTo(-38,5.4); wc.lineTo(-23,3); wc.stroke();
  wc.strokeStyle=P.ink; wc.lineWidth=3; wc.beginPath(); wc.moveTo(-40,9.5); wc.lineTo(-22,6.5); wc.stroke(); wc.lineCap='butt';
  wc.restore();
  wreckSmoke(ct,26);
}
WRECKDRAW.sentry=drawWreckSentry;
function drawContS(ct){
'@

SubRx @'
var VER='29.16';
'@ @'
var VER='29.17';
'@

$pat = "(?m)^  now:'v29\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.17: A dead Sentry leaves a smoking wreck of itself. Check 29.17 fails on v29.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
