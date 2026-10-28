# guncard
## summary
The colleague's map mostly holds. The order is right: drawHUD() is the only place that draws the "N items  $N" row, and it is the same code in career, the player 2 window (the ?p2=1 copy of the page draws its own G.bag through the same drawHUD) and the pad and keyboard labels. In the demo, trDemo() already hides the row. The bag-open case does not matter because the whole card is clipped away while the backpack is open (45448).

I found five errors or omissions:

(1) HUDBOX.gear does depend on the count, which the colleague denied. It is at 45532, not 45533, and it is rebuilt from _wpx, which comes from _gCW, which includes _gFW (the count width). So the gear box narrows with the card. Two things read it: the gun compare card placement at 22914 and the airstrike plate keep-out list at 67399. Both follow on their own and need no edit, but they will shift.

(2) Several line numbers are off. _gCW is at 45524 (not 45526), _wpx at 45525 (not 45527), the belt clamp at 45527 (not 45529) and hudPanel at 45531.

(3) The colleague missed one consequence. In ammoDraw (43085), the empty-gun reload key cap sits left of the 0 only if it fits inside the card's left inner edge. Otherwise it falls back to standing over the 0 (43097, the demo behaviour). Today the wide count row keeps the career card wide enough. Once the card narrows to max(gun name, rounds, hint), guns with short names can push the cap onto the 0. The cw-hudstates check (fixture 6950/6993) only asks that the cap exists, so it will not catch this.

(4) What the owner calls "the stash value" is the backpack value: the sum of ival(G.bag). The same figure is the YOU row on the CURRENT PILLAGER BOTS board (47054 sums it, 47059 adds the row), so the claim that it is "shown in another window" holds, P2 window included. The board is skipped in three cases: when the raid has no pillager bots at all (46991 returns), in the arcade (46038, where the card row was already hidden) and while it is collapsed. In those cases the value appears nowhere during the raid. That is his call, but it is worth naming.

(5) Smaller points. _gDs drops the descent of the count row, so the card bottom may rise a pixel or two. The comments at 45498-45502 and the cw-cardhint note at 45584 ("opposite the item count") go stale.

The fixture checks the colleague listed are correct: 9931/9993/10112, 11894/11905/11909 and 25898/25903/25911 break. Three more were looked at and are not affected: 25344 (v30.73, the demo is still shorter), 57860 (v22.73, which is about the feed) and v34.25 (type sizes).

Separately, the user request relayed in this run is about a different panel: the run info panel, whose folded title reads "contracts N/M". It is built at 44726-44731 in dark_raiders.html (44729 is _rtl.push('contracts '+_rcd+'/'+_rcn)), with the CONTRACTS row at 44671. The parent should reconcile which order this run serves.
## proposal
Minimal removal in drawHUD, shipped via an mk script. It is the same as the colleague's, with these notes:

1) Delete 45518-45520: the _gcv loop, _gCnt and _gCt.

2) Replace 45522 with:
   _gFW=_gMs(_gFf,_gHint).width; _gDs=_gDn(_gFf,_gHint);
   Optionally drop _gcv, _gcq, _gCnt and _gCt from the var list at 45504.

3) Delete 45571-45572: the _cv sum and the fillText. 45560 and 45570 can stay. Refresh the stale comments at 45498-45502, 45560 and 45584 if wanted.

4) Optional polish, to keep the reload cap left of the 0 in career as today: at 45514, add one more term to the _gR2 Math.max for guns with a magazine. The term is the cap's room:
   _gMs(_gFt,_gRs).width+4+_gMs(_gFm,_gMg).width+LH(10)+max(LH(24),capKeyWidth+LH(14))
   capKeyWidth is ammoCapKey() measured at FS(TYPE.head). This term is always on, so emptying the gun never resizes the card. Without it, a short-named gun's cap will sit over the 0 in career, like the demo.

Nothing else moves: _gFoot, _gBot, the hint draw and G.cornerBox. HUDBOX.gear (45532) narrows by itself, and its readers at 22914 and 67399 follow. The P2 window and the pad labels share this code. The demo is unchanged.

