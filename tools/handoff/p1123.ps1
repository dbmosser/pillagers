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

# STAMPS ONLY. No game code changes: this build measures what happens to the
# pillagers over a whole raid and puts the number in front of him. Balance is
# frozen before the alpha by his order of 2026-09-04.
SubRx @'
var VER='11.22';
'@ @'
var VER='11.23';
'@
SubRx @'
var WHATSNEW_VER='11.22';
'@ @'
var WHATSNEW_VER='11.23';
'@
SubRx @'
  'NO BUILDING LOSES ITS ROOMS AND NO CORNER IS WALLED OFF BEHIND A TABLE. Measured on seven seeds of both maps: the repair pass that used to tear out interiors now touches nothing, and the little pockets of floor behind furniture are gone with the doorway rules.',
'@ @'
  'THE PILLAGERS GOT THEIR OWN SCORECARD. The test robot can now sit a whole raid out and watch what the other pillagers do to the end: how many get out, how many the machines take. Nothing changed in the raid; the numbers are on the board for a ruling.',
  'NO BUILDING LOSES ITS ROOMS AND NO CORNER IS WALLED OFF BEHIND A TABLE. Measured on seven seeds of both maps: the repair pass that used to tear out interiors now touches nothing, and the little pockets of floor behind furniture are gone with the doorway rules.',
'@
SubRx @'
  now:'v11.22: two STILL OPEN lines measured and closed. The v9.72 line said eight buildings on the mile stayed sealed after the repair pass; on seven seeds of both maps the pass now demolishes nothing and seals nothing, and with the yard-wall cut off it still does, so the instrument sees. The v10.40 niches behind furniture, 12 by 12 to 84 by 28, are gone on all five of its seeds with the doorway rules on, and back with them off.',
  next:'His grades on the new map looks, menus and gun rarity, and his ruling on the mile-vs-cold shape the board now shows'
'@ @'
  now:'v11.23: the pillagers own raid, read to the clock for the first time. Every pillager number before this was cut at the robot death, two minutes in, because the sim stops moving everything when the player dies or leaves. The player is parked out of the world and kept alive, the raid runs to its clock, and the roster is tallied: most pillagers die to the machines he set at war with them, few get out, and the floor rule keeps sending more. No dial moved; the numbers are on the board for his ruling.',
  next:'His ruling on the pillagers: machines at war with them (his Q31) plus the floor rule (his v6.71 note) means most die and few get out; leave it, or soften one of the two'
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
