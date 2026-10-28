# arrow
## summary
Nothing edited. Game file is v35.66 (HEAD b73dec18d). The colleague's map is right about how things work, but most of the bottom-band line numbers are 8 lines off. It also misses two places that assume the band is on screen, one case where a gate on G.active hides a ring that is near, and two fixture checks that would quietly turn into SKIP.

USER ORDER (it wins: the band above the belt shows the start and in-progress lines only within 250 m)

Corrected line numbers for the band in drawHUD:
- the gate is at 45612: if(G.beaconT!==null&&!G.over){ (not 45604)
- inRing is at 45613
- the colour (red while holding outside the ring) is at 45617 (not 45614)
- the line text _exS is at 45621, its plate at 45622, the hudText at 45623
- if(!inRing) is at 45625
- the arrow angle and distance are at 45626
- the arrow is drawn at 45627-45630
- the metres label is at 45631-45632
- the hostiles row (inRing branch) runs to about 45650
- the "hold [x] to call" else-if is at 45652 (not 45648)
The band has no distance test at all, as they said.

What they got right:
- The beacon mirror is at 28917-28935: G.active is kept if its beacon is live (break at 28922), otherwise the first live ring wins (28930).
- Pillager bot calls are at 33269-33270. The player's own call is at 28285-28287. A teammate's call (netBeaconTake) is at 63042-63058. The guest takes the host's pointer at 63012.
- The feed line at 28868-28869 is already limited to 1400 units.
- The in-world ring prompts at 45004-45062 are drawn at each ring.
- The edge arrow (extEdgeArrow, 43131) shows only a letter and metres.
- The downed overlay (45700-45722) is drawn in the centre, not on the band.
- A ring that is already pulled stays open past its closing time (28948: 'pulled: it completes'). So the mirror always leaves G.active on the ring whose clock the band prints, and measuring the gate to G.active is consistent.

What they missed:
1. Two other spots assume the band is up whenever G.beaconT is live:
   - 43350 raises the bandage use bar above the band.
   - 45439 dims the ammo card to 0.7, because "the extract line is the one hero" (cw-h103hero).
   With the band hidden for a far ring, the ammo card still dims and the use bar still jumps up for nothing. Both should use the same test as the band.
2. The case where two rings are live: the mirror keeps G.active while its beacon runs (28922). So if his own call A is far away and a bot or teammate ring B within 250 m starts or is in progress, a gate on G.active hides the band, even though there is an extract near him. The colleague's pure G.active gate cannot show B.
3. Fixture checks:
   - v32.85 (mkfixture 17490-17512) and v19.10 (68298-68318) set g.active=g.zones[0] with the player at the seed 4242 drop. If zones[0] is more than 250 m from the drop, the band is not drawn and both return 'SKIP: the extraction line was not drawn'. That is not red, but coverage is lost without anyone noticing.
   - v32.35 (mkfixture 18866) needs the literal text 'extBanFont(G.beaconT)' in drawHUD.
   - v16.30 (75848) needs "' INBOUND  '".
   - v32.36 (18858) needs 'extBanPlate(' and v32.58 (18421) needs 'extRowPlate('.
   A version that reads another ring's beaconT must keep those strings or retarget v32.35.
   - The in-ring checks are unaffected: 43711, 59425, 56745, 56912, 67376, 67420 and 58209.
4. Per-window and mode details: drawHUD binds p=G.player for this window (44102). The player 2 / guest window gets the zones from the host (63003-63010) and the pointer by index (63012), so the gate is judged per window with no special case. The band is the same in arcade (demo) and career.

TOP PILL (the computed task's question; not part of his order)
The colleague's analysis holds:
- if a beacon is live, it locks to G.active (44447-44448)
- otherwise a waypoint wins (44449-44450)
- otherwise the nearest ring with open!==false (44451-44459), falling back to G.active (44460)
- the state comes from extPillState at 43116 (not 43117) and the pulse from extPillPulse at 43125
Correction: their pill idea of "the ring this player called" has nothing to read. No ring records who called it (no field; 28285-28287 only sets G.active), so it would need a new flag set at 28286 and in netBeaconCalled. Given the code, "closest" means the smallest centre distance among rings with open!==false. A ring that is called or held counts like an idle open one. Closed rings are skipped.

Out of scope, noted only: the extraction siren (28642-28650) loops for z===G.active, and the mirror can move G.active onto a far bot's call.
## sites
- 45612 drawHUD (band above the belt): if(G.beaconT!==null&&!G.over){ : the only gate on 'EXTRACT X INBOUND Ns' and 'EXTRACT IN PROGRESS! X NS LEFT'; no distance test (colleague said 45604)
- 45613 drawHUD (band): var inRing=dist(p,G.active)<G.active.r
- 45617 drawHUD (band): colour: red '#ff5a4a' when holding and not in the ring (colleague said 45614)
- 45621 drawHUD (band): _exS = extractNowLine(letter,G.shipHold) or 'EXTRACT X INBOUND  Ns'; plate 45622, hudText 45623
- 45625 drawHUD (band): if(!inRing): amber arrow (45627-45630) and metres label (45632) to G.active at any distance; atan2/dist at 45626
- 45652 drawHUD (band): else-if 'HOLD [X] TO CALL FOR EXTRACTION': only inside G.active, so a gate on the main if leaves it alone (colleague said 45648)
- 43350 useBar placement: MISSED: lifts the bandage use bar above the band whenever G.beaconT!==null; should use the same 250 m test or it jumps for a hidden band
- 45439 drawHUD (gear/ammo card): MISSED: ammo card dims to 0.7 while G.beaconT>0 because the band is 'the one hero'; with the band hidden for a far ring it dims for nothing
- 28922 tickExtractPoints (beacon mirror): if(MZ===G.active){ mz=MZ; break; }: G.active sticks while live, so a far call of his own hides a nearer live ring B from a G.active-only gate
- 28930 tickExtractPoints (beacon mirror): if(mz.open||!G.active||!G.active.open) G.active=mz; moves the pointer to a bot or teammate ring anywhere
- 28948 tickExtractPoints (closing): a pulled ring stays open past its cutoff (continue), so G.active is always the ring whose clock the band prints
- 33269 pillager bot extraction AI: bot call sets z.beaconT=CFG.extractWait; the mirror then adopts it
- 28286 tryExtractTick: his own call: G.active=z; no field records who called a ring
- 63058 netBeaconTake: a teammate's call takes G.active unless the host has its own live call
- 63012 net state take (guest window): guest pointer follows the host's G.active index; zones synced at 63009; drawHUD uses this window's own G.player (44102), so the gate is judged per window
- 43266 extractNowLine: builds 'EXTRACT IN PROGRESS!  X  NS LEFT'
- 44447 drawHUD (top pill target): a live beacon locks the pill to G.active at any distance (assignment 44448)
- 44451 drawHUD (top pill target): else the nearest ring with open!==false by centre distance, re-picked every frame; fallback to G.active at 44460
- 43116 extPillState: pill state and tail (colleague said 43117); extPillPulse at 43125
- 43131 extEdgeArrow: off-screen open ring: letter and metres only, no in-progress text; caller at 44891
- 28638 EXTNEAR / extMine: var EXTNEAR=60 (cw-msgroute, his 10-27 order on far-exit lines); EXTBANDM=250 belongs beside it
- 18866 mkfixture v32.35: source check needs the literal 'extBanFont(G.beaconT)' in drawHUD; a version reading another ring's beaconT must keep it or retarget
- 17500 mkfixture v32.85: g.active=g.zones[0] with the player at the seed 4242 drop; if more than 250 m away, the band is not drawn and the check SKIPs, losing coverage
- 68308 mkfixture v19.10: same setup as v32.85; it would SKIP the same way
- 75848 mkfixture v16.30: source check needs the literal "' INBOUND  '" (kept by both proposals)
## proposal
For his order (band above the belt only within 250 m):

1. Next to EXTNEAR (28638), add a constant and a helper:

   var EXTBANDM=250; // metres: the band above the belt names an extraction only this close
   function extBandOn(p){ return !!(G&&p&&G.beaconT!==null&&G.beaconT!==undefined&&!G.over&&G.active&&dist(p,G.active)<=EXTBANDM*U_PER_M); }

2. Use the helper in three places:
   - 45612: if(G.beaconT!==null&&!G.over){  becomes  if(extBandOn(p)){
     Every literal the fixture checks for stays the same: extBanFont(G.beaconT), ' INBOUND  ', extBanPlate(, extRowPlate(.
   - 43350: replace (G.beaconT!==null&&!G.over) with extBandOn(p), so the use bar only lifts when the band is really up.
   - 45439: change the dim test to typeof G.beaconT==='number'&&G.beaconT>0&&extBandOn(p).
   The else-if at 45652 is unchanged and still fires inside G.active.

3. Optional follow-up for the case where two rings are live. Only if a ring B within 250 m should show while his own far call A holds G.active. The band would read the nearest live ring within 250 m, preferring G.active, and use that ring's beaconT, hold, letter and distance. That breaks the source check v32.35 (mkfixture 18866), so it needs a retarget in the same mk. It is rare, so leave it out of this ship and log it.

4. In the mk script, have the new check place the player 300 m and then 200 m from a bot-called ring. Also make sure v32.85 and v19.10 still draw the band rather than SKIP: in their setup, put the player inside g.zones[0].

For the top pill (separate order, not shipped with this): in the beacon branch at 44447, take G.active only when dist(p,G.active)<=EXTBANDM*U_PER_M. Otherwise fall through to the waypoint branch and the nearest open!==false loop. "Ring he called himself" cannot be the test without a new z.mine flag set at 28286.
## checks
New check A: a bot-called ring with its hold running, player 3000 units (300 m) from its centre and outside it: no drawn text contains 'EXTRACT IN PROGRESS!' or ' INBOUND ' on the band, and no amber band arrow. It FAILS on v35.66, as the gate requires.
New check B: the same ring with the player 2000 units (200 m) away: the band draws 'EXTRACT IN PROGRESS!  X  NS LEFT' in '#ff5a4a' and the metres label reads '200m'.
New check C: an inbound ring (beaconT 20) 300 m away: the ammo card is drawn at full alpha (45439) and the use bar is at its normal height (43350); at 200 m both behave as before.
New check D: player inside the called ring: the band draws in teal and 'N HOSTILES CLOSING IN' still draws; player inside an uncalled G.active with no beacon: 'HOLD [X] TO CALL FOR EXTRACTION' still draws (45652).
Make sure v32.85 (mkfixture 17490) and v19.10 (68298) still run and do not SKIP with 'the extraction line was not drawn'; if they SKIP, put the player inside zones[0] in their setup within the same mk.
Source checks v32.35 (18866 'extBanFont(G.beaconT)'), v32.36 (18858), v32.58 (18421) and v16.30 (75848) stay green.
Guest window (NET on, player 2): the band is limited by that window's own player distance to the host's G.active.
Seed 4242 fingerprint unchanged (ents 85/374, containers 165/593).
## risks
What he should watch for in the next playtest:
- With a far ring live (a bot's, a teammate's, or his own that he walked away from), the band above the belt is blank until he is within 250 m of that ring's centre. Until then his only cues are the top pill (it still locks to that ring), the map and the feed. A teammate's call 400 m away shows no countdown above the belt.
- With his own call A far away and a bot ring B near him, the 3-line version shows nothing above the belt even though B is in progress. That is the optional follow-up.
- The siren for G.active can still loop for a far bot call. That is out of scope.

Gate:
- v32.85 and v19.10 can quietly go to SKIP rather than red unless their setup puts the player near zones[0].
- The seed 4242 fingerprint is unaffected (drawing only).

# clock
## summary
I edited nothing. Line numbers are from the current dark_raiders.html (74269 lines) and tools/mkfixture.ps1.

1. Mismatch to flag first. The user request relayed to this run says: "extracts starting and extracts in progress should only be shown at the bottom of the screen if player is within 250m of the extract". The computed task is about splitting the score and clock card. I did the computed review, and because the relayed request takes precedence I also mapped the 250m order (last few sites, and proposal part B).

2. What the colleague got wrong or missed.
- a) CAREER is every real raid (biggest miss). careerPostBuild runs on every non-sim raid while CAREER_ON=1 (17935, 64946). So in his game arcadeScoreHud is the only top-card path. The bare-clock else branch at 44433 only runs for sim raids, or when CAREER_ON=0.
- b) The test corpus runs that else branch. tools/mkfixture.ps1 line 1427 sets CAREER_ON=0 unless the URL has ?career=1. Any check that uses __deploy plus drawHUD (v35.50 sky icon, v35.03) tests the bare clock, not the card he sees. Those checks do not cover the new layout and will not break. The new check must call arcadeScoreHud, use arcadeDeploy, or set CAREER_ON=1 itself, and uishots need ?career=1 or a DEMO raid.
- c) Line numbers off by 1 to 4.
  - Top stack: _tz=hudRes() is at 44400, fonts at 44401, _yClk at 44404, _yCmp at 44406, _yArw at 44407, _yMk at 44408. They said 44396 to 44404.
  - _yMk is dead: it is recomputed at 44433 but never read.
  - Inside arcadeScoreHud: fonts at 68390 and 68391, geometry at 68392, YOU/P2 width at 68396, streak width at 68397, pw at 68398, bot at 68399, hudPlate at 68400.
  - The arcadeScoreHud argument y is never read (tests pass 30, 60 and 80).
  - alertDraw y0=LH(96) is at 23104, not 43104. msgLayout's LH(96) is at 43727.
- d) The alert already covers the pill today (by my arithmetic at 1080p; no picture taken).
  - Score card: 16 to 122 px. Pill: about 130 to 153. Arrow: to about 165 in CAREER, 178 in DEMO.
  - The alert plate starts at LH(96) under hudZoomIn('msg') (44783), about 125 px. It never reads SCOREBOX.
  - A taller stack will put alerts over the score card itself. This is not just a new risk on the pill.
- e) v27.99 does not always fail. Its "clock sits on the score" test only finds a score drawn at 20 px or more (33771). With the colleague's plan (score at TYPE.head, 19.5 px) it passes without testing anything. If the score keeps TYPE.title (26 px), clock above score fails it.
- f) The extEdgeArrow keep-out is already too short. LH(130)*hr is about 169 px, and the CAREER/DEMO arrow already reaches about 165 to 178 px.
- g) netPadHud needs no change: it only uses the lowest bottom, and the score card stays lowest.
- h) Fixture checks they did not list, all of which still pass:
  - v23.92 at 52560: "a clock is drawn", nothing about position.
  - v23.38 at 55160: the x2 badge is in the text.
  - v23.29 at 55573: the TEAM SCORE label.
  - v23.54 at 53975: solo shows no TEAM SCORE.
