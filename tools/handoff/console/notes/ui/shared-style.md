# 11-ui-shared-style notes
- Guide: notes/ui/style-guide.md (5 sizes 56/32/20/16/14, space 8/16/24/32/48, rad 4, scrim .80).
- Existing: CSS :root ~line 40, buttons css ~964-1000 (.ui-btn, .ghost), title css lines 125-166, 816-821, 1078, 1111, 1213-1222, 1371-1382. renderSlots() at ~64359 builds saves with inline styles.
- Before shots: notes/shots/11-before (01,57,45,46). Critic before: see accept.json.
- Plan: step 1 cw-uishared-title: tokens in :root + JS UIK object + <style id=ui-shared-title> block using only tokens; check = block has no raw px font-size/hex.
  step 2 cw-uishared-board: same for attract (45,46).
