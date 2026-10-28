# 187-title-plain-backdrop : nothing drawn behind the title screen, and no robots in the Undercroft
Queue: his order 10-27 ~20:30 in chat (verbatim): "get rid of the graphics behind the title screen -- they make no sens,e, there are robots inside the undercroft??? that should never happen". Fix and polish, allowed before 11/1.
effort: medium
Worked in: a Claude session started from his orders thread. Lanes skip in-session/.

Where: since v17.83 (dark_raiders.html ~51294, "THE UNDERCROFT SHOWS THROUGH THE TITLE") the Undercroft floor is built while the title is up and drawn under it (titleSceneReady, called ~54242 and ~61448), with a dark glass over it (CSS #title.on, cw-title-scrim ~1473). That was my visual pass, not his order, so it is reversed.
1. The title sits on a plain backdrop: stop drawing the floor under the title (and building it only for that). Use a dark backdrop in the menu style (the same palette the other menus use); no people, no machines, no floor. Keep the title itself, its buttons, the What's New card and the 2 player demo row exactly as they are. Keep attract mode (the recorded clip after 30 s idle) as it is.
2. Find what he saw as robots: take a picture of the title (uishots screen 01 or the title recipe) on v35.28 first and name what they were (machine sprites, android outfits on milling figures, something else). Then check the real Undercroft floor after ENTER THE UNDERCROFT: if any machine or robot can appear there, remove it too. Pillagers in android or trooper outfits are cosmetics he chose (10-20 dress-up) and stay, unless they are what read as robots on the title; say which in the report.
Checks (must FAIL on v35.28): with the title up, no hub floor, figure or machine is drawn under it; entering the Undercroft still builds and draws the floor as before (control).
Pictures: the title at 1080 and 4K before and after, and the Undercroft floor; look at them; send him the after title picture (SendUserFile) with one line.
Ship: preflight on lane e (check no other preflight runs on e first), then shipq. Rules: player text lower case; no storage key change; seed fingerprint unchanged.
TASK DONE when shipped and his main PC reports the build (git show origin/spare-results:spare/JUL26/status.txt, game=VER). Then move this file to console/done/ and report one line: build, on his PC, what the robots were.
