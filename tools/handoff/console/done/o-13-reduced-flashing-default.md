o-13-reduced-flashing-default : reduced flashing on by default for new players, at most about 3 bright flashes a second (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/q-round3/answers.md 2.61: "b: Yes, as a Settings switch that is on by default".
Not done (planner, 10-20): dark_raiders.html 67616-67620: the REDUCED FLASHING row (flashRed) offers OFF {flashRed:0} and ON
{flashRed:1}, default off. The switch only shrinks flashes (flash() about 22389 and 22402, the lightning flash about 44374, flashK about
49690). rg for a rate cap (flashRate, flashCap, flashes a second) finds nothing. The only task holding 2.61 (cut/16) was parked 10-19;
the question was asked about party mode, which no longer exists, and his pick is a plain Settings switch, so it is game-wide.

1. New profiles start with REDUCED FLASHING on. Existing saves keep their own choice: first find how settings are stored. If a save that
   never touched the row has no stored value (so it would follow the new default), give saves made before this version an explicit
   stored 0 when they load. Profile fields only; never change the storage key salvagerun:profile.
2. With it on, no bright full-screen flash or lightning flash repeats more than about 3 times a second: a small limiter on the
   full-screen flash and lightning paths. Spark bursts may stay (already halved).
3. The demo uses a fixed set of settings (his 3.15 a): make sure the demo gets reduced flashing on.
Checks (control must FAIL on v32.90): a new profile has flashRed 1; an old profile without the field keeps 0; with it on, 10 full-screen
flash requests inside one second draw at most 3; with it off nothing changes.
Pictures: none needed (flashes do not photograph well); write in notes-new.md what he should watch for: blasts and lightning may look
softer on his TVs.
It is a FEATURE: ship by Mon 10/26. If the rate cap cannot make it, ship only the default flip and say so.
Party risk: low to medium (blasts and lightning look softer).

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
