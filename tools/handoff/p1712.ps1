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

# A KILL THAT REACHES PLAYER 2 AFTER HIS RAID ENDED NO LONGER CHANGES HIS FINISHED RUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||(NET.entDead&&NET.entDead[m.id|0])||null;   // v16.13: or the body the gone word just took off
'@ @'
  // v17.12, co-op hunt 2026-09-28: only while this raid is running, up top on the party seed, as a hit word is. The host keeps his raid
  // going for the party, so a man player 2 had downed could bleed out after player 2 died or extracted, and the kill word then raised
  // the finished run, whose logged row shares those counts, and stepped a contract on the board refilled when the run ended.
  if(!netEntsPeer()) return 'down';
  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||(NET.entDead&&NET.entDead[m.id|0])||null;   // v16.13: or the body the gone word just took off
'@

SubRx @'
var VER='17.11';
'@ @'
var VER='17.12';
'@

$pat = "(?m)^  now:'v17\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.12: Kill credit, co-op hunt 2026-09-28: netKillTake on the player 2 window checked only that a raid was in hand, not that it was still running. When player 2 downed a pillager and then died or extracted with player 1 still up top, the man bled out on the host, netEntGone sent the kill word to his seat, and it raised G.tel.kills after endRaid had banked the kills (the pending run row holds that same object, so the logged row gained it) and ran contractKill on the board ensureContracts had refilled at the end of the run, which could step or finish a contract issued after the run. netKillTake now refuses the word unless netEntsPeer holds (linked, up top on the party seed, raid not over), as netHitTake already does. A kill word while player 2 is up top still counts. No number and no player text moved. Check 17.12 fails on v17.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
