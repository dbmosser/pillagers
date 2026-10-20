69-critic-rescore-sweep : fresh camera and critic scores for screens never scored or scored on old pictures (planner draft 2026-10-20)
effort: low

Source: tools/handoff/q-round3/helper-fixes.md item 45: "Keep the score file current."
Not done (planner, 10-20): notes/ui/accept.json has 75 keys and tools/handoff/shots/ui-screens-js.json 78 screens. Never scored: 24,
27 to 31, 39, 41-hub-backpack, 43, 67, 68, 69, 71, 73. Scored on a picture from before their fix: 41-hub-backpack-pad-p1 = 1 (12:06Z,
o-10 recipes-3, before v32.84; the 48-after pictures were never scored); 10, 11 and 15 (b-31-n1, before v32.47 and v32.50); 44 and 57
(10-18 pictures, before the saves, legend and lower-case fixes).

1. One camera pass on HEAD at 1080 for: 27, 28, 29, 30, 31, 39, 41-hub-backpack, 43, 67, 68, 69, 71, 73, 44, 57, 10, 11, 15, and the
   48-after pad backpack pictures (41-hub-backpack-pad-p1 and -p2-held). 4K only where the lint flags size.
2. Skip: 47 (vetoed, never score it), 24 (c-02 used its 6 tries: his taste call), and the cut party screens.
3. Run the critic on each picture (it records the score in accept.json). Fix NOTHING in this job.
4. Write a table in notes/69-critic-rescore-sweep.md: screen, score, finish line (4 for raid, waiting, pause and run-over screens,
   3 for the rest: 3.51 a), top P0/P1 in a few words.
5. Career screens under their finish line: one alarm line in alarms.md listing them, so the coordinator can queue polish after the
   cutoff. Settings screens (27 to 31, 73) belong to c-31, which stopped after 6 tries: list them, but mark them his taste call.
Cost: about 20 critic runs (about $3) and one lane run. Party risk: none (pictures and scores only).

TASK DONE when every listed screen has a fresh score and the table is written; TASK PARTIAL with the screens left.