Fixture retargets in the same ship:
(a) 9993 room(): f = hint width only (drop LH(16) and the ITEMS worst case). 10112: drop the 'the item count' need, keep 'the backpack key'. Since the 10116 padding math uses room(), (a) must land with the draw change.
(b) 11905/11909 v34.26: drop the item-count half, or invert it to 'an item count is drawn'. Keep the 16 px test on the backpack cue.
(c) 25903/25911 v30.53: career must keep the hint and must NOT have the value line; the demo has neither.
(d) A new check that fails on v35.66. In career and in the second window, no fillText on the gun card matches /^\d+ items?\b/i or /\$[\d,]+$/, and the '  BACKPACK' hint is still drawn. If item 4 is taken, also check that in career, with an empty gun, the cap's right edge is left of the 0's left edge.
## checks
tools/mkfixture.ps1:9993 v34.89 cw-hudcorner (block at 9931): room() adds LH(16) plus the ' ITEMS  $' worst-case width to the footer row. Retarget to the hint width only.
tools/mkfixture.ps1:10112 cw-hudcorner: career needs 'the item count' (/item/) on the card. Drop it, keep 'the backpack key'.
tools/mkfixture.ps1:10116 cw-hudcorner padding math uses room(), so the left padding fails if room() is not retargeted.
tools/mkfixture.ps1:10192 cw-hudcorner: the 'second window' mode confirms the P2 window draws the same card (steady() is skipped for it).
tools/mkfixture.ps1:11905 and 11909 v34.26 quiet corners (block at 11894): the hook matches /^\d+ ITEMS?\b/ and fails with 'no item count drawn'.
tools/mkfixture.ps1:25903 and 25911 v30.53 Q56 demo card (block at 25898): career must have the value line /^\d+ items?\s+\$/. Retarget to career having no value line.
tools/mkfixture.ps1:6993 v35.49 cw-hudstates: only checks that the reload cap exists, so it still passes. It will NOT catch the cap moving over the 0 on a narrower career card.
tools/mkfixture.ps1:25344 v30.73: the demo is still shorter than career (career keeps the hint row). Passes.
tools/mkfixture.ps1:57860 v22.73 is about the feed, not the card. Unaffected.
tools/mkfixture.ps1:18053, 33640, 35372, 63546, 73988, 81511, 102336, 103293: item regexes on other screens. Unaffected.
## risks
Low risk. HUD and render layer only: no sim, loot, pickup stack, loot rows or storage touched.

Things he may notice:
- The career gun card gets narrower, and its left edge moves right by about the old count width.
- The gun compare card (22914) and the airstrike plate keep-out (67399) follow the narrower HUDBOX.gear.
- Without proposal item 4, the empty-gun reload key cap on short-named guns jumps from left of the 0 to standing over it, as in the demo.
- The bottom edge may rise a pixel or two, because the count row's descent no longer counts.

The backpack value will then be on screen only on the CURRENT PILLAGER BOTS board's YOU row. That row is absent in raids with no pillager bots in the roster (46991 returns early) and when he collapses the board.

Gate risk: cw-hudcorner's room() and the 10112 need must change together with the draw change, or the padding check and the item-count need go red. If only 45572 is deleted and the measure is left, the card keeps its old width with an empty right half.

Process risk: the user request relayed in this run is about the run info panel ('contracts 6/8', spawn it upper right, 44726-44731 and 44671), not this gun card row. The parent must confirm which order this run serves.

# goalspos
## summary
The colleague's map is right on the main points, and I confirmed them by re-reading each site. There is one draw path ('contracts ' is built only at dark_raiders.html 44732). In a career raid the default spot is already the top right corner: bx=W-16-bw, by=TRG.y0 (16) at 44739, in the 'cond' zoom about (W,0). Only three things move it from there: the notes logged plate (44750), the minimap when it is on (44751), or a saved drag offset P.hud.cond.dx/dy (44752-44753). Nothing ever resets that offset. What they missed or got wrong:

(0) LINE NUMBERS HAVE MOVED. Both big files now have uncommitted edits from another lane's ship in flight (the cw-cx-redtracers draft). The game file has 3 extra lines after 25099, so every site they cited after 44000 is now +3. tools/mkfixture.ps1 has 67 extra lines after about 7650, so most of their check lines are +67. All lines below are the current working copy. If that draft is reverted, take 3 (or 67) off.

(1) THE PICTURE ITSELF PROVES THE PANEL WAS FLUSH RIGHT. The resize grip draws in the bottom LEFT corner only when hudGrip (46821-46826) finds the panel's right edge within LH(20)+10 px of W. The grip loop is at 46065 and draws only while the pointer is over an open panel. A bottom-left grip in his picture means dx is about 0 and the panel touched the right edge. So the gap from the corner is vertical: a saved dy, the notes plate, or the minimap. A bare dx reset would not explain the picture.

