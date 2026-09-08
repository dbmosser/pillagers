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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, confirmed by a skeptic and then by me
# reading both sites. IT IS MY OWN HALF-DONE FIX FROM v8.58, FOUND AGAIN.
#
# The death card says "KILLED BY X, N M FROM EXTRACTION". That N is measured to
# G.active, which is not the nearest way out: it is a ring the dice picked when
# the raid was built, and it is only ever re-pointed when he physically stands in
# a ring or when the one it points at closes. A player who dies without ever
# reaching a ring, which is exactly how a first raid ends, is measured against a
# ring chosen at random for him.
#
# Meanwhile the compass over his head has spent the whole raid pointing at the
# NEAREST OPEN ring, and the line directly under this one on the same card,
# "CLOSEST YOU CAME TO EXTRACTION", is measured the same way. So the card
# disagrees with the compass he was following and with itself.
#
# The helper that measures the nearest open ring already exists. I wrote it at
# v8.58 for the closest-approach figure, with a comment on all four of its call
# sites saying "the nearest OPEN ring, not the targeted one". I did not apply it
# to the death distance, which is twenty feet away in the same file. That is the
# same mistake as the Peddler and the counter, and as the lift and quick ascent:
# fix one instance, leave its twin.
SubRx @'
    T.deathDistExtract=Math.round(dist(G.player,G.active));
'@ @'
    // v12.76: THE NEAREST OPEN RING, not the one the dice nominated at raid
    // build. This is the v8.58 rule, and the helper is the same one the closest
    // approach line on this very card already uses; I applied it there and not
    // here. A man who dies without ever reaching a ring, which is how a first
    // raid ends, was measured against a ring picked for him at random, so the
    // card disagreed with the compass he had been following all raid and with
    // the line printed under it.
    T.deathDistExtract=Math.round(closestRingDist(G.player));
'@

# NEW IN.
SubRx @'
  'THE LAST BOX BEFORE THE LIFT TELLS THE TRUTH. It said you were going up with an issued sidearm, when nothing equipped means a primary is issued and the second slot is left empty on purpose, and it listed Armour on the same line as the warning that you ascend with no armour on.',
'@ @'
  'THE LAST BOX BEFORE THE LIFT TELLS THE TRUTH. It said you were going up with an issued sidearm, when nothing equipped means a primary is issued and the second slot is left empty on purpose, and it listed Armour on the same line as the warning that you ascend with no armour on.',
  'HOW FAR YOU DIED FROM EXTRACTION IS MEASURED TO THE NEAREST WAY OUT. It was measured to a ring chosen at random when the raid was built, so the number disagreed with the compass you had been following all raid and with the closest-approach line printed right under it.',
'@

# STAMPS.
SubRx @'
var VER='12.75';
'@ @'
var VER='12.76';
'@
SubRx @'
var WHATSNEW_VER='12.75';
'@ @'
var WHATSNEW_VER='12.76';
'@
$cnt=([regex]::Matches($s,"now:'v12\.75:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.75 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.75:[^']*'",{ param($m) "now:'v12.76: from the 2026-09-08 first-hour audit, confirmed by a skeptic and then by me reading both sites, and it is my own half-done fix from v8.58 found again. The death card says KILLED BY X, N metres FROM EXTRACTION, and that N was measured to the ring the raid nominated, which is not the nearest way out: it is a ring the dice picked when the raid was built, and it is only ever re-pointed when he physically stands inside a ring or when the one it points at closes. So a player who dies without ever reaching a ring, which is exactly how a first raid ends, was measured against a ring chosen at random for him. Meanwhile the compass over his head had spent the whole raid pointing at the NEAREST OPEN ring, and the line printed directly under this one on the same card, the closest he came to extraction, is measured the same way, so the card disagreed with the compass he had been following and with itself. The helper that measures the nearest open ring already exists: I wrote it at v8.58 for the closest approach figure, and all four of its call sites carry a comment saying the nearest OPEN ring and not the targeted one. I did not apply it to the death distance, twenty feet away in the same file. That is the same mistake as the Peddler and the counter, and as the lift and quick ascent: fix one instance, leave its twin. Check 12.76 kills him standing beside one open ring with the nomination pointed at a far one and requires the card to report the near one, with a control that a death beside the nominated ring itself still reports exactly what it always did; fails on v12.75.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
