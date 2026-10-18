# Changes to the queued tasks (tools\handoff\console\tasks) after his picture survey of 10-18
How to read: FILE, then OLD (copy it exactly) and NEW. Tasks 02, 03, 04 and 12 are the only queued tasks that now clash with a pick; 05 is done (console\done). The 31 new tasks are in tasks\ of this folder (20, 21a to 34b). Lower case rule: every string a player sees is lower case; the game lowers every string through one text door (ncFix, cw-lowercase), so nobody rewrites strings one by one. The capitals below are only in these task instructions.

## Why the new tasks are small
The four big UI jobs that were tried whole (13, b-30, b-31, c-31, now in console\failed) each ended after five partial runs. Every new task names its q-numbers, exact values, screens and finish line, and is sized for ONE helper run (the runner caps a run at $4 and 150 turns, and a task at 5 runs). The repo moves fast: a co-op hunt keeps shipping critic-driven fixes while he is away (v30.92 to v30.97 so far, for example a plate behind the score, settings values beside their names, a calmer feed). Each new task therefore starts with "read git log -12 first, ship only what is missing". Where such a fix and his picture disagree, his picture wins and the helper says so in its notes (conflicts.md 26 and 27 are two cases).

## Before anything runs (the session does this once)
1. Copy out\style-guide.md over console\notes\ui\style-guide.md (first line must stay READY). The critic reads only its first 8000 characters: section 0 carries the survey essentials inside that window.
2. Copy out\ui\*.md over the same names in console\notes\ui\ (motion, hud, end-cards, pause-settings, undercroft, shared-style).
3. Put one line at the very top of console\notes\ui\look-book.md and of console\notes\ui\references.md: OLDER THAN THE 10-18 SURVEY: where this file and style-guide.md disagree, the guide wins (his picture survey of 10-18 decided colours, sizes, glass cards, motion and every screen layout).
4. Create console\notes\ui\survey\ and copy the chosen pictures into it from menu-survey\img\ so view_image can open them: q01-b.jpg, q02-c.jpg, q03-c.jpg, q04-b.jpg, q05-c.jpg, q06-b.jpg, q07-b.jpg, q08-b.jpg, q11-d.jpg, q12-b.jpg, q13-c.jpg, q14-c.jpg, q15-c.jpg, q16-a.jpg, q17-b.jpg, q17-c.jpg (the ring picture task 26b looks at), q18-a.jpg, q19-a.jpg, q20-a.jpg, q21-d.jpg, q22-c.jpg, q23-d.jpg, q24-b.jpg, q25-b.jpg, q26-a.jpg, q27-d.jpg, q29-c.jpg, q30-c.jpg, q31-d.jpg, q33-b.jpg, q34-a.jpg, q35-a.jpg, q36-a.jpg. q09, q10, q28 and q32 have no jpg: their html is in menu-survey\snip\ (q09-b.html, q10-b.html, q28-b.html, q32-c.html) and tasks 24a and 24b read the numbers from there.
5. Do the queued-task changes below (02 and 04 retire, 03 amended, 12 held and amended).
6. Copy the new tasks into console\tasks in waves, because the runner has NO dependency check (lane a takes [0-9]*.md by name, the others take any free task by name, so copying all 31 at once runs them in the wrong order). Rule: copy a task only when every task its own "Needs" sentence names is in console\done. About five run at once (five lanes). The table is the earliest grouping:
   W1: 20.
   W2: 21a, 22c.
   W3: 21b.
   W4: 22a, 22b, 25a, 26a, 26b (25a, 26a and 26b only after 02 has left the queue).
   W5: 23a, 24a, 25b, 27a, 33b (27a only after 03 is in done or failed).
   W6: 23b, 24b, 27b, 28a, 29a, 29b, 30a, 31a, 32a, 33a, 33c.
   W7: 28b, 30b, 31b, 32b.
   W8: 34a, and 12 goes back into console\tasks (see its section).
   W9: 34b.
   If time runs short before Mon 10/26, drop the career-only jobs first (29a, 29b, 31a, 31b, 32a, 32b) and keep every party-facing job. 33c is a feel ship (no critic): it goes through mk-cw-*.ps1 and shipq like any game change.

