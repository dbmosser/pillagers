# 00-perf-shadow-store : the ground shadow store empties itself twice a frame (coordinator 2026-10-20 05:58, URGENT)
effort: low

What broke: the full test run on v32.66 crawled (66 of the first 120 checks in 65 min, about 10x slower than on v32.16) and its
page grew to 1.9 GB, so every helper waited on memory; it was stopped at 05:02. Found with a CPU profile on the frozen v32.66 page:
each real frame took about 1 s, 42% of it inside shadowE (getContext, fill, drawImage) plus 21% garbage collection.

Cause (v32.64 cw-figlook, "the human figures are bigger and shaped"): drawOp scales the figure by FIG_SCALE*k (about 1.15) and
then opGround calls shadowE under that scale. shadowE works out a sprite scale ss from the current transform, and
`if(SHADSPR.ss!==ss){ SHADSPR.m={}; SHADSPR.n=0; SHADSPR.ss=ss; }` empties the whole store whenever ss changes. With the world at
ss 1 and the figure at ss 2 the store is emptied twice every frame, so every shadow on screen paints a fresh canvas every frame
(measured on the page: the store never held more than 2 entries; 560,000 world shadow calls next to 20,000 opGround calls at 1.15).
In real play it costs a new canvas per shadow per frame whenever the world and the figure land on different ss (frame time,
garbage collection pauses, memory): the robots and his playtest feel it too, not only the tests.

Fix: keep one store for every ss (put ss in the key, for example k=ss+':'+R.join(',')) and drop the "empty on a new ss" line; keep
the 300 entry cap. Change nothing else: same look, same sizes, same darkness (cosmetic only, no seeded draw).

Checks (each must FAIL on the old build):
- draw 3 raid frames with the player in view (figure scale on): SHADSPR keeps the world shadow keys across frames (the store
  count after frame 3 is the same as after frame 1 and above 2), and frames 2 and 3 create no new shadow canvas.
- the picture does not change: a shadow drawn at ss 1 and at ss 2 still lands in the same place and size as before.
Then prove the test run speed: on the drafted fixture, __regressBg(0,120) finishes in under 20 minutes and the page stays under
600 MB (it took 65+ minutes and 1.9 GB on v32.66). Put the measured time in your notes.

No pictures needed (no visible change). In your notes, tell him what to watch in the next playtest: raids should feel smoother
with many bodies and boxes on screen.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
