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

# THE ICON FILLS ITS CELL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .invgrid .ic{ image-rendering:auto; }   /* v18.09: painted sharp at four times the row size and scaled down smooth (was pixelated) */
'@ @'
  .invgrid .ic{ image-rendering:auto; }   /* v18.09: painted sharp at four times the row size and scaled down smooth (was pixelated) */
  /* v18.12, HIS ORDER (2026-10-03, the item graphics): THE ICON FILLS ITS CELL. A 40 px picture sat in a 200 px stash cell, so
     the thing you were looking at was a tenth of its box. The stash and backpack cells show the icon at 62 percent of the cell
     at every layout, the shop cells at 44 percent, and the belt keys keep their small picture. The painters draw at up to six
     times the row size (v18.09), so the big picture is a sharp one. */
  #hub .invgrid .cell:not([data-plan]) .ic{ width:62% !important; height:62% !important; }
  #stagemodal .invgrid .cell:not([data-plan]) .ic{ width:62% !important; height:62% !important; }
  .vcell .ic{ width:44% !important; height:44% !important; }
'@

SubRx @'
  var R=Math.min(4,Math.max(1,Math.ceil(160/S)));
  var cnv=document.createElement('canvas'); cnv.width=S*R; cnv.height=S*R;
  var c2=cnv.getContext('2d');
  drawItemIcon
'@ @'
  var R=Math.min(6,Math.max(1,Math.ceil(180/S)));   // v18.12: up to six times, for the cell-filling picture
  var cnv=document.createElement('canvas'); cnv.width=S*R; cnv.height=S*R;
  var c2=cnv.getContext('2d');
  drawItemIcon
'@

SubRx @'
  var R=Math.min(4,Math.max(1,Math.ceil(160/S)));   // v18.09: painted sharp, as the item icons are
'@ @'
  var R=Math.min(6,Math.max(1,Math.ceil(180/S)));   // v18.09: painted sharp, as the item icons are; v18.12: up to six times
'@

SubRx @'
var VER='18.11';
'@ @'
var VER='18.12';
'@

$pat = "(?m)^  now:'v18\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.12: Item and gun pictures now fill their cells in the stash, backpack and shop instead of sitting small in the middle. Check 18.12 fails on v18.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
