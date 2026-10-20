# 44-camera-closer : camera 30 percent closer (art survey a36 C, his pick)

- The default camera zoom becomes 1.3 (spec: __setZoom(1.3)) in raids, for both players, solo and two-player, demo and career. If Settings has a zoom row, 1.3 becomes its default, and his own saved setting is left alone.
- Measure, and write in your notes, at 1920x1080 and 3840x2160: how many world units show across and up and down at 1.3, against how far a pillager bot will fire (the 600-unit rule) and the machines' ranges. If anything that can hurt you can now fire from off screen, do NOT change any range. Put the numbers in your notes and in questions.md for the coordinator.
- Check that the HUD, the map, the minimap, the extraction marker and the off-screen arrows still work at 1.3. Retarget, through the queue, any check or screenshot staging that assumed zoom 1.0.
- Keep it to one small ship, so it is easy to undo.

## How
- Each pick has its exact spec in tools/handoff/art-survey/survey.json (question id, then options[key].spec). Build it as written unless the notes here say otherwise. tools/handoff/art-survey/answers.md has his words and the coordinator's calls.
- The look to match: tools/handoff/art-survey/img/<id>-<key>.jpg (lower case key; the "a" picture is today). Motion picks have clips in art-survey/snip/<id>-<key>.html.
- Take before and after pictures of the same scene at 1080. Look at them (Read shows pictures) and fix what looks wrong. The critic (tools/console-sdk/critic.mjs) is for screens and is optional here.
- One ship per task through the queue, with a check that fails on the old build. The fingerprint must not change: these are drawing changes only, so add no random rolls to the map build or spawns.
- Frame cost: 60 fps at 4K is the bar. Measure the frame time before and after with two players on screen, and note both numbers.

Coordinator note 2026-10-19 13:45: SHIPPED v31.85 (camera 1.3). Left, lane-side only: run .codex-work/o-04-camera-closer/camera-run-request.json (both-window pictures, 4K frame times). Do not rebuild.

Coordinator note 10-20 00:20: back in tasks/ for the lane-side step it waited for. The lane now photographs camera-recipes.json itself (first 6 screens, critic on each) and sends you the pictures; the first pass spends no Codex run. Already shipped (do not ship again): cw-cx-camera130 . Review the pictures and the critic: end TASK DONE if they hold, or fix P0/P1 findings with a NEW key.

Coordinator note 10-20 02:00: the shipped camera change needs only its two-window pictures. Codex found the camera browser blocks the second window (window.open without a gesture). uishots.ps1 now has -NoPopupBlock; the coordinator runs camera-recipes.json with it (out: notes/shots/o-04-camera-closer-pair) and closes the job after looking at the pictures. Parked in waiting/ (no Codex runs).

Coordinator note 10-20 02:25: CLOSED as done. With uishots -NoPopupBlock the second window opens: camera-career-p1 staged (camera target 1.3, eased 1.3, player 2 joined the party), picture notes/shots/o-04-camera-closer-pair/camera-career-p1-1080.jpg looks right. The other three (career p2, demo p1, demo p2) stopped in the recipe with "host did not link the existing p2 window" and "both real windows did not link": the pair link inside one headless camera, not the game. The closer camera is a feel change: his next playtest judges it. Seen in passing: the teammate still reads "pillager" (helper-fixes 31, G9), and "pillager joined your party." is a sentence with a full stop.
