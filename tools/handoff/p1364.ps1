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

# IN-RAID AUDIT OF 2026-09-14, finding 1: A MEDKIT COULD BE SPENT AT FULL HEALTH.
# tickHeal cleared the queue when there was no room left under the running heal's ceiling,
# but left the ceiling itself behind. With a Bandage's 85 still stored and his health back
# at full by any other route, every medical test reads what he can reach as 85, so the
# Medkit was not refused as Already at full and was spent for nothing.
SubRx @'
  if(room<=0){ p.healQ=0; p.healRate=0; return; }
'@ @'
  // v13.63, in-raid audit: the ceiling goes with the queue, as it does when the queue runs
  // out below. Left behind, a Bandage's 85 made every later test read full health as 85.
  if(room<=0){ p.healQ=0; p.healRate=0; p.healCap=undefined; return; }
'@
SubRx @'
var VER='13.63';
'@ @'
var VER='13.64';
'@

$pat = "(?m)^  now:'v13\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.64: A MEDKIT IS NOT SPENT AT FULL HEALTH. In-raid audit of 2026-09-14, finding 1: tickHeal cleared the queue when there was no room under the running ceiling but kept the ceiling, so with a Bandage 85 still stored and health back at full, every medical test read his reach as 85 and a Medkit was used for nothing. The ceiling now clears with the queue. Check 13.64 runs a Bandage into its ceiling, brings health to full, and requires the Medkit refused and kept, with a Medkit at 50 health spent as the control; it fails on v13.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
