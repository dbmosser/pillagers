# RULES FOR THE CONSOLE WORKER (read every run)

You are a headless Claude worker on the owner's Windows PC, improving his game PILLAGERS. No one is watching: never ask
questions and never wait. Your runs are billed to his Claude Console credits, so be thrifty and finish real work.

## The project
- The game is ONE file: C:\claudecode\dark raiders\dark_raiders.html (Canvas 2D, about 4 MB, CRLF). Repo dbmosser/pillagers, branch master.
- NEVER Read the whole game file or the whole fixture (tools/mkfixture.ps1); each is far too big. Grep with line numbers,
  then Read about 150 lines around the hit.
- The deadline: the 2-player DEMO must be solid for his party on 10/30.
- Read C:\Users\User1\.claude\projects\C--Users-User1-Desktop-dark-raiders\memory\pillagers-sunday-start-2026-10-18.md
  first, and any memory file named in your task. The memory folder is READ ONLY for you; never write there.

## Hard rules (his, binding)
- Never touch localhost:8802 (his play port), his keys or passwords, his PC settings, BIOS or drives.
- Never use a browser yourself. Only the project's test scripts drive the test Chromes.
- Never reword a line he edited, and never reverse one of his rulings. His rulings are in the memory folder.
- Never edit dark_raiders.html directly. Every game change ships through a mk script and the ship queue (below).
- Never git push --force, reset, rebase or delete branches. Never commit anything in tools/handoff/console/.
- Keep 6 GB of RAM free: never start more than one extra Chrome, and close what you start.
- In-game text is short, punchy callouts in SENTENCE CASE (his hard rule 2026-10-18: NEVER all caps; "Location revealed",
  "Machine alert"; acronyms like SP, XP, HP, LMG stay). Never an
  explaining sentence on screen. Score is SP, never $.
- Never start agents, workflows, cloud sessions or scheduled tasks.

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
   Every ship also pushes GitHub and itch on its own.
4. The gate also reruns the last ~80 checks and the seed 4242 fingerprint (ents 85/374, containers 165/593). A change that
   moves the fingerprint is wrong unless the task says otherwise.
5. If a STOP says the What's New card stamp is stale, read S\genP.sh, run it with the next unused number (P8 and up) and
   ship that card key first.
6. If the gate's parse checks time out, restart its Chrome: powershell -ExecutionPolicy Bypass -File tools\cdp.ps1 -Start -Port 9346
7. If the lock S\shipq.lock looks stale (its owner in S\shipq.owner is dead for over 30 min), use bash "S/clearstale.sh". Nothing else.
8. Old checks live in tools\mkfixture.ps1. Retarget an old check only through bash "S/fixq.sh" "MESSAGE" after editing it,
   and to run single checks read S\runchk.sh first (it needs the lock: bash "S/lock.sh" then bash "S/unlock.sh").

## Your permissions are an exact list (anything else is refused, so do not try it)
- read_file, grep and list_dir anywhere. write_file and edit_file only: S\mk-cw-*, tools\handoff\console\notes\**, tools\handoff\console\questions.md,
  and Edit on tools\mkfixture.ps1. Put any list or output files you need in tools\handoff\console\notes\.
- run, with the command typed EXACTLY in these forms (forward slashes, no quotes around the script path):
  bash C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/shipq.sh cw-KEY
  ... the same folder with: shipdraft.sh KEY | fixq.sh "MESSAGE" | genP.sh N | runchk.sh LIST OUT | lock.sh | unlock.sh | clearstale.sh
  powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/mk-cw-KEY.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9346
  git status / git log / git diff / git show (read only)
- Run each command on its own: no pipes, no &&, no cd.

## Three workers share the repo (lanes a, b, c), so keep the tree clean
- A ship STOPs when the game file or tools\mkfixture.ps1 has uncommitted edits. So edit tools\mkfixture.ps1 ONLY while you
  hold the lock, and commit before you let it go: bash S/lock.sh, edit, check with runchk.sh, then
  HELD=1 bash S/fixq.sh "MESSAGE" (commits while you hold the lock), then bash S/unlock.sh. Keep each hold short, a few checks at a time.
- If your ship STOPs with "uncommitted changes", another worker is mid-edit: wait with bash S/lock.sh then bash S/unlock.sh
  (lock.sh waits for the lock), and ship again, up to 3 times. Never end a run just because of that STOP.
- Never leave the game file edited. Only the ship scripts change it.
- The lock stops EVERY worker's ships. Hold it at most 8 minutes (after 8 it is taken back automatically): plan and write your fixture edits BEFORE you take it, then take
  it, apply, runchk only the checks you touched, commit and release. Never think, explore or read code while you hold it.
  (10-17: one worker held it from 09:39 to 11:41 and nothing shipped for two hours.)

## UI work: you can SEE the game (10-18)
His words: "The weakest part of the whole game is still UI and presentation and organization of menus" and "You should be
checking for optimization of design aspects and style consistency across menus, not just getting them right but making them
actually look good". So for any change a player can see:
- The camera: powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 -Screens 01,45 -Out tools/handoff/console/notes/shots/TASKID-before -Res 1080 -Port 936N
  (N = 1 for lane a, 2 for b, 3 for c, 4 for d, 5 for e; -Res 1080,4k when size matters; add -NoLint to skip the lint). Screen names and their
  staging are in tools/handoff/shots/ui-screens-js.json (78 screens; add a screen there only by asking in questions.md).
  It shoots the CURRENT build (the fixture), so take "before" pictures first, and "after" pictures once your ship is in.
  report.json also lists lint issues (clipped, off-screen, small, low-contrast text, overlaps).
- Look with view_image. Judge like a picky art director at a AAA studio (ARC Raiders and Fortnite menus are his bar), not a
  tester: alignment, spacing, hierarchy (what the eye hits first), one font family, few text sizes, few colors, consistent
  panels, buttons, headers and close/back placement on EVERY screen. Clutter is a defect. Readable from a couch at 1080p.
- NEVER GRADE YOUR OWN SCREEN (agents praise their own work). After shipping, run the critic on the new picture, with the old
  one first if you have it: node tools/console-sdk/critic.mjs tools/handoff/console/notes/shots/TASKID-before/NAME-1080.jpg tools/handoff/console/notes/shots/TASKID-after/NAME-1080.jpg
  (a path with "before" in it is the old version; 1-4 pictures; about 4 cents). It answers with a score 1-5 and P0/P1/P2
  findings, and records the score in notes/ui/accept.json. Fix every P0 and P1 it names (ship a follow-up) and run it again.
  A screen is done at 4 or more. After two follow-ups that do not raise the score, write what is stuck in your notes and move on.
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
- End your final message with exactly one line: TASK DONE, or TASK PARTIAL: what remains.
