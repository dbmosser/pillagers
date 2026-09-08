# START HERE (written 2026-09-05, handoff from Fable to Opus; rewritten 2026-09-06 (morning) for the alpha run)

## ALPHA SHIPS TODAY, 2026-09-06, about ten hours from 07:15 (his words at 07:15). Read this block first.

**STATE (kept current by fixstate.ps1):** HEAD is v12.38 (ac876ed). The tree has **v12.39 APPLIED** and
verified on all four gates; its FULL CORPUS is running on the Browser pane tab "seed" (the only tab; the pane holds one tab since 2026-09-07 12:44).
When `window.__PROG` is finished, pass true, fail [] and only the two known skips
(v8.88, v11.24):
    bash tools/handoff/ship.sh commit 1239 cm1239.txt
then bump the HEAD line in memory dark-raiders-handoff-state.md, then
    bash tools/handoff/ship.sh start 1239 1240
and carry on down the list. Cron 866ce4db is armed every minute (re-armed 2026-09-08 07:31); re-arm if
CronList shows nothing. Resize the pane to 1920x1080 after any restart. Leave the
pane and the CPU alone while a corpus runs (a second-tab resize and heavy builds
each turned one unrelated check red). If one unrelated check goes red, re-run it
alone and straight after the new check; a bare profile left by a check is the
usual cause (see memory dark-raiders-loader-replaces-the-profile).

**THE QUEUE, ALL DRAFTED (p/f/d/a/cm in this folder), SHIP IN THIS ORDER:**

**2026-09-08 07:20 QUEUE, AFTER TWO STALLS AND THREE DIRECT ORDERS FROM HIM.** The cron died overnight (2026-09-07 17:47 to 2026-09-08 06:47, thirteen hours, v12.28 finished and uncommitted) exactly as memory dark-raiders-cron-dies-with-the-process predicts; it is re-armed as 866ce4db and CronList is now the first call of every tick, no exceptions. Earlier the same day the Fable allowance ran out and took a 12-agent review with it; he switched the session to Opus 5 at 17:30.

**HIS THREE ORDERS OF 2026-09-08, all taken:** (1) machines default Few and extraction heat default Light, shipped as 1229/v12.29; (2) delete the safe pocket entirely, drafted as 1235/v12.35; (3) his question about the alpha date, answered at 06:47 with the seven notes as the blocker list, which is why the notes outrank the audit backlog in the order below.

**THE QUEUE AS IT STANDS (renumbered 07:05 by renum1229.ps1 so his defaults could jump in; verifychain 1230..1235 from 12.29 prints chain verified; dry.ps1 1230 1235 applies every one to the scratch copy, dry game at v12.35):**
- **1229 HIS ORDER: FEWER MACHINES AND A LIGHTER EXTRACTION BY DEFAULT** (v12.29). Applied, four gates green, control on fx1228 failed on six counts, corpus running from 07:07. The harness now pins crawlerPerHouse at the old 2.5, because it pinned the two counts and not the rate and the rate is what the crawler count is floored on; without that the map fingerprint would have moved for a Settings reason. verifySafe after the change still reads 85/374 ents, 165/593 containers, parity identical.
- **1230 A CRAWLER THAT REACHES YOU BITES** (audit P1 and his standing note). REWRITTEN from three clamps to a field split (wanderT) after the 2026-09-07 review showed there are FIVE ways into a chase and the two the clamps missed are the ones HE causes by shooting; its check stages nothing on the clock.
- **1231 THE TRIGGER NEVER DIES ON A BLANK BELT CELL** (audit P1).
- **1232 HIS NOTE: THE BENCH SAYS TO HOLD THE BUTTON** (crafting; the machinery is sound, the silence was the bug).
- **1233 HIS NOTE: SPRINTING LEAVES ONE TRAIL, NOT TWO** (footprints).
- **1234 THE PEDDLER STALL IS NOT A PAUSE** (audit P2; built from a spec that was written from source and then attacked by a skeptic).
- **1235 HIS ORDER: THE SAFE POCKET IS DELETED** (v12.35). Deliberately LAST despite being his order, because it is the largest surface and the smaller builds should land first. Its patch uses a CutRx helper for three block deletions (16, 75 and 7 lines) that asserts both markers are unique and in order and prints what it removed, and it refuses to write the file if any of safegrid, safeUpKey, renderSafe or setSafe survives.

**THE FIRST PASS AT THE DELETION WAS INCOMPLETE AND THE DRY RUN CAUGHT IT**, which is the whole reason the dry chain exists: it left a six-line orphaned comment above the arming it removed, the live death-card line that printed "Safe pocket held N items" (which is actually fed by the CFG.safeSlots rebate, off since v5.57, and now says Rebate), two WHATSNEW entries describing the pocket as a live feature, and a comment pointing at a function that was gone. All folded in. THE TRAP TO REMEMBER: the world container type "safe", the secure cases in buildings and camps and the contract that searches them, shares five letters with the pocket and is a different thing; check 12.35 deploys and requires at least one secure case to be built, as the guard.

**STILL OPEN FROM HIS SEVEN NOTES:** only the reload countdown (note 7), and it is ALREADY BUILT TWICE, a ring around the cursor with a seconds readout at game 23293 and a bar over the head at 23882, both gated on CFG.cursorLoud which defaults to 1 and is not exposed in Settings. A probe is written at scratchpad probe-reload.js to prove both actually paint during a real reload; run it on the dry fixture between corpora. If both paint, the note is closed by measurement and he is told where to look, not given a third indicator.

**HIS TWO OPEN QUESTIONS, unanswered:** whether a used-up belt cell should stay dark (his answer 16) or disappear (his note of 2026-09-07); and whether he clicked or held the CRAFT button, which would confirm the 1232 diagnosis. 1232 is safe either way because it only adds words.

**QUEUE AT 17:40, MODEL SWITCHED TO OPUS 5.** The Fable weekly allowance ran out at about 13:20 and took a 12-agent draft review with it (every agent failed with a limit message, nothing lost but the run). He switched the session to Opus 5 at 17:30 and the loop resumed. SHIPPED SINCE: v12.25 (readout scale, 4ea4607), v12.26 (freebie kit at the lift, b10d93e). IN FLIGHT: v12.27 (the belt drag, four gates green at 17:32, control on fx1226 failed on all four assertions, corpus running on tab-1 since 17:33).

**THE QUEUE, IN ORDER, ALL CHAIN VERIFIED FROM 12.27 AND ALL APPLYING CLEANLY TO THE SCRATCH COPY (dry.ps1 1228 1231 at 17:38, dry game at v12.31):**
- **1228 HIS NOTE: A PEDDLER PURCHASE SAYS WHERE IT WENT** (note 4; autoBelt pins a bought gun or stim to a belt key and the backpack grid keeps a belted item off its cells, so the rifle he paid for was not where he looked). Dry-run green 13:05.
- **1229 A CRAWLER THAT SEES YOU BITES WHEN IT REACHES YOU** (audit P1 and his standing crawler note; e.cd is both the patrol wander clock and the bite cooldown, clamped to 0.3 s on the three ways into a chase, crawlers only). NOT yet dry-run on :8801.
- **1230 THE TRIGGER NEVER DIES ON A BLANK BELT CELL** (audit P1; binding the held gun to another key blanks derived cell 1 and every setHot(0) fall-back landed on it, so the first click of a raid could fire nothing). NOT yet dry-run on :8801.
- **1231 HIS NOTE: THE BENCH SAYS TO HOLD THE BUTTON** (note 3, crafting; drafted 17:37). The machinery is SOUND and the fill IS visible: the generic hover rule at CSS 459 has specificity (0,2,1) against .vbuy (0,1,0), so a held button is 8 percent amber under a 55 percent fill. What was wrong is silence: the button read CRAFT, a real click spends nothing by his v11.75 order and said nothing, an early release cancelled and said nothing. Label reads HOLD TO CRAFT, a click says to hold it, an early release says it was let go too soon. NOT yet dry-run on :8801.

**DRY RUN 17:52, ALL FIVE QUEUED BUILDS ARE DRY-RUN GREEN** on :8801 at 1920x1080 from a scratch copy at v12.32 (checks 12.29, 12.30, 12.31 and 12.32 each twice with 11.62 between). The first pass caught two of my own broken checks and both are repaired: 12.29 parked the crawler with its wander target pointing AWAY from the player, so it faced away, never sighted him and wandered off, and it is now a PAIRED measurement (the same walk in, run once with 6.5 s of clock and once with none, requiring the two times to the first bite to agree within a second) because a single deadline measured the walk in as much as the clock; 12.32 sprinted him into something and skipped, and now tries all four directions and tops up stamina so a stamina lock cannot end the run. Repairing 12.29 changed its header line, which verifychain caught in f1230 (it quotes that header) and in the d, a and cm files; all fixed, chain verified 1228..1232 from 12.27.

