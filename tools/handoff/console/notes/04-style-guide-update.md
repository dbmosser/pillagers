# 04-style-guide-update (lane e, 2026-10-18)
- Guide edited: notes/ui/style-guide.md (lime --acc #e6ff3d + hover/press, warn amber kept apart, taste rules Q40/42/44/45, window card 90% x 90% with X (Q43), bounce c1 1.5 = 8% (Q47), soft tick / punchy hit sound (Q48)).
- Shipped: v30.58 cw-cardP20 (card stamp), v30.61 cw-limeacc (tokens :root, UIC, ~30 hover tints on --acc; old checks read __ACC() from --acc, fixture window.__ACC).
- Next: cw-bounce (UIM.E.back, rise 24 px, pulse 1.08; old check 29.60 retargeted to hold on both), then cw-cardwide (Q43 windows), then after shots + critic.
- Gotchas: HELD=1 form is refused, use plain fixq.sh (it takes the lock itself, so unlock first). A // comment in a replacement that is followed by code on the same line kills the rest of the line: use /* */.
- Before shots: shots/04-before (01, 04, 18, 25, 26, 40).
- Not done on purpose: logo gradient, gold rarity badges, pad Y glyph, warn stay amber.
- 10-18 run (lane b): cw-bounce SHIPPED as v30.85. Next cw-cardwide. Settings card at 1080 is only 766px wide (--cw sp-5*15 at line ~1836), shop/codex etc to check. Before shots: shots/04-cw-before (02,04,08,18,65,07).
- 10-18 earlier run: cw-bounce PREFLIGHT PASS (as v30.65, now stale number); two ship tries failed (STOP uncommitted, then queue wait killed at 10 min). Not shipped yet. Re-run preflight e cw-bounce, then shipq with run_in_background and long timeout. Then cw-cardwide, shots, critic.
