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

# A TEAMMATE WHOSE RAID ENDED WHILE HE WAS DOWN NO LONGER BLOCKS E IN THE EXTRACTION RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!g||!g.dn||g.seat===NET.seat||netSeatName(g.seat)===null||g.sd!==(NET.upSeed>>>0)) continue;
'@ @'
    // v16.94, co-op hunt 2026-09-28: a teammate whose raid ended while he was down is nobody to pick up. His last position word
    // can land after his out word (the fast channel is unordered) and file him down on that spot for the rest of the raid, so E
    // held there started a pick-up every 3.2 s and never reached the ring pull. A seat marked out on this seed (netUpGone), or
    // one whose word went stale and is no longer drawn (netUpShown), is skipped, as the pick-up wait already reads them.
    if(!g||!g.dn||!netUpShown(g)||netUpGone(g)||g.seat===NET.seat||netSeatName(g.seat)===null||g.sd!==(NET.upSeed>>>0)) continue;
'@

SubRx @'
var VER='16.93';
'@ @'
var VER='16.94';
'@

$pat = "(?m)^  now:'v16\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.94: netMateDown picked any teammate up top whose word said down, on this raid seed, with no test of whether his raid had already ended or his word had gone stale. A last position word on the unordered fast channel can land after the out or spec word of a player who extracted from the floor, and it files him down on that spot for good, since nothing drops a stale entry. netRevHold then took E every step within 64 of that spot, sent a refused pick-up every 3.2 seconds and started again, so tryExtractTick never saw E and the other player could not pull out of that ring (X on the pad too, since it maps to E while netMateDown finds someone). netMateDown now skips a seat marked out on this seed (netUpGone) and one that is not drawn any more (netUpShown), the same tests the pick-up wait and the spectating host already use. A teammate who is down with fresh words is picked up as before. No number moved. Check 16.94 fails on v16.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
