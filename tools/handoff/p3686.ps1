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

# BUILDINGS READ IN THE SMOOTH LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _bf=(_px&&b3.kind)?bldKindFloor(b3):bldFloor(b3);   // v34.xx (cw-bldkinds): the pixel look floors by kind, the vector bake keeps its own
'@ @'
    var _bf=b3.kind?bldKindFloor(b3):bldFloor(b3);   // v34.xx (cw-bldkinds), v36.xx (cw-bldsmooth) his priorities note 10-20 (is this a house, an office, a warehouse): the smooth look floors by kind too, not only the pixel look
'@

SubRx @'
    if(_px&&b3.kind) pixKindDetail(c,b3,_ix,_iy,_iw,_ih,_lw);
'@ @'
    if(b3.kind) pixKindDetail(c,b3,_ix,_iy,_iw,_ih,_lw);   // v36.xx (cw-bldsmooth): both looks, so a house, an office and a warehouse read apart in the smooth look
'@

SubRx @'
var VER='36.85';
'@ @'
var VER='36.86';
'@

$pat = "(?m)^  now:'v36\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.86: Houses, offices, warehouses, shops and workshops now have their own floors and details in the smooth look too. Check 36.86 fails on v36.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
