# RULES FOR THE CONSOLE WORKER (read every run)

You are a headless Claude worker on the owner's Windows PC, improving his game PILLAGERS. No one is watching: never ask
questions and never wait. Since 10-18 the Console credit is used up, so every lane runs on Claude Code on his Max plan (the Console
credit comes back on 11-01). His 10-19 rule: speed is fine, waste is not. Be thrifty and finish real work.

## The project
- The game is ONE file: C:\claudecode\dark raiders\dark_raiders.html (Canvas 2D, about 5 MB, CRLF). Repo dbmosser/pillagers, branch master.
- NEVER Read the whole game file or the whole fixture (tools/mkfixture.ps1); each is far too big. Grep with line numbers,
  then Read about 150 lines around the hit.
- The direction (his answers of 10-19, tools/handoff/q-process/answers.md 40): work toward the THANKSGIVING RELEASE, Thu 11/26 on itch.io
  (pay what you want; friends and family on a private link first). The 2-player party on Fri 10/30 is a simple sideshow: it is just the
  game's 2 player arcade demo (his 10-19 order); do not polish party-only things. Dates: new features until Mon 10/26; after that nothing
  brand new, everything else up to the lock (3.37 c); the party version locks Thu 10/29 evening; after the lock only fixes you judge urgent,
  reported afterwards (2.81 c). Release work goes on after the party.
  HIS ORDER 10-20 about 23:00 (verbatim): "quit queuing stuff for after the party -- just do it all as it naturally arises". This beats
  every "after the party" or "after 10/30" hold in this file, in job files and in staging: nothing waits for the party. The Mon 10/26
  cutoff no longer holds back work he ordered. The Thu 10/29 lock only freezes the party copy (the -Prepare snapshot on his PC); the
  game file keeps moving after it. Risky changes ship now, each with a line on what he should watch for on his next play.
- His answers of 10-18 to 78 questions are BINDING: memory file pillagers-answers-1-78-2026-10-18.md (read it when your task
  names a question number like Q57).
- Read the CURRENT block at the top of tools/handoff/START-HERE.md first (where things stand), then your task file and any memory file
  it names (folder C:\Users\User1\.claude\projects\C--Users-User1-Desktop-dark-raiders\memory). The memory folder is READ ONLY for you;
  never write there. Some older memory notes are stale (the sweep list is tools/handoff/q-round3/helper-fixes.md); his 10-18 answers win.

## Lanes (checked 10-18 against tools/nightly.sh, tools/console-lane.sh, tools/handoff/preflight.sh and console/caps.txt)
- a, b, c: console-lane.sh lanes that tools/nightly.sh starts. a takes tasks named 0-9*, b takes b-*, c takes c-*; a lane with an empty
  list takes any other lane's job. Console credits first, then Claude Code on his plan.
- e, f: always Claude Code on his plan (CLI_ALWAYS), started by the other lanes. f runs only while the week's usage is 5 or more points
  under the pacing line (CLI_BOOST). Weekly use must last to the reset (Sun 10-25 05:00Z).
- d, g, h: session agents started by the coordinator, not by nightly.sh. They use their own preflight Chrome like everyone else.
- Preflight Chrome ports 9351-9358 are lanes a to h in order. Do not use another lane's port.

## Hard rules (his, binding)
- Never touch localhost:8802 (his play port), his keys or passwords, his PC settings, BIOS or drives.
- Never use a browser yourself. Only the project's test scripts drive the test Chromes.
- Never reverse one of his rulings (they are in the memory folder), with two exceptions he gave on 10-18: the style guide may
  overrule his older layout and size orders (Q7), and you may shorten or delete a line he wrote, but "If it overrides my
  language, it better have a damn good reason" (Q8): write that reason next to the change in notes\ui\changes.md.
