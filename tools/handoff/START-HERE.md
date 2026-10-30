# START HERE

## FROZEN FOR THE PARTY (his order 10-29 ~21:30, to the CEO chat): "get to a stable build and lets use that.  party is less than 48 hours away and i need some cluade usage left over for work tomorrow"
- The party build is **v36.55**, stable since 10-29 22:13 (tag stable-v36.55). His 8802 serves it at both http://localhost:8802/ and /stable.html.
- **Codex ships until Sat 10/31 12:00, then nothing until Sun 11/1 01:00** (his 10-30 "shouldn't we be blowing our codex use": every o- job is back in tasks/, unpaced; a one-shot CEO cron sets console/STOP at Sat 12:00; stable promotions are on again so stable.html tracks the newest tested build). Before that, his 10-30 order: "Over the next 30 hours, Make any edits you see as critical for two player play, and test them. Use Claude sparingly so as to leave me at least 5% of usage, try to blow Codex instead". Codex lane o runs unpaced on job o-00y (2 player online party); Claude lanes a, b, c are off (console/STOP-claude); other Codex jobs wait in console/hold-2p. stable.html stays v36.55 as the fallback. tools/handoff/console/STOP stops lanes a, b, c and o; tools/handoff/stable.freeze stops promotions. shipq.sh does NOT read STOP, so a chat must not ship by hand.
- **Save Claude use:** no scheduled check-ins, no background watchers, no robot or critic runs that call Claude. The CEO cron and watcher are off. A chat answers only when he writes to it.
- If he gives a game order now: write it into console/open-orders.md and a job in console/tasks/, do not build it, and tell him it waits until after the party.
- At the first chat turn on or after Sun 11/1: remove STOP and stable.freeze, move after-nov1/ jobs back to tasks/, re-arm the CEO check-in (text in console/checkin-prompt.txt).

## CURRENT (rewritten 2026-10-27 night). One page on purpose: every new session reads it. The old 127 KB of handoff text (10-20 and the September alpha run) is in START-HERE-HISTORY.md; it is stale, do not copy rules from it.

**The game:** PILLAGERS (old name Dark Raiders; the file is still dark_raiders.html). The owner plays, gives orders and is not a coder; his answers are binding. Current build: `var VER` in dark_raiders.html (or `git log -1`).

**His standing orders this week:**
- "I don't want any development paused or delayed because of the party or any other anticipated date. Just keep developing" (10-28, about 08:10). This ended the 10-27 "no new features until Nov 1" freeze: the parked feature jobs are back in tasks/, and nothing is held for the party or any date. Party-breaking bugs still go first in line.
- **POLISH ONLY until the party (his 10-28 16:55): "focus for the remaining 17% of weekly usage should be to polish the game as much as possible before Saturday night party".** Refined by his 10-28 ~20:30 order: "allocate the remaining weekly use responsibly between polish and new features, with polish taking the priority". The split: about two thirds polish, one third features. Polish jobs (numbered) always go first; feature jobs wait at the end of tasks/ as z-NNN-*.md (the lanes take jobs by name, so a z- job runs only when no polish job is free). At 95% of the week the CEO check-in moves any z- job not yet started back to console/after-nov1, so the last points go to polish and party fixes. Codex (own plan) runs his orders first, then polish o- jobs, then features. His direct orders always go first.
- Party: Saturday 10/31 night by his 10-28 words (earlier notes said Fri 10/30 night), the 2 player arcade demo on his main PC (http://localhost:8802/, click the demo). No launcher, no party mode. Release: Thanksgiving, Thu 11/26 on itch. Never remind him about itch payments or the tax form.
- Plan pace (10-28 16:55): the line climbs evenly from 83% to 99% at Sat 10/31 22:00 local (caps.txt PLAN_LINE_*), about 0.3 points an hour for everything together. Helper lanes follow that line by themselves; chat sessions do not, so they must keep cost down (below).
- Smooth look (pixel look off), pillager at size 1. Every player word lower case. The veto list of things he banned for good is in tools/handoff/console/RULES.md.

**Where a build goes after a ship (all automatic):** GitHub master at once; itch within about a minute (tools/itch-follow.sh); his main PC's 8802 within about a minute (the idle runner there follows master). `shipq.sh` then waits for his PC and prints `ON HIS PC vNN.NN` or `NOT ON HIS PC` (tools/handoff/onhispc.sh, log in console/onhispc.txt with the week's plan use). **Never say a build is done without its ON HIS PC line** (his 10-27 feedback: "stuff you told me you did, you didn't do"). To ask the main PC directly: `node tools/bridge/hostctl.mjs main-status`.

