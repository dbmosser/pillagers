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

# FOOTPRINTS AND DECALS ON THE GROUND GRID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxScarReplay(){
'@ @'
// v34.xx (cw-pixdecal), his pixel pass (10-20): in the pixel look a footprint or a decal is drawn from the corner of the 2 unit ground grid, so it sits on the floor pixels like the scars do. Only the draw position moves; the stored x and y, the lifetimes and the AI that smells prints are untouched.
function pixMarkSnap(v){ return pixOn()?Math.round(v/PIX_ENV)*PIX_ENV:v; }
function gfxScarReplay(){
'@

SubRx @'
wc.ellipse(_fp.x,_fp.y,4+_fp.t*14,(4+_fp.t*14)*0.42,0,0,6.2832);
'@ @'
wc.ellipse(pixMarkSnap(_fp.x),pixMarkSnap(_fp.y),4+_fp.t*14,(4+_fp.t*14)*0.42,0,0,6.2832);
'@

SubRx @'
    wc.fillRect(_fp.x-3,_fp.y-1,3,5);
    wc.fillRect(_fp.x+1,_fp.y-3,3,5);
'@ @'
    var _fsx=pixMarkSnap(_fp.x),_fsy=pixMarkSnap(_fp.y);   // v34.xx (cw-pixdecal)
    wc.fillRect(_fsx-3,_fsy-1,3,5);
    wc.fillRect(_fsx+1,_fsy-3,3,5);
'@

SubRx @'
wc.save(); wc.translate(dc.x,dc.y); wc.rotate(dc.rot);
'@ @'
wc.save(); wc.translate(pixMarkSnap(dc.x),pixMarkSnap(dc.y)); wc.rotate(dc.rot);   // v34.xx (cw-pixdecal): on the ground grid in the pixel look
'@

SubRx @'
var VER='34.47';
'@ @'
var VER='34.48';
'@

$pat = "(?m)^  now:'v34\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.48: With the pixel look on, footprints and ground marks line up with the floor pixels. With the look off, nothing changes. Check 34.48 fails on v34.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
