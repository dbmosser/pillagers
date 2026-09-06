# START HERE (written 2026-09-05, handoff from Fable to Opus; rewritten 2026-09-06 (morning) for the alpha run)

## ALPHA SHIPS TODAY, 2026-09-06, about ten hours from 07:15 (his words at 07:15). Read this block first.

**STATE (kept current by fixstate.ps1):** HEAD is v12.02 (27f174f). The tree has **v12.03 APPLIED** and
verified on all four gates; its FULL CORPUS is running on the Browser pane tab "tab-2" (the tab named seed hung on 2026-09-06 12:40 and was closed).
When `window.__PROG` is finished, pass true, fail [] and only the two known skips
(v8.88, v11.24):
    bash tools/handoff/ship.sh commit 1203 cm1203.txt
then bump the HEAD line in memory dark-raiders-handoff-state.md, then
    bash tools/handoff/ship.sh start 1203 1204
and carry on down the list. Cron 35be6fe2 is armed every minute; re-arm if
CronList shows nothing. Resize the pane to 1920x1080 after any restart. Leave the
pane and the CPU alone while a corpus runs (a second-tab resize and heavy builds
each turned one unrelated check red). If one unrelated check goes red, re-run it
alone and straight after the new check; a bare profile left by a check is the
usual cause (see memory dark-raiders-loader-replaces-the-profile).

**THE QUEUE, ALL DRAFTED (p/f/d/a/cm in this folder), SHIP IN THIS ORDER:**

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
