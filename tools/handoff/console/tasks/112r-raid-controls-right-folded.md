112r-raid-controls-right-folded : his answer rs-1, the raid controls list sits on the right-hand side, folded, and F1 opens it (coordinator 2026-10-24)
Queue (coordinator 10-24 23:58): HIS ORDER, so it goes ahead of the red-check jobs (named 112r so the lanes take it first). His answer
to rs-1 on the raid screen calls page, in chat 10-24 about 23:55: "Other, should be on right hand side, minimized, hit key to reveal".
effort: medium

What he wants (career raids):
- The controls list is folded from the start of the raid: the one short line only (today it opens on arrival and folds itself at 30 s,
  legendAuto() in dark_raiders.html about line 11596, and his v6.68 "always open on arrival" note; his new answer replaces that note for
  career).
- The folded line and the opened list sit on the RIGHT-HAND side of the screen, not the lower middle of the play space. The right side
  holds the career column (his 10-18 one column order, cw-trcol and cw-trcol2: minimap, wallet and the rest one under another, every
  item the same width). Put the folded line in that column's flow under its last item (or the nearest clear spot on the right if the
  column is full), and open the list there too, at the column's right edge, clear of the minimap, wallet, nameplate and air strike plate.
- F1 opens and closes it as today (ONE CONTROL PER JOB: no second key; the pad keeps whatever opens it today). The folded line names
  the key in the device's own words ("f1 controls" on the keyboard; the pad button's name on the pad), all lower case.
- The party demo (G.arcade) keeps today's list for walk-up players (his 10-18 walk-up orders). Both windows (player 1 and player 2)
  behave the same apart from their colour.
- The extraction fold (cw-extlegend) and the pause screen key list stay as they are.

Rules: rendering and the legend state only; no change to what a key does. All player text lower case, short; log a reworded line in
notes/ui/changes.md (Q8). style-guide.md section 0 now carries this ruling and rs-2 (keep both alert copies).
Checks (each must FAIL on the old build): in a career raid at 1080p the list is folded at 1 s and at 40 s with no key pressed; the
folded line's box and the opened list's box both lie in the right third of the screen and overlap no other HUD box (minimap, wallet,
nameplate, power-up chips, air strike plate, run info); F1 opens it and F1 again folds it; the demo still opens it on arrival.
Pictures: camera-recipes.json screens 33 (fight with a pillbox) and the career raid start at 1080p and 4K, folded and opened, both
windows; then the critic, telling it rs-1 and rs-2 are his rulings.
Job 113a works the same right column (checks v31.50 and v31.32): ship this first; 113a reruns those two after.

TASK DONE when it ships with the checks and the pictures look right, and the critic scores are written down; TASK PARTIAL with what is left.