(2) HOW A STALE OR ACCIDENTAL dy GETS WRITTEN (they gave only "a drag before v35.36"). In a raid, a left click that lands on any HUDBOX claims the click before the trigger (18763). When it lands on the panel's top strip (hudBar, 46914: full width, LH(16) tall) it starts HUDDRAG (18796-18797). Every mouse move then writes P.hud.cond.dx/dy (18583-18585), and mouseup saves it (18807). Since the quiet hud (v35.36) the panel sits folded at about 36 px tall in zoom space, so most of it is drag bar; only the LH(20) chevron box toggles. Shooting at something near the top right edge with the crosshair over the folded plate, or clicking its title instead of its chevron, drags it. So an offset can come back after any one-time reset unless the drag start is tightened. hudClampAll (43005, called each frame at 44106) only rescues a bar that is off screen. The comment at 43001 confirms there is no reset in the game, and grep finds no P.hud reset anywhere.

(3) ARCADE INHERITS IT. arcadeSandboxIn (64585) copies his whole profile, and the comment at 64567 says "His HUD layout ... are kept". So a stale P.hud.cond offset also moves the goals-only panel in the Friday party demo. Drags made in the demo are never saved (saveProfile refuses, 5893).

(4) PLAYER 2 WINDOW. It plays its own numbered save (4945, p2SlotPick), with its own P.hud. A once-per-save move must run when each window loads its save (applyGameOpts covers that), not once per machine.

(5) SMALL GEOMETRY CATCH. The vertical clamp floor is LH(10) (44753), not TRG.y0. LH = px*1.3*uiScale (13494-13495): 16 at 1080 with auto text, but 20 when P.uiScale is 1.5 (the demo sandbox's TV text, ARCADE_SBX). So in the demo the panel's top sits about 4 to 8 px lower than the column top even with no offset.

(6) drawRaiderBoard is at 46990 (they said 47063). Its position lines are 47070 (PADX 14, y0 LH(96)) and 47077-47078. It is still top LEFT.

(7) CHECKS. Old v12.25 (mkfixture 96403, assert 96456) also asserts the CONDITIONS box starts below the page readout bottom; they missed it. v31.32 and v31.50 are already on tools/handoff/stable-known-red.txt. No check today asserts that the panel's top equals TRG.y0. v35.36 stages P.hud.cond={} (7737) but measures no position.

What occupies the upper right in a career raid today, top to bottom, in the 'cond' zoom anchored at (W,0):
(a) The notes logged plate, only when this raid has notes: trGeo 5791-5801, drawn by trColDraw 5825-5840 from 46082.
(b) The minimap, only when Settings MINIMAP is on (his exports say mmSz 0, off): mmRect 43812, drawMinimap 44036, called at 44550. When folded it draws a slim 'minimap' strip that still sets MMAP.box (44046-44057).
(c) The run info panel: 44739, then 44750-44753, panel at 44755, HUDBOX.cond at 44758, mapped to the screen at 44774.
Nothing else is there. The page #topright is clipped in a raid (676, trHide 5843). The score and clock plate is top centre (SCOREBOX 40394, written at 68404). The roster and the status icons are on the left. In the demo, trDemo (5853) caps the column width, and the panel holds goals only (44555, 44680).

Side note on bullet 2 ("contracts 6/8"), confirmed. The count (44729-44733) takes in every P.contracts entry, finished and conduct ones included. The rows show only live counting contracts (runInfoCap, 44669) plus conduct lines that are not at rest (44646). quiet and swift never show, and far has an empty note. His picture (6/8 over zero CONTRACTS rows) means the 2 open ones are conduct contracts at rest or hidden.
## proposal
Read "spawn in upper right hand corner" as: whenever a raid (career or demo, either window) starts, the run info panel's top right corner touches the screen's top right corner, at TRG.y0 and W-16 in zoom space, and nothing in the column sits above it.

1) One-time reset per save. Add a condTopMove() beside mmOffMove, run from applyGameOpts (72909). It deletes P.hud.cond.dx and .dy, keeps .z and .o, and sets a flag (P.condTop1=1). It runs on each save as that save loads, so player 1's save, player 2's numbered save, and through the copy the demo sandbox are all covered. The storage key does not change. The flag only takes effect once a save is written; until then the move repeats harmlessly.

