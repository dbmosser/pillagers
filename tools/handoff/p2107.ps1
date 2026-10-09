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

# THE RING LABEL NEVER SHOWS THROUGH THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-zwid/2-6*_zr,zsy-LH(11)*_zr,zwid+12*_zr,LH(15)*_zr);
'@ @'
    // v21.07, from the whole-game bug hunt of 2026-10-08 (V-D5), seen on the 4K backpack screenshot: A RING LABEL NEVER PRINTS UNDER
    // THE OPEN BACKPACK. The label is drawn before the backpack panel, so where the two met the words showed faintly through the panel
    // and ran on past its edge, across B or I to close. While the backpack is open a label that would touch the panel (where it was
    // drawn last frame, G.bagPanel) is left out; the ring on the ground still shows, and the label is back when the backpack shuts.
    var _zbp=G.bagOpen?G.bagPanel:null;
    if(_zbp&&zcx-zwid/2-6*_zr<_zbp.x+_zbp.w&&zcx+zwid/2+6*_zr>_zbp.x&&zsy-LH(11)*_zr<_zbp.y+_zbp.h&&zsy+LH(4)*_zr>_zbp.y) continue;
    ctx.fillStyle='rgba(6,9,13,.78)';
    ctx.fillRect(zcx-zwid/2-6*_zr,zsy-LH(11)*_zr,zwid+12*_zr,LH(15)*_zr);
'@

SubRx @'
var VER='21.06';
'@ @'
var VER='21.07';
'@

$pat = "(?m)^  now:'v21\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.07: The extraction label no longer shows through the open backpack. Check 21.07 fails on v21.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
