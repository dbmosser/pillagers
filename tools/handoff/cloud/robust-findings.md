# Robustness hunt (cloud), 2026-10-15

Stopped after five rounds: round 4 (a code read of v27.33 to v27.38) and round 5 (a soak and a host-leave run on v27.38) found
nothing new to draft.

Area: crashes, leaks and long play. Game v27.27 (master at the start of the hunt). Tools added under tools/cloud:
soak.mjs (many raids back to back in one page, clock pushed, real key and mouse events, census of G arrays, listeners,
intervals, DOM and heap after each raid), oldsave.mjs (makes a real save from an old build kept in tools/), oldload.mjs
(loads a save into the current fixture and opens every menu, every kit, a CAREER raid, a death and a DEMO run, then
checks the save round trip), pair.mjs (two real windows: host plus the player 2 popup, faked controllers).

## Gate status
Every draft marked GATE PASS below was last re-gated on master v27.45 (drafted as v27.46) and printed GATE PASS there (and before
that on v27.38 and v27.32). Withdrawn: the lockdown draft (v27.37 removed the lockdown alarm) and the bounty draft (v27.43 fixed it).

## Findings

| # | What is wrong | Proof (headless Chromium eval) | Draft | Gate |
|---|---|---|---|---|
| 1 | 2 player DEMO: timed power-ups (bottomless clip, shield bubble, ...) survive a death. pwrTick's clear on dying never runs (the death beat skips updatePlayer; arcadeRespawn sets dying false). | clip 20 s and shield 10 s set, killPlayer, 80 frames: dying false, deaths 1, act {"clip":17.5,"shield":7.5} | draft-cloud-robust-pwr-death | GATE PASS |
| 2 | Overseer rampage whose Overseer dies during the 12 s warning stays live 137 s (ring, name on screen) and blocks every other raid event; the tick returned on the missing rampage mark before its dead-boss test. | CAREER seed 1: evLaunch('rampage'), boss hp 0, 400 frames: ph live, lt 8, over undefined; left live 137 s | draft-cloud-robust-rampage-dead | GATE PASS |
| 3 | 2 player DEMO: a player who dies sealed inside a lockdown respawns far away and is thrown back onto the rim of the sealed ring every frame for the rest of the seal (the side is recorded once when the doors slam). | seed 5, 2 player rules: sealed in, killPlayer, respawn 1538 from centre, next frame 283 (ring 300), 5 s later 283 | withdrawn | moot: v27.37 removed the lockdown alarm (draft GATE PASS on v27.27 and v27.32, deleted) |
| 4 | A gilded hostile pillager who extracts alive is taken for dead: GOLDEN ENEMY DOWN is said and a GOLDEN HOARD drops at the extraction ring (goldTick treats leaving G.ents as a death). | CAREER seed 21, the golden one is a raider; held in an open ring with a hold: removed with hp 234, gold.dead 1, GOLDEN HOARD at 857,2540 beside ring 850,2520, feed GOLDEN ENEMY DOWN | not drafted | the same root covers a gilded body culled from a DEMO wave or a convoy crawler leaving with the convoy (round 2 finder, read in the code, not run). Needs his ruling: what an escape should do (no hoard and a new line such as GOLDEN ENEMY ESCAPED, or golden pillagers never extract); the player 2 window says DOWN on the same word, so the fix touches the net word too |
| 5 | Magnet power-up pulls a closed stronghold's cache (finder claim: out through the fence). | DEMO seed 1, magnet held 30 s from three spots outside the fence: the cache slid 68, 221 and 34 from the centre, always inside the 240 fence, compound still shut | not drafted | could not prove it crosses the fence |
| 6 | A fire that lights on a body pushes it to the disc edge along its own line with only an open-floor test, so a body on the wall side of the centre goes through the wall (into a shut room or the far side of a building). 53 of 60 planned fuel fires (seeds 1 to 30, Cold Storage) have a disc that crosses a wall. | CAREER seed 7: player 20 left of a 16 wide wall, fire lit 60 left of it, one frame later the player is 44 right of it; 4 walls of 4 | draft-cloud-robust-fire-wall | GATE PASS |
| 7 | Kid auto-fire (player 2) calls an armed air strike on its own: auto-fire puts the cursor on the nearest enemy and the trigger down, which the strike aim reads as a press. | netAfOn stubbed true, meter full, airKey, sentry 150 away, mouse up, 12 frames: used 1, a strike in the sky, meter 0, mouse.down true | not drafted | his call: for a kid this may be wanted (the strike lands on the nearest enemy), or the strike should wait for his own trigger |
| 8 | When the host window goes and player 2 picks up the raid, player 2 plans its fires for the first time and lights every plan entry already due, on top of the host fires it already holds: the same fire stands twice (twice the burn). | two real windows, 2 player DEMO seed 23: 124 s in player 2 held one lit fire at 193,2829; host closed; 2 s later two fires at 193,2829. One window: CAREER seed 23, fire lit at 1344,1702 at 92 s, fplan cleared and netWasJoin set, one frame: two fires at 1344,1702 | draft-cloud-robust-takeover-fires | GATE PASS |
| 9 | When the host window goes and player 2 picks up the raid, a stronghold that was breached and not cleared is cleared at once and pays 1,000 with its defenders alive (the defender lists stayed in the host window). | CAREER seed 1, compound breached, 11 defenders alive; rebuilt from the host word (shNetOut, shNetTake) as player 2 holds it, netWasJoin, one frame: clear 1, score 0 to 1,000, 12 live bodies inside | draft-cloud-robust-takeover-stronghold | GATE PASS |
| 10 | When the host window goes and player 2 picks up the raid, player 2 plans the raid events for the first time and runs again every event already due, including ones the host ran and finished. | CAREER seed 23: debris planned at 185 s ran and ended; at 286 s plan cleared and netWasJoin set (as player 2 holds it): 2 s later debris in its warning again | draft-cloud-robust-takeover-events | GATE PASS |
| 11 | Barrels are not shared between the two windows: a barrel the host sets off is still standing for player 2 (his rounds keep stopping on it), and one player 2 sets off stays standing for the host and hurts nobody there. | two real windows, 2 player DEMO seed 31: both hold the same 29 barrels; the host blows 3343,3029; 4 s later player 2 still has 29 live with 3343,3029 standing. Reverse: player 2 blows 2468,2232; the host still has 26 of 26 | not drafted | too big for one draft: needs the barrels in the world word both ways (as v27.04 did for fires); a co-op build for the PC |
| 12 | 2 player DEMO: a player who dies inside a stronghold keeps his inside mark through the respawn, so coming back near it from outside he is thrown through the fence. | seed 1: breached, inside (side 1), killed, respawned 3957 away with side still 1; walked to 360 behind the fence, next frame 223 from the centre (fence 240) | draft-cloud-robust-sh-respawn | GATE PASS |
| 13 | A bounty pillager killed by a fuel fire pays BOUNTY CLAIMED 1,500: the test read any kill mark but false as yours, and a fire sets none. | CAREER seed 3: bounty live, fire lit on him at 3 health, he died with no mark: won 1, score +1,500 | withdrawn | fixed on master in v27.43 (the same test, byPlayer true or a seat) |
| 14 | When the host window goes and player 2 picks up the raid, the golden enemy is declared down at that moment (GOLDEN ENEMY DOWN, a hoard dropped) whether or not it died: the body is let go or renumbered at the takeover and goldTick takes a body gone from the list as dead (same root as finding 4). | two real windows, host closed mid-raid twice: seed 41 at 200 s, gold.dead 0 before, 1 two seconds after; seed 23, dead 0 to 1 within 15 s | not drafted | same ruling as finding 4 (what a golden enemy that leaves the list without dying should do) |
| 15 | An air strike kill on a body you last hit with a gun goes on that gun's kill tally (and could pay LONG SHOT): the strike leaves no last-blow mark. | CAREER seed 3: crawler marked as last hit by the Scav Pistol, killed by airCall: G.gunK {} to {pistol:1} | draft-cloud-robust-air-tally | GATE PASS |