2) Stop the panel picking up a new offset by accident (fix, not feature). Since v35.36 nearly the whole folded plate is drag bar, and in a raid a shot that lands on it drags it (18763, 18796, 18583). Pick one:
(a) A press on the cond bar starts a drag only after the pointer has moved some px with the button held AND the press was not a fire press. Simpler: for 'cond', make the title line toggle open like the chevron and start a drag only from a press that holds about 250 ms.
(b) Or ignore cond drags while a gun is in hand.
Without this, (1) only fixes it until his next firefight in the top right.

3) Put the notes logged plate under the panel instead of above it, so the panel's top is always TRG.y0. Simplest: no separate plate in a raid; append 'notes N' to the title line (_rtl, 44732). That needs no plate below a panel that folds and opens.

4) Clamp floor: use Math.min(LH(10), TRG.y0) at 44753, so in the demo (text scale 1.5) the panel touches the top too.

5) Leave the minimap above the panel when he turns it on. It is off for him, and a fixed square above a panel that jumps is the rule at 44541.

Nothing else has to move. The pillager board, status icons, fps box and fullscreen button are on the left, the score and clock plate is top centre, the page wallet is clipped, and the gun card (22916) and kill feed (62785) follow HUDBOX.cond.

New check (must fail before):
(i) Stage a profile with P.hud.cond={dx:-300,dy:400,z:1.2,o:1} and no condTop1, run applyGameOpts, deploy a career raid. HUDBOX.cond.y must be within 1 px of TRG.y0*_cz and its right edge within 1 px of W-16*_cz, at 1080 and 4K. .z and .o must be kept.
(ii) The same with G.tel.notes holding one note: the panel top is still TRG.y0*_cz.
(iii) A press on the folded panel's title with a mouse move of 40 px does not change P.hud.cond.dx/dy (if 2a is taken).
(iv) A deliberate drag after the move still moves it 100 for 100, so v10.42 stays green.
(v) The demo with uiScale 1.5: the top is within 1 px of TRG.y0*_cz.
Pictures: uishots 21 and 33 at 1080 and 4K, plus both party windows.

Watch-for line for him: the panel starts flush in the top right corner every raid, shooting near it never moves it, and a drag still moves it.
## checks
Line numbers are the current working copy of tools/mkfixture.ps1. Another lane's uncommitted draft added 67 lines near the top, so headers after about 7650 are +67 from what the colleague cited.
v35.36 (header 7721; P.hud.cond={} at 7737; fold and arrow asserts after 7770). Asserts the fold, the open on change and the arrow, but no position. A title-click toggle (fix 2a) would need its tap target checked against the chevron step SEVEN.
v34.88 (header 10293; c0=HUDBOX.cond.y at 10321; asserts 10347, 10359; stages P.hud={cond:{dy:...}} at 10362; drag-over-tab assert 10363). It stages a dy after load, so the one-time move does not touch it, but a drag-start change (2a) could break its 'run info dragged up over the fold tab' staging.
v34.57 (header 11256, reads HUDBOX.cond at 11271): run info is as wide as the column. Position-free.
v33.36 (header 15543; tb0 at 15558, assert 15569): with the minimap on, run info moves down. Unaffected if the minimap stays above.
v31.50 (header 21436, width assert 21506): column width. Already in stable-known-red.txt (score plate inset).
v31.32 (header 22210; plate filter 22236; title regex 22264): expects exactly 3 corner plates (notes or wallet, minimap, run info) above the run info bottom, top to bottom. It breaks if the notes plate moves under the panel or into the title (fix 3) and must be retargeted. Already in stable-known-red.txt.
v27.42 (header 36057, assert 36084): RUN GOALS rows inside HUDBOX.cond. Position-free.
v27.17 (header 37272; stages P.hud.cond={dx:0,dy:H*0.22} at 37285): stages after load. Safe from the one-time move unless the check swaps in a profile without the condTop1 flag and then runs applyGameOpts.
v25.33 (header 47616, assert 47636): with the minimap off, CONDITIONS moves up above the old minimap bottom.
v24.95 (header 49239, reads HUDBOX.cond at 49263): minimap top right, CONDITIONS under it.
v19.58 (header 67402, assert 67418) and v19.48 (header 67602, assert 67617): the feed against a staged CONDITIONS box. Position-independent.
v18.13 (header 70542): samples the corner pixels of HUDBOX.cond. Position-free.
v12.25 (header 96403, assert 96456): MISSED by the colleague. A raid CONDITIONS box must start below the page #topright readout bottom. The panel at TRG.y0 already has to pass it today; read it if the top moves (fix 4 lowers the floor).
v12.05 (header 96986, assert 97014): the notes line must not be drawn inside the HUDBOX.cond box. Fix 3 (notes in the title) changes what it finds and needs a retarget.
v11.78 (header 97875, asserts 97894-97895): CONDITIONS starts below the corner readout bottom (raid.b).
v11.52 (header 6093, cond clearance 6124-6130): credits and XP readout clear of the CONDITIONS box.
v10.42 (header 103763; moved('cond',-100,0) at 103791, (0,60) at 103794, the -9000/9000 clamp at 103801): drags must still move the panel 1:1 after the reset and after any drag-start change. It sets dx/dy directly in P2.hud, so a hold-to-drag rule (2a) does not affect it.
Fixture exposure: applyGameOpts runs about 40 times in mkfixture and at 70513 and 72860 in the game. The condTop1 flag protects staged offsets only while P keeps the flag. Any check that installs a fresh profile object holding P.hud.cond dx/dy and then calls applyGameOpts would lose the staged offset.
## risks
His saved P.hud is not in any flight recorder export, so the stale dy is inferred, not seen. The bottom-left grip in his picture rules out a dx offset, but the gap could equally be the notes logged plate (when he had logged a note that raid) or the minimap (off in his exports). Fixes 1 and 3 together cover both. Without fix 2, a one-time reset decays: since v35.36 most of the folded plate is a drag bar, and a fire click on it in a raid starts a drag. Any drag-start change touches the HUD click rule (v3.64) and the v34.88 staging, so test the chevron, the grip and v10.42. Both big files currently carry another lane's uncommitted draft, so line numbers move by +3 in the game file and +67 in mkfixture until that ship lands or is reverted. A ship STOPs on uncommitted edits, so this job queues behind it. The reset must keep .z and .o, never touch the salvagerun:profile key, run once per save behind a flag, and run on the real save before arcadeSandboxIn copies it. Watch-for for him: the panel is flush top right at every raid start in both party windows and in the demo, and shooting near it never moves it.

