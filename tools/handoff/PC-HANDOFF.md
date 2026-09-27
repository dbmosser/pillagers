# PC HANDOFF (2026-09-27, cloud session to his PC, at v16.47)

You are taking over PILLAGERS on Daniel's PC from a cloud session. Read this file, then tools/handoff/CLOUD-BRIEF.md in full.
The brief holds his binding rules (frozen numbers, TXSHIP keys, retired words, co-op rulings, BUDGETS). They all still bind.

## Where things stand
- Game: dark_raiders.html at v16.47 (commit 3e099b5), all pushed to origin master. VER and WHATSNEW_VER in the file; the
  changelog is DESIGN.md, one row per build in AUDIT.md.
- Every build since v15.85 passed its own new check twice on the dry build, FAILED on the build before, and kept the seed
  4242 fingerprint (ents {0:85,1:374}, containers {0:165,1:593}). Checks 8.61, 8.96 and 9.32 fail on old builds too (not ours).
- Live two window test (tools/nettest.html, RUN SAME MACHINE) passed at v16.46 covering: link, controller hand-over, sound,
  ascend together with the kit card on player 2, enemies shared, loot per player, player 2 shooting host bodies (hits, damage,
  kill credit), kill feed, ping, map marker, host spectating, party summary on both run cards.
- The cloud hourly routine is PAUSED so two sessions never push at once. Do not turn it back on from here.

## His rules that matter most this week
- BUDGETS: he is on his weekly Claude allocation, cap 10% of the week per 24 hours. A cap means work lean, NEVER slow down or
  stop substantive progress. Targeted greps and small reads; no workflows or subagents unless he asks; one live test per
  co-op build; short reports with a play link (rawcdn.githack.com/dbmosser/pillagers/<commit>/dark_raiders.html).
- Never stop working the queue. Do not ask him to confirm what his rules already decide (player 2 equals player 1).
- Push to origin master after every ship. The itch push (butler) is his PC's job and only with his key.

