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
#
# The haul contract asks him to extract with a haul worth some amount, and the
# number it tests is the whole backpack at the end of the raid. The backpack
# BEGINS the raid holding whatever he staged, and there is no limit on what he
# can stage or how much of it: any item with a use, which includes field guns
# worth thousands.
#
# So the highest-paying card on the board is completable in under a minute. Stage
# one expensive gun out of your own stash, land, walk to the nearest extraction
# point, hold E, leave. The bag is worth more than the card asked, the card goes
# ready, and the gun goes straight back to the stash, so it costs nothing and can
# be done again on every refill.
#
# The game already knows the difference. It stamps what the lift carried in, and
# the run earnings line subtracts it, for exactly this reason. The haul contract
# was the one place that ignored it.
SubRx @'
if(c.type==='haul'&&haul>=c.v) c.prog=c.n;
'@ @'
    // v12.65, 2026-09-08 audit: WHAT THE RUN EARNED, NOT WHAT THE LIFT CARRIED.
    // This tested the whole backpack, and the backpack starts the raid holding
    // whatever he staged, with no limit on what or how much: a field gun out of
    // his own stash is worth thousands. So the best-paying card on the board was
    // completable in under a minute with no looting, no fighting and nothing
    // risked that was not already his, and it went straight back to the stash
    // afterwards so it could be done again on every refill. The game already
    // draws this line: it stamps what the lift carried in and the run earnings
    // subtract it. This was the one place that ignored it. The threshold on the
    // card has not moved; what it measures has.
    if(c.type==='haul'&&(haul-(G.carriedIn||0))>=c.v) c.prog=c.n;
'@

# NEW IN.
SubRx @'
  'THE BUY BUTTON SAYS HOW SHORT YOU ARE, including when you cannot afford even one. That was the commonest refusal at the counter and the only one it answered with a dead grey button and no reason at all.',
'@ @'
  'THE BUY BUTTON SAYS HOW SHORT YOU ARE, including when you cannot afford even one. That was the commonest refusal at the counter and the only one it answered with a dead grey button and no reason at all.',
  'A HAUL CONTRACT COUNTS WHAT YOU CAME BACK WITH, not what you took up. Staging one expensive gun out of your own stash and walking straight to an extraction point used to finish the best-paying card on the board, and the gun went back in the stash afterwards.',
'@

# STAMPS.
SubRx @'
var VER='12.64';
'@ @'
var VER='12.65';
'@
SubRx @'
var WHATSNEW_VER='12.64';
'@ @'
var WHATSNEW_VER='12.65';
'@
$cnt=([regex]::Matches($s,"now:'v12\.64:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.64 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.64:[^']*'",{ param($m) "now:'v12.65: from the 2026-09-08 read-only audit, confirmed by a skeptic against the source. The haul contract asks him to extract with a haul worth some amount, and the number it tested was the whole backpack at the end of the raid. The backpack BEGINS the raid holding whatever he staged, and there is no limit on what he can stage or how much of it: the stage screen offers any item with a use, which includes field guns worth thousands, and the deploy slot count is effectively unlimited. So the highest-paying card on the board was completable in under a minute: stage one expensive gun out of his own stash, land, walk to the nearest extraction point, hold E and leave. The bag is worth more than the card asked, the card goes ready, and the gun goes straight back to the stash by the ordinary banking, so it cost nothing and could be done again on every refill; the board stopped being a set of errands worth choosing between. The game already draws this line: it stamps what the lift carried in and the run earnings line subtracts it, and the haul contract was the one place that ignored it. The threshold on the card has not moved; what it measures has. Honestly, this makes that card meaningfully harder, because it now asks for what it says it asks for. Check 12.65 stages a gun worth more than the card wants, extracts with nothing else, and requires the card NOT to be ready, with a control that the same value looted in the raid does finish it; fails on v12.64.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