# contracts
## summary
I checked their map against the current code and it holds. I edited nothing.

**Where they were wrong:**
- `genContract` is at 6616, not 6644.
- `claimAllContracts` is at 58974, not 58973.

**What P.contracts is.** It is the career board, and it always holds 8 contracts (`ensureContracts` 6355, the comment about eight at 6364). Every contract on it is active at once.
- Contracts that count something: kill, open and district move `prog` during the raid through `contractStep` (6712). exItem and haul are judged at extraction (`contractExtract` 6774).
- Conduct contracts (clean, quiet, swift, weak, elite, steady, far) are about 5.5% of new contracts (6669, 6675).
- A finished contract is not paid automatically. It stays on the board until he presses Claim at the Mainframe (57866 and 57894, `claimContractAt` 58961, which swaps in a fresh contract at 58970).
- So "contracts 6/8" (44728-44729) meant 6 finished contracts waiting to be paid and 2 open. The 6 finished ones cannot change during a raid.

**Why his open panel showed no contract rows.** Rows go into `_clines` only for unfinished contracts:
- Conduct contracts (44603-44645): quiet and swift never draw (44612). far has no note (44637). clean, steady, and elite before an elite kill are at rest and hidden (44642-44644).
- Counting contracts: up to 3, nearest to done first (44650-44666, `runInfoCap` 43077).

So both of his open contracts must have been hidden conduct kinds. That is likely and not a fluke. He has not been claiming, so the contracts left open are the ones that rarely finish on their own, which are the conduct rules. Any kill, open, district, exItem or haul contract would have printed a row. It was not the `condHud` setting (no stored value sets it, so it is on), and not the demo: the demo empties the rows at 44680 and its header has no contract count, because of the `!_arc` test at 44728.

**What they missed:**
1. **Comment at 44641:** "The count line says the contract is there." The quiet hud work hid the at-rest conduct lines because the count stood in for them. Dropping the count leaves no sign in the raid that a no-heal or no-down contract is active. That is the real trade-off, and it goes in the risks.
2. **Comments at 44724-44725 and 44754** ("the title is the count") also describe the count and need new wording, along with 46938.
3. **The map screen** (49376-49377) already has a 'contracts' list with 'N of M done' and every contract row. The count belongs there, not on the raid HUD.
4. **Player 2:** there is no second draw path. The header is built only at 44726-44731 (no other `'contracts '+` or `'goals '+` anywhere). A career co-op window runs the same function on its own P.contracts, and the demo window never counts contracts. One edit covers every window.
5. **Exports:** his flight-recorder exports do not list the board, so the 2-conduct reading comes from the code and cannot be confirmed from his data.

