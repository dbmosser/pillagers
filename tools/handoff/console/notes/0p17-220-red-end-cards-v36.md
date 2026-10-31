# 0p17-220-red-end-cards-v36 (lane a, 10-31)

Result: all four checks pass on the current build (v36.92). Fixture-only commit 9e9dc91b9, no game ship (so no ON HIS PC line applies).

Per check, who was wrong:
- 36.00 (KIA card scrolls 25px at 4K): PASSES now on v36.92 with no change from me. The growth seen on v36.46 was gone by v36.92 (later end card ships). Game was fine.
- 23.87 (DAMAGE TAKEN total): the check was wrong. It hardcoded "-60", but a profile with easy mode on scales the 30 hit to 21, so the card correctly shows -42. Card total matches the log. Check now reads the sentry total off the hit log and wants "AUTOCANNON-<total>" in the DAMAGE TAKEN row.
- 29.47 (Run over 32px x scale): the check was wrong. v35.99 (ff3efd448, run over moments read clearly) set a 32px floor on the title: max(32px, 32 x scale). Check now expects the same floor.
- 31.77 (label 3x under the figure): the check was wrong. v35.99 floors the label at 20px, so at scale 0.901 the 50.5px figure is 2.5x the label. Check now wants at least 2x.

No pictures taken: no player-visible change was made (all three were stale checks and 36.00 needed nothing).
Watch line for him: none.

Runs: notes/0p17-out1.txt (before: 23.87, 29.47, 31.77 red, 36.00 pass), notes/0p17-out2.txt (after: all pass).
