# 112r (lane a, 2026-10-25)
Shipped v34.54 cw-careerlegend: careerPostBuild sets legendOn=0; the folded f1 line (career, not demo) stands at the feed's right edge + 10, bottom over the vitals (the same spot as the opened list, so F1 opens upward from it). New LEGHINT var for checks. The check fails on the old build and passes on the new (folded start, both boxes in the left half and lower half, clear of the feed and vitals, shared left edge).

Facts: the old folded line stood ABOVE the 10-row feed zone (y about 500 at 1080p, mid-left, upper half); the opened list stood at x 490-900. The feed zone is always 10 rows tall, so the list cannot sit at the far left edge without covering feed rows; it stays beside the feed (left half, lower half).

Not done: pictures of the folded start, 4K, and both windows. Camera screens 19 and 33 stage the list open (legendOn forced to 1), so the after picture looks like before (shots/112r-before, shots/112r-after). Critic not run: it would score a picture showing no change. Needs a camera stage that leaves the list folded (alarms.md).

F1 still cycles folded, compact, full list (centre); no key behaviour changed. Demo: arcadePostBuild already folds the list at start (legendOn=0), so the demo does not open it on arrival today either (the job text said it does).
