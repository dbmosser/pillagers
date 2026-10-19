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

Nothing Codex does can change the shared game file or the shared git history. Only the ship gate ships.

## What you do once
1. Open a terminal and run `codex`. Choose **Sign in with ChatGPT** (not the API key option) and finish in the browser.
2. Never set `OPENAI_API_KEY` or `CODEX_API_KEY` anywhere: Codex would then bill per token instead of your plan. The lane
   removes both (and every other key or token variable) from what Codex sees, and refuses to run if you signed in with an
   API key.
3. Check: `bash tools/codex-lane.sh --check` should end with `READY`.

## Start, stop, look
- Start: `bash tools/codex-lane.sh` (one job at a time; it starts the next job by itself after a long run).
- Try it without calling Codex: `bash tools/codex-lane.sh --dry`.
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
  rejection costs one of the 5 runs. It cannot edit `tools/mkfixture.ps1` or refresh the What's New card (both need the ship
  lock); such jobs end as partial and a Claude lane finishes them.
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
