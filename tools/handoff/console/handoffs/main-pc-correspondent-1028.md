# Main PC Correspondent handoff (10-28 14:40 local)

Role, his words: "make sure we are getting our money's worth out of the Main PC's resources". Then: "need more autonomy, shouldn't be waiting on me to 'say the word' im not a dev". Cloud session: changes go as a branch to the CEO, which parses (PS 5.1) and lands them.

His standing orders to this role:
- Use the GPU now: "i don't think the party is any reason to not use the gpu".
- Keep 4 GB free on the main PC: "can we knock it down to only leave 4gb free?" (it was 6). The VM still takes its memory first.
- Test while he works at the PC: "what about daytime testing when i'm at the pc?" Never while he plays.
- No full-screen test: "get rid of the whole fullscreen concept ... i fullscreen apps all the time".
- XMP stays on; never recommend turning it off. No purchase suggestions (no 64 GB).

Landed on master (branch claude/gallant-hawking-vvpq1d, head 520ac077, pushed; nothing unlanded):
- 47c107b4: pad use counts as gaming for the VM (pad-seen.txt); fuzz.ps1 log retry.
- 77b9dbfe: runner restarts after a reboot; copy updates no longer keep 8802 down.
- a159b743 (with 1ce481d4): NewRunnerOK (refuses an unparseable new copy); LOCAL_AI=0 in caps.txt; health.sh "main PC runner:" line; no start-and-stop (waits for VM growth, 30-minute hold); one 4K two-window robot on 9332; 8802 upkeep every minute while testing; perf-4k.txt per build.
- 998de3e7: bridge firewall rule uses LocalSubnet (survives restarts).
- 8a48b533: 4 GB floor (start 6, stop under 4 at two looks); one light 1080p below-normal robot while he works.
- 5e11e303: no full-screen check; only a real pad use counts as playing (padUseT).

Open checks for the successor:
1. JUL26 status runner= should read A978208E (master's CRLF hash). At 14:37 it still read A2BB42E5, minutes after the land.
2. runner.log and fuzz.log: "below normal (he is at the PC)" robots while he works, stopped by "he is playing (...)"; size=3840x2160 starts when he is away; no stint under 10 minutes; perf-4k.txt lines appear.
3. He was told to say if the PC feels slow while he works; then make the daytime robot lighter or turn it off.
4. Unverified: whether the host game check reads the 4K robot as a game (Watch falls back to 1080p for the day, state no4k).
Baseline 10-22 to 10-27: robots 30% of the time; 0 problems in 960 raids; 116 stints, median 4 minutes.

Check-ins cancelled: trig_012xtC6gHCKHz4BDzScLsKvL (10-28 03:56Z) and trig_01KyCw323htKFXDiouESEC2S (09:18Z), both one-shots that had already failed (ACCESS_DENIED). None pending.

Do not:
- recommend turning XMP off, or buying RAM;
- go under his 4 GB floor, or take memory ahead of the VM;
- touch, stop or restart 8802 (Ensure-Play is its only starter);
- bring back the full-screen test, or the local AI without his say;
- ship a runner edit that is not ASCII and PS 5.1 (the cloud has no PowerShell).
