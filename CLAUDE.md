# CLAUDE.md - PILLAGERS

## What this project is
**Scope boundary: this project is the 2.5D 3/4 top-down version, and only that.** The owner runs three separate Claude projects for this game: this one keeps the 3/4 top-down view, and two others are complete, independent rewrites as a first-person shooter and a third-person shooter. Those are separate instances of the game with no shared assets or code. Do not convert the renderer here, do not add WebGL or a raycaster, and do not port work in from the other two. If you find first-person, third-person, raycaster or 3D code in this working tree, it arrived by mistake from another project: park it on a branch, restore the canonical file, and tell the owner rather than building on it.

PILLAGERS (it was called Dark Raiders early on; the file and folder names still say dark_raiders): a single-file HTML5 extraction shooter. The entire game is `dark_raiders.html` (a 3/4 top-down 2D canvas renderer over a flat top-down simulation, about 5 MB). Current version: read `var VER` near the top of `dark_raiders.html` (and `git log -1`); do not restate it here, it goes stale.

**Where to start:** read the CURRENT block at the top of `tools/handoff/START-HERE.md`. Helper lanes also follow `tools/handoff/console/RULES.md` (it holds the veto list: things he has banned for good). `tools/handoff/RULEBOOK.md` has older standing rules; where it disagrees with his 10-18 answers, the answers win.

**Do not read the big files whole.** `DESIGN.md` is about 5 MB (changelog sections start with `## vNN.NN`), `dark_raiders.html` is about 5 MB and `tools/mkfixture.ps1` is huge. Grep with line numbers, then read about 150 lines around the hit.

**Dates (his rulings of 10-18):** the 2-player party demo is Fri 10/30. New features until Mon 10/26, then fixes only. The party build locks Thu 10/29 evening. There is NO public launch on 10/31; party feedback comes first and the launch date is not set. What helpers may do after the cutoff and after the lock is waiting on his answers.

## Who you are working with
The owner is the designer and playtester, not a coder. Never ask him to edit code, run commands, or debug. Ship finished builds. He plays on his own server at http://localhost:8802/ (the play port; the latest stable build is at http://localhost:8802/stable.html): never test on it, restart it or change its server. His in-game notes and flight-recorder exports arrive in `exports/`. His answers are binding and live in the project memory folder (start with `pillagers-answers-1-78-2026-10-18.md` and `pillagers-afternoon-orders-2026-10-18.md`). A question never holds up work: take the best choice and log the question.

## Workflow rules
1. **Orders and data before changes.** Tuning comes from his notes, flight-recorder exports or the test and robot logs, one batch per feedback cycle, each with a one-line reason. New features come only from his orders and answers (until the Mon 10/26 cutoff); do not invent features. Respect the veto list in `tools/handoff/console/RULES.md`.
2. **One canonical file.** `dark_raiders.html` is overwritten in place. Never create copies like `dark_raiders_v2.html`. Git history is the version trail. `builds/` and `stable.html` are written by the ship pipeline and `tools/stable.sh`; do not edit them.
3. **Changes ship through the ship queue, not by hand.** Write an mk script, run `bash tools/handoff/preflight.sh LANE cw-KEY`, then `shipq.sh cw-KEY` (steps and exact commands: `tools/handoff/console/RULES.md`, "How a change ships"). A ship bumps `var VER` and the DEVNOW line, adds a `DESIGN.md` section and an `AUDIT.md` row, commits as `vNN.NN: one-line summary` and pushes GitHub master (itch too when set up). Do not bump versions by hand. A ship STOPs when the game file or `tools/mkfixture.ps1` has uncommitted edits, so helpers never edit the game file directly. The What's New card stamp (`WHATSNEW_VER`) is a separate stamp, refreshed by a card ship when the gate says it is stale.
4. **Verify before done.** The gate runs a parse check, the new check twice on the drafted build (it must FAIL on the build before), the newest ~80 older checks, and the seed 4242 fingerprint (ents 85/374, containers 165/593). Do not report a build as ready if the gate did not pass. For anything a player can see, take pictures (`tools/uishots.ps1`) and look at them.
5. **Never change the storage key** `salvagerun:profile` without a migration; it holds his progress.
6. **Respect the layer split.** Simulation, AI, collision, and line of sight run on flat top-down coordinates. Rendering (the y-sorted 3/4 canvas pass, fog, lighting) and the HUD overlay are a separate layer. Do not blur them. Do not reintroduce 3D or external libraries without an explicit request.
7. **Rollback on request.** "Revert" means `git revert` of the commit, then re-verify through the gate. Never force-push, reset or rebase.
8. **Feel is his call.** The test corpus and the crash robots (`tools/fuzz.ps1`) measure breakage, not fun. If a change is risky or untestable (rendering, feel), say plainly what he should watch for in the next playtest.
9. **Player text:** short callouts, every word lower case, `$` for money and `SP` for score, never an explaining sentence, and the lore word is "ascend" (never "drop in"). Never print, copy or read aloud an API key or a variable that holds one.

## Communication style
Bottom line first. Brief, plain language: what, why, how long. No em dashes or en dashes anywhere. Own mistakes in one line and fix them. Do not pad reports; if a check finds nothing, say so.
