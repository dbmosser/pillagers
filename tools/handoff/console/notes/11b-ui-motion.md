# 11b-ui-motion notes
- References numbers: references.md lines 36-50, checks 77-89.
- DON'T grep broad patterns on the game file (data urls blow up output). Use anchored patterns.
- Built S\mk-cw-uimotion.ps1 (10 edits, 3 checks); SHIPPED v29.60 (2026-10-18). UIM layer after titleFit IIFE; uiSndPick pure fn; scope on title, party window + arcade attract board tab (UIM.tab/tabOut in arcadeAttLoop).
- Checks: open 0/50/100/200 ms, stagger gaps, close <150ms, interrupt (close at 30ms of open, reopen mid-close), pulse 1.06 at 60ms, shake <=6px, tab slide, focus ring 33/81/95 percent, one tick per focus change, sound picker.
- v29.62 (cw-uimotion2) SHIPPED: pausebox, outcome (end card, no open/close sound), settingsmodal, keysmodal (built lazily; UIM.watch in keysOpen) on the layer. Check: each opens 0/50/200 ms, shuts <150 ms, sound only for non-end cards.
- v29.82 (cw-uimotion3) SHIPPED: 15 hub windows (trader, gamble, bar, appear, trophy, codex, lb, wn, sector, stage, carry, crate, op, welcome, terms) on the layer, same check pattern. Not on it (deliberate): fbmodal, askmodal, devmodal, cheatmodal, tunemodal, simmodal, sharemodal.
- Not done: 4K frame-time measure (needs a 4K stepping harness), hover ring, backdrop drift, cursor parallax, glimmer.
