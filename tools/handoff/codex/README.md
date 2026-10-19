# The Codex helper lane (lane o)

## What it does
A helper that runs OpenAI Codex (`codex exec`, on your ChatGPT Plus plan) on the same job list as the Claude helpers
(`tools/handoff/console/tasks/*.md`) and through the same ship gate. It takes `o-*.md` jobs first, otherwise any job no other
lane is running. For each job it loops:

1. Codex works in its own private copy of the game (`C:\claudecode\pillagers-codex`, reset to master before every run) in a
   sandbox: it can read the whole PC but write only inside that copy, and it has no internet. It writes its change as a
   draft script (`mk-cw-cx-NAME.ps1`) plus notes.
2. The lane (not Codex) copies the draft into the ship folder, runs the preflight and then the real ship (`shipq.sh`), takes
   before and after pictures (camera port 9364) and runs the critic.
3. Whatever the gate or the critic says goes back to Codex in the next message. Up to 5 Codex runs per job (the same
   MAXRUNS as the other lanes). `TASK DONE` moves the job to `done/`, five runs without it move it to `failed/`.
4. Work only the lane can do is done by the lane between the runs, not by re-running Codex (see "What the lane does for Codex").

Nothing Codex does can change the shared game file or the shared git history. Only the ship gate ships.

## What you do once
1. Open a terminal and run `codex`. Choose **Sign in with ChatGPT** (not the API key option) and finish in the browser.
2. Never set `OPENAI_API_KEY` or `CODEX_API_KEY` anywhere: Codex would then bill per token instead of your plan. The lane
   removes both (and every other key or token variable) from what Codex sees, and refuses to run if you signed in with an
   API key.
3. Check: `bash tools/codex-lane.sh --check` should end with `READY`.

## What the lane does for Codex (2026-10-19)
- **Fixture edits.** Codex writes `fixture-retarget.json` (`{"why","keys","run","edits":[{"anchor","replacement"}]}`, contract in
  `RULES-codex.md` step 5). Under the ship lock (key `held-codex-retarget`, held for minutes) the lane checks that every anchor occurs
  exactly once in `tools/mkfixture.ps1` (else the whole file is refused), applies all edits, rebuilds `tools/fixture.html`, syntax-checks
  the page script, runs the retargeted checks with `runchk.sh` and then commits with `HELD=1 fixq.sh "codex retarget for JOB: ..."`.
  A failure puts the file back (`git checkout`), frees the lock and sends the reason to Codex; the keys that depend on it wait,
  the others ship. Applied files and edits are remembered by hash (`work/JOB/retarget-applied.txt`). The helper is `retarget.mjs`.
  Try it without changing anything: `bash tools/codex-lane.sh --retarget-dry JOB` (anchor counts, the checks it would run).
  `--retarget JOB` does the same for real, without Codex.
- **Camera recipes.** `camera-recipes.json` (or `*camera-recipes.json`) in the job folder is a standalone `-Recipes` file for
  `tools/uishots.ps1`: the lane photographs every screen in it (first 6) on camera port 9364, runs the critic on each, and sends
  the pictures and the camera's own output back. At most `CAMERA_ROUNDS` (4) rounds per job.
- **No wasted tries.** A `TASK PARTIAL` with nothing new from Codex (no mk script, keys, retarget, recipes) and no lane work left is
  not re-run with the same message: the job is PARKED (`work/JOB/parked.txt`, status `parked`) and skipped until the task file, its
  notes or Codex's files change (or `PARK_MIN`, default 360 minutes, passes). A first run that delivered nothing still gets its
  second run, and a run that was cut off by the time limit is never parked.
- **Less context.** The bill follows the context sent again on every turn (input is 93-96% cached). When the last turn of the previous
  run reported more than `CX_FRESH_AT` (3000000) input tokens, the next run is a FRESH thread (prompt + "where you left off": Codex's
  last message, its files, keys.txt, filed notes) instead of a resume. `lane.log`: `fresh start: thread at N tokens`.
  `RULES-codex.md` has short reading rules (no START-HERE.md, small reads, no re-reads).
- **Model and effort.** gpt-6.1-sol at `CX_EFFORT_DEFAULT` (medium), high from run `CX_EFFORT_STEP_RUN` (3) of a job; gpt-6-luna at high.
  A task file may pin them in its first 10 lines: `effort: minimal|low|medium|high|xhigh|max|ultra` (only what the model lists in
  `~/.codex/models_cache.json`) and `model: gpt-6.1-sol|gpt-6-luna`. Shown in the status line, `--dry`, `lane.log` and `runs.txt`.
