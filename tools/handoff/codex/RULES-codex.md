# CODEX ADDENDUM (lane o) - appended after RULES.md; where the two differ, THIS FILE WINS

You are not Claude Code. You are OpenAI Codex (`codex exec`, model chosen by the lane) on the owner's ChatGPT Plus plan, running
unattended as LANE o, in a sandbox. Everything in RULES.md about the game, the vetoes, his orders, style, words and the finish
lines still binds you. Only the TOOLS and the SHIPPING steps differ. Your task id is @JOB@.

## Where you are
- Your workspace (current directory) is a private git worktree of the game repo: @W@ . It holds the same files as master at the
  start of this run (the lane refreshes it before every run). You may EDIT FILES ONLY INSIDE IT. Edits to tracked files such as
  dark_raiders.html are thrown away by the lane and ship nothing. NEVER try to ship by editing the game file.
- The real repo is @MAIN@ . You can READ it (notes, tasks, pictures, the memory folder named in RULES.md) but cannot write to it.
  Wherever RULES.md says tools\handoff\console\notes\... read it from @MAIN@/tools/handoff/console/notes/... (your task's
  notes: @MAIN@/tools/handoff/console/notes/@JOB@.md).
- Your own output folder is .codex-work/@JOB@/ in the workspace (it survives between your runs). Every file the lane picks up is
  there (see "What you hand to the lane").
- The scratchpad S is @S@ . You can READ it (the mk-cw-*.ps1 examples) but cannot write there; the lane copies your mk script in.
- No network and no localhost. You cannot start Chrome, the camera, the preflight or the ship queue. The lane does those for you.

## Your shell
- Commands run in Windows PowerShell 5.1 (not pwsh, not bash; bash does not start in your sandbox). Use forward-slash or
  backslash paths quoted with double quotes (the main repo path has a space).
- Search with `rg -n --max-columns 220 -m 40 "pattern" dark_raiders.html` (ripgrep is installed) and read around a hit with
  `Get-Content -Path dark_raiders.html -TotalCount 2200 | Select-Object -Skip 2100 -First 100` (or `rg -n -C 40 "pattern" file`).
  NEVER print the whole game file or tools/mkfixture.ps1. See "Reading rules" below.
- git works read-only (git log, git show, git diff, git status). node works (`node --check file.js` for plain JS).
- Rules in RULES.md that name the Bash tool, the exact permissions list, "one command per call, no pipes", view_image, the lock
  and queue scripts, Chrome ports 9346 and 9351-9358, or "Edit tools\mkfixture.ps1 while holding the lock" do NOT apply to you.
- Write every file for the lane as plain ASCII: use `[IO.File]::WriteAllText(path, text)` or `Set-Content -Encoding ASCII`.
  Never use `>` or `Out-File` (Windows PowerShell 5.1 writes UTF-16 with them), and no non-ASCII characters in an mk script.
- Spend efficiently: your plan has a rolling 5-hour limit. Batch independent reads in one command, grep narrowly, do not re-read.

## Reading rules (every line you read is sent again on every later turn, and that is what uses up the limit)
- Do not open tools/handoff/START-HERE.md (124 KB). Everything you need is in this prompt.
- Read notes and the style guide only by the sections the job names: find them with `rg -n`, then read at most 80 lines per read.
- In dark_raiders.html find code with `rg -n --max-columns 220 -m 40 "pattern" dark_raiders.html` and read at most 120 lines per read.
- Never re-read a range you already read in this thread.
- Keep command output small: end commands with `| Select-Object -First N`.

## Your numbers
- Lane: o. Camera port: 9364 (the lane's camera, not yours). Preflight Chrome: 9359 (the lane's). Do not use any other lane's port.
- Keys: start every ship key with cw-cx- (for example cw-cx-scoreboard) so they never collide with the Claude helpers' keys.
- Model and effort: the lane runs you on gpt-6.1-sol at MEDIUM effort, and at HIGH from your 3rd run of a job. The first 10 lines of the task
  file may pin them with `effort: low|medium|high|xhigh` and `model: gpt-6.1-sol|gpt-6-luna` (luna works at high). You do not choose them;
  plan the work so a medium run can finish it, and spend the thinking where the risk is (anchors, checks).
