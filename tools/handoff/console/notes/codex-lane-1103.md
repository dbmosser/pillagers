# Codex lane, 11-03 (Codex Correspondent, for OVERLORD)

The lane is ready and needs nothing from the owner yet. It can't start Codex before the week resets Wed 11/4 about 01:35. After that it runs o-* jobs when FnP is not busy. There are no o-* jobs yet; HTML GAME has the one line about 262 to 264, and that choice is its call. Delivery to that chat was accepted, but I saw no sign it was read.

## Changed
All three edits were made with .new, bash -n and mv, with codex/STOP set during the edit and removed after. Nothing was deleted.

1. **Editor hold.** New `fnp_hold` in tools/codex-lane.sh, checked at lane start and before every Codex run. On JUL26 it holds when:
   - a FortniteClient process is open (a walk or game);
   - the editor is closed and editor-stay-closed.txt is absent (a reopen is due);
   - the editor started under 10 minutes ago (a reopen is under way);
   - the editor is open with under 14 GB free (our own estimate, same as the Claude helpers);
   - the editor's state can't be read.
   It reads process names and start times only.
2. **Reserve gate.** New `weeknow` drops the last week reading once its week_resets date has passed, so the reserve can't rest for good. I also removed the stale "kept for party night" label. CX_PAUSE_AT stays at 99.
3. **Private copy.** C:\claudecode\pillagers-codex was renamed to C:\claudecode\pillagers-codex-old-1019 and kept. A new worktree record was made with --no-checkout, so its files land on the first job, not during a walk.

Added beyond the three, to meet your JTPC condition:
- The lane refuses to run on JUL26 if GATE_REMOTE is not 1.
- The lane's two Chrome starts in the gate no longer fire on JUL26. A missing spare PC now means the job waits and no run is spent.
- Fixture retargets are refused on JUL26, because they run checks in a local Chrome. Codex is told, its keys wait, and RULES-codex.md step 5 says so. A job that must change older checks can't finish on Codex for now.
- If the sign-in fails, the lane writes the exact step to for-you.md, once.
- The machine.sh comment now says codex-lane.sh calls the editor check too.

Added after reading dark raiders/CLAUDE.md, which I should have read first:
- One helper at a time while the editor is open: `fnp_hold` also holds when a Claude helper is running, and when that count can't be read.
- LF checkout: the private copy now checks out with core.autocrlf=false, matching the main folder. Otherwise this repo's autocrlf=true could have given Codex CRLF files, and anchors tested there could fail in the main folder. One file put through the new checkout matched the main folder byte for byte. It stays in the copy until the first job's refresh.

## Confirmed
- **JTPC route, by reading the code:** GATE_REMOTE=1 in caps.txt. preflight.sh, shipone.sh (called by shipq.sh) and uishots.ps1 all switch to the spare PC on it. The lane's derived preflight-o.sh carries it too.
- **JTPC route, live:** shipq.log at 03:27 shows a Claude lane's ship running on the spare PC through the same shipq.sh. A Codex job has not gone through it yet.
- **Remaining local Chrome starts:** three cdp.ps1 starts are left in the lane, and none can fire on JUL26. Two are behind the new guard, and one is in the retarget checks, which are now refused.
- **Function tests:** weeknow passed on a line before the reset, past it, with no date and empty. The gate and no-Chrome checks passed on this PC.
- **Reset, simulated:** with a past-reset line in a copy of the settings, the lane got through the reserve and stopped at the editor hold. It did not start Codex.
- **Real meter now:** status reads "resting: week use 100.0% reached the reserve line (99%)".
- **--check:** READY. Signed in, sandbox ok, worktree ok, preflight derivation ok.

## Not proven
- **Sign-in:** "Logged in using ChatGPT" only reads the local file, from 10-19. The first real job after the reset is the test.
- **Week use and reset time:** both come from the 10-31 reading, not a live one.
- **A walk that starts mid-run:** the hold is checked before each Codex run, so a run already going finishes. It can last up to RUN_MIN (45 min). Runs in the log are usually a few minutes.
- **Editor hold in a real run:** it has only held at lane start so far, not before a run in the job loop.
- **A Claude helper that starts during a Codex run:** console-lane.sh does not count Codex, so both can run until Codex's next run boundary, when Codex yields. I did not edit console-lane.sh.

## Your call
Codex may get few turns. It only starts when no walk, game or Claude helper is on, and at 03:37 a helper and a game were both running. If o-* jobs sit waiting, the fix is yours because you manage usage: hold Claude lane c while Codex has jobs, which also saves Claude use. I changed nothing there.

## The owner asked about Pro and FnP (11-03)
- **Pro:** I told them not now, and to look again after the 11/7 test if Codex runs out with jobs still waiting. Flat out, the last week lasted about 2.5 days on Plus, so about 3 times Plus would cover a full week. The $100 tier is the most that would ever be needed. The purchase is theirs.
- **FnP:** I found no sign Codex has worked on it. Its direct use would be a second reader for the Verse files, with no editor and no memory cost to speak of, once the week resets. That is FNP CEO's call or yours. I did not wake FNP CEO to offer it.

## Needs someone
- **Commit:** the edits to tools/codex-lane.sh, tools/handoff/machine.sh and tools/handoff/codex/RULES-codex.md are uncommitted, because I was not asked to commit. Ships only stop on uncommitted game or fixture files, so they don't block a ship.
- **Stale reading in my first report:** the "14 GB" there is our estimate, as you said. It was never the owner's rule.

## A slip to record
At 03:24 one of my process queries matched its filter against every process's command line, which would have included the editor's. It printed only the lines that matched nightly, health, checkin and lane scripts, so nothing from the editor came out. Later queries filter by process name first, and fnp_hold never reads command lines.
