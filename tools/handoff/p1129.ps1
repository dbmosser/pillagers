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

# ONE: the sector screen's figures were the v8.01 robot, two eras stale, and
# the screen never said whose they were. Refreshed from 120 seeds per map on
# v11.25 at the pinned defaults, and labelled as the test robot's.
SubRx @'
  {ext:18.0,fc:70, cont:5.3,haul:2984},
  {ext:23.5,fc:34, cont:5.2,haul:2662}
'@ @'
  // v11.29: 120 seeds per map on v11.25, the robot at its pinned greed, the
  // shipping rules. The v8.01 rows (18.0 / 70 / 5.3 / 2984 and 23.5 / 34 /
  // 5.2 / 2662) had been on the screen for three hundred builds while the
  // robot's real rate doubled with the door builds of v11.12 to v11.20.
  {ext:39.2,fc:35, cont:5.2,haul:1865},
  {ext:38.3,fc:37, cont:5.5,haul:1690}
'@
SubRx @'
    if(MS.ext!==undefined) facts.push('measured extraction '+MS.ext+'%');
'@ @'
    if(MS.ext!==undefined) facts.push('the test robot extracts '+MS.ext+'% of its raids here');
'@

# TWO: the death card's XP line counted toward the season's last reward,
# 1,200,000, and his v8.91 note took the sentence that explained it off the
# death card. A friend's first death read "+67 XP, 67 of 1,200,000". On a death
# card the line now gives the total and nothing to measure it against; the
# extraction card keeps its "of" and its "Next:" sentence.
SubRx @'
        '  &middot;  '+Math.min(cap,_xa).toLocaleString()+' of '+cap.toLocaleString()+
'@ @'
        (how==='dead'
          ? '  &middot;  '+_xa.toLocaleString()+' XP in all'
          : '  &middot;  '+Math.min(cap,_xa).toLocaleString()+' of '+cap.toLocaleString())+
'@

# STAMPS.
SubRx @'
var VER='11.28';
'@ @'
var VER='11.29';
'@
SubRx @'
var WHATSNEW_VER='11.28';
'@ @'
var WHATSNEW_VER='11.29';
'@
SubRx @'
  'THE BACKPACK ARROWS BEHAVE WHEN EVERYTHING IS ON THE BELT. With every carried item claimed by a tactical belt key the backpack grid is empty, and an arrow key used to throw the selection away. It now does nothing until there is something to select.',
'@ @'
  'THE SECTOR SCREEN TELLS THE TRUTH AGAIN. Its "measured extraction" figures were three hundred builds old and half the real number; they are fresh, and they say whose they are: the test robot. And a death card no longer measures your first 67 XP against the last reward of the season.',
  'THE BACKPACK ARROWS BEHAVE WHEN EVERYTHING IS ON THE BELT. With every carried item claimed by a tactical belt key the backpack grid is empty, and an arrow key used to throw the selection away. It now does nothing until there is something to select.',
'@
SubRx @'
  now:'v11.28: the backpack arrow keys divided by zero. The guard tested the bag length and the arithmetic used the stack count, and bagStacks hides every copy a belt key claims, so with the whole backpack on the belt an arrow made the selection NaN. drawBag clamped it back each frame, so it never threw, which is why nobody saw it; the selection was lost and Z would have dropped from index -1. The guard now tests the stacks. Reproduced with one belted SMG, arrow left, selection NaN.',
'@ @'
  now:'v11.29: the first hour past the floor, walked on a fresh profile: title, sector screen, loadout question, drop, death card, return. Two things were wrong and are fixed: the sector screen showed v8.01 robot figures (18 and 23.5 percent) as "measured extraction" while the robot extracts about 39 now, so they are refreshed from 120 seeds a map and labelled as the robot; and a death card measured a first 67 XP against the 1,200,000 of the season last reward, with the explaining sentence removed at v8.91, so it now says the total and nothing else.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
