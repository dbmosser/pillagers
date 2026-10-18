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

# No tutorial prompts in the demo raid (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeCardOn(){
  var p=G&&G.player, t;
'@ @'
function arcadeCardOn(){
  // v28.xx (cw-notutor), his answer Q70 (2026-10-18): "No tutorial prompts. The game must be completely self-explanatory." The controls card that
  // came up at every drop (and for 4 s after the shield) is gone from the raid; the HOW TO PLAY page on the attract and F1 keep the same rows.
  return 0;
  var p=G&&G.player, t;
'@

SubRx @'
tg='SHIELD \u00b7 MOVE TO START';
'@ @'
tg='Shield';   // v28.xx (cw-notutor), his Q70: the tag names the shield, it no longer tells him what to do
'@

SubRx @'
var VER='30.49';
'@ @'
var VER='30.50';
'@

$pat = "(?m)^  now:'v30\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.50: No controls card pops up when a demo run starts. Check 30.50 fails on v30.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