- **Pace to the plan.** Before every run the lane reads the newest `~/.codex/sessions/**/rollout-*.jsonl` and its last `rate_limits`
  (primary = 5 hours, secondary = week). At primary >= `CX_PAUSE_AT` (92) or secondary >= `CX_PAUSE_SEC_AT` (97) it writes
  `waiting for the ChatGPT limit: resets HH:MM` to `status-o.txt`, rests until the reset plus 2 minutes (the same rest file as a
  usage limit: the lane exits and the next start waits, the job is kept) and counts no run. A window whose reset time has passed counts
  as 0. `runs.txt` gets `model= effort= cached=NN% reasoning=N limits=P/S` per run. Codex runs with `forced_login_method="chatgpt"`.

## Start, stop, look
- Start: `bash tools/codex-lane.sh` (one job at a time; it starts the next job by itself after a long run).
- Try it without calling Codex: `bash tools/codex-lane.sh --dry` (shows the job, model, effort, the ChatGPT limit now, the prompt size).
- Pause this lane: create an empty file `tools/handoff/codex/STOP` (delete it to go on). `tools/handoff/console/STOP`
  pauses every lane.
- What it is doing: `tools/handoff/console/status-o.txt` (one line). Every run: `tools/handoff/codex/runs.txt`. Full
  transcripts: `tools/handoff/codex/log/` (not committed). Codex's notes are appended to `console/notes/JOBNAME.md`.
- When your Plus limit is reached the status says `resting: codex usage limit, back about HH:MM` and the lane comes back
  by itself (it only needs to be started again, for example by the runner). A run that hits the limit does not count.

## Known risks
- Nobody has run it against real Codex yet (not signed in when it was built). Everything around Codex was tested with a stand-in.
  The first real run needs watching: the model name (`gpt-6.1-sol` in `caps-codex.txt`), the exact flags, the usage-limit
  wording and whether `exec resume` keeps the sandbox settings.
- Codex cannot run the checks (no Chrome in its sandbox), so its checks are written blind and the gate rejects some. Each
  rejection costs one of the 5 runs. It cannot refresh the What's New card (needs the ship lock; such jobs end as partial and a
  Claude lane finishes them). Its `tools/mkfixture.ps1` edits go through the lane (`fixture-retarget.json`); the lane tests the
  retargeted checks only on the CURRENT build, before the dependent keys ship (see below).
- Retarget limits: the checks run before the new build exists, so an edited check must hold on the OLD and the NEW build (the rule in
  `RULES-codex.md`); the gate's own recent-checks window (about 80 newest) may not cover an old retargeted check on the new build. The
  rebuild swaps the shared `tools/fixture.html` (served on :8806) while the lock is held, and again when a retarget is put back.
  A check version that appears several times in one anchor is tested once (`find` takes the first). The lane never edits
  a `tools/mkfixture.ps1` that already has someone else's uncommitted change: it waits (status `waiting`) and tries later.
- The pace check reads the newest session file under `~/.codex/sessions`; if that file is the user's own interactive session the
  numbers are the same account-wide limits. If nothing can be read the lane just goes on.
- The sandbox lets Codex READ everything on the PC (including `~/.codex/auth.json`); it cannot write outside its copy or reach the
  network. The lane only copies back its notes, questions and the mk scripts (after a lint).
- The ship gate, preflight Chrome (port 9359), camera (9364) and critic are shared with the other lanes; a Codex lane adds load.
  The lane waits when under 6 GB of RAM is free.
- The Windows Store `pwsh` breaks Codex's sandbox (openai/codex issue 35871), so the lane takes WindowsApps out of Codex's PATH.
- The worktree is about 1.2 GB. `git worktree remove --force C:/claudecode/pillagers-codex` deletes it (the lane recreates it
  with `bash tools/codex-lane.sh --setup`).
- A ship commits everything with `git add -A`, so these files travel with the next ship commit.

## For the coordinator
- Not in `tools/nightly.sh` yet. Add `bash tools/codex-lane.sh` there (or start it by hand) after the sign-in and `--check`.
- `tools/devdash/server.mjs` lists lanes a to e only; add `o` to show `status-o.txt`.
- Ports: preflight Chrome 9359, camera 9364. RULES.md "Lanes" does not name lane o; the addendum
  `tools/handoff/codex/RULES-codex.md` is appended after RULES.md in every Codex prompt.
