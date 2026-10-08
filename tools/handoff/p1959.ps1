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

# A BOARD DRAGGED LOW STILL NAMES A RIVAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _rFit=Math.max(3,Math.floor((_rMax-LH(26))/LH1))-_rSum;
'@ @'
  var _rFit=Math.max(3,Math.floor((_rMax-LH(26))/LH1)-_rSum);   // v19.59, from the review (2026-10-08): the summary row comes out of the room above the floor, never out of the three-row floor (a board dragged low showed only YOU)
'@

SubRx @'
var VER='19.58';
'@ @'
var VER='19.59';
'@

$pat = "(?m)^  now:'v19\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.59: The pillager board always names at least one rival. Check 19.59 fails on v19.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
