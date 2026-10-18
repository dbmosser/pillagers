# Changes to the queued tasks (tools\handoff\console\tasks) after his picture survey of 10-18
How to read: FILE, then OLD (copy it exactly) and NEW. Tasks 02, 03, 04, 05 and 12 are the only queued tasks that now clash with a pick. Tasks 20 to 34 (this folder, tasks\) are new. Lower case rule: every string a player sees is lower case; the capitals below are only in these task instructions.

## Before anything runs (the session does this once)
1. Copy out\style-guide.md over console\notes\ui\style-guide.md (first line must stay READY). The critic reads only its first 8000 characters: section 0 carries the survey essentials inside that window.
2. Copy out\ui\*.md over the same names in console\notes\ui\ (motion, hud, end-cards, pause-settings, undercroft, shared-style).
3. Copy out\tasks\20 to 34 into console\tasks\. Copy the 36 chosen pictures (menu-survey\img\q01-b.jpg, q02-c.jpg, q03-c.jpg, q04-b.jpg, q05-c.jpg, q06-b.jpg, q07-b.jpg, q08-b.jpg, q11-d.jpg, q12-b.jpg, q13-c.jpg, q14-c.jpg, q15-c.jpg, q16-a.jpg, q17-b.jpg, q18-a.jpg, q19-a.jpg, q20-a.jpg, q21-d.jpg, q22-c.jpg, q23-d.jpg, q24-b.jpg, q25-b.jpg, q26-a.jpg, q27-d.jpg, q29-c.jpg, q30-c.jpg, q31-d.jpg, q33-b.jpg, q34-a.jpg, q35-a.jpg, q36-a.jpg) to console\notes\ui\survey\ so view_image can open them. q09, q10, q28 and q32 have no jpg: their html is in menu-survey\snip\ and the numbers are in the guide.
4. Order: 20, 21, 22 first; then the rest as in style-guide.md section 8.

## tasks\02-raid-hud-redesign.md  (recommend: keep as a pointer; the work is now tasks 25, 26 and 33)
OLD: Notes: notes\02-raid-hud-redesign.md. His words: Q57 "Ammo needs to be prominent. Ideally redesign the whole raid HUD."
NEW: Notes: notes\02-raid-hud-redesign.md. His words: Q57 "Ammo needs to be prominent. Ideally redesign the whole raid HUD." His picture survey of 10-18 (q16 to q23) now fixes the whole layout with exact pixels: do tasks 25, 26 and 33 instead of redrawing anything here; this task is done when those three are.

OLD: - Q1: the Run info box shows at most the 3 contracts closest to done; ALL contracts are listed on the map screen.
NEW: - Q1: the run goals are one 420x56 pill (x1404 y404) that opens on hold tab to the 3 goals closest to done (his q21 D); ALL contracts are listed on the map screen.

