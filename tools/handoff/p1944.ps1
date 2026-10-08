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

# THE RAIDER BOARD HOLDS ITS SUMMARY LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _rFit=Math.max(3,Math.floor((_rMax-LH(26))/LH1));
'@ @'
  // v19.44, seen on the 4K downed screenshot (2026-10-08): the "N out, N down" line under the names had no row of its own in the box,
  // so the panel's bottom edge ran through it. When it shows, it is given a row like the names.
  var _rSum=(!HOr.c&&out+dead>0)?1:0;
  var _rFit=Math.max(3,Math.floor((_rMax-LH(26))/LH1))-_rSum;
'@

SubRx @'
  var boxH=HOr.c?LH(18):(LH(20)+_rShown*LH1+LH(6));
'@ @'
  var boxH=HOr.c?LH(18):(LH(20)+(_rShown+_rSum)*LH1+LH(6));
'@

SubRx @'
var VER='19.43';
'@ @'
var VER='19.44';
'@

$pat = "(?m)^  now:'v19\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.44: The out and down line on the pillager board sits inside the board. Check 19.44 fails on v19.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
