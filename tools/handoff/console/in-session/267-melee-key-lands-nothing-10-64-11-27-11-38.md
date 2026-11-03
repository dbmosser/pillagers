STATUS 11-03 00:06 (CEO chat): the game is fine, the tests pressed the old key. Fixture 8a954a526 fixed them; 10.64, 11.27, 11.38 passed on the spare PC (cw-s267, cw-t267, read by the CEO chat). STILL TO DO, so this stays here: read those three and 25.67 in the first full run whose test copy holds 8a954a526 (not corpus-1102-2152), then take v25.67 out of tools/handoff/stable-known-red.txt and move this to done/. Not looked into: a swing does 43 though a game comment says the crowbar does 18.

# 267-melee-key-lands-nothing-10-64-11-27-11-38 : three checks say the melee swing does nothing in a staged raid (full runs corpus-1102-0048 and corpus-1102-0552, v37.39)
Queue (known-red triage 11-02). Treat as a possible REAL BUG until proved otherwise: three separate checks agree. Cause not found.
effort: medium (read-only first)

What fails, all through the melee key (V, __meleeKey()) in a raid built by __deploy or __startRaid on seed 4242 map 0:
- v10.64 "with a rifle in hand, F did not strike a body at arm's length; the cooldown case did not land its first blow" (tools/mkfixture.ps1 about line 110790). Its other lines (no ammo spent, reach, controls list) are quiet.
- v11.27 "F did not swing: melee count 0 to 0" (about line 107120): g.tel.melee does not rise after the key. Its control (down, F revives) passes, so the raid and the key path exist.
- v11.38 "control: a melee swing next to a hostile pillager left his health at 172" (about line 106773): the strike no longer lands, so the merc result proves nothing.
Green in corpus-1101-1520 (v37.17), red in both later full runs. meleeStrike (dark_raiders.html about line 26544) returns false for G.sim, G.trade, a downed or dying or rolling player, G.searching, p.cooking, a swing inside the fists rof, and raidKey drops every key while pauseOpen or the map-first hold (about lines 19516 to 19525) is on. A diff of the game from v37.17 to v37.39 shows no change in meleeStrike, the V line (about 19648) or raidKey; the only melee-adjacent edit is the kill feed icon (v37.28, cw-feedicon, fireWeapon about line 26739: blowEl, blowG), which looks sound.

Do: run the three alone on v37.17 and v37.39 (spare PC), then in a slice after the earlier checks. Log pauseOpen, mapFirst state, G.paused, G.searching, p.roll, the modal list (.modal.on) and meleeStrike's return right after the key. If it passes alone and fails in a slice it is a leaked state (a pause box, a window such as #birthmodal from job 266, or the map-first hold): fix the fixture and say so. If it fails alone on v37.39, find the build and fix the game: the swing must land. 
Rules: through shipq for a game change, fixq for tests only; seed 4242 fingerprint holds; never touch the pickup stack, loot sounds or loot rows. He should watch (game fix only): V swings the crowbar, hurts a pillager in reach, bare hands too.
TASK DONE when 10.64, 11.27 and 11.38 pass on the current build in a full run.