## Ship flow on this PC (Windows PowerShell 5.1)
Each build NNNN has pNNNN.ps1, fNNNN.ps1, dNNNN.txt, aNNNN.txt, cmNNNN.txt in tools/handoff (see 'Ship flow' in the brief):
1. powershell -File tools/handoff/dryrun.ps1 -Prev PREV -New NEW
2. parsecheck.html?f=fxdryNN.html reads PASS; the new check PASSES twice on fxdryNN and FAILS on fxctlNN.
3. bash tools/handoff/ship.sh start PREV NEW
4. fixture.html: new check passes twice; __verifySafe() pass with the fingerprint above.
5. bash tools/handoff/ship.sh commit NEW cmNEW.txt, then git push origin master.
The cloud wrote pNNNN/fNNNN with Python generators (tools/cloud/bNNNN.py + gen.py); those run on Windows too with Python 3
(set gen.H to the handoff folder if the path differs). tools/cloud/*.sh and run.mjs are Linux helpers; the Windows flow above
replaces them.

## Next, in order
0. HIS ORDER 2026-09-27 09:15 EDT: GENERAL STABILITY is the focus; HARD DEADLINE 12:15 EDT (he moved it at 09:35) for a stable build he plays co-op
   with his son. No risky render or feature work before then. Deliver a play link to a build that passed: verify chain,
   full corpus (reds rerun alone), live nettest RUN SAME MACHINE, and a crash sweep. Fixes only for real crashes, dead
   controls and co-op breakage. The 4K item waits: a pane measure at 3840x2160 is not trustworthy (the emulated 4K pane
   throttles rAF to about 3 fps, and getImageData readback pushes the canvas to software; render2D + readback read 53 ms).
   STABILITY PASS 2026-09-27 (shipped, each with its own check failing on the build before): 16.48 kit wait never starts a
   raid inside a raid; 16.49 pad tap on the map shuts it; 16.50 Settings in a raid greys PICK FILE, UNDO, tuning OPEN;
   16.51 pause box shuts when a co-op raid ends under it; 16.52 pad never lands on the PARTY CONTROLLER row or END THE PARTY;
   16.53 searches run while the host spectates; 16.54 card refresh plus stale checks retargeted; 16.55 a teammate on the
   run card goes up with the party; 16.56 a spectating host has no body; 16.57 a paused party is paused while the host
   spectates; 16.58 B backs out of map, backpack and stall; 16.59 a spectate fault goes to the run report; 16.60 every run
   report says Window: player 1 or player 2 (collector names files -fff and -p2); 16.61 ping twice marks danger;
   16.62 player 2 cannot revive a host-run pillager copy (gun duplicate); 16.63 spectating host takes no damage at all;
   16.64 spectating host still hosting (leave warning, Settings grey); 16.65 three player-text lines (PARTY subtitle,
   RACKS not WARDROBE, kit line); 16.66 B never closes a hidden floor backpack in a raid; 16.67 player 2 keeps hearing
   enemies after the host leaves his card; 16.68 a pick-up is called revived only once it took; 16.69 nothing open in the
   Undercroft rides up; 16.70 NET.up ages while the host spectates from the Undercroft; 16.71 card refresh. FROZEN at
   16.71 for his 12:15 session. Found by three workflows (review of my builds: 0 confirmed; hunt: 3 confirmed; drafts).
   PLAYTEST PHASE (14:00 on, he plays and sends notes; the session moved to Fable, budget 15% of the weekly Fable bucket):
   16.72 his controller layout for both players (memory pillagers-controller-layout-2026-09-27 holds it), 16.73 kid mode
   1/20. Drafting workflow (draft-playtest-fixes) covers: Superhot shared from the host plus the extraction clock frozen
   with time; backpack on a pad (A picks, D-pad moves, A places); pause noises; always-on crosshair with a trail; the
   5 minute alarm quieter; Host has left the raid wording (also update tools/nettest.html line ~705 /host has left/).
   HIS RULING: always seeing the other player and their shots through walls stays.
   NEXT after his session: tools/handoff/drafts/p2-equip-2026-09-27.json (a pad cannot equip a gun from the stash; a
   reviewed 6-edit draft, review said not ok as is: re-review before use; generate with drafts/gen-draft.ps1 -Key after
   copying the json to the scratchpad as draft-KEY.json); check 16.59 is order-sensitive in a batch (its P0 profile handle
   is taken before __runPrep); split review items: pause note not banked at G.over (12448), netSpecTick noteCrash with G
   swapped, tuning console hotkey in a raid, PAD.on left by checks 16.49/16.58.
   HIS PLAY SETUP (his order 10:20): he plays co-op on http://localhost:8802/dark_raiders.html (his saves; no-store, so a
   refresh loads the newest build), two windows through the mode menu; both windows post run reports to the collector on
   :8799 into exports/ (run-...-p2.txt is player 2). tools/watch-exports.ps1 in the background wakes the session on each
   new report. While he plays, do NOT apply builds to dark_raiders.html (the play port serves the working tree): draft and
   dry-run only, apply after he stops. Found by three read-only review agents; open leftovers: END THE
   PARTY in the P1 window hands the kid pad to P1 (netSameStop at ~35050); a P2 window hidden ~4.5 s while the host is on
   his card is abandoned (netUpShown age test in the spectate counts); a late fast-channel state word can resurrect an up
   entry after out/spec; netSpecTick swallows errors silently (route to noteCrash); danger double ping never fires
   (netPingMake 500 ms test runs before the 400 ms double test); padOpenModal checks #pausebox before #outcome.
   TOOLS ADDED: tools/cdp.ps1 (headless Chrome on this PC, -Start/-Open/-Expr; the Browser pane throttles when hidden, so
   use this), tools/gate.ps1 (-NN -V dry gates; -Fix for fixture.html + fingerprint), nettest.html ?soak=N (random input
   in both windows, errors, drops and a message trace). Run ONE nettest tab at a time and nothing else: background tabs in
   headless Chrome starve of frames and every step fails (0 to 1 frames a second).
1. Frame rate at 4K (item g in the brief). Measure first, on this PC's real GPU: node tools/cloud/prof.mjs fixture.html 3840 2160
   (needs Node and Playwright; serves the repo itself). Then try the drafted layer cap (tools/cloud/b1647.py at commit 45e580e:
   fog and light layers capped at 1920 wide and stretched). Ship only if frames get faster here; headless software raster
   measured it slower, which a GPU should reverse. Then look for the next biggest pass the same way.
2. Host migration (item d): the warning shipped at v16.38; player 2 taking over as host is the remaining piece. Break it into
   small shippable steps (first: when the host link drops mid raid, player 2 keeps the surface running as spectator-safe
   instead of ABANDON, behind a check), each with a live test.
3. Player 2 face blocked in the Undercroft (item e): needs his screenshot; ask him once, then move on.
4. Keep combing for player 2 parity gaps: anything player 1 sees, hears or can do that player 2 cannot.
