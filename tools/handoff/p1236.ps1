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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2, corpse-redown), specced from the
# source and then attacked by a skeptic before a line was written.
#
# killPlayer does not end a live raid. It sets hp to zero, CLEARS the downed
# flag, opens a one and a half second beat and leaves the body lying in the
# world; the frame loop keeps running the machines, the bullets and the
# throwables underneath that beat at a quarter speed. damagePlayer has no dead
# test at all: its only early return is invulnerability, and killPlayer never
# sets any. So a round, a blade or a blast that lands on the corpse walks past
# the downed branch, takes health negative and falls into the down path, which
# fires three things at once: a second DOWN toast painted over the death fade,
# another count on the downs figure that the run report and the stats card both
# print, and a rewrite of the last-hit name, which is the name the KILLED IN
# ACTION card reads out while the ledger beside it still names the real killer.
#
# One guard at the very top closes all three, and it has to be at the very top:
# the direction stamp, the hurt stamp and the name are all written before the
# invulnerability test, so a guard any lower still lets the card be renamed by
# a shot at a body. Whoever killed him killed him.
SubRx @'
function damagePlayer(amt,src,srcName,sx,sy){
  // v4.28: the direction of the hit, stamped for the ring around the body.
  if(G&&sx!==undefined&&G.player) G.player.hitFrom={ang:Math.atan2(sy-G.player.y,sx-G.player.x),at:G.t};
'@ @'
function damagePlayer(amt,src,srcName,sx,sy){
  // v12.36, 2026-09-07 audit (corpse-redown): A DEAD MAN TAKES NO MORE HITS.
  // killPlayer does not end a live raid; it opens a 1.5 second beat and leaves
  // the body in the world with p.downed CLEARED and hp at 0, and the beat in
  // loop() keeps calling updateEnts, updateBullets and updateThrowables
  // underneath it. So a round that landed on the corpse fell past the downed
  // branch below, took hp negative and re-downed a man who was already dead:
  // a second DOWN toast over the death fade, another count on the downs figure
  // the report and the stats card print, and lastHitName rewritten, which is
  // the name the KILLED IN ACTION card reads while the ledger beside it still
  // names the real killer. Whoever killed him killed him.
  // ABOVE EVERY STAMP IN THIS FUNCTION on purpose: hitFrom, hurtAt and
  // lastHitName are all written before the invulnerability test, so a guard
  // any lower still lets the card be renamed by a shot at a body.
  // It costs nothing anywhere it can be measured: killPlayer ends a sim raid
  // outright rather than running a beat, so the beat is never set under the
  // bot and no paired number moves. The round still sparks, still counts as a
  // hit and is still consumed, so the bullet stream is untouched.
  if(G&&((G.deathBeat!==undefined&&G.deathBeat!==null)||(G.player&&G.player.dying))) return;
  // v4.28: the direction of the hit, stamped for the ring around the body.
  if(G&&sx!==undefined&&G.player) G.player.hitFrom={ang:Math.atan2(sy-G.player.y,sx-G.player.x),at:G.t};
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'WHOEVER KILLED YOU KILLED YOU. A round landing on your body during the death fade used to throw a second DOWN over the top of it, add another down to your record, and put its own name on the KILLED IN ACTION card in place of the machine that actually did it.',
'@

# STAMPS.
SubRx @'
var VER='12.35';
'@ @'
var VER='12.36';
'@
SubRx @'
var WHATSNEW_VER='12.35';
'@ @'
var WHATSNEW_VER='12.36';
'@
$cnt=([regex]::Matches($s,"now:'v12\.35:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.35 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.35:[^']*'",{ param($m) "now:'v12.36: 2026-09-07 audit (corpse-redown). killPlayer does not end a live raid: it zeroes the health, CLEARS the downed flag, opens a one and a half second beat and leaves the body in the world, and the frame loop keeps running the machines, the bullets and the throwables underneath it. damagePlayer had no dead test at all, its only early return being invulnerability, which killPlayer never sets, so a round landing on the corpse walked past the downed branch and fell into the down path: a second DOWN toast over the death fade, another count on the downs figure the report and the stats card print, and the last-hit name rewritten, which is the name the KILLED IN ACTION card reads while the ledger beside it still names the real killer. One guard at the very top of damagePlayer closes all three, and it has to be at the top because the direction stamp, the hurt stamp and the name are all written before the invulnerability test. Nothing measurable moves: the bot ends a sim raid outright rather than running a beat, and the round still sparks, still counts and is still consumed. Check 12.36 puts him down with a real round, kills him with a second, then lands a third on the body inside the beat through the real frame loop and requires the downs figure, the downed flag, the toast and the killer name all to be unchanged, and the card to name the machine that killed him and not the one that shot the body; fails on v12.35.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
