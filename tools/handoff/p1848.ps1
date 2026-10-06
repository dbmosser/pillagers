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

# THE BAKED SPRITES ARE SHARP AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wallSpriteScale(){ var z=1; try{ z=ZOOM()*(DPR||1); }catch(_z){ z=1; } return Math.max(1,Math.min(2,Math.round(z))); }
'@ @'
function wallSpriteScale(){ var z=1; try{ z=ZOOM()*(DPR||1); }catch(_z){ z=1; } return Math.max(1,Math.min(4,Math.ceil(z-0.05))); }   // v18.48: rounds up and reaches 4, so 4K and odd zooms are never stretched
'@

SubRx @'
    ss=wallSpriteScale();
'@ @'
    ss=(function(){ try{ var _m=wc.getTransform(); return Math.max(1,Math.min(4,Math.ceil(Math.hypot(_m.a,_m.b)-0.05))); }catch(_t){ return wallSpriteScale(); } })();   // v18.48: the scale of the canvas being drawn on
'@

SubRx @'
function onCtxRestored(){
  ctxLost=false;
'@ @'
function onCtxRestored(){
  ctxLost=false;
  try{ WALLSPR.m={}; WALLSPR.n=0; WALLSPR.key=''; VEGSPR.m={}; VEGSPR.key=''; SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=0; ICONSPR.m={}; ICONSPR.n=0; }catch(_sc){}   // v18.48: sprites painted before the loss are blank now
'@

SubRx @'
var VER='18.47';
'@ @'
var VER='18.48';
'@

$pat = "(?m)^  now:'v18\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.48: Walls, trees, shadows and belt icons stay sharp at 4K and every zoom. Check 18.48 fails on v18.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
