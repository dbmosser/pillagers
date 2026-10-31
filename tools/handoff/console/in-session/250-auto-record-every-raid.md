# 250 auto-record-every-raid : his PC records every raid by itself, and the idle screen plays them
model: opus
HIS ORDER 10-31 ~04:40 (to the CEO chat, verbatim): "can you please set up the main pc to just record all my in-raid gameplay and use that as the idle screen? I cant be bothered to remember to click record each time"
PARTY TONIGHT: this must be ON HIS PC before the 12:00 party freeze, or it waits until Sunday. The frame rate during the party matters more than this feature.

What is on HEAD (v36.66), dark_raiders.html:
- THE RECORDER ~53190 to 53290 (v36.59 to v36.61): F9 starts; recording runs to the run end (30 min safety stop REC.max). recStop ~53257; recSave ~53271 keeps each clip in IndexedDB 'pillagers-attract' under clip-<time> and also fires a download. videoBitsPerSecond 3500000 ~53244; the codec is the first of vp9, vp8, webm.
- ATTRACT ~53014 (attClipList): idle 30 s on the title or in the hub plays every clip, newest first.
- DEV_LOCAL ~12176 (true on his localhost copies).
Build:
1. AUTO RECORD: a Settings row "record every raid" (lower case, on or off). It defaults ON when DEV_LOCAL (his PCs) and OFF elsewhere (itch). Store it in the profile settings with a safe default for old saves; the storage key salvagerun:profile is unchanged. When on, recording starts by itself at the moment the raid starts (career and the party demo), in player 1's window only (never the player 2 window, never two recorders at once), and stops and saves at the run end as now. F9 still works by hand.
2. NO DOWNLOADS from auto recordings (Chrome blocks them anyway); keep the clip in IndexedDB only. A manual F9 stop may still download.
3. SKIP SHORT RUNS: a run under 60 s (a quick death, a test) is not saved.
4. KEEP THE STORE SMALL: keep at most the newest 15 clips and at most 3 GB in total; prune the oldest after each save. His old 'main' clip goes last.
5. FRAME RATE FIRST: prefer a hardware codec. Try 'video/mp4;codecs=avc1.640028', then 'video/webm;codecs=h264', then vp8 (vp9 last: it is the most expensive in software). Target 2.5 Mbps at 30 fps, composed at 1600 wide at most. Measure the raid frame time with recording on and off (his DRS chases a cap above 60; see memory pillagers-drs-chases-cap). If recording costs more than 1.5 ms a frame, record at 1280 wide and 24 fps. Report the before and after numbers in the ship note.
6. The REC mark for an auto recording is a small dim "rec" dot, not the big red badge (it is a page element and never in the clip).
Check (must FAIL on v36.66): with the setting on under a DEV_LOCAL fixture, starting a raid starts REC with no key press; extract saves one clip and fires no download; a 40 s run saves none; a 16th clip prunes the oldest.
Rules: render and HUD only, no sim; seed 4242 fingerprint; both windows (P2 never records); never the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "your raids now record themselves; watch the frame rate". Ship through the ship queue like any lane (RULES.md "How a change ships").
TASK DONE when it is ON HIS PC (the ON HIS PC line).