BETWEEN CORPORA, before shipping 1229, 1230 and 1231: rebuild the dry fixture (dry/mk.ps1 -Src dry/game.html -Dst dry/fixture.html) and run checks 12.29, 12.30 and 12.31 twice each with 11.62 between on :8801 at 1920x1080. Each control on the previous fixture must fail: fx1228 on the crawler biting at about 6.5 s, fx1229 on the blank cell keeping the highlight and never firing, fx1230 on the label having no HOLD in it and both silences being silent.

**HIS TWO OPEN QUESTIONS, both in the 13:07 report and not yet answered:** (1) a used-up belt cell, his answer 16 said it stays and goes darker, his note of 2026-09-07 says it should disappear; 1227 left the dark cell alone and gave it words, so this is his ruling to make. (2) whether he clicked or held the CRAFT button, which would confirm the 1231 diagnosis; 1231 is safe either way because it only adds words.

**STILL UNTRACED from his morning notes:** the many-footprints glitch when running vertically (note 6; the fixture stubs tickPlayerSteps and swallows blip, so restore both before measuring, see memory dark-raiders-fixture-silences-footsteps) and the reload countdown near the player (note 7, a build not a bug).

**REVIEW OF 17:34 (workflow wf_80109af7-d74, 53 agents, read-only) FOUND 17 CONFIRMED DEFECTS IN THE QUEUE AND ALL ARE FIXED.** The two that mattered: f1228 could go RED for a profile reason, because the harness pins the primary weapon and has never pinned the sidearm, and autoBelt refuses to pin a bought gun already in either hand, so a saved sidearm of rifle would have failed the check and blamed the build; and it restored the profile BEFORE ending the raid, so the payout and the gun-slot re-sort overwrote the restore (measured: it handed back equipped smg with sidearm carbine and endRaid left BOTH slots on carbine for every check after it). Both fixed in mkfixture.ps1 and in the draft, the fixture and fx1227 rebuilt, gates re-run, corpus restarted 17:50. 1229 was REWRITTEN from three clamps to a field split (wanderT) because the review showed there are FIVE ways a crawler enters a chase and the two the clamps missed are the ones HE causes by shooting, and one of the three could never fire; its check now stages nothing on the clock. 1230 got its two staging skips turned into failures, a third arm for the second fall-back, and its design entry corrected (the helper is not a no-op after X). Six more findings came back as full build specs with verbatim anchors and check bodies: **tools/handoff/specs-0907.md** (the stall freezing every extraction clock, a hit on the corpse re-downing a dead man, F held spending the self-revive, the two gun-slot faults, the merc looting hostiles). RE-COUNT every anchor before drafting from it.

**AUDIT BACKLOG:** tools/handoff/audit-0907-confirmed.md holds all 24 confirmed findings from the 07:35 read-only audit with scenarios, fix sketches and check sketches. 1229 and 1230 are its two P1s. A workflow running from 17:34 (run wf_80109af7-d74) is turning ten of the P2s into verbatim-anchor build specs with refuters; read its result before drafting any of them by hand.

