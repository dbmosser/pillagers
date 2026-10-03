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

# THE ITEM ICONS ARE PAINTED SHARP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var cnv=document.createElement('canvas'); cnv.width=S; cnv.height=S;
  var c2=cnv.getContext('2d');
  drawItemIcon(c2,key,S/2,S/2,S*0.82);
'@ @'
  // v18.09, HIS ORDER (2026-10-03, "item graphics like the guns still look terrible"): THE ICONS ARE DRAWN SHARP. Every icon the
  // menus show was painted once at its row size, 22 to 30 pixels, and then blown up to 40, 64 or 110 by the stash layouts with
  // image-rendering:pixelated, so a gun was a handful of blocks. The painters are vector shapes, so the icon is painted at
  // four times its row size (up to 160 across) and the browser scales it down smooth; every layout now shows real edges.
  var R=Math.min(4,Math.max(1,Math.ceil(160/S)));
  var cnv=document.createElement('canvas'); cnv.width=S*R; cnv.height=S*R;
  var c2=cnv.getContext('2d');
  drawItemIcon(c2,key,S*R/2,S*R/2,S*R*0.82);
'@

SubRx @'
  var cnv=document.createElement('canvas'); cnv.width=S; cnv.height=S;
  var c2=cnv.getContext('2d');
  mercPortrait(c2,id,S/2,S/2,S*0.86);
'@ @'
  var R=Math.min(4,Math.max(1,Math.ceil(160/S)));   // v18.09: painted sharp, as the item icons are
  var cnv=document.createElement('canvas'); cnv.width=S*R; cnv.height=S*R;
  var c2=cnv.getContext('2d');
  mercPortrait(c2,id,S*R/2,S*R/2,S*R*0.86);
'@

SubRx @'
  .invgrid .ic{ image-rendering:pixelated; }
'@ @'
  .invgrid .ic{ image-rendering:auto; }   /* v18.09: painted sharp at four times the row size and scaled down smooth (was pixelated) */
'@

SubRx @'
var VER='18.08';
'@ @'
var VER='18.09';
'@

$pat = "(?m)^  now:'v18\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.09: Item and gun icons are drawn sharp in every menu instead of blown-up blocks. Check 18.09 fails on v18.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
