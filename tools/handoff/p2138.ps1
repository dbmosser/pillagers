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

# THE MAP HEADER STANDS CLEAR OF THE FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillText('SECTOR MAP',ox,oy-10);
'@ @'
  // v21.38, from the 4K visual pass of 2026-10-09 (W-D3): THE MAP HEADER STANDS CLEAR OF THE FRAME. The header line (SECTOR MAP, the
  // waypoint hint and the weather) sat 10 pixels above the map at every screen size, but since v9.15 the frame grows with the screen
  // (3*_MZ out from the map, 3*_MZ thick), so at 4K the frame reached 9 pixels up and the words stood on it. The gap grows by the same
  // _MZ now. At 1080p _MZ is 1 and nothing moves.
  var _hdY=oy-10*_MZ;
  ctx.fillText('SECTOR MAP',ox,_hdY);
'@

SubRx @'
    ctx.fillText(_hsub,_hx,oy-10);
'@ @'
    ctx.fillText(_hsub,_hx,_hdY);
'@

SubRx @'
'CLICK to set a waypoint',_hx,oy-10);
'@ @'
'CLICK to set a waypoint',_hx,_hdY);
'@

SubRx @'
if(_trB>oy-10-_wfp&&
'@ @'
if(_trB>_hdY-_wfp&&
'@

SubRx @'
    _wxR,oy-10);
'@ @'
    _wxR,_hdY);
'@

SubRx @'
var VER='21.37';
'@ @'
var VER='21.38';
'@

$pat = "(?m)^  now:'v21\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.38: On a 4K screen the SECTOR MAP header no longer sits on the map frame. Check 21.38 fails on v21.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