- i) raidStatusDraw (47157; tiles at 47166 and 47174) has its own DEMO SCORE and RAID CLOCK tiles. That is a separate Tab panel and is not affected.
- j) The player 2 window and the same-PC second window run the same drawHUD and arcadeScoreHud (ARCADE.role 'p2'). There is no split-screen path.

3. HUDBOX and EDGEBOX. The card, the pill and the sun register no HUDBOX or EDGEBOX key. The card's only box is SCOREBOX (40394), and exactly five places use it: 40394, 40398, 44433, 60931, 68401. EXTPILL and WXICON (43115) hold state only.
## sites
- 44400 drawHUD top stack: _tz=hudRes(); 44401 fonts _fClk=FSz(TYPE.title), _fCmp=FSz(TYPE.label), _fMk=FSz(TYPE.head); 44404 _yClk=6*_tz+_hClk; 44406 _yCmp; 44407 _yArw; 44408 _yMk (dead, never read)
- 44433 drawHUD: G.arcade||G.career calls arcadeScoreHud(_yClk,_tz) and draws the sun with wxIconDraw at SCOREBOX.x+w+LH(16)*_tz, y=SCOREBOX.y+min(h/2,LH(28)*_tz), r=LH(10)*_tz. It pushes _yCmp to _arcB+8*_tz+_hCmp*1.05. The else branch (bare clock plus sun) is only reached with CAREER_ON=0 or a sim raid, never in his play, but it is what most fixture checks exercise
- 17935 careerPostBuild call: every non-sim, non-arcade raid becomes CAREER (CAREER_ON=1 at 64946; g.career=1 at 65112)
- 68386 arcadeScoreHud: the whole card. 68390: fb=FSz(TYPE.title) for the score number, fs=FSz(TYPE.label) for the label. 68391: clock font fc=FSz(fin?TYPE.title:TYPE.head). 68392: top=16z, pad=12z, labelY, scoreY, clockY. The argument y is unused
- 68396 arcadeScoreHud: 2P YOU/P2 column width (side); 68397 streak width sw; 68398 half width pw; 68399 bot (includes the clock row when the clock is on)
- 68400 arcadeScoreHud: hudPlate(cx-pw,top,pw*2,bot-top): the one plate
- 68401 arcadeScoreHud: SCOREBOX.g/x/y/w/h written (the only box the card registers)
- 68402 arcadeScoreHud: label: 'SCORE' (solo or CAREER) or 'TEAM SCORE', in UIC.tx_2
- 68403 arcadeScoreHud: score number nm, font fb
- 68404 arcadeScoreHud: clock: clockPopIn (1.22 pop, 51246) in the final minute, red #ff5a4a when fin, else #cdd6dd, m:ss at clockY
- 68405 arcadeScoreHud: 2P: YOU n and P1/P2 n at cx+w/2+24z, beside the score row (host and p2 windows)
- 68406 arcadeScoreHud: streak xN in gold, right-aligned at cx-w/2-10z; 68407 returns bot
- 44466 drawHUD extract pill: pill text and state (extPillState); 44467 _epw, _eph, _xpx, _xpy=_yCmp-_hCmp*1.05; 44470 hudPlate; 44473 hudText; 44474 EXTPILL state only, no rectangle stored
- 44475 drawHUD compass arrow: _az=_tz*(arcade?ARCADE_ARW:1) (ARCADE_ARW=2 at 68415); 44476 translate W/2,_yArw(+8*_tz in DEMO)
- 43189 wxIconDraw: sky icon; WXICON.id/x/y written at 43194; no box
- 43115 globals: EXTPS, EXTPILL, EXTARROW, WXICON declared
- 40394 SCOREBOX / wlUnder: SCOREBOX declared. wlUnder at 40397 to 40399 hides world name labels over EDGEBOX.trcol, HUDBOX.cond or SCOREBOX. A new clock card must be added here or labels show through it
- 60931 netPadHud: pad-lost card placed below max(HUDBOSSB,HUDGIFTB,HUDMSGB,SCOREBOX bottom). The score card stays lowest, so no change is needed
- 43150 extEdgeArrow: fixed top-centre keep-out W/2-LH(170)*hr, width LH(340)*hr, height LH(130)*hr (about 169 px at 1080p). It is already shorter than the CAREER/DEMO arrow bottom (about 165 to 178 px). HUDBOX/EDGEBOX loop at 43144
- 43238 ringBadgeSlide: keeps clear of HUDBOX, EDGEBOX, NETTEAMBOX and G.cornerBox only; called at 44864 for ring badges. It does not see SCOREBOX
- 43727 msgLayout: HUDFEEDT=LH(96); the alert band starts at a fixed height and never reads SCOREBOX; runs at 44113, before the top stack
- 23104 alertDraw: y0=LH(96), drawn inside hudZoomIn('msg',W/2,0) at 44783: about 125 px at 1080p, centred, so it already overlaps the CAREER pill
- 47157 raidStatusDraw: Tab panel tiles DEMO SCORE (47166) and RAID CLOCK (47174); a separate path, not affected
- 1427 mkfixture header: CAREER_ON=0 unless ?career=1, so __deploy checks test the bare-clock branch, not his card
- 33746 mkfixture v27.99: clock 18 px or more at 5:00 and 25 px or more in the last minute. The test at 33771 fails only when a score of 20 px or more is drawn and the clock is not below it. It fails if the score stays TYPE.title, and passes without testing anything if the score drops to TYPE.head. Retarget it to clock above and clock px greater than score px
- 24281 mkfixture v30.96: one plate at y<=0 covering label, number and clock (filter at 24294). Already known-red (stable-known-red.txt line 64); stays red; retire or retarget it
- 21369 mkfixture v31.50: world labels hidden over the score plate. It finds the plate at y0<=1 (about 21456), so it is known-red (line 63). It also arms '14 px under' and '14 px right of' the plate, so the clock card must go into wlUnder
- 6241 mkfixture hudtv: arcadeScoreHud(30,hudRes()) in both seats: SCOREBOX.y>=16, and 3 labels TEAM SCORE / YOU / P1|P2 at 16 px or more. Passes if SCOREBOX stays the score card
- 6938 mkfixture v35.50: sky icon within W*0.15 of the centre and y<H*0.12. Runs in a CAREER_ON=0 raid (else branch), so the new layout does not affect it
- 9331 mkfixture v35.03: fakes SCOREBOX as 240x90; not affected
- 24718 mkfixture v30.83: SCORE label ink at least 6 px from the top; passes (it moves lower)
- 48499 mkfixture v25.13: CAREER arcadeScoreHud draws 'SCORE' and '150' (48503); passes
- 51677 mkfixture final-minute red: DEMO clock red at 1:00 and not at 1:01, read from the arcadeScoreHud fill; passes if the clock keeps #ff5a4a
- 52560 mkfixture v23.92 / v23.38 / v23.29 / v23.54: text-only checks (m:ss drawn, x2 badge at 55160, TEAM SCORE at 55573, solo has no TEAM SCORE at 53975); pass
- 7993 mkfixture v35.30 FOUR: ring badge measured relative to the extract pill text; passes
- 45612 250m order: bottom extract band: if(G.beaconT!==null&&!G.over): 'EXTRACT X INBOUND Ns' or extractNowLine (43266, 'EXTRACT IN PROGRESS! X NS LEFT') at _exBan (45610) with extBanPlate. The arrow and distance row when outside the ring is at 45627 to 45634; the 'N HOSTILES CLOSING IN' row is at 45643 to 45648. There is no distance gate today
- 21152 250m order: constants: U_PER_M=10 and metres(); 250 m is 2500 world units. The top-lane say('EXTRACT IN PROGRESS!') at 28869 is already gated at 1400 units
## proposal
A. Score and clock order. The change goes in arcadeScoreHud (68386 to 68408) and the line at 44433. The function keeps returning the bottom of the lowest card, so the pill and arrow push-down at 44433 works without change.

