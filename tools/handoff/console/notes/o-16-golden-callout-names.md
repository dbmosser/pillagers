
--- codex run 2026-10-20 14:52 ---
2026-10-20: Prepared cw-cx-goldnames against v32.99. No tracked game file was edited.

The host now passes the fallen body kind into goldDrop and stores it for the death word. The word adds a fifth field, keeping the original four fields in place. The linked receiver uses that kind even when the body never reached its window. Older four-field words use a cached body when available. One helper produces golden sentry down, golden pillager bot down, golden crawler down, golden bulwark down, golden howler down and golden listener down. Search the hoard, loot, effects, timing and random draws stay as before.

The new fixture check tests every name directly, then exercises goldTick, goldDrop, goldNetOut and goldNetTake for all six kinds. It verifies the subtitle, one hoard on the host, no second hoard on the receiver, no repeated callout, and the older-word fallback. The control build lacks the helper and returns a failure. Three older checks expect the generic words; fixture-retarget.json keeps them valid on both old and new builds before shipping.

Local validation: mk script printed written; all eight anchors matched exactly once; patched inline JavaScript and the new check parse with Node; all three fixture anchors match exactly once. No Chrome or runtime check was run in this sandbox. The lane owns preflight, shipping and runtime results.

Four camera recipes stage sentry and pillager bot callouts through both the host death path and the linked receiver path. These are separate staged views, not a connected two-window play session. Pictures and critic results remain for the lane. No layout or game-feel changes are included.


--- codex run 2026-10-20 15:26 ---
2026-10-20 follow-up: The lane shipped cw-cx-goldnames as v33.07 and applied fixture retarget commit 9c4d34c4. The three retargeted checks passed on the trial build before shipping.

Reviewed all four attached round-1 images. None shows the golden callout because all four camera stages threw before calling the golden code. The recipes were evaluating private game functions from page scope. Corrected all four recipes to use the existing fixture-only __gx game-scope helper. The fixture does not advance the feed entrance merely by waiting, so staging now calls feedTick(0.3) and __frame explicitly. It clears old feed and map-popup queues and collapses the fixture-forced controls legend through its existing state. The camera now requires a matching FEEDBOX row and a matching text draw, rather than accepting only a logged message.

The first critic round judged invalid staging and the surrounding unchanged raid HUD. Its missing-callout finding is addressed by the recipe correction. No HUD redesign is part of this words-only job; those pictures cannot assess the shipped callout. No extra ship key or game change is needed. All revised recipe JavaScript and expect expressions parse locally. Lane action: photograph the revised four recipes and run the critic again.


--- codex run 2026-10-20 15:30 ---
2026-10-20, round-2 review: All four camera recipes staged correctly with zero lint findings. The attached pictures visibly confirm golden sentry down and golden pillager bot down in the host and linked paths, with search the hoard. The same line also appears in the bottom-left feed. The critic scored each full raid frame 2 and identified that duplicate as a P0/P1 defect.

Prepared cw-cx-goldonce to address the task-related duplicate in both paths. It adds the existing fd option to the two say calls, keeping the top callout and skipping the redundant feed entry. It keeps all six specific names, the required subtitle, the message log, hoards, death packet, effects and timing. The critic suggestions to shorten pillager bot to bot and delete search the hoard conflict with this task and were not followed.

The new check stages sentry and raider deaths on both paths, renders the real HUD with the fixture say wrapper, and requires exactly one text draw containing the name and search the hoard. Round-2 traces and pictures show two copies on the control build, so this check fails there. Revised camera expectations require one drawn callout and no duplicate feed row. Local validation: mk script printed written; two unique anchors; patched game script and regression check parse; handoff is ASCII. Runtime validation and the next four pictures belong to the lane.

Other critic findings concern the unchanged raid HUD, including its currency column, status bars, hotbar and panel styles. This task is a specific golden-name change, not a raid HUD redesign. The mandated four career currency rows must not be removed or merged on critic advice.


--- codex run 2026-10-20 15:40 ---
2026-10-20 final review: cw-cx-goldnames shipped in v33.07; cw-cx-goldonce shipped in v33.08. Both keys remain in keys.txt. The current fixture contains their checks as 33.07 and 33.08; the lane reported successful ships through its gates. The three older retargeted checks were committed as 9c4d34c4 and passed before shipping.

Inspected all four attached round-3 pictures. Both host and linked paths show golden sentry down or golden pillager bot down once, with search the hoard. The extra bottom-left copy is gone. Camera staging confirms one text draw, zero matching feed rows, and zero lint issues in each view. These are separate staged host/receiver views, not a connected two-window session.

Review stop rule: after the two follow-ups (correcting staging, then removing the duplicate), the critic score remains 2 for all four full raid images. Applying the rule to record what is stuck and move on. This is not a critic pass. Remaining findings include the existing raid panels, currency column, ghost panel under the roster, hotbar and status bars, plus the callout's inherited 18.7px styling and hierarchy under the timer. The duplicate was fixed. Do not delete search the hoard or shorten pillager bot; those critic suggestions conflict with this task. No broader HUD redesign or timing change is included.

Preserved the two best available versions for comparison:
- v33.07, correct names with the duplicate: tools/handoff/console/notes/shots/o-16-golden-callout-names-recipes-2/golden-sentry-host-1080.jpg and golden-sentry-linked-1080.jpg; golden-raider-host-1080.jpg and golden-raider-linked-1080.jpg in the same directory.
- v33.08, final chosen version with one callout: tools/handoff/console/notes/shots/o-16-golden-callout-names-recipes-3/golden-sentry-host-1080.jpg and golden-sentry-linked-1080.jpg; golden-raider-host-1080.jpg and golden-raider-linked-1080.jpg in the same directory.

The requested specific-name behavior and regression checks are shipped. No further lane work is requested for this task.

