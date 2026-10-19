# c-31-ui-pause-settings (lane c) notes

## Run 2026-10-18 night (c-31aa) - no work possible
- In this Console run the `run` tool REFUSED tools/uishots.ps1 (both with and without -NoLint, port 9353), so no new pictures could be taken. The critic (node tools/console-sdk/critic.mjs) does run, but the newest pictures on disk (c-31z-before/after2, c-31y-after2) predate v31.59-v31.61 for some screens and predate pset6/pset8 for 25 (pause box), so grading them would judge old builds.
- A critic run on c-31z-before/25 returned 3 and the same findings pset6/pset8 already shipped fixes for (56px report row, quiet abandon, flush tab). Nothing new to act on blind.
- Did not ship blind UI changes: no way to see them or have the critic grade them (rule: never grade my own screen).
- Next run needs the camera: shoot 18,25,26,32,42,49,70,72,74,75 first, then critic them (old picture first), then do the items still open from the c-31y list: snap settings list to whole rows, section labels before keys/pad rows, lb/rb glyphs, pad focus staging for 74/75, pause box 42/49 not yet touched.

## Run 2026-10-18 late (c-31y)
- Before shots: shots/c-31y-before. Shipped v31.59 (cw-pset10) and v31.61 (cw-pset11); after shots c-31y-after, c-31y-after2.
- Critic: 75 pad rebind 2 -> 3 (better) -> 3 (same); 70 settings controls 2 -> 3 (better) -> 3 (same). Other screens not re-shot this run (18/72/74 ~ 3 earlier).
- STUCK, so the next run should not repeat it:
  * Critic keeps asking to widen the Settings column (960) and move steppers to the right edge. That is a documented decision (cw-cardwide / v30.95: label sits next to its stepper). It also contradicts itself between rounds (pane fill: "drop it" then "put it back"). Do not chase it.
  * "send play data" as a row instead of a tab: Q61 allows moving it, not removing; not done.
  * Not done: snap list height to whole 56px rows (needs JS to measure; the 48px fade hides the cut), 20px tab strip with 32px gaps, lb/rb glyphs at the tab ends, section labels "keyboard / pad" before keys and pad rows, 3px accent tab flush on title (stray 36px lime tick is the existing 4.5*8 tab).
  * Pause box 25/42/49 not touched this run.
- All steps through cw-pset11 are lower case and keep every Q61 item.