1. Clock card on top, only when raidClockOn().
- Font: fc=FSz(TYPE.huge,z), about 39 px at 1080p, at all times.
- Final minute: red, plus clockPopIn. The size stays the same, so the score card does not jump down a minute before the end. Today the plate grows at fin.
- Geometry: cTop=16z, cPad=10z, clockY=cTop+cPad+ch, cBot=ceil(clockY+ch*.25+cPad).
- Width: half width cw=ceil(max(70z, measureText('10:00')/2+cPad)), measured once, so the card does not jitter as the digits change.
- Draw it with hudPlate(cx-cw,cTop,cw*2,cBot-cTop,null,HUDC.plate).
- Record a new global CLOCKBOX {g,x,y,w,h}, declared beside SCOREBOX at 40394. Set CLOCKBOX.g=null when the clock is off.

2. Score card below it.
- top=clock?cBot+6z:16z. The score number keeps fb=FSz(TYPE.title), about 26 px. That keeps it readable at the party and below the clock size, which is the order.
- labelY=top+pad+lh, scoreY=labelY+8z+h, bot=ceil(scoreY+h*.25+pad).
- Remove the clock line at 68404 from this card. Keep the YOU/P2 column (68405) and the streak (68406) unchanged.
- SCOREBOX keeps meaning the score card. That keeps 6241 and netPadHud valid.
- Alternative: drop the score to TYPE.head (19.5 px). That costs about 27 px less height, but shrinks the party's main number without being asked.