**Checks.** I grepped tools/mkfixture.ps1 and the only check that asserts the 'contracts N/N' text is 7698 (v35.36 cw-quiethud SIX). The other five only match the title by pattern and keep passing.
## proposal
I recommend the same fix as the colleague: drop the count and leave everything else alone. Delete lines 44728-44729 of dark_raiders.html.

**Result:**
- In career, the panel title reads 'goals D/N' when the raid has goals and 'run info' when it has none.
- The demo does not change.
- The contract rows stay exactly as they are under the 'contracts' heading: up to 3 counting contracts with their progress, plus any conduct contract that breaks or changes.
- Contract movement still opens the panel for 4 seconds, because _rsig does not use the count.

**Why:**
1. The number misleads. In his case 6 of the 8 were finished contracts waiting at the Mainframe, which cannot change during a raid. The other 2 were conduct rules that his v11.88 order and the quiet hud hide on purpose.
2. He asked for less on screen and a small panel. Listing all 8 contracts, or bringing back the at-rest conduct lines, would grow the panel and undo two of his own rulings.
3. The full board, with its own 'N of M done', is already on the map screen (49376) and on the Mainframe board.
4. It removes two lines, adds no feature (fine under the no-features rule until 11/1), and does not touch looting.

**Alternatives I rejected:**
- (a) List every unfinished contract: more rows, and it brings back lines he removed.
- (b) Count only the contracts the panel lists, as 'contracts N': it is still a number with nothing listed while the panel is folded, which is exactly his complaint.
- (c) Show the at-rest conduct lines when the panel is open: it undoes quiet hud change 3.

**Ship with:**
- New wording for the comments at 44641, 44724-44725, 44754 and 46938.
- An update to tools/mkfixture.ps1 line 7698 (SIX): assert that no recorded text matches /^contracts \d+\/\d+/, and that the folded title is one line, 'goals D/N' or 'run info'. Keep the rest of SIX and SEVEN.
- A new check that FAILS on the build before: a career raid with an 8-contract board, 6 finished, 2 at-rest conduct (clean, steady), goals present. Assert that no fillText matches /contracts \d+\/\d+/ and that the title is 'goals D/N', both folded and opened by the arrow.
## checks
tools/mkfixture.ps1:7698 (v35.36 cw-quiethud SIX): asserts hasIn('contracts 1/3') on a 3-contract board staged at 7671; MUST be updated, or it fails after the fix
tools/mkfixture.ps1:22197: title found by 'run info' or /^(contracts|goals) \d+\/\d+/; still passes
tools/mkfixture.ps1:25580: same title regex, plus /^run info$/; still passes
tools/mkfixture.ps1:28028: maps the count title to 'run info' to check the heading colour; still passes
tools/mkfixture.ps1:28713: finds the title font size by the same regex; still passes
tools/mkfixture.ps1:35995 (v27.42 run info): ttl() accepts 'RUN INFO' or the count; still passes
tools/mkfixture.ps1:10301 (fold tab click): checks riOpen and P.hud.cond.o, not the text; unaffected
## risks
- **Rules he cannot see in the raid:** with the count gone, an active no-heal (clean) or no-down (steady) contract leaves nothing on the raid screen until it breaks, and quiet or swift never show at all. The v4.03 reasoning was "a rule you cannot see is a rule you will break." His later orders (v11.88, the quiet hud) chose a quiet screen anyway, and the map screen lists every contract before he ascends.
- **Unclaimed pay:** with 6 finished and unclaimed, nothing in the raid points him to the money waiting at the Mainframe. The count never said that clearly either. A pointer to unclaimed pay would be a new feature, so it waits for after 11/1.
- **Why his picture had no rows:** that both open contracts were hidden conduct kinds comes from the code and from the fact that he does not claim. His exports do not list the board, so it cannot be confirmed.
- **Title width:** the panel width is measured from the rows, not the title, so a shorter title cannot clip anything.
- **What to watch for:** the right panel's header in career reads 'goals 0/3' or 'run info', and contract progress still pops the panel open for a few seconds.

