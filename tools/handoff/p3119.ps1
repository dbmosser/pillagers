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

# TITLE: THE FIGHT BEHIND THE SCOREBOARD READS (BLUR 5 TO 2PX) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract{ -webkit-backdrop-filter:blur(5px); backdrop-filter:blur(5px);
'@ @'
/* v31.xx (cw-title-sharp), his Q52/Q54 "REAL pillager-versus-robot combat" and "it must not cost frame rate: 60 fps at 4K": the 5px blur smeared the two tiny fights behind the scoreboard and how-to into mud (shot 03-r8/45) and is a full-screen blur of a moving canvas every frame at 4K. 2px keeps the glass and lets the fight read, and the pass is cheaper. */
body #attract{ -webkit-backdrop-filter:blur(2px); backdrop-filter:blur(2px);
'@

SubRx @'
var VER='31.18';
'@ @'
var VER='31.19';
'@

$pat = "(?m)^  now:'v31\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.19: The fight behind the scoreboard and how-to reads clearly. Check 31.19 fails on v31.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
