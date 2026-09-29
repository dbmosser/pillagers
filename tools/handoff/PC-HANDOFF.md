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

## PLAYTEST QUEUE (2026-09-27 afternoon, see memory pillagers-playtest-2026-09-27)
Shipped 16.72-16.76. Generated, not shipped: p1677 crosshair, p1678 alarm quarter (+check 16.30 retarget), p1679 backpack on a
pad. Reviewed drafts in tools/handoff/drafts (*-2026-09-27.json; generate with drafts/gen-draft.ps1 -Key after copying to the
scratchpad as draft-KEY.json): autofire (renumber from 16.76), p2-saves. Drafting when stopped or pending: stash-pad, y-heal,
pad-liveness, downed-extract; kit-options (random loadout / top gear) was stopped for budget, redo solo. Still to write:
sprint takes the player out of focus aim. BUDGET: weekly all-models must stay at or under 20% (RULEBOOK rule 21).

## STOPPED 2026-09-27 15:37 AT v16.82 FOR HIS BUDGET (weekly all-models 19%, his cap 20% until ~08:00 2026-09-28)
Shipped this afternoon: 16.72 layout, 16.73 kid 1/20, 16.74 host out wording, 16.75 Superhot shared + clock, 16.76 pause hum,
16.77 crosshair, 16.78 alarms quarter, 16.79 backpack on a pad (raid), 16.80 pad follows its window, 16.81 sprint drops focus
aim, 16.82 player 2 sees only its own save. NEXT (drafts in tools/handoff/drafts): kid firing = autofire draft PLUS his rule:
no auto-fire while player 2 moves the right stick himself, and player 2 turns it on in his own window; Y heal = y-heal draft
PLUS his rule: only with a Bandage, Medkit or armour plate SELECTED on the tactical belt (use that item); stash-pad (review not
ok, read it); downed-extract (review: edit 2 breaks check 15.79, fix before use); kit options random/top gear (redo solo).
Asked him: is the 125% menu zoom Chrome own zoom? (game menus already default to 130%). Gave him the AAA gap list.

## STOPPED AGAIN 2026-09-27 16:25 AT v16.86 (weekly all-models reads 19%; his cap 20% to ~08:00 2026-09-28)
Shipped since 15:37: 16.83 kid firing (P2 row, right stick takes over), 16.84 hold Y / T heals a teammate with the item
selected on the tactical belt only, 16.85 stash screen on a pad (A grab, D-pad, A place, B lets go), 16.86 a teammate who has
left is never waited for (a narrow fix; his downed-extract report may instead be keyboard focus on the P2 window: asked him).
LEFT: kit options random from stash / top gear (redo solo); his 125% zoom question; his downed-extract answer.

## 2026-09-28 10:50: v16.87 TOP GEAR and RANDOM FROM STASH at the kit question; v16.88 card refresh (his playtest line).
His explicit asks are all shipped. Waiting on him: is his 125% zoom Chrome own zoom; was his downed-extract E going to the
player 2 window (keyboard focus). Weekly all-models read 21% this morning. Next idle work: the full corpus in four headless
Chromes (tools/cdp.ps1, one per port 9336-9339) on v16.88, then the stale checks it shows.

## 2026-09-28 afternoon: v16.89 the keyboard always drives player 1 on one PC (likeliest cause of his downed-extract report);
v16.90 comment wording (9.59); v16.91 party code boxes in the game font (11.09). Tests retargeted: 16.44 (kid 1/20), 16.15
(host is out wording), 16.89 presses keys on the body; nettest pad release 800 ms. Full sweep on v16.88: newest 200 and
oldest 216 done, every red fixed; the 400-600 part hangs for hours in one long simulation (look at it: which check).
4K MEASURED ON HIS GPU (item g): RX 7900 XTX, headless Chrome 3806x2055, solo raid seed 4242: 60 fps locked, avg 16.7 ms,
p95 16.8 ms. The layer cap draft is not needed; item g closed unless he reports slow frames (then measure two windows).

