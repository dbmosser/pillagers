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

# A MAN SENT AFTER YOU SEARCHES THE RIGHT PLACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function searchSector(e){
  if(e.searchX!==undefined) return;
  if(e.tx===undefined||e.ty===undefined){ e.searchX=e.x; e.searchY=e.y; return; }
'@ @'
function searchSector(e){
  // v20.28, from the whole-game bug hunt of 2026-10-08 (H7): a search point was cleared only when he saw you, so a man who lost
  // you once and was later shot from cover, or called by his crew, kept walking to his OLD search point, sometimes across the map.
  // A search point now belongs to the target it was built for, and a new target more than 90 units away builds a new one.
  if(e.searchX!==undefined){
    if(e.searchFx===undefined||e.tx===undefined||e.ty===undefined||(Math.abs(e.searchFx-e.tx)<=90&&Math.abs(e.searchFy-e.ty)<=90)) return;
    delete e.searchX; delete e.searchY; delete e.searchArc;
  }
  if(e.tx===undefined||e.ty===undefined){ e.searchX=e.x; e.searchY=e.y; return; }
  e.searchFx=e.tx; e.searchFy=e.ty;
'@

SubRx @'
var VER='20.27';
'@ @'
var VER='20.28';
'@

$pat = "(?m)^  now:'v20\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.28: Pillagers and machines you shoot from cover come looking where you are, not where you used to be. Check 20.28 fails on v20.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
