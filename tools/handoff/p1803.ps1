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

# THE FOG AND DARKNESS SHEETS DRAW AT HALF SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var litC=document.createElement('canvas'),lx2=litC.getContext('2d');
'@ @'
var litC=document.createElement('canvas'),lx2=litC.getContext('2d');
// v18.03, AAA CHECK after his report of 2026-10-03 (frame rate lag): THE TWO SOFT SHEETS DRAW SMALL. The fog of war sheet and
// the darkness-and-lamps sheet were each a full screen of pixels, cleared, filled and composited every frame, at 4K eight
// million pixels apiece, and the Render resolution row never touched them. They hold nothing but gradients and one soft cone
// edge, which do not need every pixel. They draw at SOFTR of the screen now (half at 1440p and 4K, two thirds at 1080p, less
// again under a lower render resolution) and are stretched back over the frame. The hub's warm light sheet is the same sheet.
var SOFTR=1;
'@

SubRx @'
  fogC.width=W; fogC.height=H;
  litC.width=W; litC.height=H;
'@ @'
  SOFTR=Math.max(0.33,((W*H>2.6e6)?0.5:0.67)*gfxScaleNow());   // v18.03: the soft sheets' share of the screen
  fogC.width=Math.max(1,Math.round(W*SOFTR)); fogC.height=Math.max(1,Math.round(H*SOFTR));
  litC.width=Math.max(1,Math.round(W*SOFTR)); litC.height=Math.max(1,Math.round(H*SOFTR));
'@

SubRx @'
  lx2.globalCompositeOperation='source-over';
  lx2.clearRect(0,0,W,H);
  // CFG.bright lifts everything you can actually see.
'@ @'
  lx2.globalCompositeOperation='source-over';
  lx2.setTransform(1,0,0,1,0,0); lx2.clearRect(0,0,litC.width,litC.height); lx2.setTransform(SOFTR,0,0,SOFTR,0,0);   // v18.03: the sheet is SOFTR of the screen; everything below draws in screen units through this
  // CFG.bright lifts everything you can actually see.
'@

SubRx @'
  lx2.setTransform(Z,0,0,Z,-ox*Z,-oy*Z);
'@ @'
  lx2.setTransform(Z*SOFTR,0,0,Z*SOFTR,-ox*Z*SOFTR,-oy*Z*SOFTR);   // v18.03: world units on the small sheet
'@

SubRx @'
  lx2.setTransform(1,0,0,1,0,0);
  wc.drawImage(litC,0,0);
'@ @'
  lx2.setTransform(1,0,0,1,0,0);
  wc.drawImage(litC,0,0,W,H);   // v18.03: stretched back over the frame
'@

SubRx @'
  fx2.setTransform(1,0,0,1,0,0);
  fx2.clearRect(0,0,W,H);
'@ @'
  fx2.setTransform(1,0,0,1,0,0);
  fx2.clearRect(0,0,fogC.width,fogC.height); fx2.setTransform(SOFTR,0,0,SOFTR,0,0);   // v18.03: the fog sheet is SOFTR of the screen
'@

SubRx @'
  fx2.setTransform(Z,0,0,Z,-ox*Z,-oy*Z);
'@ @'
  fx2.setTransform(Z*SOFTR,0,0,Z*SOFTR,-ox*Z*SOFTR,-oy*Z*SOFTR);   // v18.03: world units on the small sheet
'@

SubRx @'
wc.drawImage(fogC,0,0);
'@ @'
wc.drawImage(fogC,0,0,W,H);   // v18.03: stretched back over the frame
'@

SubRx @'
  lx2.globalCompositeOperation='source-over';
  lx2.clearRect(0,0,W,H);
  lx2.fillStyle='rgba(14,12,36,'
'@ @'
  lx2.globalCompositeOperation='source-over';
  lx2.setTransform(1,0,0,1,0,0); lx2.clearRect(0,0,litC.width,litC.height); lx2.setTransform(SOFTR,0,0,SOFTR,0,0);   // v18.03: the home sheet draws small too
  lx2.fillStyle='rgba(14,12,36,'
'@

SubRx @'
  wc.drawImage(litC,0,0);
  wc.globalCompositeOperation='lighter';
  for(i=0;i<HB.lights.length;i++){
'@ @'
  lx2.setTransform(1,0,0,1,0,0); wc.drawImage(litC,0,0,W,H);   // v18.03: stretched back over the frame
  wc.globalCompositeOperation='lighter';
  for(i=0;i<HB.lights.length;i++){
'@

SubRx @'
var VER='18.02';
'@ @'
var VER='18.03';
'@

$pat = "(?m)^  now:'v18\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.03: The fog and darkness layers now draw at half size and are stretched back, which cuts two of the heaviest full-screen passes to a quarter of their pixels. Check 18.03 fails on v18.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
