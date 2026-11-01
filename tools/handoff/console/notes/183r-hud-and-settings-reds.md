# 183r-hud-and-settings-reds (lane a, 11-01, build v37.03)

Ran each check alone on v37.03 (notes/183r-out1.txt):
- 34.89 cw-hudcorner: PASS. Fixed since the corpus run by later retargets (0p18-221 etc). Dropped.
- 30.17 Settings detail pane first row in view: PASS. Dropped.
- 34.90 cw-thirdsize: FAIL, but with a new message ("the survivor tracer is drawn 19.1 over the round, his flash 21.6 up"), not the corpus one. Cause: b, the check went blind. Since cw-cx-reticleflight (his 10-29 note) the tracer leaves the muzzle at gun height and eases down to the sim line over 220 world px (smoothstep, shotDrawLift). The check measured 47 px out, so it read 19.1 instead of 21.6. The game is right.
  Fix: trY in check 34.90 divides the measured height by what is left of the lift (1 - smoothstep(travelled past the drawn muzzle / 220)), so it reads the muzzle height again; every comparison (tracer vs flash, vs pillager tracer, partner window) is unchanged and still strict (1 px).
  Landed in fixture commit 143c2f8d1 (another worker's fixq swept the edit in). Re-run: 34.90 PASS (notes/183r-out2.txt).

No game change, no ship needed.
