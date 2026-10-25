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

# RAID BACKPACK GRID FILLS THE CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var TILE=LH(54)*BZ,GAP=
'@ @'
var TILE=Math.max(88*BZ,LH(54)*BZ),GAP=
'@

SubRx @'
var rowsAll=Math.max(1,Math.ceil(stacks.length/COLS));
'@ @'
var rowsAll=Math.max(2,Math.ceil(stacks.length/COLS));   // v28.xx (cw-bagtiles), the critic (2026-10-20: a tiny 3-item grid, a small under-filled box): the grid is 88 px tiles (style guide Tile) and always shows at least two rows of cells, empty ones drawn quiet, so the card is filled by its grid; no change to what is carried
'@

SubRx @'
if(si>=stacks.length) break;
'@ @'
if(si>=stacks.length){ var _ex=gx+c2*(TILE+GAP), _ey=cy+r2*(TILE+GAP); ctx.fillStyle='#16191b'; ctx.fillRect(_ex,_ey,TILE,TILE); ctx.strokeStyle='#2e3337'; ctx.lineWidth=1; ctx.strokeRect(_ex+.5,_ey+.5,TILE-1,TILE-1); continue; }
'@

SubRx @'
var hh=LH(226)*BZ+rows
'@ @'
var hh=LH(236)*BZ+rows
'@

SubRx @'
ctx.font=bFS(TYPE.head);
    ctx.fillStyle='#efe9dc';
    ctx.fillText((sit?sit.name
'@ @'
ctx.font=bFS(TYPE.title);   // v28.xx (cw-bagtiles), the critic: one hero, the selected item name at the screen title size
    ctx.fillStyle='#efe9dc';
    ctx.fillText((sit?sit.name
'@

SubRx @'
var VER='34.64';
'@ @'
var VER='34.65';
'@

$pat = "(?m)^  now:'v34\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.65: The raid backpack shows a full grid of larger tiles and a bigger selected item name. Check 34.65 fails on v34.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
