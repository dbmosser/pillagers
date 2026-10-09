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

# THE SECTOR MAPS ARE SHARP AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sectorPreviewDraw(cv,M){
  var c=cv.getContext('2d'), W0=cv.width, H0=cv.height, sc=Math.min(W0/M.w,H0/M.h), ox=(W0-M.w*sc)/2, oy=(H0-M.h*sc)/2, i, z, b, e, n=0;
  if(!c) return 0;
  c.clearRect(0,0,W0,H0);
'@ @'
function sectorPreviewDraw(cv,M){
  // v20.95 (V-B4): a map canvas made sharp (sectorPrevSharp below) is drawn in its page size and scaled up into its larger store
  var c=cv.getContext('2d'), _sk=!!(cv._k&&cv._lw&&cv._lh), W0=_sk?cv._lw:cv.width, H0=_sk?cv._lh:cv.height, sc=Math.min(W0/M.w,H0/M.h), ox=(W0-M.w*sc)/2, oy=(H0-M.h*sc)/2, i, z, b, e, n=0;
  if(!c) return 0;
  c.setTransform(1,0,0,1,0,0); c.clearRect(0,0,cv.width,cv.height);
  if(_sk) c.setTransform(cv.width/W0,0,0,cv.height/H0,0,0);
'@

SubRx @'
  c.textAlign='left';
  return n;
}
function sectorPreviews(host){
  var cvs=host.querySelectorAll('canvas.secprev'), i, ix, n=0;
  for(i=0;i<cvs.length;i++){ ix=parseInt(cvs[i].getAttribute('data-map'),10); if(FIXED_MAPS[ix]){ try{ sectorPreviewDraw(cvs[i],FIXED_MAPS[ix]); n++; }catch(_sp){} } }
  return n;
}
'@ @'
  c.textAlign='left';
  c.setTransform(1,0,0,1,0,0);
  return n;
}
// v20.95, from the whole-game bug hunt of 2026-10-08 (V-B4), seen on the 4K lift picture: THE SECTOR MAPS ARE SHARP AT 4K. Each map
// was drawn on a canvas of 420 pixels and the page then stretched it to the menu size, about two and a half times at 4K, so the
// zone names and the building edges came out soft and blurred. The canvas now holds as many pixels as the screen shows there (the
// menu size times the screen pixel ratio, never below 1 and at most 3), keeps its place and size on the page, and the map is drawn
// scaled into it. At 1080p with the usual menu size nothing changes.
function sectorPrevSharp(cv){
  var k;
  if(!cv._lw){ cv._lw=cv.width; cv._lh=cv.height; }
  k=(window.devicePixelRatio||1)*((typeof menuScale==='function')?menuScale():1);
  k=Math.max(1,Math.min(3,k||1));
  cv.style.width=cv._lw+'px'; cv.style.height=cv._lh+'px';
  cv.width=Math.round(cv._lw*k); cv.height=Math.round(cv._lh*k); cv._k=k;
  return k;
}
function sectorPreviews(host){
  var cvs=host.querySelectorAll('canvas.secprev'), i, ix, n=0;
  for(i=0;i<cvs.length;i++){ ix=parseInt(cvs[i].getAttribute('data-map'),10); if(FIXED_MAPS[ix]){ try{ sectorPrevSharp(cvs[i]); sectorPreviewDraw(cvs[i],FIXED_MAPS[ix]); n++; }catch(_sp){} } }
  return n;
}
'@

SubRx @'
var VER='20.94';
'@ @'
var VER='20.95';
'@

$pat = "(?m)^  now:'v20\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.95: At 4K the sector maps on the lift page are sharp, not blurred. Check 20.95 fails on v20.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
