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

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 3: AT THE DEFAULT CLOCK, RING CLOSURE LINES AND THE FOUR-MINUTE WARNING WERE
# OVERWRITTEN IN THE FRAME THEY WERE SAID. On the Standard 540-second raid one ring closes at 360 and another at 240, so at 6:00
# the closure of the first and the two-minute warning for the second are said in the same pass, and at 4:00 the closure of the
# second lands in the same frame as the minute warning. Both were plain say() calls, which hold one line with the last winning,
# so one of each pair was never on screen: the four-minute warning never showed on default settings. The two ring lines now wait
# their turn through the queue instead of writing over what is showing.
SubRx @'
      say('Extraction '+extLetter(cz)+' closes in two minutes.');
'@ @'
      sayWhenFree('Extraction '+extLetter(cz)+' closes in two minutes.');   // v14.11, HUD audit: waits its turn instead of writing over a line
'@
SubRx @'
      say('Extraction '+extLetter(cz)+' is closed.');   // v10.75: the letter, as everywhere else
'@ @'
      sayWhenFree('Extraction '+extLetter(cz)+' is closed.');   // v10.75: the letter, as everywhere else; v14.11: waits its turn
'@
SubRx @'
var VER='14.10';
'@ @'
var VER='14.11';
'@

$pat = "(?m)^  now:'v14\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.11: RING CLOSURE LINES WAIT THEIR TURN. Raid HUD and map screen audit of 2026-09-15, finding 3: on the default 540-second clock one ring closes at 360 and another at 240, so a closure and a two-minute warning were said in the same pass at 6:00 and a closure landed on the minute warning at 4:00, and both being plain say() calls one of each pair never showed. The ring lines now go through sayWhenFree. Check 14.11 runs one extraction tick in which one ring closes and another is warned, and requires both lines to survive, with a ring closing alone saying so as the control; it fails on v14.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
