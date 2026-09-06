
## STILL OPEN, found 2026-09-06 (read-only menu and save audit, 14 agents, 27 raw findings, top 8 refute-tested, 5 confirmed)

The Undercroft, the stash and item menus, the staging screen, the save, the
shops, and the first evening of a brand-new player. Line numbers are as read at
v11.56. Each line survived a skeptic whose brief was to kill it; where the
skeptic corrected the severity or the consequence, the corrected version is what
is written here. This is the standing ship blocker region.

- P1 THE UNDERCROFT HUD IS PAINTED AND THEN ERASED IN THE SAME FRAME (27702). drawHubWorld ends by calling drawHubHUD, which paints the floor heading, the stash and runs line, the "[E] STATION" prompt and its key list, the H CONTROLS panel, the NEW IN card and the line that teaches WASD, SHIFT and E; v8.95's clear sits BELOW that call and wipes all of it every frame, repainting only the belt. So the floor has no screen furniture at all, H is a dead key, and since the v10.88 briefing card was deleted there is no on-screen teaching of the floor controls. The project's own "0 opaque pixels on the entire HUD canvas" note recorded this and read it as a fact about the floor. SHIPPING as v11.58.
- P2 THE FLOOR KEEPS TAKING KEYS BEHIND THE CHARACTER SCREEN (26965). #title is a .screen and not a .modal, so hubModalOpen returns false while the character-selection screen is up and the floor keeps running: WASD walks (harmless, the arrival resets it), but E, R, F and T still fire the station you were standing in. At the lift, R runs commitKit() and startRaid(), dropping you into a live raid with the title screen painted over it and the clock running. FIX: one line in hubModalOpen returning true while #title is on.
- P1 THE SAFE POCKET CANNOT BRING HOME A THROWABLE OR AN AMMO BOX, BUT READS 1/1 (29002). Raised independently by two regions. setSafe refuses a gun and accepts a Frag Charge, a Smoke, a Decoy or an Ammo Box, but those live in the pouch and the reserve, not the backpack, so the death path cannot bank them. Because CFG.safeSlots has been 0 for everyone since v5.32, the named pocket is the ONLY thing that survives death, so naming a grenade silently spends the player's single death protection on nothing for that whole raid while the ascent screen tells him he is covered. FIX: refuse use 'throw' and 'ammo' in setSafe the way a gun is refused, and clear an already-saved bad P.safe on load.
- P1 A FRESH PROFILE HAS NO NAME, SO THE TITLE SCREEN PRINTS A BROKEN LINE (33258, default profile at 2002). The default profile literal has no pname, and the character screen prints it. Same class as the dayMigrated hole v8.44 closed three lines above it. This is the FIRST thing a new player sees on alpha day. FIX: add pname:'PILLAGER' to the default profile literal.
- P1 TAKE THE FREEBIE KIT WIPES THE BACKPACK AND THE WHOLE BELT PLAN, WITH NO UNDO (18097, 32255). Taking the free kit destroys everything already packed out of the stash and the belt plan with it, with no confirmation and no restore; a related path makes the Stash panel inert, sell button included, after the kit is taken. On the alpha path a new player is very likely to press it after packing. FIX: in the audit output; needs one build of its own.

NOT VERIFIED THIS RUN: 19 further raw findings from the same six regions were
never refute-tested and are NOT recorded here as findings. They are in the run
output at tasks/wql3h8913.output; treat any of them as a lead, not a fact.
