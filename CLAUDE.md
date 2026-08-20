# CLAUDE.md - Dark Raiders

## What this project is
Dark Raiders: a single-file HTML5 extraction shooter. The entire game is `dark_raiders.html` (3/4 StarCraft-style 2D canvas renderer over a top-down simulation). Current version: v0.8. `DESIGN.md` is the source of truth: pillars, systems, config reference, changelog, telemetry protocol, known limits. Read it at the start of every session before touching anything.

## Who you are working with
Daniel is the designer and playtester, not a coder. Never ask him to edit code, run commands, or debug. Ship finished builds; he plays them by opening `dark_raiders.html` in his browser.

## Workflow rules
1. **Data before changes.** Tuning changes come from flight-recorder exports (in `exports/` or pasted into chat). One batch of tuning changes per feedback cycle, each with a one-line reason. No speculative changes without data. New features only when Daniel asks.
2. **One canonical file.** Overwrite `dark_raiders.html` in place. Never create copies like `dark_raiders_v2.html`. Git history is the version trail.
3. **Version discipline.** Every build: bump the version in all three strings (title-screen brand, flight recorder export header, config copy line), add a changelog entry to `DESIGN.md`, then commit as `vX.Y: one-line summary`.
4. **Verify before done.** After every edit, extract the script content and run `node --check` on it. Do not report a build as ready if it has not passed.
5. **Never change the storage key** `salvagerun:profile` without a migration; it holds his progress.
6. **Respect the layer split.** Simulation, AI, collision, and line of sight run on flat top-down coordinates. Rendering (the y-sorted 3/4 canvas pass, fog, lighting) and the HUD overlay are a separate layer. Do not blur them. Do not reintroduce 3D or external libraries without an explicit request.
7. **Rollback on request.** "Revert" means `git revert` or checkout of the prior commit, then re-verify.
8. **Feel is his call.** The bot sim measures balance, not fun. If a change is risky or untestable (rendering, feel), say plainly what he should watch for in the next playtest.

## Communication style
Bottom line first. Brief. No em dashes or en dashes anywhere. Own mistakes in one line and fix them. Do not pad reports; if a check finds nothing, say so.
