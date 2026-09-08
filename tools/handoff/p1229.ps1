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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P1, confirmed by three refuters) AND HIS
# STANDING NOTE: "standing still and crawler didn't hurt me even though he was
# close", "crawler attacks and pathfinding were still kinda messed up".
#
# e.cd is doing two jobs. In the idle branch it is the wander timer: whenever it
# reaches zero the machine picks a new spot and rolls cd=rnd(3,7). In the chase
# branch it is the bite cooldown: the bite fires only when cd<=0 and sets cd=0.7
# after. Nothing on the way into a chase clears it. So a crawler that had just
# rolled a six second wander, saw him and closed, stood inside bite range
# serving out the rest of that wander before its first bite, about 2.6 seconds
# on average and up to seven.
#
# THE FIRST DRAFT OF THIS BUILD CLAMPED THE CLOCK AT THREE TRANSITIONS INTO
# CHASE. The 2026-09-07 draft review killed that: there are FIVE ways in, and
# the two the clamps missed are the ones he causes himself, a round or a swing
# landing on a machine that was not yet fighting him (game 17825 and 17927).
# One of the three, the possum wake, could never fire, because a crawler
# playing dead has cd 0 already. So the wander gets its own field instead and
# every way in is covered at once, now and later. Only the crawler is moved off
# e.cd: the sentry shares the same fault, but its first shot is a balance change
# he has not asked for (NO BALANCING BEFORE ALPHA), so it is named here and left.
SubRx @'
      // cd is decremented once per frame below; do not tick it here as well
      if(e.cd<=0){
'@ @'
      // cd is decremented once per frame below; do not tick it here as well
      // v12.29, audit P1 and his standing crawler note: e.cd was the wander
      // timer here AND the bite cooldown in the chase branch, and none of the
      // five ways into a chase cleared it, so a crawler that reached him stood
      // in bite range serving out the rest of a wander of up to seven seconds.
      // The wander gets its own field on a crawler, which covers every way in
      // at once. The sentry keeps the shared field: same fault, but a faster
      // first shot from a sentry is a balance call he has not made.
      var _wf=(e.kind==='crawler')?'wanderT':'cd';
      if(!(e[_wf]>0)) e[_wf]=0;
      if(e[_wf]<=0){
'@
SubRx @'
          e.tx=sp.x; e.ty=sp.y; }
        e.cd=rnd(3,7);
'@ @'
          e.tx=sp.x; e.ty=sp.y; }
        e[_wf]=rnd(3,7);
'@
SubRx @'
      want=Math.atan2(e.ty-e.y,e.tx-e.x);
      if(dist(e,{x:e.tx,y:e.ty})<30) e.cd=0;
'@ @'
      want=Math.atan2(e.ty-e.y,e.tx-e.x);
      if(dist(e,{x:e.tx,y:e.ty})<30) e[_wf]=0;
'@
SubRx @'
    if(e.cd>0) e.cd-=dt;
    // Enemies were silent except when firing, so there was nothing for a noise
'@ @'
    if(e.cd>0) e.cd-=dt;
    if(e.wanderT>0) e.wanderT-=dt;   // v12.29: the wander clock, its own field on a crawler
    // Enemies were silent except when firing, so there was nothing for a noise
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A CRAWLER THAT REACHES YOU BITES. It used to stand next to you for up to seven seconds first, serving out the clock it had rolled for its next wander, whether it came for you on its own or because you shot it.',
'@

# STAMPS.
SubRx @'
var VER='12.28';
'@ @'
var VER='12.29';
'@
SubRx @'
var WHATSNEW_VER='12.28';
'@ @'
var WHATSNEW_VER='12.29';
'@
$cnt=([regex]::Matches($s,"now:'v12\.28:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.28 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.28:[^']*'",{ param($m) "now:'v12.29: 2026-09-07 audit P1 and his standing crawler note. e.cd was two clocks on one field: the wander timer in the idle branch, which rolls 3 to 7 seconds whenever it runs out, and the bite cooldown in the chase branch, which lets a bite through only at zero. Nothing on any of the five ways into a chase cleared it, so a crawler that reached him stood in bite range serving out the rest of its wander, about 2.6 seconds on average and up to seven. My first draft clamped the clock at three of those five transitions; the draft review killed it, because the two it missed are the ones he causes himself by shooting, and one of the three could never fire. The wander has its own field on a crawler now, so every way in is covered at once. The sentry keeps the shared field on purpose: same fault, but a faster first shot from a sentry is a balance call he has not made. Check 12.29 parks a crawler on patrol 25 units from a still player, stages nothing on the clock and lets the game roll its own, and requires the first bite inside 1.5 s; a crawler already in chase with a clear cooldown must bite inside 0.6 s, which proves the room can measure a bite at all; and a crawler wandering out of sight must still wander while its bite cooldown stays clear. Fails on v12.28, where the roll costs three to seven seconds.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