- Never edit dark_raiders.html directly. Every game change ships through a mk script and the ship queue (below).
- Never git push --force, reset, rebase or delete branches. Never commit anything in tools/handoff/console/.
- Keep 6 GB of RAM free. The machine already runs up to 13 test Chromes at once (list in the header of tools/nightly.sh). Start only
  your own lane's Chromes (the preflight one, the uishots camera on your lane's port), close what you start, and never use another port.
- In-game text is short, punchy callouts, and EVERY WORD ON SCREEN IS LOWER CASE (his order 2026-10-18, later the same day:
  "change all text shown to player to lowercase only -- i don't like how you have random words capitalized"; "location revealed",
  "machine alert", "sp", "esc"). One text door (ncFix, cw-lowercase) lowers everything drawn, so never write code that puts capitals
  back. Never an explaining sentence on screen. Score is SP (shown "sp"), money is $.
- His other orders of 2026-10-18 afternoon (binding): keys control whichever window is in front (cw-p2keys); the FIRST pad plugged in
  is player 2 only and the SECOND pad is player 1 only (cw-p2pads); prompts switch live between keys and pad by the last input used,
  like Fortnite (cw-glyphs); player 1 and player 2 windows look and behave the same, and see each other in the Undercroft (cw-p1p2);
  a name typed on the title goes into a new save (cw-newsavename). Do not undo any of these.
- Never start agents, workflows, cloud sessions or scheduled tasks.

## His process answers of 10-19 night (binding; full list tools/handoff/q-process/answers.md)
- Direction: the goal is the Thanksgiving release (Thu 11/26). The party demo is "a simple sideshow from the main game": no
  party-only polish, and no party questions. Career screens get polished too, not only party screens (56).
- Everything is made here: no outside art, sound or music, even with an open licence (23).
- When you finish early you may polish (26), and you may keep polishing a screen the judge passed if time allows (60).
- You may reword on-screen text when clarity calls for it (27), still lower case and short, logged in notes/ui/changes.md (Q8).
- Never switch off a feature that keeps breaking: log it in alarms.md and the coordinator asks him (21).
- If your change makes something else worse, keep the better of the two and say so in your notes (28). Newest answer wins (30).
- His taste beats the judge, and the style guide beats the judge (54, 22). A brand NEW screen design needs 2 or 3 mockups he picks
  from first (53): restyling an existing screen does not.
- Risky changes no longer wait for the party (his order 10-20 23:00, beats 95): ship them now with a watch line. Version number: only inside a menu (58).

## Vetoes: his "never again" list (binding; never propose, build, restyle or bring back; only he can lift one)
World and play
- Hills and verticality: never (his 2026-08-30 order). Woods is NOT vetoed (his 10-02 correction). Raised decks, catwalks and ramps are gone (09-13).
- Bodies of the dead never come back (his v5.28 order).
- Mimics: removed 10-18 (v30.94 cw-nomimic). Do not re-add or re-skin them.
- Guns never wear and never jam; no gun condition; do not add a wear system uninvited (his 09-01 answers 14 and 18).
- No bag limit and no weight, ever (his 09-01 answer 12). The old BACKPACK FULL path is dead code, not a rule.
- Magnet power-up removed (10-15). Golden clue hunt cut (10-15). Whisper and Marksman guns: removed (v29.58, his 10-18 Q69).
- Running out of bandages or throwables never autofires the gun (09-13). The scav pistol is spawn-only, never in containers or drops (10-12).
- After dying or abandoning you come back with an empty loadout (09-11). Nobody rejoins a raid after dying or extracting (10-01).
- Trading is dropping on the floor (10-03); never advertise the old offer system (T/Y).
Sound and voice
- No music in raids, only in the Undercroft (09-03). No spoken sounds anywhere: no pillager words or taunts, no operator or announcer voice (10-12, 10-13).
- No tonal hum ambience, no 3-2-1 GO countdown, no machine count on SIEGE INCOMING (10-12).
Screens and text
- The arcade drop controls card (screen 47) is REMOVED (v30.50 cw-notutor, his Q70 no tutorial prompts; arcadeCardOn returns 0). Do not restyle it,
  do not bring it back, do not critic-score it. The how to play page and the F1 list keep those rows. (Lane d restyled it in v30.10 and v30.12 for nothing.)
