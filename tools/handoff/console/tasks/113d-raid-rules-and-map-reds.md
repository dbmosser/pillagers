113d-raid-rules-and-map-reds : seven checks newly failing on v34.53 on raid rules and the maps pass again
Queue (coordinator 10-24 21:10): the full test run corpus-1024-1829 on v34.53 has 46 failing, 40 newly (14 on v34.18); split by
screen so the helpers work them at once after the reset. Feed order: checks newly failing in the newest full run.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 19:51). Run file:
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1024-1829.txt
Your FAIL lines (check -> what it saw):
- v30.26 vault guns ride on the golden pool -> "a kill on a low roll left no vault gun in the death path"
- v22.12 a district contract names the sector it was rolled on -> "the raid line read "CONTRACT DONE Search 13 containers in RECEIVING
  APRON or HOARFROST ROWS"" (v34.46 shortened the contract done line; player text is all lower case)
- v20.38 a crier that marked player 2 never brands the host -> "the host was branded MARKED by a Crier that marked player 2; the host
  was told a Crier raised the alarm on him"
- v15.80 one set of enemies run by the host -> "an enemy round on the party member did not post a hit word to his seat with its damage
  and its shooter ({"t":"hit","seat":1,"dmg":46,"kind":"raider",...})" (his 10-18 word: pillagers and pillager bots, never raider)
- v13.81 a dropped gun keeps its own rounds -> "control: a carbine found in an ordinary crate arrived with -1 rounds, not half a magazine"
- v10.81 some buildings are destroyed -> "COLD STORAGE building 12 lost interior walls too, 9 against 10"
- v9.81 no wall inside a building forgets what it is -> "control: the maps hold 2268 and 558 walls rather than 2191 and 545, so the
  split geometry moved"
Likely ships: v34.46 contract line, v34.49 and v34.50 building kinds and solid pieces per building kind. The seed 4242 fingerprint
(ents 85/374, containers 165/593) must stay; if a map's wall count moved on purpose, re-aim the counts and say which ship.
These are rules, not looks: a real break in v20.38, v15.80, v13.81 or v30.26 is a 2-player or loot bug, fix it in the game.

Steps:
1. Run each check alone on the current build; drop any that pass (the run went short on memory at times, two robots at once).
2. For each left, find the ship that broke it (git log v34.18..HEAD; the last full run where it passed was corpus-1023-2304 on v34.18)
   and say which of two it is:
   a. the game really broke (a player sees it wrong, a rule no longer holds): fix the game in an mk script;
   b. a newer ship changed it on purpose (his later order) or the check reads an old layout: re-aim the check at what the game does now
      and name the ship and the order in the DESIGN.md section. Never loosen a check just to make it pass.
3. One batch per cause, through preflight.sh and shipq.sh as usual.

TASK DONE when the seven pass on the drafted build or are fixed in a shipped batch; TASK PARTIAL with the ones left and why.

--- COORDINATOR 2026-10-24 21:25: step 1 is done for you. Each check was rerun alone on v34.53 (fresh tab of the corpus Chrome, as a
full-run slice runs it). All seven fail alone (real): v30.26, v22.12, v20.38, v15.80, v13.81, v10.81, v9.81.
A lead to test first, not a finding: v34.49 and v34.50 put more walls on both maps (v9.81: 2268 and 558 against 2191 and 545), and the
map build rolls per wall, so every roll after the build moved (memory dark-raiders-map-build-rolls-per-wall). v20.38 stages the Crier
160 px from the host with markSeat 1 but never sets its facing; since v21.23 a Crier that SEES a player re-marks him every frame
(dark_raiders.html about line 31896, `if(sees){ ... e.markSeat=... }`), so if its rolled facing now points at the host, marking the host
is the right game behaviour and the check's staging is what broke (b: set the facing away from the host or put it out of sight; then
show the control fails on v34.53 as staged before). Ask the same of v30.26 (a low roll), v13.81 (the crate's carbine), v15.80 (which
body fired) and v22.12 (which contract rolled) before calling any of them a game bug.
--- COORDINATOR 2026-10-24 21:50: v13.81's "-1 rounds" is not a gun with -1 rounds. The check writes -1 when the carbine from the
ordinary crate is in neither hand (mkfixture.ps1, `got=...?p.secAmmo:(...?p.ammo:-1)`), so the control's carbine was not equipped by
openContainer after the second bagHeldGun. Find why it stayed out of the hands (the belt, the bag, a new pickup rule since v34.18).
--- COORDINATOR 2026-10-24 22:25: v20.38 lead confirmed on v34.53 (alone, fresh tab): the run's full reason is also "player 2 was never
told the Crier fired", i.e. the fire word went out for seat 0. markSeat changes only where `sees` is true, so the staged Crier saw the
host and re-marked him: the game is right and the staging broke (b). Re-aim: set the Crier's facing away from the host before the
windup (c.face = Math.atan2(c.y-p.y, c.x-p.x), the host is 160 px to its left) and check it cannot see him, then show the control
(today's staging) fails on v34.53. Note: a patched copy of a check cannot be eval'd in the page (the game's names live in its own
scope), so try a change only through a drafted fixture (mkfixture.ps1, fxdryNN).
--- COORDINATOR 2026-10-24 22:55: v10.81 and v9.81 leads confirmed in the code (b, re-aim both; the game is right).
v34.50's bldSolid (dark_raiders.html about line 10928) skips ruined buildings (`if(!plan||b.ruined) continue;`) and makes each piece a
wall with `ib:bi, furn:P.f, bs:1`. v10.81's survey counts every wall with an `ib` as an interior partition BEFORE it skips `w.furn`
(mkfixture.ps1, `if(w.ib!==undefined){ inner[w.ib]=...; continue; }`), so with the dial off a building gets its v34.50 bed or rack row
and with the dial on (ruined) it does not: "lost interior walls, 9 against 10" is a furniture piece, not a room. Count only partitions
(skip w.furn, as the shell count already does) and show the control fails on v34.53 as written. v9.81's control counts (2191 and 545)
are the walls before v34.50; 2268 and 558 are those plus the solid pieces: re-aim the counts and name v34.50 (86i ship 2, his 10-20
22:55 and 23:00 orders) in the DESIGN.md section. v34.50's DESIGN note says the pieces are placed last from grit() so the seeded stream
stays put; my 21:25 line above saying every roll moved is wrong, so look at v30.26, v13.81, v15.80 and v22.12 on their own merits.