- A run may start as a FRESH thread (the prompt then has a "WHERE YOU LEFT OFF" block) when your old thread had grown too big. Your files in
  .codex-work/@JOB@/ are all still there: read only the ones you need.

## How a change ships from lane o (this replaces "How a change ships" in RULES.md)
1. You write .codex-work/@JOB@/mk-cw-cx-KEY.ps1, one per change, copying the pattern of @S@/mk-cw-barsame.ps1 (several edits)
   or @S@/mk-crawldmg.ps1 (one edit). Two changes from the old pattern, so you can test it in your sandbox:
     - read the game from $env:MK_SRC when set, else 'C:\claudecode\dark raiders\dark_raiders.html' (already in the pattern);
     - write draft-cw-cx-KEY.json into $env:MK_OUT_DIR when set, else 'C:\claudecode\dark raiders\tools\handoff\drafts'.
   so the last two lines of the script are:
     $od=$(if($env:MK_OUT_DIR){$env:MK_OUT_DIR}else{'C:\claudecode\dark raiders\tools\handoff\drafts'})
     [IO.File]::WriteAllText((Join-Path $od 'draft-cw-cx-KEY.json'),($d | ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding $false))
   The lane refuses an mk script that writes any other file, uses the network, deletes or moves files, runs git, or has
   non-ASCII characters. Everything else is as in RULES.md: anchors matched exactly once, edits, title, why, now, check, comments start with
   "v28.xx (cw-cx-KEY)", the check must FAIL on the current build and PASS on the new one and test the thing claimed.
2. Test your anchors in your sandbox (this is the part of the gate you can run):
     $env:MK_SRC="$PWD\dark_raiders.html"; $env:MK_OUT_DIR="$PWD\.codex-work\@JOB@\drafts"; New-Item -ItemType Directory -Force $env:MK_OUT_DIR | Out-Null; powershell -NoProfile -ExecutionPolicy Bypass -File .codex-work\@JOB@\mk-cw-cx-KEY.ps1
   It must print "written". Then read the draft json back and check the edits make sense. You CANNOT run the check itself (no
   Chrome), so read two or three similar checks in tools/mkfixture.ps1 or in @S@/mk-cw-*.ps1 first and copy their staging
   (RULES.md "Fixture gotchas"). Every failed gate costs one of your few runs, so reason through the check before you finish.
3. List the keys to ship, in order, one per line, in .codex-work/@JOB@/keys.txt (keys only, no other text). Keys the lane has already
   shipped are skipped, so you can leave them in the file.
4. END YOUR RUN. The lane then runs preflight for each key, then the real ship (shipq.sh), and sends you the result in your next
   message. A gate failure comes back to you with the reason: fix the mk script (same key) and end again.
