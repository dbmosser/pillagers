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

## NEXT UP (kept current; the hourly watchdog reads this when nobody is working)
1. SHELVED (2026-09-29, waiting on his word): the local model scan. On Windows with his AMD card Ollama keeps a copy of the model in system RAM (32b: about 23 GB, near-freeze; 14b: 8.6 GB and still tripped the 6 GB guard) and the 14b found nothing in 16 co-op sections and gave only style notes by hand. Do not run it unless he asks. 2026-09-29 11:00, at his ask, the 32b ran (tools\localscan\load32.ps1 then scan.ps1 -Model qwen2.5-coder:32b -MinFreeMB 0 -Chunk 140 -Ctx 8192): it loads fully on the GPU but keeps an 18.6 GB private copy in RAM (under 1 GB free); 30 co-op sections, 17 flags, every one checked was a false alarm. Evening stress test: 4 h 20 min, PC stayed up at about 1 GB free (load dipped to 64 MB), 626 flags. DELETED 2026-09-29 on his word ("not worth it"); Ollama itself is still installed with no model.
2. DONE 2026-09-29: the full suite on v17.24 is clean (15.79 retargeted to v17.14; 13.23/12.94/12.80/12.79/12.74/12.21 were shard harness reds, all pass alone; 9.42 takes 20 s alone, far longer under load). Two-player soak on v17.24: 3 of 3 pass. v17.25 card line for the menu fixes. NEXT: run bash tools/handoff/overnight.sh 14400 (four loops, 6 GB RAM floor) and read SOAKFAIL lines in tools/handoff/overnight.log for the two open leads (roster drop, extra item); keep tokens low, no agent teams.
3. Waiting on him (do not decide): P2 payout uses P2 own saved terms and hire; his 125% zoom question.
LOAD RULES after the 2026-09-28 crash: keep 6 GB RAM free, at most 4 test Chromes, no big download on top of tests.

## 2026-09-29 midday: bot crash sweep, 800 full raids on v17.25, zero errors.
tools\handoff\botsweep.ps1 (the game bot, __simSeedsFull, one seed at a time, errors caught per seed, progress in the title)
and watchbots.sh. Sector 0 seeds 5000-5399: 64 extracts, 336 deaths, no error. Sector 1 seeds 6000-6399 (-Map 1): 92
extracts, 308 deaths, no error; sector 1 raids run about 1 a minute per browser (sector 0 about 25).

## 2026-09-29 afternoon: v17.26-v17.36, fourth hunt, TWO-PLAYER ONLY (his order: focus on 2-player functionality).
17.26 a kept P2 pad pick for an unplugged pad no longer hands the only pad to P1; 17.27 a pad that drops or returns no
longer moves the other player's pad; 17.28 P2 can no longer pick up or pay a pillager/survivor the host runs (copied items);
17.29 P2 smoke and decoys work on the host (netThrSend/netThrTake); 17.30 host enemies hear P2 and P2 no longer fakes a
Listener waking; 17.31 P2 shooting a peace-made pillager costs P2, not P1; 17.32 siege arrivals keep clear of every player;
17.33 after P1 is out, P2's ring gets its siege and can be called again (netSpecRings); 17.34 the kit wait no longer starts
the host raid behind the title; 17.35 picking a same-machine row again no longer reloads the live P2 window; 17.36 broken
walls, cover and glass fall in every window. All gates passed incl. recent.ps1. A solo hunt was stopped on his word.

## 2026-09-30 morning: overnight load (9 h) plus 2 h more on v17.36; he is resetting his PC.
PC stayed up all night. Soaks 129/138 overnight; bots on both sectors and 48 4K batches, zero errors. The failures were
checked in code: kill credit with no feed = a stray enemy round lands the last hit (removal precedes bullets, credit code
sound); position gap 38 vs 24 once; timeouts and a downed P2 finished off = test. TWO OPEN LEADS, need one full capture:
(a) the roster fell below two for about 2 s at 12 fps under the heaviest load and P2's raid ended (the old log cut the
status/err fields; overnight.sh now keeps 1100 chars); (b) a P2 box search landed one more item than the host listed (2 of
138): the loot failure now prints the backpack before and after and the lines read. Logs: tools/handoff/overnight-0930*.log.

## 2026-09-30: HIS PICKS FROM AAA-GAPS.md, all shipped v17.37-v17.48 (built solo, low tokens, one per build).
17.37 controller rumble (RUMBLE, padRumble; P2 buzz asked of the window that reads his pad; Settings row); 17.38 CTRL+click
packs one from the stash (SHIFT already quick-moved a stack); 12 death recap ALREADY EXISTED (HOW IT WENT on the KIA card);
17.39 co-op score screen (score word t:'sc', PARTY block on the end card); 17.40 achievements (ACHS, P.ach, Mainframe list,
retro from P.log); 17.41 card; 17.42 stash search and sort (STASH_Q, P.stashSort); 17.43 graphics options (gfxScale, fpsCap,
fxLevel rows); 17.44 trading in a raid (gift words offer/yes/give/no; T or pad Y with the bag open; item leaves only on yes);
17.45 THE OVERSEER boss (bossTick at 2 s, lair nearest the map centre, leash 1100, OVERSEER HOARD; made from fixed numbers so
the build and fingerprint are untouched); 17.46 drop-in (JOIN THE RAID IN PROGRESS; raidq -> late raid word with clock, time
left, host position and gone bodies); 17.47 hit jolts and death animations (drawing only); 17.48 card.
Known limits: the boss draws as a big warden in the P2 window (the mirror carries no size); drop-in is tested by check 17.46
in one window, not yet in the two-window nettest.

## 2026-09-30 evening (he is away 7 h, low-token polish)
- v17.49 THE OVERSEER is drawn to its size (drawWardenAt scales a warden with r>34 around its feet; both windows, r rides the new word).
- v17.50 a late teammate gets the ent 'new' words for bodies numbered after the build (NET.entBuilt), so the boss has its name, size and bar.
- v17.51 REAL BUG found by the new two-window drop-in step: #joinlate was appended to #hub (the terminal panel, hidden on the floor)
  and only drawn from netRefresh. It is now position:fixed on document.body, refreshed from showScreen, and a guest going up at the
  lift (netGuestHeld) with the host up top asks to join late, so a pad player can drop in.
