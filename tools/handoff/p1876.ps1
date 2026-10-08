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

# A SCOPED GUN ZOOMS IN A LITTLE ON ADS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function ZOOM(){ return ZC*hudRes(); }
'@ @'
// v18.76, HIS NOTE (2026-10-07): "when a gun has a scope, like the auto rifle, it should actually zoom in a lil bit when player
// uses ADS". A scoped gun (WEAPONS optic, 1.1 to 2.4) aimed down its sights now pulls the camera in by a share of its power:
// 1+(optic-1)*0.35 (dial CFG.adsZoom), so the Auto Rifle about 9 percent, the Marksman Rifle about 30, the Longshot about half
// again. It eases in and out in render2D (G.adsZ), only in a live raid, never in the bot sim (its aim and the seeded stream
// stay as they were), and every reader of the projection (w2s, mouseWorld, the pad aim, the camera) sees it through ZOOM.
// The baked sprites (walls, trees, shadows) keep the scale of the zoom without it, so aiming never re-bakes the street.
function adsZf(){ return (typeof G!=='undefined'&&G&&!G.sim&&!G.over&&typeof state!=='undefined'&&state==='raid'&&G.adsZ>0)?G.adsZ:1; }
function ZOOM(){ return ZC*hudRes()*adsZf(); }
'@

SubRx @'
function wallSpriteScale(){ var z=1; try{ z=ZOOM()*(DPR||1); }catch(_z){ z=1; } return Math.max(1,Math.min(4,Math.ceil(z-0.05))); }
'@ @'
function wallSpriteScale(){ var z=1; try{ z=ZOOM()/adsZf()*(DPR||1); }catch(_z){ z=1; } return Math.max(1,Math.min(4,Math.ceil(z-0.05))); }   // v18.48: rounds up and reaches 4, so 4K and odd zooms are never stretched; v18.76: without the scope zoom, so aiming never re-bakes
'@

SubRx @'
    ss=(function(){ try{ var _m=wc.getTransform(); return Math.max(1,Math.min(4,Math.ceil(Math.hypot(_m.a,_m.b)-0.05))); }catch(_t){ return wallSpriteScale(); } })();
'@ @'
    ss=(function(){ try{ var _m=wc.getTransform(); return Math.max(1,Math.min(4,Math.ceil(Math.hypot(_m.a,_m.b)/adsZf()-0.05))); }catch(_t){ return wallSpriteScale(); } })();   // v18.76: without the scope zoom
'@

SubRx @'
  var Z=ZOOM(),VW=W/Z,VH=H/Z;
'@ @'
  // v18.76, his note: the scope zoom eases toward its target here, once a frame, before anything reads ZOOM.
  (function(){ var m=opticMag(), k=(CFG.adsZoom===undefined)?0.35:CFG.adsZoom, tgt=(m>1&&!G.sim&&!G.over)?Math.max(1,1+(m-1)*k):1, d=Math.max(0,Math.min(0.1,+dt||0));
    if(!(G.adsZ>0)) G.adsZ=1; G.adsZ+=(tgt-G.adsZ)*(1-Math.exp(-d*11)); if(Math.abs(tgt-G.adsZ)<0.0005) G.adsZ=tgt; })();
  var Z=ZOOM(),VW=W/Z,VH=H/Z;
'@

SubRx @'
var VER='18.75';
'@ @'
var VER='18.76';
'@

$pat = "(?m)^  now:'v18\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.76: Aiming down sights with a scoped gun zooms the view in a little; stronger scopes zoom more. Check 18.76 fails on v18.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
