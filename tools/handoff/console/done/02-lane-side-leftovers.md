# 02-lane-side-leftovers : the pictures and critic runs nine shipped Codex jobs left behind (4K, linked windows, one report copy)
Queue (CEO 11-01): folded from waiting/, where these sat 2 to 11 days. Every game change below is already shipped and ON HIS PC; the Codex
lane could not finish them because its camera is fixed at 1080p and its camera rounds ran out. A Claude lane CAN shoot 4K and linked windows.
effort: medium

What this job is: take pictures, look at them, run the critic, write what you saw. NO game change and NO ship in this job. If a picture
shows a real bug, or a critic P0/P1 needs code, write it as one line under "Follow-ups" in notes/02-lane-side-leftovers.md (job name, what
is wrong, picture path) and move on; the coordinator turns those into jobs.

Camera (your lane port 936N: a=1, b=2, c=3 ...). Each job's Codex camera recipe is tools/handoff/codex/work/JOB/recipes.json (on this VM;
the folder is git-ignored, so read it, do not expect it in git). Typed exactly:
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 -Recipes tools/handoff/codex/work/JOB/recipes.json -Out tools/handoff/console/notes/shots/02-JOB -Res 1080,4k -Port 936N
(recipes marked popups below open a second window by themselves: "popups": true in the file). Then Read every picture, then
  node tools/console-sdk/critic.mjs OLD-1080.jpg tools/handoff/console/notes/shots/02-JOB/NAME-1080.jpg tools/handoff/console/notes/shots/02-JOB/NAME-4k.jpg
with OLD the newest Codex picture of that screen (tools/handoff/console/notes/shots/JOB-recipes-N/, highest N). The critic does not know
his rulings; skip findings that would reverse one. A recipe that fails to stage: fix the recipe in a copy at
tools/handoff/console/notes/02-recipes/JOB.json (you may write under notes/) and shoot from that; at most two tries per job, then note it and go on.

The nine (do them in this order; party and 2 player first):
1. o-00v-239-ping-and-map-mark-are-one (v36.53, popups, 6 screens). Left: linked captures on the current build; raid critic was 3/4. Look:
   the middle mouse mark and the map mark are one mark in both windows (P1 amber, P2 cyan).
2. o-140-red-enemy-tracers (v35.67, popups, 4 screens day/night P1/P2). Left: the 4K pictures and critic. Look: enemy rounds read red
   against the red danger HUD, noise rings and rain at night; player rounds keep their gun tint.
3. o-120c-wallet-double-text (fix in v35.01/v35.48, popups, 6 screens). Left: the 4K pictures. Look: ONE cash figure in the top right box,
   hub and raid, both windows. Codex's 1080 run passed 51 of 51 samples; only 4K is unproven.
4. o-145-pad-sprint-toggle-default (v36.66, 2 screens host/p2). Left: recapture with the corrected recipes and the critic. Look: the
   sprint row shows the new default (hold on keys, toggle on the pad) and is in view.
5. o-11-157-golden-bolts-and-stays (v36.64, 2 screens career/demo). Left: one picture per window of a LINKED 2 player raid with a fleeing
   golden. The recipe is single-window; make a linked copy (take the pairing and popups setup from o-140's recipes.json) in notes/02-recipes/.
6. o-02-172-night-pays-cash (condition SP 1.05x, v36.57, 4 screens). Left: post-ship pictures and the critic of the sector page, terms and
   the extracted card (host and guest). Look: the condition shows as SP, no extra $. (The linked SP check is job 211, not this one.)
7. o-91b-report-news-style (v33.70, 2 screens news window and report recorder). Left: real 4K pictures and the critic; the news window
   scored 2 and the recorder 3 at 1080. Record both scores at 1080 and 4K; a score under 4 goes in Follow-ups with its P0/P1 list.
8. 85-preraid-map-no-cache-labels (v33.55, 2 screens). Left: the raid-start map at 4K and the critic. Look: no cache, looted or strongbox
   words on the raid-start map; extract labels still there. His picture: notes/his-shots/2026-10-20-preraid-map-cache-labels.png.
9. o-131-gun-impact-sound-caps (v35.38, no pictures). Left: copy the Codex report /c/claudecode/pillagers-codex/.codex-work/o-131-gun-impact-sound-caps/notes/131-sound-caps.md
   to tools/handoff/console/notes/131-sound-caps.md (Read it, then Write it there unchanged), with one line at the top: "copied 11-01 from
   the Codex work folder; the voice counts are its local probe, not a browser measurement".

Write as you go, one block per job, in tools/handoff/console/notes/02-lane-side-leftovers.md: picture paths, critic score 1080/4K, what
you saw in one line, and Follow-ups. The original job files are in done/ with a "folded" line; do not move them.
Rules: never touch the game file, the pickup stack, loot sounds or loot rows; no ship; no 8802. Model: Sonnet high.
TASK DONE when all nine have a block in the notes file (a job whose recipe would not stage after two tries counts, with the reason).
TASK PARTIAL with the numbers of the ones left.