- nettest.html dropStep: A goes up, C abandons, closes its card with oc_btn, presses JOIN, must be on A's seed, clock within 3 s and
  hold THE OVERSEER by name and r. It resets CFG first (the soak's random keys can switch SUPERHOT on, which stops the host clock).
  The fixture __topClear only hides the run card and keeps G; a party test must close it with oc_btn as a player does.
- overnight.sh SECS LOOPS (e.g. 18000 ABC) runs a subset; ABC leaves room for the gate Chrome under the 4-Chrome rule.
- v17.52 an open trade offer stays on screen (drawGiftLine under the boss bar: who offers what, T or Y, seconds left; giver sees who it waits on).
- v17.53 a teammate who links while the host is up top is told (welcome carries up: seed via netWelcomeUp; NET.hostSeed set, status says go up at the lift).
- v17.54 card refresh (WHATSNEW_VER 17.54, PLAYING TOGETHER, SMOOTHER). Next card refresh due by ~17.69.
- v17.55 in a party raid the backpack header says Y offer to teammate (T on keys), shorter on a narrow panel.
- v17.56 the kill feed names THE OVERSEER (e.boss), and a linked window says it is down and its hoard is open (netEntDeathFx).
- nettest.html now also has: tradeStep (A offers by T, C takes with a forwarded pad Y), reloadStep (C's iframe reloads mid-raid, relinks
  ~0.5 s, told by the welcome, ENTER THE UNDERCROFT via #titlestart, JOIN, same seed and clock). Nearby bodies hold fire (cd) while C
  shoots, so crossfire no longer reads as a lost kill. soakloop prints trade/drop/relink ms. DO NOT ship while a soak batch runs: the
  ship rebuilds fixture.html and a reloaded C comes back on the new VER, which the host rightly refuses (the step now says so).
- v17.57 a ping on THE OVERSEER names it (netPingName). v17.58 a late join takes down the walls the host already has down (m.wg,
  NET.wallN0). v17.59 a late join gets the map markers already placed.
- TOOLING: gate.ps1 leaked a tab per ship on Chrome 9344 (48 tabs, 12.8 GB, starving the 6 GB floor); fixed. soakloop.ps1 now copies
  fixture.html to fixture-soak-PORT.html per run, so shipping during a soak is safe again.
- v17.60 a stale host-up mark clears (raidno and every welcome reset NET.hostSeed). v17.61 #joinlate is 20 px with "or go up at ENTER
  RAID!". v17.62 the host reads NAME is joining the raid. v17.63 the host reads NAME is out of this raid (killed/extracted/abandoned).
  v17.64 runElapsed(): a late joiner's run length and abandon XP cost count from G.lateEl (set in netLateApply).
- nettest loot step lets E go once the listed items are in (held on, it searched the next pile: the "extra item" lead (b) was this);
  any other box opened during the hold is named. Drop-in step also takes a wall down on A first.
- OPEN QUESTION TO HIM (asked 2026-10-01): block JOIN THE RAID IN PROGRESS after dying or extracting from that raid (my suggestion:
  yes; still allowed after a closed window or a link drop). Nothing changed until he answers.
- v17.66 HIS RULING 2026-10-01: no rejoining a raid you died or extracted in (join: NET.lateBan set in netUpEnd; host: NET.lateOut[seat]
  from the out word, netLateReply answers raidno why out). Abandon, a closed window or a lost link can still rejoin. Two-window test still passes.
- v17.67 a new raid clears the sit-out marks (host netUpAnnounce: NET.lateOut={}; teammate netUpTake without m.late: NET.lateBan=0).
- nettest drop-in step now also kills C after the trade and checks no JOIN for that raid (rep.banOk, soakloop prints ban).
- 10-01/02 long runs (loop A 3 h x4, then ABC 8 h): 45/45, 44/45 (one enemy 260 units apart on C, once), 111/114 + ~270 bot batches clean.
  nettest now resets Settings and keeps both players alive through the whole raid step. OPEN LEAD: pad X at one crate near the
  start (~3050,2885, crate, 1 item) twice did not start a search on C (near box yes, ring false, X held and forwarded, got ~327).
  The pad loot report now names a stall, a peddler or a door in reach. Do not run quick checks on 9336/8804 while loop B runs.

## NEXT UP (2026-10-02 ~11:00, before he switched the model to Fable)
- Game at v17.67, all shipped and pushed. Focus: two-player same-PC co-op, low tokens, no agent teams unless he asks.
- RUNNING: tools/handoff/overnight.sh 14400 A (two-player soaks on Chrome 9335/:8809, until ~15:00, log tools/handoff/overnight.log);
  a watcher wakes on a "pad loot" or "hit none" failure. Heartbeat: tools/handoff/heartbeat.sh in the background each session.
- OPEN LEADS (both rare, both now instrumented in nettest):
  (1) pad X at one crate near the start (~3050,2885) twice did not start a search on C; the report now names stall/peddler/door.
  (2) C hit none of 6 bodies at 90 units (3 times in ~400 sessions, with no Settings moved); the report now gives C pos, face,
      angle to target, gun, canvas and frame sizes (r.diag).
  (3) once: an enemy 260 units apart between windows 2 s after start (fast channel loss?); enemy lines now kept in reports.
- STILL WAITING ON HIM: P2 payout from his own Terms/Hire or the host's; whether his 125% zoom is Chrome zoom or Windows scale.
- SHIP: drafts via scratchpad mk-*.ps1 builders (copy the pattern of tools/handoff/drafts/draft-latesay.json), validate-draft.ps1,
  then bash tools/handoff/shipone.sh KEY 1767 1768 (versions without the dot). Card refresh due by ~17.79 (stamped 17.65).
- 10-02 lead (2) "C hit none of 6": diag showed C holding a scuttle; forced scuttle on C in a run -> 5/30 pellets hit, host took the
  damage: the gun is NOT it. The first try also had C facing 53 deg off the target: the test re-stands C every frame behind a moving
  target and the camera lags the mouse aim. ~1% of sessions; a test weakness, not a game fault. __weapons() hook hands C a gun.
- v17.68 a teammate going down is said once (netOnState, the word that first carries dn in this raid: NAME is down. Pick them up.) with padRumble.
- 10-02 load raised: six test Chromes, overnight.sh loops A-E, two runs at once with different log names (overnight.log ABC, overnight2.log DE).
- v17.69 HIS RULING 2026-10-02: the remaining player picks up the raid when the host is gone (netHostGone no longer abandons: upSeed 0 ->
  solo update and loot paths, e.net bodies dropped, the boss remade at its health via bossTick(true)). TO DO: a nettest step that reloads
  A mid-raid and checks C keeps running; what a reopened host window does to C mid-raid is untested (it pairs anew; C is solo until then).
- RULEBOOK rewritten at his order (AAA feel on top, woods off the vetoes, balancing allowed, garbled gun-wear line removed:
  his answer #14/#18 is NO wear, NO condition).
- v17.70 one sound setting for the pair (NET_WHO_KEY both/p1/p2, netSndWhoOn gates the gain; PARTY button cycles; storage event syncs).
- STRESS (tools/handoff/stress.ps1, 1080p, PC under 5 loops): 40 bodies update 0.3 ms draw 2.9 ms; 160 bodies update 3.2 draw 5.3;
  frame median 16.6 (vsync), p95 19-21, worst 25-31 at every N (machine load, not the game). Idle rerun scheduled after 23:00.
- v17.71 the kid menu (KID MODE heading; P.kidBack / kbOn(); host carries m.kb; the v17.66 sit-out skips a death when it is on; extract still ends his raid).
- v17.72 HID worker tick: a covered/minimised host window keeps running a shared raid (hidTick when no rAF for 200 ms and netEntsHost()).
- v17.73 gamepaddisconnected in a raid: pause box + "Controller disconnected. Plug it in, then resume."
- TOOLS: cdp.ps1 -Throttle N (CPU slowdown) and -Shot path.jpg; stress.ps1, memsoak.ps1, shots.ps1 (visual pass screenshots to tools/handoff/shots/).
  shipone.sh: GATE_CDP=9346 ships on a second gate Chrome (profile pillagers-cdp9346) while 9344 is busy.
- v17.74 volume rows (volApply from the loop: BUS.gain=master*fx; MUS.lvl*music*master). v17.75 remappable keys (P.keymap, keyRemapEvent at the
  window keydown/keyup, CHANGE KEYS window, swap semantics; raid prompts still say defaults).
- VISUAL PASS 2026-10-02 (tools/handoff/shots/*.jpg at 1080p): legend columns collided and the panel is too big in play (v17.76);
  NEW-IN card was a wall of six paragraphs (v17.77 shows five, headline+line); sector page is 80% empty (map previews would fill it);
  title has no scene behind it; raid HUD panels are debug-grey with hatched corners (a styling pass); shop and stash are fine.
- PAD SURVEY (agent, 2026-10-02): keyLabel/PADLABEL is the one place for pad names; LEGEND_MINI_PAD was stale (B roll, A fire);
  no pad id was ever read. v17.78 padbrand: PAD.brand from gp.id, padB() translates, legend fixed, b carried in the pad word.
- v17.76 legend columns + collapsed after 3 raids; v17.77 NEW-IN card shows five notes, headline+line (wnShort), stale host line fixed;
  v17.78 PlayStation names (PAD.brand, padB, keyLabel, LEGEND_MINI_PAD fixed to his layout). Queued: secprev (sector maps), padbrand2
  (full legend), titlebg (the Undercroft under the title). BUDGET 22:30 Thu: Fable 61%, ALL MODELS 76% (the binding cap), ~1.2%/h.
- v17.79/82 sector maps on the sector page (sectorPreviewDraw from FIXED_MAPS; rows overflow:hidden). v17.80 card refresh (stamped 17.80).
  v17.81 full legend pad names. v17.83/84 the Undercroft under the title (titleOn, titleSceneReady, #title.on translucent; drawHubHUD
  and station names skipped under the title). Two-window test 2/2 on v17.79. Next card refresh due by ~17.95.
- IDLE STRESS 23:20 Thu (a corpus still ran on 9344, so not fully idle). 1080p: 40 bodies update 0.6 / draw 5.0 ms; 160: 5.7 / 9.2 (frame
  median 17.2, p95 22); 240: 8.9 / 11.7 (median 19.8 = ~50 fps). 4K: 240 bodies 7.1 / 10.7, median 17.6: the GPU is not the limit.
  CPU 4x SLOWER (a weak laptop stand-in, headless = software raster): 40 bodies draw 28 ms, frame 38 ms (26 fps); 120 bodies 91 ms.
  Drawing is the cost on weak PCs; Render resolution / Effects (v17.43) are the levers. CANDIDATE: auto-detect slow frames and
  point at those settings once. MEMORY 30 raids: heap floor 16 -> 26 MB (sawtooth 23-53); mild; a 100-raid soak queued.
- MEMORY 100 raids (memsoak, 5 s each): heap returns to 17-20 MB at raids 17, 51, 75, 89; peaks 61. No leak.
- CORPUS at 1080p on v17.84: 30 of 912 fail (tools: baseline in task bmev5km6k). Known causes from today: kid row renamed (v16.44), per-window
  sound gone (v16.24/29, v15.78), host-leave rule (v15.91, v16.15), NEW-IN card (v11.92), legend collapsed after 3 runs (fixture now
  opens it on __deploy). The rest await the v17.48 comparison run.
- CORPUS TRIAGE 2026-10-03 00:30 (full __regress at 1080p, 912 checks): on v17.84 30 failed; on a v17.48 fixture with the same checks
  the same 22 OLD checks also fail, so they rotted BEFORE today (the ship gate runs only the newest 80): v12.94 v12.80 v12.74 v12.21
  v12.05 v11.85 v11.65 v11.63 v11.09 v10.74 v10.52 v10.44 v10.28 v10.11 v9.93 v9.71 v9.58 v9.55 (+ v13.23 v12.79 which pass now).
  TO DO: a maintenance pass over those 22 (each: environment, stale expectation, or a real bug; v10.11 is the stash tab row gaining
  the search and SORT controls at v17.42). Today's intended changes: fixture updated (kid row name, host-lost line, 3 sound checks
  retired); with the legend opened on __deploy, v8.91 v10.95 v10.93 v10.78 v10.41 v15.91 v11.92 v11.39 pass again.
- CORPUS MAINTENANCE 2026-10-03 01:00: run one at a time, 18 of the 22 old failures PASS (the full run leaks state between checks);
  the four left were stale expectations, all adapted in mkfixture (v10.11 SORT button, v10.74 taller card, v9.58 977 px headless
  window vs a 1080 fit, v10.28 OPEN disabled under a leftover raid). A fresh full run is going for the clean count.
- v17.85 the Keys window in the game font (appended beside partymodal) and its list scrolls (max-height 58vh). Found by the full corpus.
- HARNESS LEAK: after the v17.83/17.84 title checks, v10.93 and v10.95 (station names / words drawn) fail in the same page; the
  real floor is fine (floor.jpg after 17.84 shows the names). HB restore did not cure it; bisecting which of the two leaks.
- HARNESS LEAK FOUND 01:40: my v17.76/17.81/17.84 checks left an own fillText on ctx/wc, shadowing the prototype capture the older
  text checks use (v10.93, v10.95, v9.93...). Fixed (delete the stub). Memory: dark-raiders-stub-a-method-delete-it-after. Full corpus rerun going.
- CORPUS 02:00: 6 of 913 fail in the full run after the restore fixes (three v14.1x checks assigned fillText back too). Left: v15.91,
  v11.65, v11.63, v9.55 pass alone (order-dependent, a later pass); v11.09 sees an <a> in Times that only an earlier check creates
  (no anchors on a fresh page); v10.41 fixed by v17.86 (legend says crouch toggle).

## NEXT UP (2026-10-03 02:10)
- Game at v17.86 (v17.87 slowhint shipping on gate 9346: GATE_CDP=9346). All pushed. Priorities (his, 10-02): no bugs, smooth menus,
  look and feel, two-player; no new depth. Bar: ARC Raiders x Fortnite 2026 x CoD BR. Alpha for friends: Halloween.
- RUNNING: night runs (overnight.sh ABC -> overnight.log, DE -> overnight2.log) until ~06:40. Six test Chromes: 9335/9338 soaks,
  9336/9337 bots, 9345 4K, 9344 corpus/scratch, 9346 gate. Heartbeat on. Budget 02:00: all-models 78%, Fable 65%, reset Sun 01:00.
- CORPUS: 6/913 in a full run; 4 order-dependent (v15.91 v11.65 v11.63 v9.55 pass alone), v11.09 an <a> an earlier check leaves.
  Full run: open fixture.html on 9344, Expr __regress() (40 min). Lesson: stubs on ctx/wc must be deleted, not reassigned.
- CANDIDATES NEXT: controller button remap (bigger; keyLabel/PADLABEL + PADHOLD maps are the seam); raid HUD panel style pass
  (shots in tools/handoff/shots); first-five-minutes audit with a fresh profile and a pad only; the four order-dependent checks;
  stale "On the surface B cycles his orders" (hire orders moved to O; his TXSHIP line, ask him).
- TOOLS: stress.ps1 (-Throttle), memsoak.ps1, shots.ps1 (-Cdp 9346 -Port 8806), cdp.ps1 -Shot/-Throttle. Two-window test: soakloop.ps1.
- v17.86 legend says crouch toggle again (v10.41). v17.87 perfNote: ten seconds of frames mostly over 25 ms say once that Settings has
  Render resolution and Effects (raw gap, not under a Frame cap). v17.88 queued: a pad unplug pauses only the window that plays it
  (NET.padIx), since both windows on one PC hear every gamepaddisconnected.
- FRESH-SAVE PASS 02:30 (tools/handoff/shots-fresh.ps1 -> shots/fresh/): title, WELCOME PACK, floor and stash read well; the stash is
  the dead end for a stranger (icons without names, empty loadout, tiny key legend) -> v17.89 #firstkit line in the loadout column
  while runs==0 and nothing is packed. Still plain: WELCOME PACK is a text list (icons would be AAA); stash cells have no names.
- v17.90 WELCOME PACK rows carry item icons (gunIcon / drawItemIcon into 56px canvases). Fresh-save shots retaken: shots/fresh/.
- v17.91 card refresh (stamped 17.91, A BETTER FIRST HOUR). Next card due by ~18.06.
- NIGHT 10-02/03 (23:38-06:40): soaks 87/90 + 90/93 (2 machine stalls while I shipped, 1 test-aim miss, 3 unfinished); bots 173
  batches, none with errors (one empty result line at 02:23); 4K 32 batches, one at 3 fps at 00:50 while corpus+memsoak+stress all
  ran, the rest 54-60. Game at v17.91.

## STYLING PASS (his order 2026-10-03 07:50: "styling across all menus, HUDs etc needs massive improvements") — DO THIS FIRST
Bar: ARC Raiders x Fortnite 2026 x CoD BR. One look everywhere: dark glass panels (translucent, 1 px light border, 6 px radius,
no hatched corner grips), one type scale (Rubik; uppercase letter-spaced labels for headers, sentence case for body), one accent
(amber) for the primary action, bone text, ash hints, consistent button heights and paddings, visible hover/focus, generous spacing.
Stages, one build each, screenshots after (tools/handoff/shots.ps1, shots-fresh.ps1): A) CSS theme for all HTML menus (modals,
rows, tabs, buttons, inputs, scrollbars); B) title screen; C) raid HUD canvas panels via one shared panel helper (legend, pillager
board, contracts, vitals, weapon box, belt frame); D) run card; E) stash + shop + sector page. Keep every id and class the checks
use; measure with a style check (same font, same radius, no Times, buttons within one height).
- 10-03 morning, his asks: (1) STYLING PASS across all menus/HUDs first (plan above). (2) Player 2 character selection: v17.93 p2saves
  (p2SlotPick, activeSlot2 pointer, IN USE BY PLAYER 1/2, the old profile:p2 moves into a free slot once; nettest updated).
  (3) F11 did not fullscreen the P2 popup: v17.92 answers F11 itself. (4) ITEM GRAPHICS (guns especially) "look terrible, need massive
  improvements": an icon art pass is part of the styling work, guns first (gunIcon at ~28389, drawItemIcon at ~28470).
- v17.92 F11 handled by the game (both windows). v17.93 player 2 picks a character (SHIPPED; two-window test 2/2 with P2 on its own
  numbered slot). Stage A theme (draft-theme.json) shipping next on 9346, screenshots after.

## 2026-10-03 afternoon: his live notes while playing (v17.94 to v18.05)
He played co-op with his son and sent notes mid-raid. Each shipped as its own build, in order:
- v17.94 styling pass stage A (one look for every HTML menu). Stages B-E still to do (title, raid HUD panels, run card, stash/shop).
- v17.95 EXTRACT NOW! -> EXTRACT IN PROGRESS! (banner, ring badge, sector map line). Checks 11.54, 11.74, 12.21 and the 15.0x map-line regex were adapted.
- v17.96 the seal spawns at a random landmark each raid (seeded side stream 4, never the one nearest the first spawn, never under half the farthest).
- v17.97 the seal opens marginally quicker: 34/55/76 s (was 40/65/90).
- v17.98 extraction takes 30 s to arrive (DEF.extractWait 25 -> 30); the 30 s window was already so.
- v17.99 a Settings change keeps scroll, focused button and pad highlight (setKeep/setRestore around renderSettingsInner).
- v18.00 kid-mode rows shared between the two windows (localStorage salvagerun:kid with a stamp; storage event re-renders Settings).
- v18.01 Auto resolution row (DRS): slow frames step gfx scale down a notch at a time to Low, smooth frames step it back; first step says so once.
- v18.02 ESC from the player 2 window pauses player 1: the handed key is dispatched on document.body, not at window (the capture-order trap in memory).
- v18.03 fog-of-war and darkness sheets draw at SOFTR of the screen (0.5 at 1440p/4K, 0.67 at 1080p, times the render scale) and are stretched back.
- v18.04 What's New card restamped (WHATSNEW_VER 18.04).
- v18.05 trading in the Undercroft: stash item menu OFFER row; T (or Y on the floor) takes; same gift words with hub:1.
LAG: he reported frame-rate lag while I had five test Chromes running. Killed them all at once. RULE: when he is playing, no test loads at all. The lag "when running and revealing new assets" is not fully explained; DRS and the half-size sheets are the generic answer. Still worth profiling: the per-frame canSee loop over all ents, buildVisPoly ray count in built-up areas, per-frame gradient creation per tree/house.
NEXT: gun and item icon art pass (his explicit ask), styling stages B-E, then the profiling above.

## 2026-10-03 later: his second batch of notes (v18.06 to v18.08) and two findings
- v18.06 fewer big robots at the extraction siege: cap 5+7*greed (was 6+8), sentries 3 in 10 (was 1 in 2).
- v18.07 shared sight: a teammate's view cone is cut from your fog (netMateFog/netMateLamp/netMateSees), enemies in his sight are seen; Settings row Shared sight (CFG.sharedSight, On).
- v18.08 kid firing turns player 2 toward the nearest enemy in sight (afLook) before it is in gun range.
- GATE LESSON (memory dark-raiders-gate-tabs-share-storage): the control tab's saves fire storage events in the dry tab, SAVE_STALE goes up and its capture listener eats ESC/Enter; check 18.02 clears it first. The dry chain reuses %TEMP%\pillagers-dry\dry<Prev> with its own mkfixture copy: delete it after editing a check.
- "GOLD OUTLINE AROUND PLAYER 2'S FACE IN THE UNDERCROFT": almost certainly the default look of a new character, COSDEF hair 'blonde' + cut 'long' (HAIRCOL.blonde is gold; the long cut is a flat rounded rect behind the face). Player 2's new numbered save (v17.93) wears the default. Asked him whether to change the default for new characters or leave it to the mirror; not changed yet.

## 2026-10-03 evening: the art and styling pass continues (v18.09 to v18.14)
- v18.09 icons painted sharp: itemIconURL/mercPortraitURL draw at R x the row size (R up to 4, then 6 at v18.12); .invgrid .ic image-rendering auto (was pixelated).
- v18.10 the gun painter: materials (rarity receiver, gunmetal barrels, dark furniture, wood), bevel per part, ground shadow, rarity glow on big icons, fine details (rail ticks, port, muzzle, sight, trigger, mag plate, grip lines) when u>=0.9. Same silhouettes. Check samples the pistol slide at x +6 units (clear of the frame and the sight).
- v18.11 styling stage B, the title: gradient wordmark (.wordmark), glass step cards (.tcard/.tstep/.tbody), vignette backdrop on #title.on (still translucent for 17.83).
- v18.12 the icon fills its cell: #hub .invgrid .cell:not([data-plan]) .ic 62%, .vcell .ic 44%.
- v18.13 styling stage C: hudPanel(x,y,w,h,a) rounded gradient panel for conditions, pillager board, both legends and the backpack panel.
- v18.14 the icon lift: iconLift(c,w,h) light/shade clipped to the shape plus a soft shadow, run by itemIconURL for non-gun icons.
STILL TO DO in this pass: stage D (run card), stage E (stash/shop/sector page: the shop's cream card is deliberate, leave it), the vitals panel and belt frame in the HUD, and a look at the raid backpack icons (canvas-drawn, no lift yet).

## 2026-10-03 night: the frame cost, measured and cut (v18.13 to v18.16)
- v18.13 HUD panels share hudPanel(); v18.14 icon lift (two half gradients: transparent white next to transparent black at the midpoint, or the shade half goes light grey).
- MEASURED (scratchpad probe-perf.js / probe-callers.js through tools/cdp.ps1 -Expr, 4x throttle): 3,650 fillRect calls a frame at the spawn, 4,270 walking south; 3,500 of them inline in render2D = the per-wall weathering loops. Recipe in memory pillagers-frame-cost-is-wall-weathering.
- v18.15 walls bake their weathering: wallPaint (the old block, moved), wallSprite (per wall, round(ZOOM*DPR) scale, LRU 320, keyed on seed/day/decay/scale), CFG.wallBake 0 restores live paint.
- v18.16 trees and bushes bake their blobs: vegSprite/vegDraw per rounded radius and palette; bush blobs sway together.
- NEXT if he still sees lag: shadowE ellipses (~160/frame), drawContS boxes (~140 rrF), then re-measure; the update side (canSee per ent per frame, buildVisPoly) was not measured.

## 2026-10-03 late: "still not clear how trading works" (v18.17, v18.18)
- v18.17 trading is on the legends: LEGEND and LEGEND_PAD gain a TEAM section (T / Y offer or take a traded item; N / LB+RB ping); the compact legend adds the two rows while NET.on (rows now _mr=ceil(MN.length/2)); #kb_trade line in the stash key bar shown when netHubSeat()>=0 (toggled in refreshInv); #partytrade paragraph in the Party window.
- v18.18 card restamped.
- A trade-clarity workflow (3 tracers + 2 refuters per dead end) ran read-only; its findings and what was shipped from them are below this line when done.
- v18.19 a controller takes an Undercroft offer with a window open: padMenu reads Y first on its own edge (PAD.yMenuWas) because a panel owns the pad before the hub branch runs.
- v18.20 a waiting raid offer is taken first: netGiftKey answers G.giftIn before the backpack-open offer branch.
- The full corpus (944 checks) is running in headless Chrome 9344 on fixture.html; it is slow (about 3 a minute while the gate ships), so the gate rests until it finishes. Results go here when in.

## 2026-10-03 11:00: the trade audit (workflow wf_a0e43cc0, 55 agents) and what shipped from it
26 dead ends claimed, 18 held up under two refuters each. Shipped: v18.21 the offer line and THE OVERSEER bar were painted BEFORE drawHUD's clearRect and never reached the screen since v17.45/v17.52 (check 17.52 passed on a fillText capture: green for the wrong reason); v18.22 T with the backpack open is the trade key only (no fall-through to netAidHold), nothing behind the Peddler stall; v18.23 a failed trade says why (downed receiver answers no why:'down', a window with no raid answers why:'gone', expiry said on both sides, a no closes the giver offer); v18.24 pad Y on a highlighted .cell dispatches a contextmenu at the cell (the item menu, so a controller can Offer/Equip/junk from the stash); v18.25 floor hints (pause key line, stash idle text, floor bottom line and H card say the trade key while a party is on).
NOT DONE from the audit (judged later or design): pass ammo / second gun / belt-bound items; 3-4 player recipient choice; item loss when the data channel drops between yes and give (needs an ack); offer while the receiver is in a text box.

## 2026-10-03 12:xx: HIS ORDER, TRADING IS DROPPING (v18.26 to v18.28)
- v18.26 short dark hair is the default look (COSDEF hair dark, cut crop; Dark hair how:always).
- v18.27 up top: Z (pad Y with the backpack open) drops the selected item as a pile; bagDropSel is the one drop function; a linked window sends {t:'pile',k,x,y,ib} and the host makes the box (netPileTake), numbered and told to the party by netContTick as any new box. Legends, backpack header, pause line and the Party window teach Z / Y. The T/Y offer words (v17.44) stay in code, unadvertised; checks 17.55, 18.17, 18.25 retargeted.
- v18.28 the Undercroft: stash menu row Drop on the floor (hubDropMake) makes a crate (HB.drops, drawn through the hub DR list, prompt [E] TAKE X), taken with E/A beside it (hubDropTake, in updateHubWorld after the station pick); {t:'hdrop',op:put|took} over the party, host relays. Checks 18.05 (offer plumbing tested through netHubOffer directly) and 18.25 (stages a crate) retargeted.
- The corpus is still running on 9344 (420/944 at 11:56); result lands in scratchpad corpus-result.txt.
- v18.29 card restamped (leads with trading is dropping). v18.30 DRAG TO DROP: a backpack drag let go outside G.bagPanel and off the belt (and not a hire gift) calls dropItem; the stash screen has #floordrop (data-drop, shown as flex while netHubSeat()>=0, name in #floordropwho) whose __grabDrop unpacks a kit item if needed and hubDropMake()s it; a pad grabs with A and presses A on the DROP HERE button.
- 13:3x MODEL SWITCH (Fable allowance gone): state is clean at HEAD v18.30, everything pushed. Still running on his PC: headless Chrome 9344 with the corpus tab (result lands in the scratchpad corpus-result.txt via the poller; if the poller died, open tools/cdp.ps1 -Port 9344 -Match corpus=1 -Expr "window.__PROG&&__PROG.res&&__PROG.res.summary"), gate Chrome 9346 idle, heartbeat. Next: read the corpus result, fix real regressions only; then styling stages D/E, shadows bake, and his next notes.

## 2026-10-04 (Opus, very low token, one gate Chrome started and closed per build)
- v18.31 styling stage D, the run card (#root .ocwin glass, h1 glow, .tag pills, #oc_btn gradient). v18.32 stage E, stash and shop (.cell/.vcell rounded gradient tiles, .invtab, .vdet shadow).
- v18.33 iconSprite/drawIconSprite: the raid belt, backpack cells and EQUIPPED portrait draw cached sprites with iconLift (ICONSPR, cap 400).
- v18.34 the belt keys are rounded gradient tiles (roundRect clip, rarity wash inside, rounded ring).
- The full corpus was stopped at 773/944 when he started Fortnite (2026-10-03 ~15:30). Rerun it only when he says the PC is free.
- Full corpus 2026-10-04 (slices of 120 in fresh tabs via scratchpad corpus-slices.sh; the one-tab run hung at 802 after 5 h). Real bug found: v18.35 one siege size (siegeBase(GR)=5+7*GR read by the call promise, spawner, pull cap and the linked-window copy; the promise still said the old 6+8*GR). Checks retargeted to his rulings: 9.85 (siege numbers), 15.76 (player 2 pointer), 16.82 retired (player 2 saves list), 18.28 (fresh page title), 9.88 (3% margin for rounded tiles), 9.34 (counts siegeBorn only). Order-dependent, pass alone: 11.63, 15.91. All test Chromes closed after.
- 2026-10-04 evening: v18.35 one siege size; v18.36 ground shadows stamped (SHADSPR); v18.37 bar() draws rounded gradient capsules (centre keeps the fill colour); v18.38 + v18.39 a hudPanel behind the bottom-right weapon readout, kept right of the belt (the corner draws under translate(_boG)+hudZoomIn('gear'), so the belt edge is converted into that space); v18.40 the STAMINA/WINDED word sits beside its bar in the bar colour.
- The two-player soak (overnight.sh A on 9335) hung in its first run at the soak stage for over an hour with no log line; stopped. Suspect headless-tab rAF throttling; look at it before relying on soaks again. NOTE: a kill filter matching 'overnight' also kills the bash that runs it.
- v18.41 the posture chip (STANDING...) is a hudPanel. Screenshot after it: the raid HUD now reads as one set (rounded panels, capsule bars, belt tiles, weapon panel clear of key 9). Stopped here for the night to keep tokens low; nothing running on his PC.
- 2026-10-05 his order (icons drastically better, low token): v18.42 keyIcon(c,key,S,col) paints bandage, medkit, stim, plate, ammobox, smoke, decoy, frag with gradients, ink outline and their defining parts (called at the top of drawItemIcon's switch); v18.43 gunArt(c,fam,id,W,col,S) draws every gun family from real outlines (u=S/110), called first in gunIcon with the ground shadow and rarity glow; the old block painter stays as the fallback. Screenshots of shop and stash confirm both. Next if he wants more: parts/salvage icons (scrap, wire, cell, board...), and the in-world loot props.
- 2026-10-06 code comb (workflow wf_b4be1c15, 14 agents, 10 confirmed of the recent code): shipped v18.45 card, v18.46 floor crates safe (pushed out of station reach, nearer-crate wins, dropper cannot take own while linked, P.floorDrops written and floorDropsRestore at load and netReset), v18.47 spectating host makes piles and a no-link drop is local, v18.48 sprites scale ceil up to 4 + shadow scale from the canvas transform + caches dropped on context restore, v18.49 HIDDEN chip kept above the weapon panel, boss bar at LH(108)*hudRes, offer line at LH(132)*hudRes (its check's control failed on the chip being a fillRect, so the boss arm may not have been exercised). Not done: offer line vs toast overlap is moot (offers untaught).

## 2026-10-07 evening: comb round 2 closed (v18.50 to v18.57)
- v18.50 sealstuck: a seal banked past the new (quicker) need opens on the next E.
- v18.51 hidspec: a covered host window keeps the kept raid running while the host spectates.
- v18.52 padunplug: an unplugged controller pauses only the window that played it (PAD.ix, kept by pollPad).
- v18.53 staleout: the out word names its raid (sd); a word about another raid is dropped ('stale').
- v18.54 keysall: G, Q, Z, V, O are on KEYS_ACTS; Backspace and Backquote refuse a bind.
- v18.55 p2live: the player 2 window marks salvagerun:p2live every 2 s (removed on pagehide); slotBlocked honours a mark under 75 s.
- v18.56 eraseblk: ERASE re-checks slotBlocked at the click.
- v18.57 card-1857: WHATSNEW_VER 18.57; the card draws only WN_SHOW=5 lines, so the newest lines now sit right under the alpha line. Next refresh by ~18.72.
- Harness: soak4k.ps1 now forces a 3840x2160 canvas (__forceSize); before, the D soak ran at 1886x975 when 9345 was started by cdp.ps1 -Start.

## 2026-10-07 night: look and feel from screenshots (v18.58 to v18.68)
- v18.58 crateslink: crates told to a linking window (hubDropsTell), a leaving window's crates leave the other floor (no double take), dropper may take own crate back while nobody is linked.
- v18.59 keyprompt: keyLabel and the Undercroft footer (hubFootKeys) name remapped keys.
- v18.60 legendfit: compact legend keys from the key map (legendKeys), word column clears the widest key (CTRL / C).
- v18.61 stowmelee: STOWED Bare Hands shows no ammo count.
- v18.62 hubread: Undercroft title/stats with a dark halo, #topright text-shadow, footer above the belt (hubFootY).
- v18.63 hublabels: station name plates centred under the drawn name and as tall as the letters; the bar warning below its plate.
- v18.64 shopicons: .vcell .ic 60% (was 44%); check 18.12 retargeted to any tile-relative size >= 44%.
- v18.65 sectorcard: lift page sector name 28px, facts 16px.
- v18.66 contractrows: Mainframe contract rows a few sizes up.
- v18.67 titlesolid: title mode rows and save rows have a dark fill.
- v18.68 card-1868: WHATSNEW_VER 18.68; next refresh by ~18.83.
- Fixture: 17.71 restores salvagerun:kid (it left kb:1 shared, which broke 17.66); 17.66 pins kid comeback off; 16.33 finds the YOUR PARTY line anywhere.
- Shots: tools/handoff/shots/*.jpg retaken on v18.67. Not fixed (taste or low value): station pages centre their content (safe center), Integrity vs HP wording in the backpack, map preview labels overlap on The Cold Mile.
- v18.69 zonenames: sector preview zone names shrink to fit their zone and break onto two lines.
- v18.70 zonelabel: an extraction ring label slides to stay whole on screen.
- v18.71 beltfont: belt key numbers, counts and caption scale with the slot (beltFS); caption names the V key as set.
- v18.72 contractwrap: the raid contract count is glued to its last word (no lone 0/1 line).
- v18.73 tcardsolid: title step cards solid.
- 9345 (4K soak) now runs in a real 3804x2055 window (soak4k.ps1 relaunches it when the port is down); 4K shots in tools/handoff/shots4k.
- Heartbeat cron 3ef10367 at :17 and :47 (session-only, 7-day expiry).

## 2026-10-07 late: his notes of the evening, 4K pass, three workflows (v18.74 to v19.00)
- His notes shipped: v18.74 Overseer bar waits until seen (canSee latch e.barSeen); v18.75 heal/plate use bar (drawUseBar); v18.76 scoped ADS zoom (adsZf, G.adsZ, CFG.adsZoom 0.35; sprite scale ignores it); v18.93 Blotter gradual onset (workflow wf_c854b8f7-bd1, one k factor, BUZZRNDP crossfade); v18.94 hue phase (BUZZPH); v19.00 status icons on the left (workflow wf_8a4a5010-9a1; heal ring moved off the head, CFG.healRingHead dial; ACID row renamed BLOTTER).
- Belt slot 8 to 1 (workflow wf_a2bde6e5-ae9): v18.87 handgun, v18.88 bagslot, v18.89 gunswap, v18.90 presspick, v18.91 floorgun, v18.92 stalekey.
- Visual pass: v18.77 gambler lines centred, v18.78 framed-window text cap (#root .msub 1180 beat 1060), v18.79-v18.83 FASHION previews (outfit, fit, face, tattoo close-up, hat, beard, hairstyle; BUILD unchanged though v18.82's note says otherwise), v18.81 racks fill, v18.85 raid backpack text at 4K (bFS, LH*BZ), v18.86 legend hides under the backpack, v18.95 Undercroft text at 4K, v18.96 bar warning clamp, v18.97 run card note box, v18.98 stash belt one row.
- Cards: v18.84 and v18.99 (stamp 18.99). Every new card check carries the moved-on SKIP (see ship-flow memory).
- Draft gotchas: a draft why/now/title with double or single quotes breaks the generated p-script or the DEVNOW JS line; strip them. Agent-written checks need a trailing comma.
- Fixture fixes: 17.71 restores salvagerun:kid; 17.66 pins kid comeback off; 16.33 finds YOUR PARTY; 11.65 and 11.63 trim the 60-run log first; 18.57/18.68 card checks skip once moved on.
- 4K soak now real 4K (3804x2055): 56-60 fps; the 18 and 33 fps dips were my screenshots on the same Chrome. Co-op soak 16/16 pass; five runs at 4-7 fps likely load contention, coop-soak2 (40 runs) checking.

## 2026-10-08 night: the review's 14 findings, 4K polish (v19.01 to v19.22)
- Review of v18.75-v19.00 (scratchpad review-findings.txt, 14 confirmed): #14 v19.07 coophud (NET HUD out of the vitals zoom, NETTEAMBOX reset each frame), #4 v19.08 scope zoom only on a deliberate aim (PAD.adsAim), #9 v19.09 outfit off for piece previews, #8 v19.10 use bar above the extraction lines, #10 v19.11 status column shrinks and caps at two columns, #1 v19.12 refused gun-key drop restores the belt, #3/#5 v19.13 preview caches keep one look (prevCacheGuard), #7 v19.14 first Blotter dose arms no crossfade (BUZZLASTK), #12 v19.16 FASHION operator panel scrolls an inner box (#appopscroll), #13 v19.17 previews painted at shown size (prevQ, prevRows), #2 v19.18 gun swap names the key it lands on, #11 v19.19 status column avoids moved board/legend/vitals (falls right of them when no room), #6 v19.20 one rack rebuild per click.
- v19.20 did NOT speed the click (110-130 ms at 1080p): the time is the PNG encode of about 49 previews (about 55 ms; painting 6 ms). Moving off PNG needs checks 18.79, 18.82, 19.17 retargeted. Correction written in DESIGN.md.
- Other: v19.01 empty belt key is just a key, v19.02 sector map labels placed by priority (mapPlaceLabels), v19.03 map backing opaque, v19.04 KIA card pictures, v19.05 extraction card haul, v19.06 pause key line never breaks an entry.
- Cards: v19.15 (stamp 19.15, next refresh by about 19.30).
- 4K screenshots (shots4k): v19.21 the what is new card is drawn scaled with hudRes; v19.22 hiding chip and extraction ring labels use hudFS (FS times hudRes). Not done: the belt caption (beltFS 0.12) is still small at 4K; raising it collides with the extraction rows above the belt.
- Corpus night run (corpus-slices.sh): its stall detector counts a busy tab as stuck, so slice 0 was marked STALLED at index 0 while it was running; check 0 passes by hand.
- v19.23 shopstats: shop cream panel lists numbers for consumables (itemStatsHTML: heal amount, over, up to 85/100, put-on time; plate armour; stim; frag blast).
- v19.24 lotbig: gambler offer item at 72 px on a dark tile (was 34). His v9.94 inner "Limited Time Offer" line kept; the section header duplicates it, left alone.
- v19.25 liftprint: lift kit box 15 px (was 11), day and weather hints 14.
- v19.26 secblank: a sector line he blanked (TXSHIP " ") takes no room unless Edit the words is on.
- v19.27 baricons: bar rows lead with the drink's status icon (barIconURL paints statusGlyph by swapping ctx).
- v19.28 wnbag: the what is new card waits while the floor backpack is open.
- v19.29 mapgap: HOT GROUND and SURVEYED second lines a font line height apart (were 12/14 px at any size).
- v19.30 card-1930 (stamp 19.30, next by ~19.45).
- v19.31 mapbound: mapPlaceLabels keeps a moved label on screen and below the SECTOR MAP line (RECEIVING APRON went off the top).
- v19.32/v19.33 mapwx, mapwxgap: the map time and weather line ends left of #topright with a 1.6 x font gap.
- v19.34 beltcap: belt hint on a dark strip, #b4bfca.
- v19.35 hubwalls: Undercroft walls blended about half way toward navy (hubWallHex); a look change, flagged in the note so he can ask for them back.
- Fixture retargets (commit f452ead9): 17.95 reads drawMapOverlayRaw, 17.82 accepts fs=11 start, 15.91 host-leaving arms follow his 10-02 pick-up ruling (netHostGone NET.upSeed=0).
- Night shots: setting P.cond='night' before __deploy still gave a day raid in the fixture (8am); not chased.
- v19.36/v19.37 ocfoot, ocfoot2: run card button row solid with a fade strip above (.ocacts::before); .ocwin has no bottom padding (moved to the last note line) so the pinned row sits on the card edge.
- v19.38 statkeys: YOUR STATS titles wrap (two-line min height). v19.39 netsign: lifetime loss reads -$9,750. v19.40 seasontext: REWARDS count light with a dark edge, bar 20 px.
- v19.41 legfit: full H list panel measured to its widest line; the v12.79 empty second column and its divider are gone.
- v19.42 partytrade: #partymodal .hint gets the 1060 cap (the TRADING line ran across the whole screen).
- Seen and left: stash shows 3 huge columns at true 1080p and 4K (his v6.22 bigger cells x menu zoom 1.3); lamp pools are two flat discs on purpose ("stepped, not a smooth falloff"); gambler offer has a LIMITED TIME OFFER header over his own Limited Time Offer line.
- Co-op soak 2: 39/40 pass; run 4 failed staging (22 rounds, 0 hits, a wall between); 6 runs at 3-6 fps when the 4K window covers the soak window (occlusion throttle), the rest 49-57.
- v19.43 exptag: the bar warning (his words) shrinks to 70% at most so it sits under THE LAST POUR, not THE STASH. Corpus night run: all slices pass except the three retargeted checks (17.95, 17.82, 15.91), now passing alone; 11.52 passes alone.
- v19.44 boardsum: the raider board reserves a row for its "N out, N down" line.
- Review 2 (workflow wf_5b7ee0ed-e2a over v19.01-v19.37, 17 agents; 11 confirmed = 8 unique, 2 refuted; list in scratchpad review2-confirmed.txt), all shipped: v19.45 mapmarker (player dot and party dots drawn after the labels via MAPLAST), v19.47 materows (teammate rows step below the board only when it covers their 30% band in the left column), v19.48 feedcond (kill feed starts under HUDBOX.cond in its column), v19.49 lookkey (worn outfit left out of cosLookKey), v19.50 ocfade (fade strip 14px, inside the gap), v19.51 wnenter (ENTER does not dismiss the card while the floor bag is open), v19.52 maptx (map label boxes measured on TX text; blanked labels skipped), v19.53 surveyed (one line side by side when two do not fit). Fixture: 19.29 accepts one line.
- v19.46 card-1946 (stamp 19.46; next by ~19.61; the 19.46 check no longer requires the October 7 line, which has aged off the five shown).
- HUDBOX is not on window: page-scope probes cannot read it; HUDBOX.legend may hold local (pre-zoom) coordinates mid-frame, so do not bound by it from netTeamHud.
- v19.54 exrows4k: extraction lines above the belt use hudFS and offsets times hudRes; drawUseBar lift scales to match.
- v19.55 prompts4k: hudAtIn(x,y) scales a world prompt about its point (door, revive, search, ring countdowns, pad prompt). Lesson: in a check, set the camera by stepping __frame(0.05) a few times after moving the player; setting g.anchX leaves w2s NaN and hudAtIn's isFinite guard then skips.
- v19.56 callonce: in the active ring with no beacon, the [E] CALL prompt over the character steps aside for the HOLD E line above the belt.
- v19.57 prompts4k2: cook countdown, reload bar and search bar with its count scale about their point (hudAtIn). Review 3 (wf_dfe94578-042) over v19.38-v19.57 running.
- Review 3 (wf_dfe94578-042, 10 agents, v19.38-v19.57): 6 confirmed = 4 unique, 1 refuted; all shipped: v19.58 feedband (feed moves only when CONDITIONS covers its 46% band; below if it clears ~0.78H, else above), v19.59 boardmin (summary row subtracted inside the 3-row floor), v19.60 doordodge (hudDodge at the drawn size, lift brought back through the scale), v19.61 revbar4k (co-op revive bar through hudAtIn with a finally).
- v19.62 card-1962 (stamp 19.62, next by ~19.77).
- Corpus: [842,962) re-run with a busy-tolerant stall detector (scratchpad corpus-slices.sh).
- 4K text scans (render a raid, floor and map frame at 1080p and 4K, compare each text's drawn size): only the belt caption and counts grow less than 1.6x (beltFS); the map marker tags did not grow at all, fixed in v19.63 maplabel4k (mapLabel uses hudFS, offsets times _MZ). v19.64 maptries (placer tries up, left, right before down). v19.65 cachegap (CACHE tag at qy-20*_MZ).
- Corpus [842,962) re-run: one red, 10.78 (it scrolled the grid; since v19.16 the operator panel inner box scrolls); retargeted to scroll the box holding SURPRISE ME, passes. Whole corpus now clean.
- v19.66 beltcap4k: belt hint font = larger of beltFS(bw,0.12) and hudFS(micro) (beltCapFS); drawUseBar cap reads the same size.
- v19.67 craftstats: the craft panel shows itemStatsHTML for the crafted item. Found, not changed: BUILD (cosBuild) is never read by drawOp, so Lean/Broad/Curved look identical; asked him in the morning report.
- v19.68 padhline: on a pad the compact legend drops H full list and its row. v19.69 padring: .padfocus 3px outline, ring plus glow, opacity 1. Pad-mode shots: floor footer and raid HUD switch to pad buttons; the stash key-hint row (DRAG, RIGHT CLICK, SHIFT...) stays mouse-only in pad mode (left: pad stash actions not checked).
- v19.70 stashpadbar: padBodyCls() keeps body.padon in step with PAD.on (pollPad and the release path); CSS swaps #invkeybar for #invkeybarpad (D-PAD, A pick up/place, Y all actions, B back). body.padon is available for other DOM pad hints.
- v19.71 pausepad: keysLegendHtml() returns the LEGEND_PAD layout when PAD.on; togglePauseBox(true) calls keysLegendApply() so the pause key line matches the device when the box opens.
- v19.72 wnpad: the NEW IN card's last line reads walk to dismiss when PAD.on (no pad button closes it; walking does).
- v19.73 trheading: body:has(.modal.on) #topright{ top:24px } - with a window open the corner readout is centred on the window h3 (it sat 18 css px above, on the frame line).
- v19.74 trright: and right:33px, so it ends where the h3 underline ends (measured 33 css px at 1080p and 4K).
- v19.75 card-1975: WHATSNEW_VER 19.75; new line 1 PLAYER 2 ON A CONTROLLER (v19.68-v19.72).
- v19.76 stashtabs: stash category tabs, search box and SORT 10.5/11px -> 13px (a 4K DOM text scan of all station windows found these and the key row as the only menu text under 26 real px at 4K). Check note: #stashtabs is itself .invtabs, so select tb.firstElementChild's tabs.
- v19.77 keybar: .keybar words and kbd 10.5 -> 12.5px. #invkeybar holds a hidden zero-width child; count only visible items when testing for wraps.
