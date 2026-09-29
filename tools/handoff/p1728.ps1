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

# PLAYER 2 CAN NO LONGER PICK UP OR PAY A PILLAGER OR SURVIVOR THE HOST RUNS, WHICH COPIED ITEMS AND STANDING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(DE.kind==='raider'&&DE.downed&&!DE.net&&dist(p,DE)<64){ downRdr=DE; break; }
'@ @'
    // v17.28, co-op hunt 2026-09-28: and on a linked window none is picked up at all. The bodies of the opening build are this
    // window own objects the host runs, never marked net, so player 2 was paid from a copy of the pack and his standing went up
    // by 3 on every press while the host kept the man down. A pick-up there waits for a word the host applies.
    if(DE.kind==='raider'&&DE.downed&&!DE.net&&!netEntsPeer()&&dist(p,DE)<64){ downRdr=DE; break; }
'@

SubRx @'
    if(SE.kind==='stray'&&!SE.helped&&dist(p,SE)<70){ stray=SE; break; }
'@ @'
    // v17.28, co-op hunt 2026-09-28: not on a linked window. The survivor there is a copy the host runs, so a hand over paid
    // player 2 900 to 1500 on this window alone and the next word from the host made him ask again, for another payout.
    if(SE.kind==='stray'&&!SE.helped&&!netEntsPeer()&&dist(p,SE)<70){ stray=SE; break; }
'@

SubRx @'
var VER='17.27';
'@ @'
var VER='17.28';
'@

$pat = "(?m)^  now:'v17\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.28: On a linked window (player 2 in the host raid) the downed pillager scan and the survivor scan in updatePlayer skip every body. The v16.62 guard only skipped bodies marked net, and the bodies of the opening build are the window own objects that the host runs, never marked, so player 2 was paid from a copy of the pack, his standing rose by 3 and was saved, and the next host snapshot put the man down again for another press. The survivor had no guard at all and paid 900 to 1500 per hand over. Both now test netEntsPeer; solo play, the host and the bot are untouched. Check 17.28 fails on v17.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
