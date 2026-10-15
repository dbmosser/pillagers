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

# THE MAGNET LEAVES EVENT REWARDS AND PARTY BOXES ALONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!c||!mt[c.type]||!c.loot||!c.loot.length||G.searching===c) continue;
'@ @'
    if(!c||!mt[c.type]||!c.loot||!c.loot.length||G.searching===c) continue;
    if((c.tag&&EV_WRECK_TAGS[c.tag])||NET.on) continue;   // v27.45 (rvw3, cloud review 9): the reward of an event stays where the event put it, and in a party nobody drags boxes (each window would move its own copy and the host would answer FAR for a box the other player sees at his feet)
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.45 (rvw3), the CLOUD REVIEW of 2026-10-15, finding 9 (checked against the code): the MAGNET power-up pulled every body, bot wreck and CACHE within 520 toward you through walls and fences. The STRONGHOLD CACHE, the CONVOY CRATE and the
// GOLDEN HOARD are caches, so they slid out of a sealed stronghold to whoever stood at the fence; and in a party each window moved its own copy of a box, so the host answered FAR to a search of a box that the other player
// saw at his feet. The magnet does not touch the reward boxes of an event now, and in a party (two linked windows) it does not move boxes at all; it still pulls the pickups on the ground.
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.44';
'@ @'
var VER='27.45';
'@

$pat = "(?m)^  now:'v27\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.45: The magnet no longer drags event rewards, and moves no boxes in a party. Check 27.45 fails on v27.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
