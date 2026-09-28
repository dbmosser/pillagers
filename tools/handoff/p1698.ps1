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

# A ROUND OR CHARGE ON A PILLAGER WHO HAS JUST BLED OUT NO LONGER TAKES THE KILL FROM PLAYER 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var e=G.ents[i],de=dist(e,f);
'@ @'
    var e=G.ents[i],de=dist(e,f);
    if(e.finished) continue;   // v16.98, co-op hunt 2026-09-28: a man who bled out lies here one more frame; a charge on the body wrote the kill mark again and took the kill from player 2, so it passes him as lightning does
'@

SubRx @'
            if(en.roll>0.08) continue;
'@ @'
            if(en.roll>0.08) continue;
            if(en.finished) continue;   // v16.98, co-op hunt 2026-09-28: a man who bled out lies here one more frame; a round on the body wrote the kill mark again and took the kill from player 2, so it passes over him
'@

SubRx @'
            if(en3===b.owner) continue;
'@ @'
            if(en3===b.owner) continue;
            if(en3.finished) continue;   // v16.98, co-op hunt 2026-09-28: the same for an enemy round, which wiped the player 2 seat mark off a man who had just bled out
'@

SubRx @'
var VER='16.97';
'@ @'
var VER='16.98';
'@

$pat = "(?m)^  now:'v16\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.98: Kill credit, co-op hunt 2026-09-28: a pillager who bleeds out is marked finished with no health and is only taken off the map on the next frame, but rounds and charges are stepped in between. The enemy round loop, the player round loop and explodeFrag had no skip for that body (the lightning strike loop did), so a round or charge on it ran the killing blow branch again and set bySeat to 0 or byPlayer to true, and netEntGone then sent no kill word to player 2 or gave the kill to the host. All three loops now skip a finished body, so the round or charge passes over it. A downed man is not finished and can still be shot and finished off. No number and no player text moved. Check 16.98 fails on v16.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
