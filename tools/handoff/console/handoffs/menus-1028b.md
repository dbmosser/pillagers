# Menus master handoff (VM session, 2026-10-28 evening)

## Role, his words
"This thread is the 'menus master'." Then: "can you continue to refine menus?" Runs locally on the VM in C:\claudecode\dark raiders and ships its own drafts.

## His standing orders to this chat
- Plain words only. His words: "i don't know what any of this means but it's not helpful" and "Im not a dev. Are you improving the menus or not." No check names, file names or versions. Say what changed on screen, show a picture, give one watch line.
- "money versus raid score/sp should never be intermingled" (extracted card, 10-28).
- Pause box shows every modifier and setting that changes sp.

## His screen is 4K
His feedback pictures are 3838x2158. Hub zoom there is 2.27 (about 1690x950 layout px), the run card zoom 2.47 (874 layout px tall). Always take pictures at 4K as well as 1080 (uishots -Res 4k,1080).

## Shipped (ON HIS PC)
cw-spmoney v35.45, cw-xpbreak v35.73, cw-pausesp v35.75, cw-menupolish1 v35.88, cw-pausecond v35.89,
cw-menupolish2 v35.93 (Wirt gamble panel: mystery tile beside the odds by rarity; stash hotbar ends on the backpack row, scroll bar or not),
cw-endcards v35.95 (KIA card: how it went and damage taken side by side at body size, names left aligned, time as m:ss; extracted card: damage taken sources in two columns so the footnote sits above the button).
cw-wirtfit v35.97 (Wirt offer at 4K: the offer picture gives up height when the panel is short, so the buy button lines up with the gamble button and its need line sits inside the panel; builder menus-round5/build-round5.py).
cw-kiafit v36.00 (KIA card with a full 8 hit list fits 4K: rows line height 1.4, lost money and tiles closer; builder menus-round5/build-round5b.py).
cw-keycards v36.18 (HIS ORDER 10-28: in-game keys are keycards; keys only means keys you press; builder menus-round6/build-keycards.py).
cw-stashtabs v36.21 (HIS PICK a: loadout tabs backpack and keys on the loadout title line; item details a floating card beside the stash item; old check 35.42 retargeted by fixq; builder menus-round6/build-stashtabs.py).

## Stash backpack pick: DONE
He picked a on 10-28 (shipped v36.21). Pad players: the details card follows the pad highlight in the stash grid.

## Next candidates
- CEO 10-28: next, menus the party players see first (title, demo start, run cards) at 4K.
- The 16-screen survey sheets in tools/handoff/drafts/menus-round1/ for anything else that looks squeezed at 4K.

## Drafts folders
- menus-round1: survey sheets. menus-round2: cw-menupolish2 builder (vm-fix-round2.py), wirt recipes, VM pictures.
- menus-round3: stash pick mockups and page. menus-round4: cw-endcards builder (build-round4.py), check (check-endcards.js), recipes-cards.json (KIA and extracted card with a fake hit history), base/ and after/ pictures.

## Must not
- Reword his TXSHIP lines: the hire banner "***experimental feature may glitch***", "buy a friend.", "stuff for you to do.", "no history between you.", the crafting and notoriety descriptions.
- Restyle the corner money readout (trcol).
- Cut the 1 sp = $1 payout on extraction unless he says so.
- Edit dark_raiders.html or tools/mkfixture.ps1 by hand; touch 8802; close or restart the gate Chrome 9346.

## How this chat worked (VM)
- Builders are python scripts run from the repo root that write tools/handoff/drafts/draft-cw-KEY.json; anchors are literal and must occur once.
- mk script in the ship scratchpad (C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/mk-cw-KEY.ps1) only checks the draft parses; copy mk-cw-endcards.ps1.
- bash tools/handoff/preflight.sh g cw-KEY (lane g, Chrome 9357), then shipq.sh cw-KEY from that scratchpad in the background; done = the ON HIS PC line.
- Test Chrome: powershell -File tools/cdp.ps1 -Start -Port 9357 -Size 3876,2265 (4K viewport) or 1956,1185 (1080); one at a time; -Close after. A drafted fixture for probing: write tools/fxNAME.html, probe JS served from tools/ via fetch+eval; delete both after.
- Weekly plan use is high: one change at a time, no parallel agents or workflows.

## Check-ins
None scheduled.
