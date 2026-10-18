# 11b-ui-motion notes
- References numbers: references.md lines 36-50, checks 77-89.
- DON'T grep broad patterns on the game file (data urls blow up output). Use anchored patterns.
- Built S\mk-cw-uimotion.ps1 (10 edits, 3 checks); PREFLIGHT PASS as v29.60 (2026-10-18). UIM layer after titleFit IIFE; uiSndPick pure fn; scope '#title,#partymodal' + arcade attract board tab (UIM.tab/tabOut in arcadeAttLoop).
- Checks: open 0/50/100/200 ms, stagger gaps, close <150ms, interrupt (close at 30ms of open, reopen mid-close), pulse 1.06 at 60ms, shake <=6px, tab slide, focus ring 33/81/95 percent, one tick per focus change, sound picker.
- Not done: 4K frame-time measure, pause/end cards on the layer (add selector to UIM.scope + UIM.watch(id)), hover ring, backdrop drift.
