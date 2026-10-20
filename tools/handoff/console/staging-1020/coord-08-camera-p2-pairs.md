coord-08-camera-p2-pairs : close o-07 and o-08, then make the camera stage player 2 of a real linked pair (planner draft 2026-10-20)
effort: medium

COORDINATOR OR A SESSION AGENT (tools/uishots.ps1 and the o-07/o-08 waiting files). Do not move into tasks/.
Merges three survivors: two-window-pictures, p2-window-pad-verify and camera-p2-never-stages.
Source: tools/handoff/q-round3/answers.md 2.86 (a 2-player change is done only when seen in both windows): "a: Yes"; waiting/o-07-pad-lost.md: "TASK PARTIAL: coordinator must run the supplied camera command".
Not done (planner, 10-20): o-07-pad-lost.md and o-08-pad-owner.md are still in tools/handoff/console/waiting/, not done/. The camera
summaries show every real-pair player 2 shot as "NOT STAGED ... both real windows did not link" (o-04 pair, o-06 recipes-2, o-07
recipes-4, o-08 recipes-3 and -4). uishots.ps1 has had no fix since c2a7b924 (-NoPopupBlock). The robots link two windows fine (fuzz.log
p2=link_7s_join_9s), so the camera path is at fault, not the game. Single-seat p2 scenes and the p1 side of a pair DO stage.

1. Today: run the corrected o-07 and o-08 recipes once with uishots -NoPopupBlock, as the 10-20 04:00 coordinator note in both files says.
   Linked: run the critic, close both into done/. Not linked: close both TASK DONE with one line and put the two-window look on his
   playtest list. No more camera rounds for them.
2. Then: find why the camera cannot stage the player 2 side of a real pair. Is it the recipes (o-08 found netslot=B with p2=1 disables
   NETP2) or uishots' second-window handling? Compare with how tools/fuzz.ps1 pairs. Make one real-pair player 2 picture stage (demo raid
   and hub).
3. Then rerun the two-window checks that went to his playtest sheet if cheap (o-01 stash pays per window), and take the two
   pictures job 62 waits on (waiting/62-share-drop-ping.md: a dropped item pings the teammate, v32.97), then move 62 to done/.
Why it matters: job 62 (share by drop) and any 2-player change before the lock is done only with a picture from each window (2.86 a).
Party risk: low (tooling only).
Done when: o-07 and o-08 are in done/, and one real-pair player 2 picture stages.
