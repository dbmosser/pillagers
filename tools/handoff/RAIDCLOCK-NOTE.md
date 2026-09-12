# 2026-09-12: A DEPLOYED RAID DRIVEN BY __loop DOES NOT RUN THE RAID CLOCK

Found while writing check 13.10 and NOT chased down, so the next person starts here
rather than from scratch.

## MEASURED on the v13.09 fixture, with no container and no new code involved

    __deploy({kit:[],safe:null,mapIx:0,seed:4242})
    player moved to 10 units inside zones[0], radius 78, open true
    raid alive (over null), not downed, timeLeft 540
    keys cleared, KeyE held, six __loop frames

RESULT: `zones[0].pullT` stays null, `beaconT` stays null, and `G.t` is STILL 0.

So the player update runs (check 12.91's downed crawl moves the body exactly this way)
but the raid clock does not advance and the extraction pull never starts.

## WHY IT MATTERS

No check in the corpus proves a real E-hold extraction. Every one of them ends a raid
through `__endRaid`, which skips the pull entirely. The whole two-stage pull, call and
then board, is unguarded, and that is the single most important thirty seconds in the
game.

## WHERE TO START

- Compare `__deploy` against `__startRaid`. Check 12.87 uses `__startRaid` and ends
  raids successfully; verifySafe's abandon arm loots for 420 frames and its clock DOES
  move.
- The difference between those two entry points is the first thing to read.
- Also worth checking: whether `__loop` steps the raid only when `state==='raid'`, and
  what `__deploy` leaves `state` set to.
