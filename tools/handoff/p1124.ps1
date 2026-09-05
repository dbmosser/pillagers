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

# STAMPS ONLY. No game code changes: v11.24 corrects a misreading in v11.23's
# notes and gives the pillager scorecard a second vantage point.
SubRx @'
var VER='11.23';
'@ @'
var VER='11.24';
'@
SubRx @'
var WHATSNEW_VER='11.23';
'@ @'
var WHATSNEW_VER='11.24';
'@
SubRx @'
  'THE PILLAGERS GOT THEIR OWN SCORECARD. The test robot can now sit a whole raid out and watch what the other pillagers do to the end: how many get out, how many the machines take. Nothing changed in the raid; the numbers are on the board for a ruling.',
'@ @'
  'THE SCORECARD CAN WATCH THE CREWS FEUD TOO. Rival crews only pick fights within sight of you, by design, so the scorecard now has a seat in the middle of the map as well as one outside it. Checked: they do shoot each other where you can see it.',
  'THE PILLAGERS GOT THEIR OWN SCORECARD. The test robot can now sit a whole raid out and watch what the other pillagers do to the end: how many get out, how many the machines take. Nothing changed in the raid; the numbers are on the board for a ruling.',
'@
SubRx @'
  now:'v11.23: the pillagers own raid, read to the clock for the first time. Every pillager number before this was cut at the robot death, two minutes in, because the sim stops moving everything when the player dies or leaves. The player is parked out of the world and kept alive, the raid runs to its clock, and the roster is tallied: most pillagers die to the machines he set at war with them, few get out, and the floor rule keeps sending more. No dial moved; the numbers are on the board for his ruling.',
'@ @'
  now:'v11.24: a correction to v11.23 and a second vantage point. v11.23 read zero pillager-on-pillager deaths off the raid with the player parked out of the world and called the feud system dead; feuds fire only within 600 units of the player, by design, because line of sight is only answerable near him. Parked in the middle of the map instead, rival crews shoot each other: hits, downs and deaths in one raid at peace with the machines. The scorecard hook takes a park option now, and a check holds the feud dial to that.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
