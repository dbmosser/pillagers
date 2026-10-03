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

# THE STYLING PASS, STAGE C: ONE PANEL FOR THE RAID HUD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawRaiderBoard(){
'@ @'
// v18.13, THE STYLING PASS, STAGE C: ONE PANEL FOR THE RAID HUD. Five HUD boxes (conditions, the pillager board, both legends and
// the backpack) each drew their own flat black rectangle with a thin stroke. They share one panel now: rounded corners, a slight
// top-to-bottom gradient, a one pixel steel border and a hairline of light along the top edge, so the HUD reads as one set of
// instruments. Every position, size and hit box is what it was.
function hudPanel(x,y,w,h,a){
  var r, g;
  if(!(w>0&&h>0)) return;
  r=Math.min(6,w/2,h/2); a=(a===undefined)?0.76:a;
  function path(px,py,pw,ph,pr){ pr=Math.max(0,Math.min(pr,pw/2,ph/2)); ctx.beginPath(); ctx.moveTo(px+pr,py); ctx.lineTo(px+pw-pr,py); ctx.quadraticCurveTo(px+pw,py,px+pw,py+pr); ctx.lineTo(px+pw,py+ph-pr); ctx.quadraticCurveTo(px+pw,py+ph,px+pw-pr,py+ph); ctx.lineTo(px+pr,py+ph); ctx.quadraticCurveTo(px,py+ph,px,py+ph-pr); ctx.lineTo(px,py+pr); ctx.quadraticCurveTo(px,py,px+pr,py); ctx.closePath(); }
  ctx.save();
  path(x,y,w,h,r);
  try{ g=ctx.createLinearGradient(0,y,0,y+h); g.addColorStop(0,'rgba(14,19,40,'+a+')'); g.addColorStop(1,'rgba(6,9,13,'+a+')'); ctx.fillStyle=g; }catch(_g){ ctx.fillStyle='rgba(6,9,13,'+a+')'; }
  ctx.fill();
  path(x+.5,y+.5,w-1,h-1,r);
  ctx.strokeStyle='rgba(127,146,216,.42)'; ctx.lineWidth=1; ctx.stroke();
  ctx.beginPath(); ctx.moveTo(x+r,y+1.5); ctx.lineTo(x+w-r,y+1.5); ctx.strokeStyle='rgba(255,255,255,.06)'; ctx.lineWidth=1; ctx.stroke();
  ctx.restore();
}
function drawRaiderBoard(){
'@

SubRx @'
ctx.fillStyle='rgba(6,9,13,.72)'; ctx.fillRect(bx,by,bw,bh);
    ctx.strokeStyle='rgba(127,146,216,.40)'; ctx.lineWidth=1; ctx.strokeRect(bx+.5,by+.5,bw-1,bh-1);
'@ @'
hudPanel(bx,by,bw,bh);   // v18.13: the one HUD panel
'@

SubRx @'
  ctx.fillStyle='rgba(6,9,13,.72)';
  ctx.fillRect(PADX-8,y0-LH(13),LW,boxH);
  ctx.strokeStyle='rgba(127,146,216,.40)'; ctx.lineWidth=1;
  ctx.strokeRect(PADX-7.5,y0-LH(12.5),LW-1,boxH-1);
'@ @'
  hudPanel(PADX-8,y0-LH(13),LW,boxH);   // v18.13: the one HUD panel
'@

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.72)'; ctx.fillRect(mx-8,my-6,MW,MH+10);
    ctx.strokeStyle='rgba(127,146,216,.40)'; ctx.lineWidth=1;
    ctx.strokeRect(mx-7.5,my-5.5,MW-1,MH+9);
'@ @'
    hudPanel(mx-8,my-6,MW,MH+10);   // v18.13: the one HUD panel
'@

SubRx @'
  ctx.fillStyle='rgba(6,9,13,.82)'; ctx.fillRect(x-8,top-6,LEGW,boxH+10);
  ctx.strokeStyle='rgba(127,146,216,.55)'; ctx.lineWidth=1;
  ctx.strokeRect(x-7.5,top-5.5,LEGW-1,boxH+9);
'@ @'
  hudPanel(x-8,top-6,LEGW,boxH+10,0.84);   // v18.13: the one HUD panel
'@

SubRx @'
  ctx.fillStyle='rgba(6,9,13,.96)'; ctx.fillRect(x,y,PW,hh);
  ctx.strokeStyle='#3a4552'; ctx.lineWidth=1; ctx.strokeRect(x+.5,y+.5,PW-1,hh-1);
'@ @'
  hudPanel(x,y,PW,hh,0.96);   // v18.13: the one HUD panel
'@

SubRx @'
var VER='18.12';
'@ @'
var VER='18.13';
'@

$pat = "(?m)^  now:'v18\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.13: The raid HUD panels share one look: rounded, softly shaded, one border. Check 18.13 fails on v18.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
