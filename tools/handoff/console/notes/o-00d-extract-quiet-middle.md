
--- codex run 2026-10-28 22:12 ---
2026-10-28 - Sound audit before changes (v36.23)
- dark_raiders.html:29031-29055: xalarm throb every 1.8 s, currently first/last 4 s, no throb while the ship holds. Synth at 10436-10447 lasts 1 s.
- 29056-29065: inbound sonar ping through the ENTIRE wait, every 2.2 to 0.55 s. This is the continuous middle sound. Synth at 10448-10460 lasts 0.46 s. No extract hum loop exists.
- 28688 and 28724: beacon melody plus alarm on local call; 63702: beacon melody for the host receiving a teammate call.
- 22907-22921: alertShow plays a short alertSting; a queued extraction alert can start later than its original call, so its sound also needs the wait rule.
- 29271: touchdown thump plus alarm on landing; 29279-29280: lastcall pulse in the final eight seconds of the landed ship window. These are outside the inbound wait and should remain, as should boarding.
- 28605: sndExtracting rising beacon ONLY when starting the second pull after the ship has landed (hold>0); 28611: board ticks during that pull; 35694 / 8097-8101: EXTRACTED chord on departure. Preserve these.
- 8080, 8103-8104, 51857: TWOMIN / ONEMIN are RAID clock warnings, not extract countdown sounds. Preserve vital raid-clock warnings.
- 7673-7675, 7705-7715: musicWanted rejects a raid and tickMusic cuts leftover outcome music. The extraction/music comment at 7699 is stale; no extract music or looping sting plays in a raid.
- 8351-8354 / 8390-8405: sfxHere keeps ring audio local in each window; no party echo. NoiseMark at 8044 creates visual sound rings only, with no enemy wake-up.
Enemy pull, independent from audio:
- 28702-28722: local call ping plus nearby hostile alert/investigate targets. Host receiving a party call mirrors it at 63695-63699.
- 29117-29150: per-zone siege arrival timer spawns machines during wait AND landed hold.
- 29159-29231: every two seconds ping emits 1200*(1+0.7*greed)*echo, and the separate capped 1500-unit pull refreshes pillagers/machines. Neither depends on xAlarm, inbound audio, noiseMark or alarmAge. Keep this code and its seeded draws byte-for-byte.
Watch: the extract is quiet in the middle of the wait but still pulls enemies
Prepared cw-cx-extractquiet (12 exact edits):
- XALARM_LEN 4 to 3; siren and sonar share an audio-only timing gate. Short cue tails fit inside the opening three seconds.
- Extract/siege alert stings obey the same rule even if queued. Other alerts, raid-clock warnings, boarding ticks/rise, landed last-call warnings, touchdown and extracted chord keep their normal behavior. The extract dial also mutes automatic call, landing and last-call sounds; boarding/departure remain outside this wait control.
- Sound age advances while muted and for inactive called rings. Local, teammate and AI pillager calls reset their sound clocks. Player 2 world snapshots seed the age from the remaining wait, preventing a mid-wait sync from replaying the opening alarm.
- Additional audit: 29347-29356 queues extraction closing/closed alerts without a key; these now share the extract alert sound gate too. 33690-33696 is an AI pillager call: its ping attracts enemies, but it has no direct audible beacon tone.
Validation here: mk script printed written. All 12 anchors match exactly once as literal shipping anchors, including sequential application. The edited game script and regression check parse. Static comparisons confirm the siege/pull block, spectating-host siege, boarding interaction, rising boarding cue and raid-clock warning logic are unchanged. No game or fixture file was edited.
Regression handed to the lane: exercise each seat (p1/host and p2/join), with extract sound on and muted; record all direct wait cues; require opening and final sonar/siren and no middle sound; require nine full-strength two-second enemy pings over 19.95 seconds and both pillager/machine target refreshes, including six or more middle pings; check hold attraction, delayed extract/siege/closing alert stings, unrelated alerts, sound tails and a real player-2 mid-wait world packet.
No fixture retarget needed: 33.35 accepts the narrower opening/final windows; 27.90 still gets two early siren throbs in five seconds.
DESIGN watch line is included verbatim in the draft why text, which the queue writes to DESIGN.md: the extract is quiet in the middle of the wait but still pulls enemies
Still required from lane: browser preflight, ship, unchanged seed 4242 fingerprint and ON HIS PC line. A real paired-window listen and pictures from both windows remain the acceptance evidence requested by his two-player rule; this sandbox cannot launch those windows. No player-visible layout/text changed, so no UI critic or camera restyle is needed.

--- codex run 2026-10-28 22:18 ---
2026-10-28 - Completion
Lane confirmed cw-cx-extractquiet SHIPPED as v36.24, commit 63203dacf, and ON HIS PC v36.24 after 62 seconds. Confirmed the refreshed master contains the 3-second gate, regression check 36.24, and the exact DESIGN watch line. The shipped regression covers both seat roles, mute, a mid-wait player-2 snapshot and continuous enemy pull. No further code is needed. The paired-window listening/picture handoff from the previous run remains a coordinator playtest watch; this run makes no claim to have opened or listened to either window. Delivery finish line (shipped and ON HIS PC) is met.