**2026-09-07 12:50 REORDER FOR HIS MORNING NOTES.** The four audit drafts 1225 to 1228 (ring pointer, belt highlight, belt plan after a free run, nothing born sealed) are PARKED verbatim in tools/handoff/parked/ (their labels still read 12.25 to 12.28 over 12.24; the 1225 review fixes are folded in, 1226 to 1228 still need theirs, listed under SESSION LIMIT STALL). His notes ship first, from 1225 on: **1225 HIS NOTE: THE CORNER READOUT SCALES WITH THE MONITOR** (note 2; written 12:47, dry-run green twice on :8801 at 1920x1080 with 11.62 between; applied to the tree 12:50). Next, traced by the notes workflow (session tasks file w1gpbbtph.output, result.traced, one entry per note with cause, scenario, fix and a proposed check): **1226 the lift FREEBIE KIT answer no longer overwrites a packing already kept aside at the stash** (note 5; verified by reading: ASKALT at game line 27541 snapshots P.kitSaved unconditionally while the stash button guards on P.freeKit at 32946, so taking the kit at the stash and confirming it again at the lift saved an empty kit and the death restore gave nothing back); **1227 the belt** (note 1; three edits: a stash drop onto the backpack column for an item bound to a key with nothing packed goes through planPut and says so instead of vanishing into the per-key hide in renderKitCol, a bound key with nothing packed shows a 0 on the plan, and a spent key in a raid says No X left instead of nothing; NEEDS the DOM drag reproduced on :8801 first); **1228 the Peddler purchase line names where the item went** (note 4: autoBelt claims a bought gun or stim for the belt and bagStacks then keeps it out of the backpack grid, so the line has to say which surface it is on). The CRAFT note (3) is UNRESOLVED: the workflow traced an amber-over-amber hold fill, and its own verifier refuted it (button:hover:not(:disabled) at CSS line 459 outranks .vbuy, so the fill does show during a real hold); his 07:59 export says textEdit 0; the button reads CRAFT with only a tooltip saying hold. Next step: his profile (session temp rescode.txt, the PIL1 code from the 07:59 export) on the dry fixture through the restore flow (#rescode, #resread, #resword = restore, #resgo), then a real hover plus mousedown on CRAFT and __loop for 1.2 s. Footprints (6) and the reload countdown (7) are not traced yet. When the note builds are done, bring the parked drafts back renumbered after them with a renum script in the renum1207.ps1 style, then verifychain. DRAFTED 13:05, ALL FOUR NOTE BUILDS: 1225 (readout scale, in its corpus at 12:52), 1226 (lift freebie guard), 1227 (belt drag onto a set key, the 0 badge, No X left; the v9.03 dark cell is left for his ruling: answer 16 said stay dark, the note says disappear), 1228 (Peddler purchase line names the surface). p/f/d/a/cm for all four in this folder; verifychain 1225..1228 from 12.24 printed chain verified at 13:05; no non-ASCII, no never-word. 1226 to 1228 are NOT yet dry-run: between corpora run dry.ps1 1226 1228 from the v12.25 tree, dry/mk.ps1 -Src dry/game.html -Dst dry/fixture.html, then checks 12.26, 12.27, 12.28 twice each with 11.62 between on :8801 at 1920x1080. Each control on the previous fixture must fail: fx1225 on the empty kept list and the empty backpack after the death; fx1226 on the missing 0, the vanished Bandage, the unnamed key and the silent spent key; fx1227 on the three purchase lines ending at the price. 13:07: 1225 COMMITTED (4ea4607, corpus 355 green, two known skips); 1226 applied, four gates green (control on fx1225 failed on three counts), corpus running on tab-1. 1226 to 1228 DRY-RUN GREEN 13:05 on :8801 (dry.ps1 1226 1228 from the v12.25 tree; each twice with 11.62 between). AUDIT QUEUE AFTER HIS NOTES (13:15): the 07:35 audit workflow finished with 24 confirmed findings, exported with scenarios, fix sketches and check sketches to tools/handoff/audit-0907-confirmed.md. Drafted from it: **1229 A CRAWLER THAT SEES YOU BITES WHEN IT REACHES YOU** (audit P1 and his standing crawler note: e.cd is both the patrol wander clock and the bite cooldown; clamp to 0.3 s on the sighting, packCall and possum transitions, crawlers only, sentries left for his ruling; written 13:10, chain verified 1225..1229, NOT yet dry-run: dry.ps1 1229 1229 from the v12.28 tree, or 1227 1229 from v12.26, then check 12.29 twice on :8801; if arm A bites late on the FIXED build, the sighting needs more than one frame and the 2 s bound should become 2.5). Next from the audit: **1230 the trigger never dies on a blanked belt cell 1** (audit P1: binding the held gun to another key blanks the derived cell 1, and every setHot(0) fall-back plus the raid start lands on it; a gunCell() helper replaces setHot(0) and an empty cell yields to the gun cell like the v12.08 empty-throwable rule). Then the parked drafts (ring pointer, belt highlight, belt plan after a free run, nothing born sealed) renumbered after these, then audit P2s in order (packScatter park, investigate exit, crier alarm, howler crater and wall, merc loots hostiles, trade window freezes clocks, corpse re-down, F held spends the revive, bagged gun magazine, G on an empty cell, gun slot reconcile, dead slot 2).

**SESSION GAP 2026-09-06 21:25 to 2026-09-07 07:31.** The session ended with v12.23 applied and gated (parse PASS, check x4, sweep, control on fx1222 failed as required) but its corpus never started; the cron died with the process. At 07:31: cron re-armed (52d2450b), servers restarted (8802 play, 8800 fixture, 8799 collector, 8801 dry), pane reopened on tab seed at 1920x1080, the v12.23 corpus started 07:34. HIS ORDER 07:30: spend the week of Fable tokens over the next day; Ultracode on; read-only audit workflows run in the background during every corpus (wf_813218f2-fe2 audit, then a draft review). Drafted queue after 1223: 1224, 1225, 1226, 1227, 1228 (all dry-run green). The moving-player probe of 21:25 was MY artefact (the probe walked the player through walls); the standing-player probe stands, and 1228 is its build.

**SESSION LIMIT STALL 2026-09-07 08:05 to 12:20.** Two workflows launched at 07:35 (75-agent audit wf_813218f2-fe2, 46-agent draft review) plus a 15-agent notes investigation at 08:00 emptied the 5-hour session budget; every agent and the loop itself stood still until the 12:20 reset (190 ticks queued). Rule, now in memory pillagers-session-limit-stops-the-loop: one workflow of at most 40 agents an hour, never two at once. The draft review finished first: 26 confirmed defects in drafts 1224 to 1228, full list in the session tasks file w64jmihdu.output under result.confirmed. 1224 repaired 12:21 (it had overclaimed that closures stopped reading the clock; closeAt -1 still fired the two-minute warning at the drop), 1225 repaired 12:45 (see its queue line). STILL TO FOLD IN before each ships: 1226 reword the setHot reason and the "always has a cell" claim; 1227 set P.planBeforeFree=null in the non-free commitKit branch, drop the _gunSlot claims, reset P.kitChosen=0 and P.dropKit=[] in the finally; 1228 hoist unsealEnts to mid-raid births or narrow its claims to buildRaid.

**HIS SEVEN PLAY NOTES OF 2026-09-07 MORNING outrank the drafted queue once 1224 is committed** (memory pillagers-his-notes-2026-09-05 has his wording): (1) a used-up belt item should vanish and bandages would not drag over; (2) credits and XP in the corner too small, every menu, word, UI and HUD should scale with 1080p, 1440p and 4K; (3) crafting bar not working, cannot craft at all (reproduced WORKING on the dry fixture with a real mousedown and __loop, bar 5 to 95 percent and the craft fired, so the next step is his own profile through the restore code, saved in the session temp as rescode.txt, then the bench); (4) Peddler purchases including an Auto Rifle never reached the inventory (purchases reach G.bag and bank to P.stash and P.weapons at extraction; he DIED on run #11 with credits 5,511 to 64, so the items died with him; candidate build: a purchase line saying the item rides in the backpack until you extract); (5) loadout restore after the freebie kit may be incomplete (1227 territory, test the whole backpack); (6) many footprints when running vertically (restore tickPlayerSteps and blip in the fixture before measuring); (7) a reload countdown bar or circle near the player. The notes-investigation workflow was resumed 12:20 as task w1gpbbtph and had written nothing by 12:45.

**CURRENT QUEUE (2026-09-06 16:45, REORDERED AGAIN by renum1207.ps1 after his two messages of 16:33; this list outranks every older list below):**
- His 16:33 messages: "GET THIS GAME TO A PLACE OF SANITY WHERE YOU FEEL COMFORTABLE CALLING IT THE ALPHA" and "crawler attacks and pathfinding were still kinda messed up... if the player stops walking sometimes the crawler will too". The crawler note was REPRODUCED on the dry fixture (a crawler running at a standing player gives up 106 units short: its alert clock expires on the way, packScatter pushes it off the point) and is built as 1207.
- **1206 THE FLOOR STOPS TAKING KEYS BEHIND THE CHARACTER SCREEN.** Applied, gates green, corpus running at 16:34.
- **1207 HIS NOTE: A CRAWLER THAT WAS COMING FOR YOU KEEPS COMING** (chaseHold overtime while more than 40 units from the last sighting; dial chaseHold, 0 = old clock). Written 16:45, NOT yet dry-run: dry.ps1 1207 1221 + dry/mk.ps1 + checks 12.07 to 12.21 on :8801 (tab "tab-3") BEFORE ship.sh start 1206 1207.
- **1208 THE TRIGGER IS NEVER DEAD ON AN EMPTY GRENADE CELL** (was 1219), **1209 BROWSING THE BACKPACK NO LONGER WALKS YOU** (was 1220), **1210 THE SECOND DOWN TELLS THE TRUTH** (was 1214), **1211 ESC CLOSES THE OPEN BACKPACK ON THE FLOOR** (was 1216), **1212 A DEATH BANKS THE XP ITS CARD PRINTS** (was 1218), **1213 THE LIFT FREEBIE KIT CLEARS THE BELT PLAN** (was 1215; it writes P.kitSaved that only 1216 reads, harmless), **1214 THE CONTROLS CARD STOPS TEACHING A DEAD KEY** (was 1217).
- **1215 to 1221 POLISH** (were 1207 to 1213: safe pocket, freebie kit restore, controller craft, bench guns pill, station heading, bigger blast leftovers, map says EXTRACT NOW).
- **1222 P RESUMES A PAUSED RAID, AS THE BOX SAYS** (first-ten-minutes audit, the last undrafted item on its list; drafted 2026-09-06 19:58 while the v12.18 corpus ran: the box no longer focuses its note on open, raidKey answers only P and ESC while pauseOpen). verifychain 1219..1222 from v12.18 printed chain verified. DRY-RUN GREEN 2026-09-06 20:12 on :8801 (dry.ps1 1220 1222 from the v12.19 tree; 12.22 twice, again after 11.62, and 12.20, 12.21, 12.02, 12.11 alongside). Ship it after 1221 with ship.sh start 1221 1222; the control on fx1221 must fail on "scheduled 1 delayed call" and "the second P did not resume".
- **1223 GOING DOWN LETS GO OF THE GRENADE** (in-raid audit P2, verified by reading at v12.19: the down branch clears prep and the heal but not the cook, and the cook clock and release sit past the downed return, so the COOKING clock froze over him and the self-revive stood him up holding a half-burned live grenade; one line, if(p.cooking) releaseCook() before the fall is recorded). Drafted 2026-09-06 20:22 while the v12.19 corpus ran; verifychain 1220..1223 from v12.19 printed chain verified. NOT yet dry-run: dry.ps1 from the tree VER+1 to 1223 + dry/mk.ps1 + check 12.23 twice on :8801 between corpora.
- **1224 THE CLOCK SWITCHED OFF IS NOT A CLOCK AT ZERO** (in-raid audit P2, verified by reading at v12.19: with raidSec 0 timeLeft sits at 0, so the boarding window min(30,max(3,timeLeft-1)) gave 3 s and the Pulled line warned the clock runs out first; both read CFG.raidSec>0 first). Drafted 2026-09-06 20:27 while the v12.19 corpus ran; verifychain 1220..1224 from v12.19 printed chain verified. FIRST DRY RUN 20:26 (dry.ps1 1221 1224 from v12.20): 12.23 green twice and after 11.62; 12.24 RED for the check, not the build: it built the raid with a clock and then zeroed timeLeft, which closed every ring with a closing time, so the call was refused, and it read hold (already 16 ms burned) instead of holdMax. Repaired 20:28 (clock off before __deploy, holdMax); chain re-verified. SECOND DRY RUN 20:43 (dry.ps1 1222 1226 from v12.21): 12.24 green twice and after 11.62. REMAINING in-raid audit items after these: the second open ring hijacking the pointer (P2, rare), Q cycling a selector the belt does not show (P2, Q is taught nowhere), the pinned-weather turn timer (P3, developer-facing); the hub belt over the [E] STATION prompt still needs a floor screenshot at 1920x1080.
- **1225 THE RING YOU CALLED KEEPS THE POINTER** (in-raid audit P2, verified by reading at v12.20: tickExtractPoints runs first inside tryExtractTick and its mirror gives the beacon ring the pointer and the clock, then the standing-ring line hands the pointer to any open ring stood in on the same frame; the ring stood in now wins only when it carries the beacon or no ring does). Drafted 2026-09-06 20:33. REVIEW FIXES APPLIED 2026-09-07 12:45 (scratchpad fixrev1225.ps1, 18 edits): the call site now sets G.active=z when a call lands (the draft review found the new clock written under the old ring name for that frame), every "ship" in p/f/d/a/cm and in the f1226 anchor replaced with "extraction", MEASURED reworded to map 0 only; verifychain 1225..1228 from 12.24 printed chain verified. NEEDS A FRESH DRY RUN (dry.ps1 1225 1228 from the v12.24 tree, dry/mk.ps1, check 12.25 twice on :8801) before ship.sh start 1224 1225, because p1225 gained an edit after its 20:43 dry run.
- **1226 THE BELT SHOWS WHAT THE TRIGGER WILL THROW** (in-raid audit P2: cycleThrow, which Q and the trigger fallback call, turned G.tsel and left G.hot, so the belt lit one throwable and the trigger cooked another; the highlight now moves to the cell of the throwable made ready, set directly because setHot on a throw cell throws). Drafted 2026-09-06 20:35. verifychain 1221..1226 from v12.20 printed chain verified. DRY-RUN GREEN 20:43 on :8801 (dry.ps1 1222 1226 from v12.21; dry game v12.26): 12.25 and 12.26 twice each and again after 11.62, with 12.22, 12.23, 11.98, 11.60 and 12.08 green alongside. Ship in order; each control on the previous fixture must fail. After these the in-raid audit list has only the pinned-weather turn timer (P3, developer-facing) left; the hub belt over the [E] STATION prompt still needs a floor screenshot at 1920x1080.
- **VERIFIED BY READING, NOT A BUILD (2026-09-06 20:40):** the v12.16 Not-verified lead that the Stash panel goes inert, sell button included, while the freebie kit is taken is the v6.44 design: CSS lines 314 to 318 dim the stash grid and the buy button under #stagemodal.freekit and #hub.freekit on purpose, with the comment saying so, and USE MY OWN GEAR (v12.16) lifts it. A player who wants to sell while on the free kit switches back first. Leave it unless he says otherwise.
- **1227 THE BELT PLAN COMES BACK AFTER A FREE RUN** (the v12.13 Not-verified line, verified by reading at v12.21: commitKit took only the packing out of P.kitSaved into P.kitBeforeFree and dropped the plan and gun slot, and endRaid restored only the packing on a non-extract end; commitKit now keeps P.planBeforeFree {hot,gun} beside it and endRaid restores it on the same rule, then dropDeadKeys). Drafted 2026-09-06 20:50 while the v12.21 corpus ran; verifychain 1222..1227 from v12.21. f1227 ALSO carries the three harness repairs from the leftovers list (11.88 pins P.hud, 11.85 pins the pane, 11.81 restores P.seals; 7 SubRx blocks). DRY-RUN GREEN 2026-09-06 21:03 on :8801 (dry.ps1 1223 1227 from v12.22; dry game v12.27): 12.27 twice and again after 11.62; 11.88, 11.85, 11.81 (repaired), 12.16 and 12.13 green alongside. Ship after 1226; the control on fx1226 must fail on the Medkit key and the gun slot.
- **1228 HIS NOTE (20:55): NOTHING IS BORN SEALED IN A VAULT** (his message after run #10 on v12.21, export consumed-run-20260906-205450.txt: felt really good, crawlers still get stuck chasing. REPRODUCED on the dry fixture at v12.26: 1 of 105 chasing crawlers never progressed, CRAWLER A-31 elite inside the cs_freezer locked room shell, a 110-cell nav island; freeSpot knows walls not rooms; twelve seeds both maps: ten bodies sealed in twelve raids, five at seed 555 on THE COLD MILE incl. a howler and a pillager. unsealEnts in buildRaid walks each sealed body out through its door, no draws, counts unchanged; dial unseal 0 = old placement). Drafted 2026-09-06 21:12 while the v12.22 corpus ran. DRY-RUN GREEN 2026-09-06 21:21 on :8801 (dry.ps1 1224 1228 from v12.23; dry game v12.28): 12.28 twice (about 7 s each, three deploys) and again after 11.62, with 12.27 and 9.30 green alongside. Ship after 1227; the control on fx1227 must fail on the five sealed bodies at seed 555. NEXT PROBE for his note: a chase with the player MOVING across doors and furniture (the standing-player probe found only the vault case).
- verifychain.ps1 -First 1207 -Last 1221 -Ver 12.06 -Wn 12.06 printed "chain verified" at 16:44.

**CURRENT QUEUE (2026-09-06 14:45, REORDERED by renum1219.ps1 so his two direct afternoon notes ship before alpha; this list outranks every older list below):**
- **1198 A HOLD STARTED BEFORE THE WINDOW SHUT FINISHES, E ANYWHERE IN THE RING** (his orders). APPLIED, four gates green, corpus running at 14:45.
- **1199 THE RIGHT-CLICK MENU IS THE SIZE OF THE STASH (4K)** (his note of 14:05; was 1219). Next.
- **1200 THE HOWLER DOES NOT SHELL THROUGH A ROOF** (his note of 14:30; was 1220).
- **1201 THE FIRST SESSION IS SET UP LIKE EVERY LATER ONE** (was 1200; matters for every friend on a fresh profile).
- **1202 A PAUSE NOTE SURVIVES ESC** (was 1199).
- **1203 to 1220** are the former 1201 to 1218 in the same order, every label up two (freebie death keeps the pistol, heal verb, notes line, polish, second down toast, lift freebie clears the plan, ESC closes the floor backpack, controls card, death banks card XP, empty grenade cell, arrows with the bag open).
- The WHATSNEW_VER chain was repaired by hand where a build does not bump it (1201, 1204 heal verb, 1205 notes line); `tools/handoff/verifychain.ps1 -First 1199 -Last 1220 -Ver 11.98 -Wn 11.98` walks the whole chain and must print "chain verified" before any dry run. Run it after EVERY renumber.
- **DRY RUN DONE 14:52 on the reordered chain:** dry.ps1 1200 1220 from the tree at v11.99 applied every draft cleanly to v12.20, and checks 11.99 and 12.00 to 12.20 all PASS on the dry fixture (:8801, pane tab "tab-3" at 1920x1080). Redo only if a draft is edited.

**CURRENT QUEUE (2026-09-06 14:50, after his afternoon notes; this list outranks every older list below):**
- **1194 HIS FOUR WORDING NOTES** (Crier alarm, Pillbox death, one per raid, Search resumed). In flight at 14:50.
- **1195 GUNS DRAG LIKE ANY OTHER ITEM** (his order: rack cells drag; rackToStash and rackPut; a figure gun takes the key alone). Drafted, NOT dry-run.
- **1196 A BELT KEY TAKES HALF THE STACK AND SHOWS xN** (his order; planPut packs half, the plan cell shows the count). Drafted, NOT dry-run.
- **1197 THE TACTICAL BELT DRAGS WITH THE BACKPACK CLOSED** (his notes: ghost on the cursor, hand gun released off the belt bags it, a gun key drags). Drafted, NOT dry-run.
- **1198 A HOLD STARTED BEFORE THE WINDOW SHUT FINISHES, E ANYWHERE IN THE RING** (his orders; the ring already accepted E anywhere, the first press is a 1.6 s hold). Drafted, NOT dry-run.
- **1199 to 1201 FIRST TEN MINUTES** (were 1195 to 1197 this morning): pause note survives ESC, first session setup, freebie death keeps the pistol.
- **1202 THE HEAL VERB, 1203 THE NOTES LINE** (were 1198 and 1199 earlier; check 12.02 was 11.97).
- **1204 to 1211 POLISH** (were 1199 to 1206 this morning; labels 12.04 to 12.11).
- **1212 to 1218 MORE FIRST-RAID FIXES** (were 1207 to 1213: second down toast, lift freebie clears the belt plan, ESC closes the floor backpack, controls card X key, death banks card XP, empty grenade cell trigger, arrows do not walk with the bag open). The read-only review wf_282ab182-3ea of these seven (as 1207 to 1213) is in its journal and NOT yet folded in: its first finding is that the second-down toast should name the pad button through keyLabel.
- **1219 THE RIGHT-CLICK MENU TAKES THE MENU ZOOM (4K)** and **1220 THE HOWLER DOES NOT SHELL THROUGH A ROOF** (his notes of 14:05 and 14:30). Drafted 15:10; the dry chain applies them; checks 12.19 and 12.20 pass on the dry copy. The dry range is now 1196 to 1220.
- **DRY RUN:** after the v11.94 commit, `dry.ps1 1195 1218` from the tree at v11.94, then dry/mk.ps1, then checks 11.95 to 12.18 on :8801 between corpora. The pane is hidden all afternoon, so a corpus takes about 45 minutes.



**CURRENT QUEUE (2026-09-06 midday, after two renumbers; this list outranks every older list below):**
- **1188 HIS ORDER: "left to be gone" and "nothing killed yet" out of the CONDITIONS panel** (his message with a screenshot, about 11:40). They were the verdicts of the kill-nothing and three-minute conduct contracts, printed without their names; the panel skips those two.
- **1189 FULGURITE ONLY FROM A STRIKE CACHE** (his note; was 1188).
- **1190 GUNS BACK INTO THE BACKPACK** (his order; was 1189).
- **1191 THE BELT: SUPPORT MG FIRING LIKE A PISTOL, DRAG CELLS TO OTHER KEYS** (his note; was 1190).
- **1192 to 1198 FIRST TEN MINUTES** (from the read-only audit wf_e9fb3c4f-c46, 8 agents, 35 findings; the ten highs verified by reading the code): 1192 the NEW IN card fits and a first launch never sees it; 1193 ENTER and the start button commit the typed name; 1194 a pause note survives ESC; 1195 the first session runs the Settings pass and the 1.3 menu zoom; 1196 dying with the freebie kit keeps the pistol you own; 1197 the heal verb tells the truth (both reviews); 1198 the notes-logged line sits below the corner readout.
- **1199 to 1206 POLISH** (the former 1191 to 1198: character screen keys, safe pocket refuses throwables, freebie kit restore, controller craft, four guns on the bench pill, modal headers drop the balance, pillager throw band, map says EXTRACT NOW!). Their labels were shifted by renum1199.ps1 and renum1189b.ps1; every 11.9x mention in them was an anchor or a control reference.
- **1207 THE SECOND DOWN TELLS THE TRUTH** (first-ten-minutes audit, verified 2026-09-06 12:50: the down branch reads only hp, so a second hit to zero downs him with the revive spent and the toast still says F gets him up). Drafted; dry-run it with the rest (dry.ps1 from the tree VER+1 to 1207).
- **1208 THE LIFT FREEBIE KIT CLEARS THE BELT PLAN** (first-ten-minutes audit, verified 2026-09-06 13:20: askKit ASKALT set freeKit and nothing else while the stash button clears P.kit, P.hotAssign, P._gunSlot). Drafted, NOT yet dry-run.
- **1209 ESC CLOSES THE OPEN FLOOR BACKPACK** (same audit, verified: the v8.70 pause branch does not count hubBagOpen and returns before the v8.95 backpack line). Drafted, NOT yet dry-run.
- **1210 THE CONTROLS CARD STOPS TEACHING A DEAD X KEY** (same audit, verified: no KeyX handler and no pad swap exist; the belt keys are the swap). Drafted, NOT yet dry-run.
- **1211 A DEATH BANKS THE XP ITS CARD PRINTS** (same audit, verified: endRaid prints the card with buzzXpMul, clears P.buzz on dead or abandon, then commitRun banks through addXp with the bonus read live as none). Drafted, NOT yet dry-run.
- **1212 THE TRIGGER IS NEVER DEAD ON AN EMPTY GRENADE CELL** (same audit, verified: startCook on an empty selected cell returns or cycles to another grenade; v2.92 never covered a cell selected empty). Drafted, NOT yet dry-run.
- **1213 BROWSING THE BACKPACK NO LONGER WALKS YOU** (same audit, verified: raidKey sets keys[code] for every key and the movement reads the arrows regardless of G.bagOpen). Drafted, NOT yet dry-run. Dry-run all six with dry.ps1 from the tree VER+1 to 1213.
- **NOT DRAFTED, from the same audits, in value order:** P cannot close the pause box while its textarea has focus; hub belt may cover the [E] STATION prompt (UNVERIFIED, take a screenshot of the floor with the operator at the lift); the second review of v11.84 says only the player's Lance rounds pass through crawlers (stamp `thru` on fromPlayer or copy the two lines into the enemy branch); check 11.80 should also count __ambOff calls rising by 2; check 11.85 should pin __forceSize(1920,1080); check 11.81's control arm should restore P.seals.
- **LEFTOVERS OF THE DRAFT REVIEW wf_cfc891c0-f2e (47 findings; highs and mediums folded in by fixdrafts5.ps1 + fixdup5.ps1):** check 11.88 should reset and restore P.hud (a collapsed CONDITIONS panel on the saved profile reads as a red for the wrong reason; copy the idiom at mkfixture ~3191); the v11.88 patch left the quiet and swift verdict branches unreachable rather than deleting them, and the v9.70 comment under it still cites "nothing killed yet" as a live example (delete both branches and reword the comment in a polish build); check 11.97 has no arm for the named belt heal slot (stage P.hotAssign the way check ~1468 does, then setHot and useHot); the 1188 check spies fillText by hand where __textTrace exists; the queue drafts still use the DEVNOW idiom `now:'v11\.NN:[^']*'` which cannot carry an apostrophe (never put one in a DEVNOW sentence).
- **DRY RUN BEFORE SHIPPING 1189:** `powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/dry.ps1 1189 1206` from the tree at v11.88, then `dry/mk.ps1`, then run checks 11.89 to 12.06 on :8801 between corpora (tools/serve.ps1 -Root tools/handoff/dry -Port 8801 if the server is down).


1. **1176 SCAV PISTOL 3600 -> 1800** (his order; my number). Trivial.
2. **1177 FRAG: RADIUS 150 -> 190, ENEMY 85..15 -> 115..25, HIM 60..12 -> 80..18**
   (his order; he overruled his own no-balancing rule). cfgv 17 -> 18 with a
   migration moving a saved 150 to 190. The check stages a real blast 40 units
   from a pillager and drives the real loader with a cfgv 17 save. The fuse is
   still 1.1 s, his ruling pending.
3. **1178 THE CORNER READOUT, TWICE THE SIZE EVERYWHERE** (his notes: useless on
   the floor; then "in corner during raid still wayyyyyy too tiny"). 32px
   figures, 14px labels, 44px tall, one size in the hub and in raids; the raid
   CONDITIONS box starts below the readout's real bottom (topRightBottom(),
   read in drawHUD). REDRAFTED this morning; the earlier hub-only draft is gone.
   f1179's anchor was repointed to the new 11.78 what-line.
4. **1179 GREEN AND BLUE GUNS ON THE BENCH** (his order). Four recipes: Compact
   SMG, Burst Carbine (green), Auto Rifle, Riot Scattergun (blue), parts worth
   more than the gun sells for and less than buying it. Reverses his v9.84
   rule for those two colours only.
5. **1180 THE HUM ON THE FLOOR AFTER AN EXTRACTION** (his note, chat, about 06:50).
   Root cause found by reading: the raid branch keeps calling tickAmbience
   over the outcome card with alive = !downed, true after an EXTRACTION, so
   the bed was written back up to 0.16 after endRaid cut it, then held there
   once the raid was dropped. A death leaves him downed, so only extractions
   hummed. One line at the call site. The check wraps tickAmbience.

**Run `powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/dry.ps1 1176 1180`
before shipping 1176** (the range must start at the tree's VER+1). Run each
new check 3 to 5 times in one page and once after a raid-ending check (11.62).

**A READ-ONLY REVIEW OF DRAFTS 1180 TO 1193 (workflow wf_27344e1d-0ec, 14 agents, Read/Grep/Glob only) FOUND 30 DEFECTS AND ALL ARE FOLDED IN** by fixdrafts1/2/3.ps1 (drafts), fix1180b/c.ps1 (the v11.80 tree delta) and fixd1180.ps1 (its DESIGN entry); every script is idempotent and already applied, do NOT re-run them. The biggest: 1180 slowed the cut (re-asserted last) and gave a false reason deaths never hummed; 1184 counted a piercing round as N hits (accuracy over 100 percent); 1186 said "gave you" on a death card; 1189 flipped the slot map with no gun in hand; 1190 pointed the highlight at a blanked cell (trigger dead); 1191 left the keydown copy of the gate; 1192 poisoned the profile and left the pocket in the right-click menu; 1193 missed the lift question, dead keys and the death restore; 1183 froze the stim clock during rolls; 1187 walked backwards and lost its count. All thirteen repaired checks (11.81 to 11.93) run green twice on the :8801 dry fixture at v11.93. A finding is acted on only after reading the quoted lines yourself; these were.

**FIVE FOLLOW-UP BUILDS FROM THE REVIEW OF THE SHIPPED CODE (workflow wf_b2fb5361-485, seven read-only agents over v11.74 to v11.80), DRAFTED AND QUEUED AFTER 1193, in this order:** 1194 a controller or the keyboard can craft again (v11.75 deleted the button click; a synthetic-only click returns, the hold dies when the trader window hides, tooltip reads CRAFT_HOLD, card drops the SERVICE sentence); 1195 the bench tells the truth about its guns (the Carbine is blue by dispR, one green and three blue; itemBlurb gun branch; detail pill via dispR; craftPart/craftUse know servo and optic; shop panel line; checks 11.79 and 9.43 repaired); 1196 the station heading balance is hidden under the enlarged readout (check 11.52 repaired, it double-scaled condTop); 1197 the bigger blast follow-ups (pillager throw band near edge follows the radius, cover warning covers the radius, card centre figures 140/98, check 11.44 sentinel unpinned); 1198 the sector map says EXTRACT NOW under a landed ring. Dry-run 1183 to 1198 from the tree VER+1 before shipping 1183 and run every new check twice on :8801. Lower findings from that review not built: 11.76 check wording ("the 1800 he asked for" is mine), 11.75 tooltip prose, 11.80 draft record (p1180 lacks the shipped second line; fix1180b/c partly applied), 11.78 DESIGN wording ("twice").

**DRAFTED THIS MORNING (about 07:20), FROM HIS 06:26 AND 06:39 EXPORTS (p/f/d/a/cm 1181 to 1188 in this folder; 1183 to 1188 NOT yet dry-run, do that first: dry.ps1 from the tree VER+1 to 1188, build dry/fixture.html, run each check twice on :8801):** 1181 the KIA cutting line removed; 1182 healing stacks and a plate goes on over a bandage (two prep timers); 1183 stim = 10 s unlimited stamina and 1.2x speed (useStim); 1184 the Lance travels through crawlers (b.thru); 1185 map extraction names and countdowns readable (TYPE.head/label); 1186 survivor pays 900 to 1500 and hands over one of titan/core/optic/servo, card drops already banked; 1187 helped survivor walks to the nearest open ring and leaves (e.gone, parked off-map); 1188 Fulgurite item (2500) and the strike cache holds only it. THE DRY RUN OF 1177 TO 1182 CAUGHT THREE BROKEN CHECKS (11.77 read the fixture pin fragR 150 and handed __applyLoaded a wrapped object; 11.79 forbade contract parts the plate recipe uses; 11.80 ended the raid between frames, and the real hum lives INSIDE the frame that ends the raid, see d1180) and all are repaired; the dry fixture is served on :8801 from tools/handoff/dry (not in start-servers.ps1). The v11.76 corpus went red once on 10.34 because I resized a second tab while it ran: leave the pane alone during a corpus. DRAFTED this morning as well (about 07:35): 1189 a held gun drags into the open backpack (bagHeldGun; the gun cells were select-only since v7.21); 1190 a belt key holding a bagged gun equips it (setHot calls equipFromBag, swaps up, moves the highlight) and derived cells drag by the item they show. ALSO DRAFTED this morning (about 07:40), the three menu-audit items: 1191 hubModalOpen counts #title (floor keys behind the character screen); 1192 the safe pocket refuses throw and ammo and a bad saved pocket is cleared on load; 1193 the freebie kit keeps the packing aside (P.kitSaved) and USE MY OWN GEAR restores it minus what was sold. The dry range 1178 to 1193 applies (dry game v11.93); run 11.83 to 11.93 twice on :8801 between corpora before shipping each. Still open for his ruling: the 1.1 s fuse; the crawler charging note (vague); enemies converging on extraction (his maybe). AFTER 1193 the queue is empty: audit what shipped today by reading, and watch exports/ for his next notes. The older list follows for the record.

**NOT YET DRAFTED (superseded list), FROM HIS 06:26 EXPORT (exports/consumed-run-20260906-062618.txt,
v11.73 runs, authenticated: dur 267 to 427 s, real killers), in value order:**
6. **1181 REMOVE "N seconds of cutting, lost with you."** from the KIA card.
   His words: "I have no idea what the fuck that means, just remove it." The
   line is the else branch under `if(G.seal&&G.seal.gained>0)` in the outcome
   card (~18370). Delete the push; keep the extract branch. Check: build the
   card on 'dead' with G.seal.gained>0 and require the assembled phrase absent;
   control on the previous fixture finds it.
7. **1182 HEALING: no "Still applying prior healing item. N to go."** (his
   note: "isn't accurate -- just get rid of it") **AND plates while a bandage
   is healing AND the next bandage while the prior one heals** (his note
   @164s). The gate is `(p.healQ||0)>0&&CFG.healSolo!==0` in useMedical
   (~12459) and the belt path (~13226); healSolo is a DEF dial (1). Read
   startPrep/prep and how plates are applied before drafting; the
   `if(_pp.prep) say('Already applying ...')` line is the plate blocker if
   plates go through prep.
8. **1183 STIM INJECTOR: unlimited stamina and 1.2x speed for 10 seconds** (his
   spec). Read the current stim effect first.
9. **1184 MERIDIAN LANCE ROUNDS TRAVEL THROUGH CRAWLERS** (his note @248s).
   Bullet-vs-entity hit code; the lance is `lance` in the gun table (dmg 96,
   optic 1.6). Pass through crawlers only, keep hitting them.
10. **1185 THE MAP SHOWS A CLOSE COUNTDOWN ON EACH EXTRACTION** (his note
    @327s). The HUD already has `_zSub='closes in '+fmtMS(...)` (~26437); the
    map screen needs the same per marker.
11. **1186 THE SURVIVOR PAYS MORE, and drop ", already banked"** (his note).
    The line is at ~18323 (`G.strayPaid`). The amount is his call; pick a
    number, say it is mine.
12. LOGGED, NOT ORDERS: "crawler movement and charging at player is still
    messed up" (vague; needs a reproduction), and "too many enemies converge
    on extraction point -- maybe some of them should go back to patrol more
    quickly if they don't find anything?" ("maybe": balance, for his ruling).

**STILL OPEN AFTER THOSE, from the 2026-09-06 menu audit:** the freebie kit
wiping a packed backpack and belt plan with no undo; the safe pocket accepting
a grenade it can never bank while reading 1/1; the floor taking station keys
behind the character screen. AUDIT.md has the fixes.

**AND HIS RULING STILL WANTED:** the frag fuse at 1.1 seconds, which is why the
grenade kills him rather than the warning being late. If he gives a number it
is one line.

## FINAL RUN BEFORE ALPHA (handoff to Fable, 2026-09-06)

**STATE: HEAD is v11.72 (8ac8eec) and THE TREE IS CLEAN.** Nothing is
mid-flight. The whole v11.46 audit queue is shipped, along with all six of his
2026-09-05 notes, the Undercroft HUD erase and the belt-key grenade: 21 builds,
v11.52 to v11.72, every one with a green corpus (304 checks, only the two known
skips) and a control that fails on the previous build.

**FIRST ACTION: `bash tools/handoff/ship.sh start 1172 1173`.** 1173 is drafted
AND dry-run green: a character who has never saved had no name. Then the usual
four gates and the corpus.

**THEN, THE ALPHA-PATH ITEMS STILL OPEN** (all from the 2026-09-06 menu audit,
recorded in AUDIT.md under its 2026-09-06 heading, none drafted as builds):
1. TAKE THE FREEBIE KIT wipes a packed backpack and the whole belt plan, with
   no confirmation and no undo. A new player is likely to press it after
   packing. Highest value left.
2. The safe pocket accepts a Frag Charge or an Ammo Box and reads 1/1, but the
   death path cannot bank either, so it silently spends the only death
   protection there is. One line in setSafe, plus clearing an already-saved bad
   P.safe on load.
3. The Undercroft keeps taking E, R, F and T behind the character screen; at
   the lift, R starts a raid under the title. One line in hubModalOpen.

**WHAT SHIPPED TONIGHT (20 builds, v11.52 to v11.71, every one with a green
corpus and a control that fails on the previous build):** all six of his
2026-09-05 in-run notes; the Undercroft HUD erase; the belt-key grenade; and
the entire v11.46 audit queue.

**THE HARNESS BIT FOUR TIMES TONIGHT and every repair is in the drafts:** a
check guarding on a hook from a renumbered build (skipped silently); a control
that required a blank strip only true while the HUD was erased; a check that
judged a multi-item lot by the last stash entry; one that renamed a row of the
shared WEATHER table; one that assumed which button writes the run row; and one
that skipped on a raid left in memory. THE STANDING RULE THAT CAME OUT OF IT:
run every new check three to five times in one page before the corpus, and once
straight after a neighbouring check that ends a raid. A check that is green
alone and red or skipped in the corpus is order-dependent, and the fault is
almost always in the check.

**MID-FLIGHT (2026-09-06, handing back to Fable):** HEAD is v11.56 (5afdc0a).
The tree has v11.57 APPLIED (his note E, LIGHTNING INCOMING at the ring) and
verified on all four gates: parse PASS, check 11.57 PASS, __verifySafe PASS at
1920x1080, control fails on fx1156.html. Its FULL CORPUS is running on the
Browser pane tab "seed". FIRST THING: on that tab run
`JSON.stringify(window.__PROG)`; when finished is true, pass is true, fail is
[] and only the two known skips (v8.88, v11.24) are listed:
    bash tools/handoff/ship.sh commit 1157 cm1157.txt
then bump the HEAD line in memory dark-raiders-handoff-state.md, then
    bash tools/handoff/ship.sh start 1157 1158
and carry on down the list below. Everything from 1158 to 1163 was dry-run
green in sequence at 2026-09-06.

THE ORDER FROM HERE (renumbered twice tonight; this list is the truth):
- 1158 THE UNDERCROFT HUD ERASE. The biggest find of the night and the one to
  get in before alpha. The floor painted its heading, its [E] STATION prompt
  and key list, the H controls panel, the NEW IN card and the line teaching
  WASD, then wiped all of it in the same frame; H has been a dead key. From
  the 2026-09-06 menu audit. NOTE FOR HIM: this makes the NEW IN card visible
  again at boot until he moves, which is that card's original design and may
  not be what he wants now.
- 1159 his note F, the four sounds that bypassed the heard-not-seen noise ring.
- 1160 the belt-key grenade fix (a throwable on a tactical belt key was a dead
  key that also deleted the working grenade cell).
- 1161 to 1172 the v11.46 audit queue, unchanged.

**AFTER ANY MACHINE RESTART, in this order, or every measurement is void:**
1. `powershell -ExecutionPolicy Bypass -File tools/start-servers.ps1`
2. CronList; re-arm the build tick if it is gone (it dies with the process).
3. `preview_start` at http://localhost:8800/parsecheck.html, then
   `resize_window 1920x1080` on tab "seed". A fresh pane is 0x0 and every DOM
   measurement skips or lies.
4. `git status --short` to see what was mid-flight, and `grep "^var VER=" dark_raiders.html`
   to see which build the tree is carrying.

**HIS TELEMETRY OF 2026-09-05 22:26 and 22:35 (exports/consumed-run-20260905-2226*.txt
and -2235*.txt; two real runs on v11.51, both DEAD, both lastHit YOUR OWN CHARGE,
killer other) OUTRANKS THE DRAFTED QUEUE. His notes, verbatim, in the order to
build them (one thing per build, his words on screen):**

A. "COOKING A GRENADE SHOULD COUNT down, NOT UP!!!" and "cooking grenades should
   give more warning before exploding in your hand, need a message with 1 sec
   left like COOKED GRENADE! THROW GRENADE NOW". He died to his own charge in
   BOTH runs (downs 2, rev 1, lastHit YOUR OWN CHARGE). One build: the cook
   readout counts down to the burst and at one second shouts his line.
B. "activating sprint should automatically stop crouching" and "rolling should
   automatically stop crouching". One build: sprint (hold Shift, v10.87) and the
   roll both leave the crouch toggle (v10.07).
C. "'EXTRACTION - OPEN' IS CONFUSING... POSSIBLE STATES FOR AN EXTRACTION POINT
   SHOULD INSTEAD BE: 'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN' /
   'EXTRACTION POINT - 30S UNTIL EXTRACTION BEGINS' / 'EXTRACTION POINT - EXTRACT
   NOW! 30S UNTIL EXTRACTION ENDS' / 'EXTRACTION POINT - CLOSED FOR THE REMAINDER
   OF THIS RAID'". His four strings, with the live seconds where he wrote 30S.
D. "lightning shouldn't strike inside buildings". The storm strike placement
   must reject any point inside a building interior.
E. "when lightning is about to hit, it should say like 'lightning incoming' at
   the circle." A label on the strike warning ring (v11.35 drew it in screen space).
F. "how lightning shows red noise, I want ALL noises to do that when they are
   outside the player's vision but within earshot, eg visualize noises with red
   circles!" A feature: every heard noise source outside the view cone draws a
   red ring at its position while audible. Design it small first (gunshots,
   footsteps, doors), prove it with a check that fires a shot out of view and
   reads the ring, and keep the CFG dial noiseSee in mind (it exists).

Then the chat note already shipping as v11.52 (credits and XP top right), then
the drafted queue 1153 to 1164.

READ BEFORE BUILDING A AND B (Fable read the code 2026-09-05 23:20):
- A. FRAG_FUSE is 1.1 SECONDS (var FRAG_FUSE=1.1, ~line 11367). The in-hand
  readout (drawHUD ~23312-23340) already prints "COOKING 0.8s" counting DOWN
  and a shrinking bar; startCook/releaseCook/cookOff are ~11447-11471; the
  cook clock runs in updatePlayer ~14263-14268 and cookOff fires at 1.1 s.
  That fuse is why it went off in his hand twice: a beat too long on the
  button and it is gone. A "one second left" warning on a 1.1 s fuse would
  appear the instant he presses. The fuse is a balance number and his order
  is no in-raid balancing before alpha, so DO NOT move it silently: build his
  shout (at <=1.0 s left, honest even if it is immediate), make the readout
  bigger and unmistakably a countdown, and put the 1.1 s figure in the report
  in plain words as the real cause with a request for HIS number. If he gives
  one, it is a one-line change to FRAG_FUSE. Also check what he saw counting
  UP: the only cook readout counts down, so it may be the landed grenade or
  a fill-direction of bar(); look at bar()'s fill argument (1-cf) before
  claiming it counts down on screen.
- B. Crouch is a toggle flag G.crouchTog (keydown ~10447, crouchHeld() ~3415).
  Sprint is computed in updatePlayer ~14057-14059 as
  `_shHeld && stam>2 && !stamLock && !stamRelease && !crouch && mg>0`, so
  today holding Shift while crouched simply does not sprint: crouch wins.
  His rule: sprint wins. Fix: when _shHeld and mg>0 and G.crouchTog, clear
  G.crouchTog before computing crouch (and say nothing; the stance readout
  already changes). The roll is tryRoll() ~11311-11331: clear G.crouchTog
  there too. One build, one check that sets crouchTog, holds Shift with W
  and requires crouchTog false and sprint true, then sets it again, rolls
  and requires it false; control fails on the previous fixture.

NEW, 2026-09-06 (Opus): a second read-only audit ran over the IN-RAID
subsystems (14 agents, 27 raw findings, top 8 refute-tested, none refuted;
19 raw findings were NOT verified and are listed in the run output at
tasks/wgxerrwcf.output). Its strongest finding is DRAFTED AND DRY-RUN GREEN
as 1159 and ships after his notes: a throwable put on a tactical belt key was
a dead key that also deleted the working grenade cell (the v8.31 stim hole,
one item type later). The audit queue moved again to 1160 to 1171
(renumber1160.ps1 then fixdev1160.ps1) to make room. The other seven
confirmed findings are written into AUDIT.md under the 2026-09-06 heading:
a frozen cook while downed that throws itself on revive, Q desyncing the
throw selector from the belt, a pinned weather burning seeded rolls every
frame, the fulgurite cache glowing the rarity it discarded, a second open
ring hijacking the extraction pointer, and a 3-second boarding window when
the raid clock is OFF.

NUMBERING (done 2026-09-05 23:45): the audit queue was shifted to 1159 to
1170 (renumber1159.ps1 then fixdev1159.ps1), so his note builds take 1153 to
1158. STATUS: B = v11.53 (sprint and roll leave the crouch) verified on all
four gates; check git log for whether its corpus committed it. DRAFTED and
dry-run green in sequence: C = 1154 (extraction point states in his words),
A = 1155 (the cooked-grenade shout; the 1.1 s fuse NOT moved, his number
requested in the report), D = 1156 (no strike point inside a building), E =
1157 (LIGHTNING INCOMING at the ring), F = 1158 (the four sounds that
bypassed the heard-not-seen ring: strike telegraph, extraction inbound pulse,
touchdown, last call, now positioned through sfx; the ring system noiseMark
already existed since v9.07). Ship them in order with `ship.sh start PREV
NEW`, each through the full procedure below. The audit queue 1159 to 1170
follows directly; no further renumbering is needed. The old crash line in his report (v10.96, sub
is not defined) is history, fixed at v10.98.

**HIS NOTE, 2026-09-05 ~22:30, OUTRANKS THE DRAFTED QUEUE:** "credits and xp
should be shown at all times in the upper right hand corner." Build it as the
very next build after whatever is mid-flight: a persistent readout of credits
and XP in the upper right of the screen, in the Undercroft AND in a raid AND
under every panel that does not cover that corner; one word per thing from
the vocabulary memory (Credits, XP). Prove it with a check that reads the two
figures off the real canvas or DOM in both places and requires them to track
P.credits and P.xp after a change; the control fails on the previous fixture.
If the drafted numbers collide, renumber the drafts UP by one with
tools/handoff/dry/renumber3.ps1 as the template (it bumps VER, WHATSNEW,
DEVNOW and the f-file anchors) and dry-run again before shipping.

WHERE WE ARE: run `git log --oneline -5` in C:\claudecode\dark raiders. The
newest "vX.YY:" subject is HEAD. Fourteen builds were fully drafted and
DRY-RUN GREEN in order on scratch copies (every anchor applies, end state
parses as v11.63): p/f/d/a/cm 1150 to 1163 in this folder. THE NEXT BUILD is
the lowest number in that range whose cm<n>.txt subject line is NOT yet in
git log. Confirm the tree is clean first (`git status --short` prints
nothing); if it is not, a build is mid-flight: read DESIGN.md's top entry to
see which, and carry it through the procedure below from step 3.

## What each draft fixes (all from the v11.46 read-only audit in AUDIT.md,
## section "STILL OPEN, found 2026-09-05")

(Renumbered 2026-09-05 late: his readout note took 1152 and everything after
it moved up one. The shift tool renumber1152.ps1 plus fixdev1153.ps1 did it;
the escaped "11\.NN" inside each p-file's DEVNOW regex needs the second tool.)

- 1150 closing the Undercroft backpack overwrote loadout edits made at the Mainframe (P0) SHIPPED
- 1151 my v11.42 sector-line pattern regression (wrong map name printed) (P1) SHIPPED
- 1152 HIS NOTE: credits and XP in the upper right at all times, raids and Undercroft
- 1153 Wirt Buy sold the clock-at-click lot, not the shown lot (P1)
- 1154 a merc who boards an earlier extraction was never paid (P1)
- 1155 the outcome card printed base XP while the profile banked more (P1)
- 1156 byPlayer never cleared on revive: a saved pillager was still your kill (P1)
- 1157 tags and a note chosen after Copy report were dropped (P1)
- 1158 the restore code left the armoury behind (P1)
- 1159 the restore code was blank for a name above U+00FF (P1)
- 1160 the notoriety banner said the Peddler was done with you (P2)
- 1161 belt drop on the stash said back in the backpack (P2)
- 1162 with pillagers None the extraction-heat row read CUSTOM (P2)
- 1163 [+] on a collapsed pillager board started an invisible resize (P2)
- 1164 a note typed in the pause box on the floor rode into the next raid (P2)

The range in every command below is therefore 1150 to 1164, and the dry run
is `dry.ps1 NEW 1164`.

## The per-build procedure (one build at a time, never two)

Below, PREV is HEAD's four-digit tag (v11.50 = 1150) and NEW is PREV+1.

Servers first: powershell -ExecutionPolicy Bypass -File tools/start-servers.ps1
(:8802 is his PLAY port and shares his profile: NEVER test there. :8800
serves the tools folder: fixture.html, parsecheck.html, fx<PREV>.html.)

1. Dry-run what is left before each ship (uses copies, touches nothing real):
     powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/dry.ps1 NEW 1163
2. Start the build (applies p and f, rebuilds fixture.html and fx<PREV>.html,
   inserts d into DESIGN.md and a into AUDIT.md):
     bash tools/handoff/ship.sh start PREV NEW
3. In the Browser pane (resize_window 1920x1080 first; a fresh pane is 0x0).
   One tab is enough; chain these in one browser_batch:
   - http://localhost:8800/parsecheck.html: wait 4 s; document.title must be
     "PASS v<NEW> parse check".
   - http://localhost:8800/fixture.html: wait 6 s. Find the corpus array (the
     window key whose value is an array of {v,what,run} objects longer than
     50), run the entry whose v is the new version, require null (PASS).
     Then `await __verifySafe()` and require summary PASS: ents {0:85,1:374},
     containers {0:165,1:593}, parity identical on both maps, loot on both,
     endings EXTRACTED / KILLED IN ACTION / ABANDONED, hub thrown null.
   - http://localhost:8800/fx<PREV>.html: wait 6 s; run the same new entry.
     It MUST return a failure string (the control). A PASS there means the
     check does not test the fix: stop and fix the check.
   - Back on fixture.html: wait 6 s, `__regressBg()`. Then poll
     `window.__PROG` ({done,cur,finished,res:{pass,checked,fail,skipped}})
     every few minutes; a `sleep 540` Bash call in the background is the
     timer. Nine to ten minutes. Green = pass true, fail [], and ONLY the two
     known skips (v8.88 pane height, v11.24 feud unmeasurable). Never
     navigate that tab while it runs.
4. Commit (archives, rebuilds the publish zips, git commit -F cm<NEW>.txt):
     bash tools/handoff/ship.sh commit NEW cm<NEW>.txt
   Pass the BARE filename; an absolute path gets mangled by MSYS.
5. Bump the HEAD line in the memory file dark-raiders-handoff-state.md.
6. Report to him in plain language, play link http://localhost:8802/dark_raiders.html
   top and bottom, bullets, no em or en dashes, own mistakes in one line.
7. Start the next one immediately. Never park on a wakeup while a build is
   available; a tick that ships nothing is a failed tick.

## Standing rules that bit this week

- v11.58 ALSO REPAIRED CHECK 9.88, whose control required the bottom of the HUD
  canvas to be blank with the belt dial off. That was only true because the
  floor HUD was being erased, so it fired on correct behaviour. A pixel COUNT
  cannot separate the belt from the floor HUD behind it (91809 against 91809);
  the control now compares a CHECKSUM of the real pixels with the dial on and
  off and requires them to differ. inkSum and unionOf live in that check.
- AFTER ANY RENUMBER, check hook dependencies. A check that guards on a
  window.__ hook added by a LATER build returns SKIP forever, on the new
  fixture AND on the control, and a skip reads like a pass. Compare
  `grep -oh "window\.__[a-zA-Z]*=" tools/mkfixture.ps1` (installed) against
  `grep -oh "window\.__[a-zA-Z]*" tools/handoff/f*.ps1` (used). As of v11.56
  the only unshipped hooks are __wirtLot, __identityIds and __wxHard, and each
  is installed by the same f-file that uses it, so the queue is clean.
- After patching a check, REBUILD fx<prev>.html
  (`mkfixture.ps1 -Src tools/prev<PREV>.html -Dst tools/fx<PREV>.html`), or the
  control still runs the old check text and skips instead of failing.
- A control that reads a function's SOURCE (fn.toString()) reads its comments
  too. Check 11.54's "no old badge phrase in drawHUD" control failed on a
  stale comment; fixcm1154.ps1 reworded it and p1154 carries the edit. Before
  writing such a control, grep the function body for the phrase in comments.

- No non-ASCII in any .ps1 (PowerShell 5.1 reads them as ANSI).
- Bash heredocs broke twice on apostrophes, and sed ate backslashes in a
  Windows path; write files with the Write tool.
- A SKIP is not a PASS. A control must FAIL on the previous fixture.
- No in-raid balancing before alpha: bug fixes, crashes, menus, saves and
  text continue; dials do not move.
- Never change the salvagerun:profile storage key without a migration.
- The cron dies with the process: CronList first every tick, re-arm if gone.
- One solo build at a time; no agent swarms (the 5-hour session limit).
- His telemetry in exports/ and Downloads outranks everything when it is
  real (dur:0s or killer:test is a fixture leak, not him).

## After 1163

The v11.46 audit queue is then fully shipped. The older audit memories
(full-file audit, RAID audit queue) are HISTORY, not queues: fourteen of
their sixteen named items were already shipped when re-checked at v9.43, and
their task-output files no longer exist on disk. Do not work a line from them
without checking the live file. The pool for new builds is:

1. AUDIT.md under STILL OPEN (anything not struck through).
2. DESIGN.md "Not verified:" lines, newest first; drive each one and either
   close it with a check or leave it as his ruling.
3. A fresh read-only audit: ONE bounded Workflow of read-only agents (Grep and
   Read only, never the browser, never Bash or Edit), each finding refuted by
   a skeptic before it is queued. The v11.46 one found 18 real defects in one
   pass; that is the highest-yield source there is.

Concrete leads swept from the "Not verified:" lines on 2026-09-05 (most of
those lines are "his own eye" or "his own play" and are not builds; these
are the testable ones):
- v11.04: a restore code from a much older build pasted into a newer one; the
  code carries v:1 and nothing reads it. Decide what a future v:2 does.
- v10.91 / v10.78 / v10.79: the HUD grip pinning, the two window overflow
  sweeps and the four draw-signal floors were measured at 1080p only; the
  pane DOES resize to 1440p and 2160p (resize_window), so run them there.
- v10.12: an old profile with P.loadouts is inert but never cleaned; a
  migration that deletes the field, with a check, is a small honest build.
- v11.27 / v11.28 / v11.30: the pad paths (belt buttons, D-pad through the
  backpack grid, strike and heal as separate buttons) were never pressed; the
  fixture can synthesise pad state through the PAD object.
- v11.36: "seven other combat-agent findings still queued" at that build; the
  memory dark-raiders-handoff-state lists them under QUEUED unbuilt agent
  findings. Several shipped since (v11.37 to v11.41); check AUDIT.md first.

## How a draft is written (for builds after 1163)

p<n>.ps1 patches the game with SubRx exact-match asserts (each anchor must
match exactly once) plus an edit-count assert, and bumps VER, WHATSNEW_VER,
the WHATSNEW line and the DEVNOW `now:'v..:'` stamp. f<n>.ps1 inserts a
{v,what,run} check into tools/mkfixture.ps1 before the previous version's
entry; the check runs INSIDE the game's closure, so internal functions and
variables (P, G, CFG, state, restoreCode, togglePauseBox, HUDBOX...) are
reachable directly, and window.__* hooks are the fixture's instruments.
d<n>.txt is the DESIGN.md entry (ends with "Not verified:"), a<n>.txt the
AUDIT.md table row, cm<n>.txt the commit message. Copy any of 1150 to 1163
as the template. Reproduce the defect in the page BEFORE writing the fix.
