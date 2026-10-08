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

# THE KILL FEED KEEPS ITS PLACE UNDER A LOW PANEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _fy0=H*0.46, _fcb=HUDBOX.cond;
  if(_fcb&&_fcb.x<W-LH(16)*_fhr&&_fcb.x+_fcb.w>W-LH(220)*_fhr) _fy0=Math.min(H*0.75,Math.max(_fy0,_fcb.y+_fcb.h+LH(20)*_fhr));
'@ @'
  // v19.58, from the review (2026-10-08): v19.48 pushed the feed under the panel whenever the panel was in its column, so a panel
  // dragged low pulled the feed down over its own rows and onto the weapon readout. The feed moves only when the panel covers its
  // own band at 46 percent: below the panel when that still clears the weapon readout (about 78 percent down), else above the panel.
  var _fy0=H*0.46, _fcb=HUDBOX.cond, _fn=Math.max(1,(NET.feed||[]).length), _fbh=_fn*LH(22)*_fhr;
  if(_fcb&&_fcb.x<W-LH(16)*_fhr&&_fcb.x+_fcb.w>W-LH(220)*_fhr&&_fcb.y<_fy0+_fbh&&_fcb.y+_fcb.h>_fy0-LH(13)*_fhr){
    var _fbelow=_fcb.y+_fcb.h+LH(20)*_fhr, _fabove=_fcb.y-(_fn-1)*LH(22)*_fhr-LH(12)*_fhr;
    if(_fbelow+_fbh<=H*0.78) _fy0=_fbelow; else if(_fabove>=LH(20)*_fhr) _fy0=_fabove;
  }
'@

SubRx @'
var VER='19.57';
'@ @'
var VER='19.58';
'@

$pat = "(?m)^  now:'v19\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.58: In co-op the kill feed stays clear of the CONDITIONS panel wherever it is dragged. Check 19.58 fails on v19.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