## 2026-09-28 evening (he is away 3-4 h, ultracode on): v16.92-v17.00, NINE CO-OP FIXES from an agent bug hunt.
Hunt: 5 readers on the co-op code, a skeptic per finding (14 held). Drafts: tools/handoff/drafts/draft-<key>.json, each
reviewed by a second agent and checked by drafts/validate-draft.ps1 (applies a draft to an in-memory copy; writes nothing);
gen-draft.ps1 now reads the now text from the draft. Shipped with the strict chain (scratchpad shipone.sh: gen, dryrun, gate
parse + new check PASS/PASS on dry + FAIL on control, start, -Fix gate + fingerprint 85/374 165/593, commit, push):
16.92 keys held in the P2 window let go on blur/pagehide; 16.93 ESC/TAB that shuts the P2 pause box is not handed to P1;
16.94 a teammate whose raid ended while down no longer takes E in the ring; 16.95 a refusal at a held box lets go of the old
box; 16.96 a teammate search stands still while the party is paused; 16.97 P2 search bar counts the host box; 16.98 rounds and
charges pass a bled-out body (kill mark kept); 16.99 a pick-up clears the seat kill mark; 17.00 pad X after a pad gap, another
screen or a roll searches instead of reloading. NOT DONE (need his word or low value): P2 payout uses P2 own saved terms and
hire, not the host's (design); the focus-loss rescue closes a backpack opened by pad/forwarded keys (medium).
nettest.html: the soak keeps both players alive (and the shots step), no Start/Back on the random pad, clearFloor presses
Resume, a stray counted hit tries the next body, richer failure logs. Last 12 soak sessions on v16.91 all passed.
Suite: shard.html shows progress in the page title (a busy page cannot answer cdp); the middle of the corpus holds checks
that run for many minutes (slow, not hung). Eight shards now (9336-9343 on 8804-8807, 8811-8814).

## 2026-09-28 night: v17.01-v17.14. Second co-op hunt (6 areas, 12 held), drafted and shipped the same way.
17.01 a focus change keeps a same-machine backpack open (pad drag kept, mouse drag dropped); 17.02 kid mode 1/20 really
applies (and the Settings row); 17.03 letting go of the right stick ends aiming (Superhot time stops, kid firing returns);
17.04 a downed pad player calls the extraction with X; 17.05 going down or rolling stops a teammate pick-up; 17.06 a host
armoury gun picked up by P2 is not in both saves; 17.07 a loaner Bandage stays a loaner between teammates; 17.08 a heal
given to a teammate already healing comes back; 17.09 WHAT IS NEW card refresh (parse gate refuses a card 0.21 behind);
17.10 a heal the teammate could not take comes back; 17.11/17.12 kills after a run ended leave the saved run alone;
17.13 a spectating host hears no raid in his Undercroft; 17.14 a P2 window on its title goes up with the party.
LESSONS: drafts from different groups can touch the same lines (17.07 moved an anchor of 17.10): validate every queued
draft with -After the whole chain before starting it. The gate ran only the new check and v17.00 broke check 16.72 (a
check-side staging issue: the roll was never ended); tools/handoff/shipone.sh now runs recent.ps1 (the newest 80 checks
by version on dry and control, stop on any new failure). __REGRESS is NOT in version order: pick checks by parseFloat(v).
A long synchronous check loop makes the page unreachable over cdp: use rr.sh (one check per timeout, progress in the title).
Tools saved here: shipone.sh KEY PREV NEW (Chrome 9344 on :8806), recent.ps1, rr.sh MINV, soakloop.ps1 -Cdp -Port,
sweep8.ps1 + watchshards.sh (eight shards 9336-9343, servers 8804-8807 and 8811-8814), drafts/validate-draft.ps1.
All 75 checks from v16.40 up pass on v17.14. Soak on a loaded PC showed 1-2 fps seconds: rerun alone to separate load.
LEFT FOR HIM: P2 payout uses P2 own saved terms and hire (design); his 125% zoom question.

## 2026-09-28 late: v17.15-v17.24, third hunt (menus, stash, belt, shop, saves; 10 held), shipped with recent.ps1 in the chain.
17.15 a plain click on an armoury gun no longer moves it to the stash; 17.16 a pad can put a gun in gun 1/2 or take it out
on the stash screen (A, A on an armoury gun opens the gun menu); 17.17 an item on belt key 1 no longer buries the gun; 17.18
dragging a belt key holding a backpack gun no longer swaps the gun in hand; 17.19 ESC/TAB on Settings in a raid shuts
Settings, not the pause box; 17.20 a held ESC/TAB on the kit question no longer shuts the sector page; 17.21 a hire is spent
at the lift (no free redeploy after a refresh); 17.22 a guest keeps his own hire through a party raid; 17.23 the host-abandon
path of the gun copy; 17.24 two tabs on one save no longer wipe each other. The rack-click check first SKIPped on both builds
(it tested the drop zone before entering the Undercroft): a reviewer without a browser cannot see a SKIP; the gate did.
Weekly all-models read 31% at 23:50 (21% that morning): the agent teams cost ~10% in one evening. He asked whether I was
still token-lean; I said no, and asked whether to go lean after these ten. Until he answers: no new agent teams.