## Candidates read in the code but not proven (not drafted)

- arcadeRebuild (player 2 joining a raid the host started before the link was up) keeps the score and clock but rebuilds the
  raid flow, so goal chips, the stronghold chip and the golden hoard can be earned twice in one run.
- After a takeover the clue search circle keeps the last circle the host sent and stops shrinking or following.
- In a shared co-op raid the death beat runs the bodies for 1.5 s without the raid flow, so a body can cross a fence, the
  lockdown wall or a fire and be snapped back after.
- The air strike can be armed and called during the 2 player drop-in hold.
- The TEAM combo chain runs on the wall clock and is not reset between runs.
- Player 2's kills in a party raid never reached his gun kill tally or his trophies: fixed on master in v27.34.
- The haul reveal keeps playing its pickup sounds when the EXTRACTED card is closed by the party ascending within 3 s.
- After a takeover the run goal figures are recounted from player 2's own counters, so a goal bar can drop (8 of 10 to 2 of 10).
- An alert pushed aside by a critical one stings again when it takes the lane back (v27.33 says each alert that takes the lane
  stings, so this may be intended): his call.
- Player 2 side of finding 15: the mirror keeps his last round's mark and a barrel blast returns on his window before marking,
  so a strike or barrel finish can still tally on his gun after v27.34. Read in the code, not run.