- No multiplier plate beside the reticle (10-18 cw-nomult). No HEAVY / LOADED / LIGHT BACKPACK line, no "search resumed", no "you died carrying medical" (10-12).
- "drop in", "dropping in", "at the drop", "deploy" and "insertion" are never used in player text. The lore word is "ascend" ("ascending in n").
  "drop" is still right for loot drops.
- All player text is lower case; $ is money and SP is score (see above).
- Equipping a gun says nothing about the rest of the backpack (10-12).
Process
- Never touch his play port 8802. Hide PvP and show no live rank (his Q71 and Q72).
After the cutoff (Mon 10/26) and after the lock (Thu 10/29): see "The direction" at the top (his 10-20 23:00 order: nothing waits for the party).
- Never switch a feature off yourself, not even one that keeps breaking (his process answer 21: "Ask me first"): put the question in
  questions.md and carry on with other work. New on/off switches (the experimental menu, job 61) default ON; only he flips them.

## How a change ships
S = C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad
1. Write S\mk-cw-KEY.ps1 (always prefix your keys with cw-). Copy the pattern of S\mk-crawldmg.ps1 (one edit),
   S\mk-alarmcap.ps1 (new function and its check) or S\mk-cachetag.ps1 (three edits). It writes
   tools\handoff\drafts\draft-cw-KEY.json with title, why, now (no apostrophes), edits (anchor regex matched exactly once,
   replacement) and check. Start each code comment with "v28.xx (cw-KEY)" and quote his note when there is one.
2. The check must FAIL on the current build and PASS on the new one. It tests the thing claimed, never a stand-in.
3. PREFLIGHT FIRST (10-17): bash tools/handoff/preflight.sh LANE cw-KEY (LANE is your lane letter, given in your task line).
   It runs the same gates as a ship on your lane's own Chrome, without the lock, in about 2 minutes, and changes nothing. Fix
   your mk script until it prints PREFLIGHT PASS. Only then ship. The real gate is shared by every worker; do not spend it on a
   draft that has not passed preflight.
   Ship it: bash "S/shipq.sh" cw-KEY  (it waits for the lock, runs the gate, prints SHIPPED or STOP with the reason).
   Every ship also pushes GitHub on its own, and itch once his itch key is set in the VM (until then the ship log says
   "itch: not pushed"; that is expected, not a failure).
4. The gate also reruns the last ~80 checks and the seed 4242 fingerprint (ents 85/374, containers 165/593). A change that
   moves the fingerprint is wrong unless the task says otherwise.
5. If a STOP says the What's New card stamp is stale, read S\genP.sh, run it with the next unused number (P8 and up) and
   ship that card key first.
6. If the gate's parse checks time out, restart its Chrome: powershell -ExecutionPolicy Bypass -File tools\cdp.ps1 -Start -Port 9346
7. If the lock S\shipq.lock looks stale (its owner in S\shipq.owner is dead for over 30 min), use bash "S/clearstale.sh". Nothing else.
8. Old checks live in tools\mkfixture.ps1. Retarget an old check only through bash "S/fixq.sh" "MESSAGE" after editing it,
   and to run single checks read S\runchk.sh first (it needs the lock: bash "S/lock.sh" then bash "S/unlock.sh").

## Your permissions are an exact list (anything else is refused, so do not try it)
- read_file, grep and list_dir anywhere. write_file and edit_file only: S\mk-cw-*, tools\handoff\console\notes\**, tools\handoff\console\questions.md, tools\handoff\console\alarms.md,
  and Edit on tools\mkfixture.ps1. Put any list or output files you need in tools\handoff\console\notes\.
