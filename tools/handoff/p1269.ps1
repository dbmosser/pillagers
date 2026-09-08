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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
# THE SAME FAULT AS v12.65, ON THE OTHER SIDE OF THE SAME NUMBER.
#
# The XP a run pays for its haul is worked out from the whole backpack, and the
# backpack lands already holding whatever was staged. There is no limit on what
# can be staged, and every one of those items is handed straight back to the
# stash on extraction.
#
# So: put a hundred thousand of your own stash into the backpack, ride up, walk
# to the nearest extraction point, hold E. That pays about thirty five hundred
# XP for the haul, multiplied up by night and weather and a dose to something
# near six thousand, and the stash comes back untouched. Repeat. The whole
# reward track is walkable in a few hundred risk-free round trips with nothing
# found and nothing lost.
#
# It also poisons my own numbers. The haul on the run record and the career best
# both include value that was never looted, so every haul figure and every
# comparison I have taken off that log is inflated by whatever he happened to be
# carrying up.
#
# The game already knows how to correct it: the run earnings line subtracts what
# the lift carried in, and the banked record carries that figure. These two sites
# never subtracted it.
SubRx @'
  sp+=Math.round(((rec.haul||0)/1000)*35);
'@ @'
  // v12.69, 2026-09-08 audit: THE HAUL IS WHAT THE RUN BROUGHT BACK. This paid
  // on the whole backpack, and the backpack lands holding whatever was staged,
  // so a walk up and straight back down with his own stash in it paid XP for
  // loot he already owned and handed the stash back untouched. The run earnings
  // line has always subtracted what the lift carried in; this did not.
  sp+=Math.round((Math.max(0,(rec.haul||0)-(rec.carriedIn||0))/1000)*35);
'@

SubRx @'
    if(haul>P.best) P.best=haul;
'@ @'
    // v12.69: and the career best is the best haul he has BROUGHT BACK, not the
    // most he has ever carried up and down again. This is also the number my own
    // measurements read off the run log.
    var _netHaul=Math.max(0,haul-(G.carriedIn||0));
    if(_netHaul>P.best) P.best=_netHaul;
'@

# NEW IN.
SubRx @'
  'ANSWERING THE HIRE BENCH QUESTION LEAVES YOU AT THE BENCH. Pressing Hire nobody closed the bench behind its own confirm card, so saying no put you on the bare floor and saying yes redrew the bench where you could not see it.',
'@ @'
  'ANSWERING THE HIRE BENCH QUESTION LEAVES YOU AT THE BENCH. Pressing Hire nobody closed the bench behind its own confirm card, so saying no put you on the bare floor and saying yes redrew the bench where you could not see it.',
  'THE XP A RUN PAYS IS FOR WHAT YOU BROUGHT BACK. Carrying your own stash up the lift and straight back down paid full haul XP for loot you already owned, and handed the stash back untouched, so the whole reward track could be walked without finding anything.',
'@

# STAMPS.
SubRx @'
var VER='12.68';
'@ @'
var VER='12.69';
'@
SubRx @'
var WHATSNEW_VER='12.68';
'@ @'
var WHATSNEW_VER='12.69';
'@
$cnt=([regex]::Matches($s,"now:'v12\.68:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.68 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.68:[^']*'",{ param($m) "now:'v12.69: from the 2026-09-08 read-only audit, the same fault as v12.65 on the other side of the same number. The XP a run pays for its haul was worked out from the whole backpack, and the backpack lands already holding whatever was staged, with no limit on what can be staged and every one of those items handed straight back to the stash on extraction. So a hundred thousand of his own stash in the backpack, a ride up, a walk to the nearest extraction point and a hold of E paid about thirty five hundred XP for the haul, multiplied up by night and weather and a dose to something near six thousand, with the stash coming back untouched, and it repeats: the whole reward track is walkable in a few hundred risk-free round trips with nothing found and nothing lost. It also poisons my own numbers, because the haul on the run record and the career best both included value that was never looted, so every haul figure and comparison I have taken off that log is inflated by whatever he happened to be carrying up. The game already knows how to correct it, since the run earnings line subtracts what the lift carried in and the banked record carries that figure; these two sites never subtracted it. Honestly, this removes an XP faucet, so the track is longer than it was yesterday for anyone who was using it. Check 12.69 pays a run whose whole haul was carried up and requires no haul XP and no career best from it, with a control that the same value looted in the raid pays exactly what it always did; fails on v12.68.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