- NET.entDead is not reset between raids, so a player 2 window that missed a body's words could match a kill word to a body of
  the last raid (needs a rejoin mid-raid). Weak.
- The alert sting has no check for a benched player 1 window, so an idle DEMO cabinet can sting under the attract screen: feel.
- At 1280x720 the v27.35 feed zone (a quarter of the width) is narrower than its lines: feel, playtest watch.
- The Director reads only the host's damage, so player 2 in a heavy fight never brings a breather (may be by design).

## Checked and clean

- Two real windows (host plus the player 2 popup, faked controllers): 5 runs of 4 real minutes each, player 2 joined every run
  and moved, both windows ended every run, no page error, no crash entry, no non-finite number, DOM and heap flat. Host closed
  mid-raid: player 2 carried on with no error (findings 8 to 10 are what it got wrong).
- A stress save (v16.10 save plus removed rig ids, unknown items in stash, kit and belt, an unknown gun equipped, a contract of
  an unknown type): boots, every menu, every kit, raids, no error, round trip clean.

- Long play, three soaks: seed 202 (36 raids, v27.30) and seed 303 (24 raids, 1.5 game hours, v27.38) were as clean as the
  first. Two more host-leave runs (seed 41 on v27.32, seed 57 on v27.38) showed only findings 8 and 14.
- Long play, first soak: 36 raids back to back in one page (demo1, career, demo2 in turn; both maps; 300 game seconds each, about 2.6
  hours of game time, seed 101): no page error, no game crash entry, no non-finite number on the player or any entity, every
  raid ended; heap 24 to 66 MB and back after each raid, DOM 1082 to about 1230 and flat, 3 intervals throughout, the save
  grows only by the run log, which is capped at 60.

- Old saves: a real v16.10 save and a real v23.96 save (made by playing two raids in the builds kept in tools/) boot in
  v27.27 with no page error and no crash entry; every menu render, all four kits, a CAREER extraction, a death and a DEMO
  run pass; the round trip changes only mapIx 1 to 0, the frozen second map clamped on load, by design.
- Listeners: the per-raid growth seen first was on detached nodes the garbage collector frees; attached listeners stay flat.