3. Sun icon at 44433. Draw it beside the clock card when CLOCKBOX.g===G: x=CLOCKBOX.x+CLOCKBOX.w+LH(16)*_tz, y=CLOCKBOX.y+CLOCKBOX.h/2. Otherwise keep the current SCOREBOX placement.

4. Pill and arrow: no code change. They follow the returned bot.

5. wlUnder (40398): add `||(CLOCKBOX.g===G&&wlHit(CLOCKBOX,X,Y,X1,Y1))`.

6. extEdgeArrow keep-out (43150). Store the real stack bottom as a global HUDTOPB at the end of the arrow draw (about 44480), as the arrow centre plus 6*_az. Use h=max(LH(130)*hr, HUDTOPB+LH(6)). This fixes the already-short keep-out too.

7. The else branch (bare clock, CAREER_ON=0 or sim raids only): leave it as it is. Then v35.50, v35.03 and the other __deploy checks do not move.

8. Fixture.
- Retarget v27.99: clock drawn above the score, and clock px greater than score px.
- Leave v30.96 and v31.50 known-red, or retarget them to two plates.
- New check (solo DEMO, 2P DEMO host and p2, and CAREER with CAREER_ON=1, at 1080p and 4K):
  - two hudPlate calls at top centre, and the clock plate bottom at or above the score plate top;
  - the m:ss text above the score text;
  - clock font px greater than score font px;
  - the EXTPILL text baseline below SCOREBOX bottom;
  - wlUnder true inside CLOCKBOX.
- It fails on today's build, where the clock sits under the score on one plate.

Height cost at 1080p: the stack grows about 49 px. The score card spans about 91 to 171, the pill about 179 to 202, and the arrow ends near 227 in DEMO.

