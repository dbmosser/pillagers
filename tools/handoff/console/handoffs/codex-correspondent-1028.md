# Codex Correspondent handoff, 10-28 (cloud session_01LWYNPWvCm8EYsNVBKVqoJB)

ROLE, his words (10-27 night): "Name this chat Codex Correspondent -- your job is to make sure we are getting our money's worth out of Codex". On my first report: "i don't understand what any of this means. Im not a dev. Are you using Codex to improve the game or not?", then "are you helping?". So: tell him in plain words what Codex added to the game.

STANDING ORDERS TO THIS CHAT: none beyond the role. He gave no orders here on Codex models, effort or limits. Lane facts at 10-28 12:40: gpt-6.1-sol, high effort every run (the script reads only CODEX_EFFORT); limits.txt week 16%, 5-hour 72%, week resets 2026-11-04 01:35.

WHAT THIS CHAT DID
- 10-27 about 22:55 sent the CEO six items. Landed on master: 1 (13 jobs renamed o-), 2 (console-lane.sh line 100 filter "/o-[^/]*\.md$"), 3 (checkin.sh keeps 5 o- jobs queued), 4 (codex/limits.txt meter), 5 (README marks unbuilt guards "not built"). Still open: 6, the heldby rule (a TASK WAITING on a job no list holds, or on itself, counts as a try) is not in codex-lane.sh.
- Result, 10-27 23:09 to 10-28 12:25: 20 Codex builds (19 ON HIS PC in onhispc.txt; v35.56 NOT, replaced by v35.57), 9 jobs DONE (120d, 120e, 120f, 120g, 132, 135, 137, 138, 142).

EVIDENCE (runs.txt, week one)
- Small scoped fixes win: 13 jobs DONE in 2 or 3 runs, about 1.3M input each.
- Big hunts lose: 87r reds (22.8M, partial after 5 runs), 94 and 95 (partial after 5 runs each), 90 (8.1M, partial).
- Week one hit the weekly cap at about 306M input in 3.5 days, then sat locked out 5 days. Allowance unused at a reset is lost, so the lane should never run dry while the week has room.

OPEN WORK
- Branch claude/festive-newton-g6wg38, base 9bd6b6a5. No code changes from this chat. The only commit is this file, pushed. Nothing unpushed.
- Item 6 above.

CHECK-INS CANCELLED (both deleted 10-28)
- trig_01Rrmr58ZQTKRHFSrmbYMjTJ "Codex usage check", due 10-28 07:30 local. It fired at 07:31 and failed (access denied), so it never reached him.
- trig_01LYLjGSm9Lpisrv4CFScwJL "Codex evening check", due 10-28 21:00 local: read limits.txt, count queued o- jobs and Codex builds on his PC since 12:40, refill to 5 o- jobs if the week is under 80%, then tell him in two or three plain sentences how many fixes Codex added and whether it still has work. I promised him this check; the successor owns it tonight.

THE SUCCESSOR MUST NOT
- Talk to him in lane terms (o- prefix, runs, tokens, filters). Say what changed in the game.
- Hand Codex jobs that need live measuring, a soak, fixq or mkfixture retargets, his saved profile, two-window net work, or a red-check hunt.
- Set OPENAI_API_KEY or CODEX_API_KEY anywhere (billing would leave his plan).
- Call a build done without its ON HIS PC line.
- Ask him to run or edit anything.
