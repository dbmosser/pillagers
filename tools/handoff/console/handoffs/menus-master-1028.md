# Menus master handoff (cloud session_01LWYNPXiHS4AhCeZ16oZ6gY, 2026-10-28)

## Role, his words
"This thread is the 'menus master'." Then: "can you continue to refine menus?"

## His standing orders to this chat
- Plain words only. His words: "i don't know what any of this means but it's not helpful" and "Im not a dev. Are you improving the menus or not." No check names, no file names, no versions unless he asks. Say what changed on screen, show a picture, and give one watch line.
- "money versus raid score/sp should never be intermingled" (extracted card, 10-28).
- Pause box: "this is where all the modifiers/settings that impact sp should be shown, so the player knows exactly what they are playing" (10-28).

## Shipped (ON HIS PC)
cw-spmoney v35.45 (extracted card: score panel and money panel), cw-xpbreak v35.73, cw-pausesp v35.75, cw-menupolish1 v35.88.

## Open, ready to ship (branch claude/blissful-gates-fumotn, commit 0c93ad02, pushed)
1. cw-pausecond: tools/handoff/drafts/draft-cw-pausecond.json plus retarget-cw-pausecond.patch (check 35.75, regenerated on v35.88). The pause box also lists night, hard weather and signed terms (x1.05 each), and the headline is settings times conditions. This completes his pause order. Cloud gate PASS on v35.88.
2. cw-menupolish2: draft-cw-menupolish2.json, menus-round2/. Wirt's gamble panel gets a mystery tile and odds by rarity; the stash hotbar sits on the backpack's 12px inset. Gate PASS on v35.87. Ship after 1.

## Next candidates (from the 16-screen survey, tools/handoff/drafts/menus-round1/survey-sheet*.jpg)
- Stash backpack: #kitgrid is a 139px box, so 10px of the second row of slots peeks under the first. His answers 8 and 28 require 12 slots to be drawn, so fixing it needs a layout pick from him (2 or 3 pictures). Do not resize the stash without his pick.
- KIA card (the non-career one) still has small centred "how it went" and "damage taken" tables.
- On a run with many recovered guns, the extracted card's damage footnote scrolls under the button.

## Must not
- Reword his TXSHIP lines: the hire banner "***experimental feature may glitch***", "buy a friend.", "stuff for you to do.", "no history between you.", and the crafting and notoriety descriptions.
- Restyle the corner money readout over every window (his trcol order).
- Cut the score-to-money payout (1 sp banks $1 on extraction, his 10-12 rule) unless he says so. I offered; he has not answered.
- Ship from the cloud. Cloud drafts go to the CEO chat; the PC ships them.

## Tools (cloud)
- PowerShell 7: see tools/cloud/README-2026-10.md.
- Gate: bash tools/cloud/gate.sh KEY [--base REV]. For a retarget or a stale card stamp, gate against a temp worktree commit; never push that commit.
- Camera: tools/handoff/drafts/menus-round1/cshots.mjs FILE OUTDIR names (runs the uishots recipes headless).
- Builders and checks for each draft are in its drafts folder.

## Check-ins
None. This session never scheduled any, so nothing was cancelled.
