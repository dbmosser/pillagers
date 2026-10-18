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

# A NEW CODEX GUN IS ONE FEED LINE, NOT TWO CALLOUTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
try{ say('CODEX ENTRY','info',
'@ @'
try{ /* v31.xx (cw-codexfeed), the critic on screen 36 (2026-10-19): a new gun showed twice, top centre and bottom left. say() puts every line in the feed AND the top lane, so this one goes to the feed only (a quiet note, not an alert). */ feedSay('CODEX ENTRY','info',
'@

SubRx @'
var VER='31.50';
'@ @'
var VER='31.51';
'@

$pat = "(?m)^  now:'v31\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.51: A gun you find for the first time is noted once in the left feed, no longer twice on screen. Check 31.51 fails on v31.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
