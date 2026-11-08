# 00p-m3d-raid-sources notes (run of 11-08)
Key cw-m3dsrc. mk: S\mk-cw-m3dsrc.ps1, check S\mk-cw-m3dsrc.check.js. Pictures: S\mk-cw-m3dshots.ps1 writes notes/shots/m3dsrc-recipes.json.
00p-m3a-drops is in done/, so no wait.
Design: one table WORN_SRC (a row per machine kind, pillager/tough/elite, boss for the overseer and the juggernaut (v37.59, a bulwark with boss2), locked for keycard room boxes).
wornPieceKey(R,O) is the shared piece roll in 00p-m3a's dice order (a plain box gives the same piece as before; the check proves it against an inline copy of the old roll).
wornKillRoll(ct,e) runs at the six places a death already leaves a wreck or body (warden cache, pillbox, pillager body, listener, botwreck, snitch). No new container ever.
Seed: G.seed, the kind and e.wsi (spawn index, stamped in buildRaid's sleep loop; later spawns get 100000+counter at death).
Numbers (his 26 raids v35.38 to v37.56, exports/run-20261031-044133-885.txt and run-20261107-190409-065.txt): 13.4 containers opened, kills a raid crawler 13.5, sentry 4.2, snitch 0.6, bulwark 0.15, howler 0.15, pillager 0.7.
SHIPPED v37.62 cw-m3dsrc, ON HIS PC 40 s after the ship; fingerprint ents 85/374, containers 165/593 held. Pictures notes/shots/00p-m3d-after (wreck and body mid search, 1080 and 4K, lint 0). No critic run: nothing new is drawn (the tip is 00p-m3a's, already critic-scored).
Preflight lessons: no apostrophes in now/why; game functions are not on window (reference them directly); the first kill of a raid draws on RNGS once (warm-up kills); vaultKillDrop rolls on Math.random (pin it in a check that compares two kills).
Total estimate 4.4 a raid (boxes 3.4, wrecks 0.45, pillagers 0.45, keycard rooms 0.1). WORN_BOX_CH left at 0.34. The 1 wreck in 5 searched is an estimate: the run log does not split boxes from wrecks.