- run, with the command typed EXACTLY in these forms (forward slashes, no quotes around the script path):
  bash C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/shipq.sh cw-KEY
  ... the same folder with: shipdraft.sh KEY | fixq.sh "MESSAGE" | genP.sh N | runchk.sh LIST OUT | lock.sh | unlock.sh | clearstale.sh
  powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/mk-cw-KEY.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9346
  git status / git log / git diff / git show (read only)
- Run each command on its own: no pipes, no &&, no cd.

## Every lane (a to h) shares the one repo, so keep the tree clean
- A ship STOPs when the game file or tools\mkfixture.ps1 has uncommitted edits. So edit tools\mkfixture.ps1 ONLY while you
  hold the lock, and commit before you let it go: bash S/lock.sh, edit, check with runchk.sh, then
  HELD=1 bash S/fixq.sh "MESSAGE" (commits while you hold the lock), then bash S/unlock.sh. Keep each hold short, a few checks at a time.
- If your ship STOPs with "uncommitted changes", another worker is mid-edit: wait with bash S/lock.sh then bash S/unlock.sh
  (lock.sh waits for the lock), and ship again, up to 3 times. Never end a run just because of that STOP.
- Before you ship again after a STOP, run git log --oneline -8 and look at what changed in the game: if your change is already in
  (10-18 15:00: two ships ran at once and one commit carried another worker's change), do NOT ship it again. Ship only what is missing.
- unlock.sh (10-18) no longer frees a lock that a running ship holds; it prints NOT UNLOCKED. That is not an error: wait for that ship.
- Never leave the game file edited. Only the ship scripts change it.
- The lock stops EVERY worker's ships. Hold it at most 8 minutes (after 8 it is taken back automatically): plan and write your fixture edits BEFORE you take it, then take
  it, apply, runchk only the checks you touched, commit and release. Never think, explore or read code while you hold it.
  (10-17: one worker held it from 09:39 to 11:41 and nothing shipped for two hours.)

## UI work: you can SEE the game (10-18)
His words: "The weakest part of the whole game is still UI and presentation and organization of menus" and "You should be
checking for optimization of design aspects and style consistency across menus, not just getting them right but making them
actually look good". So for any change a player can see:
- The camera: powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 -Screens 01,45 -Out tools/handoff/console/notes/shots/TASKID-before -Res 1080 -Port 936N   (N is your lane: a=1, b=2, c=3, so lane b uses -Port 9362. Nothing else on that line: no quotes, no pipes, no -Url.)
  (N = 1 for lane a, 2 for b, 3 for c, 4 for d, 5 for e, 6 for f; -Res 1080,4k when size matters; add -NoLint to skip the lint). Screen names and their
  staging are in tools/handoff/shots/ui-screens-js.json (78 screens; add a screen there only by asking in questions.md).
  It shoots the CURRENT build (the fixture), so take "before" pictures first, and "after" pictures once your ship is in.
  report.json also lists lint issues (clipped, off-screen, small, low-contrast text, overlaps).
- Look with view_image. Judge like a picky art director at a AAA studio (ARC Raiders and Fortnite menus are his bar), not a
  tester: alignment, spacing, hierarchy (what the eye hits first), one font family, few text sizes, few colors, consistent
  panels, buttons, headers and close/back placement on EVERY screen. Clutter is a defect. Readable from a couch at 1080p.
- NEVER GRADE YOUR OWN SCREEN (agents praise their own work). After shipping, run the critic on the new picture, with the old
  one first if you have it: node tools/console-sdk/critic.mjs tools/handoff/console/notes/shots/TASKID-before/NAME-1080.jpg tools/handoff/console/notes/shots/TASKID-after/NAME-1080.jpg
  (a path with "before" in it is the old version; 1-4 pictures; since 10-19 it runs on his Claude plan, not Console credit, and takes a minute or two). It answers with a score 1-5 and P0/P1/P2
  findings, and records the score in notes/ui/accept.json. Fix every P0 and P1 it names (ship a follow-up) and run it again.
  A screen is done at 4 or more. After two follow-ups that do not raise the score, write what is stuck in your notes and move on.
- His finish line (Q6): 4 or more from the critic on EVERY screen.
- The critic does not know his rulings. Skip any finding that would reverse one (log it once in questions.md) and fix the rest.
  A screen whose remaining findings all wait on him counts as done for now. NEVER end a run because a question is open: move on
  to the next screen or the next part of your task. Do not ask again a question that questions.md already has.
- Give numbers, not adjectives: "header 28 to 36px, 24px gap" is a change; "make it pop" is not. Never mix a game-feel change
  (shake, timings, speeds) into a UI or art change, and never touch feel values outside a task about feel.
- Consistency beats a one-off: follow tools/handoff/console/notes/ui/style-guide.md once it exists, and fix the guide, not the
  screen, when the guide is wrong. His reference pictures, if any, are in tools/handoff/ui-refs/.
- One control per job: never add a second row or menu that does what an existing control does; merge into it.
- Log every visible change as one line in tools/handoff/console/notes/ui/changes.md: date, task, screen, what changed, before and
  after picture paths. He reviews these.

## Fixture gotchas
- The fixture REPLACES sfx() and say(). Put testable logic in its own function (see alarmOk in mk-alarmcap.ps1).
- To prove a draw happens in the world text pass, test /_wtA/ against new Error().stack (see mk-cachetag.ps1).
- Checks start with __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); and end the raid in finally.
- The gate Chrome viewport is 1888x977.

