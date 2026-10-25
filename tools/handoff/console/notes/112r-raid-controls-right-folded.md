# 112r (lane a, 2026-10-25)
Shipped v34.54 cw-careerlegend: careerPostBuild sets legendOn=0; the folded f1 line (career, not demo) stands at the feed's right edge + 10, bottom over the vitals (the same spot as the opened list, so F1 opens upward from it). New LEGHINT var for checks. The check fails on the old build and passes on the new (folded start, both boxes in the left half and lower half, clear of the feed and vitals, shared left edge).

Facts: the old folded line stood ABOVE the 10-row feed zone (y about 500 at 1080p, mid-left, upper half); the opened list stood at x 490-900. The feed zone is always 10 rows tall, so the list cannot sit at the far left edge without covering feed rows; it stays beside the feed (left half, lower half).

Not done: pictures of the folded start, 4K, and both windows. Camera screens 19 and 33 stage the list open (legendOn forced to 1), so the after picture looks like before (shots/112r-before, shots/112r-after). Critic not run: it would score a picture showing no change. Needs a camera stage that leaves the list folded (alarms.md).

Run 2 (2026-10-25): re-shot 19, 33, 24 at 1080 (shots/112r-after2). All show the compact list open at x 490-900: the camera stage is not a career raid (careerPostBuild runs only when CAREER_ON), so legendOn stays 1. The fold is still unseen in a picture; the v34.54 check proves the boxes. Screen 24 fails its own expect (stale snapshot g). Needs a CAREER_ON camera stage (folded start, then after one F1), then 4k, both windows, critic with rs-1 and rs-2 named as his rulings. I may not edit ui-screens-js.json; already in alarms.md.

F1 still cycles folded, compact, full list (centre); no key behaviour changed. Demo: arcadePostBuild already folds the list at start (legendOn=0), so the demo does not open it on arrival today either (the job text said it does).

Run 3 (2026-10-25): confirmed cw-careerlegend still in the build (3 hits). No new work possible: pictures and critic still wait on a CAREER_ON camera stage in ui-screens-js.json (alarms.md line 300), which I may not edit.

Run 4 (2026-10-25): no change. ui-screens-js.json still has no CAREER_ON stage (alarms.md line 300 open). Code shipped (v34.54); pictures, 4k, both windows and critic wait on that stage.
Run 5 (2026-10-25): no change. ui-screens-js.json still has no CAREER_ON stage; code shipped in v34.54; pictures and critic still wait on it.
Run 6 (2026-10-25): no change. ui-screens-js.json still has no CAREER_ON stage; code shipped v34.54; pictures and critic still wait on it.