B. The 250m extract order (the relayed request).
- At 45612, keep the outer if, and wrap its drawing in `if(dist(p,G.active)<=250*U_PER_M){...}`. This hides INBOUND, EXTRACT IN PROGRESS, the arrow and distance row, and the hostiles row beyond 250 m.
- Keep it inside the outer if, so the else-if "HOLD [X] TO CALL" (in the ring only) cannot fire by mistake.
- Gate on the player's own window position. In 2P each window has its own G.player, so a teammate's far call stays hidden.
- New check: beacon inbound and holding, player at 240 m shows the band, at 260 m shows none of the three lines. It fails on today's build.
## checks
tools/mkfixture.ps1 33746 v27.99 (assertion 33771): retarget to clock above score and clock px > score px
tools/mkfixture.ps1 24281 v30.96: known-red (stable-known-red.txt line 64); still red with two plates; retire or retarget
tools/mkfixture.ps1 21369 v31.50: known-red (line 63); needs CLOCKBOX in wlUnder for its label arms
tools/mkfixture.ps1 6241: SCOREBOX.y>=16 and 3 score labels >=16px in both seats; passes if SCOREBOX stays the score card
tools/mkfixture.ps1 6938 v35.50: runs with CAREER_ON=0 (else branch); unaffected
tools/mkfixture.ps1 9331 v35.03: fake SCOREBOX; unaffected
tools/mkfixture.ps1 24718 v30.83, 48499 v25.13, 51677 final-minute red, 52560 v23.92, 55160 v23.38, 55573 v23.29, 53975 v23.54, 7993 v35.30 FOUR: pass
tools/mkfixture.ps1 1427: CAREER_ON=0 by default; a new check must set CAREER_ON=1 or use arcadeDeploy or arcadeScoreHud directly
New check A: clock plate above score plate with no overlap, clock px > score px, pill below SCOREBOX, wlUnder covers CLOCKBOX; solo DEMO, 2P host and p2, CAREER; 1080p and 4K
New check B: bottom extract band (45612) drawn at 240 m and absent at 260 m, for both INBOUND and EXTRACT IN PROGRESS
uishots at 1080p and 4K with ?career=1 or a DEMO raid: normal, final minute, alert up, 2P p2 seat
## risks
1. Alerts on the score card. The alert and location tag plate starts at a fixed LH(96), about 125 px at 1080p (23104, 43727), and does not read the top stack. By my arithmetic it already covers the CAREER pill today. After the split it would cover the score card. If uishots with an alert up show this, make msgLayout use HUDFEEDT=max(LH(96), last frame's HUDTOPB/z+LH(6)). That moves the alert and feed band down, which is a visible change.

2. The larger 39 px clock plus the 1.22 pop needs width headroom. Measure '10:00', not the live digits.

3. In the 2P window the YOU/P2 column hangs right of the score card. The sun moves to the clock card, which is narrower and above, so it no longer meets that column. Check the p2 seat in pictures.

4. Most of the corpus runs with CAREER_ON=0, so a green gate says little about the CAREER card he plays. The new check and the uishots recipe must force CAREER or DEMO (?career=1 or arcadeDeploy).

5. v27.99 changes meaning: it fails if the score stays 26 px, and passes without testing anything if the score drops below 20 px. Retarget it either way.

6. Feel: he should watch that the score still reads from the couch, and that the taller stack does not cover enemies near the top of the screen.

7. The 250m gate hides the INBOUND countdown from a player who is far away while his teammate called the ring. That matches the order, but he should confirm it feels right in 2P.

# pops
## summary
The relayed user request for this run is a different order: "extracts starting and extracts in progress should only be shown at the bottom of the screen if player is within 250m of the extract". The computed task asked about SP pops, so this answer covers only the SP order. Nothing was edited. The extract order still needs its own job.

I checked the colleague's map against the current dark_raiders.html. Most line numbers are right (feedLabel 23279, feedMoney 23292 with the suffix at 23397, MSGLEAN 23482, label 23781, scoreBonus 67684 with its label at 67689, scoreKill label 67698, arcadeKill label 67723, styMedal 67774, the plate 67939, flowChip 65774-65781, vault 64926-64936, the score card 68386). There is only one kill credit path: 31664 calls arcadeKill or careerKill, after the kill line from feedKillEnt at 31658, so DEMO, CAREER and the player 2 window all reach the same pops.

Corrections and misses:
1. VAULT OPEN at 29706 is said as kind 'obj'. msgReach (23493) returns '' for obj unless the line matches MSGOBJ (23484), and 'X VAULT OPEN' does not match. So the line and its '+500 SP' sub only go to the run log; they are never on screen. The only visible vault score is the '+500 SP' float at the door (64929 / 64934), plus the lone gold money line that float makes in the feed via feedMoney. Removing the sub is cosmetic. mkfixture 46508 still asserts the returned sub contains '500'.
2. 'ext' alerts (GOAL DONE / BOUNTY CLAIMED / STRONGHOLD CLEARED from flowChip at 65780, and the streak callouts) are top banners via alertSay (22686). A banner that waits too long in the queue goes to the feed through alertToFeed (22671), with its sub attached when the sub is four words or fewer (23276). This is a second draw path for the flowChip '+N SP' sub.
3. Ordering quirk. flowKill runs before the kill label (67716, 67706). If a run goal completes on a kill, flowChip's '+N SP' float reaches feedMoney first and takes the kill line's gold suffix slot. The kill's own '+N SP' then becomes a lone money line. Both go away when the floats go.
4. In the player 2 window, GOAL DONE (67373, goalsNetTake) and STRONGHOLD CLEARED (67267) are said from net state with no SP figure. They have no float, so nothing there needs to change.
5. Missed: the bounty reward is shown as '$'. 'BOUNTY ON THE MAP' alert, sub 'HE HUNTS YOU  $N' (66320); the player 2 window version is at 67131; the world tag over the hunter is 'BOUNTY  $N' (66350). BOUNTY.pay is paid into the score as SP through flowChip (66329), so this is score shown as money, which breaks the '$ for money, SP for score' rule. It is an announcement of a reward, not an earn pop. It is a judgement call under this order, and a wording bug either way.
6. The feedSay 'pick' branch (23262-23268) cannot be reached in play. say() sends every 'pick' line to pickSay (23571) before feedSay (23588). Only check 30360 calls it directly. The pickup stack itself is pickSay (22758) with the _ptags tag from 26912 and the 'SCRAPPED +N SP' tag from 67603. Leave all of it alone.
7. The medal emblem row is only pushed when scoreBonus pays (67776). The scoring must stay or the medals vanish. Only the label at 67689 and the plate figure at 67939 should go.
8. The combo ring at the cursor (styleDraw 67957) shows no number since cw-nomult. It is not a score pop.
9. Money labels that stay: '+$N' at 16111 (helping a stray pillager pays real money).
10. Standing panels that show '+N SP' are not pops: the RUN INFO goal rows (44684), goalsHud (65814), the tab card (67384), and the RSTAT 'DEMO SCORE' / 'RAID SCORE' tiles (47166, 47168).
11. The score card (68386-68409) has no count-up and no flash. The only animation is clockPopIn on the final-minute clock. The colleague was right.
12. Confirmed dead: ARCADE.banner is set only in arcadeExtracted (65344), which has no callers. So the EXTRACTED! banner (68433-68448) and the PLAYER n EXTRACTED +N SP line never show; 68381 can only fire on a partner 'x' event, which only the dead path sends.
## sites
- 67723 arcadeKill: DEMO kill: world float '+N SP' (y-20). Through feedLabel->feedMoney it becomes the gold suffix on his kill line, or a lone money feed line. PURE SP. Kill line stays (feedKillEnt 31658)
- 67698 scoreKill (via careerKill 67704): CAREER kill: same '+N SP' float and suffix. PURE SP
- 31664 entity death: The only call site for arcadeKill/careerKill (gated by e.byPlayer), so it covers both windows and both modes
- 23287 feedLabel: Regex /^\+(\$..|N SP)$/ sends a bare '+N SP' label to feedMoney; 23285 drops ' +N SP' (medal); 23288 MSGLEAN return. The check at 30355-30359 calls this directly, so keep it
- 23292 feedMoney: Attaches the figure to the newest own kill line under 0.8 s old (Ln.money, drawn 23397); otherwise feedAdd 'money' line (23295)
- 67689 scoreBonus: World float 'TXT +N SP' (FINISHER 24891, CLOSE CALL 33493, medals with txt ''). Under MSGLEAN no feed line. PURE SP. Removing it also removes the FINISHER/CLOSE CALL words, because their callers only draw the plain word when scoreBonus returns 0
- 24891 finisher: 'FINISHER +100 SP' via scoreBonus; plain 'FINISHER' fallback only when no score mode
- 33493 closeCall: 'CLOSE CALL +25 SP' via scoreBonus; plain fallback at 33494 only when no score mode
- 67776 styMedal: Medal: scoreBonus float ' +N SP'. The emblem is pushed only if scoreBonus paid. feedMedal (23297) is a no-op under MSGLEAN. Callers 67800/67801/67805/67808/67819/68251/68311
- 67939 styMedalDraw: Name plate under the newest emblem: name + '+N SP' figure (fg). Drawn from 44176. The figure is PURE SP; the emblem and name are the approved medal
- 65780 flowChip: ext top banner (alertSay): head + sub 'detail  +N SP' for GOAL DONE 65792 / BOUNTY CLAIMED 66329 / STRONGHOLD CLEARED 66735. If it waits too long in the queue, alertToFeed (22671) writes it to the feed with the sub. Remove only the '+N SP' part
- 65781 flowChip: World float '+N SP' over the player (y-44), plus a feedMoney line or a kill-line suffix (flowKill runs before the kill label). PURE SP
- 64929 arcadeVaultPay (CAREER): World float '+500 SP' at the door, plus a feedMoney lone line. PURE SP. The returned sub (64930) is never on screen
- 64934 arcadeVaultPay (DEMO): Same float; sub at 64936 is never on screen
- 29706 keycard door open: say('X VAULT OPEN','obj',_vop): msgReach (23493) returns '' because MSGOBJ (23484) does not match, so the line is run log only. Correction: not a visible alert. Its '+500 SP' sub is not drawn
- 22671 alertToFeed: Second draw path: an ext/warn banner that waited too long is said as 'obj' into the feed with its sub (shown if 4 words or fewer, 23276)
- 66320 bounty event start: MISSED: warn alert 'BOUNTY ON THE MAP', sub 'HE HUNTS YOU  $N'. BOUNTY.pay is SP (paid by flowChip 66329) but is shown as $. Reward announcement, not an earn; judgement call plus a wording bug
- 67131 player 2 window bounty: MISSED: same alert on the partner window, 'HE HUNTS <HOST>  $N'
- 66350 bounty world tag: MISSED: 'BOUNTY  $N' drawn over the hunter. Score shown as $. Standing tag, judgement call
- 67373 goalsNetTake: Player 2 window: say('GOAL DONE','ext',{sub:gl.t}), no SP figure. Nothing to change
- 67267 stronghold net take: Player 2 window: 'STRONGHOLD CLEARED' sub 'STRONGHOLD', no SP. Nothing to change
- 65211 arcadeDied: warn alert 'SCORE LOST' sub '-N SP' (2P demo death). Loss, not earn; judgement call
- 69728 arcadeHiSay: ext alert 'NEW HIGH SCORE' sub 'SCORE N SP' (total). Judgement call
- 67725 arcadeKill streak: DOUBLE KILL..UNSTOPPABLE ext banner, sub 'xN' (also 67700 career; TEAM COMBO say 68312). Multiplier only: kill feedback, stays
- 16111 stray helped: '+$N' label: real money, not score. STAYS
- 26912 grantLoot: Arcade valuable pickup tag '+N SP' goes to pickSay. PICKUP STACK: NEVER TOUCH
- 67603 arcadeGunLoot: 'SCRAPPED +N SP' pickup tag. NEVER TOUCH
- 23266 feedSay pick branch: SP pick becomes a money row. Unreachable in play (say routes pick to pickSay at 23571); only check 30360 reaches it. NEVER TOUCH
- 44684 RUN INFO goals: Standing '+N SP'/DONE rows (also goalsHud 65814, tab card 67384, RSTAT score tiles 47166/47168). Panels, not pops
- 68386 arcadeScoreHud: Top-centre score card: SCORE/TEAM SCORE, figure, YOU/P1/P2 split (68405), streak 'xN' (68406). No count-up or flash; only the final-minute clockPopIn. STAYS
- 65344 arcadeExtracted (dead): Only setter of ARCADE.banner; no callers, so the banner at 68433-68448 and the 68381 PLAYER n EXTRACTED +N SP line are dead
## proposal
Before any build, the orchestrator should confirm which order this run serves. The user's relayed request is the extract-banner 250 m order, not this SP order.

For the SP order, the colleague's plan stands, with these fixes:
1. Drop the kill floats in arcadeKill (67723) and scoreKill (67698). Keep feedLabel and feedMoney as they are: they become idle in play, and check 30355-30359 still calls them.
2. In scoreBonus (67689), drop the label but keep the scoring (styMedal at 67776 needs the paid return). Change FINISHER (24891) and CLOSE CALL (33493-33494) so the plain word is always drawn. Today it is drawn only when scoreBonus returns 0.
3. flowChip: drop the float (65781) and the '  +N SP' tail of the sub (65780), keeping 'detail'. This also cleans the alertToFeed copy.
4. arcadeVaultPay: drop both floats (64929, 64934). The returned sub is never on screen (29706 obj line is run log only), so either keep it to spare check 46508 or drop it and retarget that check.
5. Medals: keep the emblem and name, and drop the '+N SP' figure from the plate (67939). No check asserts the figure.
6. Decide the bounty separately. Either drop the '$N' reward from 66320 / 67131 / 66350, or at least make it SP. Leave it unless he asks, since it is a reward announcement; but it is a $-vs-SP wording bug, so it is worth a small fix.

Leave alone: the pickup stack (26912, 67603, pickSay, the 23266 branch), the kill lines, money labels such as 16111, the standing goal panels, the score card, and the streak callouts.
## checks
mkfixture v23.38 arcade15: 55164 hasLbl, 55177 +50 popup, 55183 +100 popup (RED if kill float removed); 55211 control stays green
mkfixture v23.56 arcade31: 53839 hasLbl, 53881 crawler kill popup +50 SP (RED)
mkfixture v25.54 career vaults: 46505-46508 VAULT OPEN sub carries 500 (red only if the returned sub is dropped)
mkfixture v27.38 partyp1: 36131 header, TWO name plate (safe), SEVEN 36202-36204 one feed line per medal (already at odds with MSGLEAN)
mkfixture v26.84 party1 FIVE about 39257-39258 medal name drawn (safe)
mkfixture v28.81 cw-feedsp 30344, 30355-30361 direct feedLabel/feedSay routing (safe if functions kept)
mkfixture v29.03 cw-feedall 29587-29588 bare CLOSE CALL makes no feed line (safe)
mkfixture v27.98 33804, v26.73 flow3 39943, v26.63 feel15 40583-40615, v28.51 31179, v28.35 31992: payouts only (safe if scoring kept)
mkfixture v27.94 snd3 34028-34032 styMedal sounds (safe if scoreBonus still pays)
mkfixture 29269 '+50 SP' sample text only (safe)
## risks
Checks in tools/mkfixture.ps1 (grep only) that go red if the pops are removed:
- v23.38 arcade15 (header 55160): hasLbl 55164; 55177 'no +50 popup for the first kill' and 55183 'no +100 popup in G.labels'. These go RED. The control at 55211 (a normal raid shows no popup) keeps passing.
- v23.56 arcade31 (header 53836): hasLbl 53839; 53881 'the crawler kill popup is not +50 SP' goes RED. 53867 (pickup tag) and 53874-53875 (HUD score) stay green.
- v25.54 career vaults: 46505-46508. Still green if arcadeVaultPay keeps returning {sub:'+500 SP'}; RED if the sub is dropped.
- v27.38 partyp1 (header 36131): TWO only asserts the name on the plate, so dropping the figure is safe. SEVEN at 36202-36204 expects one feed line per medal; feedMedal is already null under MSGLEAN, so it is probably already red or known-red. Unchanged by this fix.
- v26.84 party1 FIVE (about 39257-39258): asserts the medal name is drawn, not the figure. Safe.
- v28.81 cw-feedsp (30344, 30355-30361) calls feedLabel/feedSay directly. Safe as long as those functions stay.
- v29.03 cw-feedall at 29587-29588 asserts a bare CLOSE CALL label makes no feed line. Safe; drawing the plain word as a world label does not create a feed line under MSGLEAN.
- v27.98 (33804), v26.73 flow3 (39943), v26.63 feel15 (40583-40615), v28.51 (31179) and v28.35 (31992) check score payouts only. Safe if scoring is kept.
- v27.94 snd3 (34028-34032) calls styMedal for medal sounds. Safe if scoreBonus still pays.
- 29269 uses '+50 SP' as sample text only.

All of these are v23-v29, so probably outside the newest ~80 the gate runs, but the robots and full corpus will report them. Retarget 55177, 55183 and 53881 to assert there is NO SP popup.

Feel: kills lose the gold number at the body and on the kill line. He should watch whether kills still feel rewarding with only the score card ticking (it has no count-up or flash to make up for it). If the FINISHER and CLOSE CALL callers are not changed, those words vanish entirely.

# far
## summary
The colleague's map is mostly right. The cause they found is correct: the extraction band above the belt in drawHUD (dark_raiders.html 45612 to 45650) is gated only by G.beaconT!==null&&!G.over and never checks distance. The beacon mirror at 28930 makes any live ring G.active: a bot call (33269), a teammate call (63058) or, on the P2 window, the host's call synced at 63009 and 63012. So "extract in progress!  b  30s left" with "327m" shows from anywhere on the map. Corrections and misses:

(1) The 'ext' say() lines do NOT go to the bottom-left feed. say() at 23572 sends kind crit, warn and ext to alertSay, which is the TOP alert banner (alertDraw 23103, y0=LH(96)). They only drop into the bottom-left feed (feedRect 23374) through alertToFeed (22671) when they wait more than 2.5 s or are pushed out. So EXTRACTION CALLED (28346, 63060), EXTRACT IN PROGRESS! (28869) and EXTRACTION MISSED (28899) are top-of-screen lines, not bottom ones.

(2) The one real bottom-of-screen "starting" feed line is 'PILLAGER BOT CALLED EXTRACTION' at 33275. It is kind 'info', ranked 'b' by MSGKEEP (23488), and drawn in the bottom-left feed. Its reach is chatNear (31085): under 900 u, or canSee, whose range is VF()=viewFar 620 x weather x optics. That is normally well under 2500 u but is not an explicit 250 m cap.

(3) MISSED: line 45439 dims the ammo card to 0.7 whenever G.beaconT>0, because "the extract line is the one hero". With the band hidden far away, the ammo card would still dim for nothing. It should read the same predicate.

(4) MISSED: fixture check v34.89 (tools/mkfixture.ps1 9931, the staging at 10165 to 10175) sets g.beaconT=40 without placing the player, in career, demo and 'second window' modes. It FAILS (not SKIPs) with 'no extract countdown drew with the ship called' if the spawn is more than 2500 u from g.active. v34.29 (11835) would FAIL on 'the ammo card is at 1 while the ship is inbound' if fix 3 is applied, since it stages g.beaconT=20 with no position.

(5) v34.09 (12354) does not lose its callout. It also sets g.active.beaconT=8, so the on-ring prompt loop (45013 to 45029) calls hudPrompt 'EXTRACT A INBOUND 8s'. w2s (36054) never returns null and there is no screen cull, so fillText still runs off screen and matches /^extract\b/. The check stays green, but it no longer tests the band.

(6) Line corrections: the CLOSING and CLOSED sayWhenFree calls that use extMine are at 28946 and 28951, not 28914 and 28920. The landing say is at 28869 (its gate is at 28868). The teammate call say is at 63060 (G.active is set at 63058).

(7) Extra source-text checks the edit must keep:
- 18410 needs the exact text 'extRowPlate(_exH,W/2,_exRow,_exR,_exBW)' in drawHUD.
- 18421 and 18850 need 'extRowPlate(' and 'extBanPlate(' in drawHUD.
- 75848 needs "' INBOUND  '".
- 97939 counts extractNowLine( call sites.

Confirmed:
- The world prompts and ring badges are drawn at the ring's own screen position. The badge loop culls at 44828, and the closed-ring skip at 44840 is 800 u.
- The edge pill extEdgeArrow (43131) shows only the letter and metres, never a countdown, and only for rings just off the side of the screen.
- No ring has an owner or caller flag. netCallAt (63037) exists only on the linked P2 window, for 1.5 s.
- Each window (host and P2) runs its own drawHUD with p=G.player (44102), so one gate covers P2, arcade/demo and career alike.

Distance: dist() (10697) is plain Euclidean on the flat sim x/y, measured from the player to the ring CENTRE (not its edge). U_PER_M=10 (21152) and metres(u)=round(u/10), so 250 m = 2500 world units. The band's own arrow readout uses the same centre distance, so with the gate the band never shows more than '250m'. EXTNEAR=60 (600 u, 28638). extMine (28639) counts any ring with a live beacon as 'mine', so it must not be reused here.
## sites
- 45612 drawHUD bottom band: if(G.beaconT!==null&&!G.over){ is the only gate on the whole bottom band (headline, arrow, metres, hostiles row). It has no distance test. This is the line to change.
- 45621 drawHUD bottom band: _exS = holding ? extractNowLine(_exL,G.shipHold) : ('EXTRACT '+_exL+' INBOUND  '+ceil(G.beaconT)+'s'). These are the in-progress and inbound ('starting') headlines. extBanPlate is at 45622 and hudText at 45623.
- 45625 drawHUD bottom band: if(!inRing){ amber arrow + metres(_ed)+'m' } (45626 to 45632): the '327m' he saw. The else branch (45633 to 45649) is the HOSTILES CLOSING IN row drawn by extRowPlate. The source text 'extRowPlate(_exH,W/2,_exRow,_exR,_exBW)' must stay exactly as written (fixture 18410).
- 45651 drawHUD bottom band: } else if(!G.over&&dist(p,G.active)<G.active.r){ HOLD [X] TO CALL. This runs only in the ring. If the gate is folded into the 45612 condition, this branch still cannot fire for a far live beacon, because dist > r.
- 45439 drawHUD ammo card dim (MISSED): if(typeof G.beaconT==='number'&&G.beaconT>0) ctx.globalAlpha=0.7: the ammo card steps down because the band is the 'hero'. Without the same distance gate it dims while nothing is drawn at the bottom.
- 43350 drawUseBar lift: (G.beaconT!==null&&!G.over)||(in ring) lifts the use bar over the band. The first half should become the new predicate.
- 47351 useBandBox lift: The same lift test, for the compact controls list dock. It must change together with 43350 and 45612, or the list flashes or leaves a gap (fixture v34.89 checks this).
- 28930 tickExtractPoints beacon mirror: if(mz.open||!G.active||!G.active.open) G.active=mz; G.beaconT=mz.beaconT; (28926 to 28935). Any live ring becomes G.active, whether a bot, the host or a teammate called it. Root cause; not changed by this order.
- 63012 netWorldTake (P2 window): P2's window takes the host's G.active and G.beaconT (ring state synced at 63009). The host's far call fills P2's band too. The same drawHUD gate covers it, because p is P2's own G.player.
- 63058 netBeaconTake (host): A teammate's call sets G.active=Z and G.beaconT on the host. The say at 63060 'EXTRACTION CALLED' (kind ext) is a TOP alert-banner line with no distance gate. It reaches the bottom-left feed only through alertToFeed overflow (22671).
- 33275 raider AI ring call: say('PILLAGER BOT CALLED EXTRACTION','info',...) gated by chatNear (31085: <900 u or canSee, range VF()=viewFar 620 x weather x optics). It is kind info, ranked b by MSGKEEP (23488), and goes to the BOTTOM-LEFT feed. This is the one bottom 'starting' line outside the band.
- 23572 say / alert routing: if(msgAlertK(k)){ ... alertSay(m,k,o); return; } sends kind crit, warn and ext to the top alert banner (alertDraw 23103, y0=LH(96)), not the feed. The colleague's claim that ext lines go to the bottom-left feed is wrong except on overflow.
- 28346 tryExtractTick own call: say('EXTRACTION CALLED','ext',...): his own call, made from inside the ring. Top banner. No change needed.
- 28868 tickExtractPoints landing: if(dist(p,z)<1400){ ... say('EXTRACT IN PROGRESS!','ext') at 28869 }: top banner, already within 140 m. No change needed.
- 28898 tickExtractPoints missed: EXTRACTION MISSED (say at 28899), gated at dist<1400. Top banner. Fine.
- 28946 close warnings: sayWhenFree CLOSING (28946) and CLOSED (28951), with reach:extMine(cz)?undefined:0. The colleague cited 28914 and 28920, which is wrong.
- 28639 extMine / EXTNEAR: extMine(z) is true for G.active, for any ring with a live beacon, or within EXTNEAR*U_PER_M (60 m = 600 u). Because 'any live beacon' counts as mine, it is useless for this gate.
- 45013 on-ring prompts: The loop draws hudPrompt(extractNowLine or 'EXTRACT L INBOUND Ns') at w2s(ring) for every live ring, at any distance, with no screen cull (w2s at 36054 never returns null). It is visible only when the ring is on screen, but fillText still runs off screen, which keeps fixture v34.09's callout list non-empty.
- 44828 ring badge loop: if(!zs||zs.x<-90||zs.x>W+90||zs.y<-40||zs.y>H+40) continue: badges show only for rings on screen. The skips at 44831 and 44837 assume the band shows while he stands in the ring, which still holds (in the ring is well within 2500 u).
- 43131 extEdgeArrow: Edge pill: 'b 152m' plus an arrow, no countdown. It is reached only through _zEdge (44862) for rings just off the side of the screen, and may sit on any edge. Not part of this order.
- 43227 zoneBadge / extractNowLine: Text builders only (43227 and 43266). Leave them alone. Keep the number of extractNowLine( call sites (fixture 97939).
- 21152 U_PER_M / metres / dist: U_PER_M=10; metres(u)=round(u/10); dist (10697) is Euclidean from the player to the ring centre in world units. 250 m = 2500 u.
## proposal
Drawing only, no sim change.
1) Next to EXTNEAR (after 28639) add:
var EXTSHOW=250;   // metres
function extBandOn(p){ return !!(G&&p&&G.active&&G.beaconT!==null&&G.beaconT!==undefined&&!G.over&&dist(p,G.active)<=EXTSHOW*U_PER_M); }
2) At 45612 change `if(G.beaconT!==null&&!G.over){` to `if(extBandOn(p)){`. The else-if at 45651 still needs dist<r, so it never fires for a far live beacon. Leave the body untouched: keep "' INBOUND  '", the extBanPlate( call and the exact text extRowPlate(_exH,W/2,_exRow,_exR,_exBW).
3) At 43350 and 47351 replace `(G.beaconT!==null&&!G.over)` with `extBandOn(p)`, so the use bar and the controls list dock lift only when the band is really drawn.
4) At 45439 add `&&extBandOn(p)` to the ammo-card dim (recommended; otherwise the ammo card dims with nothing at the bottom).
5) At 33275 add `&&dist(p,z)<=EXTSHOW*U_PER_M` beside chatNear. This line is the bottom-left feed's 'starting' line, and canSee alone has no hard 250 m cap.
6) Optional: the teammate-call EXTRACTION CALLED at 63060 is a top-banner line, so it is outside 'bottom of the screen'. To stop it ever overflowing into the bottom-left feed from far away, add reach:(G.player&&dist(G.player,Z)<=EXTSHOW*U_PER_M)?undefined:0. I recommend leaving it as is for the party, so P1 still learns that P2 called.
His own ring: G.active cannot tell his own call from a bot's or a teammate's. There is no owner field, and netCallAt exists only on the P2 window, for 1.5 s. The literal gate therefore hides the band for his own call too beyond 250 m. Keep it literal; the compass (44447), the light shaft (42015) and the edge pill still lead him back.
Fixture re-aims (each needs p placed near g.active, e.g. p.x=g.active.x+g.active.r+40; p.y=g.active.y):
- 9931 v34.89, in the 'ship called' block near 10165: FAILS, not skips, if the spawn is more than 2500 u from g.active.
- 17490 v32.85 and 68298 v19.10: they SKIP, which hides the coverage. Do NOT also set zones[0].beaconT there: that adds world-prompt and badge ' INBOUND ' lines that the ban spy would also catch.
- 11835 v34.29: only if step 4 is taken.
- 12354 v34.09: stays green through the off-screen world prompt but no longer tests the band. Re-aim it so the test means something.
New check: stage a ring with G.active set and hold 30, shipHold 30 and beaconT 0. With the player 300 m (3000 u) away, the band draws no 'EXTRACT IN PROGRESS' and no 'NNNm' text, and the use bar stays at its low position. At 200 m it draws both. It must FAIL on v35.66, where the band draws at any distance.
## checks
tools/mkfixture.ps1:9931 v34.89 (staging near 10165 to 10175): g.beaconT=40 with no player position, in career, demo and second window modes; 'no extract countdown drew with the ship called' FAILS when the spawn is more than 2500 u from g.active. Must be re-aimed (MISSED by the colleague).
tools/mkfixture.ps1:11835 v34.29: g.beaconT=20 with no position; asserts the ammo card is at 0.7 or less. Fails only if the 45439 dim is gated too. Re-aim the player near g.active.
tools/mkfixture.ps1:11819 v34.30: asserts the ammo card is at 0.65 or more while inbound. Stays green either way.
tools/mkfixture.ps1:17490 v32.85 and 68298 v19.10: g.active=zones[0], g.beaconT=30, no position; they SKIP ('the extraction line was not drawn') if far. Re-aim by moving the player only; do not set zones[0].beaconT.
tools/mkfixture.ps1:12354 v34.09: g.beaconT=8 and g.active.beaconT=8; the callout list stays non-empty through the off-screen on-ring hudPrompt (45013 to 45029), so it stays green but stops testing the band. Re-aim is optional.
tools/mkfixture.ps1:43711 v26.12, 59425 v22.41 and 56745 v22.99: the player is in the ring or at r+30. Stay green.
tools/mkfixture.ps1:94427 v12.57 and 92491 v12.93: tryExtractTick and outHint only, no draw. Unaffected (the colleague's worry about 94427 is unfounded).
tools/mkfixture.ps1:18403/18410, 18415/18421 and 18850: source checks need the exact text 'extRowPlate(_exH,W/2,_exRow,_exR,_exBW)', 'extRowPlate(' and 'extBanPlate(' inside drawHUD.
tools/mkfixture.ps1:75848 v16.30: the source must keep "' INBOUND  '".
tools/mkfixture.ps1:97939: counts extractNowLine( call sites; add none and remove none.
tools/mkfixture.ps1:6041, 70859, 95204, 96528 and 97922: zoneBadge and extractNowLine text checks. Unaffected.
tools/mkfixture.ps1:21031 and 57199: source checks for the literal say('PILLAGER BOT CALLED EXTRACTION'. Keep the literal if 33275 gains a distance test.
## risks
1. His own call: walk more than 250 m from the ring he called and the bottom countdown and its distance arrow disappear. Watch for 'lost my countdown'. 2. The root cause, the mirror at 28930, stays: the top compass and the world light shaft still lock onto a far ring someone else called. 3. Whether the seed 4242 map 0 spawn is within 2500 u of the random G.active (16588) is unknown without a run. Expect v34.89 to fail and v32.85 and v19.10 to skip until they are re-aimed. 4. The three lifts (43350, 47351, and the band at 45612) and the ammo dim (45439) must read one predicate, or the controls list or the use bar jumps or overlaps. v34.89 checks that it does not flash. 5. P2 window: the host's far call no longer shows P2 a band. Top alerts on P2 are unchanged (P2 gets no say for the host's call either way). 6. The gate measures to the ring centre, not its edge, which matches the metres the band displays.

