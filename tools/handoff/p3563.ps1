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

# HUD SIZE WORKS FOR TV (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudRes(){
  if(!W||!H) return 1;
  return clamp(Math.min(W/1920,H/1080),1,2.2);
}
'@ @'
// v28.xx (cw-cx-hudtv): HUD SIZE already saved a choice but nothing read it. Grow raid panels and their hit boxes together; the Undercroft keeps its own layout.
function hudTvScale(){ return (CFG.hudTv===1&&typeof G!=='undefined'&&G&&!G.hubFloor&&!G.over)?1.2:1; }
function hudRes(){
  if(!W||!H) return 1;
  return clamp(Math.min(W/1920,H/1080),1,2.2)*hudTvScale();
}
'@

SubRx @'
   hint:'Large for TV: bigger raid text for a screen across the room.',
'@ @'
   hint:'Large for tv: bigger raid panels, minimap and belt.', // v28.xx (cw-cx-hudtv): say what the existing choice now changes.
'@

SubRx @'
    if(hx<_rL) hx=Math.round(_rL);
'@ @'
    if(hx<_rL) hx=Math.round(_rL);
    // v28.xx (cw-cx-hudtv): bigger corners would squeeze the belt smaller. In TV mode grow the slots above both corners, with the same recorded click and drag cells.
    var _tv=hudTvScale();
    if(_tv>1){
      var _nz=_hz/_tv, _nbR=390*(HUDZ.body||1)*_nz*hudUserZ('body')+Math.max(0,hudOff('body').dx),
          _ngL=W-252*(HUDZ.gear||1)*_nz*hudUserZ('gear')+Math.min(0,hudOff('gear').dx),
          _nbw=Math.max(20,Math.min(Math.floor((_ngL-_nbR-LH(28)-_gt)/sl.length),LH(112))),
          _topB=H-(34+50+LH(5)+LH(18))*(HUDZ.body||1)*_hz*hudUserZ('body')+hudOff('body').dy,
          _topG=H-(34+LH(80))*(HUDZ.gear||1)*_hz*hudUserZ('gear')+hudOff('gear').dy;
      bw=Math.max(20,Math.min(Math.round(_nbw*_tv),Math.floor((W-LH(32)-_gt)/sl.length)));
      tw2=sl.length*bw+_gt; hx=Math.round((W-tw2)/2);
      hy=Math.max(LH(16),Math.min(_topB,_topG)-bw-LH(24));
    }
'@

SubRx @'
var VER='35.62';
'@ @'
var VER='35.63';
'@

$pat = "(?m)^  now:'v35\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.63: Large for tv grows raid panels, minimap and belt; the belt sits above the bottom corners. Check 35.63 fails on v35.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
