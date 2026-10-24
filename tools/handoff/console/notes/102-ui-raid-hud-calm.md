# 102-ui-raid-hud-calm (lane a, 2026-10-24)

## Shipped (three steps, each through preflight and shipq)
- v34.24 cw-hudpanels: every HUD panel fill in a raid frame is one graphite (rgba 17,19,21 at 88 percent). Was 6 variants (blue-black plate 78, graphite 88, posture chip 78, hidden chip 78, gun card 62, near-black 90 backings). Check: all hudPanel/hudPlate fills in one frame are one colour. Retargeted old check 18.34 (belt key corner threshold 40 to 16, the plate behind the keys is more solid now).
- v34.25 cw-hudtype: HUDZ.body 1.40 to 1.36 (same as the gun card), HUDZ.raiders 1.15 to 1.08 (board words 16 px). Distinct on-screen word sizes in one raid frame 14 to 10 (check: at most 10). Top-right column zoom (cond) NOT touched (his column).
- v34.26 cw-hudquiet: item count and backpack cue on the gun card 16 px on screen (were 20 and 24); board title cream not amber (run info title already cream); hidden chip label size and the 88 percent plate. Check measures all four.

Frame cost: no draw call added (fonts, colours and two zoom numbers only), so DRS.workMs not re-measured; I could not read it from the headless gate. Watch line for him: the vitals and the belt sit a hair smaller and left, the pillager board is a little narrower, the ammo card footer is quieter.

## Critic (pictures in notes/shots/102-before, 102-after, 102-final; all 1080p)
| screen | before | final |
| 21 raid hud calm | 2 | 3 (after v34.24 and .25 alone it said "same" at 2) |
| 19 first raid | 2 | 3 |
| 37 extracting | 3 | 3 (says "yes, better") |
| 61 wheel open | 3 | 3 (says "yes, better") |
Best two versions: 102-before (v34.23) and 102-final (v34.26). Final is the better one; keep it.

## What the critic still names (not done, needs a decision or a bigger job)
1. Key legend (about 400x170, always open on raids 1 to 3): collapse to a chip after 20 s. His Q70 says no tutorial prompts; the legend is the F1 list. It is the biggest clutter block. Needs the legend job (hud.md item 2), not a type change.
2. Contract lines wrap ("extract with a haul worth $1,600 or more 0/1"): shorten contract text (Q8 allows it with a logged reason) or measure the wrap to the panel width. Many checks read contract text.
3. Hotbar: slot 1 amber outline and slot 4 blue tint both read as selected; empty slot silhouettes too loud; slot digits 12 px. P1 amber and P2 cyan stay, so this needs one chosen focus rule.
4. Extraction shows twice (top-centre chip and "extraction c available" tag on the right edge).
5. Timer 30 px vs ammo hero: the guide allows the extract timer as hero; the critic wants 56. Not done: two heroes would compete with ammo.
6. Toasts (feed) differ in width and left bar colour: the bar colour carries the kind (his feed order); a unified plate shape could be next.
7. "in cover" read as "In cover" by the critic at 16 px: it is the lower case i with its dot, not a capital. No change.

Stuck reason for 21: every remaining finding is layout or a rule of his (legend, contracts, top-right column, belt focus). No further type or colour step would move it.