## tasks\02-raid-hud-redesign.md  (RETIRE: the work is now tasks 25a, 25b, 26a, 26b, 33a, 33b and 33c)
Lane a has 02 now (run 3 of 5 in runs.log, last run $1.94). When its current run ends (its next runs.log line), move console\tasks\02-raid-hud-redesign.md to console\done\ by hand; its notes file stays, and 25a reads it. Do not copy 25a, 26a or 26b before that, so two helpers never redraw the raid HUD together. If it stays in the queue instead, change it as below, so the next run costs almost nothing.
OLD: REDESIGN THE RAID SCREEN (his answers 10-18; he put the raid screen FIRST, Q49).
NEW: THE RAID SCREEN IS NOW TASKS 25a, 25b, 26a, 26b, 33a, 33b AND 33c (his picture survey of 10-18 fixed every pixel of it). This task changes no code: check that notes\02-raid-hud-redesign.md exists, then end TASK DONE at once. The old ask, for history: REDESIGN THE RAID SCREEN (his answers 10-18; he put the raid screen FIRST, Q49).

OLD: TASK DONE when every listed screen scores 4 or more from the critic, or TASK PARTIAL with the rest.
NEW: TASK DONE as soon as the notes file is confirmed (there is nothing to score here).

## tasks\03-title-and-backdrop.md  (keep; it is in its late runs, and it must be in console\done or console\failed before 27a is copied; its fight is already in: v30.69 cw-title-fight, v30.82 behind the scoreboard and how-to)
OLD: - Q50: keep the normal title screen (no special party version). Q51: drop the story paragraph and the three step cards for one
  line, "Ascend. Pillage. Extract." Q53: no raiders beside the logo. Q72: no PvP row (task 01 hides it).
NEW: - Q50: keep the normal title screen (no special party version). Q51: drop the story paragraph and the three step cards for one
  line, "ascend. pillage. extract." (lower case, under the lime wordmark at the bottom-left, his q12 B). Q53: no raiders beside the logo. Q72: no PvP row (task 01 hides it). The title layout itself (menu column on the right, player switch, three rows) is task 27a, from his q11 D and q13 C.

OLD: - Q52 and Q54: behind the title, the scoreboard and the how-to pages, show the live map, dimmed, with REAL pillager-versus-robot
  combat happening in it (no recorded clip). It must not cost frame rate: 60 fps at 4K on the title.
NEW: - Q52 and Q54: behind the title, the scoreboard and the how-to pages, show the live map graded dark teal (his q14 C), from the bottom: the map at 30 percent colour (canvas composite saturation with grey at .70), a #07131a fill at 60 percent, a teal tint (#12707c, composite color, 42 percent), lime tracers and white muzzle flashes on top, the right-side scrim of his q11 D, and a cached vignette (an ellipse 78 percent by 80 percent, clear to 52 percent, edge rgba(0,0,0,.5)); NO blur. REAL pillager-versus-robot
  combat happens in it (no recorded clip). It must not cost frame rate: 60 fps at 4K on the title, with no per-frame filter and no extra offscreen copy of the world.

OLD: Screens 01, 44, 45, 46, 56, 57. Before and after pictures, the critic, 4 or more. TASK DONE when shipped and scored, or PARTIAL.
NEW: Screens 44, 45, 46, 56, 57, and 01 for its backdrop only (the title layout is task 27a). Before and after pictures, the critic, 4 or more. TASK DONE when shipped and scored, or PARTIAL.

## tasks\04-style-guide-update.md  (RETIRE: the guide is already written and tasks 20 to 24b do the shared look)
Move console\tasks\04-style-guide-update.md to console\done\ by hand when its current run ends (run 3 of 5 in runs.log). Its notes (notes\04-style-guide-update.md) still say that cw-bounce passed preflight but is NOT shipped and that cw-cardwide should not be built: both are OBSOLETE, v30.85 (menus bounce on open) and v30.89 (settings and keys fill the screen as a card) are in the game. Put one line at the top of that notes file: cw-bounce (v30.85) and cw-cardwide (v30.89) are shipped; task 24a retunes the bounce to his picture and task 22a sets the exact window; nobody deletes them. If the file stays in the queue instead, change it as below.
OLD: Edit notes\ui\style-guide.md and the shared UI object in the game, then re-apply to every screen already on the shared look:
NEW: Change nothing in the game: his picture survey of 10-18 settled all of this (the guide is already written, tasks 20 to 24b do the shared look). Only check that notes\ui\style-guide.md starts with READY and that its section 0 is under 8000 characters, then end TASK DONE. The old asks below are history:

OLD: Run the critic on the screens you touch. TASK DONE when the guide and the shared look are updated and re-applied.
NEW: TASK DONE as soon as that check passes (there is no screen to score).