OLD: - Q58: in career the top-right becomes one tidy row. Q59: $ for money, SP for score. Q64: keep the low-ammo box marker.
NEW: - Q58: in career one tidy money row "$900  0 xp" (24px) sits at the top-left, x96 y54, because the top-right is now the minimap column (his q16 A picture). Q59: $ for money, sp for score, shown in lower case. Q64: keep the low-ammo box marker (the plate's bottom row "ammo box 40 m", his q17 B).

OLD: Screens 19-24, 33, 34, 36, 37, 48, 50, 51, 61, 78. Before and after pictures, the critic, 4 or more everywhere (Q6).
NEW: Screens 19-24, 33, 34, 36, 37, 48, 50, 51, 61, 78 (split: tasks 25, 26, 33 own them). Before and after pictures, the critic, 4 or more everywhere (Q6).

## tasks\03-title-and-backdrop.md  (keep; run it BEFORE task 27; its fight is already in: v30.69 cw-title-fight, scripted pillagers against robots behind title, scoreboard and how-to)
OLD: - Q50: keep the normal title screen (no special party version). Q51: drop the story paragraph and the three step cards for one
  line, "Ascend. Pillage. Extract." Q53: no raiders beside the logo. Q72: no PvP row (task 01 hides it).
NEW: - Q50: keep the normal title screen (no special party version). Q51: drop the story paragraph and the three step cards for one
  line, "ascend. pillage. extract." (lower case, under the lime wordmark at the bottom-left, his q12 B). Q53: no raiders beside the logo. Q72: no PvP row (task 01 hides it). The title layout itself (menu column on the right, player switch, three rows) is task 27, from his q11 D and q13 C.

OLD: - Q52 and Q54: behind the title, the scoreboard and the how-to pages, show the live map, dimmed, with REAL pillager-versus-robot
  combat happening in it (no recorded clip). It must not cost frame rate: 60 fps at 4K on the title.
NEW: - Q52 and Q54: behind the title, the scoreboard and the how-to pages, show the live map graded dark teal (his q14 C: map at 30 percent colour, #07131a overlay at 60 percent, lime tracers, white muzzle flashes, a cached vignette, NO blur), with REAL pillager-versus-robot
  combat happening in it (no recorded clip). It must not cost frame rate: 60 fps at 4K on the title, with no per-frame filter and no extra offscreen copy of the world.

## tasks\04-style-guide-update.md  (recommend: RETIRE it; tasks 20 to 24 replace it. If it must stay, change as below)
The guide is already written (out\style-guide.md, steps 1 to 3 of "before anything runs"). The shared look is rebuilt in tasks 20 to 24. Its notes say v30.61 cw-limeacc shipped (lime #e6ff3d, about 30 hover tints on --acc) and cw-bounce passed preflight but is NOT shipped. The survey replaces both: do NOT ship cw-bounce (c1 1.5 = 8 percent bounce, 24px rise, 1.08 pulse) and do NOT build cw-cardwide (S/mk-cw-cardwide.ps1, the 90 percent by 90 percent window). Delete S/mk-cw-bounce.ps1, S/mk-cw-cardwide.ps1 and tools\handoff\drafts\draft-cw-bounce.json from the queue so no run ships them. The lime keeps working meanwhile; task 20 changes its value to #c4f12e (the old checks read __ACC() from --acc, so they follow).
OLD: Edit notes\ui\style-guide.md and the shared UI object in the game, then re-apply to every screen already on the shared look:
NEW: The style guide is already written (notes\ui\style-guide.md, copied from the survey). Do NOT edit it except to correct a mistake you can prove. The shared UI object and the re-apply are tasks 20 to 24; this task only checks that the guide and the game agree:

OLD: - Q46 the accent for "selected" and main buttons becomes lime yellow, the most visible shade on the dark background (check the
  contrast at 1080 and 4K; keep rarity and danger colours distinct from it).
NEW: - Q46 the accent for "selected" and main buttons is lime #c4f12e (his q03 C; contrast 13.7:1 on the panel, 14.5:1 for the ink #0d1200 on it; lime text only on a dark plate). Rarity and danger colours stay distinct from it.

OLD: - Q43 windows (Settings, stash and the rest) become a centred card with an X in the corner that takes up NEARLY THE WHOLE screen.
NEW: - Q43 windows (Settings, stash and the rest) are one frosted-glass card (his q04 B) of 1728x972 at x96 y54 with a 56px circle X in the corner: NEARLY THE WHOLE screen (task 22).

OLD: - Q47 livelier menu motion, with bounce (overshoot about 6 to 10 percent; still never ignore a press). Q48 soft ticks on focus,
  punchy hits on confirm and on score.
NEW: - Q47 livelier menu motion, with a light bounce: overshoot 5.3 percent on cards and presses (ease-out-back c1 1.2, his q28 B), a 4.6 percent spring on the highlight glide (q10 B), a 2 percent pop on window open (q09 B); never over 6 percent; still never ignore a press (task 24). Q48 soft ticks on focus,
  punchy hits on confirm and on score.

## tasks\05-party-launch-mode.md  (no change: it is DONE; runs.log 10-18 15:50, v30.79, file now in console\done)
Nothing to edit in the file. Two things for the later tasks, written into them already: (1) task 27 must keep the ?party=1 behaviour (title hidden, arcade attract at once, checks (a) to (g) of task 05 stay green) when it builds the new title list of his q13 C; with ?party=1 the whole list is hidden; (2) the strings that task 05 left in capitals ("Player 2: press A", "Exit demo", "1 PLAYER") go lower case in task 27 and task 34 (his order), nothing else about task 05 changes. The pause stays the same entries, drawn as the q29 C tiles in task 30.

## tasks\12-ui-party-screens.md  (keep, but shorter: the other screens now have owners)
OLD: Screens: 46, 47, 48, 49, 52, 53, 54, 55, 56, 58, 62, 63, 64. Move each onto the shared look and fix what look-book.md says,
NEW: Screens: 62 and 63 only (the arcade operator menu and its new-party confirm). The rest have owners: 46, 52, 53, 54, 55, 56 and 64 are task 28; 58 is task 27; 49 is task 30; 47 is task 23; 48 is tasks 25 and 26. Shoot those anyway after they ship and fix only what is still under 4. Move 62 and 63 onto the glass shell (a dialog 640 wide, main action lime, "exit demo" separate as the danger ghost, lower case) and fix what look-book.md says,

OLD: Read
notes\ui\style-guide.md, look-book.md and shared-style.md first.
NEW: Read
notes\ui\style-guide.md (rewritten 10-18 evening: lime #c4f12e, glass cards, 24/32/48/96), look-book.md and shared-style.md first. Needs tasks 20 to 22 shipped; run it after 27 and 28.

Its notes (notes\12-ui-party-screens.md) end "STUCK: the critic gives 3 to every small card". The open asks are now decided by the survey: bake the world dimmed and hide the HUD behind a pause or card = q07 B (blur 12px + 55 percent black; fixture 29.88 is retargeted to it, no 95 percent solid scrim any more); focus state on rows = q05 C (6px lime bar + wash); the how-to page (46) gets the glass card with the 56px X and a lime button (task 28).

## console\RULES.md (optional, one line)
OLD: - Consistency beats a one-off: follow tools/handoff/console/notes/ui/style-guide.md once it exists, and fix the guide, not the
  screen, when the guide is wrong.
NEW: - Consistency beats a one-off: follow tools/handoff/console/notes/ui/style-guide.md (rewritten 10-18 evening from his picture survey; his chosen pictures are in notes/ui/survey/) and fix the guide, not the screen, when the guide is wrong. Where the guide and a picture he chose disagree, the picture wins.

## Old checks the new tasks will break (the helpers retarget each through fixq.sh; listed so nobody is surprised)
29.88 and the other solid-scrim checks (scrim .80 to .97 becomes 55 percent over a 12px blur); 29.33 (no raw literals in ui-shared: new fixed strokes 2px, 4px, 6px need tokens or an allow-list entry); the cw-tvtext profile checks (uiScale 1.5, menuZoom 1.25, career 1.3 become 1.0); the UIM motion checks (open 0/50/100/200 becomes 0/60/154/280, stagger, tab slide, ring 33/81/95); 29.83 (tile size 72 becomes 112/100); HUDBOX overlap and text-drawn checks (the whole raid HUD moves); title row checks (the new switch and three rows); settings checks that read #setdetail; any check that names #e6ff3d, #16191b, #efe9dc, #aaa498, #e5482f, #9cc7ff or #7fa6c9.
