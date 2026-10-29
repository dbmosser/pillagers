
--- codex run 2026-10-29 01:13 ---
2026-10-29, first run, v36.31. Read the completed 228-freeze-when-downed job first: v36.26 ON HIS PC fixed the world name tag loop. That hang was unrelated to the Lance sound.

Found the sound before making the draft. trace-audio.js extracts the actual reload, shot, bank decoder, receiver and room generators and logs every source start/end and the complete connected audio graph. It also renders those nodes offline at 22050 Hz, including gain automation, Web Audio lowpass Q in dB, filters and feedback delays. The mix is unity, without a compressor hiding a tail; this is a diagnostic renderer, not a native browser recording. audio-node-log-before.json has the old graph and results; audio-node-log.json has the draft results.

The long sound is the shared room reverb. Its four feedback lowpass filters left Q at the Web Audio default (+1 dB). That creates a resonant peak; the high indoor/vault feedback can keep that frequency ringing after the source stops. The vault trace grows instead of decaying. Both ordinary and active Lance reloads reproduce it in the owner and teammate paths. Lance, Longshot and rocket shots can excite it too. The Lance shot length 5000 is samples, not 5000 ms; its original source buffers are already short. No shot voice lengths need changing.

The active-reload trace sends ~whine, ~ping, ~whinex in that order. The local whine and the teammate whine are both stopped within 70 ms of completion. Delayed seat/latch/ping sources all finish promptly. The persistent sound is downstream in the room, not a late-starting whine. The vent, seat, charge and ready ping remain intact.

Prepared cw-cx-lancetail. Two game edits only: set the room feedback lowpass Q to -3.0103 dB (no resonant boost), and lower vault feedback from 0.86 to 0.80. The reverb remains enabled, including enclosed-room wet level, damping and short gunLayers reflections. No pickup, loot, loot row, seeded random or world-generation code changes.

Validation: mk printed written; both exact anchors match once; the complete game JavaScript parses after applying the draft in a temporary diagnostic copy. A sandbox simulation of the proposed fixture check fails on the current build and passes on the draft. That check uses the real sound generators, records source lifetimes, renders the connected room graph, tests full and active reloads in both receiver paths, verifies whine/ping/cut wire order, and checks Lance/Longshot/rocket last shots. It restores the globals it replaces. No old fixture check needs retargeting.

Draft offline results: worst peak more than 1.5 seconds after the deadline was 0.0001269, below 0.001. Vault owner/teammate active reloads last exceeded 0.001 at 1.126 seconds after completion; full reloads were below it within 0.721 seconds in the vault and 0.899 seconds indoors. All three isolated shots were below it within 0.891 seconds. Open-air cases also passed. Browser preflight, real shipping gates, fingerprint and ON HIS PC remain the lane's work.

DESIGN watch line is in draft.now: the Lance no longer rings on after a reload
Watch on next play: finish a normal and active Lance reload indoors or in a vault. All four reload cues should remain, with the ring dying quickly. Other world sounds through the same room reverb also decay sooner. No screen changes or camera shots are needed for this audio fix.

