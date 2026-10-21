77-minimap-off-by-default : no minimap in raids unless he turns it on in Settings (his order 2026-10-20 evening)
effort: medium

Source (his words, 10-20 about 21:55, verbatim): "remove minimap entirely, i guess make it an option in settings but default to leaving it off"
Where: the raid minimap sits under the corner money column (MMAP.box, mmBottom about dark_raiders.html line 41849; mmSizeK sets its size from the
Settings minimap row, sizes S, N, L; trBW makes the column as wide as the minimap; trBox, topRightBottom and the run info panel stack under it).

What to do:
1. One control per job (his rule): add an "off" choice to the existing Settings minimap row instead of a new row; "off" is the default.
2. His saved setting: he asked for it gone, so a save that holds a minimap size moves to "off" once (a one-time flag in the profile, never a new
   storage key; salvagerun:profile stays). After that his choice is his.
3. With the minimap off, nothing is drawn for it and nothing keeps clear of it: the run info panel and anything under the corner move up to sit
   under the money block. The full map (the m key) and the raid-start map are not touched.
4. Two players: both windows follow their own setting; both default to off.
Check (new, must fail on the build before): a fresh profile in a career raid and in the demo draws no minimap and MMAP.box is empty; set the row
to N and the minimap is back at its old size; an old save with a minimap size comes in as off once; the seed 4242 fingerprint holds.
Pictures: raid at 1080 and 4K, before and after, plus Settings with the row showing off.
Cut-off: FEATURES. Ship before Mon 10/26.
Note: job 74 (compact corner block) works on the same corner; whoever takes the first of 74 and 77 should take both, 77 first, so the block's width
is no longer tied to a minimap that is not there.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