## tasks\05-party-launch-mode.md  (no change: it is DONE; v30.79, file in console\done)
Nothing to edit. Two things for the later tasks, written into them already: (1) task 27a must keep the ?party=1 behaviour (title hidden, arcade attract at once, checks (a) to (g) of task 05 stay green) when it builds the new title list of his q13 C; with ?party=1 the whole list is hidden; (2) the strings that task 05 left in capitals ("Player 2: press A", "Exit demo", "1 PLAYER") go lower case through the text door and tasks 27a, 34a and 34b check them (his order), nothing else about task 05 changes. The pause stays the same entries, drawn as the q29 C tiles in task 30a.

## tasks\12-ui-party-screens.md  (HOLD, then keep but shorter: the other screens now have owners)
Runs.log shows 12 at run 4 of 5, and its notes say it is stuck on 62 because the critic keeps giving 3 to small cards. Move console\tasks\12-ui-party-screens.md to a new folder console\held\ now (when no lane has it), and put it back into console\tasks in wave 8 with 34a, when 22a, 22b, 27b and 28b are in console\done (34b judges 62 and 63, so 12 must be in done before 34b). It has one run left; with two screens instead of thirteen that is enough. If it still ends partial, split 62 and 63 into two tasks.
OLD: Screens: 46, 47, 48, 49, 52, 53, 54, 55, 56, 58, 62, 63, 64. Move each onto the shared look and fix what look-book.md says,
NEW: Screens: 62 and 63 only (the arcade operator menu and its new-party confirm; v30.97 already dropped its empty run count and made the focus ring amber: keep both). The rest have owners: 46, 54, 56 and 64 are task 28b; 52, 53 and 55 are task 28a; 58 is task 27b; 49 is task 30a; 47 is task 23a; 48 is tasks 25a, 26a and 26b. Shoot those anyway after they ship and fix only what is still under 4. Move 62 and 63 onto the glass shell (a dialog 640 wide, main action lime, "exit demo" separate as the danger ghost, lower case) and fix what look-book.md says,

OLD: Read
notes\ui\style-guide.md, look-book.md and shared-style.md first.
NEW: Read
notes\ui\style-guide.md (rewritten 10-18 evening: lime #c4f12e, glass cards, 24/32/48/96), look-book.md and shared-style.md first. Needs tasks 22a and 22b shipped (git log shows their cw- keys); read git log -12 first.

Its notes (notes\12-ui-party-screens.md) end with that stuck report. The open asks are now decided by the survey: bake the world dimmed and hide the HUD behind a pause or card = q07 B, task 22c (blur 12px + 55 percent black; fixture 29.88 is retargeted to it, no 95 percent solid scrim any more); focus state on rows = q05 C, task 22b (6px lime bar + wash); the how-to page (46) gets the glass card with the 56px X and a lime button, task 28b.

## console\RULES.md (optional, one line)
OLD: - Consistency beats a one-off: follow tools/handoff/console/notes/ui/style-guide.md once it exists, and fix the guide, not the
  screen, when the guide is wrong.
NEW: - Consistency beats a one-off: follow tools/handoff/console/notes/ui/style-guide.md (rewritten 10-18 evening from his picture survey; his chosen pictures are in notes/ui/survey/) and fix the guide, not the screen, when the guide is wrong. Where the guide and a picture he chose disagree, the picture wins.

## Old checks the new tasks will break (the helpers retarget each through fixq.sh; listed so nobody is surprised)
29.88 and the other solid-scrim checks (scrim .80 to .97 becomes 55 percent over a 12px blur, task 22c); 29.33 (no raw literals in ui-shared: new fixed strokes 2px, 4px, 6px need tokens or an allow-list entry, task 22b); the cw-tvtext profile checks (uiScale 1.5, menuZoom 1.25, career 1.3 become 1.0, task 21b); the UIM motion checks (open 0/50/100/200 becomes 0/60/154/280, stagger, tab slide, ring 33/81/95, tasks 24a and 24b); 30.85 (the bounce numbers c1 1.5, 24px rise, 1.08 pulse, task 24a); 30.89 (settings and keys fill the screen less 48px: task 22a makes every window 1728x972 at x96 y54); 30.90 (title buttons 48px: task 27a); 30.91 and 28.78 (the downed bar family: the sliding-mark bar and its +0.50s pop stay, only the plain bleed bar goes, task 33b); 30.93 (the feed lines, task 33a); 30.95 (settings value next to its name: task 30b puts it at the right end of the row, conflicts.md 26); 30.96 (the plate behind the score, task 25a, conflicts.md 27); 29.83 (tile size 72 becomes 112/100/80, tasks 29a and 31a); HUDBOX overlap and text-drawn checks (the whole raid HUD moves); title row checks (the new switch and three rows); settings checks that read #setdetail; any check that names #e6ff3d, #16191b, #efe9dc, #aaa498, #e5482f, #9cc7ff or #7fa6c9.
