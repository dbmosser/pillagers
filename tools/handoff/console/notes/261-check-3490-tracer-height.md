# 261-check-3490-tracer-height (lane c, 11-01)

Result: a test bug, not a game bug. No game job needed (b does not apply).

Cause: the survivor tracer height is right (shotLy = 20 times the drawn size, 19.1 at his build). Check 34.90 compared it to the
survivor flash height read as sv.y minus the flash y. But gfxShot puts the flash at sh.y + sin(ang)*17 - shotLy, so the flash carries
the round's own aim spread. A wide shot (sin of the angle about -0.147) moves the flash 2.5 up: 19.1 + 2.5 = 21.6, exactly the
red text. Which spread a shot gets depends on the random state when the check runs, so it fails in the full runs and passes alone.

Fix (fixture commit 24e4d9481, fixq): the expected height is now sv.y - own.y + 17*sin(own.a), the gun line the flash sits on.
Same claim (the tracer leaves at the gun line of the drawn body), no spread in it. Runs alone: 34.90 PASS before and after (the
red needs the full-run random state), so the proof of the fix is the next VM full run.

Left for the coordinator: delete the v34.90 line from tools/handoff/stable-known-red.txt (not on my write list), after a full run
shows 34.90 green. The player check at about line 16466 (your own tracer against the drawn muzzle) has the same spread shape but
uses gunMuzzleAt with the angle in it, so it follows the spread; it has not failed.
