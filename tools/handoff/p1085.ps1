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

# ============ HIS NOTE: RANDOM HUMS THAT LAST WAY TOO LONG, LIKE AFTER YOU DIE.
# ============
# ============ FOUND BY COUNTING. The file creates 40 oscillators and stops 38.
# ============ The two that are never stopped are the ambient bed: a 54 Hz sine
# ============ and an 81.5 Hz sine, plus a looping noise bed, a weather layer and
# ============ a 36 Hz dread sine. That is DELIBERATE. They are a permanent bed
# ============ and they are meant to be silenced by driving their GAIN to zero,
# ============ not by being stopped.
# ============
# ============ AND THE ONLY THING THAT DRIVES THAT GAIN IS tickAmbience, called
# ============ from exactly one place in the whole file, inside the raid branch of
# ============ the frame loop. The moment a raid ends, that branch stops running.
# ============ Nothing else in the file touches AMB. So the gain FREEZES at
# ============ whatever it held on the last raid frame and those five voices go on
# ============ sounding at that level through the outcome card, through the
# ============ Undercroft, and until you deploy again.
# ============
# ============ AND IT FREEZES LOUD. The target is 0.16 + 0.30 * threat, where
# ============ threat is the nearest hunting body, 1 when something is on top of
# ============ you. The last frame of a raid you LOSE is the frame something was
# ============ on top of you, so the bed is near its maximum at exactly the moment
# ============ it stops being driven. That is the hum, and dying is the way to get
# ============ the loudest one.
# ============
# ============ THE FIX: one function that cuts all three ambient gains, called
# ============ when a raid ends, whatever the ending. A short fade rather than a
# ============ hard stop, because a bed that vanishes on a frame boundary clicks;
# ============ 0.12 against the 0.45 the live bed uses, so it is gone in under
# ============ half a second instead of never.
SubRx @'
// Footsteps for things you cannot see. This is the whole point of the pass: a
'@ @'
// v10.85, HIS NOTE: the bed is the only sound in the game with no stop, by
// design, and tickAmbience above is the only thing that drives its gain. It runs
// inside the raid branch of the frame loop and nowhere else, so when a raid ends
// the gain simply stops being written and those five voices hold their last
// level for as long as the page is open. This is what cuts them.
// A COUNTER, not a boolean: a check with no audio context cannot hear the gain
// go down, but it can prove this was reached once per ending and never during
// ordinary play.
var AMBOFF=0;
function ambienceOff(){
  AMBOFF++;
  var A=AMB; if(!A) return false;
  var a=ac(); if(!a) return false;
  var t=a.currentTime;
  try{
    // cancelScheduledValues first, or the ramp tickAmbience set on the last raid
    // frame keeps pulling the gain back up after this one is written.
    A.g.gain.cancelScheduledValues(t);  A.g.gain.setTargetAtTime(0,t,0.12);
    if(A.wg){ A.wg.gain.cancelScheduledValues(t); A.wg.gain.setTargetAtTime(0,t,0.12); }
    if(A.dg){ A.dg.gain.cancelScheduledValues(t); A.dg.gain.setTargetAtTime(0,t,0.12); }
  }catch(e){}
  return true;
}
// Footsteps for things you cannot see. This is the whole point of the pass: a
'@

SubRx @'
function endRaid(how){
  if(G.over) return;
  G.over=how;
'@ @'
function endRaid(how){
  if(G.over) return;
  G.over=how;
  // v10.85: the raid loop stops here, and it is the only thing that was driving
  // the ambient bed down. Cut it now or it hums at its last level for as long as
  // the page is open. Ahead of everything below because everything below can
  // throw, and a hum that outlives the raid is what he actually hears.
  try{ ambienceOff(); }catch(_ao){}
'@

SubRx @'
var VER='10.84';
'@ @'
var VER='10.85';
'@
SubRx @'
  now:'v10.84: your crawler note, and it was worse than a crawler. A machine inside a building could not find its way out to you: twenty seconds, never closer than 97 units, no damage, while the same crawler in the open kills in ten. The doorways were sealed on the routing grid, not in the world.',
'@ @'
  now:'v10.85: your note about hums that last way too long. The ambient bed is five voices that are never stopped on purpose and silenced by turning their gain down instead, and the only thing that turned it down ran inside the raid loop. End a raid and the gain froze where it stood, loudest if something was on top of you when you died.',
'@
SubRx @'
  'MACHINES CAN FIND THE DOOR NOW.
'@ @'
  'THE HUM STOPS WHEN THE RAID DOES. The low bed under a raid is five voices that never stop, turned down rather than switched off, and the only thing turning them down ran inside the raid itself. So it froze at its last level when you died and kept going through the card and the Undercroft, loudest of all if something was on top of you at the end.',
  'MACHINES CAN FIND THE DOOR NOW.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
