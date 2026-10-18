# c-02-ascent-and-light-shafts
Shipped v30.34 (cw-ascent, d99bcb15). Preflight and gate passed, fingerprint held.
- Rise: G.rise set in startRaid (not sim); ascentSink(p) gives px below ground; drawn in the sorted player branch via ascentBegin/End (clip + translate + hatch + teal beam + dust ring). 1.3 s. Skipped by keydown/mousedown/touchstart (capture), p.moving, p.muzzle, roll.
- Exit: same sink driven by z.pullT/1.4 during the boarding hold (no added delay; cancelling the hold lifts him back).
- Shafts: lootShaft() on dropped piles only (ct.dropped, unopened) by ct.best; none for common. Unopened boxes and caches get none (rulings 2026-08-26, lean6).
- Not done: no screenshot/critic (no UI screen stages it); no sound. Possible follow-up: shafts on a dead pillager's gear drop if he wants known loot marked.
