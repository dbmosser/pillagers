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
# The level is a function of XP, and the file works it out in exactly one place:
# at the end of a raid. Selling salvage is the other way XP is earned, and both
# sale paths add the XP and never touch the level.
#
# So the Undercroft card shows two numbers that contradict each other. Sell a bag
# for four thousand, watch the XP figure on that card jump by four thousand, and
# the Level printed directly above it does not move. Nine cosmetics gate on that
# level, so the racks he has just earned stay locked until he goes up and comes
# back. On a fresh profile the very first sell-all is the moment four of those
# nine gates are actually earned, and it is the one moment the game will not
# honour them.
#
# The formula does not change. Only where it is worked out does: a level derived
# from XP is recomputed wherever XP moves.
SubRx @'
  P.xpLevel=1+Math.floor(Math.sqrt((P.xp||0)/220));
'@ @'
  syncXpLevel();   // v12.67: the same formula, in one named place
'@

SubRx @'
  P.credits+=gained; P.xp=(P.xp||0)+gained; P.stash=kept;   // v10.02, his answer 42: no bar bonus on a sale
'@ @'
  P.credits+=gained; P.xp=(P.xp||0)+gained; P.stash=kept;   // v10.02, his answer 42: no bar bonus on a sale
  syncXpLevel();   // v12.67: XP moved, so the level and the racks it gates move with it
'@

SubRx @'
        if(ix>=0){ P.stash.splice(ix,1); clearKeysFor(k); P.credits+=ival(k); P.xp=(P.xp||0)+ival(k); saveProfile(); renderHub(); }
'@ @'
        if(ix>=0){ P.stash.splice(ix,1); clearKeysFor(k); P.credits+=ival(k); P.xp=(P.xp||0)+ival(k); syncXpLevel(); saveProfile(); renderHub(); }   // v12.67: XP moved, so the level does
'@

SubRx @'
function cstand(){ return P.cstand||0; }
'@ @'
function cstand(){ return P.cstand||0; }
// v12.67, 2026-09-08 audit: THE LEVEL IS A FUNCTION OF XP, so it is worked out
// wherever XP moves rather than only at the end of a raid. Selling is the other
// way XP is earned and both sale paths added the XP without touching the level,
// so the Undercroft card showed two numbers that contradicted each other and the
// nine cosmetics gated on the level stayed locked until he had been up and come
// back. The formula is unchanged, and it lives here once so it cannot drift.
function syncXpLevel(){
  P.xpLevel=1+Math.floor(Math.sqrt((P.xp||0)/220));
  return P.xpLevel;
}
'@

# NEW IN.
SubRx @'
  'THE CONTRACT BOARD COUNTS CONTRACTS. Its one progress line said Contracts completed and printed a weighted number instead, so your first ever HARD card made it read two, and the line under it asked for credits while sounding like cards.',
'@ @'
  'THE CONTRACT BOARD COUNTS CONTRACTS. Its one progress line said Contracts completed and printed a weighted number instead, so your first ever HARD card made it read two, and the line under it asked for credits while sounding like cards.',
  'SELLING SALVAGE MOVES YOUR LEVEL, not just your XP. The level was only worked out at the end of a raid, so the card showed a level that disagreed with the XP printed under it and the racks you had just earned stayed locked until you went up and came back.',
'@

# STAMPS.
SubRx @'
var VER='12.66';
'@ @'
var VER='12.67';
'@
SubRx @'
var WHATSNEW_VER='12.66';
'@ @'
var WHATSNEW_VER='12.67';
'@
$cnt=([regex]::Matches($s,"now:'v12\.66:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.66 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.66:[^']*'",{ param($m) "now:'v12.67: from the 2026-09-08 read-only audit, confirmed by a skeptic against the source. The level is a function of XP and the file worked it out in exactly one place, at the end of a raid; selling salvage is the other way XP is earned and both sale paths added the XP and never touched the level. So the Undercroft card showed two numbers that contradicted each other: sell a bag for four thousand, watch the XP figure on that card jump by four thousand, and the Level printed directly above it did not move. Nine cosmetics gate on that level, so the racks he had just earned stayed locked until he went up and came back, and on a fresh profile the very first sell-all is the moment four of those nine gates are actually earned and the one moment the game would not honour them. The formula does not change; only where it is worked out does, and it now lives in one named place called wherever XP moves. Check 12.67 sells enough salvage in one go to cross a level boundary and requires the level and the cosmetic gate it opens to move at the counter rather than after the next raid, with a control that the formula itself is unchanged at a known XP figure; fails on v12.66.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
