# 206 sky bolt (cw-skybolt)
- mk: scratchpad mk-cw-skybolt.ps1. boltMark(S) at the strike splice in strikeTick (skips G.sim, no rr); drawBolts(wc,...) before gfxScreen in render2D.
- Shape: boltShape(seed) from a mulberry hash of strike id (host) / rid (partner) and spot, so both windows match (seen: same seed 1409722969 in p1 and p2 shots).
- Life 0.32 s, double flicker, skipped at effects reduced, off screen, or when reduced flashing holds the flash back.
- Pictures (drafted build, held at first frame): notes/shots/206-skybolt/*.jpg, 1080 and 4k, demo p1, demo p2, career p1. First cut too faint; glow 0.30->0.45 w10->12, core 3->3.6, bloom 42->50.