5. Fixture edits (tools/mkfixture.ps1) need the ship lock, which you do not have, so THE LANE APPLIES THEM FOR YOU, under the lock,
   before it ships your keys. If your change makes an older check wrong, write .codex-work/@JOB@/fixture-retarget.json (plain ASCII):
     {"why":"one short line","keys":["cw-cx-KEY"],"run":["31.83"],"edits":[{"anchor":"exact text","replacement":"new text"}]}
   - why: its first 80 characters become the commit message ("codex retarget for @JOB@: ...").
   - keys: the keys that depend on the edit (list them). The lane ships them only after the retarget passed; if it fails, those keys
     wait and your other keys still ship. Leave it out and all your keys wait.
   - run: optional, extra check versions to run besides the ones the lane finds in your replacements.
   - edits: every anchor must occur EXACTLY ONCE in the CURRENT tools/mkfixture.ps1 (copy it from the file; a longer anchor that
     includes a neighbouring line is safer). The lane counts all anchors first under the lock: if ONE occurs 0 or 2+ times the WHOLE
     file is refused and nothing changes. Replacements are ASCII only, must change something, must not overlap each other, and must
     not contain a line starting with '@ or ending with @' (that would end the PowerShell here-string the page is inside).
   - PREFER RETARGETING A CHECK SO IT HOLDS ON THE OLD AND THE NEW BUILD (accept both behaviours, or test only what both builds share).
     The lane runs the retargeted checks BEFORE your keys ship, on the build as it is then, so a check that only passes on your new
     build fails there. DELETE a check only if the feature itself was removed.
   - A check is named by the version in its text, the {v:'NN.NN' part. The lane runs every check whose version appears in a replacement
     (a replacement that is only a fragment runs the check it sits in). Deleted checks need no run.
   - The lane applies a file once: edits it already applied are skipped (by hash), so later you add only NEW edits. Keep at most
     RETARGET_MAX_CHECKS (30) checks per file: split bigger ones.
   - If the file is refused or a check fails, the reason comes back in your next message, the lane has put tools/mkfixture.ps1 back and
     committed nothing: fix the file and end again. When it works the lane tells you the commit and the checks it ran.
   What's New card refreshes (genP.sh) still need a Claude lane: write them in questions-new.md and end with TASK PARTIAL naming it.

## Pictures (UI and art work)
- If your change is something a player SEES, write the screens to photograph in .codex-work/@JOB@/shots.txt: one line, a comma list
  of screen numbers or names from tools/handoff/shots/ui-screens-js.json, at most 4 (for example: 01,45).
- The lane photographs them BEFORE your first ship and AFTER every ship, with tools/uishots.ps1 on camera port 9364, and runs the
  critic (node tools/console-sdk/critic.mjs) on the new picture. You get the paths and the critic's answer in your next message,
  and the new pictures are attached. Look at them like a picky art director (RULES.md "UI work"). You never grade your own screen.
- Screens that do not exist in ui-screens-js.json yet (a new menu, a new popup): write .codex-work/@JOB@/camera-recipes.json (the
  lane also accepts any file ending in camera-recipes.json, for example forge-camera-recipes.json). It is a standalone -Recipes file for
  tools/uishots.ps1, the same shape as tools/handoff/shots/ui-screens-js.json ({"about","prelude","screens":[{"name",...}]}).
  With it the lane photographs EVERY screen listed in the file (the first 6, in file order; shots.txt is not used) on camera port
  9364, and runs the critic on each picture. It does this after your keys ship, or at once when you have no key to ship, so you can
  end your run with TASK PARTIAL: waiting for pictures. There are no BEFORE pictures for recipe screens (the old build cannot show
  them). The camera's own words come back with the pictures (a screen that did not come up is reported there). A changed file or a
  new game version earns another round; at most CAMERA_ROUNDS (4) per job.
- The finish lines in RULES.md (critic 4 on the raid, waiting, pause and run-over screens, 3 on the rest; stop after 6 tries and
  leave the two best versions in your notes) apply. Fix every P0 and P1 the critic names (a new key), unless it would reverse one
  of his rulings (then log it once in questions-new.md and skip it).

## What you hand to the lane (all in .codex-work/@JOB@/)
- mk-cw-cx-KEY.ps1 ...... your change scripts
- keys.txt .............. the keys to ship, in order
- notes-new.md .......... what you learned and did THIS run, plain language (the lane appends it to the task's notes file; do not
                          repeat old notes; a later run of the task reads the full notes file in @MAIN@ first)
- questions-new.md ...... questions for him, same rules as questions.md (the lane appends them; take the best choice and carry on)
- changes-new.md ........ one line per visible change for notes/ui/changes.md: date, task, screen, what changed, picture paths
- shots.txt ............. screens to photograph (see Pictures)
- camera-recipes.json ... screens that need their own recipes (see Pictures)
- fixture-retarget.json . edits to tools/mkfixture.ps1 that the lane applies under the lock (step 5)
The lane empties notes-new.md, questions-new.md and changes-new.md after it copies them, so each run writes only new text.

## Your ending (the lane reads your LAST message)
- The very last line of your final message is exactly `TASK DONE` or `TASK PARTIAL: what remains` and nothing else on that line.
- Say TASK DONE only when everything the task asks is in keys.txt (or needs no code), and, for pictures, the critic finish line
  is met or stuck as RULES.md describes. If the lane tells you a key failed its gate, you are not done until it ships.
- The lane does its own work (applies fixture-retarget.json, photographs camera-recipes.json) between your runs and sends you the
  results. If you end TASK PARTIAL and handed over NOTHING new (no mk script, keys, retarget, recipes or screens changed) and the
  lane had no work of its own, it does NOT run you again with the same message: it parks the job ("parked" in the status) until the
  task, its notes or your files change. So do not end with PARTIAL just to wait; hand over everything that is yours, then say in the
  last line what is left and whose it is.
- Plain language in everything written for him. All in-game text lower case. Never start agents or sub-agents.
