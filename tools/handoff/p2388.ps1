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

# SHARP HUD AT ANY RESOLUTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var W=0,H=0,DPR=1;
'@ @'
var W=0,H=0,DPR=1,DPRH=1;   // v23.xx (gfx4): DPRH is the HUD canvas ratio (the screen's own, capped at 2); DPR is the world's, with the render scale in it
'@

SubRx @'
  DPR=Math.min(window.devicePixelRatio||1,2)*gfxScaleNow(); RES_APPLIED=CFG.gfxScale; DRS.applied=DRS.scale;   // v17.43: his pick 28, the render resolution; v18.01: and the auto step
  var r=cv.getBoundingClientRect();
  W=r.width; H=r.height;
  cv.width=W*DPR; cv.height=H*DPR;
  wc=cv.getContext('2d'); wc.setTransform(DPR,0,0,DPR,0,0);
  hcv.width=W*DPR; hcv.height=H*DPR;
  ctx=hcv.getContext('2d'); ctx.setTransform(DPR,0,0,DPR,0,0);
'@ @'
  // v23.xx (gfx4), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 11, render scale. A lower Render
  // resolution, or an Auto resolution step, used to shrink BOTH canvases, so every HUD word, number and icon went soft along
  // with the world. Now only the world canvas (cv, DPR) takes the render scale. The HUD canvas (hcv, ctx) always draws at the
  // screen's own pixels (DPRH, the device ratio capped at 2), so text stays sharp at any resolution and the world alone pays
  // for the speed. The soft sheets below still follow the render scale.
  DPRH=Math.min(window.devicePixelRatio||1,2);
  DPR=DPRH*gfxScaleNow(); RES_APPLIED=CFG.gfxScale; DRS.applied=DRS.scale;   // v17.43: his pick 28, the render resolution; v18.01: and the auto step
  var r=cv.getBoundingClientRect();
  W=r.width; H=r.height;
  cv.width=W*DPR; cv.height=H*DPR;
  wc=cv.getContext('2d'); wc.setTransform(DPR,0,0,DPR,0,0);
  hcv.width=W*DPRH; hcv.height=H*DPRH;
  ctx=hcv.getContext('2d'); ctx.setTransform(DPRH,0,0,DPRH,0,0);
'@

SubRx @'
  var _pa=Math.abs((ctx.getTransform?ctx.getTransform().a:1)||1)/((typeof DPR==='number'&&DPR>0)?DPR:1);
'@ @'
  var _pa=Math.abs((ctx.getTransform?ctx.getTransform().a:1)||1)/((typeof DPRH==='number'&&DPRH>0)?DPRH:1);   // v23.xx (gfx4): ctx runs at DPRH, not the world DPR
'@

SubRx @'
  R=Math.max(1,Math.min(3,Math.round((typeof DPR==='number'&&DPR>0)?DPR*1.5:1.5)));
'@ @'
  R=Math.max(1,Math.min(3,Math.round((typeof DPRH==='number'&&DPRH>0)?DPRH*1.5:1.5)));   // v23.xx (gfx4): icons draw on the HUD canvas, which no longer takes the render scale
'@

SubRx @'
   hint:'How many pixels the game draws. Lower is softer but runs faster on a slower PC.',
'@ @'
   hint:'THE WORLD ONLY. HUD AND TEXT STAY SHARP. LOWER RUNS FASTER.',   // v23.xx (gfx4): the HUD canvas no longer takes this scale
'@

SubRx @'
var VER='23.87';
'@ @'
var VER='23.88';
'@

$pat = "(?m)^  now:'v23\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.88: Render resolution now softens only the world: the HUD and its text stay sharp at every setting. Check 23.88 fails on v23.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
