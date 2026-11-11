# PILLAGERS-HTML NEW CEO: handoff to the successor (written 11-11 07:50 ET by the first holder, session local_2501bdaf)

## Who you are and what binds you
- You are the HTML project's lead chat (owner's 11-08 package). Your RULES row: "Maintain the separate HTML project's essential instructions, work, and evidence; coordinate appropriate Codex work without importing FnP requirements."
- Read, in this order: `C:\claudecode\dark raiders\CLAUDE.md`, `tools\handoff\START-HERE.md` (CURRENT block + the NEW PHASE line), `tools\handoff\console\RULES.md` (veto list, how a change ships), and the owner addendum, which is the last sections of `C:\claudecode\FNP new 11082026\RULES.md`: 1.x PC protection, 2.3 cleanup, 4.8 digest, 4.9 pacing, 4.10 owner channel, 6.x Codex usage and the idle backlog.
- Memory notes that matter most: `pillagers-new-phase-2026-11-08.md` (commands for every duty), `pillagers-autonomy-m103-2026-11-08.md`, `pillagers-itch-key-hold-2026-11-08.md`.
- FnP and HTML stay separate (D12). Never copy FnP game requirements into this folder.

## The owner's standing orders (newest first)
- 11-11 ~04:0x: "Keep everything else rolling too of course". 11-10: no idling ("if you don't have other work you should be seeking to improve/refactor what is already established"). Keep a ranked, always-full backlog, and start the next row in the same turn without asking him.
- Codex: spend this week's Codex usage by Fri 11-14 08:00 ET (M172; reset tokens expire 11-30). Read Codex usage only from `C:\claudecode\FNP new 11082026\status\codex-usage.json`, never from Codex session files (RULES 6.1). On 11-11 at 03:53 Codex had used 2%.
- Claude pacing, RULES 4.9 (his 11-08 08:22 text): one shared budget for every chat. A fixed hourly ceiling runs from 19% at 11-08 08:23 to 90% at Sat 11-14 15:00, rising 0.471 points an hour. FNP NEW REPORTER keeps it in `status\claude-usage.json` "pace". Over the ceiling, development slows but never stops (owner M082/M084): short, batched Claude turns, and work goes to Codex. At 11-11 06:00 the week was at 72% against a ceiling of about 43%, so the Claude helper lanes a, b and c stay idle by design.
- M103 autonomy: decide, do, verify and report. Escalate only gameplay preferences, scope or spending changes, actions outside your authority, or owner-only steps, and always with a recommendation. Archive (never delete) a superseded worker chat after a verified handoff. Never archive Reporter (local_978234f7) or the family top chat (local_6488d5a9).
- M091: never raise the itch upload key or the stuck itch version with him until he does ("later, leave me alone abt it for now"). itch has had v37.39 since 11-02 (invalid key). The internal alarm in tools/itch-follow.sh fires once per stuck version and can stay.
- Owner channel, RULES 4.10: he reads only FNP NEW REPORTER. Anything for him goes through `python -I -B "C:\claudecode\FNP new 11082026\tools\owner_queue.py" add --source "PILLAGERS-HTML NEW CEO" --project HTML --responsible WHO --kind update|question|approval|action|risk|decision --text "..."`, then one line to the Reporter with the id. Use `mark ID received|answered|superseded --by ...` when answers come back. He said 11-10 that he does not read this chat. No routine status relays.

## Your recurring duties
1. **Hourly digest, 06:00 to 23:00, and the daily part (a) at midnight** (RULES 4.8): `C:\claudecode\html-digest.md`. The scheduled task "Pillagers HTML digest check" writes `C:\claudecode\html-digest\html-wake.txt` when a watched file changed (config: `C:\claudecode\html-digest\digest_html.json`). It also appends "HH:00 no change." lines by itself. Keep a background watcher running:
   `W=/c/claudecode/html-digest/html-wake.txt; while [ ! -s "$W" ]; do sleep 60; done; echo "HTML WAKE:"; cat "$W"`
   On each wake:
   - read get_usage;
   - write `tools/handoff/console/plan-usage.txt` as `0 WEEK EPOCH`;
   - add a short entry under the `<!-- newest entry first ... -->` marker, with the game version, what moved, and one 4.9 pacing line;
   - empty the wake file (`: > html-wake.txt`);
   - log the wake: `python "C:/claudecode/FNP new 11082026/dashboard/set_status.py" --dir 'C:\claudecode\html-status' --id pillagers-html-new-ceo --project HTML --chat "PILLAGERS-HTML NEW CEO" --stage working --task ... --last-result ... --next-action ... --event wake --reason ...` (plain python, not -I);
   - restart the watcher.
   At midnight, rewrite part (a) for the day and clear part (b).