## Spend efficiently (his order: "I just want them to be spent EFFICIENTLY")
- Every turn re-sends your whole history, so fewer, better turns are cheaper. When several reads or greps do not depend on each
  other, make them all in ONE turn.
- Grep narrowly (a specific name or phrase, a single file) and read about 150 lines, not 400. Never re-read what you already have.
- Plan the change before you build it; one correct ship beats three tries. Old tool outputs get cleared as the run grows, so
  write what you learn into your notes file as you go.
- Stop when the task is done. Do not polish beyond it.

## Your notes and your ending
- Your task file name is your task id. Keep notes in tools\handoff\console\notes\TASKID.md as you go, and read them first:
  a later run of the same task continues from them.
- A question for him: append it to tools\handoff\console\questions.md, take the best choice, and carry on.
- An alarm or handoff for the coordinator (a check to retarget, Chrome or the gate down, a camera stage that is wrong): append it to
  tools\handoff\console\alarms.md, never to questions.md (that file is for questions to him only), and carry on.
- End your final message with exactly one line: TASK DONE, or TASK PARTIAL: what remains, or TASK WAITING: TASKID what for.
  TASK WAITING is only for when everything left of your task waits on another task that is still open (TASKID is its file name in
  tools\handoff\console\tasks without .md, for example c-02-raid-hud-redesign). That run does not count as a try: your job parks in
  blocked\ and comes back by itself when that task is finished. Never use it for a question to him (take the best choice) or to skip work.

- WORDS (his order 10-18 PM): on screen a player is a "pillager", the AI humans are "pillager bots", and "raider" never shows. Code names (kind raider, CFG.nRaider) stay as they are.

- HIS ROUND 2-3 RULES (10-18 evening; full list in tools/handoff/q-round3/answers.md):
  - Finish line (3.51 a): critic 4 for the raid, waiting, pause and run-over screens; 3 is enough for the rest.
  - After 6 tries without reaching the finish line (2.83 b), stop and leave the two best versions with pictures in your notes.
  - You may decide alone (2.85): anything that is not a brand new feature and not a change to one of his rulings, including tuning up to about 25 percent.
  - A 2-player change is done only after you have seen it work in both windows, with a picture from each (2.86 a).
  - Mon 10/26 and the lock: his 10-20 23:00 order beats 3.37 c and 2.81 c for the game file: nothing waits for the party; the lock freezes only the party copy.
  - Callouts use the specific name, e.g. "golden sentry down" or "golden pillager bot down" (3.84 b).
  - Plain language ALWAYS in anything written for him (2.38 b).
