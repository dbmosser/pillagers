# 41-art-player-states (lane b)

Shipped v32.65 (cw-playerstates, fb219f19). One ship, check fails on v32.64 and passes on v32.65; fingerprint unchanged (ents 85/374, containers 165/593).

- Another lane (cw-figlook, v32.64) wrapped drawOp with the 1.25 figure scale while I was building. My wrapper took the name drawOp0, the old body is now drawOpB, so the chain is drawOp (scale) -> drawOp0 (states) -> drawOpB (body). Shadow and seat ring are drawn by opGround inside my wrapper.
- Rarity tiers: WTIER fists 0, pistol 1, smg 2, magnum/carbine/shotgun/rifle 3, lmg 4, sniper/lance/rocket 5; a rarity twin (RV_BASE) is +1. Names in RCOL: common, uncommon, rare, elite (4), gold (5). Laser = tier 4 or 5, or w.q==='gold'.
- a11: swing 3.4/5.0, bob 2.6/3.6, lean 1.2/2.8, squash and stretch about the feet on each footfall (scaleY .94 to 1.03).
- a12: whole-body white 66 ms then red fade to 300 ms, recoil 2.5 px away from the shot (own window: p.hitDX from the shot source; mate: no direction, flash only, from his health dropping). The old chest glow is gone.
- a13: stains, 1.5 px slump, walk 30 percent slower, drips every 0.9 s, body outline (INK) pulses red at hpFlashRate. Screen wash untouched. Mate uses his reported hp (under 32).
- a14: downed (own p.downed or mate g.dn) kneels (crouchnone, bowed forward), gun sprite on the floor, red ring 1.2 Hz. The tag and the +0.50s bar are untouched. Pillager bots still go flat.
- a15: own death beat (1.5 s): falls 90 degrees away from the hit in 0.22 s, flat, fades 0.4 to 0.9 s with 14 amber/seat points rising. Nothing drawn after 0.9 s.
- a16: dots from the muzzle to 40 px short of the crosshair, under the bodies; laser for tier 4/5 and golden while sights held (ray stops at the first wall or hostile). Mates get dots only (their crosshair is not sent).
- Pictures: shots/41-before and 41-after (screens 21, 34, 36). Kneeling, dots and the red outline are visible at 1080.
- Not done: frame time numbers (no tool in my list to run a profiler; added cost is one wrapper per body and a second body draw only for 0.3 s after a hit). Watch for: 4k with two windows and several pillager bots hit at once.
- Not seen: a picture from the second window (2-player). The mate path (kneel, flash, low health, dots) shares the same code but is unpictured.
