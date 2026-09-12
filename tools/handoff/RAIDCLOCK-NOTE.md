# 2026-09-12: CLOSED. THE RAID CLOCK WAS FINE AND THE PROBE WAS WRONG

This file used to say that a deployed raid driven by the loop does not run the
raid clock and that the extraction pull never starts. Both halves were wrong,
both were my instrument, and the wrong version is kept below so the mistake is
readable rather than quietly gone.

## WHAT THE PROBE CLAIMED

> player moved to 10 units inside zones[0], radius 78, open true
> raid alive (over null), not downed, timeLeft 540
> keys cleared, KeyE held, six __loop frames
> RESULT: zones[0].pullT stays null, beaconT stays null, and G.t is STILL 0.

## WHY BOTH HALVES WERE WRONG

THE CLOCK. G.t advances exactly as the loop promises. Measured on v13.10, six
frames from a fresh deploy: G.t rises 0.1335, which is the first frame clamped
to 0.05 by the dt clamp plus five frames at 16.7ms. Measured again with the
timestamps started a second in the future in case real frames were interleaving:
identical, 0.1335. There was never anything to find.

THE PULL. Calling the ship is a HOLD, not a press. tryExtractTick accumulates
z.callT by dt and returns early until it reaches 1.6 seconds. Six frames is one
tenth of a second. The probe let go of the key 1.5 seconds before the game was
ever going to answer it.

## THE REAL SHAPE OF THE WAY OUT, measured end to end

1. Hold E inside an open ring for 1.6 seconds. z.callT fills, the call bar reads
   it, then the ship is called: z.beaconT is set to CFG.extractWait and G.active
   moves onto that ring.
2. Wait out the inbound countdown, which is minutes long.
3. The ship lands: z.hold is set to min(30, timeLeft - 1), the boarding window.
4. Hold E again for 1.4 seconds. z.pullT fills, and at 1.4 endRaid('extract')
   fires. Releasing the key clears z.pullT on the next frame; it does not bank.

Roughly 96 frames for the call and 84 for the board. Any probe that holds E for
fewer than about 100 frames will see nothing happen and has measured nothing.

## THE GAP THAT WAS REAL

The other claim in the old note was true and is now closed. No check in the
corpus proved a real hold-E extraction, because they all end raids through
__endRaid, which skips the pull. Check 13.11 drives all five stages on a live
raid with real frames and the real key.