2. **Dashboard rows** in `C:\claudecode\html-status\`: `pillagers-html-new-ceo.json` and `html-codex-lane-o.json`, at the start, on a block and at the finish. The dashboard runs at http://127.0.0.1:8835/.
3. **Codex lane o is the engine this week.** Keep tools/handoff/console/tasks/ and backlog/ full of o-*.md jobs: when tasks/ has no o- job, the lane pulls the next backlog file by name. When Codex stops with "coordinator action required", do the fixture retarget yourself:
   - edit tools/mkfixture.ps1 exactly as Codex's note says;
   - commit it with `bash tools/handoff/shipkit/fixq.sh "MESSAGE"`;
   - check the result with `node tools/handoff/codex/retarget.mjs jscheck tools/fixture.html`;
   - add a note line to the job's notes file and alarms.md;
   - if the job sits in failed/, put it back in tasks/ with fresh runs by renaming its lines in spend.txt and cli-spend.txt to NAME-rK, then mv it.
4. **JT PC holds for FnP tests**, on request from FNP NEW JT PC CORRESPONDENT or the lead. Write `tools/handoff/spare/fnp-hold.txt` with `until=EPOCH` (the folder is gitignored, so use `git add -f`). Remove the file on "FNP JT DONE". The runner already stops HTML tests whenever Fortnite runs there.

## State at handoff (11-11 07:50)
- Game v37.67 ("end run leaves only your seat", on his PC 11-08 20:31). He has not played v37.59 to v37.67 yet (said "later today" on 11-08).
- tasks/:
  - **o-h05 revive with a bandage:** check 37.17 retargeted (eafd6262e). Its draft waits at the gate, 4 tries used of 5.
  - **o-h09 loot in sight:** my 11-11 amendment lets it fall back from 140-320 to 60-140, then 320-480, then the nearest point within 600 that is in sight.
  - **o-h15 every hud panel movable:** check 34.88 retargeted (839c17dc2). It has fresh runs.
- backlog/: season zero m4 in order: o-p4a survival level, o-p4b level picks, o-p4c pick badges, o-p4d co-op boost and one raid-end screen. Each later job WAITs ON the one before it. m5 and later wait in notes/progression/m4-m10-jobs.md. m5a needs 2 or 3 mockups he picks from (rule 53), so ask that through the Reporter with a recommendation when you reach it.
- waiting/: o-h06, h08, h11, h13, h14, h16 and h17 all shipped or are code-complete. They wait only on camera pictures or critic follow-ups that need the JT PC, or on HUD critic findings outside their scope. Pick them up when the JT PC is free.
- **Fix 11-11 (4da009807, 83f704659):** a gate that only waited on a busy JT PC used to count as a spent Codex try. Now it returns a wait. The lane process that was still running the old code was stopped at 07:05. **First thing to check:** a fresh `codex-lane.sh` process has started (the "Pillagers runner" task launches it every 15 min), and o-h05 is not losing tries. At 07:50 no lane process was running, and the JT PC was paused for a person using it (`tools/handoff/spare/live.txt` paused=1). The cause, fixed 08:02 (8588423f3): the runner's gaming hold (tools/nightly.sh, `machine_game_holds` in tools/handoff/machine.sh) treats any running FortniteClient on the main PC as him playing, and starts nothing new. The client is usually the FnP lead's test client. Step (5c) in nightly.sh now starts lane o when Fortnite is the only hold, and lane o's own guard (codex-lane.sh, his input under 3 min or a two-player check) still applies.
- itch: still v37.39. Do not raise it with him (M091).

## Things that bit me (do not repeat them)
- pillagers-watchdog came back on after a reboot (it ran 11-11 07:07). After any restart, run list_scheduled_tasks and set it to enabled:false again (owner M195). Owner M197: he reads only the Reporter, so this chat writes no recaps, one terse status line per turn.
- The Bash tool collapses `\\` and turns `\n` inside heredoc Python into real newlines. Write Windows paths, JSON and escape sequences with the Write or Edit tool, or use chr(92) in Python.
- A running bash script keeps its functions in memory. Editing codex-lane.sh does not reach a lane process that is already looping, so stop it (lock pid in tools/handoff/console/lane-o.lock/pid plus its preflight children) or wait for it to end. Always write .new, run `bash -n`, then mv.
- A scheduled task's description saying "paused" means nothing: set enabled=false and verify it (the pillagers-watchdog mistake of 11-08).
- set_status.py fails under `python -I`.
- Pass `-c core.autocrlf=false` to every git pull or push here. tools/handoff/spare/ is gitignored.
- Never edit dark_raiders.html by hand. Edit mkfixture.ps1 only through fixq.sh. No HTML tests on the main PC. Never stop, restart or change 8802 except through tools/start-servers.ps1. Never touch the TbT VM. Never read other chats' transcripts or any keys.
