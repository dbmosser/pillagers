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

# WORLD TEXT STAYS SHARP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@ @'
// v23.xx (gfx5), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 11, render scale. WORLD TEXT DRAWS ON
// THE HUD CANVAS. The nameplates, the party tags, the damage numbers and the floating labels (loot found, targets down, WEAK SPOT)
// were filled on the world canvas, so a lower Render resolution or an Auto resolution step softened every one of them with the
// world, while the HUD beside them stayed sharp (gfx4). render2D now hands the two world text passes (_wtA, _wtB) and the exact
// world transform they were drawn in to drawHUD, which runs them right after its clear and vignette on the HUD canvas: wc is
// pointed at ctx for the length of the two passes and handed back in finally, and the transform is the same one in CSS pixels,
// scaled by the HUD ratio (DPRH) in place of the world ratio (DPR). What is drawn, where, and the canSee gate on the nameplates are
// unchanged; the words are now sharp at any render scale and sit over the rain and the weather fog as well as the dark. A HUD
// drawn on its own (no raid frame before it) draws no world text: the hand-off is cleared as soon as it is used.
var GFXWT=null;
function gfxWorldText(){
  var o=GFXWT; GFXWT=null;
  if(!o||o.g!==G||!ctx||!wc) return false;
  var keep=wc, m=o.m, k=DPRH/((o.d>0)?o.d:1), z;
  ctx.save();
  try{
    if(m) ctx.setTransform(m.a*k,m.b*k,m.c*k,m.d*k,m.e*k,m.f*k);
    else { z=DPRH*o.z; ctx.setTransform(z,0,0,z,-o.ox*z,-o.oy*z); }
    ctx.globalAlpha=1; ctx.globalCompositeOperation='source-over'; ctx.textAlign='left';
    ctx.textBaseline=o.tb||'alphabetic'; if(o.f) ctx.font=o.f;
    ctx.lineWidth=(o.lw>0)?o.lw:1; ctx.lineCap=o.lc||'butt'; ctx.lineJoin=o.lj||'miter';
    ctx.shadowBlur=0; ctx.shadowColor='rgba(0,0,0,0)'; ctx.imageSmoothingEnabled=(o.ism!==false);
    wc=ctx;
    if(typeof o.a==='function') o.a();
    if(typeof o.b==='function') o.b();
  } finally { wc=keep; ctx.restore(); }
  return true;
}
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@

SubRx @'
  // v22.xx (R45): the world text, over the darkness and the fog of war sheets, in the world transform it was drawn in before
  wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);
  try{ if(typeof _wtA==='function') _wtA(); if(typeof _wtB==='function') _wtB(); } finally { wc.globalAlpha=1; wc.textAlign='left'; wc.restore(); }
'@ @'
  // v22.xx (R45): the world text, over the darkness and the fog of war sheets, in the world transform it was drawn in before
  // v23.xx (gfx5): handed to drawHUD with that transform, and filled there on the HUD canvas (gfxWorldText), so it stays sharp at any render scale
  wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);
  try{ GFXWT={g:G,a:_wtA,b:_wtB,m:(wc.getTransform?wc.getTransform():null),d:DPR,z:Z,ox:ox,oy:oy,tb:wc.textBaseline,f:wc.font,lw:wc.lineWidth,lc:wc.lineCap,lj:wc.lineJoin,ism:wc.imageSmoothingEnabled}; } finally { wc.restore(); }
'@

SubRx @'
  drawHUD();
  drawBuzzFx();
'@ @'
  try{ drawHUD(); } finally { GFXWT=null; }   // v23.xx (gfx5): the world text hand-off is this frame's only
  drawBuzzFx();
'@

SubRx @'
  ctx.clearRect(0,0,W,H);
  var vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
  vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,.45)');
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H);
'@ @'
  ctx.clearRect(0,0,W,H);
  var vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
  vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,.45)');
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H);
  if(GFXWT) gfxWorldText();   // v23.xx (gfx5): the nameplates, tags, damage numbers and labels of this raid frame, sharp on the HUD canvas
'@

SubRx @'
var VER='23.95';
'@ @'
var VER='23.96';
'@

$pat = "(?m)^  now:'v23\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.96: Nameplates, damage numbers and loot labels now draw on the sharp HUD layer and stay crisp at any Render resolution. Check 23.96 fails on v23.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
