$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\lint.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# CLASS E, ADDED 2026-09-12 AFTER v13.03 FOUND ONE BY HAND. Two spellings of one
# thing is his own rule broken, and it has a second cost that is easy to miss: his
# text edits are matched on the WHOLE string, so a line written two ways takes his
# rewrite of it to one of the two places and not the other. That is exactly what the
# experimental warning did, capitals on the hire tab and mixed case on the floor.
#
# CASE ONLY, AND PROSE ONLY, and both narrowings were measured rather than guessed.
# The first cut grouped on letters and digits alone and returned 65 hits, nearly all
# of them markup fragments, colour values and selector strings that happen to collide
# once punctuation is stripped. That is the same mistake class A made with a lazy
# regex. Differences of punctuation and spacing are ordinary; what splits his edits is
# the same words spelled two ways.
SubRx @'
Say ('TOTALS  A=' + $aHits + '  B=' + $bHits + '  C=' + $cHits + '  D=' + $dHits)
'@ @'
# ---------------------------------------------------------------- CLASS E
# ONE THING SPELLED TWO WAYS. His rule is one word per thing, and there is a second
# cost: his text edits are matched on the whole string, so a line written two ways
# takes his rewrite of it to one of the two and not the other. v13.03 is exactly that,
# the experimental warning in capitals on the hire tab and mixed case on the floor.
$eHits = 0
Say '## E. one thing spelled two ways'
Say ''
$seen = @{}
foreach ($m in [regex]::Matches($s2, "'([^'\\\r\n]{8,120})'")) {
  $t = $m.Groups[1].Value
  if ($m.Index -gt 0 -and $s2[$m.Index - 1] -match '[A-Za-z]') { continue }
  if (($m.Index + $m.Length) -lt $s2.Length -and $s2[$m.Index + $m.Length] -eq ':') { continue }
  # Prose or a sign he reads, not markup, not a selector, not a colour.
  if ($t -match '[<>{}#\\]') { continue }
  if ($t -match 'data-|ctx\.|rgba|px |span ') { continue }
  if (($t -split ' ').Count -lt 2) { continue }
  if ($t -notmatch '^[A-Za-z*][A-Za-z *.,:;!?()%@-]+$') { continue }
  # CASE ONLY: punctuation and spacing differences are ordinary English.
  $norm = $t.ToLower()
  if (-not $seen.ContainsKey($norm)) { $seen[$norm] = New-Object Collections.ArrayList }
  if (-not $seen[$norm].Contains($t)) { [void]$seen[$norm].Add($t) }
}
foreach ($k in $seen.Keys) {
  if ($seen[$k].Count -lt 2) { continue }
  $eHits++
  Say ("  " + (($seen[$k] | ForEach-Object { '[' + $_ + ']' }) -join ' vs '))
}
Say ''

Say ('TOTALS  A=' + $aHits + '  B=' + $bHits + '  C=' + $cHits + '  D=' + $dHits + '  E=' + $eHits)
'@

SubRx @'
$lines = $s -split "\r?\n"
'@ @'
$lines = $s -split "\r?\n"
# Class E reads the game WITHOUT his baked edit map, whose keys and replacements are
# the same sentence twice by design and would be most of the list.
$s2 = $s
$_e0 = $s2.IndexOf('var TXSHIP=')
if ($_e0 -ge 0) {
  $_e1 = $s2.IndexOf("`n", $_e0)
  if ($_e1 -gt $_e0) { $s2 = $s2.Substring(0, $_e0) + $s2.Substring($_e1) }
}
'@

SubRx @'
Write-Output ('LINT  dials-never-read=' + $aHits + '  banned-words=' + $bHits + '  unstamped-migrations=' + $cHits + '  overwritten-lines=' + $dHits + ' (' + ($dSeen - $dHits) + ' cleared)')
'@ @'
Write-Output ('LINT  dials-never-read=' + $aHits + '  banned-words=' + $bHits + '  unstamped-migrations=' + $cHits + '  overwritten-lines=' + $dHits + ' (' + ($dSeen - $dHits) + ' cleared)' + '  two-spellings=' + $eHits)
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
