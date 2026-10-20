coord-10-critic-recipe-records : the critic records recipe pictures, and "pass" follows his finish lines (planner draft 2026-10-20)
effort: low

COORDINATOR ONLY (tools/console-sdk/critic.mjs is not in a lane's write list). Do not move into tasks/.
Source: tools/handoff/console/alarms.md (o-02): "critic.mjs does not persist accept.json records for custom filenames".
Not done (planner, 10-20): tools/console-sdk/critic.mjs line 31 (shotName) and line 66 only record a picture whose name matches
/(\d\d-[a-z0-9-]+?)(-1080|-4k)?\.(jpe?g|png)$/, so j8-*, j7-*, corpus-air-hand-* and stashraid-* scores are never saved; line 67 sets
pass: v.score >= 4 for every screen. Its last commit is 61964ab8 (10-19). accept.json has 75 entries and 1 pass:true (skeptic count).

1. Record a recipe picture under its recipe name (the file name without -1080/-4k and the extension) when it has no NN- prefix.
2. pass follows his 3.51 a: 4 for the raid, waiting, pause and run-over screens; 3 for the rest.
3. Do not add a "his taste call" mark for 6-try screens: no order asks for it (the skeptic dropped that part).
Party risk: none (tooling).
Done when: a recipe picture's score appears in accept.json under its name, and pass matches the finish line.
