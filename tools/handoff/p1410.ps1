$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 7: THE SURVIVOR'S [E] GIVE PROMPT SHOWED WHERE E DID NOTHING FOR HIM.
# The prompt over a found survivor who wants something you carry was drawn within 120 units, but E only hands the item over
# within 70. Between 70 and 120 the prompt named the key, and pressing it gave nothing and said nothing, or went to a nearby
# crate or ring instead. The prompt now appears only where the key works.
SubRx @'
      if(dist(_se,p)>120) continue;
'@ @'
      if(dist(_se,p)>70) continue;   // v14.10, HUD audit: the prompt only where E hands the item over (70), not out to 120
'@
SubRx @'
var VER='14.09';
'@ @'
var VER='14.10';
'@

$pat = "(?m)^  now:'v14\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.10: THE GIVE PROMPT SHOWS ONLY WHERE E GIVES. Raid HUD and map screen audit of 2026-09-15, finding 7: the [E] GIVE prompt over a found survivor was drawn within 120 units while E only hands the item over within 70, so between the two the prompt named a key that gave nothing. The prompt now uses the same 70. Check 14.10 traces the HUD text with a survivor who wants a carried item at 100 units and requires no GIVE prompt, with the survivor at 50 units drawing it as the control; it fails on v14.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
