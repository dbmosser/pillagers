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

# CONTRACTS, NOTORIETY AND WAVES AUDIT OF 2026-09-14, finding 6: THE NOTORIETY FADE COUNTER SURVIVED THE
# STRAY CLEARING YOUR NOTORIETY. A point of notoriety fades after four extractions: P.notExt counts
# them while notoriety is above zero, and resets only when a point fades. Helping a Stray takes a
# point off without touching the counter. So at notoriety 1 with three extractions counted, a Stray
# took it to zero with the count still at three, and the next point earned faded after a single
# extraction instead of four. Clearing the last point clears the count with it.
SubRx @'
    P.notoriety--;
    sayWhenFree('Word of that will travel too. Notoriety '+P.notoriety+'.');
'@ @'
    P.notoriety--;
    if(P.notoriety<=0) P.notExt=0;   // v13.95, contracts audit: the fade count goes with the last point
    sayWhenFree('Word of that will travel too. Notoriety '+P.notoriety+'.');
'@
SubRx @'
var VER='13.94';
'@ @'
var VER='13.95';
'@

$pat = "(?m)^  now:'v13\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.95: A STRAY CLEARING YOUR NOTORIETY CLEARS ITS FADE COUNT. Contracts, notoriety and waves audit of 2026-09-14, finding 6: a point of notoriety fades after four extractions counted on P.notExt, which resets only when a point fades, and helping a Stray took a point off without touching it, so at notoriety 1 with three counted the Stray took it to zero with three still counted and the next point faded after one extraction. Clearing the last point now clears the count. Check 13.95 helps a Stray at notoriety 1 with three counted and requires both at zero, with notoriety 2 keeping its count as the control; it fails on v13.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
