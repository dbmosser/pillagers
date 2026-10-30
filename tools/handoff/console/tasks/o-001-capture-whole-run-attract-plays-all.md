# o-001 capture-whole-run-attract-plays-all : F9 records the whole run, and an idle game plays every capture
HIS ORDER 10-30 ~13:30 (to the CEO chat, verbatim): "i just made some 3 min captures.  change the video capture to capture the entire run once turned on, and then update the game to play through all the captures during the party if the game is afk"
Party matters: this must be ON HIS PC before the Sat 10/31 12:00 party freeze. It goes first in line.

What is on HEAD (dark_raiders.html):
- THE RECORDER ~53000: REC={...,max:180}; F9 starts, F9 stops, and it stops by itself after REC.max seconds; the REC mark shows m:ss / 3:00. recSave stores the blob in IndexedDB 'pillagers-attract' store 'clips' under the ONE key 'main', so every new capture REPLACES the last, and a copy downloads as pillagers-attract.webm.
- ATTRACT MODE ~52914: ATTRACT_IDLE=30; only on the title (attTitleUp); it plays ONE clip on loop (the 'main' clip, else attract.mp4 / attract.webm beside the game file). The party arcade has its own arcadeAttTick.
Build:
1. WHOLE RUN: once F9 turns recording on, it records until the run ends (extract, death, abandon, the run over card), then saves by itself. F9 still stops it early. No 3:00 cap; keep a 30 minute safety stop. The REC mark shows only the running time (m:ss). Recording keeps going through a pause, the map and the backpack (page menus are not in the clip, as now).
2. KEEP EVERY CAPTURE: store each clip under its own key (clip-<time>). The old 'main' key counts as the oldest clip. The download gets a unique name: pillagers-attract-<yyyymmdd-hhmm>.webm.
3. PLAY ALL WHEN AFK: after ATTRACT_IDLE seconds with no input, the attract overlay plays every capture back to back (newest first), then starts the list again. It plays on the title AND in the undercroft hub, and in the party arcade's idle beat if that has none of its own. Never in a raid; never while a text box has focus (the party invite and reply code boxes) or the fullscreen gate is up. Any key, click, mouse move over 12 px or pad input stops it, and that press does nothing else (as now).
4. CLIPS ON DISK TOO: also play every file listed in attract/list.json beside the game file, a JSON array of file names in attract/. A missing or bad list is ignored without an error. Skip a listed file whose byte size equals a browser-kept clip, so the same capture never plays twice. attract.mp4 / attract.webm stay as before.
5. A clip that fails to load is skipped; the overlay never shows a black screen.
6. Player text, lower case: the mark reads "rec 0:42"; the overlay keeps "pillagers" and "press any key" / "press any button".
Check (must FAIL on the current build):
- REC.max is not the stop: a fake clock past 180 s while recording is still recording, and an extract then saves.
- Two saved clips both exist in the store.
- Idle 30 s in the hub with two clips makes the overlay play clip 1, then clip 2 on its 'ended' event.
- A key stops it.
Old checks about the 3 minute stop or the single 'main' clip: retarget them to his new order and list them in the ship note.
Rules: render and HUD only, no sim; seed 4242 fingerprint; never the pickup stack, loot sounds or loot rows; storage key salvagerun:profile untouched (the clips live in their own IndexedDB). DESIGN.md watch line: "f9 now records your whole run; when nobody touches the game it plays all your recordings". Model: Codex high.
TASK DONE when it is shipped and ON HIS PC.
