# 186b-quiet-hud-panels : the quiet hud, part B: one money number, hide what is at rest, gun name once
Queue: his order 10-27 ~20:20 in chat (verbatim): "build the quiet hud, all 5 changes". Polish of what exists, allowed before 11/1.
Part A (186a, another session at the same time) does the text lanes (no double lines, concealed icon, extraction word). Touch only the panels below.
effort: high
Worked in: a Claude session started from his orders thread. Lanes skip in-session/.

The quiet hud he picked has 4 places: top centre (clock, extract distance, one alert), left feed, right stack (pickups only), bottom strip (health left, belt middle, ammo and backpack value right).

Part B, his changes 2, 3 and 4 (see tools/handoff/shots recipes 21, 33, 34, 50 for today's look):
2. One money number. The backpack value shows only on the ammo card (bottom right, "b/i backpack 5 items $1,770"). The top-right card (cash, stash, xp, backpack) is not drawn in a raid; the run info / run goals card moves up into its place. Keep the pillager board ("you $1,770" is a ranking). If the forge or the pedlar needs a balance, it shows on that screen while it is open.
3. Things at rest hide. The stance word ("standing") shows only when crouched or down. The stamina bar shows only when stamina is not full (fade, no pop). The contracts / run goals card folds to one line ("contracts 1/3", arcade "goals 0/3") and opens for a few seconds when one of them changes, then folds again; its fold arrow still opens it for good. Drop at-rest filler lines such as "no elite killed yet".
4. The gun name shows once: the label over the belt ("scav pistol fire use") goes; the ammo card names the gun. Keep anything that label carried that exists nowhere else (the fire key hint for an item in hand is drawn by drawHand, keep that).

Checks (each must FAIL on v35.25): the top-right money card draws nothing in a raid and the backpack value draws once; at full stamina standing still no stance word and no stamina bar; crouched the stance word shows; the contracts card is one line at rest and opens when a contract moves; the belt label is gone and the ammo card still names the gun. Old checks that test these panels: re-aim them through fixq (RULES.md step 8) so they prove the new rule; never loosen one just to pass.
Pictures: uishots screens 21, 33, 34, 50 at 1080, look at them, and send the 33 picture to him (SendUserFile) with one line.
Ship: preflight on lane f (check no other preflight runs on f first), then shipq. Rules: player text lower case, short; HUD layer only; no storage key change; seed fingerprint unchanged.
TASK DONE when shipped and his main PC reports the build (git show origin/spare-results:spare/JUL26/status.txt, game=VER). Then move this file to console/done/ and report one line: build, on his PC, what to watch for (stamina and stance appear only when they matter; money only by the ammo).
