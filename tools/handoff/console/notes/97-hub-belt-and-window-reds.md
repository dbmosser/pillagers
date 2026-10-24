# 97 notes (lane c, 10-24)
- 33.33 passes alone on the current build (flaky in the corpus run, not a game bug). No change.
- 21.42: case b. v28 hubbagreadability/hubbagfinish put the open-backpack belt under the grid (hubBagBeltLeft/Width), left of the detail pane. Check now expects the belt centred on the grid span, still on screen.
- 18.78: case b. v2400s gambler restyle sets the list max-width to none; check now treats none as the 1060 text cap (text lines must still be 1060, never 1180).
- Committed as 3be24da0c (fixture only; no game change, so no ship). Not re-run after the edit: fixq regenerated the fixture; next corpus run will confirm. No pictures taken (no visible change).
