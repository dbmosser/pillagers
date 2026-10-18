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

# Clean the swearing out of the baked on-screen lines (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  You cheap bastard.
'@ @'
  You cheapskate.
'@

SubRx @'
Shit's about to get real.
'@ @'
Things are about to get real.
'@

SubRx @'
This is some shit Claude came up with.
'@ @'
This is some wild idea Claude came up with.
'@

SubRx @'
var TXSHIP={
'@ @'
// v28.xx (cw-cleanwords), HIS ANSWER (2026-10-18, Q76): clean the swearing out of on-screen lines and keep the attitude. Three of his baked lines
// (Q8: a changed line gets its reason in notes/ui/changes.md): "You cheap bastard." is now "You cheapskate.", "Shit's about to get real." is now
// "Things are about to get real.", and "This is some shit Claude came up with." is now "This is some wild idea Claude came up with."
var TXSHIP={
'@

SubRx @'
var VER='30.27';
'@ @'
var VER='30.28';
'@

$pat = "(?m)^  now:'v30\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.28: Three on-screen lines lost their swearing and kept their attitude. Check 30.28 fails on v30.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
