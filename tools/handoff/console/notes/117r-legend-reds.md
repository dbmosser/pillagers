# 117r-legend-reds (lane a, 10-27)
All three failed alone on the current build, and all three were case b (the check went blind after v34.78 made the legend key caps). No game change, no ship: fixture commit 8ce8aa33b, all three PASS on the rebuilt fixture.
- 8.91: legend is 267 wide at 1080p (was 311 floor) but a taller panel with bigger type; floor is now the AREA of the old panel scaled with the screen (raiders and cond keep the width floor).
- 18.60: key text is centred in its cap, so x is the middle; check now reads edges from the textAlign it was drawn with. No real collision (the cap sizes itself).
- 17.76: the old 'tactical belt' label and column no longer exist; check now compares the right edge of column 1 words with the left edge of the cap holding B / I in column 2 (needs a 4px gap).
No picture taken: nothing visible changed.
