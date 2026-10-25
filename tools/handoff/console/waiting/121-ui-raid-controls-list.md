# 121-ui-raid-controls-list : the opened raid keys list reads at couch distance (screens 79 and 80, his rs-1 list)
Queue (coordinator 10-25 09:35): keeps the helpers fed behind 117 to 120. Feed order: a screen the critic scored under 4. Job 112r
placed the list (v34.54, mid-bottom left, folded, F1 opens) and its notes end: "Not done: the list restyle (a separate picture job,
style-guide sizes)". Every career raid shows the folded chip; F1 opens the list.
effort: medium

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json; both need the address option ?career=1, already
in their recipe):
- 80-raid-controls-career-after-f1 2, target 4: "the unfolded panel is a dense, tiny, dim, ragged four-column block that overlaps the
  log and sits on the water".
- 79-raid-controls-folded-career 2, target 4: the folded "f1 controls" chip uses a different chip style from the "standing" tag.
Start with fresh pictures and a fresh critic score on HEAD.

Fix, in this order:
1. Measure first: if the opened list overlaps the left log or any HUD box at 1080p or 4K, clear it (move the log or stack them),
   keeping the list where he ordered it (mid-bottom LEFT, his rs-1: do not move it to another corner or make it always open).
2. The list on one opaque panel (style-guide.md Panel), key caps as in the guide's Chip / key cap rule (a cap plus a word, cap letter
   upper case, word lower case), rows at the guide's label size or larger, grouped into a few short sections instead of four loose
   columns, one footer line only (the critic saw the f1 line twice).
3. The folded chip in the same chip style as the "standing" tag.
No new bindings, readouts or controls; the same keys listed. Both windows look the same apart from their colour: take one picture from
player 2's window too.

Rules: read style-guide.md and shared-style.md first. All player text lower case, short; log any reworded or removed line with its
reason in notes/ui/changes.md (Q8). Rendering only: no change to the bindings, the F1 behaviour, saves or the storage key
salvagerun:profile. Tell the critic rs-1 and rs-2 are his rulings (position and keeping both alerts are not findings).
Checks (each must FAIL on the old build): the opened list does not overlap the left log at 1080p and 4K; its row text is at least the
guide's label size; one footer line.
Pictures: camera-recipes.json with 79 and 80 at 1080p and 4K, then the critic.
TASK DONE when 80 reaches 4 from the critic (never your own grade), or the fixes shipped and the scores are written with the reason
for any point left (stop rule 2.83 b applies); TASK PARTIAL with what is left.
