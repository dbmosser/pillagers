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

# RAID HUD TYPE SIZES MERGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HUDZ={body:1.40, gear:1.36, raiders:1.15, legend:1.5, cond:1.05};
'@ @'
var HUDZ={body:1.36, gear:1.36, raiders:1.08, legend:1.5, cond:1.05};   // v28.xx (cw-hudtype), the critic on screens 21, 19, 37, 61: 'too many type sizes'. The vitals share the gun card's 1.36 (was 1.40) so their words land on the same sizes, and the pillager board is 16 px at 1080p, the guide's label size (was 17). The top-right column (cond) stays as he placed it.
'@

SubRx @'
var VER='34.24';
'@ @'
var VER='34.25';
'@

$pat = "(?m)^  now:'v34\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.25: The health, stamina and status words are a hair smaller; the pillager board words are 16 px. Check 34.25 fails on v34.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
