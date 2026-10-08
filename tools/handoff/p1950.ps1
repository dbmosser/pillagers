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

# THE RUN CARD FADE STAYS IN THE GAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ocacts::before{ content:''; position:absolute; left:0; right:0; top:-28px; height:28px; pointer-events:none;
'@ @'
  .ocacts::before{ content:''; position:absolute; left:0; right:0; top:-14px; height:14px; pointer-events:none;   /* v19.50, from the review (2026-10-08): inside the 14px gap above the row, so on a card that does not scroll it no longer veils the note box */
'@

SubRx @'
var VER='19.49';
'@ @'
var VER='19.50';
'@

$pat = "(?m)^  now:'v19\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.50: The run card note box is never veiled. Check 19.50 fails on v19.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