**How his orders become work:**
- He talks to exactly two chats, both pinned and on his phone (his 10-27 night order: "Only give me the threads I need to interact with"): "CEO and Efficiency Czar" (runs the operation: chats, models, tools, check-ins, follow-up of every order) and "Gameplay Edit Intaker" (his game orders; it was "Game feature requests and edits"). Every other chat or agent is a helper: Remote Control off (the app default is now off), never pinned, archived when its job is ON HIS PC (the app also archives anything idle for 1 day). Never turn Remote Control on for a helper.
- His order chat is "Gameplay Edit Intaker" (renamed by him 10-27 ~22:50; it was "Game feature requests and edits"). Each order goes into tools/handoff/console/open-orders.md the moment he gives it, then gets a job file in console/in-session/ and its own helper (a background agent from the CEO or orders chat, or a session with Remote Control off). Nothing lives only in a chat.
- At most 3 sessions build at once (VM memory: each gate run opens Chrome; and the plan). More orders wait as job files.
- **Model ladder** (10-27 night, his "figure out an efficient escalation plan"; our runs.log plus reports/model-escalation-research.md). Start each job on its rung, set with start_session `model` / `effort` (the lanes do it by themselves in console-lane.sh):
  1. Free: the local reviewer (qwen) reads every new build's diff; Codex (lane o, Sol medium, high from run 3) takes small, exactly specified fixes with no old-check retarget.
  2. Sonnet 5.5 high: text, layout, colour, one number, a small rule. Never Sonnet xhigh or max (Opus high scores higher for less).
  3. Opus 5.5 high: a normal fix or polish job, and every Claude lane run from run 3 on.
  4. Opus 5.5 xhigh, the top rung: a crash, a bug that already failed once, a rendering or netcode mystery, anything that can break the 2 player party demo (a lane job file whose first lines say `model: opus` starts on Opus). Never max.
  - Move UP one rung after two failed preflights on the same cause, a critic score stuck twice, or him saying it is still broken: start the higher rung fresh with a short summary of what failed (a running session: set_session_model / set_session_effort from the CEO chat).
  - Move DOWN: once a strong model has found the cause, a mechanical follow-up (renames, one number, retargets) goes to Sonnet or Codex as an exact job file.
  - Lanes: 4 tries per job (runs 1-2 Sonnet, 3-4 Opus), then the job lands in failed/ and the CEO chat splits or re-scopes it.
  - After the party: trial of Sonnet with an Opus advisor against Opus high (console/after-nov1/e1-advisor-trial.md).
- A long chat that has been summarized twice hands its open orders to fresh sessions and keeps only check-ins.
- Budget guard (10-27 night; week 66% at 21:42, burning about 1.5 points an hour against the line's 0.4): before starting a build session, read the week in console/plan-usage.txt and the line in console/status-a.txt. More than 10 points above the line: save by doing FEWER things at once (at most 2 build sessions), never by doing them worse; the model still follows the job (his 10-27 night: "this has to be AAA top to bottom"). Sonnet stays only for jobs it does as well: text, layout, colour, one number.
- Default model (10-28): `.claude/settings.json` starts any session that names no model on Opus 5.5 at high (rung 3), so a forgotten pick no longer lands on xhigh; an explicit model or effort still wins. The Claude Correspondent chat watches cost only (each chat's model, effort and context size, duplicate work) and reports to him; the CEO chat still coordinates.
- Fix and polish jobs that are not his direct orders wait in console/tasks/ for the helper lanes (a, b, c on his plan, o on Codex; status in console/status-LANE.txt).

**How a change ships:** mk script, `bash tools/handoff/preflight.sh LANE cw-KEY` until PREFLIGHT PASS, then the ship queue script `shipq.sh cw-KEY` (exact paths and steps: RULES.md "How a change ships"). Never edit dark_raiders.html or tools/mkfixture.ps1 by hand; never bump versions by hand. Batch fixes with one cause into one ship.

**Read next, only what your job needs:**
1. tools/handoff/console/RULES.md (veto list, how a change ships, permissions).
2. The memory index (loaded for you); open the BINDING notes your job touches.
3. tools/handoff/console/open-orders.md for what he has asked for and not got yet.
4. Screen work: tools/handoff/console/notes/ui/style-guide.md; camera: tools/uishots.ps1; look at the pictures.

**Watching (10-27 night, his "why only once every 2 hours?"):** the CEO chat runs tools/handoff/console/ceo-watch.sh in the background: checkin.sh every 10 minutes, no AI cost, and it wakes the CEO only on a LOOK/STOP line or alarms.md line it has not reported before (then the CEO handles it and starts the watcher again). The 2-hourly check-in stays as the full review; he hears only about changes he will notice.

**Where the news is:** tools/handoff/nightly/DATE.md (runner summary), tools/handoff/console/alarms.md, the dev dashboard (tools/devdash, port 8820). Check-ins: tools/handoff/console/checkin.sh prints ALL CLEAR / LOOK / STOP.

**Never:** test on, restart or change his 8802 server; change the storage key `salvagerun:profile` without a migration; edit a running bash script in place (write .new, `bash -n`, then mv); add 3D, a raycaster or WebGL (this project is the 2.5D one only).
