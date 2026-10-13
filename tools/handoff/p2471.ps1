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

# THE HOW TO PLAY KEYS ARE VISIBLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
'#attract .arcpage table{margin:0 auto;border-collapse:collapse}
'@ @'
'#attract .arcpage table{margin:0 auto;border-collapse:collapse;color:inherit;font:inherit;letter-spacing:inherit}
'@

SubRx @'
function arcadeAttHow(pg){
'@ @'
// vNN.xx, UI REDESIGN ui5q1r (his #50, found by the visual lint of the attract HOW TO PLAY page): THE KEYS ARE VISIBLE. The page
// has no doctype, so the browser runs in quirks mode, where a table does not inherit colour or font from the page: the KEYBOARD and
// CONTROLLER cells were default black on the black page, and only the action names (coloured on their own) showed. The table
// inherits the colour, font and spacing of the page now (arcattcss), so every key reads in bone at the page size.
function arcadeAttHow(pg){
'@

SubRx @'
var VER='24.70';
'@ @'
var VER='24.71';
'@

$pat = "(?m)^  now:'v24\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.71: The arcade HOW TO PLAY page shows its keyboard and controller keys again. Check 24.71 fails on v24.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
