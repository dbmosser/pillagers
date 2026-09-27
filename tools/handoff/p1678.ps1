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

# CLOCK ALARMS DOWN TO A QUARTER (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
      cwg.gain.setValueAtTime(.04*vol,cwt); cwg.gain.setValueAtTime(.04*vol,cwt+.2);
'@ @'
      // v16.78, his order: still too loud after v16.30 took them to a third; a quarter of that level again, .04 to .01
      cwg.gain.setValueAtTime(.01*vol,cwt); cwg.gain.setValueAtTime(.01*vol,cwt+.2);
'@

SubRx @'
    ckg.gain.setValueAtTime(.03*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);   // v16.30: a third of the level
'@ @'
    // v16.78, his order: the last ten seconds tick goes down with the clock alarms, a quarter of the v16.30 level, .03 to .0075
    ckg.gain.setValueAtTime(.0075*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);
'@

SubRx @'
var VER='16.77';
'@ @'
var VER='16.78';
'@

$pat = "(?m)^  now:'v16\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.78: THE CLOCK ALARMS DROP TO A QUARTER. His note: the 5 minutes left alarm and the other clock marks were still too loud after v16.30. The warning tone and the last ten seconds tick now play at a quarter of that level; nothing else moves. Check 16.78 fails on v16.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
