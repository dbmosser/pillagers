# 0p09-191-first-fight-15-20s (lane b, 10-31)

Shipped v36.87 (594f36298, key cw-firstfight). ON HIS PC v36.87 printed 67 s after the ship.

## Result (standing player at the start, Cold Storage, 40 seeds, probe: render off, 50 ms steps)
- Before (v36.85/86): median first contact about 89 s. 19 of 40 seeds met nothing in 100 s. The earliest were 13.7 s and 26 s; most came at 26 to 50 s.
- After (v36.88 build): median about 15.8 s (seeds 1-20 median 16.8, seeds 21-40 median 15.7). Range 13.6 to 31.9 s; 1 of 40 seeds in the second run of 1-20 had none in 100 s.

## Why it was slow
1. The first pack came at 22 s and landed 770 to 1060 away.
2. A ring called by an AI pillager (even far away) froze the wave clock for the whole start (siegeCalled). About half the seeds had this within the first 6 s.
3. The nearby-hostile cap (6) could also block the first pack.

## What changed (dark_raiders.html, arcadeWaveTick and helpers)
ARCADE_FIRST={iv:11,minR:480,maxR:640}; arcadeFirstOn(WS) (demo only, no wave yet, never career); the first pack comes after 11 s, lands 480 to 640 away, ignores the cap, and is held only by a called ring within 1000 of a player (arcadeSiegeNear). Later packs and career: unchanged. Fingerprint held (85/374, 165/593).

## Watch for in a playtest (for DESIGN.md; the ship wrote the section but not this line, my lane cannot edit DESIGN.md)
- About 16 s after the map closes, two crawlers should walk into view and find you. If it feels like an ambush before you have moved, push ARCADE_FIRST.iv up (11 to 14) or minR/maxR out.
- Walking players meet them a bit sooner than the standing numbers above.
- In 2 player, the pack picks one of the two players at random and lands 480 to 640 from that one.
- A called extraction ring close to you still holds the first pack (as it held every pack before).

## Not done
- No two-window picture (this is sim timing, not a drawn thing; the measurement ran the host demo on the test Chrome). Probe: S/mk-cw-fight191probe.ps1 (never shipped).
