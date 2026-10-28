# START HERE

## CURRENT (rewritten 2026-10-27 night). One page on purpose: every new session reads it. The old 127 KB of handoff text (10-20 and the September alpha run) is in START-HERE-HISTORY.md; it is stale, do not copy rules from it.

**The game:** PILLAGERS (old name Dark Raiders; the file is still dark_raiders.html). The owner plays, gives orders and is not a coder; his answers are binding. Current build: `var VER` in dark_raiders.html (or `git log -1`).

**His standing orders this week:**
- "Ok no new features until Nov 1. Resources should now be spent polishing, bug fixing, etc" (10-27). Feature jobs wait in tools/handoff/console/after-nov1 and go back to tasks/ on Sun 11/1. His fullscreen gate, fog of war and hotbar items orders of 10-27 are his own exceptions.
- Party: Fri 10/30 night, the 2 player arcade demo on his main PC (http://localhost:8802/, click the demo). No launcher, no party mode. Party readiness comes first until then. Release: Thanksgiving, Thu 11/26 on itch. Never remind him about itch payments or the tax form.
- Plan pace: weekly use climbs to 90% by Fri 10/30 08:00 (caps.txt PLAN_LINE_*). Helper lanes follow that line by themselves; chat sessions do not, so they must keep cost down (below).
- Smooth look (pixel look off), pillager at size 1. Every player word lower case. The veto list of things he banned for good is in tools/handoff/console/RULES.md.

**Where a build goes after a ship (all automatic):** GitHub master at once; itch within about a minute (tools/itch-follow.sh); his main PC's 8802 within about a minute (the idle runner there follows master). `shipq.sh` then waits for his PC and prints `ON HIS PC vNN.NN` or `NOT ON HIS PC` (tools/handoff/onhispc.sh, log in console/onhispc.txt with the week's plan use). **Never say a build is done without its ON HIS PC line** (his 10-27 feedback: "stuff you told me you did, you didn't do"). To ask the main PC directly: `node tools/bridge/hostctl.mjs main-status`.

**How his orders become work:**
- His order chat is "Game feature requests and edits". Each order goes into tools/handoff/console/open-orders.md the moment he gives it, then gets a job file in console/in-session/ and its own session. Nothing lives only in a chat.
- At most 3 sessions build at once (VM memory: each gate run opens Chrome; and the plan). More orders wait as job files.
- Pick the session's cost to fit the job (start_session `model` / `effort`):
  - text, layout, colour, one number or a small rule: `model: claude-sonnet-5-5`, `effort: high`;
  - a normal fix or polish job: Opus, `effort: high`;
  - only a bug that already failed once, a crash, or a rendering or netcode mystery: Opus, `effort: xhigh`.
- A long chat that has been summarized twice hands its open orders to fresh sessions and keeps only check-ins.
- Budget guard (10-27 night; week 66% at 21:42, burning about 1.5 points an hour against the line's 0.4): before starting a build session, read the week in console/plan-usage.txt and the line in console/status-a.txt. More than 10 points above the line: Sonnet at high for every new session. Week at 85% or more before Fri 10/30 08:00: start only fixes for something that breaks the 2 player party demo; everything else waits as a job file. His 10% stays his.
- Cost seat (10-28, his "do everything you've recommended"): the budget guard covers chat seats too, not only build sessions. Until the party, Opus is for party breakers only; polish runs on Sonnet at high. `.claude/settings.json` makes Sonnet at high the default for any session started without a model; name Opus when the job rule above calls for it. The Claude Correspondent session checks the week every 4 hours.
- Fix and polish jobs that are not his direct orders wait in console/tasks/ for the helper lanes (a, b, c on his plan, o on Codex; status in console/status-LANE.txt).

**How a change ships:** mk script, `bash tools/handoff/preflight.sh LANE cw-KEY` until PREFLIGHT PASS, then the ship queue script `shipq.sh cw-KEY` (exact paths and steps: RULES.md "How a change ships"). Never edit dark_raiders.html or tools/mkfixture.ps1 by hand; never bump versions by hand. Batch fixes with one cause into one ship.

**Read next, only what your job needs:**
1. tools/handoff/console/RULES.md (veto list, how a change ships, permissions).
2. The memory index (loaded for you); open the BINDING notes your job touches.
3. tools/handoff/console/open-orders.md for what he has asked for and not got yet.
4. Screen work: tools/handoff/console/notes/ui/style-guide.md; camera: tools/uishots.ps1; look at the pictures.

**Where the news is:** tools/handoff/nightly/DATE.md (runner summary), tools/handoff/console/alarms.md, the dev dashboard (tools/devdash, port 8820). Check-ins: tools/handoff/console/checkin.sh prints ALL CLEAR / LOOK / STOP.

**Never:** test on, restart or change his 8802 server; change the storage key `salvagerun:profile` without a migration; edit a running bash script in place (write .new, `bash -n`, then mv); add 3D, a raycaster or WebGL (this project is the 2.5D one only).
