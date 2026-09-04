# AUDIT QUEUE

One file. This is the only place a finding's status is true. It used to live in a
303KB task blob, two memory files and DESIGN.md at once, and they disagreed:
on 2026-09-01 I picked six "open" items off the old list and **all six had
already been fixed**, which I only discovered by reading the code each time.
That is what this file exists to stop.

USE __sim, NOT __rawStep, when the player is meant to be passive. __rawStep is the BOT playing: it shoots, it moves, it gives away position. Three of my false reproductions came from reading its output as if the player were standing still.

Rules: a finding is CLOSED only with the build that closed it named beside it.
When a fix ships, update the row in the same commit. Do not trust a status you
did not just read here.

Source of the 2026-09-01 full-file audit (107 findings, 10 regions, each
adversarially verified):
`AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\a5a0e3f7-a767-4d3d-810d-75cdd25dc613\tasks\wyqb1dy04.output`
(parse `.result`; line numbers in finder titles run 9-23 low).

## Closed, verified against the current file on 2026-09-01

| Finding | Closed by | How it was confirmed closed |
|---|---|---|
| Staged pulls announced the containers CONTENTS, not what was taken: pulling one item named all three and spoiled the box | v9.22 | announce the granted keys; full open unchanged since it passes contents as keys; check fails on a v9.21 fixture |
| Extraction pull dragging a Listener off its hunt | not a defect | checked v9.22 by calling the extraction tick directly: pull took 3 machines, Listener not among them; its heard position moves via its own ears, which the code documents |
| Flight recorder counted damage THROWN not TAKEN (30 logged for a hit that cost 15), so every balance number I quoted was inflated by armour | v9.21 | accumulation moved into the row helper at the moment the hit lands, above the sim guard; 15/15/15; check fails on a v9.20 fixture |
| Death screen HOW IT WENT table logged pre-armour damage and pre-hit health (30/100 for a hit that cost 15 and left 85; killing blow read HEALTH 20) | v9.20 | row written when the hit lands; 15/85 and 0 on the killing blow; check fails on a v9.19 fixture naming all four |
| His EXTRACT CACHE rename (outstanding since 2026-08-29), four rewards reading CASH against his vocabulary, and a WHATSNEW card 21 builds stale | v9.19 | ELITE CACHE on both maps, rewards say CREDITS, card rewritten and bumped; check fails on a v9.18 fixture naming all three |
| Title screen scrolled at menu text size 1.3 on a short screen (21px at 1720x720); fixed rhythm never asked how tall the screen was | v9.18 | height-gated tightening below 820; 0px overflow at 1.3, 1080/1440/2160 unchanged; check fails on a v9.17 fixture |
| His ultrawide screenshot: the title column was a hard 820px, 50 pct of a 1720 screen, with ~430px empty each side and a scrollbar | v9.17 | base width moved to CSS, aspect-gated override above 19/10 grows it to 74 pct; 16:9 still exactly 820px; check fails on a v9.16 fixture |
| The WORLD never scaled with the monitor: ZOOM() returned the dial alone, so 4K showed 2.13x more ground (1920 units vs 4090) at half the size | v9.16 | ZOOM() is dial x hudRes; 1.05x now, projection exactly 1.000 at 1080p and 2.000 at 4K, pointer round trip 0-1px; check fails on a v9.15 fixture |
| Sector map chrome: frame and markers stayed 1080p-sized at 4K (frame reached 4px out at both) while the map grew 2.15x | v9.15 | frame, cache ring, encampment, locked-door and key markers scale by the same hudRes the text uses; check fails on a v9.14 fixture |
| Sector map: the map grew 2.15x at 4K while every label stayed at its 1080p pixel size (18.7/15.6/23.4 at both) | v9.14 | drawMapOverlay shadows FS with the screen factor; heading now 1.91x wide and 2.06x tall at 4K; check fails on a v9.13 fixture and guards the font cache from leaking |
| The BACKPACK never scaled with the screen: 1194x435 at 1080p and 1295x435 at 4K (1.08x wide, 1.00x tall) | v9.13 | tile/gaps/margins/paddings scale by hudRes; exactly 2.00x at 4K, same 11 columns, 1080p unmoved; check fails on a v9.12 fixture |
| Contract "+ XP" text lying, and nRaider:0 producing an empty map | not defects | checked v9.13: the sell handler does pay XP, and the row reads "AI pillagers 0-20" where 0 correctly means none |
| HUD panels could be dragged fully off screen and saved there, with no reset control anywhere (one flick put vitals at x -886) | v9.12 | clamp at the top of drawHUD keeps the drag bar reachable and repairs an already-broken profile; check fails on a v9.11 fixture |
| Bot water double-penalty, notes counter off the right edge, drag offset drawing-vs-hit mismatch | not defects | checked v9.12: fixed at v8.41, v8.43, and drawing agrees with hit-testing |
| His answer 48: Wirt had no special item at all, only the 2,500 gamble (two buttons, no hourly anything) | v9.11 | Lot of the Hour, flat 10,000, hashed from the clock so no seeded draw moves; check fails on a v9.10 fixture |
| His answer 37: reviving a pillager cost a medkit and paid nothing carryable (his bag unchanged, +0 credits) | v9.10 | he hands over his gun or best item, removed from his bag and stamped so the body cannot pay it twice; check fails on a v9.09 fixture |
| His answer 38: the resize corner drew the aiming reticle, and drag and minimise drew the same undifferentiated arrow | v9.09 | four pointers (move/resize/minimise/reticle), hudHit gained a grip part; check fails on a v9.08 fixture |
| Downed screen: CRAWL TO THE RING flashed (21.1 pct brightness swing every 1.2s) and the block never scaled with the screen | v9.08 | pulse gone while downed (0.0 pct), block scales with hudRes (bar 253px at 1080p, 506px at 4K); check fails on a v9.07 fixture |
| His answer 39 / sound visualisation: no noise visualisation existed at all (measured 0 pixels changed by an unseen gunshot) | v9.07 | red rings for unseen sounds; 1 ring and 120 px for unseen, 0 and 0 for seen; check fails on a v9.06 fixture |
| His answer 32: death screen should show bag value lost | not a defect | checked v9.07: KIA screen lists every item LOST and prints "5 items lost, $7,450 gone" |
| GREENBELT: contracts named a colour palette (RUST YARD / FOUNDRY / GREENBELT / BLOCKHOUSE) as if it were a place | v9.06 | contracts now name the map zones; check fails on a v9.05 fixture with 10 of 10 naming a palette |
| His answer 8: fire while looting | not a defect | checked v9.06: holding search plus trigger fired 31 rounds over 240 frames with the bar still filling |
| His answer 44: COLD STORAGE offered only 4 eligible start points, so he kept landing in the same corners | v9.05 | 6 new spawns; pool 4 to 10, distinct starts 4 to 10 over 60 seeds, top share 40 pct to 16.7; check fails on a v9.04 fixture |
| His crier note: criers idled inside houses (46.3 pct of patrol time on COLD STORAGE, 3 of 16 spawning indoors on THE COLD MILE) | v9.04 | new regress check fails on a v9.03 fixture; after, 0.2 and 0.4 pct, crawlers still 80.6/60.4 pct indoors |
| Answer 16: an emptied belt key became a DIFFERENT item (medkit slot became Frag Charge) instead of greying | v9.03 | new regress check fails on a v9.02 fixture with the exact defect, passes on v9.03 |
| `var cap` deleted while four readers remained; holding E threw | v8.37 | loot leg of `__verify` |
| v7.39 migration ran unstamped every load, wiping the mile's seal and fog | v8.38 | |
| `replaceCost` read `o.cost`, SHOP rows carry `price`; servicing ~6x too cheap | v8.38 | |
| district contracts never compared `ct.d` to `c.d` | v8.38 | |
| nameplates drawn from the centre of a centred plate, overflowing 82px | v8.39 | |
| belt `_eq` branch inverted `inHand` once `p.swapped` went true | v8.39 | |
| `padRelease` wiped `PAD.prev`; every pad button level-triggered | v8.39 | |
| safe pocket armed before buildRaid auto-packs, so it never fired | v8.40 | |
| DEV CHEAT BOX unconditional in shipping builds | v8.40 | |
| bot paid the water speed penalty twice (0.34 x 0.55) | v8.41 | read the code: `moveToward` now excludes the player |
| bot crouch noise discount applied twice | v8.41 | `CNOISE` carries only the wading factor |
| XP formula scored only 5 of 9 tracked kill kinds | v8.42 | `KILLXP` has all nine |
| contract payouts printed "+ XP" while the writer pays none | v8.42 | the "+ XP" text is gone from both surfaces |
| a bullet hitting a machine sent that machine after the PLAYER | v8.42 | |
| chosen sidearm accrued wear but never got the worn gun's stats | v8.43 | |
| "N notes logged" drawn left-aligned at W-16, off the right edge | v8.43 | `textAlign='right'` set locally at the call |
| HUD drag offset applied differently in drawing vs hit-testing | v8.44 | |
| a raider's equipped gun duplicated into its drop bag (~900c each) | v8.44 | probed 7 raiders: exactly one copy, dedupe guard live |
| merc ignored the LOOT order | v8.45 | |
| merc's cut paid from a number only a HUD draw updated | v8.46 | |
| contracts could never report completion mid-raid | v8.47 | probed: district contract goes 0/1 to 1/1 and stamps `contractsMid` |
| the great door's slab drew over everything, unsorted | v8.50 | |
| four routes out of the backpack never called `clearKeysFor` | v8.51 | |
| reinforcements arrived a minute early, first one instantly | v8.53 | |
| heal/plate wind-up bar drawn behind the player's own head | v8.54 | |
| fulgurite was a corpse, placed with no reachability test | v8.55 | 197/197 bad strike points relocated, median 40 units |
| roads crossed every authored wall (only 10 of 597 blocked one) | v8.55 | 446 and 802 crossings to 0, controlled against the v8.54 build |
| Warden and Bulwark used the light footstep | v8.55 | `__regress` checks all nine kinds every build |
| nine player-facing strings said "1 items" | v8.56 | each read back at n=1 and n>1 |
| a ring pillager's sight came from the PLAYER'S scope, skipping crouch and concealment | v8.43 | read the code: the call now passes the same values the chase branch uses |
| "closest you came to extraction" measured to the targeted ring, not the nearest open one | v8.58 | 152m vs 387m on cold, 166m vs 381m on the mile |
| the sector board printed a dimension in hectares, ten times too small | v8.58 | rendered board now reads 420 by 340 metres, 14.3 hectares |
| the down message asked for medical that self-revive never needed | v8.58 | emptied the bag, went down, F worked: 40hp, one revive |
| the workshop promised jamming while every wear band is jam 0 | v8.58 | text corrected; a regress check watches the table |
| melee swung with no line of sight test on either the crawler or the Listener | v8.59 | 9 wall-separated geometries inside reach on the mile, all 9 now refused |
| rolling froze heal-over-time completely | v8.59 | 30 queued points applied 0 while rolling, 30 standing still; now equal |
| burst echoes skipped wear, so a burst gun wore a third as fast per round | v8.60 | 0.33 per round against 1.00; now 1.00, single-shot control unchanged |
| a crawler killed while playing dead never died and never dropped | v8.60 | hp -5 and still in the list after 10s; now dies, and the ambush still arms |
| the boarding hold banked progress when you walked out of the ring | v8.61 | held to 1.033, left for 2s, finished in 20 frames; now resets, and boarding without leaving still works |
| death screen HEALTH/DAMAGE columns showed pre-armour values | misidentified | the only DAMAGE column is the weapon inspect panel; the health figure is stamped after armour and after hp is reduced |
| grantLoot's tail announced items still in the box | misidentified | the line there is the auto-equip message for a gun already taken |
| closeSchedule was absolute seconds against a scaled clock | already correct | it is fractional [2/3, 4/9, null] and clamped; queue row was stale |

## Could not reproduce
| Extraction pull overwriting a Listener hunt: source has no Listener guard (the noise path does) but the pull never fired on a Listener in 3 attempts, pullN stayed 0 across 200 frames. Open, v9.21. |

| Finding | What I did | Result |
|---|---|---|
| a sentry in chase walks to the player's LIVE position with no sight test | wrote the fix, then compared against the v8.61 build checked out and rebuilt | REFUTED and the fix REVERTED. The role block does read p directly, but it sits inside `if(sees&&...)` and only runs while the machine can see you. Both builds gave identical numbers, so the patch never executed. |
| packCall recruits Criers, and a Crier can never execute a pack role | applied packCall's exact treatment to a Crier and stepped 5s with __sim | it moved 290 units with its moving flag set. Not frozen. Whether it is a GOOD pack member is a design question. |
| simStep never calls tickHot, so the hot zone is frozen in every headless sim | grep | fixed at v8.45, which added the call. |
| shooting a Crier before it spots you leaves `wind` NaN, HUD prints "CRIER NaNs" | swept 4 raids x 150s on both maps for any NaN numeric field on any entity or the player | no NaN found. Both writers of `state='alarm'` set `wind` on the same line. Reopen only with a repro. |
| `nRaider:0` from the Settings row produces an empty map | set it and counted kinds | it removes raiders and nothing else: 58 ents to 51, every other kind intact. The row does what it says. |

## Open

| Finding | Note |
|---|---|
| the collision push-out can eject a body through a thin wall | v8.60 CONFIRMED REAL, not a probe artefact: with no bot navigation at all, 8 of 1228 thin walls on the mile eject the player out the far side, 32 to 53 units in one frame. NOT FIXED: unreachable in play (centre never inside a wall over 7200 frames; rolling into them crossed 0 of 1039), and collide runs for every entity every frame. |
| melee: no merc exclusion, no aggro, no break | v8.59 closed the wall/LOS half. Armour was already applied by damagePlayer, so that part of the finding was wrong. The rest is unreproduced. |
| beacon investigate overwrites the Listener's hunt | from the raid audit, not yet reproduced |
| ~85 remaining mediums and lows from the full-file audit | not yet triaged into this table |

## For his ruling, not a defect

- The extract-closure comment says points close "leaving one". True on COLD
  STORAGE (3 rings); THE COLD MILE has 6 and only 2 ever close, so the late-raid
  squeeze barely happens on the bigger map. Matching the comment is a large
  difficulty change on the map that already extracts higher (23.5 vs 18.0).

## For his ruling, added v8.58

- **Should worn guns jam?** The mechanic is built and wired end to end: the wear
  step's jam figure is copied onto the weapon and the firing path rolls against
  it and jams the gun for 0.9 seconds. All four wear bands carry `jam:0`, so it
  has never once fired. The workshop used to advertise it; that text is now
  corrected rather than the table changed, because turning it on is a balance
  decision. One table edit switches it on whenever he wants it.

## Checked v8.63, nothing found

| Finding | What I did | Result |
|---|---|---|
| the Undercroft stations | walked to each and pressed E, the real path | all eight register and open, nothing thrown, no broken text. THE STASH is a screen, not a modal, which is why an earlier sweep read it as opening nothing. |
| station panels overflowing at 1920x1080 | measured every panel and every child box | three have children outside the panel box (Mainframe, Settings, cheat box), all inside a scroll region with nothing unreachable. |
| a CFG dial silently switching off a whole system | checked all 18 dials that default to zero | all bot-only or deliberate. safeSlots is the retired pocket implementation, zero for everyone since v5.32, superseded by the named-item one. |
| the panel promise "ONE ITEM SURVIVES YOUR DEATH" | __deploy with a real kit, then died, both directions | it works. Named item comes home, nothing comes home without one. Now a regression check. |

## For his ruling, added v8.63

- **Should abandoning a raid destroy the kit you carried up?** Measured with a
  kit of servo, scrap and wire: extract returns all three, dead loses all three,
  abandon also loses all three. Abandon already carries a 75 percent XP penalty
  against the 50 percent for death, so walking away is strictly worse than dying.
  It applies instantly too: quitting one second after landing, nothing moved and
  nothing searched, still destroys the kit, on a path written to discard the run
  as never having happened. NOT changed, because returning the kit on an instant
  quit lets you deploy, read the map and quit for free, repeatedly.

## Closed v8.64

| Finding | Closed by | How it was confirmed |
|---|---|---|
| a raid that takes your kit left the belt keys bound to it | v8.64 | dead / instant abandon / abandon after 3s all clear now; extract keeps both keys with both items home |

## Checked v8.64, nothing found

| Finding | What I did | Result |
|---|---|---|
| a kit containing a gun or armour leaves the stash by a different route | deployed a rifle and a plate through all three endings with a clean armoury | all correct: extract banks the rifle and returns the plate, dead loses both, abandon restores the armoury exactly as before deploy |
| the kit has a three slot limit the code does not enforce | staged 1 to 6 items and counted what went up | there is no limit. DEPLOY_SLOTS is 9999 and no player-facing text claims three. The stale phrase is a code comment. |

## Checked v8.65, nothing found

| Finding | What I did | Result |
|---|---|---|
| a gun bound to a belt key might fire instead of equipping | bound a gun, drove the slot, counted shots | it never fires. The two gun slots swap correctly both ways. Now a regression check. |
| belt assignments might not survive or might wrongly survive a raid | traced the in-raid map against the stored one | the raid gets a copy and only MANUAL pins are written back, so automatic pins correctly do not persist. |
| an automatic pin can mask a derived slot that grows into its index | read the yield logic and the slot list | automatic pins yield to the highest empty slot; manual ones deliberately override, which is the v6.61 rule. |
| a plate wastes most of its value | read the item and the rig cap | a plate is 20 against a cap of 60 and applies fully. The 55 figure in an old comment is stale text. |

## Checked v8.66, nothing found

| Finding | What I did | Result |
|---|---|---|
| the belt key handler itself might be wrong | real keydown events for digits 1, 2, 5 and 6 | correct: each selects its slot, the gun slots swap weapons, and nothing fires. |
| dragging onto a belt slot | drove the real mouseup handler against the real hit boxes, six cases | all correct: assigns, refuses a gun on a consumable slot and a consumable on a gun slot with a message that names the refusal, moves without duplicating, treats a drop on its own slot as a click, and swaps two occupied slots cleanly. Five locked into the suite. |

## HIS QUEUE, reported 2026-09-01 during v8.67, NOT yet done

| Ask | Note |
|---|---|
| ~~Extraction screen: the "first seen" line is cheesy, remove it~~ | DONE in v8.68 per the note below this table |
| ~~Extraction screen: "x of Y XP" does not say what happens at Y~~ | ALREADY DONE, checked at v9.88: the line reads "Next: <tier>, reward N of M, X XP away. Claim it at the Mainframe.", and on a death screen it is omitted on his v8.91 note |
| ~~Extraction screen: "Claim it at the board" should read "Complete contract at mainframe"~~ | DONE in v8.68 per the note below this table |
| ~~Extraction screen: why is there no proficiency rating~~ | DECIDED by him, folded: level is the one number, proficiency lives on only as the Net carried out card |
| ~~Extraction screen: "the Mainframe, 4 racks fenced the data" should read "Mainframe bonus: $XXX", moved to the bottom in a dimmer colour, it is not that important~~ | DONE at v8.69: reads "Mainframe server bonus: $X" in ash at the bottom |
| ~~Cannot move items from the tactical belt to the backpack in the Undercroft~~ | CLOSED v9.82: reproduced with the gesture, one line, the missing half of v8.72 |
| ~~Remove crafting of purple, blue and gold strength guns; they should only come from the Peddler or raid loot~~ | ALREADY TRUE, checked at v9.84: RECIPES holds eight recipes and not one is a gun; guns come only from the Peddler and the surface |
| ~~Superhot mode: remove the text "moving the mouse to aim is free"~~ | DONE in v8.68 per the note below this table |
| ~~Make sure all the modifiers in the settings menu work as intended~~ | CLOSED v9.84 and v9.85. All 24 options write their keys. All eight rows now driven to a WORLD consequence: six were honest, the Machines row moved sentries and not crawlers (v9.84), and extraction heat was a real choice at Light and worth one machine at Heavy (v9.85). Both fixed, both with checks |
| ~~INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both~~ | DONE, and both halves re-measured at v10.70. The raid grid stopped drawing a copy claimed by a key at v8.78 and the Undercroft grid at v6.60; measured today, packing three items and putting one on key 3 takes the backpack count from 3 to 2 while the key count goes to 1. G.bag stays the single store on purpose, because moving items between two real arrays would touch every loot, drop, sell, death and extraction path in the file |
| ~~Too many footsteps when sprinting~~ | NOT REPRODUCED at v9.86: 2.2 sounds a second walking, 3.2 sprinting, 1.6 crouched; stamina caps a held sprint at 2.5 average. Tapping movement gives FEWER steps, not more. The stutter was fixed at v8.73 |

## HIS QUEUE, updated end of v8.68

DONE in v8.68: EXTRACTION IN PROGRESS wording; superhot hint; "Complete contract at mainframe"; first-seen line removed; "Nearest extraction is Xm away" on the downed screen.

STILL OPEN:

| Ask | Note |
|---|---|
| ~~Extraction screen: "x of Y XP" does not say what happens at Y~~ | ALREADY DONE, checked at v9.88: the line reads "Next: <tier>, reward N of M, X XP away. Claim it at the Mainframe.", and on a death screen it is omitted on his v8.91 note |
| ~~Extraction screen: why is there no proficiency rating~~ | DECIDED by him, folded: level is the one number, proficiency lives on only as the Net carried out card |
| ~~Extraction screen: "the Mainframe, 4 racks fenced the data" -> "Mainframe bonus: $XXX", moved to the bottom in a dimmer colour~~ | DONE at v8.69 |
| ~~Cannot move items from the tactical belt to the backpack in the Undercroft~~ | CLOSED v9.82: reproduced with the gesture, one line, the missing half of v8.72 |
| ~~Remove crafting of purple, blue and gold strength guns; Peddler or raid loot only~~ | ALREADY TRUE, checked at v9.84: no recipe makes a gun |
| ~~Make sure all the modifiers in the settings menu work as intended~~ | CLOSED v9.84 and v9.85. All 24 options write their keys. All eight rows now driven to a WORLD consequence: six were honest, the Machines row moved sentries and not crawlers (v9.84), and extraction heat was a real choice at Light and worth one machine at Heavy (v9.85). Both fixed, both with checks |
| ~~INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both~~ | DONE, re-measured at v10.70: the raid grid since v8.78, the Undercroft grid since v6.60, counted per key so one of three medkits on a key leaves two in the backpack. The row above it in this table is the same ask and carries the numbers |
| ~~I opens the BACKPACK. Write the matching list of consistent definitions~~ | CLOSED v9.89: the vocabulary note gains Backpack, Hotbar, Safe pocket, Stash with their never-words, and the six on-screen strings that called the hotbar a tactical belt or the bar now say hotbar |
| ~~Too many footsteps when sprinting~~ | NOT REPRODUCED at v9.86: 2.2 sounds a second walking, 3.2 sprinting, 1.6 crouched; stamina caps a held sprint at 2.5 average. Tapping movement gives FEWER steps, not more. The stutter was fixed at v8.73 |
| ~~ESC should pause in the Undercroft~~ | ALREADY BUILT since v8.70, measured at v9.83 with a real Escape keypress on the floor: the pause box opens |
| ~~The roll graphic is WRONG in the Undercroft~~ | NOT REPRODUCED at v9.83: it draws a disc, fill 0.78 against a circle 0.785, and travels 43 units |

## FOR HIS RULING, 2026-09-04: NOTE 19

19. SEVEN OF EVERY EIGHT PEOPLE IN THE UNDERCROFT ARE IN A FULL-BODY SUIT.
    Measured at v10.99 while testing the racks. The crowd's look roller picks one
    item from EVERY rack, and that includes the OUTFIT rack, which holds Own
    Clothes plus seven full-body suits: the Skeleton, the Machine, the Trooper,
    the Android, the Tomb Explorer, the Baller and the Street Poet. A suit
    overrules every other rack by design, his answer at v10.54. So the floor is
    mostly costumes and the hats, beards and tattoos v10.99 just switched on are
    invisible on most of the crowd. Measured: 3 of 16 crowd rolls show a hat.

    NOT CHANGED, because this is a look decision and not a defect. The options,
    for a word from him: leave it, weight Own Clothes so suits are rare on the
    floor, or take the outfit rack out of the crowd roll entirely so a suit is
    something only he wears. Say "suits rare", "no suits down there", or nothing.

## HIS NOTES 21 AND 22, 2026-09-04

21. "sometimes my shots make a red noise circle when they hit something,
    sometimes they don't --whats up with that?" A rule he can see the effect of
    and cannot work out. Find what actually gates that ring: damage dealt, the
    kind of thing hit, distance, the noiseSee dial, or whether the shot killed.
    Then either make it consistent or make the rule legible. REPRODUCE BY
    ENUMERATION: fire at each kind of target at several ranges and record when
    the ring appears, rather than watching for it.

22. "Once again, crawlers aren't attacking properly?" SECOND TIME HE HAS ASKED.
    The first was 2026-09-03, "i saw atleast one instance where i was standing
    still and crawler didn't hurt me even though he was close", which led to the
    two if/else chains finding: a non-raider fell into the idle-wander else in
    the middle of a chase and that wiped the crawler attack cooldown every frame.
    If it is back, that fix was incomplete or a second path does the same thing.
    HIGHEST VALUE ON THE BOARD: combat that does not work makes the alpha
    pointless. Reproduce by standing a player still inside a crawler's reach and
    counting damage per second over many frames, at several distances and with
    several crawler states, rather than by watching one instance.

## HIS NOTE 20, 2026-09-04: THE BALLER'S JERSEY IS COVERED

20. "micheal jordan character, can't see his jersey bc its blocked by a black
    block (maybe supposed to be backpack straps?)".

    FOUND, and it is not the backpack. The pack is drawn BEFORE the torso and the
    torso covers it. It is the jersey's own black side panels, added at v10.46:
    two bars of #14161b, each 2.4 wide and 10 tall, at the outer edges of a
    13-wide chest. That is 4.8 of 13, thirty-seven percent of the jersey, in
    near-black, on a red shirt. At sprite size two black vertical bars on a chest
    read as straps, which is exactly what he said.

    THE BUILD: the side panels become trim rather than blocks, thin enough that
    the red reads as a jersey and the 23 has room, and the check measures the
    pale and red pixels across the chest against the black ones rather than
    asserting a width. The v10.46 jersey check already counts pale pixels and
    must be updated in the same build, since its subject is being changed.

## HIS NOTE 18, 2026-09-04: ONE FONT, AND THE LOOT POP IS STILL THE WRONG ONE

18. "the loot text that pops on screen upon looting that tells you what item you
    got is still too bolded -- use the entire font across the entire game".
    STILL, so this is the second time he has raised it; the first was the note
    about looted item names being super-bold and hard to read.

    ALREADY FOUND, the cause: the world label function draws with
    "Titan One", the heavy display face the title screen uses, and not with the
    TYPE roles that the rest of the game is set in. Every world label goes
    through it, so PICKED UP, the item name, DOWNED, ELIMINATED and the rest are
    all in the display face at 10 or 11 px, which at that size reads as a solid
    black slab rather than as text.

    THE BUILD: the label font becomes a TYPE role like everything else, and then
    the whole file is swept for any other draw call that names a family directly
    rather than going through TYPE, because his instruction is not about this one
    label, it is "the entire font across the entire game". The title screen
    wordmark is the one place a display face is deliberate and it is in the DOM,
    not on the canvas.

    REPRODUCE BY COUNTING, not by looking: trace one frame of a raid and one of
    the Undercroft, record the font on every text draw, and count how many are
    not one of the five TYPE roles. Then require that count to be zero, with a
    control that the tracer sees a font it was given on purpose.

## FOUND WHILE PROVING AN INSTRUMENT, 2026-09-04: NOTE 17

17. NO PILLAGER HAS EVER WORN A HAT, A BEARD OR A TATTOO. Found at v10.94 while
    proving the eye instrument, by asking each rack whether it changes a NON-hero
    figure at all. The same rack, on the same call, changes the hero and changes
    a pillager by nothing:

        headgear   hero 31978 pixels, pillager 0
        beard      hero  5221 pixels, pillager 0
        tattoo     hero   801 pixels, pillager 0

    CAUSE: the block that draws the fringe, the beard, the tattoo and the
    headgear sits inside a hero-only branch, so everything in it is hero-only.
    Hair cut is outside it and does reach a pillager, which is why the crowd
    looks varied enough that this went unnoticed.

    WHAT IT COSTS: the Undercroft crowd rolls a hat, a beard and a tattoo for
    every member and none of them are drawn. Two lines of the new-in card promise
    the racks reach the crowd and the pillagers, and v10.24 was built on that
    claim. So this is a shipped promise that is not true.

    THE BUILD: ungate the headgear, the beard and the tattoo, and leave the
    FRINGE hero-only, because that is the operator's own hair styling and giving
    every pillager her fringe would be a different change. Reproduce first with
    the same instrument, then require a non-zero delta per rack on a pillager and
    an unchanged hero, and check the raid too, not only the Undercroft, since the
    same call draws both.

## HIS NOTES, 2026-09-04, FIFTEENTH AND SIXTEENTH

15. "pillagers in the undercroft still have weird eye collissions on trhier faces
    in some instances". STILL, so this is a return of something already looked
    at once. The crowd in the Undercroft dresses from the same racks as the
    operator, so an eye is drawn against a head that varies by build, skin,
    headgear and hair, and "in some instances" says it is a combination and not
    every figure. REPRODUCE BY ENUMERATION, not by looking: roll every crowd
    look the game can produce, draw each one large, and measure whether the eye
    marks land inside the head and clear of the brow, the headgear brim and each
    other. The instrument has to be a count of bad combinations out of the total
    tried, or "some instances" can never be shown to be fixed. Note that the
    field is not called face on an entity, and that v10.16 already has a look
    roller the check can drive.

16. "add weather conditions as a selection toggle in the 'Where are you going'
    screen". The sector screen. Weather already exists in the raid world; this
    asks for it to be a CHOICE at the point of departure, alongside the map and
    the time of day, rather than something the raid decides. Check first what
    weather states the raid actually supports and whether the sector screen can
    already pass one through, because his answer 23 makes the time of day a
    random roll and weather may be wired the same way. This is a new player
    facing control, so it needs a place on that screen, a saved preference, and
    the raid honouring it. Not a balance change: no dial moves, the weather is
    whatever it already was, he just picks it.

    HIS FOLLOW-UP, same day: "choose more difficult weather shouild hive small xp
    boost like 1.1x". So the toggle is not free. The harder states pay more XP,
    at about 1.1x, the way night already pays 1.2x XP under his answer 22. That
    gives the ranking a job: clear pays 1.0, and the states that cut sight or
    kill the lamps pay the bonus. This is HIS number, not a dial I chose, and it
    goes in with the toggle rather than after it, because a choice with no cost
    and no reward is not a choice.

## HIS NOTES, 2026-09-04 EVENING, TENTH TO FOURTEENTH

10. "text in the undercroft should be less transparent/more opaque". The station
    labels and any floor text on the Undercroft. Measure the alpha each is drawn
    at before changing it, and raise them together rather than one at a time.

11. "change 'Discount Fashion Depot' to 'Fashion' wherever it occurs". Every
    occurrence, including the station label, the window title, any WHATSNEW or
    primer text, and the vocabulary note, which currently defines the long name.

12. "anything that can be used to craft or for a contract, etc. should not be
    classified as salvage". A classification rule, not a balance change: an item
    that is a crafting input or a contract target must not read as salvage in the
    bag, the stash, the sell screen or the run report. Reproduce by listing every
    item that is both a craft or contract input AND currently tagged salvage.

13. "pausing at the undercroft screen should give an option to 'RETURN TO
    CHARACTER SELECTION' that takes the player back to the title screen", then:
    "actually 'RETURN TO THE UNDERCROFT' AND 'RETURN TO CHARACTER SELECTION'
    should be the 2 choices". So the Undercroft pause box offers exactly those
    two, in that order.

14. "when friends give feedback the game should also log their character info,
    that way if they lose their character accidentally, we can give them a code
    to restore it". The run report already carries a profile summary line; this
    wants enough to RESTORE from, and a code the player can be given back.
    Design question to decide before building: the whole profile is far too big
    for a paste, so the restore code is probably a compact encoding of the parts
    that matter, name, credits, XP, stash, cosmetics, and it needs a matching
    import path in Settings. Larger than one build.

## HIS NOTES, 2026-09-04 EVENING, SEVENTH TO NINTH. He is away about 8 hours from
## this point and the alpha is about 60 hours out.

7. "X to change weapons i don't think is necessary any more given the hotbar, we
   can remove concept of x to change weapons". Delete the swap-guns key and the
   concept. Check every place that mentions it: the keydown handler, the legend,
   the pause controls text, the primer, the pad map, and anything that calls
   swapGuns from elsewhere. The two-gun carry itself stays; only X goes.

8. "if i click fullscreen and then click to change the save, it kicks me out of
   fullscreen, why??". A real bug. Likely cause to check first: changing the save
   reloads the page or rebuilds the canvas, and a browser drops fullscreen on
   navigation. Reproduce on the real game, not a fixture, because fullscreen
   needs a user gesture and a real document.

9. "get rid of the 'first time out' menu/screen, delete it entirely, no more
   references to it, the player has to figure this shit out on their own".
   Delete the primer card, its opener, its cue line, its scroll handling and
   every string. Note this retires v10.69 and its check, which measured the cue
   counting hidden cards; that check must go with the feature rather than be
   left asserting a screen that no longer exists.

## HIS NOTES, 2026-09-04 EVENING, FIFTH AND SIXTH

5. "change the feedback buttons at the end of a raid to something more current".
   The run report card's feedback row. Read what those buttons say today before
   changing anything: the tags are a fixed list and some were written for a much
   older build. Reproduce by listing every tag string the card offers and the
   ones the recorder has actually received, which is in the telemetry header as
   FEELING TAGS. Ask what a friend playing today would want to press.

6. "do some design research, pick a single font style, and apply it across the
   entire game. When items are looted, the names should not be in super-bold
   (thats how it looks right now), it makes it hard to read". TWO PARTS, and the
   second is the concrete one: the loot pickup line is drawn heavy and he cannot
   read it. Reproduce by finding every font weight used for a picked-up item
   name and measuring it. The first part is a whole-game typographic pass and is
   larger than one build: inventory the font stacks and weights actually in use
   first, then propose ONE family and one weight ladder before changing a
   pixel. Do the loot weight first, it is his actual complaint.

## HIS NOTES, 2026-09-04 EVENING, THIRD AND FOURTH (with a screenshot)

3. "text collission occcuring in lower right corner". The screenshot shows the
   gear panel: SUPPORT MG in the big weapon line and the green OPEN CLOUDED
   condition text drawn straight through it, overlapping by most of a word.
   Reproduce by measuring the two text rectangles on the gear panel at 1920x1080
   with a long weapon name and a condition tag showing.

4. "corner drag to size for lower right corner needs to be in lower left side,
   otherwise there's nowhere to drag to increase size". The resize grip for the
   lower-right HUD panel sits in its lower-right corner, which is already in the
   screen corner, so dragging outward has nowhere to go. It belongs on that
   panel's lower-LEFT corner. Same for any other panel anchored to a screen edge:
   the grip goes on the corner that faces INTO the screen.

## HIS NOTES, 2026-09-04 EVENING. BOTH TAKEN NEXT, IN THIS ORDER.

1. "change sprint on shift to something you hold to sprint instead of toggle".
   This REVERSES half of v10.07, which made crouch and sprint toggles on his
   own 2026-09-03 answer. He named sprint only, so crouch stays a toggle until
   he says otherwise. Reproduce: press and release Shift and show the operator
   is still sprinting; then hold and release and show sprint follows the key.
   Watch for the two places that read it, the live player and the legend, and
   for the stamina drain which is written against the sprint state and not the
   key. Not balancing: the speed and the stamina cost do not change, only what
   turns it on.

2. "player marker on map should be much larger, hard to see right now".
   The map screen, the one M opens. Reproduce by measuring the marker in pixels
   at 1920x1080 against everything else drawn on that screen, then size it so it
   reads at a glance. Nothing else on that screen changes.

## HIS INSTRUCTION, 2026-09-04: NO MORE IN-RAID BALANCING BEFORE ALPHA

Verbatim: "i feel like you are still wasting time on in-raid balancing and i don't
need any more of that before alpha ships please". BINDING until he lifts it. No
build before the alpha may move a balance dial, an entity count, a damage or
health number, a spawn rate or a map's contents. Bug fixes to his own notes,
crashes, sound and menus are not balancing and continue.

HIS RULE ON SOUND, same day: "there shouldn't be any oscillators with gain that
fades less than zero over a reasonably short time". Taken as a standing rule and
built into v10.85's check, which pins the count of oscillators started and never
stopped at the 2 the ambient bed accounts for, so a new voice with nothing to
turn it down is caught the day it is added.

## FINDING, 2026-09-04, HIS CRAWLER NOTE: REPRODUCED AND DIAGNOSED, FIX WITHHELD

His note reproduced exactly. Stand outside a building with a crawler inside it,
in chase with full alert: TWENTY SECONDS, never closer than 97 units, ZERO
damage. The same crawler in the open closes to a gap of 9.6 and kills in ten
seconds; inside the same building as you it closes to 9.4 and kills. So the
attack, the reach, the cooldown and the states are all fine. It cannot get out.

THE ROUTER SAYS SO: the crawler carries path null and pathFail 1 for the whole
chase, falls through to the local wall hug, and bumps around indoors while its
alert decays.

CAUSE: the nav grid is 16 unit cells and every wall is inflated by 12 before
cells are marked blocked. A doorway is a 64 unit gap in a 16 unit wall, so the
two runs either side eat 12 each and 40 units remain, two and a half cells. When
anything narrows that further the last free cell disappears and a door a body
can WALK through becomes a door no body can ROUTE through.

MEASURED at seed 4242, buildings a machine cannot route out of, counted only
where there is verified open ground to stand outside:
  COLD STORAGE    4 of 13
  THE COLD MILE  15 of 59

THE FIX IS WRITTEN AND WAS NOT SHIPPED. Each building records the gaps it cuts
and a doorway cell is unblocked only where its centre is outside every wall
rectangle with no padding, so it can never open a route through anything solid.
It takes the counts to 3 of 13 and 8 of 59, nineteen traps down to eleven, with
entities, containers and walls all identical. It is in tools/handoff as p1084
and f1084 a to d.

WHY IT WAS WITHHELD: with the fix in, v10.46 fails, a check about the number 23
jersey sprite on the clothing rack, reading -15 pale pixels where it needs 6.
The player spawn and every container position are byte identical either way and
I could not explain the connection. Sixty hours before he shows this to his
friends I am not shipping a change I cannot account for. Next tick: bisect the
four edits, find it, ship it.

STILL OPEN even with the fix in: the exact case that started it, building 3 on
COLD STORAGE with the player 52 units off its west wall, finds a route and does
not walk it, stalling at 73 units for thirty seconds.

THREE OF MY OWN PROBES WERE WRONG before any of the above was true, and each
would have shipped a fix for nothing: one put the crawler outside the map, one
called a spot clear when the crawler's start was inside a building, and one
teleported the player 300 units away, past a crawler's 135 unit sight, and read
the blindness as a bug.

## HIS NOTES, 2026-09-04, sent 60 hours before the alpha. BOTH TAKEN NEXT.
- "sound needs work, there are random humms that last way too long, like after
  you die, etc". A hum that outlives the raid it belongs to. Reproduce first:
  drive a raid to each of the three endings and to the pause box, and list every
  oscillator and every gain node still scheduled or still running afterwards,
  with how long each has left. The fixture SILENCES sound (memory: the fixture
  overrides say, sfx and blip), so this has to be measured on the real game on
  :8802 or on an unstubbed fixture, or it will report silence and prove nothing.
  Taken as the next build.
- "double check that crawler attacking is working properly, i saw at least one
  instance where i was standing still and crawler didn't hurt me even though he
  was close". Reproduce: stand the player still, put a crawler inside its reach,
  step the game and count damage over time; then sweep distance and angle to
  find the band where it closes but never lands a hit. v9.60's two-if-else-chain
  fault is the obvious suspect (memory: non-raiders fall into the idle-wander
  else mid-chase and it wiped the crawler attack cooldown every frame), so check
  that first and check whether crouching or standing still changes the branch.
  Taken as the build after the sound one, unless the sound work is small.

## HIS NOTES, 2026-09-03, three lines before leaving for six or seven hours
- "when a pillager is downed, it should take more than 1 scav pistol shot to
  eliminate them." Taken as the next build. Reproduce: a downed pillager, one
  Scav Pistol round, does he die.
- "menus and hud in the raid are still wonky, can you give them an overhaul".
  Broad. Measured first: every HUD panel rect at 1080p, 1440p and 4K, looking for
  overlaps between panels, panels off the viewport, and drawn text outside its
  own panel. What is wonky gets fixed by name; nothing gets redesigned blind.
- "i am going to be gone all day and give very little or no feedback for the
  next 6-7 hours". No questions, keep shipping, real notes first.

- "crouch should be default bound key to each of ctrl and c" (sent a few minutes
  after the other two). Taken as its own build after the downed pillager: crouch
  reads ControlLeft, ControlRight and KeyC, and the legend says so.

- "on pause screen text --- RMB = 'aim down sights'" (a minute later). The pause
  screen's controls text should read RMB aim down sights; today the full legend
  says "steady aim" and the compact one says "aim". Its own build after crouch.

- "during a raid, mouse wheel should zoom, but ctrl and mouse wheel should
  change the hud size, just like the - and = keys do" (two minutes later). The
  wheel handler at the canvas already zooms the world; with ctrl held it should
  step the HUD size through UISCALES exactly as Minus and Equal do. Its own build.

- "when a mouse wheel is used inside a scrollable menu, it should scroll up and
  down, NOT modify the menu size -- like on this page [screenshot: SHOP, CRAFT,
  AND HIRE, the HIRE tab, a scrollbar beside the grid], it modifies menu size...
  but it shouldn't if i'm inside the menu." Then: "inside the scrollable portion, rather". Same build as the wheel note above:
  in a raid the wheel zooms and ctrl-wheel sizes the HUD; inside a scrollable
  menu the wheel scrolls and never resizes.

- "Wirt screen '$2500 a go' -- change to '$2500 per roll'. 'You do not have to
  carry it out of here' -- DELETE this sentence, not helpful" (a few minutes
  later). Two strings on Wirt the Gambler's screen. Its own build.

- "for buyable item -- call it" (sent incomplete, a minute after the Wirt note).
  Then, completed: "Limited Time Offer -- Worth X. New item in X minutes" -- "thats the only text we need there". Wirt's 10k lot card keeps exactly those three lines and nothing else. Same build as the other Wirt strings.

- "Wirt screen should draw a more clear delineation between the gamble and the
  Limited Time Offer item" (right after). Same Wirt build: two sections, THE
  GAMBLE at $2,500 per roll, and LIMITED TIME OFFER with Worth X and New item in
  N minutes, visibly separated.

- "wirt's Limited Time Offer item should change every 5 minutes" (right after).
  It changes hourly today, wirtLotHour on 3,600,000 ms. Same Wirt build: the
  period becomes five minutes and the card says New item in N minutes off it.

- "using Liquor or Blotter should give a small XP boost per stack while the
  effect is occurring" (2026-09-03, while v9.91 was in its full run). The bar's
  two doses today do what their tags say and nothing for progress. Taken as its
  own build after the Wirt screen: while a buzz is up, XP earned is multiplied by
  a small amount per stacked dose, shown where XP is shown.

- "the stash screen is way too busy -- SCRAP it entirely -- change it so it just
  has 1. Stash inventory 2. Player backpack 3. Player hotbar 4. Safe Pocket
  5. Freebie Kit Selection. Get rid of the stuff marked out in white in the
  image [screenshot of THE STASH at v9.90: the whole YOUR OPERATOR column on the
  left, cosmetics and the numbered loadout saves, is struck out in white; so is
  the bottom row of buttons, RETURN TO THE UNDERCROFT, SHOP, CRAFT, ARTEFACTS,
  SURFACE: DAY, LAYOUT 6/10, SETTINGS, and the armour line above it]. day vs.
  night selection should move to map selection screen that occurs upon
  ascension. Cosmetics should move to their own screen and their place in the
  Undercroft, maybe call it 'Appearance'. Build out the cosmetics system even
  more. after you've met ALL my current unfulfilled requests, audit, comb code,
  clean, audit polish, improve, etc" (2026-09-03, right after the XP note).
  Taken in order after the XP build, as more than one build: (a) the stash
  screen cut to his five parts, with the operator column, the loadout saves,
  the button row and the armour line gone from it; (b) SURFACE day or night
  moved to the map choice on ascension; (c) an Appearance station in the
  Undercroft holding the cosmetics; (d) more cosmetics. Then the standing idle
  policy: audit, comb, clean, polish. Open question I will decide myself: how he
  gets back to the Undercroft and to the freebie kit once the button row is
  gone (ESC and a single close, most likely, since the kit stays on the screen).


## TELEMETRY, 2026-09-03 09:02, his export run-20260903-090258.txt (v9.90 recorder, install 4gm5qv8ul7y5)
Authenticated: real. Eleven runs, durations 26s to 543s, shots up to 157, killers
crawler, raider, sentry, listener, timer. Runs 1 to 10 were in earlier exports;
the new one is #11 on v9.90: DEAD, Chatter, 111 seconds, killed by a sentry
(K-43) in a siege on THE COLD MILE at dusk, zero containers opened, one crawler
and one pillager killed, downed twice and revived by his crew both times, died
151 m from the nearest extract while "doing extract".
What the whole file says, in the recorder's own words: 0 of 11 extracted; 6 of
10 deaths before ever calling extraction, 4 during the siege; "60 PERCENT DIED
BEFORE THE DECISION TO LEAVE EXISTED. Fix the looting phase first." Killers
across the file: listener 3, sentry 3, crawler 2, raider 1, timer 1. His
feeling tags: Pillagers felt dumb x1, Listener unfair x1, Maps feel samey x1.
Taken as: the machines kill him, not the pillagers; the Listener and the sentry
are the two to look at when the balance work comes up after his notes. Question
46 and 47 of QUESTIONS-2026-09-03.md ask him for the target rate and his own
read of what kills him. The file is renamed consumed-.

## HIS FIFTY ANSWERS, 2026-09-03, about 10:40, to QUESTIONS-2026-09-03.md. BINDING.
He wrote: "YOU FIGURE OUT THE ORDER, I WILL RETURN IN 5-6 HOURS." Then: "we
desperately need to improve the graphics for the guns, its hard to even tell
what they are." Then: "ok cya in 5-6 hours."

The stash screen
1. Every menu screen in the game has a CLOSE button, and ESC works on every menu screen.
2. Tabs: KEEP, "super helpful", reorganised into Guns, Consumables (armour plates, heals, grenades), Parts, Salvage, Keys, Other if needed.
3. Sell bar: KEEP ON STASH.
4. One-line control hint: KEEP.
5. Numbered loadout SAVE slots: REMOVE, not needed.
6. Freebie kit: keep the single selection option as it is, nothing more.
7. The armour warning goes on the ASCEND MAP SCREEN (the sector page), not the stash.
8. Backpack on the stash screen: a GRID OF FIXED CELLS.
9. Arrangement as now, unless I see a way to materially improve it.
10. No search box.

Discount Fashion Depot (he renamed Appearance)
11. The word: "DISCOUNT FASHION DEPOT".
12. A new station on the floor called DISCOUNT FASHION DEPOT.
13. Drop none of the six categories.
14. ADD ALL of: face paint or scars, eyes, beard, gloves, boots, backpack colour, patches or badges, tattoos; also different clothing, more variety, anything else I can think of.
15. Cosmetics are EARNED.
16. No cosmetic costs credits.
17. The chosen look is ALWAYS visible on your character in the raid.
18. Randomiser button: YES.
19. Saved looks, three named presets: YES.
20. Other pillagers in the raid draw from the same cosmetic pool: YES.

Ascension and day or night
21. One prominent toggle on the map screen.
22. Night: "already jarring"; give more XP, a multiplier "just like 1.2".
23. Two choices only, and DAY gives a random time of day: morning, noon, afternoon or evening. (Checked against the code: pickTod already draws one of five times, dawn, 8am, noon, 6pm, 8pm, on every raid, independent of the day-or-night choice; night is a darkness layer on top. Nothing to build unless he wants dawn dropped.)
24. Default to DAY every ascent.

The raid HUD and menus
25. Bothers him most: CONTROLS (legend), CONDITIONS, PILLAGER BOARD, and ON-HUD MESSAGING.
26. Keep panel dragging and resizing; the mouse must CLEARLY indicate resize when over a corner.
27. Controls legend shown by default.
28. The Undercroft stash screen should incorporate the EXISTING RAID BACKPACK appearance, not the other way round.
29. Only PAUSE stops time; the map and the backpack keep the raid running. (Checked against the code: syncPause sets G.paused only for the pause box and the tuning console; the backpack and the map never pause. Already so; nothing to build.)
30. He plays at 4K; the game must be accessible at 1080p, 1440p and 4K.
31. No minimap needed; M opens the map.
32. Messages: not sure how a stack works in practice, would have to see it; messages should FADE eventually. (Checked against the code: the message line already fades, its alpha follows the last second of its 3.2 second life. Nothing to build; a stack is his to see first.)

Controls
33. Crouch on CTRL and C: TOGGLE.
34. Aim down sights on RMB: HOLD.
35. Sprint on SHIFT: TOGGLE.
36. No other key changes named.

Wirt and the economy
37. Limited Time Offer stays a flat $10,000.
38. The offer prints the item's name as well: "YES OF COURSE".
39. The $2,500 gamble should have a chance at the top items. (Checked against the code: the pull is rollTable(GAMBLE_POOL) and the pool carries blackbox, relay, codex, reactor and bloom at weight 1 each against a total near 130, so the top items come up about one pull in 26. Already so; nothing to build unless he wants the odds moved.)
40. Credits and XP at the top of every menu screen, consistently. (Checked against the code and then driven on v10.14: every station window, the trader, Wirt, the Depot, the bar, the terms, the contracts, the sector page, the cheat box and the settings, opens with credits and XP stamped into its heading (stampBalance in openModal since v6.14), and the stash screen carries its own header. Already so; nothing to build.)

The bar and XP
41. XP bonus: 2.5 percent per dose or liquor shot.
42. The bonus applies only to XP earned in raids, not to sales.
43. The dose clock keeps running in the Undercroft.

Pillagers and combat
44. A downed pillager starts at 50 health, and health TICKS DOWN during the downed count, so it takes three shots plus a little tick-down.
45. Downed pillagers CRAWL toward cover: "they should always play like real players, remember?"
46. No balance tuning: "30% is fine, I am just playtesting... it feels good for now."
47. Sentries and pillagers kill him most, "which is what it should be". Unrelated: RENAME THE ORGAN.

Sound
48. (blank)
49. MUSIC SHOULD NEVER PLAY IN A RAID, only in the Undercroft. (Checked against the code before acting: musicWanted() has returned false for the whole of a raid since v5.2x on his own order, "THE SURFACE IS SILENT"; nothing to build unless a probe hears otherwise.)

Order
50. I decide the order. He returns in 5 to 6 hours.

Plus, after the answers: "we desperately need to improve the graphics for the guns, its hard to even tell what they are."

MY ORDER, one thing per build, decided 2026-09-03 10:45:
v9.98 stash cut (in flight) -> v9.99 Discount Fashion Depot -> v10.00 more cosmetics, earned -> v10.01 gear panel inside the screen -> then his answers cheapest and most binding first: 41/42 bar bonus 2.5 percent, raids only; 38 the offer names its item; 44 downed pillager 50 and ticking down; 49 no music in a raid; 24 day by default; 22 night pays 1.2x XP; 23 day is a random time of day; 33/35 crouch and sprint toggle; 5 loadout saves removed from the ascent check; 7 armour warning on the sector page; 2 the tabs reorganised; 8/28 the stash backpack as a grid of cells in the raid backpack's style; 1 CLOSE and ESC on every menu; 40 credits and XP on every menu; 47 rename the organ; the guns' graphics; then 14/18/19/20 the wardrobe categories, randomiser, presets and pillagers' looks; then 25/26/32 the four HUD panels, the resize cursor and message fade; 29 map and backpack do not pause; 39 confirm the gamble reaches the top items. Then audit and clean.

## HIS NOTES, 2026-09-03 about 14:00, then "keep at it, be back in 4 hours"
- "i want a master chief esque green halo helmet as one of the cosmetic options"
- "and ghostface from scream as a helmet/head option"
- "i want a red and black 23 jersey (MJ) as a clothing option"
- "I want different shoes as options -- jordan 1, jordan 11, etc"
Taken as four rack additions after the drafted queue: two headgear (a green
Spartan-style helmet with a gold visor; a white Ghostface-style mask), one
clothing (a red and black number 23 jersey), and shoes on the BOOTS rack (a
Chicago-style red, white and black high-top; a Concord-style black and white
patent low-top; a Bred-style black and red high-top). Earned, never bought,
his answers 15 and 16. Names stay descriptive rather than brands.
## THE QUEUES ARE EMPTY, 2026-09-03 after v9.90
- "i want cosmetics to be a major part of what keeps people coming back for the
  long haul -- poke around community forums and read about what people say
  about Halo Reach because that game had the perfect 'earn cosmetics' system --
  we can add other pieces as you see fit -- outfits, gloves -- i would love to
  make the cosmetics screen kinda look like how you equip your character in
  diablo" (about 14:10). Taken as: (a) research first, a background pass over
  what players praise in Reach's Armory (credits from every match, rank tiers,
  challenges, commendations, pieces you can see coming, nothing random, nothing
  bought); (b) then the Depot becomes a paper doll, the figure in the middle
  with a slot per body part around it, Diablo-style; (c) then a visible ladder:
  what the next piece is and what earns it, on the screen and after a raid.
- RESEARCH DONE (about 14:30): what players praise in Reach's Armory, what
  they hated, and the Diablo layouts, with a dozen quoted statements, in
  tools/audits/reach-cosmetics-research-2026-09-03.md. Short form: credits
  after every game in every mode; buy in any order, nothing random; rank is
  lifetime earnings and never falls; new pieces appear when you rank up;
  daily and weekly challenges were the log-in hook; commendations tracked how
  you play; everything visible on your Spartan; a capstone gated on owning
  every helmet. Hated: the daily cap, the grind at the top, dead money, the
  double gate, the MCC re-do with fixed unlock order. For Pillagers, with
  buying ruled out by his answers 15 and 16: every ending pays, the NEXT
  piece named with its distance on the Depot and the outcome card, play-style
  gates (kills by weapon, streaks, night extracts), a capstone per rack.
  Challenges are a new system and wait on him.

## PRE-VERIFICATION OF THE QUEUE, 2026-09-03 about 16:00

Every drafted build from v10.19 to v10.36 was applied in order to scratch
copies, a fixture was built from the end state, parsed, and every queued
check was run on it from a second origin. Found and fixed before any of them
shipped:

- three anchor drifts (the jersey's torso anchor, then two cascades);
- seven checks whose `return /regex/.test()` the parse page's balance
  counter misreads as a division (parenthesised; the game compiled fine);
- the what-is-new card would have gone stale again at v10.30 (rewritten
  inside v10.29);
- the Spartan helmet and the ghost mask left a beard showing under the chin
  (both extended down over it);
- the jersey's one-pixel numeral and panels did not register at raid zoom
  under the dark tint (bolder, and the tests read brightness and saturation
  rather than absolute white and black);
- the chest patch sat on the gun-arm side and showed one row of itself
  (moved to the side away from the gun, drawn after the plate); three new
  patches had no mark and read as nothing (given marks);
- the neck ring tattoo lay under the torso's outline (lifted);
- the olive pack was 34 channel-units from the default canvas, below any
  eye's notice (recoloured);
- six checks whose staging assumed the counters as they were before the
  later gates existed (the next-piece control, earned-this-raid's second
  raid, the streak breaker, the capstone's locked count, the patch rack's
  ownership, the message line's baseline of 170 not 109).

Second pass, about 20:30, after his evening notes went in ahead of the
queue: the whole chain from v10.25 to v10.47 applied to scratch copies, the
end state parsed and its full corpus run on the second origin. Found and
fixed before shipping:

- the renumbering had rewritten two shipped-build comments inside the boots
  draft's anchors (the face slot's v10.21 and the mkRaider faceMark note), and
  the helmet build's card rewrite anchored on a card the belt rename had
  since changed;
- the paper doll check measured the hidden div doll (0x0) instead of the
  painter's canvas, and the canvas at 200 wide pushed the right tiles out of
  a 352-pixel column (the column is 420 now and the canvas shrinks to fit);
- the lifetime earnings check priced the kit ahead of landing: a frag in the
  kit goes to the tactical belt and the lift adds a bandage of its own, so
  the bag is read as landed on both sides;
- the welcome pack's decline said NO THANKS, and every window's way out is
  CLOSE (his answer 1, the v10.10 check); it says CLOSE;
- the floor-names check went silent once the cheat box sat behind its switch;
  it flips the switch for its own run now.

## HIS NOTES, 2026-09-03 about 17:20 (on the build he played, v10.20 or v10.21)

- "notes on fashion depot in last build -- eyes don't look like they do in
  the raid, and the ones in the raid look wayyy better -- hair doesn't render
  properly inside the fashion depot, its just all over the operators face"
- "in the undercroft, 'discount fashion depot' text needs to be lower so that
  it doesn't run into the Dev Cheat Box text"
- "Everyone in undercroft has blue eyes"
- "In stash, instead of hotbar, let's call it 'tactical belt', across the
  entire game"

Taken as, in this order, ahead of the queued cosmetics builds: the station
label moved clear of the cheat box; the Undercroft's eyes; the Depot figure
drawn by the raid's own sprite painter, so it looks exactly as she does in
the raid and every rack shows the same way in both places; and TACTICAL BELT
replacing hotbar everywhere a player can read it (vocabulary: one word per
thing).
- "this text is still wayy to small" (about 17:25), with a screenshot of THE
  STASH at v10.20 on his 4K monitor: tab labels, headings, hints and buttons
  at eleven to thirteen pixels on a 3840-wide screen. Taken as: the Undercroft
  scales with the monitor the way the HUD does, on top of his own zoom.
- "Add the tuning console as a window option inside settings -- consider how
  that interacts with the toggle buttions inside settings, e.g. should a
  change to the toggle result in a change to the tunting value" (about
  17:30). Taken as: a TUNING CONSOLE button in Settings; the console reads the
  live dials when it opens, so a toggle's change shows there; a console edit
  that lands on a toggle's value shows in the toggle.
- "in the mainframe - your stats -- the 'net carried out' explanation makes
  no sense-- should be 'everything you've extracted'  -- should be called
  'Net lifetime earnings' and it should be calculated as the sum of, for all
  games, everything extracted, minus everything carried in (including stuff
  carried in and then lost via KIA or abandoned, e.g not extracted)" (about
  17:35). Taken as: the stat card is NET LIFETIME EARNINGS, its explanation
  says exactly that, and its number is the sum over every logged run of
  value extracted minus value carried in, a run that died or was abandoned
  counting its carried-in value as lost.
- "when a new character is started, they should get a prompt that gives them
  a welcome pack with a few blue and green guns, heals, grenades etc to their
  stash so they can play around with some of the gear." (about 17:40)
- "Make it so the dev cheat box has to be enabled in settings in order to use
  the terminal/access it, so maybe players don't find it right away.  also
  make it where you have to successfully extract from atleast one game before
  you can turn on the setting that enables the dev cheat box." (about 17:40)

The order for his notes, ahead of the queued cosmetics builds: v10.22 the
menus resize only with CTRL and the wheel and never below the screen's
size; v10.23 the Depot's station label clear of the cheat box; v10.24 the
Undercroft crowd dresses from the racks, eyes included; v10.25 the Depot
figure drawn by the raid's own painter; v10.26 TACTICAL BELT; v10.27 NET
LIFETIME EARNINGS; v10.28 the tuning console inside Settings; v10.29 the
welcome pack; v10.30 the dev cheat box behind a switch that unlocks after
a first extraction. The queued cosmetics builds move to v10.31 onward.
- "acid needs more visual waves/melting effects, varied visual effects,
  should be inconsistent and random, chaotic," then "(blotter)" (about
  17:45). Taken as v10.31: the Blotter's screen effect gets waves and melting
  that vary from dose to dose and second to second, never the same twice.
  The queued cosmetics builds move to v10.32 onward.
The raid audit queue, the full-file audit's named items, and his fifty answers are
all shipped, decided, superseded, or not reproduced, with one design item left
that needs his word (an item is in the backpack or the hotbar, never both). A
six-region adversarial audit of the Undercroft (input, floor, screens, stash,
shop, ascent) was launched at v9.90 as workflow wf_8f1dab6c-586, two refuters per
top finding, reading the live file. Its confirmed findings become the queue.

## HIS NOTE, 2026-09-03, sent mid-tick right after switching the model
- "music needs more of a dark and low tone -- it sounds too friendly -- game is
  supposed to be post-apocalyptic". Taken as the next build. The harness cannot
  hear anything (see dark-raiders-fixture-silences-footsteps), so the proof has
  to be what the music SCHEDULES: pitch, mode, tempo, timbre, not what it sounds
  like. What it sounds like is his to judge.

## HIS NOTES, 2026-09-01 session, live queue
Shipped v8.79: NEW IN card too small; mouse zoom range; WINDFALL caption;
loot items popping all at once; DOWN/DOWN instead of DOWNED/ELIMINATED.

OPEN, in the order he sent them:
- CRAWLERS INDOORS. "need crawlers to spawn indoors more often" and "every house
  should be a gamble bc likely to be a crawler or 3 in there".
- GUN NAME AND RARITY DISAGREE. "i have a weapon of blue rarity but it says its a
  'gold burst carbine'". His screenshot shows two blue belt tiles and the prompt
  line reading Gold Burst Carbine. Suspect the quality word and the tier colour
  are two different scales sharing one noun.
- THE HUD IS TOO SMALL. "all this shit needs to be bigger on screen", with
  screenshots of the vitals block (STANDING / ARMOUR / STAMINA / HP) and the belt
  row with the prompt line above it.
- RESOLUTION. "game needs to be playable at 1080p, 1440p or 4k".
- CRAWLER DAMAGE. "crawler doing too much damage now" and "its like crawlers hit
  multiple times in too rapid a succession". Read that second line first: it is a
  hit CADENCE report, not a damage-per-hit report, so measure the interval
  between a crawler's landed hits before touching any damage number.
- HOTBAR BIGGER, and VISIBLE IN THE UNDERCROFT.
- I IN THE UNDERCROFT: NOT REPRODUCED at v9.83. I opens the BACKPACK, not the
  terminal, and closes it again on the same key. Driven with a real keypress.
- ROLL GRAPHIC IN THE UNDERCROFT: NOT REPRODUCED at v9.83. Measured on the floor:
  SPACE sets the roll, the operator draws as a DISC 46x51 with a fill ratio of
  0.78 against a perfect circle's 0.785, and he travels 43 units. Whatever was
  wrong when he reported it three times is fixed; v8.70 corrected the phase and
  v8.83 the pose. If he still sees a figure rather than a ball, it is a different
  gesture or a different screen and I need to see it.
- DOWN SCREEN WORDING, his exact replacements:
  "Crawl or bleed out" and
  "You are bleeding out.  Crawl to open extraction point if possible"
- EXTRACTED SCREEN: "Claim it at the Mainframe".
- ~~EXTRACTED/DEATH SCREEN: drop "Anything you drank or took is gone".~~ DONE at
  v8.87; grepped at v10.74 and the string exists nowhere but in the comment that
  records the removal.
- ~~XP CEILING: "what happens at 1.2m XP? death screen isn't clear".~~ ALREADY
  ANSWERED, measured at v10.74 by driving both cards at the cap. The line under
  the total reads "All 100 rewards earned. XP keeps counting, but there is
  nothing left that it pays for." on the death card AND on the extraction card.
  XP is held at 1,200,000 so it reads 1,200,000 of 1,200,000. My first probe
  said this was missing and my probe was wrong: it searched for a "Next:" line,
  which is exactly the line the ceiling replaces.
- ~~TITLE SCREEN WASTES THE SCREEN.~~ CLOSED AT v10.73. His shot on a wide
  monitor: the whole thing is a narrow column in the middle with empty space
  either side. Reproduced at 1920x1080: content x=427 to x=1493, so 1,066 of
  1,920 pixels, 56 percent, with 427 empty down each side. The column was capped
  at 820 and the only widening rule was gated on min-aspect-ratio 19/10, an
  ultrawide, so 16/9 missed it by a tenth. Cap follows the viewport now with an
  820 floor: 56 to 81 percent at 1080p, 78 to 81 at 1366x768.
- SOMETHING AT THE START OF COLD STORAGE IS BROKEN. His screenshot shows a long
  trench/wall run. Note he saw it every raid because of the v8.82 spawn bug, so
  re-ask him which part is broken now that the start point moves.
- ~~FOOTPRINTS THROUGH WALLS.~~ ALREADY DONE, read at v10.73 and not re-measured:
  both decal draws carry a sight gate, "if((dc.print||dc.ripple)&&!dc.mine&&
  !canSee(...)) continue" and the same on G.prints, with mine bypassing it so
  your own wake is never hidden from you. His words: "i can see pillager
  footprints when i can't see the pillager -- intentional? I wanted sound
  visualization for stuff we couldn't see". The sound ping still shows through,
  which is what he asked for.
- I AND ROLLING IN THE UNDERCROFT: BOTH CHECKED ON THE FLOOR AT v9.83 AND NEITHER
  REPRODUCES. I opens the backpack and closes it on the same key. SPACE rolls:
  the operator draws as a disc 46x51, fill ratio 0.78 against a circle's 0.785,
  and travels 43 units. He reported these three times and I fixed the roll twice,
  at v8.70 and v8.83; the second one took. Nothing more to change without seeing
  what he is seeing.

## OPEN AND RED, as of v8.88
- THE UNDERCROFT BELT DRAG. CLOSED AT v9.82. His note: "I don't understand why I
  can't move items from the tactical belt to the backpack in the undercroft".
  Reproduced with the gesture at last: the drag starts and lands on the backpack
  column and nothing happens, silently. One line, the backpack handler refusing
  anything not from the stash. It is the missing half of v8.72, which taught only
  the STASH to catch what came off the belt. The check that kept this green was
  named for the backpack and dragged to the stash; renamed at v9.82.
- STANDING LABEL COLLIDES WITH STAMINA. His screenshot, v8.89. The status chip is
  placed with raw pixel offsets (_up = 22 with no armour, 44 with) while its own
  box height is LH-scaled, so the two stop clearing each other as the text size
  grows. Measure both rects at several text sizes before touching it. NEXT.
- SUPERSEDED, do not act on this: THE THREE IN-RAID PANELS ARE TOO SMALL. His
  words at v8.88: "these menus are still WAY TOO SMALL -- need to be twice as
  large as they are now", naming the CURRENT PILLAGERS board, the controls legend
  and the CONDITIONS panel. AT v9.66 HE ASKED FOR THE OPPOSITE for two of the
  three: "current pillagers and conditions should be smaller in the hud compared
  to the other stuff", and they were measured as the two LARGEST on screen and
  cut to 1.15 and later 1.05. Enlarging them now would reverse his own later
  instruction. Only the legend is still short of the older target, at 1.5 against
  a nominal 2.0, and he has not repeated that ask since.
- 'EXTRACT CACHE' should be called 'ELITE CACHE'. His words, confusing name.
- CRIERS SHOULD NOT ENTER HOUSES unless chasing a pillager, and should leave the
  house once done. Note this interacts with v8.86, which moved most crawlers
  indoors; check what a crier does around an occupied building before changing it.
- DOWNED OVERLAY: the big flashing "CRAWL TO THE RING" is unnecessary, and the
  text around it is too small. Invert the emphasis.
- KIA SCREEN: drop the "Next: <reward>, reward N of 100, X XP away" line. He does
  not need the next reward while reading a death screen.
- PANEL SIZES (measured 1920x1080, none are in HUDZ): pillagers board 334x176,
  legend 311x131, conditions 257x203. He wants them TWICE this size. Anchors that
  work without collisions: raiders top-left (0,0), conditions top-right (W,0),
  legend bottom-left (0,H) so it grows up and clears the vitals block at y934.
  Wrap the CALL SITES (drawRaiderBoard, drawLegend, the cond IIFE) rather than
  the bodies, because all three have early returns that would skip a restore.
- TELEMETRY WATCH, runs 3/4/5 (v8.81, v8.81, v8.89): cont:0 on all three, haul
  equal to the kit he took up, firstLoot none. Run 5 ran 183s and opened nothing.
  CONFOUNDED: moved only 6801 units in 183s and he was sending menu screenshots
  throughout, so he was probably testing UI, not looting. Do NOT retune on this.
  If the next real play session also shows cont:0, that is the top item.

## HIS 50 ANSWERS, 2026-09-01. BINDING.
1 crawler damage feels good. 2 house occupancy about right; house = any indoor
structure. 3 never more than 3 per house. 4 he never sees sentries. 5 crawler
count = houses x 2.5, keep some outside. 6 he does not know what a siege is;
nothing should be meant to end the raid. 7 one revive only. 8 time-vs-value
question closed, balance feels good. 9 no. 10 no. 11 move items to and from the
hotbar while the backpack is open. 12 NO bag limit, no weight, unlimited. 13 yes
abandoning destroys the kit, obvious. 14 REMOVE wear and jam entirely. 15 belt
persists between raids. 16 emptied belt slot goes darker, still shows the item,
indicates none left. 17 Gilded is fine. 18 REMOVE the concept of gun CONDITION;
strength by rarity only. 19 any number of guns. 20 Peddler sells purple and
below, no gilded. 21 I in the Undercroft opens the backpack, same as in raid.
22 hotbar visible in the Undercroft. 23 YES you can roll in the Undercroft.
24 the Undercroft is both a place and a menu. 25 menus twice as large RELATIVE TO
THE SCREEN. 26 must look good and big at 1080p, 1440p and 4K. 27 panels remember
collapsed. 28 off centre is fine. 29 keep all panel content, do not modify.
30 same. 31 XP ceiling: leave for now. 32 death screen should show lost bag
value. 33 proficiency = money extracted, extract vs die rate, times downed,
accuracy, damage per raid, mixed. 34 Mainframe bonus already decided, stop
asking. 35 keep contracts on the extraction screen. 36 pillagers team up.
37 reviving a pillager pays a gun or a rare item. 38 board shows pillagers never
seen. 39 pillagers "just stood there after getting attacked". 40 criers must not
IDLE in houses. 41 machines never open containers. 42 the Warden is beatable.
43 two sectors, deeper. 44 COLD STORAGE needs about TEN starts. 45 THE BROKEN
WALL: go right from the start, a long container-looking structure, its TOP WALL
is glitched and can be walked through. 46 samey maps: not a worry now.
47 first quote is current, second is the replacement. 48 ONE THING VERIFIED
DEEPLY per build. 49 stop reporting sim extract rates, stop rebalancing.
50 what makes him quit: menu size or functionality glitches, inventory glitches
and limitations.
- ZOOM IN CLOSER: "need to be able to zoom in closer on player with mouse wheel
  during raids", "2-3 times as close as current version". ZMAX is 3.0 as of
  v8.79; he wants roughly 6 to 9. Check the renderer holds at that zoom before
  raising it, and that the sprite and fog still read.

## HE PLAYS AT 4K. Every layout number I quote at 1080p is multiplied by the
## screen factor on his actual screen. v8.91 shipped panels at 2.0, which is 3.8
## at 4K, and he says they are now too big.
- PANELS TOO BIG at 4K. Default should be about 75 percent of current, so the
  base drops from 2.0 to 1.5. HE ALSO WANTS A DRAG HANDLE: grab the corner of a
  panel and resize it, size changes accordingly, and it should persist.
- TWO BARS WHEN LOOTING, yellow and red. Should be ONE, yellow.
- TEXT COLLIDING WITH THE HOTBAR: "EXTRACT A INCOMING 16s" and the "Scav Pistol
  [FIRE] use [V] signal" line are drawn over the belt cells.
- TEXT COLLIDING WITH THE STAMINA BAR: STANDING chip sits on the STAMINA bar.
  Confirmed again at 4K with a screenshot.
- GREENBELT: his question "wtf is that? an old map?". It is a live DISTRICT
  palette name (one of several) and contracts reference it, but the name appears
  exactly once in the file, in the colour table. The game never labels a district
  anywhere he can see, so "Search 2 containers in GREENBELT" names a place he has
  no way to find. Either show district names in the world and on the map, or stop
  writing them into contracts.

## HIS 50 CONFIRMATIONS, 2026-09-01. What NOT to touch, and what he corrected.
CONFIRMED, DO NOT WORK ON: shooting is loud (4); rolling is for dodging (6);
grenades situational (7); stuck in place while looting (8, but see below); one
item at a time (9); loot fully or walk away (11); litter marks a looted
container (13); extraction is the loudest thing (14); 30s window (15); extract
while downed (16); ride someone else pull (17); death loses the bag (18);
pillagers are competitors (19); their haul is a reason to hunt (20); they extract
without you (21); silly handles (22); revive a pillager (23); Undercroft is a
place you walk (24); stations not one terminal (25); unlimited stash (26); ascent
screen (28); grid inventory (29); rarity colour on the tile (30); nine belt slots
(31); dragging is primary (32); right click menu (33); vitals bottom left (34);
belt bottom centre, off centre is fine (35); board top left (36); conditions top
right (37); two sectors (40); hand-authored maps (41); water (43); weather (44);
credits and XP separate (45); guns found not bought (46); no tutorial popup (49);
the death sequence is good (50).

HE CORRECTED ME, THESE ARE NEW WORK:
- 1. What kills him is PILLAGERS and MULTI-ENEMY ATTACKS AT EXTRACTS, not crawlers.
- 2. Three crawlers should NOT necessarily beat him.
- 3. Sentries should be FIGHTABLE, and he never sees them.
- 5. The chase-breaker is crouching IN A BUSH specifically.
- 8. HE SHOULD BE ABLE TO FIRE WHILE LOOTING.
- 10. NO WINDFALL. Remove the windfall system entirely.
- 12. Any container can spawn any item; only the probabilities change by type.
- 27. THE PEDDLER IS INSIDE THE RAIDS. I had him in the Undercroft.
- 38. Panels resizable by the corners (shipped v8.93) AND the cursor must become
  a CONTEXTUAL SYMBOL over a panel: drag, resize, minimise, normal pointer,
  instead of staying the aiming reticle.
- 39. He never sees the noise visualiser. He wants it real: a crawler on the far
  side of a wall should show LITTLE RED CIRCLES marking the noise.
- 41. Loot and enemy spawns must change every raid.
- 47. Contract is completed in the raid, the reward is claimed at the Mainframe.
- 48. WIRT should sell one special item for 10k that changes HOURLY.

## 2026-09-02, checked against the live code rather than my notes

Eighteen of HIS 50 ANSWERS were verified against dark_raiders.html directly. My
memory notes disagreed with this file on the numbering of 38, 39 and 41, so the
numbers below are this file's.

| His ask | Status | Where it stands |
| --- | --- | --- |
| 39 pillagers stood there after being attacked | SHIPPED v9.25 | One aimed round never set the hostile flag; the bullet path now does. Reproduced first with one shot then eighteen seconds of silence. |
| 45 the broken wall | FOUND, NOT YET FIXED | No wall is missing. Every structure is drawn about 26 units above its collider, so on the long container rows east of the COLD STORAGE start you walk a body width into the visible top and vanish behind it. The wall-clip tripwire tests for the centre being INSIDE the collider, which this bug never does, which is why it stayed silent for six builds. |
| 6 siege, and nothing ending the raid | NOT BUILT | The siege is real and scales with carried loot; the game never uses the word anywhere the player can read it. Timer expiry is endRaid('dead') with full loss and the slider has no off position. Both halves are design changes, not defects. |
| 2, 3, 5 house occupancy | PARTIAL | The three per house cap holds at defaults. Crawler count is a flat dial scaled by map size: about 0.7 per house on COLD STORAGE and 1.3 on THE COLD MILE, against the 2.5 he asked for. |
| 36 pillagers team up | PARTIAL | Crews decide who a pillager fights among his own kind and who he picks up. Nothing coordinates them against the player. Only machines team up. |
| 33 proficiency | PARTIAL | Exists but is money only, and is labelled "Net carried out". Accuracy, times downed, damage and extract-vs-die rate are recorded per run and none of them enters the formula. |
| 11 hotbar with the backpack open | DONE | Drag onto the belt works in both places. Dragging off the belt into the backpack works in the raid (v9.31) and the Undercroft (v9.82). The dragged item IS drawn in the Undercroft, measured at v9.87. |
| 22 hotbar visible in the Undercroft | DONE v9.88 | It was only drawn inside the opened backpack; the floor held nothing. The belt is drawn on the floor now, display only, and edited in the backpack. |
| 4 sentries | ALREADY BUILT | About 14 on COLD STORAGE and 66 on THE COLD MILE, nothing culls or hides them. The maps are large enough that meeting one is a coin flip. |
| 7 one revive | ALREADY BUILT | Self revive is one a raid. Reviving others is unlimited and, since v9.24, free. |
| 15 belt persists | ALREADY BUILT | Saved to the profile; only slots holding something you no longer own clear. |
| 19 any number of guns | ALREADY BUILT | Nothing counts or caps weapons. |
| 20 peddler purple and below | ALREADY BUILT | Tops out at elite; gilded no longer exists anywhere in the game. |
| 23 roll in the Undercroft | ALREADY BUILT | SPACE rolls and the ball is drawn. |
| 27 panels remember collapsed | ALREADY BUILT | Saved immediately, though only three panels have a collapse glyph. |
| 38 board shows pillagers never seen | ALREADY BUILT | The board lists every pillager on the map with no "have you met him" gate. |
| 41 machines never open containers | ALREADY BUILT | Every container-open path is the player's own search or an AI branch gated on the entity being a raider. |
| 42 Warden beatable | ALREADY BUILT | 900 health, no armour, no shield, no healing, slower than the player; the back seam does triple damage and freezes it for four seconds. |
| 43 two sectors, deeper | ALREADY BUILT | Exactly two. THE COLD MILE is 900 by 760 metres against COLD STORAGE at 420 by 340, nearly five times the area. |

## 2026-09-02, the overnight run he asked me to plan

He asked for a plan for a 10 to 12 hour absence and got one: pick a big thing,
work in committed slices, batch the corpus, stop mining a dead queue. He approved
batching the same day. What follows is what that plan produced.

| Item | Build | Evidence |
| --- | --- | --- |
| His instruction: reviving a pillager should be free | v9.24 | empty bag was refused with "No medical to revive him with"; now free, still 40 percent health, still friendly, still pays his gun. The v9.10 check that demanded the cost was turned around rather than deleted |
| His 39: pillagers stood there after being attacked | v9.25 | one aimed round from 400 units, trigger released, eighteen seconds watched: never turned, never fired back. The bullet set STATE and nothing ever set the hostile FLAG |
| His instruction: hostile after the first shot, including a miss | v9.26 | 11 rounds past him at 26 units, none landing, no reaction at all. missWake 40, measured from his edge. notoriety still charged, allies still excluded |
| His 45: the broken wall | v9.27 | no wall is missing. Every solid draws its top face 26 units above its collider, so you walk a body width into the visible container and are partly swallowed. Colliders untouched; the operator is drawn through whatever covers him |
| His 36: pillagers team up, slice 1 | v9.28 | crew of four, one spots you, one comes. The shout existed and called nobody. Now up to crewMax crewmates in earshot answer it |
| His 36, slice 2 | v9.29 | they arrived on bearings 13, 10 and -1, three degrees apart, in single file. Each called man now takes his own station: 146 degrees off the spotter against 52 |
| His 2, 3 and 5: crawler count and house occupancy | v9.30 | 1.25 and 1.50 per house against his 2.5. Now 2.60 and 2.61, the surplus outdoors, occupancy unchanged at 70 percent, never more than 3 in a house |
| Every build archived | tools | builds/ had stopped at v0.x, 92 of 846. archive-build.ps1 now runs every build; restore-build.ps1 pulls any version back out of git; 220 playable on disk |

Two of my own checks began SKIPPING when v9.30 changed the spawn counts, because
they stood the player due east and assumed open ground. A skip reads as green in
the summary, which makes it worse than a failure. Both now scan for a bearing with
an actual line of sight.

Still open from his 50, unchanged: 6 the siege and the lethal raid clock, 11
dragging an item off the belt during a raid, 33 proficiency using the five things
he named rather than money alone, 36 slice 3.

## 2026-09-02 evening, the second absence

He asked me to follow my own productivity report. What that produced:

| Item | Build | Evidence |
| --- | --- | --- |
| His 6: he does not know what a siege is | v9.34 | the line explaining it was written and overwritten in the same frame; an empty bag and a bag worth 37,500 were told the same two sentences. Now named and counted, and the count matches what arrives to the unit |
| His 6: nothing should be meant to end the raid | v9.35 | the clock slider bottomed out at two minutes with no off. Zero now reads OFF: no expiry, no rings closing, elapsed time still recorded. The clock still kills you at 15 seconds if you leave it on |
| A REGRESSION I SHIPPED AT v9.30 | v9.36 | HEAVY PATROLS raised sentries 44 percent and crawlers 4 percent, because my house-derived crawler floor overwrote the term. Now 42 and 39. He pays 30 percent hazard pay for that term |
| Abandoning while bleeding out kept both guns | v9.37 | the pause box offered Abandon run for the whole 17 second bleed-out, and the abandon branch never strips the armoury. Closed, with the handler refusing as well as the button hiding |
| Shooting a Listener switched it off | v9.38 | 9 hits and 306 damage left alone, 0 and 0 after a round put it into a state its own block has no branch for. Fixed in the Listener, so the frag path is covered too |
| The harness was lying in two separate ways | tooling | the device pixel ratio made eight checks read a quarter of the canvas and report "nothing was drawn"; my own v9.36 check leaked HEAVY PATROLS into the SAVED profile and denied two shooting checks a firing line. Ratio pinned, profile cleaned before every check |

MINING IS DONE BY WORKFLOW NOW, not by hand. Eight agents read one subsystem each
against the live file, then skeptics tried to refute every high-impact finding.
That produced the v9.37 and v9.38 builds and a vetted queue, and it caught my own
v9.30 regression, which two full corpus runs had missed because nothing in the
corpus had ever signed a term.

THE WHOLE VETTED QUEUE IS NOW SHIPPED. What it produced:

| Item | Build | Evidence |
| --- | --- | --- |
| the last-minutes warnings sent you to a ring that was already shut | v9.39 | nearestOut walked every ring and never read the open flag. It now skips shut ones, and with all of them shut it says so instead of naming one |
| the Peddler promised your stall money survives your death | v9.40 | a 5,000 credit stall balance and a death: 0 credits banked, while the panel said "Yours even if you die out there" and the death screen said "Stall money lost where you fell" |
| the new-player card said raids pay no XP | v9.41 | one raid, nothing sold: 134 XP extracted, 67 died, exactly half. The card said "Nothing else pays XP" and claimed XP gates the shop, whose highest gate is 2 |
| breaking line of sight did not shake a chase at range | v9.42 | a pillager hidden 567 units off and 95 degrees from the last sighting walked 218 units at cosine 0.996 STRAIGHT AT him with no frame of sight; the same pillager at 189 units did it right. v8.62 called this refuted and its stated reason is not true of the file |
| the workshop billed for servicing guns that cannot wear | v9.43 | a pistol at 1,600 rounds is identical to a clean one and the bill was 1,944 credits and two Servo Actuators. The Tacker: 900 to replace, 540 to service. Three more defects fell out of the same block |
| Wirt's 10,000 counter was a guaranteed loss | v9.44 | eight of eight items lost between 5,400 and 8,300. Six were pure salvage, which cannot be sold to a player at any price. Seven lots now, every one worth 10,620 to 12,420 across the counter |
| HIS INSTRUCTION: rigs out of the game | v9.45 | unwearable since v5.83 and still 2.16 percent of every loot key, one thing in 46. He had asked more than once and three earlier passes each removed one layer and left the items |
| at 4K the controls legend could not be clicked at all | v9.46 | it painted at y 1898-2216 and the game recorded it at 1356-1749, so clicking the legend hit the health panel and clicking empty air 400 pixels above it grabbed the legend. Its last line sat 58 pixels off the bottom, permanently. The shift was applied outside the zoom when drawing and inside it when recording |

COULD NOT REPRODUCE, said plainly: the "CONCEALED chip sits over the gear stack"
report. Measured at 1920x1080, 2560x1440 and 3840x2160, crouched and concealed,
with every HUD box compared pairwise: no panel overlaps any other at any of the
three. The concealment readout is drawn INSIDE the gear panel, at its top, which
is where it is meant to be. After v9.46 the only remaining 4K anomaly is that the
gear panel's box padding overhangs the bottom edge by 11 pixels; no text is drawn
below the screen anywhere, and the resize grip is still grabbable at the last
on-screen pixel, so it costs nothing.

AND TWO MORE, from the list he said was still unfulfilled:

| Item | Build | Evidence |
| --- | --- | --- |
| HIS 36 slice 3: a crew that loses you searches as a crew | v9.47 | v9.42 made losing sight matter and immediately exposed this: three pillagers in chase, none able to see him, all three targeting 400,660 TO THE UNIT and finishing 22 units apart. Each man now sweeps his own sector, spread by the golden angle |
| "maps feel samey": one cause with a number on it | v9.48 | all 104 buildings on both maps wore the identical floor, and 54 percent of the ones on THE COLD MILE are the same 320x240 box. Five floors now, fixed per building so the map is still learnable. Districts were checked first and are innocent: largest share 37.5 percent |

AND THE SECOND HALF OF THE STRETCH:

| Item | Build | Evidence |
| --- | --- | --- |
| at 4K the controls legend could not be clicked at all | v9.46 | it painted at y 1898-2216 and the game recorded it at 1356-1749, so clicking the legend hit the health panel and clicking empty air 400 pixels above it grabbed the legend. Its last line sat 58 pixels off the bottom, permanently. The shift was applied outside the zoom when drawing and inside it when recording |
| HIS 36 slice 3: a crew that loses you searches as a crew | v9.47 | three pillagers in chase, none able to see him, all three targeting 400,660 TO THE UNIT and finishing 22 units apart. Each man now sweeps his own sector, spread by the golden angle |
| "maps feel samey": one cause with a number on it | v9.48 | all 104 buildings on both maps wore the identical floor, and 54 percent of the ones on THE COLD MILE are the same 320x240 box. Five floors now, fixed per building so the map is still learnable. Districts were checked first and are innocent: largest share 37.5 percent |
| the pillager board covered the health bar and every key binding | v9.49 | on THE COLD MILE it was 927 pixels tall on a 1080 screen, overlapping the vitals by 496x193 and the legend by 467x196, and hanging 42 pixels off the bottom. Found by screenshotting a raid, not by reading code |
| HIS INSTRUCTION: say what the game wants to run in | v9.50 | a note under the version line, and the title screen tightened so it still fits at 720p, where it had been overflowing by 8 pixels since v9.18 and by 28 once the note went on |
| machines converged on the last sighting the way pillagers used to | v9.51 | four sentries in chase, none able to see him, all four steering at 400,660 TO THE UNIT and every one of them holding the role pin. The sector picker is one function at file scope now instead of a copy in each branch |
| the crew fan opened at v9.47 did not guarantee a fan | v9.52 | 4 of 12 stands on THE COLD MILE sent two men to points 100 units apart or less, worst pair 14 units, because the arc summed a golden angle with a term three times larger than the gap it opens. Five claimable sectors now. The v9.47 check had been passing it on a single lucky stand |
| the interface stopped growing at 1080p | v9.53 | the menus never got the screen factor the title screen got, so at 4K they were 1.9x smaller than the title in front of them; the title screen ran 192px off the bottom; and the reticle was drawn from literal numbers scaled by nothing, seven pixels of line on a 3840 screen. My first cut raised uiScale instead and the v9.13 backpack check caught it: 11 columns at 1080p, 7 at 4K, because the HUD already multiplies by hudRes |
| the crawler was blind in front and sighted behind | v9.54 | canSee takes a cone range and a peripheral range, and the call site passed e.rng as the cone range. That is 340 for a sentry and 26 for a crawler, which is its BITE REACH. Held still and pointed straight at him it noticed him at none of 40, 80, 120, 160, 200, 260, 340 or 440 units. v8.48 found the same value doing the same damage to machine-vs-pillager targeting and fixed only that half |
| your bare hands were drawn as a pistol | v9.55 | fists are in WEAPONS and drawItemIcon sends anything in WEAPONS to gunIcon, so the second weapon slot showed a gun whenever you carried none. drawItemIcon('fists') was pixel identical to gunIcon('fists'). My first reading blamed the vacant slot and the check I wrote for it PASSED on the broken build, which is what sent me back to his screenshot |
| the clock sat on top of the extract distance at every size | v9.56 | the top centre block was drawn at the literal baselines 30, 46, 60 and 82. 30 to 46 is sixteen pixels for a font that renders at thirty one, so the clock overlapped the line below it by 6px at 1080p, 1440p and 4K alike, and the font never grew: 31px on a 4K screen and on a laptop |
| HIS TELEMETRY: a Listener killed him 2 metres from the extraction | v9.57 | 8 runs 0 extracted in his own recorder, the last two both killed by a Listener, run 8 carrying 5455c after seven minutes and closestExt 2m. Measured: a Listener kills a man on full health in 1.7s against 4.9 for a crawler, hits for 34 against 13, moves at 196 against a 158 walk, and its blow landed on the FIRST FRAME it was in reach. It winds up 0.45s now and misses if you leave |
| the title screen recommended fullscreen and had no way to get there | v9.58 | v9.50 added the line on his order; the file contained no requestFullscreen call at all for the eight builds since. A GO FULLSCREEN button sits beside the line, its label driven off fullscreenchange rather than off the click, and the v9.53 title fit still measures zero overflow |
| HIS WORDING: call FOR extraction | v9.59 | ten player-facing places used the shorter verb phrase, including the ring prompt, the compass line, the centre callout, both controls lists, the title card, the primer and a Settings row. This overrode his own vocabulary note, so the note was updated rather than his instruction |
| HIS INSTRUCTION and his own tag: a Listener could not be walked away from | v9.60 | 196 against a 158 walk, so it closed at 38 units a second. Measured on v9.59: walking flat out in the open for three seconds with a head start he LOST 103 units. Now 142, under his walk and under a crawler. His recorder: 10 runs 0 extracted, Listener killed him on 7, 8 and 10, and he tagged run 10 Listener unfair |
| HIS REPORT: the downed screen was ugly, repeated DOWN and collided | v9.61 | two centre blocks that did not know about each other, in two coordinate systems: DOWN at 94px and YOU ARE DOWN at 47px on the same 4K panel, with the bleed timer inside the self-revive line by 8px at 1080p and 17 at 4K. One panel now, stacked from its own type. The v9.08 check was encoding the old bar position and had to be taught to FIND the bar |
| HIS RULE: a bandage stops at 85, only a medkit reaches 100 | v9.62 | five places needed it because health arrives over seconds: the item, the instant path, the over-time path, the drain and the item picker. The picker took the CHEAPEST heal, so at 90 health it reached for a bandage, found it useless and reported no medical supplies while a medkit sat in the bag |
| HIS REQUEST: a red circle where a pillager you cannot see is shooting from | v9.63 | the ring already existed and was invisible: radius 8 at 22 percent opacity, and half of that 22 was the occlusion multiplier dimming the cue BECAUSE a wall was hiding the shooter. Measured at three hidden spots: 0, 0 and 0 red pixels before, 352, 365 and 359 after. Three faults in my own probe first, the worst being w2s returning world coordinates because no frame had been drawn |
| HIS INSTRUCTION: rank the pillager board by haul, live | v9.64 | it was in spawn order, and with the v9.49 ceiling that meant the board showed the men carrying the LEAST and hid the richest behind the more-out-here line. Measured: YOU then 210, 420, 420, 840 before; YOU then 5370, 3240, 2870, 2760 after. Also caught by v9.19 in the same build: the what-is-new card had been stale since v9.50, fifteen builds |
| HIS REPORT: too many old cars, more unique outdoor cover on the mile | v9.65 | counted 487 wrecks on the mile and every one of them the same car object. Five kinds now, weighted per map: 136 skips, 129 barriers, 122 pallets, 55 cars, 45 pipe bundles. The footprint and the random stream are untouched, so ents 85/369 and containers 157/589 are unchanged; the kind comes from a position hash. My first hash put 485 of 487 in one slot because a plain 32-bit multiply loses its low bits in JS |
| HIS NOTE: pillagers and conditions should be smaller than the rest of the HUD | v9.66 | they were the LARGEST of the five panels, raiders 196,392 square pixels and cond 107,694 against 102,676 for the vitals, because HUDZ had both at 1.5. Now 1.15, and the board ceiling 56 to 38 percent because the ceiling is DIVIDED by the scale and would have grown to match. This reverses his own answer 25 at v8.91, so v8.91 and v8.93 were updated rather than the instruction |
| HIS NOTE: the wheel should resize text in the Undercroft, and it should be slightly smaller | v9.67 | it already worked on the floor, 1.30 to 1.38, and did nothing at all at five of five station panels, because a v6.64 rule hands the wheel to anything scrollable and every station panel is built around a scrolling list. Shift scrolls now. The panel is 0.92 of every other menu, exactly one notch of the wheel |
| HIS NOTE: the extraction call should be 3x longer, epic, undulating | v9.68 | it was one square oscillator, 310 milliseconds, for the loudest decision in the raid. Now 0.96s, three voices with an octave underneath, and a 5.5 Hz vibrato on the tone. The fixture had never been able to check a sound at all: it blocks AudioContext and stubs blip, so a recording stand-in was added, and my own memory note about that stub is what unstuck it |
| HIS NOTE: the low health flash should slow 2x out of combat | v9.69 | it ran on one rate forever, a cycle every 1.05 seconds, as urgent alone in a corridor as with three machines on him. THE GAME HAD NO IDEA WHAT COMBAT WAS: v8.52 records the last two combat stamps were deleted at v5.50 and nothing has read either since. Now hunted within 900, fired within 4s, or hit within 5s. Measured off drawn pixels: one cycle calm against two hunted over 2.08 seconds |
| HIS NOTE: hold space to surrender when downed and the self-revive is already spent | v9.71 | measured on v9.70 first: SPACE held 2.5 seconds with the revive gone did nothing, and there was no field for it. The only exits were the 17 second bleed and a 30 units per second crawl, which from across a map is a wait with an answer he already knows. Now a 1.5 second hold, gated on the revive being spent so it cannot end a raid while he still holds one, and blocked while he lies inside a landed extraction. My first reproduction set a property on __keys, which is a FUNCTION, and measured nothing |
| STANDING FINDING: the game demolishes a fifth of its own buildings at load | v9.72 | HALF FIXED. Measured at seed 4242: 16 of 84 on THE COLD MILE and 2 of 20 on COLD STORAGE lost their authored interior because one cell somewhere could not be reached. The furniture layer has removed only what TOUCHES the pocket since v1.94; the partition layer never learned that and was still all-or-nothing. Now peeled up to four times: mile 16 to 12 and 171 to 180 interior walls, cold storage 2 to 1. Entity counts identical in both arms, so the world did not move |
| NEW, FOUND WHILE PROVING v9.72: the repair does not repair, and never checks | OPEN | flooding the FINAL walls of THE COLD MILE still finds 8 buildings holding interior floor nothing can reach, all 8 flagged repaired, two of them large (110 and 144 unreachable cells). Their interiors were destroyed for nothing. Every wall within 24 units of the four worst is an UNTAGGED SHELL wall, so their one or two 64 unit doors are bricked up by neighbouring geometry they do not own. The pass never re-floods after the blanket strip, so it cannot see this. Fix needs shell segments tagged with their building id before a door can be punched safely |
| REGRESSION MY OWN v9.72 CAUSED, and the hole it exposed | v9.72 | the v9.30 check caught a house holding 7 crawlers against his cap of 3. Nobody was created, 219 crawlers and 369 entities either way: changing which walls survive shifts where the placement rolls land. I gave three wrong explanations before measuring, each a plausible code path rather than the one the men came from. What ended it was counting exits: 39 of the 40 ways out of that building are open ground, so the mover was fine and the fault was timing. ENCAMPMENTS MAKE CRAWLERS AFTER THE CRAWLER LOOP, at the camp centre plus 120 units of jitter, and that line has never looked at a building. The cap is now checked once with everybody on the map: worst house 3 with the pass on, 7 with it off |
| FOR HIS RULING, the one cost of v9.72 | OPEN | THE COLD MILE now places 564 containers where it placed 589, a drop of 25 or about 4 percent, because containers go in free interior floor and there are 9 more interior walls. Entities unchanged at 85 and 369. Not a bug, the direct consequence of the fix, and a balance change I did not set out to make. partRepair 0 puts both back. The seed 4242 container fingerprint is now 157 and 564 |
| CORRECTION, mine: the v9.72 note that "something bricks up doorways with a wall the width of the gap" | v9.73 | WRONG. That segment was a WINDOW and its 68 units came from rnd(52,84) in carveWindows, not from DOOR. Windows are carved into a wall and never fill a gap. Building 6 was wrong too and the fault was my ruler: I counted unreachable cells over the whole footprint including the wall band. Flooded properly from the player start at cell 8, building 6 is entirely reachable, 617 cells, none unreachable |
| A LOCKED ROOM IS NOT A FAULT, and the game was demolishing buildings for having one | v9.73 | buildings 2 and 11 on THE COLD MILE hold one unreachable pocket each, 484 and 625 cells, walled by lockWall segments matching map.locked exactly: THE BOND ROOM and THE DEEP FREEZE. Authored, named, opened with a key, shut on purpose. carveWindows already refuses to window a locked-room shell; the repair pass did not know, so it read a strongroom as a fault, deleted every partition the building owned, and left the strongroom locked anyway. Mile 12 demolished to 10, interior walls 180 to 188 |
| FINGERPRINT RE-BASELINED, third time and deliberate | v9.73 | the landing spot on THE COLD MILE moved from 8798,5698 to 350,3400, the far corner, because it is chosen against the wall list and this build keeps 8 more walls. 84 buildings then qualify as houses where 82 did, crawlers are houses times 2.5, so 219 to 224 and ents 369 to 374. NOW: ents 85/374, containers 157/576. Every seeded number ever quoted for the mile was measured from a different corner and is no longer comparable. lockedOk 0 puts all of it back |
| HIS RULE, conditions panel smaller than the rest of the HUD, broken by the re-baseline | v9.73 | on the moved map it measured 103,664 square pixels against 102,782 for the vitals, over by under one percent. Invisible on screen and still a broken rule, and it moved because the panel is sized by its CONTENT, so the rule only held while the contract list was short. Zoom 1.15 to 1.05 puts it about 16 percent under, which content variation cannot undo |
| THE CREW FAN: two real faults found, and one I caused fixing the first | v9.73 | the re-baselined map re-sampled v9.52 onto new stands and it went red at 60 units. I guessed the cause three times and the number came back as exactly 60 every time. Exposing searchSector to the harness so the picker could be driven directly ended it. ONE: the claim set was keyed to whichever man reset it last, and each man carries his own last-seen point, so a crew wiped and re-anchored it man by man and handed slot 0 out three times. TWO: the fan was drawn around each man's own sighting rather than the shared one, so distinct slots still landed 42 units apart. THREE, mine: fixing one removed the accidental slot recycling the drifting anchor had been doing, so four men draining five slots fell onto the golden-angle overflow. A slot now belongs to a man for the episode. Closest pair 134 at spreads of 0, 40 and 150 |
| HIS ASK: "can you make all text fields in the game editable so i can just edit them in game???" | v9.74 | DONE, and it is the last big thing on his list. An override is keyed BY THE STRING, not by where it is drawn, so it needs no ids, survives every panel rebuild, and correcting a phrase in a menu also corrects it where the HUD paints it. Two doors: ctx.fillText wrapped once on the prototype covers all 172 call sites, and a MutationObserver on #root covers the menus. Settings row "Edit the words", off by default. Click any phrase, type over it, Enter commits, clear the box and Enter restores the original. Saved in a new profile field, no migration, storage key untouched |
| MY OWN CHECK WALKED PAST THE ONLY BUG THAT MATTERED | v9.74 | it drove the engine instead of the gesture, and passed on a build where every HUD string was unreachable by an actual click. elementFromPoint over the HUD returns the transparent panel stacked above the canvas, not the canvas, and I treated "a panel with no text in it" as "nothing here". The check now goes through txClick and was proved against a build carrying the engine WITH the bug put back: it reports "a click on 8:59 was answered with nothing at all" |
| THE HOLE IN v9.74, found by using it | v9.75 | 42 of the 91 strings the HUD paints in one frame carry a number, and v9.74 remembered an edit by the exact words. Driven end to end: he edits "EXTRACT 141m", takes five steps, and the line reads "EXTRACT 146m" again. His wording was filed under a phrase that would never be drawn again, which is worse than not having the feature because it works just long enough to look like it works. An edit is now remembered by the SHAPE of the line, every run of digits a blank, and the numbers he keeps are carried through while digits he typed himself stay literal. "Kill 2 criers, top 3 pay  0/2" later reads "Kill 5 criers, top 3 pay  3/5" |
| THE SHAPE MATCH WAS TOO LOOSE FOR ONE SHAPE, and it was the worst one | v9.76 | measured across 92 drawn lines: 43 carry a number, reducing to 30 shapes, and only 4 shapes are shared. Three are the same line at a different value, which is the point of v9.75. The fourth is A BARE NUMBER, whose shape is one blank and matches every number in the game. Driven on v9.75: renaming one hotbar slot from "3" to "THIRD" turned ALL SEVENTEEN bare numbers on screen into THIRD. A shape is now only kept if it has a letter, or two blanks with something other than a space between them, which keeps all 27 lettered shapes plus the clock and the ammo counter. A refused shape is not a refused edit: the exact override still applies. Profiles are pruned when armed, because v9.75 shipped |
| THE PASS CONDEMNS BUILDINGS ON A GRID TOO COARSE TO SEE THEIR DOORS | v9.77 | the nav cell is 16 and a doorway is 64, so whether a door exists depends on where it falls. Flooding the finished COLD MILE at 16, 8 and 4 gives three different answers: sealed [2,6,11,14,15,20,21,53] then [2,11,14,15,20,21,31] then [2,11,14,15,20,21]. Buildings 6 and 53 are not sealed at any honest resolution. THIS PROJECT WAS FOOLED BY THE SAME THING TWICE BEFORE and both times I re-ran MY OWN measurement finer and moved on; the game never got the correction. Now a building the coarse pass wants to condemn is re-tested on a local grid of 4 over the building plus 96 units of street, flooded from the edge. Mile 10 demolished to 7, interior walls 188 to 192, entity counts unchanged |
| MY OWN CONTROL WAS FOOLED BY THE BUG IT WAS TESTING | v9.77 | the safety control flooded at cell 8 and reported buildings 6 and 71 as holding dead floor. At cell 4 a player walks straight into both. It asks at 4 now and the two arms come back identical |
| A THIRD CHECK RE-SAMPLED ONTO WORSE GROUND BY A WALL CHANGE | v9.77 | v9.47 went to SKIP with "1 of them can still see the hidden spot". It picks the FIRST stand on the map that fits and hides a spot from the four posts the men START on, but they move during the chase. Third time this month a map-derived arena has been re-sampled by a build that moves walls, so it now collects up to six arenas and takes the first that survives the whole way through. Nothing it asserts changed |
| A FOURTH CHECK, AND THIS ONE HAD BEEN PASSING ON LUCK | v9.77 | v9.42 skipped with "raider never entered chase from a clear sighting" across six stands. Driven: A RAIDER'S SIGHT IS 302 AT SPAWN AND 187 WHILE PATROLLING, and that check stood the player 250 to 320 out for the first sighting. Whether it worked came down to which raider was first in the list and how the arena fell. Sighting moved to 150 to 210, and it now prefers a man whose sight covers the distance. The hidden spot stays at 500 to 700, which is the band the defect lived in |
| FINGERPRINT: outdoor cover on the mile, 487 to 484 | v9.77 | deliberate and understood. Cover is placed by asking spotFree against the wall list, and this build keeps three more buildings' interior walls, so three candidate spots are refused. ENTITIES ARE STILL 374, which is the half of the fingerprint that says the seeded stream did not move, and building footprints are identical |
| CLOSED v10.40, measured on v10.39 before any change: 14, 15, 20 and 21 are enterable at 4242; what other seeds flag is slivers and one furniture niche, see the v10.40 row. Was: the demolition achieves nothing for four buildings | CLOSED v10.40 | 14, 15, 20 and 21 on THE COLD MILE hold unreachable floor at every resolution including 4, so they are not the grid bug, and they are STILL sealed after their interiors are destroyed. The v9.72 finding that the repair does not repair, with four names on it |
| CLOSED AT v9.79: THE COMPOUND WALLS WERE DRAWN THROUGH THE BUILDINGS | v9.79 | building 14 is 300x220 at 3380,2450 and two landmark walls cross its inside, 3013,2502 550x18 and 3478,2520 18x134, leaving a sealed pocket of 72x124 in a house whose shell has a good door. Building 21 loses 204x124. THE REPAIR PASS COULD NEVER HELP: it only removes walls carrying a building id and a landmark wall carries none, so it guts the house and the room stays shut. Landmark walls are now cut against the INSIDE of any building they cross. MILE 7 demolished to 0 and sealed 14,15,20,21 to NONE; COLD STORAGE 1 to 0 and 17 to NONE; entity counts unchanged; yard walls cut not deleted, 62 pieces to 64. CLOSES THE DEMOLITION THREAD across v9.72, v9.73, v9.77 and v9.79 |
| A DOWNED PILLAGER TAKES MORE THAN ONE SCAV PISTOL ROUND | v9.91 | his note, the first of the day: "when a pillager is downed, it should take more than 1 scav pistol shot to eliminate them". REPRODUCED from the code and then driven: on going down the game wrote e.hp=1 on purpose ("a second hit while he is down kills outright") so one Scav Pistol round at 19 finished a downed man exactly as a Longshot would. He has 40 now, three pistol rounds and two of anything heavier, as a dial raiderDownHp; the bleed clock is unchanged so it is a cost to finishing him, not a second life. Check downs a man through the game's own path, fires the pistol's 19 through the real bullet loop, requires him still down after one and more than one to finish, and proves the dial with a one-round finish at 1 and a two-round finish at 60 damage. Fails on a v9.90 fixture: "one Scav Pistol round finished a downed pillager, he went down with 1 health" |
| C CROUCHES | v9.92 | his note: "crouch should be default bound key to each of ctrl and c". REPRODUCED from the code: crouch read exactly ControlLeft or ControlRight in three places, and C toggled autoloot, inert since the bag became unlimited on 2026-08-22. One reader, crouchHeld(), for all three; C on the preventDefault list; the autoloot toggle removed and its dead hint corrected; pause box and both legends say CTRL / C. Check walks him 24 real-loop frames with nothing, with C, with CTRL, and requires C to halve him as CTRL does, within eight points of each other; presses C through the real handler and requires autoloot not to move; reads the crouch row from both legend tables. Fails on a v9.91 fixture: "with C held he still walked at 100% of full speed" |
| RMB AIMS DOWN SIGHTS | v9.93 | his note: "on pause screen text --- RMB = 'aim down sights'". The pause screen said RMB steady aim; the full legend steady aim; the compact one aim. Pause screen and full legend now say aim down sights. The compact legend says sights, MEASURED: its value column is 58 units at 1080p in 600 10px Rubik, and "aim down sights" is 79.4 wide, "sights" 30.6. Check reads the pause box and both legend tables, then draws the compact legend and requires every row to end inside the HUD's own panel box. Also: __regressBg(), the chunked corpus runner, moved from an injected script into the fixture. Fails on a v9.92 fixture |
| WIRT HAS TWO COUNTERS | v9.94 | his five Wirt notes: per roll, delete the carry sentence, three lines only on the offer, a clear delineation, five minutes. Read off v9.93: one column, the card printed a name, a with-list, a worth, "for the hour" and minutes, and changed hourly. Now THE GAMBLE (steel border: price per roll, log, Gamble button) and LIMITED TIME OFFER (amber border, faint amber ground: icon, Limited Time Offer, Worth $X, New item in N minutes, Buy) with Leave below; WIRT_LOT_MS 300000. Check counts the card's three lines in his words, requires the old strings gone, measures two bordered boxes with different border colours and at least 8 px between them, and drives the clock by hand across five-minute windows. Fails on a v9.93 fixture |
| THE WHEEL: ZOOM, CTRL-WHEEL HUD SIZE, MENUS SCROLL | v9.95 | his two wheel notes. Read off v9.94: the canvas wheel zoomed with any modifier; the document listener's scroll rule was off in the whole Undercroft since v9.67, so station lists (the HIRE grid in his screenshot) resized instead of scrolling. Now hudSizeStep(dir) is the one step Minus and Equal take, ctrl-wheel on the canvas calls it and does not zoom; the document listener lets any scrollable box under the pointer scroll, floor or not. Check dispatches real wheel events: ctrl-wheel steps the HUD one index and leaves zoom alone, plain wheel zooms and leaves the HUD alone; Wirt's list overflowed, wheel over it leaves menuZoom unchanged and the event unswallowed; wheel on the floor still sizes. Fails on a v9.94 fixture |
| A DOSE FROM THE BAR PAYS | v9.96 | his note: "using Liquor or Blotter should give a small XP boost per stack while the effect is occurring". Read off v9.95: XP written at three sites (run progress, sell one, sell all), none reading the buzz. Now addXp is the one writer, multiplied by 1 + 0.05 per live dose, both kinds together, ten at most (dial buzzXp); shown on the bar's IN YOUR BLOOD tag, the raid conditions row, and the sell-all line. Check runs one record sober, at two, ten and twelve doses (110, 150, capped), dial at zero as control, sells a scrap at two doses for 10 percent more, and reads XP +10% off the bar. Fails on a v9.95 fixture |
| DAY OR NIGHT IS CHOSEN ON THE WAY UP | v9.97 | his note: "day vs. night selection should move to map selection screen that occurs upon ascension". Read off v9.96: one SURFACE: DAY button in the stash screen's bottom row toggled P.cond; the sector page opened only with more than one map offered, so a choice placed there would be unreachable with one map. Now the sector page has SURFACE, DAY and NIGHT under the map list, chosen one drawn amber with a line saying which you go up in, and the lift always opens the page. The stash button stays one more build and follows. Check takes the lift on a clean profile, requires the sector page (not the loadout question), clicks NIGHT and DAY reading P.cond and isDay(), requires the buttons to differ once chosen, the old button to follow, and ASCEND to still reach the loadout question. Fails on a v9.96 fixture: "the sector page has no DAY and NIGHT buttons" |
| THE STASH SCREEN IS FIVE THINGS | v9.98 | his note with the white-marked screenshot: scrap it, five parts only. Removed from the stash screen: the YOUR OPERATOR column (figure, six cosmetic slots, loadout saves), the armour line, and the whole bottom row (RETURN, SHOP, CRAFT, CONTRACTS, SURFACE, LAYOUT, SETTINGS). Kept, as the stash inventory's own: tabs, drag hint, detail, sell bar. One CLOSE top right; TAB and ESC still close. The ascent check keeps its operator panel until Appearance exists. Check opens the stash from the terminal, requires every struck element absent, the five parts drawn with nine hotbar cells, CLOSE to work, and the ascent check's operator panel still there as control. Fails on a v9.97 fixture |
| DISCOUNT FASHION DEPOT | v9.99 | his note: "Cosmetics should move to their own screen and their place in the Undercroft", and his answers 11 and 12: the word is DISCOUNT FASHION DEPOT, a new station. Read off v9.98: cosmetics lived in the operator column (gone from the stash at v9.98, still on the ascent check), and the picker showed loadout saves until a slot was clicked. Now a station on the floor, bottom left, opens its own screen: figure and six slots left, the whole of the racks right with all six groups showing before any click; no loadout saves there; CLOSE below. Check fires the station's act, requires the screen, six slots, tiles and all six headings before a click, no save rows, a clicked owned tile to change the profile, and CLOSE to close. Fails on a v9.98 fixture: no station |
| NINE MORE THINGS TO WEAR | v10.00 | his note: "Build out the cosmetics system even more". Read off v9.99: six headgear, five hair colours with two more (ash, violet) in the colour table and never in the wardrobe, eight clothing colours. Added: Watch Cap, Field Cap, Bandana, Hood (all earned), Ash and Violet hair (earned), Olive Drab, Charcoal and Bone clothing (owned), each drawn on the sprite, the figure and the swatch; Moss hair no longer costs credits (his answers 15 and 16). Check reads the sprite's head pixels against Bare for every headgear and requires each to draw, requires every wardrobe colour to exist and every table colour to be wearable, every headgear to have a swatch, and the counts as controls. Fails on a v9.99 fixture: "colours nobody can wear: hair ash, hair violet; only 5 headgear besides Bare" |
| THE HUD MEASURED, THE GEAR PANEL INSIDE THE SCREEN | v10.01 | his note "menus and hud in the raid are still wonky" and answers 25, 26, 30. MEASURED on v9.98 at 1080p, 1440p and 4K: no panel overlaps another; one panel, gear (bottom right), ends 6, 8 and 11 px below the screen; 23 to 25 text strings (clock, extract line, message line, hotbar strip) have no panel box. Cause: the gear box was declared 38 below a baseline that is 34 above the edge. Now 30. Check reads every box at three sizes, requires inside and non-overlapping, and the gear text inside its box as control. Fails on a v10.00 fixture: "gear leaves the screen at 1920x1080: bottom 1086 of 1080" |
| THE BAR PAYS 2.5 PERCENT, RAIDS ONLY | v10.02 | his answers 41 and 42. v9.96 paid five percent a dose on the run and on both stash sales. Now 2.5 percent a dose on the run only; the two sales pay their plain price; the bar line, the IN YOUR BLOOD tag and the sell line say so. The v9.96 check regraded: two doses 5 percent, ten 25, twelve capped, dial at zero sober, a sale pays its plain price, the tag reads XP +5%. Fails on a v10.01 fixture: "two doses paid 239, not the 228 that two and a half percent a dose gives" |
| WIRT NAMES WHAT IS ON THE COUNTER | v10.03 | his answer 38: the offer prints the item's name, "YES OF COURSE". v9.94 had hidden the names on the icon's hover title. The card is four lines now: Limited Time Offer, the item and what comes with it, Worth $X, New item in N minutes. The v9.94 check counts four and requires the headline item named on line two. Fails on a v10.02 fixture: "the offer card has 3 lines" |
| A DOWNED PILLAGER STARTS AT FIFTY AND BLEEDS | v10.04 | his answer 44: start at 50, health ticking down as part of the downed count. v9.91's forty sat still until the clock ran out. Now fifty, falling fifty over the sixteen second bleed; a round shortens what is left; the clock stays the ceiling. Check downs a man, reads fifty, runs four real-loop seconds unshot and requires 8 to 18 points gone, runs out the bleed and requires him finished; control: two rounds leave about twelve and a third finishes. Fails on a v10.03 fixture: "he went down with 40 health, not fifty; four seconds down took only 0.0 points off him" |
| EVERY ASCENT STARTS AT DAY | v10.05 | his answer 24: default to day. v9.97 remembered the last choice, so night carried over. The lift resets P.cond to day (and the ground cache) before it opens the sector page. Check sets night, takes the lift, requires the page at day with DAY drawn chosen; control clicks NIGHT and requires it to take. Fails on a v10.04 fixture: "the sector page opened with the surface at night, not day" |
| A NIGHT RAID PAYS 1.2 TIMES THE XP | v10.06 | his answer 22. The run record never said night; it does now, stamped at the end of the raid, and addProgress multiplies a night run's XP by nightXp (1.2) before the bar's bonus; the sector page says "XP pays 1.2x" beside NIGHT. Check pays one record as day and as night and requires 1.2x, dial at 1 as control, then deploys at night, extracts through the game's end and requires the record to say night. Fails on a v10.05 fixture: "a night run paid 228, no more than a day run at 228" |
| CROUCH AND SPRINT ARE TOGGLES | v10.07 | his answers 33 and 35 (34: ADS stays a hold). One press of CTRL or C crouches, the next stands; one press of SHIFT sprints, the next walks; each turns the other off; exhaustion clears sprint. Toggles on G, so a raid starts standing. Pause screen and full legend say on/off. The v9.92 crouch check and the v8.73 sprint check press keys through the real handler now instead of holding them. Fails on a v10.06 fixture: "with C held he still walked at 100% of full speed" (a press, not a hold, on the old build does nothing) |
| THE ORGAN IS THE PILLBOX | v10.08 | his answer 47: "RENAME THE ORGAN". The emplacement (kind choir) was ORGAN, its guns ORGAN MOUTHs, its leavings an ORGAN WRECK. Now PILLBOX, PILLBOX SLIT, PILLBOX WRECK, THE PILLBOX HAS SEEN YOU, the guide card and the two feeling tags; the kind is unchanged. Check reads the maker's name, the cards and tags as data, then drives the loop with one beside the operator until it speaks and requires PILLBOX and not the old word. Fails on a v10.07 fixture: "the emplacement is named [ORGAN A]" |
| YOU CAN TELL THE GUNS APART | v10.09 | his note: "we desperately need to improve the graphics for the guns, its hard to even tell what they are". One painter drew every gun from the same five rectangles, no outline. Now eight families each with its known shape (handgun, revolver, SMG, rifle, scattergun, machine gun, marksman, lance), every part outlined in ink first; rarity colour kept. Check paints every weapon at 26 px through the real painter, requires each to draw with a dark outline and every cross-family pair to differ in a fifth of its pixels; control: the icon cache serves an image. Fails on a v10.08 fixture: "icons with no dark outline" and near-identical pairs |
| EVERY WINDOW SAYS CLOSE, AND ESC GOES THROUGH IT | v10.10 | his answer 1. Seventeen windows had ways out labelled Leave, Close, CLOSE, Back and Got it. ESC already closed the front window everywhere (a capture handler since v8.1x; I had written otherwise from reading one branch, and the driven control proved me wrong), but stripped .on except for the tuning console and the primer. Now every way out says CLOSE and ESC presses the front window's own CLOSE for every window (escCloseTopModal), the loadout question's NO and the tuning latch included. Check reads every window for CLOSE and presses ESC on five opened windows; control: ESC still closes the stash. Fails on a v10.09 fixture: "windows whose way out is not CLOSE: tradermodal says Leave, ..." |
| THE STASH TABS ARE HIS SIX, IN HIS ORDER | v10.11 | his answer 2: keep the tabs, reorganise into Guns, Consumables (plates, heals, grenades), Parts, Salvage, Keys, Other if needed. Was ALL, GUNS, ARMOUR, PARTS, SALVAGE, CONSUMABLES, KEYS. Now ALL, GUNS, CONSUMABLES, PARTS, SALVAGE, KEYS, with plates under CONSUMABLES and OTHER drawn only when non-empty. Check stocks one of each, reads the row, clicks CONSUMABLES for the plate and the medkit, ALL count as control. Fails on a v10.10 fixture: "the tabs read [ALL, GUNS, ARMOUR, PARTS, SALVAGE, CONSUMABLES, KEYS]" |
| THE LOADOUT SAVES ARE GONE | v10.12 | his answer 5: "REMOVE IT, NOT NEEDED". The three numbered saves under the operator on the ascent check, five functions and a picker branch, removed; the picker shows its hint until a slot is clicked; P.loadouts left inert. Check renders the ascent check and requires no save or load rows, no LOADOUTS heading, no loadout functions; control: the headgear slot still opens its racks. Fails on a v10.11 fixture: "the loadout save rows are still under the operator on the ascent check" |
| THE ARMOUR WARNING IS ON THE SECTOR PAGE | v10.13 | his answer 7. The warning was the stash screen's readiness line, copied by the sector page on open (via a full renderHub); v9.98 removed the line and the warning had been nowhere since, which I missed. Now written on the sector page under "Going up with" from the same rig numbers; the dead writer in renderHub removed; no renderHub call from the sector page. Check takes the lift and requires "no armour on", "Armour Plates" and the cap on the sector page; control: not back on the stash. Fails on a v10.12 fixture: "the sector page does not warn about armour" |
| THE BACKPACK IS A GRID OF CELLS, IN BOTH PLACES | v10.14 | his answers 8 and 28. Both backpacks used the same cells and both collapsed to a sentence when empty. Now twelve slots drawn whatever is in them (padSlots, BACKPACK_SLOTS), packed cells first, dashed empty slots after, growing past twelve as needed; the raid look kept. Check: empty stash backpack has twelve empty slots and no sentence; two packed give two filled and ten empty; the raid backpack the same; control: a packed cell is draggable with the item in its title. Fails on a v10.13 fixture: "the empty backpack draws 0 cells" |
| A DOWNED PILLAGER CRAWLS FOR COVER | v10.15 | his answer 45: crawl, "they should always play like real players". A downed man lay still. Now, while you can see him within 700 units, he searches eight points for one he can reach that you cannot see, every 1.5 s, and crawls there at a quarter speed, still bleeding; nothing found, he lies still; the sim untouched; dial raiderCrawl. Check stages a downed man forty units off a wall with the operator in sight, runs three real seconds and requires at least fifteen units crawled (forty if still in sight); controls: the dial off must not move him, the bleed clock must still finish him. Fails on a v10.14 fixture: "a downed pillager beside a wall crawled 0.0 units in three seconds" |
| SURPRISE ME, AND THREE LOOKS | v10.16 | his answers 18 and 19. Under the Depot figure: SURPRISE ME dresses the operator in a random owned thing from every rack; three LOOKS with SAVE and CLICK TO WEAR keep the six cosmetic keys (P.looks). Check earns everything, opens the Depot, requires SURPRISE ME to change the outfit and dress only in owned things, saves look 2, changes, wears it back, and requires three rows and six slots as controls. Fails on a v10.15 fixture: "there is no SURPRISE ME at the Depot" |
| BEARD, THE SEVENTH RACK | v10.17 | his answer 14, first category of eight. Five beards (Clean Shaven owned; Stubble, Goatee, Full Beard, Mutton Chops earned), drawn on the sprite under the face before the headgear so a mask covers it, on the figure, and as a swatch; seventh slot, profile key cosBeard, part of a look and of SURPRISE ME. Check requires five on the racks, one owned and none priced, every beard to change the sprite's head pixels, a mask to cover the full beard, the figure slot and swatches; control: headgear rack whole; the two six-slot checks now count at least six. Fails on a v10.16 fixture: "the racks hold 0 beards, not five" |
| THE PILLAGERS DRESS FROM THE RACKS | v10.18 | his answer 20. Pillagers had a coat and a name; the sprite read hair, hairstyle, headgear, skin and beard off unset fields, so all looked alike. Now raiderLook(ident,x,y) hashes who and where into picks from every rack, a third bareheaded, never the crown, spending no seeded roll. Check: the seed fingerprint at 4242 stays 85 ents and 165 containers (the control that matters), then at least three hairs, hats, skins, cuts and two beards among the map's pillagers, all real rack ids, no crown, and the same man dressed the same twice. Fails on a v10.17 fixture: "pillagers do not draw from the racks: there is no raiderLook" |
| EYES, THE EIGHTH RACK | v10.19 | his answer 14, second category. Six colours (Brown owned; Hazel, Blue, Green, Grey, Amber earned), the iris drawn in colour under the pupil on the sprite, the figure's eyes tinted, an eye swatch, an eighth slot and key, part of a look, and pillagers draw eyes from it. Check: six on the racks, one owned, none priced, key, default and colour for each, every colour changes the sprite's eye pixels against Brown, the slot and swatches; controls: seed fingerprint unmoved, every pillager has eyes. Fails on a v10.18 fixture: "the racks hold 0 eye colours, not six" |
| THE MOUSE SAYS WHAT A PANEL CORNER DOES | v10.20 | his answer 26. v9.09's drawn glyph stayed and the OS pointer was hidden in a raid. Now over a panel's resize corner the OS pointer is the diagonal double arrow, over its drag bar the move cross, over its minimise glyph the hand, from the same hudHit the glyph reads; away from panels it is hidden behind the reticle. Check moves the game's mouse onto a real corner and bar through mousemove and reads the canvas cursor; control: hidden away from the panels. Fails on a v10.19 fixture: "over the body panel resize corner the pointer is [none]" |
| FACE, THE NINTH RACK | v10.21 | his answer 14, third category. Six faces (Plain owned; Freckles, Scar, Mud, War Paint, Black Eye earned), drawn by the sprite's face painter with three new marks, a mark on the figure, a glyph swatch; ninth slot and key, part of a look, and pillagers draw a face from the rack. Check: six on the racks, one owned, none priced, every face changes the sprite's head pixels against Plain, the slot and swatches; controls: seed fingerprint unmoved, every pillager has a rack face. The raider field is faceMark, because e.face is the facing angle; the first draft named it face and every pillager stopped firing, caught by the end-state corpus. Fails on a v10.20 fixture: "the racks hold 0 faces, not six" |
| THE MENU SIZE NEVER GOES BELOW THE SCREEN, AND THE WHEEL SAYS WHAT IT DID | v10.22 | his note about 17:25, the stash text at 4K. MEASURED: a plain wheel over a menu with no list resized the menus by 0.08 a notch down to 0.7, silently, and the profile kept it; an empty stash has no list; his screenshot reads as a size near 0.8. Now the floor is 1.0 on the wheel, the Settings steps and the loaded profile, the wheel toasts MENU SIZE N%, and the what-is-new card moves to v10.22. The wheel's three notes (v3.57, v9.67, v9.95) stand. Check: wheel down from 1.0 stays 1.0, 0.7 draws no smaller than the screen factor, 0.7 loads as 1.0, a Settings step stays at 1.0, the toast names the size; control: wheel up gives 1.08 and 1.5 draws at 1.5 times the factor. Fails on a v10.21 fixture: "the wheel took the menu size below 1.0, to 0.92" |
| THE DEPOT AND THE CHEAT BOX NO LONGER SHARE A NAME PLATE | v10.23 | his note about 17:20. MEASURED at 1080p: the two names twenty-three pixels apart with thirty-six pixel plates, overlapping 400 to 570; the Depot's name cannot go lower without standing in the bottom wall. A station can carry its name under it; the cheat box does. Check: every station name traced, no two intersect, all on the screen; control: the Depot still opens. Fails on a v10.22 fixture: "DISCOUNT FASHION DEPOT runs into DEV CHEAT BOX" |
| THE CROWD DRESSES FROM THE RACKS | v10.24 | his note about 17:20: everyone in the Undercroft has blue eyes. MEASURED: the crowd rolled skin, hair, hat and cut from four old lists and nothing else, so every face wore the painter's default eyes, beard and face. Now the roll walks every rack (crown excluded) and the look is handed to the painter whole. Check: thirty looks all carry eyes, beard and face from the racks with at least two eye colours, none the crown; half the floor given blue and half green, both drawn; control: the old fields still roll. Fails on a v10.23 fixture: "30 of 30 crowd looks have no eyes; everyone wears the painter's default" |
| THE FIGURE AT THE DEPOT IS THE SPRITE | v10.25 | his note about 17:20: the raid's eyes look far better and the doll's hair lay over the face. The figure was a second drawing of her in divs; now the raid's painter draws her on a canvas at five times raid size, from the same code, so every rack shows the same in both places and later racks need nothing here. The doll stays hidden for the pieces that read it. Check: canvas painted; cap, blue eyes, beard and violet hair each change it; the doll has no height; control: the slots still beside her. Fails on a v10.24 fixture: "the Depot has no painted figure, only the doll of divs" |
| THE HOTBAR IS THE TACTICAL BELT | v10.26 | his note about 17:20: tactical belt across the entire game. Fourteen player-facing places renamed: the raid backpack panel, the stash loadout column, both legends, the pause gear rows, the primer, the search prompt, the ascent summary, the drag-off toast, the throwable hint, the card. v9.89 and v9.90 turned round to require his word and forbid the old. Check: the legend tables hold his word and not the old, the panel, column, hint, card and primer likewise; control: backpack still named. Fails on a v10.25 fixture: "no legend says tactical belt; the old word stands everywhere" |
| NET LIFETIME EARNINGS | v10.27 | his note about 17:35. The card showed proficiency (banked minus sixty percent of what you died holding, floored at zero). Now the bag is valued at landing and at extraction, the record keeps both, earnings are extracted minus carried in with a death or abandon losing what it carried, the profile keeps the running sum (negative allowed), an old profile sums its log once, and the card says what it is. Check: in and out with the same kit reads zero, a death with a landed bag reads minus that bag, scrap out adds the scrap, the card named and explained, an old log sums haul-only; control: the Experience card. Fails on a v10.26 fixture: "the profile has no lifetime earnings; the card is still proficiency" |
| THE TUNING CONSOLE IS A ROW IN SETTINGS, AND THE ROWS READ THE DIALS | v10.28 | his note about 17:30. A TUNING CONSOLE row with OPEN; the rows show the option the live dials match or CUSTOM in amber; closing the console over Settings redraws them; a click steps from what the row shows and writes the dials. Both ways, which was his question. Check: the row opens the console, a hand-set sentry count reads CUSTOM, an option's values read as that option, a click writes and shows the next; control: the backquote key. Fails on a v10.27 fixture: "Settings has no row for the tuning console" |
| THE WELCOME PACK | v10.29 | his note about 17:40. A new character's first time down opens a window: a green gun (Compact SMG) and a blue one (Burst Carbine), two medkits, three bandages, two plates, two frags and a smoke, into the stash on TAKE THE PACK; CLOSE or ESC declines; offered once; a profile that has climbed or owns anything is stamped quietly. Check: fresh character offered, takes it, guns in the armoury one green one blue, items in the stash, stamped, no second offer; a decline gives nothing and stamps; control: three runs never offered. Fails on a v10.28 fixture: "there is no welcome pack window" |
| THE CHEAT BOX IS BEHIND A SWITCH THAT UNLOCKS AFTER ONE EXTRACTION | v10.30 | his note about 17:40. The box stood on every local floor with no switch. Now a DEV CHEAT BOX row in Settings puts it on the floor, LOCKED and inert until the profile has extracted once, and the host gate stays. Check: a fresh character finds no box and a locked switch that does nothing; one extraction unlocks it; ON puts the box on the floor and it opens; control: OFF takes it away. Fails on a v10.29 fixture: "a fresh character finds the dev cheat box on the floor" |
| THE BLOTTER MELTS, AND NEVER THE SAME WAY TWICE | v10.31 | his note about 17:45. The warp was a fixed score on every dose. Eight numbers rolled with each dose drive a melt pass, the frame pouring downward in strips that sway and stretch on their own clocks, the pouring breathing on a slower rolled clock; Math.random, never the seeded stream. Check: two doses differ between two moments and between two rolls by three times a still scene's drift; a fresh dose rolls the clocks; control: no dose, near still. Fails on a v10.30 fixture: "the Blotter has no rolled clocks; every trip is the same score" |
| BOOTS, THE TENTH RACK | v10.32 | his answer 14, fourth category. Five pairs (Black owned; Tan, Olive, Oxblood, Bleached earned), the sprite's two fixed boot greys now BOOTCOL by id, boots drawn under the figure's legs, a boot swatch; tenth slot and key, part of a look, and pillagers draw boots. Check: five on the racks, one owned, none priced, colour for each, every pair changes the sprite's feet pixels against Black, the slot, the figure's boots and swatches; controls: seed fingerprint unmoved, every pillager booted. Fails on a v10.31 fixture: "the racks hold 0 pairs of boots, not five" |
| GLOVES, THE ELEVENTH RACK, AND HANDS THAT MATCH THE SKIN | v10.33 | his answer 14, fifth category. Bare Hands owned, four gloves earned; found on the way: the sprite's hands were one fixed tan on every skin at all four hand sites. Now handColour(st) is the gloves or the skin, at all four; hands on the figure; a hand swatch; eleventh slot and key; part of a look; pillagers draw from it. Check: five entries, one owned, none priced, every pair changes the sprite against bare hands, ebony skin changes the bare hands, the slot, the figure's hands and swatches; controls: seed fingerprint unmoved, every pillager has a gloves entry. Fails on a v10.32 fixture: "the racks hold 0 pairs of gloves, not five" |
| BACKPACK COLOUR, THE TWELFTH RACK | v10.34 | his answer 14, sixth category. The sprite's pack was one brown; five now (Canvas owned; Olive, Black, Rust, Sand earned), PACKCOL by id on the sprite, a strap on the figure, a pack swatch; twelfth slot and key, part of a look; pillagers draw from it. Check: five on the racks, one owned, none priced, colour for each, every pack changes the sprite against Canvas, the slot, the strap and swatches; controls: seed fingerprint unmoved, every pillager has a pack. Fails on a v10.33 fixture: "the racks hold 0 packs, not five". Also: the v9.58 check measured the fullscreen button with the title screen switched off and failed on a build that never touched it; it now switches the title on for the measurement, as v9.50 does |
| PATCH, THE THIRTEENTH RACK | v10.35 | his answer 14, seventh category. Six entries (none owned; Red Cross, Skull, Star, Chevron, Flag earned), one painter drawPatch for the sprite chest and the swatches, a square on the figure; thirteenth slot and key; part of a look; pillagers draw from it. Check: six on the racks, one owned, none priced, every patch changes the sprite chest against none, the slot and painted swatches; controls: seed fingerprint unmoved, every pillager has a patch entry. Fails on a v10.34 fixture: "the racks hold 0 patches, not six" |
| TATTOO, THE FOURTEENTH RACK | v10.36 | his answer 14, eighth and last category. Six entries (No Ink owned; Teardrop, Neck Ring, Tribal, Anchor, Spider earned), inked on the sprite's face and neck before the beard and headgear, a mark on the figure, a glyph swatch; fourteenth slot and key; part of a look; pillagers draw from it. All eight of his categories are on the racks now. Check: six on the racks, one owned, none priced, every tattoo changes the sprite's head pixels against No Ink, the slot and swatches; controls: seed fingerprint unmoved, every pillager has a tattoo entry, fourteen kinds. Fails on a v10.35 fixture: "the racks hold 0 tattoos, not six" |
| THE ALPHA, FIRST BUILD: A CRASH IS CAUGHT | v10.37 | his ask about 16:45, an alpha for his friends on itch in 72 hours. Nothing caught an uncaught error: no onerror, no rejection handler, no report line; a throw inside a frame threw again next frame in silence. Now every uncaught error and unhandled rejection is written to P.crashes with build, screen, message and stack top, the same message inside five seconds counts on one entry, the newest twelve are kept, the run report carries a CRASHES section under the install line, and the player is told once. Check: one dispatched error makes one stamped entry and a report line, four of the same make one entry counted four, a rejection is recorded, twenty distinct hold at twelve newest, an empty event records nothing; control: the report header. Fails on a v10.36 fixture: "the profile has no crashes list, so a fault on a friend machine records nothing" |
| THE ALPHA, SECOND BUILD: THE WHAT IS NEW CARD IS CURRENT | v10.38 | the card a friend reads first stood at v10.22 against a v10.37 build, fifteen builds behind, with nothing about the welcome pack, the crash catcher, the eleven new racks, the Depot figure, net lifetime earnings, the tuning row or the Blotter; the parse gate would have failed the build at twenty. Now at v10.38, opening with what an alpha is, then the things a friend meets first. Check: card within two hundredths of the build, ten or more lines, ALPHA first, the welcome pack, the fourteen racks, net lifetime earnings and the tactical belt named, no lone hotbar, no dashes; control: the once-per-load latch. Fails on a v10.37 fixture: "the card is at v10.22 against a build at v10.37, so a friend reads news that is 15 builds old" |
| THE ALPHA, THIRD BUILD: ASKED BEFORE IT SENDS | v10.39 | his question about 16:55, a place that lets friends push feedback. The seam existed (PUBLIC_DROP, null) and consent was a Settings switch under a hint saying it did nothing; a friend was never asked. Now the Undercroft asks once after the welcome pack, in plain words, only when an address exists; YES sends each report as the raid ends, CLOSE keeps them in Downloads and still counts as answered, ESC reaches it, Settings changes it either way and its hint reads the true state. The collector is tools/collector/worker.js with his seven steps in README.md; the URL goes in as a one line build. Check: no question without an address; with one, the window with Downloads and Settings named, YES on and answered and closed and not asked again, CLOSE off and answered and closed, arrival through the welcome asks, the Settings hint both ways, the card naming the question; control: the welcome pack window. Fails on a v10.38 fixture: "there is no question window; a friend on itch is never asked whether reports may be sent" |
| THE ALPHA, FOURTH BUILD: THE FOUR SEALED BUILDINGS ARE OPEN, AND A GUARD | v10.40 | the STILL OPEN line "the demolition achieves nothing for four buildings" measured again on v10.39 before anything was touched: 14, 15, 20 and 21 on THE COLD MILE at seed 4242 are enterable; no building on that seed holds floor nothing can reach. Fifteen seeds flag one to four buildings each, and those are slivers and one furniture-plugged niche per seed, 12x12 to 84x28 units, with open doors and reachable centres, invisible to the coarse repair (cell 16 padded 12). A drafted door punch was thrown away as dead code. No game change; a guard on five seeds for any unreachable room of 32x32 or more. Check: seeds 4242, 4, 2, 9, 6 clean, ents 374 at 4242; control: building 0 bricked up on purpose is named by the guard. The niche is a new STILL OPEN line below |
| HIS WORDS, FIRST BATCH | v10.41 | his 17:15 ask for the text document, and his first thirty two rows back as a pasted table. Nine changed and went in through tools/textdoc/import-text.ps1: RAID PAUSED, the pause box controls (E interact, crouch toggle, superhot mode, tuning sliders), the feedback line, YES, ABANDON THIS RUN, the downed line (true: extraction while downed is permitted), Wirt's sentence and Gamble 2500c (the static 450c label was never seen; the code writes the real price over it), the Depot sentence; two of those (the abandon confirm, Wirt's line) are written by code and went into the writers too, which the corpus caught. Three rows came back empty (the feedback hint, The Terms description, Sign nothing) and are held until he says whether empty means delete. Check: each line read back off the screens; control: the two held lines unchanged. Fails on a v10.40 fixture: "the pause box does not say RAID PAUSED" |
| THE PILLAGER BOARD AND THE CONDITIONS PANEL FOLLOW THE HAND | v10.42 | the STILL OPEN line "the raiders board runs ahead of the cursor". Both panels added the screen-pixel drag inside their zoomed space, so the board moved 1.15 times the hand and the panel 1.05, and their on-screen clamps were in the same wrong space. Both now divide the drag by their zoom and clamp against the screen edges brought into that space; the 13 of 40 was the right-edge clamp doing its job. Check: 100 sideways moves each 100, 80 and 60 down likewise, 9,000 off the edge keeps the handle on screen (the v9.12 rule); control: the vitals block still 100 for 100. Fails on a v10.41 fixture: "a 100 pixel drag moved the pillager board 115 pixels" |
| THE MESSAGE LINE GROWS WITH THE MONITOR | v10.43 | his answers 25 (on-HUD messaging) and 30 (4K). MEASURED with the text trace: every panel doubles from 1080p to 4K through hudRes; the message line was 19px at both, scaling only with the HUD size dial. Now drawn inside hudZoomIn('msg',W/2,0) so it grows with the panels and stays centred. Check reads the drawn size at 1080p, 1440p and 4K and requires 1.2x and 1.8x, centred, at its old place at 1080p. Fails on a v10.42 fixture: "at 4K the message line is 19px against 19px at 1080p" |
| THE FULL CONTROLS LIST IS ON THE SCREEN | v10.44 | his answers 25 and 30. MEASURED: the full list (H twice) drew its MOVE heading at y -52 and its rule cards inside the conditions panel at 1080p, and the whole list at x 4797 on a 3840-wide screen at 4K, so on his monitor it showed nothing. Cause: the centred list was drawn inside the compact panel's corner zoom (anchored left edge, bottom target). Now scaled about the bottom centre, capped to fit. Check draws it at three sizes and requires heading, hide line and sound key inside, the list centred, no rule line in the conditions box; control: compact legend still bottom left. Fails on a v10.43 fixture: "at 3840x2160 the MOVE heading is at 4797,504, off the screen" |
| THE SPARTAN HELMET AND THE GHOST MASK | v10.45 | his notes about 14:00: a Master Chief style green helmet and a Ghostface style mask. Two headgear: Spartan Helmet (green, gold visor, twenty extracts) and Ghost Mask (pale, black hollows, three Wardens), both covering the face; swatches and figure glyphs. Check: both on the rack and earned, each changes the sprite's head by a large margin, the helmet green and the mask pale by pixel count, a full beard hidden under each, swatches, the figure; control: the visor still draws. Fails on a v10.44 fixture: "the headgear rack is missing spartan, ghostmask" |
| THE NUMBER 23 JERSEY | v10.46 | his note about 14:00: a red and black 23 jersey. On the clothing rack, earned at level four: red stops, black side panels and a pale 23 painted on the sprite's torso; the figure gets inset panels and the numeral; the swatch shows the number. Check: on the rack and earned, more red, pale and black torso pixels than slate, figure and swatch carry the number; control: slate plain. Fails on a v10.45 fixture: "the clothing rack has no jersey" |
| SNEAKERS ON THE BOOTS RACK | v10.47 | his note about 14:00: different shoes, Jordan 1, Jordan 11 and so on. Three pairs on the boots rack, earned: Chicago High-Tops (red, white sole, twenty runs), Concord Low-Tops (black, pale collar, white sole, twelve extracts), Bred High-Tops (black, red sole, level five). Boot colours grew a sole stop and a collar stop; the sprite draws them; the figure gets a sole border; swatches a sole strip. Check: on the rack, earned, sole colours, feet pixels red and pale as expected, figure and swatch soles; control: black boots draw no sole. Fails on a v10.46 fixture: "the boots rack is missing sneakchi, sneakcon, sneakbred" |
| NIGHT IS DENSER | v10.48 | his note about 19:15, "night mode should have more enemy density since it pays better". Night paid 1.2x XP and spawned what day spawned. Now the machines come out nightDens times as many after dark, 1.35 by default, the crawler house floor included (as HEAVY PATROLS already does); day untouched, the pillagers keep their count, the bot takes the night too. At seed 4242 THE COLD MILE goes 337 to 445 machines (374 to 482 entities), COLD STORAGE 74 to 101. Check: day fingerprint 374, night at least 1.15x machines and 1.25x sentries with pillagers equal, dial at 1 equals day; the v9.30 house rule run by night. Fails on a v10.47 fixture: "night spawns 337 machines against 337 by day; it is not denser" |
| HIS IN-GAME TEXT EDITS ARE PICKED UP PERMANENTLY | v10.49 | his order about 19:35, "IF i EDIT TEXT USING THE IN GAME TEXT EDITOR, YOU SHOULD PICK IT UP PERMANENTLY". The editor kept edits on the profile (P.txt, P.txp) and nothing carried them off his machine. The run report now carries TEXT EDITS and TEXT PATTERNS as JSON; the local collector lands it in exports/; tools/textdoc/pull-edits.ps1 merges the maps and import-text.ps1 -Map bakes them into the source by manifest row, or as the exact string. An edit sends a report the moment Enter is pressed; the Edit the words row and the editor are DEV_LOCAL only, so friends never see it. Every tick reads exports/ for edits first. Check: probe maps present and reading back, empty maps write nothing, header as control. Fails on a v10.48 fixture: "the run report carries no TEXT EDITS line, so an edit lives and dies in the browser" |
| FACE MARKS AND BEARDS CLEAR OF THE EYES, BOOTS ARE BOOTS | v10.50 | his note about 19:20 on the Depot. Measured against the eye band (32.5 to 26.5 units up): freckles at 27.8 and 27.2 inside it, the scar 33.6 to 27.2 through the right eye, the stubble 1.7 into it, the goatee and the mud clipping it; the boots were the whole lower leg. Now freckles on the cheeks at 26.0 and 25.4, the scar on the outer cheek at 6.2 right, mud from 26.4, every beard from 26.2 or lower, the dust mask down to the chin, trousers a darker cut of the coat with the boot colour on the foot and a collar. Check: the eye band read off the whites, marks and beards below it, the scar outside it, two boot colours differing over at most 44 of 57 rows; control: the band itself. Fails on a v10.49 fixture: "the freckles start at row 145, inside the eye band that ends at row 165" |
| BEHIND THE TERMINAL HE IS SHOWN THROUGH THE WALL, AND NEVER RUNS IN PLACE | v10.51 | his notes about 19:30 and 19:45. The terminal plinth's collider is y 385 to 405 and the room paints every wall top 26 units above its collider, the raid's lift, and never got the raid's v9.27 see-through pass, so from behind he stopped at 374 under the drawn top and vanished into the terminal; and the walk cycle was keyed to the keys, so pinned there he ran in place. Now the room runs the raid's see-through arithmetic against its own wall list and paints him again at half alpha when a wall top covers him, and moving is the ground covered this frame, measured after the wall push. Check: pinned behind the plinth with S held, no movement and no walking; on the open floor, both; frames with the pass off and on differ behind the plinth and are identical in the open. Fails on a v10.50 fixture: "pinned against the plinth he runs in place: moving is true with no ground covered; behind the plinth the see-through pass changes 0 pixels; he vanishes into the drawn wall top" |
| THE CRATE PROMPT AND THE ITEMS-LEFT COUNT ARE BIGGER | v10.52 | his note about 20:00. The prompt over a container was label size, 18.7 px rendered on the 1080p pane, and the count under the search bar micro size, 15.6, the smallest type in the game, on the line he reads while deciding on one more pull. Prompt is a callout now, 23.4; count a label, 18.7, in a pill grown to fit; the item name under a single-item prompt moved down clear of it. Check: a raid at seed 4242, operator on the first unopened crate, the HUD's text traced standing and mid-search; the prompt at least 21 px and on screen, the count at least 17. Fails on a v10.51 fixture: "the prompt [E] SEARCH CRATE is drawn at 18.7 px, smaller than a callout (23.4 here at 1080p); the count 1 item left is drawn at 15.6 px, smaller than a label (18.7 here)". My first thresholds, 18.5 and 15, came from a remembered 1.3 multiplier; the pane multiplies by 1.56 and the old build passed them, so they were measured and reset to 21 and 17 |
| THE CHEAT BOX HAS AN ALL COSMETICS SWITCH | v10.53 | his notes about 19:40: unlock all cosmetics from the dev cheat menu, and make it a toggle. One flag on the profile, P.cosAll, read by the ownership rule ahead of every earning rule; nothing earned or bought is written or cleared, so cutting it off returns exactly the racks he had. The button under TAKE $100,000 reads ALL COSMETICS: OFF or ON. Check: flag cleared, racks counted, one click gives the flag, the label and every rack; a second click gives the first count back with the bought list and the earned counters unchanged. Fails on a v10.52 fixture: "the cheat box has no ALL COSMETICS switch" |
| OUTFITS: SEVEN FULL-BODY SUITS THAT OVERRULE EVERY OTHER RACK | v10.54 | his notes about 19:50 and 19:55. A new OUTFIT rack at the top of the Depot: the Skeleton, the Machine, the Trooper, the Android, the Tomb Explorer, the Baller and the Street Poet, each earned like any rack. Worn, the painter takes the suit's coat, trousers, boots, skin and hands, its own cut, hat and beard, no mark, tattoo or patch, and paints the suit's own marks last; Own Clothes puts the racks back. The four named characters and people are licensed or real, so these are the game's own archetypes. Check: the rack counted, the outfit in the look kinds, the figure painted at 5.2: an unearned suit changes nothing, each earned suit changes at least 300 pixels and hides every slate coat pixel, the Trooper paints helmet green, the Depot lists OUTFIT first with eight tiles. Fails on a v10.53 fixture: "the OUTFIT rack holds 0 suits, not seven; a look does not carry the outfit; the Trooper paints no helmet green; the Depot does not list OUTFIT as its first slot; the Depot racks show 0 outfit tiles, not eight". The full corpus then failed six older sprite checks: the saved :8800 profile carried the Skeleton from a dry run and the cleaner keeps cosmetics; the cleaner now resets the outfit slot, and a random look leaves the outfit rack alone; corpus re-run after both |
| FOOTPRINTS FOLLOW THE GROUND YOU COVER | v10.55 | his note about 20:00, "sprint footprint glitch is still happening", reproduced with the live stepper: the print was keyed to time with a key held, 0.22 s at a sprint, and stamped before the wall push, so held into a wall he piled prints under himself a step inside the wall. Now one print per 56 units of ground actually covered, measured after the push, in the direction he moved; none while pinned. Check: the live loop on map 0 at seed 4242; a walk and a sprint across open ground with every gap 48 to 64 units; a sprint into a wall for 120 frames with no movement, at most one print, and no print inside any wall. Fails on a v10.54 fixture: "pinned against a wall, sprinting into it for 120 frames, he stamped 8 prints under himself" |
| EVERY GUN HAS ITS OWN VOICE | v10.56 | his note about 19:40, guns first. The audit found sixteen guns on eleven voices: Magnum and Longshot borrowed the Auto Rifle, three pairs differed by a lowpass corner, every shot was the identical waveform, and reload, bolt and dry pull were silent. Now a crack, a body and where earned a tail and the action cycling, per gun; six percent jitter per shot; reload, reloadin and dry voices at the reload starts, the reload finish and the empty pull. Check: a recording audio context; sixteen different voices, no two shots identical, drift under fifteen percent, and the three new voices scheduling nodes. Fails on a v10.55 fixture: "Scav Pistol fires the identical waveform twice; ... Magnum and Auto Rifle schedule the same voice; ... Longshot and Auto Rifle schedule the same voice; ..." (sixteen guns, every one identical twice, two borrowing the rifle). My first check tripped the parse gate: a regex written straight after return reads as a division to its bracket counter; parenthesised now |
| FOOTSTEPS: HEEL AND SOLE, LEFT AND RIGHT, THE GROUND UNDER EVERYONE | v10.57 | his note about 19:40, the second sound family. A step was one noise burst per surface, centred, on a fixed clock, the identical waveform every time; machines and pillagers had two recipes and no surface. Now heel then sole, the surface's own tell (grit, a creak, the ring, a rustle, a splash and a drip), a sprint harder and a crouch softer, left and right in the ear, a breathing clock, eight percent jitter; enemies step through the same generator on the surface under their own feet. Check: a recording audio context; five different voices each with a heel and a sole, none repeating, sprint louder and crouch softer than a walk, two real steps panning opposite ways, a pillager in a building scheduling the wood body. Fails on a v10.56 fixture: "stone schedules 5 nodes, not a heel and a sole; stone schedules the identical step twice; ... a sprint step (44) is not louder than a walk (44); a crouch step (44) is not softer than a walk" |
| THE TRAILING NOISE AFTER A GUN IS SHORT | v10.58 | his notes about 21:25 and 21:27 on the play build with v10.56's voices. The big guns' tail was 0.35 of the crack and 1.6 times its length (the Longshot 12,160 samples), the pump's second click landed at 0.42 s. Now nothing a shot schedules starts past 0.30 s, the tail is 0.9 of the crack at a tenth of its level and darker, the big cracks are shorter, the bolt clicks at 0.16 s and the pump at 0.16 and 0.26. Check: a recording context that notes start times and buffer lengths; sixteen guns with no node past 300 ms and no buffer past 6,000 samples; the Longshot's tail no longer than its crack and its quietest layer at most 0.12 of the loudest. Fails on a v10.57 fixture: "Magnum schedules a 7680 sample buffer; Longshot schedules a 12160 sample buffer; Scuttle schedules a src 420 ms after the shot; Riot Scattergun schedules a src 420 ms after the shot; Meridian Lance schedules a 10240 sample buffer; the quietest layer under the Longshot is 0.31 of the crack, not a tenth" |
| BEHIND A WALL YOU LOOK LIKE YOURSELF, FADED | v10.59 | his note about 21:30. The v9.27 see-through pass painted him through a wall as one flat light-blue colour with no racks; behind cover he turned blue, while the Undercroft's pass already drew the real figure. Now the raid pass makes the sorted pass's own call for him at 0.55 alpha: coat, racks, outfit, stance, gun, roll, reload. Check: a raid at seed 4242, the operator under a big wall's drawn top, a frame with the pass off and on, at least 80 pixels differing, then the chest sampled in both frames: blue over red may not exceed the wall top behind it by more than 15. Fails on a v10.58 fixture: "the chest seen through the wall is bluer than the wall behind it by 30 (blue over red): a light-blue cutout, not his coat". My first check measured the blue share of the whole figure and passed the old build; the control caught it |
| WALLS ARE SOLID, AND NOBODY STANDS INSIDE ONE | v10.60 | his two notes about 21:40 and 21:45, both with pictures: the transparency looks goofy, and people are still caught on walls in the Undercroft. One fault, and mine: every wall is painted 26 units above the rectangle it collides with, so the strip just north of a wall is standable floor the wall paints over, and since v9.27 the answer was a faded copy of the player drawn on top. Measured on v10.59 over 1,200 steps: bodies inside a wall picture 1,821 times of 19,200 samples, 8 of 15 people, every one painted over, one counter holder permanently. Now the room collides everyone with what the walls PAINT, places the crowd against the pictures at build, pushes after every clamp, and the see-through dial is off, so a wall is in front of you or behind you. Check: the picture worked out from the collider and the renderer's lift, the dial off out of the box, 1,200 steps with nobody inside a picture. Fails on a v10.59 fixture: "walls still go transparent by default (seeThrough is 1); the room does not know what its walls paint; over 1200 steps of the room, people stood inside a wall picture 1659 times (5 of 15 bodies); first: body 6 (a post holder) at 190,426 inside the picture of the wall at 0,450 700x20, at step 0". The dry run caught the room own clamp putting bodies back inside the south wall and the v10.51 check aiming at a spot nobody can stand in any more; the corpus then caught the SECOND crowd build (coming down to the floor rebuilds the people and that call passed the colliders), so there is one builder now, and the what-is-new card fifteen builds out of date, which is what a friend reads first |
| THE UNDERCROFT IS DARKER AND GLOOMIER | v10.61 | his note about 21:50, the second on this: v9.87 dropped the register an octave and closed the filter to 1500 and it is still too happy. What was left: the tune was led by a SQUARE wave at 0.105 over a triangle at 0.075, the shimmer rolled every eighth, and the room walked at a hundred a minute. Now the triangle leads at 0.115 with the square under it at 0.035, the room plays at seventy-six (0.197 a sixteenth), the corner closes to 900, the shimmer plays one a quarter at 0.04, and the bass is held 3.4 s so the room hums. Same dial: off puts the bright room back. Check: the piece played dry; the square quieter than the soft voice, a sixteenth no faster than 0.1875, a corner at or under 1000, at most 4.5 shimmer notes a bar and none above 0.05, a bass note at least 2.5 s, and a control that turns the dial off and requires the square and the open filter back. Fails on a v10.60 fixture: "the square is still the loudest thing in the tune (0.105 against 0.075); the room plays a sixteenth every 0.15 s; the lowpass corner is 1500 Hz; the shimmer plays 8.0 notes a bar; the shimmer is still at 0.060". Also: v9.87 named the tune by its TIMBRE, so a timbre change read as a deleted voice; it names it by its length now |
| A FOUND GUN TAKES THE EMPTY SLOT | v10.62 | his note about 21:25. Reproduced on v10.61: pistol in hand, Bare Hands in the second slot, a found Auto Rifle equipped to the hand put the rifle in his hand, bagged the pistol and left the second slot empty. Now a found gun is routed to the free slot when the one he asked for is full and the other is not; with both full the asked-for slot is still replaced, which is the only way to choose, and the line names the gun he kept. Check: four cases through the bag's own call, his case, its mirror, both full, and asking for an already empty slot. Fails on a v10.61 fixture: "with the second slot empty, equipping a found rifle turned the Scav Pistol out of his hand (hand is now Auto Rifle); the found rifle did not go to the empty second slot (it holds Bare Hands); the pistol was bagged anyway" |
| A HOWLER OUTSIDE CANNOT BOMB YOU INSIDE A HOUSE | v10.63 | his note about 21:32. Measured on v10.62 first: standing mid-building (460x420 at seed 4242 map 0), a shell from a Howler 300 units outside took 41 health in one hit; a roof stopped nothing. Now a shell landing on a building bursts on the roof and nobody under it is touched, him or the pillagers sheltering there, while it still booms, flashes, shakes and pulls attention; and only when the shooter was not under the same roof, so a Howler that came inside still hurts. Check: the impact driven directly, four ways: inside with the shooter out (nothing), in the open beside it (still hurts), fired from inside (still hurts), and a pillager under the roof (untouched). Fails on a v10.62 fixture: "standing inside a building, a shell fired from outside still took 41.0 health off him" |
| F STRIKES, AND THE CONTROLS SAY SO | v10.64 | his note about 21:32. Measured on v10.63: with a rifle in hand and a body at arm's length, ten keys pressed one at a time (F T Y U J K L N R V) touched nothing; the word MELEE appears only as the ammo counter for empty hands; neither controls list named a key. Now F strikes with whatever is held, reusing the Bare Hands swing so reach, arc, damage, backstab, noise and sound are the already measured ones, with its own cooldown and no ammunition cost, and both lists name it. Check: the real key handler driven; a hit at arm's length with the magazine untouched, no hit at 300 units, two presses landing one blow, and melee named in both lists with F in the full one. Fails on a v10.63 fixture: "with a rifle in hand, F did not strike a body at arm's length; the full controls list does not name melee; the short controls list does not name melee". My two errors, both caught by the dry run: the strike counted itself through a bare T (a local alias elsewhere) and threw before swinging, and the check reset the body's x but not its y between cases so it measured a live crawler's drift |
| THE CARD THAT ASKS HOW IT FELT CAN HAND YOU THE ANSWER | v10.65 | not his note: the alpha. The end of raid card asks HOW DID THAT RUN FEEL with tags and a note box, then offered only Log run and return; the sole copy button was buried in Settings behind the Operator Terminal on the recorder tab, and the public drop is unset so a friend's report stops in their Downloads. Now the card has Copy report beside it: it logs the raid with tags and note through one shared commit, fills the recorder box with the same text, copies it, says "Copied. Paste it to Daniel." on its own face, leaves the card open, and cannot log the raid twice. Check: a real raid ended, a note typed, Copy pressed; the report holds that raid and the note, the log gains no second row, the note is on the logged row, the card stays open, and leaving adds nothing. Fails on a v10.64 fixture: "the end of raid card has no Copy report button". My check assumed the raid is logged at the button; it is banked before the card is drawn (v8.17) and the card patches the row |
| A NEW CHARACTER ACTUALLY GETS THE BRIEFING | v10.66 | not his note: the alpha, and the first thing a friend meets. Arriving on a fresh save opened the primer (FIRST TIME OUT) and then opened the welcome pack on the next line; opening a window closes every other one, so the primer died the instant it appeared. Measured on v10.65: on arrival only the pack is up, the primer's seen flag is still 0, it is paid only on a second arrival with no raid in between, and after the first raid v7.88 stamps it away unread. Now the three first-run cards queue (pack, consent when a drop exists, primer) and the primer stays owed for the first three raids. Check: a fresh save driven five ways, including a player who goes straight up and comes back. Fails on a v10.65 fixture: "closing the welcome pack does not bring up FIRST TIME OUT; after one raid the primer is gone unread" |
| THE WELCOME PACK GUNS GO INTO HIS HANDS | v10.67 | not his note: found by driving a first session in a cleared browser. The pack promises "a green gun and a blue one" and puts them in the armoury, then the deploy issues a starter to anyone with nothing equipped, which is every new character; measured on v10.66 he went up holding a Scuttle with pistol, smg and carbine in the armoury and 'fists' equipped. Taking the pack now fills the two weapon slots as well, and only slots that hold nothing, so a player who already chose keeps his choice. Not the found-gun auto-equip he refused on 2026-08-24; that stays off. Check: a fresh save three ways, the slots after taking, the gun actually in hand on deploy with no loaner flag, and a rifle owner keeping his rifle. Fails on a v10.66 fixture: "after taking the pack his first slot holds fists, not the smg he was given; he went up holding Scuttle instead of the Compact SMG from his welcome pack" |
| HARNESS, MY ERROR: the corpus named three different checks on one build | v10.67 | the full run failed twice and disagreed with itself: v9.25 and v10.50 on run one, v8.72 on run two, all three green run alone. TWO CAUSES, both mine. The extraction card is not a modal so showScreen cannot clear it, and six checks end a raid without closing it; it then covers the page and v8.72's belt drag releases onto the card, which reads back as his old symptom. Proved by hand: four failures in a row with the card up, PASS the moment it was closed, nothing else touched. And neither runner pinned the display or cleaned the saved profile before starting, so run one inherited a deployed raid and a hand probe's cosmetics, which is what "the fullbeard paints nothing" was reading. FIX: every check starts with the card shut, safe because the only two checks that read it open it themselves, and both runners now call __pinDPR and __cleanProfile first. The v9.82 lesson in a second place |
| HARNESS, MY ERROR: two checks were leaning on an old profile | v10.68 | the corpus went red naming v10.50 and v9.25, and neither is a regression: v10.50 fails identically on a v10.67 fixture as the first check on a fresh page. What changed was the PROFILE, which driving a friend''s first session rewrote to a young character. COSMETICS ARE EARNED and cosWorn falls back to the default for any rack the profile does not own, so P.cosBeard=''fullbeard'' on a profile with 8 extractions paints Clean Shaven; the Full Beard needs ten, the Stubble and Goatee are gated on runs which it had, which is why one beard of three failed. Fixed with his own v10.53 unlock flag, restored afterwards. v9.25 read notoriety as an ABSOLUTE TOTAL and passed at 1 or more, so a profile carrying 12 made it green before a round was fired. From zero it went red and the cause is older than the check: a peaceful pillager turns hostile on PROXIMITY inside 180 units and the ladder started at 110, so he was fighting before the round landed and the charge correctly declined. Measured by hand: at 110 hostile at frame 4 and no charge, at 190 the charge fires 0 to 1. AND HIS REACH IS 187, so no single distance can prove both that he fights back and that the charge fires. Split into two seats, close for the fight and far for the charge |
| A FOUND GUN TAKES THE EMPTY SLOT, THE OTHER HALF | v10.68 | his note of 2026-09-03 about 21:25, "when i find a gun it should go to the next open slot, not kick my scav pistol out of slot 1". v10.62 closed the backpack-equip half and could not reach the half he named, because a better gun never gets as far as the backpack: the pickup equips it on the spot. REPRODUCED on v10.67 on the real play path, holding E through the game's own frame loop, COLD STORAGE seed 4242: Scav Pistol in hand, Bare Hands in the second slot, nearest container holding a Compact SMG, and after the search the SMG is in his hand, BARE HANDS IS STILL IN THE SECOND SLOT and the pistol is in the bag. FIX: the found gun fills the empty slot, his hands are untouched, nothing is bagged or spliced, and the line names both guns and the swap key. BOTH SLOTS FULL IS UNCHANGED on purpose; whether a found gun should equip itself at all is his 2026-08-24 note and his call. Check drives both arms on the real loot path with a rifle in the full slot, which the pickup could not have put there. Fails on a v10.67 fixture: "the smg he found pushed the Scav Pistol out of his hands" |
| THE BRIEFING SAYS HOW MUCH OF IT YOU HAVE NOT READ | v10.69 | not his note: found driving a first session in an empty browser, and it closes the STILL OPEN line measured at v10.68. FIRST TIME OUT is the one card that teaches the game and most of it was off the bottom: 18 cards, 1558 pixels, in a 912 pixel box at 1920x1080, so eleven on screen and SEVEN NOT, behind a 5 pixel scrollbar with no words anywhere saying the list continues. Hidden: the radio, the Pillbox, arranging the HUD, THE BULWARK AND ITS SLAB, contracts that judge how you played, the Mainframe, and Settings. The three it calls the ones that get people killed are above the fold and so is calling extraction, so a friend can still finish a raid; the Bulwark card is the one worth a life. Two columns rejected on measurement: halving the width doubles each card's height. FIX: a line under the list counting what is below, clickable to scroll a page, gone at the end, plus a 12 pixel scrollbar in amber for that list alone. The count is read off the rendered page so it survives the window size and his text size dial. Check opens the real card, requires the line to name the exact hidden count, requires the click to move the list and reveal a card, and requires silence at the bottom. Fails on a v10.68 fixture: the line does not exist |
| THE LOADOUT NUMBER COUNTS WHAT IS ACTUALLY GOING UP | v10.70 | the ascent panel reads LOADOUT with "Xc going up", which is the number he reads before deciding what to risk, and it was computed from the BACKPACK GRID. The grid is deliberately not the loadout: since v6.60 a copy claimed by a tactical belt key is taken out of it, on his own rule that an item is in one or the other and never both. So the header inherited the subtraction. REPRODUCED on v10.69 in the Undercroft: a medkit, a plate and a servo packed read 860c; move the medkit to key 3, which moves nothing out of the loadout, and it reads 650c, the medkit being worth 210. The safe pocket was never counted at all: a bandage worth 60 in it moved the number not at all, and the safe pocket is the one thing that survives death. FIX: the header counts the whole backpack including the copies on keys, plus the safe pocket. The three labels under it are untouched, because "Backpack N packed" is about the grid and is right. Check packs three items of different values, requires the total not to move when one goes on a key while the backpack count does, requires the safe pocket to add its exact 60, and carries a control that leaving an item behind still takes its value off. Fails on a v10.69 fixture naming both totals |
| THE SAFE POCKET TELLS THE TRUTH, AND MY v10.70 IS CORRECTED | v10.71 | the pocket NAMES one item key and one copy comes home if you die CARRYING it, which is v6.01's spec and right; it is a name for something in your backpack, not a slot of its own, and the deploy has always armed only when the named key is in the kit going up. THREE FAULTS. MINE FIRST: v10.70 added the pocket to the LOADOUT total. Measured, medkit plus plate 550c, plus a bandage worth 60 is 610c correct, NAME that packed bandage as safe and it reads 670c counting it twice, and name a bandage that is NOT packed and it still reads 610c counting something that stays home. Taken back out; the belt copies half of v10.70 stands. OLDER AND WORSE: the stash screen read 1/1 whether or not the named item was going up, because safeKey accepts it sitting in the stash, so a bandage in the stash with a backpack of medkit and plate reads armed and deploys with P.safeUp null. Reads NOT PACKED now, with the cell saying so in hazard red and a new safeUpKey answering "will anything come home" with the deploy's own test. THIRD: the ASCENT CHECK, which calls itself the last stop where everything can still be changed, never named the one thing that survives your death; its summary line now ends with named and packed, named but not packed in red, or no safe pocket. Check arms it three ways across both screens and the deploy, with a control that packing the item really does move the total by its own 60. Fails on a v10.70 fixture on the first assertion and on both totals |
| THE DEATH SCREEN COUNTS THE GUN IT SAYS YOU LOST | v10.72 | the KIA ledger lists what you carried, each line marked LOST, then sums it up; the guns were listed and left out of the sum, so the last line contradicted the list above it. REPRODUCED on v10.71: die with a Medkit, a Bandage and his own Scav Pistol, three lines say LOST, and the line under them says "2 items lost, $270 gone" while the pistol is worth 300. A gun is the most valuable thing carried, 300 for the Scav Pistol to 1,500 for the Auto Rifle against items at 60 to 340, so a friend dying with the welcome pack in his hands loses 2,000 credits of guns and reads a number with none of it in. FIX: counted in the same loop that prints the LOST lines so the two cannot disagree, valued with the same ival the bag uses, and named separately as "2 items and 1 gun lost" because a gun is not an item anywhere else in the game; the singular now reads "1 item". An ISSUED LOANER stays out of both and always did, carriedGuns skips issued kit and a death holding a Sputter lists no gun. Check drives two real deaths and carries a control that the same bag with and without his own gun differs by exactly the gun's value. Fails on a v10.71 fixture on all three assertions of the first arm |
| THE TITLE SCREEN USES THE MONITOR | v10.73 | his open note, "TITLE SCREEN WASTES THE SCREEN. His shot on a wide monitor: the whole thing is a narrow column in the middle with empty space either side". REPRODUCED on v10.72 at 1920x1080: the content runs x=427 to x=1493, so 1,066 pixels of a 1,920 pixel screen, FIFTY SIX PERCENT, with 427 pixels of nothing down each side, on the first screen anybody sees. CAUSE, one line: the column is capped at 820 and the only rule that widened it was gated on min-aspect-ratio 19/10, an ultrawide, so a 16/9 monitor missed it by a tenth and got the narrow-laptop layout. FIX: the cap follows the viewport with a floor, max(820px,min(1320px,62vw)). Everything here paints inside a zoom of about 1.3, so 62vw is what paints near 80 percent, and the 820 floor leaves every screen under about 1,320 exactly as it was. Measured 1920x1080 56 to 81 percent and 1366x768 78 to 81, both fitting sideways and downwards. The one block of prose is capped at 760 or widening the column turns two sentences into a single 1,496 pixel line. Check pins the display, forces 1920x1080, runs the game's own zoom fitter and measures the painted rectangle: at least 72 percent used, both edges on screen, no scrolling, and the opening sentence under 1,100 with a control that it has not collapsed. Fails on a v10.72 fixture naming 56 percent and the 427 pixels |
| THE WAY OUT OF THE RUN REPORT WAS BELOW THE FOLD | v10.74 | not his note: found measuring the run report the way v10.73 measured the title screen. REPRODUCED on v10.73 at 1920x1080 with a realistic full bag, ten packed and eight picked up, dying with the welcome pack's two guns: the card is 890 wide, 46 percent of the screen, and 1,078 tall, with 945 pixels of content in an 826 pixel box, so 119 sit below the fold and what is down there is the BUTTON ROW. LOG RUN AND RETURN at y1100 to 1144 and COPY REPORT beside it, in a card that ends at 1079. A friend who dies with a full bag cannot see the way out or the way to send me the report without scrolling a panel he has no reason to think scrolls, which on the alpha hides the whole feedback path. WIDENING DOES NOT FIX IT and I measured that before reaching for it: at 1,430 and at 1,625 wide the content is still 945 tall, because the ledger is one line per item however wide the box gets. The 86vh cap is right; what was wrong is which part scrolled away. FIX: the action row is pinned to the foot of the card with a fade, measured at 993 to 1038 inside a card ending at 1079. A card too short to scroll is unchanged. Check drives two deaths, full bag and one item, and requires both buttons inside the card at the top AND at the bottom of the scroll, with controls that the full bag really scrolls and the short one really does not. Fails on a v10.73 fixture naming the button and the pixels |
| THE CLOSING WARNING NAMES THE POINT THE MAP DRAWS | v10.75 | his one-word rule, broken on the two messages where the name matters most because they are the ones that make you change your plan mid raid. Every surface names an extraction point with a LETTER: the map draws EXTRACT A, B and C, the banner says EXTRACT B INCOMING, the inbound marker the same, all through extLetter. Two messages used a NUMBER, "Extraction 3 closes in two minutes" and "Extraction 3 is closed". REPRODUCED on v10.74 at seed 4242 on COLD STORAGE by running the raid clock to 200 seconds through the real frame loop: two points close, the map draws A, B and C with two marked CLOSED, and the message beside it says Extraction 3. Worse than untidy, because the closed-point message says "The open one is 326m away, marked on your map", so the game sends him to the map and then names something that is not on it. FIX: both call extLetter, which takes the zone rather than an index so it cannot drift from what is painted. Check runs the real clock through the frame loop, listens to what the game says, and requires every closure line to name a letter the map would paint, with a control that the first point really reads as A. Fails on a v10.74 fixture quoting the line |
| HIS TEN STASH LAYOUTS GET THEIR PICKER BACK | v10.76 | v7.66 was his order, "ten layouts and a button", and v7.72 he picked 6 as the default. v9.98 took the stash screen down to five things and the LAYOUT button went with the row it lived in; its own comment records the cost, "the arrangement stays at the default and the other nine rules in the CSS are inert". Nine of his ten have been unreachable since. MEASURED ON THE REAL GAME at 1920x1080 with a sixty item stash: layout 6 asks for columns at least 230 css pixels wide holding a 56 pixel icon, the stash grid runs 2,322 pixels of content in a 477 pixel box, THREE CELLS ARE FULLY VISIBLE AT A TIME, the only buttons on the screen are CLOSE, Sell all salvage and TAKE THE FREEBIE KIT, and there is no laybtn in the document. Looked at as well as measured: six enormous boxes each holding one small icon. FIX: the big cells are HIS PICK and stay; the CHOICE comes back, in Settings beside Text size rather than onto the screen he simplified, cycling 1 to 10 and wrapping and naming the one that is on. applyStashLayout stays the only writer of the attribute so the setting and the screen cannot disagree. Check requires the picker to exist and name the layout, reaches all ten by clicking and comes back round, then measures the grid at 6 against 7 for more columns and smaller cells. Fails on a v10.75 fixture: there is no picker at all |
| THE TITLE SCREEN FILLS A 4K MONITOR TOO | v10.77 | his note "game needs to be playable at 1080p, 1440p or 4k", and my own v10.73 fixed only the first. I wrote "1440p and 4K not verified" four builds running because I believed the test pane would not go bigger; it will, resizing the tab gives a real 2560x1440 and 3840x2160 viewport. MEASURED at 3840x2160 on v10.76: the title screen paints 45 PERCENT with 1,062 pixels empty down each side, barely better than the 56 percent v10.73 set out to fix, on the machine he tests on. CAUSE: everything paints inside a zoom and the zoom differs by resolution, so a fixed vw fraction cannot hold; raising the 1,320 cap fixes 4K and OVERFLOWS 1440p, measured at 2,745 painted on a 2,560 screen. FIX: the cap is computed from the zoom applyMenuZoom has just settled on, 80 percent of whatever screen it is, with the same 820 floor. After: 1080p 81 to 80, 1440p 67 to 80, 4K 45 to 80, all fitting both ways. ALSO, my v10.74 check could not run at those sizes: its control fires when a full bag does not fill the card, which is true at 1440p and 4K and is not the build failing, and it reported a FAILURE; it SKIPs now and names the screen height. Check requires 72 to 92 percent used and the cap to be within four percent of what the measured zoom needs, so a constant cannot pass. Fails on a v10.76 fixture at 4K |
| TWO WINDOWS CUT THEIR OWN CONTENTS OFF | v10.78 | swept all nineteen windows for the v10.74 fault. Two push content past their own box while the box is overflow hidden, so it is not below a fold, it is gone. MEASURED at 1920x1080 in css pixels: the Discount Fashion Depot 521 past its box, the ascent check 401. In the Depot that is SURPRISE ME at 412 device pixels below the window and all three LOOKS slots with their SAVEs at 499, 571 and 643, a whole feature from v10.16 nobody can use; on the ascent check it is sixteen rows including BEARD, EYES, FACE, BOOTS, GLOVES and BACKPACK, so half the operator cannot be dressed on the page that offers to dress him. A fresh character measures the same. No scrollbar, and the wheel cannot help because the handler only scrolls a box whose overflow is auto or scroll. FIX is the house rule from v5.31 and v8.76: the window holds still and the list inside scrolls. Both are built round the same two column grid, so the grid scrolls. After: 0 past the box, an 11 pixel bar, SURPRISE ME reachable, CLOSE and ASCEND unmoved. Check sweeps every window and then takes the Depot in particular, with a control that SURPRISE ME was not already in view. Fails on a v10.77 fixture naming both windows and both numbers |
| THREE GUARDS ONLY ASKED WHETHER A THING WAS DRAWN AT ALL | v10.79 | closes the STILL OPEN line "v8.99, v9.07, v9.08 and v9.15 are still numbers nobody measured". No game change; the whole build is in the harness. MEASURED at 1920x1080, DPR 1, seed 4242, map 0: the container search bar appearing moves 1,319 pixels against a floor of 0; the same bar filling from empty to half, 1,319 against 0; a noise ring at the frame it is born, 120 against 20; the standing extract prompt pulses 21.3 percent against 3. So a bar reduced to ONE pixel, a ring reduced to a fifth and a pulse reduced to a ninth all passed: three of the four were really "is it non-zero", which is v9.86's green-for-the-wrong-reason. FIX: one shared __FLOORS table carrying both the floor and the reading it came from, every floor at half its live value, and each message now names the reading and the floor so the margin is visible. v9.15 needed nothing, its thresholds are ratios against a screen that doubled and it greps the source for fixed radii. NEW CHECK v10.79 measures all four signals live and judges the floors themselves: each floor must sit under the live reading and above a quarter of it. Control: with no __FLOORS the fallback supplies the old 0/0/20/3 and all four quarter-strength assertions fire on a v10.78 fixture |
| HIS NOTE "NEEDS TOWN CENTERS" WAS ANSWERED BY CODE NO MAP CALLED | v10.80 | closes the STILL OPEN line "town centres from his map notes". TOWN SQUARE has existed since v6.92 carrying the comment "His note, verbatim: needs ... town centers. Guaranteed on every map, not pooled: a town has a centre or it reads as a warehouse district", and the word townsq appears exactly ONCE in the file, in its own definition. Guaranteed on no map, so the monument, six market stalls and two benches had never been built in the game; FLOODED PLAZA is idle the same way. Same fault as the v3.x MAPCONT constant. WHERE, measured per landmark as pieces surviving of nine and whether the monument stands: COLD STORAGE PACKING FLOOR 7 of 9 with its monument, best of five; on THE COLD MILE every landmark WITHOUT an archetype loses its monument to the lmCut rule, so the square must take over one of the map's three identical CARGO YARDS. MY FIRST CHOICE WAS WRONG AND MY OWN NEW CHECK REFUSED IT: SUMP YARD is the squarest at 2000x1700 and its centre is inside the water rectangle at 700,5900, all eight ways round the monument wet. Measured across all twelve mile landmarks, ways round the centre that are dry and clear: FROST YARD 8, BLAST FREEZER 7, PUMPWORKS 7, MANIFEST 6, BREAKER 6, OUTRAIL 6, GANTRY STACKS 3, COLD BLOCKS 2, COLD NINE 1, SUMP 0. THE FROST YARD is the only one open, dry and one of the three repeated yards, so it does both jobs; renamed THE FROST MARKET. COST, measured both ways: entities do not move at all, 85 and 374, crawlers 52 and 224; walls mile 2461 to 2440 and cold 616 to 623; containers mile 552 to 593, cold 165 unchanged and pinned nowhere. One pin moved, not the eleven I first wrote. NEW CHECK v10.80 requires every archetype the file defines to be built by some map, with plaza named as the one knowingly idle, then requires each square to be really in the world: a monument at the centre, at least four pieces round the rim, five of eight ways round the monument clear. Control: the two squares must be different places. Fails on a v10.79 fixture with "the archetypes no map builds are [plaza, townsq]" and "map 0 has no town centre on it at all" |
| HIS NOTE, THE OTHER HALF: DESTROYED BUILDINGS | v10.81 | closes the STILL OPEN line "destroyed buildings from his map notes". MEASURED FIRST: all 104 buildings across the two maps have a complete shell, 20 of 20 on COLD STORAGE and 84 of 84 on THE COLD MILE, every one a closed box with one or two doorways; not one has ever been destroyed. Ruins are NOT this and the file says so: "A collapsed building draws as a broken silhouette, never as a box with a door, because the whole point is that there is no way into it" - those are solid blocks in open ground. A wrecked building is one of the 104, still enterable and lootable, with whole runs of OUTER wall gone so it can be seen into and entered from any side. INTERIORS ARE LEFT STANDING on purpose: partitions carry a building id and the repair pass, the sealed-room pass and three checks all count them, so taking them out would move numbers those checks own for unrelated reasons; a blast that opens the outside and leaves the rooms is also the truer picture. NO RANDOM NUMBERS: the pass runs at the end of the map build after every roll and chooses by a hash of position, so CFG.bldgRuin 0 reproduces the old map exactly, and it only REMOVES geometry, so it cannot seal a room, bury a container or block a way out. Two runs of shell always stand. Never a building holding an authored strongroom. NEW CHECK v10.81 runs both arms on seed 4242 per map and requires: the dial off ruins nothing and moves neither entity nor container count; each ruined building lost perimeter, kept at least 12 percent of it and kept every interior wall; each untouched building is byte-identical; no strongroom building was opened. Control: the whole check is an A/B on its own dial, so with the pass absent both arms are identical; on a v10.80 fixture it fires "COLD STORAGE has no destroyed building on it at all; THE COLD MILE has no destroyed building on it at all; only 0 destroyed buildings across both maps". MEASURED: entities 85 and 374 and containers 165 and 593 identical either way, walls 623 to 610 and 2440 to 2403, 2 buildings and 13 runs torn open on COLD STORAGE and 7 and 37 on the mile, 2 buildings skipped for holding a strongroom. TWO MISTAKES OF MINE, both caught by measuring: the pass first sat ahead of the streak, window and lift passes, which all roll per wall, so the stream moved behind it and COLD STORAGE lost seven entities and gained ten walls; and a flat chance per building gave COLD STORAGE ONE wrecked building at every rate from 0.09 to 0.18, so the rate became a proportion with a floor of two |
| A DESTROYED BUILDING DID NOT LOOK DESTROYED | v10.82 | closes the Not verified line v10.81 shipped with. MEASURED on COLD STORAGE at seed 4242: the mean brightness of the floor inside the ruined building at 2980,1330 reads 124.76 with the wrecking dial off and 124.81 with it on, four hundredths of one percent, so the only thing saying a building had come down was the absence of some wall and from any distance it read as unfinished rather than fallen. FIX in bakeGround, which is painted once per raid: the interior goes darker and colder, a scorch gradient marks the middle, rubble blocks are scattered at a density scaled to the floor with a shadow under each, and dust spills out past the line the walls used to hold, because a ruin that stops at its own footprint reads as a floor tile. Every position and size comes from a hash of its own coordinates, so no rr() is drawn, the seeded stream cannot move and the same building has the same rubble every time. Paint only: no collision, sight or pathing change. MEASURED AFTER: the ruined floor moves 99.47 percent of its pixels and its mean falls 124.76 to 114.30; the standing building next door moves 0.08 percent and does not change brightness at all. NEW CHECK v10.82 runs both arms on both maps and requires every ruined building to move at least 45 percent of its floor and lose at least 4 points of brightness, every standing building to move under 3 percent, open ground away from any ruin to move under 3 percent, and the entity and container counts to be identical either way. Control: at least two ruins must have been found to look at. Fails on a v10.81 fixture with the ruined floors moving 0.1 percent |
| THE MAP COULD NOT TELL YOU WHICH BUILDINGS HAD FALLEN | v10.83 | closes the Not verified line v10.82 shipped with. A destroyed building is a tactical fact since v10.81, no cover on the missing side and open from any direction, and the map is where a route is chosen; it painted every building with one rule. MEASURED on COLD STORAGE at seed 4242 at 1920x1080, mean brightness of each building's square on the map: the two fallen ones 69.29 and 64.31, the seven standing ones in the same district 72.86 to 82.22. Gap to the nearest standing building 3.57 against a spread of 9.36 among the standing ones, so the ruins were only darker BY ACCIDENT, because fewer wall pixels land on them, and a difference smaller than the noise is not one a player can read. FIX: three signals, because a shade alone is what failed. The fill drops from .15 to .06 alpha so the shape reads as not solid, a diagonal hatch at a fixed 7 screen pixel spacing is clipped into it so the weight is the same on a small building and a large one, and the outline is drawn broken rather than continuous. TWO WRONG INSTRUMENTS BEFORE THE RIGHT ONE, and this is the finding worth keeping: brightness cannot judge it because the mile's standing buildings vary among themselves by 58 points, and counting edges cannot either because a busy rect full of walls and labels reads 49 where a hatched ruin reads 31. What isolates the mark is redrawing the same map with the ruined flags cleared. MEASURED that way: every fallen building moves 80.21 to 95.05 percent of its own square, every standing one moves exactly 0.00. NEW CHECK v10.83 requires every fallen building to move at least 40 percent and every standing one under 1, on both maps, with controls that something differed at all and that at least two ruins were there to look at. Fails on a v10.82 fixture, where clearing the flags changes nothing |
| HIS NOTE: A CRAWLER GOT CLOSE AND DID NOT HURT ME | v10.84 | REPRODUCED: a crawler inside a building, in chase with full alert, never comes within 97 units of a player standing outside and does zero damage in TWENTY SECONDS, while the same crawler in the open closes to 9.6 and kills in ten, and inside the same building closes to 9.4 and kills. The attack, reach, cooldown and states are all fine: it cannot get out, and the router says so, carrying pathFail for the whole chase. CAUSE: the routing grid is 16 unit cells with every wall inflated by 12, so a 64 unit doorway in a 16 unit wall keeps 40 units, two and a half cells, and anything that narrows it further seals on the grid a door that is open in the world. MEASURED at seed 4242, counting only buildings with verified open ground outside: COLD STORAGE 4 of 13, THE COLD MILE 15 of 59. MY FIRST CUT WAS WRONG AND THE HARNESS CAUGHT IT: carving map.nav itself also moved what the map PLACES, because navReach reads the same grid; counts stayed identical, which is what I checked, and v10.46 went red because the operator's jersey read 3 pale pixels against 21 with the scene around him moved. The build was withheld for a tick rather than shipped unexplained. FIX: map.nav is untouched and keeps deciding placement; map.navD is a copy with doorways opened and is what bodies route on, at both navPath sites and rebuilt when a wall comes down. A cell opens only where its centre is outside every wall with no padding. AFTER: 3 of 13 and 8 of 59, nineteen traps down to eleven, with entities 85 and 374, containers 165 and 593 and walls 610 and 2403 all identical and v10.46 green. NEW CHECK v10.84 drives a crawler out of every building on both maps, clearing the search cooldown each step so waiting is never read as failing, holds each map to its earned count, and controls that the two grids are different objects with different contents. STILL OPEN: eleven buildings remain traps, and building 3 on COLD STORAGE now finds a route and does not walk it, stalling at 73 units for thirty seconds |
| HIS NOTE: RANDOM HUMS THAT LAST WAY TOO LONG, LIKE AFTER YOU DIE | v10.85 | his 2026-09-04 note. FOUND BY COUNTING: the file creates 40 oscillators and stops 38, and the two never stopped are the ambient bed's 54 Hz and 81.5 Hz sines, joined by a looping noise bed, a weather layer and a 36 Hz dread sine. That is deliberate; a permanent bed is meant to be silenced by driving its GAIN to zero. THE FAULT: the only thing that drives that gain is tickAmbience, called from exactly one place in the whole file, inside the raid branch of the frame loop, and nothing else in the file touches AMB. When a raid ends that branch stops running, so the gain FREEZES at its last value and those five voices sound at that level through the outcome card, through the Undercroft, and until the next deploy. AND IT FREEZES LOUD: the target is 0.16 + 0.30 * threat where threat is 1 when something is on top of you, so the last frame of a raid you lose is the loudest frame, which is why dying is the way to hear it worst. FIX: ambienceOff() cuts all three ambient gains with cancelScheduledValues first, because the ramp written on the last raid frame otherwise pulls the gain back up, then a 0.12 fade against the live bed's 0.45 so it is gone in under half a second instead of never; called from the top of endRaid, ahead of everything that can throw. NO DIAL IS TOUCHED and no balance number moves. NEW CHECK v10.85 takes HIS RULE as its second half: it requires the bed to be cut exactly once on each of the three endings and never during ordinary play, and then requires the file's count of started-but-never-stopped oscillators to stay at the 2 the bed accounts for, so a sixth voice with nothing to turn it down is caught as the next hum. The needle is assembled at runtime so the check cannot find itself in the page. Control: with no cut hook the fallback reports the old build rather than skipping, and all three endings fire |
| HIS NOTE, THE OTHER HALF: THE HUM ALSO SURVIVES A PAUSE | v10.86 | his 2026-09-04 note said "like after you die, etc", and this is the etc, and it is the one most people will meet. v10.85 cut the ambient bed when a raid ENDS; this covers the pause. THE FAULT: the entire raid update, tickAmbience included, sits inside a branch gated on !G.paused, so opening the pause box means nothing writes those gains again and the bed holds its last level for as long as the menu is open. Pausing happens many times a raid; dying happens once. And it holds at whatever the room was, because the level follows the nearest hunting body, so pausing while something is on you leaves the loudest version of the bed running under a still menu. FIX: duck on the frame the pause opens, once and not every frame, and let tickAmbience ramp it back on its own when play resumes, which it does with a 0.45 time constant so the room returns in about a second rather than snapping on. NO DIAL MOVES; no balance number, entity count or map content changes. NEW CHECK v10.86 steps a real raid and requires: no duck during twenty frames of ordinary play, exactly one duck on the frame the pause opens, no further ducks across forty more paused frames, no duck on resume, the duck flag cleared so the next pause is armed, and a SECOND pause ducking again, because a build that ducked once per raid and never again would pass every other line. Control: with no cut hook at all the check reports the old behaviour rather than skipping, and fires on a v10.85 fixture |
| HIS NOTE: HOLD SHIFT TO SPRINT, NOT A TOGGLE | v10.87 | his 2026-09-04 note, and it REVERSES half of v10.07, which made crouch and sprint both toggles on his own answer 35 of 2026-09-03. He named SPRINT only, so crouch is untouched and stays a toggle. REPRODUCED before touching anything: press and release SHIFT with the operator moving and eight frames later G.sprinting is still true and G.sprintTog still set, because a keydown flipped a flag and the movement code read the flag as though it were the key. FIX: the keydown handler for SHIFT is gone entirely and updatePlayer reads keys['ShiftLeft'] or keys['ShiftRight'] itself; the pad already maps its left stick click onto ShiftLeft in the same keys object, so the controller needs no second path, and the crouch toggle no longer clears a sprint flag that does not exist. THE v8.73 EXHAUSTION RULE IS UNTOUCHED and is the reason this is more than deleting a flag: a held key that sawed sprint on and off 25 times in 20 seconds was cured by stamRelease, which requires a release and a fresh press, and that keys off the held state so it works identically for a real hold. NO DIAL MOVES: sprint speed stays 1.62, stamina cost, noise radius and footstep tempo are all unchanged; only what turns sprinting on changed. WHATSNEW line rewritten from "CROUCH AND SPRINT ARE TOGGLES" and WHATSNEW_VER moved 10.80 to 10.87. NEW CHECK v10.87 clears every latched key first, then requires: held SHIFT sprints, release stops it within eight frames, the right-hand SHIFT behaves the same, crouch still toggles and stays toggled twenty frames later and toggles back on a second press, an exhausted operator does not sprint on a held key, does not resume when breath returns without releasing, and does sprint after a release and a fresh press. Fails on a v10.86 fixture with "still sprinting eight frames after SHIFT was released" |
| HIS NOTE: DELETE FIRST TIME OUT ENTIRELY | v10.88 | "get rid of the 'first time out' menu/screen, delete it entirely, no more references to it, the player has to figure this shit out on their own", 2026-09-04. A REAL DELETION, not a stubbed function left behind: the window, its eighteen cards, the renderer, the under-the-fold cue v10.69 built, the scroll wiring, the never-show tick box, the close handler, the css for its list and its cue, and the three shipped WHATSNEW lines and three comments that named it. Thirty-two references to zero, asserted by the patch itself, which refuses to write unless the count is nil and the only surviving mention of the words FIRST TIME OUT is the BUILDING line announcing its removal. WHAT MUST NOT BREAK, and the reason this is not one big cut: firstRunNext is a CHAIN, welcome pack then consent question then card, so the call goes with the function rather than being left pointing at nothing; verified by driving a new character and getting the pack. THE TWO PROFILE FLAGS, primerOff and primerSeen, are never read or written again and stay harmlessly in old saves; nothing migrates because nothing depends on them. THE CHECKS GO WITH THE FEATURE in the same build, and not all the same way: v10.69 and v9.41 were entirely about the card and are RETIRED; v10.66 tested the pack then the handover and is TRIMMED to the pack, which still matters, plus a new line that the pack does not come back after a raid; v10.26 checked one word on four surfaces and keeps three; v10.10's window sweep no longer names a window that does not exist. The fixture's own __primer hook is gone because it called three functions that no longer exist. 224 checks to 222. No dial moves |
| HIS NOTE: X TO CHANGE WEAPONS IS NOT NEEDED ANY MORE | v10.89 | "X to change weapons i don't think is necessary any more given the hotbar, we can remove concept of x to change weapons", 2026-09-04. REPRODUCED: in a raid holding an SMG with a carbine stowed, one X press swaps them. WHAT GOES: the keydown handler, KeyX in the list of keys the page swallows so the browser cannot act on them, the bracketed [X] in front of the stowed gun on the HUD, and the two keyboard legend lines that taught it. Zero occurrences of KeyX left, asserted by the patch. WHAT STAYS, and this is the careful part: the swap FUNCTION has four other callers and every one is a way he still wants, dragging a gun onto the one in your hands, the hotbar bringing a stowed gun up, and two in the bot for pulling a sidearm when the primary runs dry and upgrading to a better gun found in a raid; deleting the function would silently take all four. The stowed gun and its ammo are still shown, minus the bracket promising a key that is gone. NOT TOUCHED: the controller, whose X is a face button meaning search through a different table; removing those legends would take search off the pad. ALSO FIXED, a leftover of the previous build: the legend still read "SHIFT sprint on/off" after v10.87 made it a hold. NEW CHECK v10.89 clears every latched key, then requires X to swap nothing, the swap function to still swap when called directly, no keyboard legend to teach swapping with a key, and the pad's X to still map to search. Control: it fails if no legend can be read at all. No dial moves |
| HIS NOTE, WITH A SCREENSHOT: TEXT COLLISION IN THE LOWER RIGHT | v10.90 | his picture shows SUPPORT MG, the biggest text on the HUD, with the green EXTRACTION - OPEN label drawn straight through it. CAUSE: that label is a WORLD label drawn at the extraction ring's projected screen position, so it goes wherever the ring is, while the gun name, the ammo and the stowed gun are HUD text pinned to the bottom-right corner and are NOT a panel, so nothing has ever known they are there. Stand with an open ring down and to the right and the two land on the same pixels. Four other world labels can reach the same corner: a locked door, the key it needs, a downed man and his timer. FIX: the corner readout measures itself as it draws and leaves its rectangle on G, 230 by 119 at 1920x1080 with a floor of 180 wide so a short gun name still reserves what the ammo line under it needs; every world label then asks one helper whether it would land there, and is LIFTED clear rather than hidden, because a marker you cannot see is worse than one an inch higher, and never lifted off the top of the screen. The box is one frame old on purpose and safe, because the corner text is pinned and only changes width when the gun does. TWO MISTAKES OF MINE: I first put the helper inside drawHUD, next to the local it reads, where it worked and was invisible to everything outside, and the check correctly reported the game had no dodge at all; and the wiring spy saw nothing until the operator was stood beside a ring, because a ring that projects off screen is culled before it can ask, and at the drop every ring is off screen. NEW CHECK v10.90 requires the corner to measure itself and to be where the readout is, a label dropped in it to be lifted clear of it, a label nowhere near it to be untouched, a tall label never to be pushed off the top, and, by replacing the helper with a spy for one frame, the real labels to actually ask. Control: a build with no helper reports his screenshot rather than skipping. No dial moves |
| HIS NOTE: THE RESIZE GRIP HAS NOWHERE TO DRAG TO | v10.91 | "corner drag to size for lower right corner needs to be in lower left side, otherwise there's nowhere to drag to increase size", 2026-09-04. REPRODUCED, every panel measured at 1920x1080: gear sits 8 pixels from the right of the screen and 5 from the bottom, cond 17 from the right, while body has 1374 to its right, legend 1445 and raiders 1529. The grip has always been the panel's bottom-RIGHT corner and the panel is sized by how much further the pointer gets from the OPPOSITE corner, so on the gear panel there were 8 pixels of travel and effectively no way to make it bigger. FIX, in his words: the grip goes on the corner that faces INTO the screen. A panel whose right edge is within a grip-width and ten pixels of the screen edge grips on its LEFT and is sized from its top-right; every panel with room keeps the bottom-right corner. ONE FUNCTION DECIDES and all four readers ask it: the mousedown that starts a resize, the drag that sizes it, the drawing of the diagonals, which are mirrored when the grip is on the left, and the cursor shape. Those four disagreeing is exactly how a grip ends up looking like it is somewhere it is not. NEW CHECK v10.91 walks every resizable panel and requires: a pinned panel grips left and a roomy one grips right, every grip has at least 120 pixels of travel before the pointer leaves the screen, the anchor is the corner the grip is not, a click just inside the grip is accepted and one on the opposite corner is refused. Controls: at least one pinned panel and at least one roomy panel must be present, or it is testing half a rule. Fails on a v10.90 fixture, which has no such function at all. No dial moves |
| HIS NOTE: THE PLAYER MARKER ON THE MAP IS TOO SMALL | v10.92 | "player marker on map sohuld be much larger, hard to see right now", 2026-09-04. REPRODUCED IN PIXELS at 1920x1080, map 0, seed 4242: the gold dot that is you was 43 gold pixels, 8 wide by 7 tall. TWO CAUSES: the disc radius was a flat 4 with a 5.6 ink ring and an 11 pixel heading line, and it was the ONLY marker on that map not multiplied by the map's own zoom, where the cache ring is (9+2q) times it, the encampment 5 times and the key 3.2 times, so on a bigger screen every other marker grew and his got relatively smaller. Measured on v10.91 at 2880x1620, zoom 1.5: 39 gold pixels became 41, a ratio of 1.05. FIX: disc to 8 and on the same zoom as its neighbours, ink ring to 11, heading line to 24 with a thicker stroke, plus a 15 pixel halo at 18 percent alpha underneath so the marker separates from whatever it stands on instead of relying on contrast it may not have. After: 203 gold pixels, 31 by 15, and 2.2 times the pixels at 2880x1620. NEW CHECK v10.92 counts pixels EXACTLY 255,192,74 at full alpha, which isolates the flat disc because the halo is 18 percent, the ring is near black and the 85 percent line over darker ground blends away from the exact value; it requires 150 pixels and radius 7 at 1920x1080, radius no more than 22 so much larger does not become a blot, and at 2880x1620 at least 1.8 times the pixels and 1.35 times the radius. Controls: the zoom must actually reach 1.4 at the larger size, and the operator is moved 600 units and the count must follow him while the old spot empties, which proves the gold counted is him. Fails on a v10.91 fixture on all four: 39 pixels, radius 4.1, ratio 1.05. No dial moves |
| HIS NOTE: THE UNDERCROFT TEXT IS TOO SEE-THROUGH, AND THE DEPOT IS NOW FASHION | v10.93 | "text in the undercroft should be less transparent/more opaque -- change 'Discount Fashion Depot' to 'Fashion' wherever it occurs", 2026-09-04. REPRODUCED, and the cause is not the one the note points at: the station names were dimmed TWICE, once by their own 75 percent alpha and again by being painted into the world BEFORE the room's darkness went over it, a full-screen rgba(14,12,36,.40) over the brightness dial with holes at the lamps. INSTRUMENT, because faint is not a number: draw the same frame twice, once with the names not painted, and difference; what is left in each name's rectangle is exactly the ink it contributes to the finished picture. Both draws use the frame call that advances nothing, so the lamps flicker identically. MEASURED on v10.92: average 78 of a possible 152 across eight stations, lift 67, cheat box 64; wind the brightness down so the sheet more than doubles and it falls to 49, a ratio of 0.63. FIX: the names are UI and not scenery, so the block is lifted into hubStationNames and called AFTER the light composite with the same camera handed to it, landing in the same place at the same size; text opaque #cfd8e2 in place of rgba(160,172,184,.75) on a .86 plate rather than .5, since a half transparent plate showed the floor through the letters. Two more see-through lines in the same room fixed: the controls line, rgba(140,152,163,.75), and the sub-line under each station prompt, #8a96a1. AFTER: average 169, worst 151, ratio 1.02 when the room goes dark. HIS SECOND HALF: the station, the racks window title, four new-in lines and the Settings line all say FASHION. NEW CHECK v10.93 requires 130 average ink, no station under 120, ratio at least 0.90, the racks station named FASHION, and no new-in line or window title carrying the old name; controls are that four names were found, that none painted nothing either way, and that the brightness dial actually darkened the picture by 15 percent. Fails on a v10.92 fixture on all of it. MY MISTAKE, caught by the new check on my own build: my announcement line spelled out the old name in order to say it had gone, which is the name still occurring; reworded. No dial moves |
| HIS NOTE 15: WEIRD EYE COLLISIONS ON UNDERCROFT FACES | v10.94 | "pillagers in the undercroft still have weird eye collissions on trhier faces in some instances", 2026-09-04. SOME INSTANCES cannot be answered by looking at a crowd of eight out of tens of thousands of looks, so it was answered by ENUMERATION: a new fixture hook draws one figure alone at nine times raid size, and the eye is located from the drawing itself, the whites being the one flat colour on a lone figure, so nothing in the check repeats a coordinate from the source. MEASURED on v10.93, percentage of the eye area painted over: faceplain 0, facescar 0, facefreckles 0, facemud 0, facepaint 65.9, faceshiner 51.4. War paint is two thin bars straight across both eyeballs so each eye reads as a sliver above a sliver; the shiner is an ellipse centred on the right eye and slightly larger than it, so the eyeball is washed purple. Twenty-eight rolls of the crowd's own generator, each measured against itself with the mark removed, put the worst at 63.9. FIX IS THE ORDER, NOT THE ARTWORK: a mark is on the skin and an eye is not skin, so the face-mark block moves to just before the eyes; paint still crosses the face, the shiner still bruises the socket, neither is over the eyeball. Nothing moved or was recoloured and no rack lost a look. AFTER: 0.0 on all six and 0.0 across the crowd rolls. NEW CHECK v10.94 enumerates the rack and 28 crowd rolls and allows nothing over 8 percent; controls are a magenta blot painted straight over both eyes which must read at least 80 percent, at least four marks on the rack, and at least three kinds of mark across the rolls. Fails on a v10.93 fixture with the exact numbers above. No dial moves |
| HIS NOTE 18: THE LOOT POP IS STILL THE WRONG FONT | v10.95 | "the loot text that pops on screen upon looting that tells you what item you got is still too bolded -- use the entire font across the entire game", 2026-09-04, his second time asking. REPRODUCED BY COUNTING: every text draw in a raid frame, its HUD, the map screen and four Undercroft frames traced and its font recorded. Almost all of it was already the game family in one of five roles, at three sizes because the HUD scale multiplies them. Three were not: the item name on the loot pop at 17.2px Titan One, PICKED UP and every other world label at 15.6px Titan One, and the faint district numbers baked into the ground at 114 to 244px Titan One. Titan One is the toybox display face the title wordmark uses; at fifteen pixels it reads as a slab, not a word. IT WAS NEVER A WEIGHT, IT WAS A SECOND TYPEFACE. WHY IT SURVIVED THE AUGUST PASS: the world label function measures and draws with a font string of its own, so it never went through a role and the sweep never reached it. FIX: the label measures and draws in the same roles as everything else, micro for the small one, which lands at exactly the 13 rendered pixels it already had, and label for the large one, which goes from 14.3 at weight 400 in a heavy display face to 15.6 at weight 600 in the game face. The ground numbers and the placeholder dash on an item with no portrait come across too. The only Titan One left is the game's own name on the title screen and the corner brand, which is a wordmark. NEW CHECK v10.95 traces every word drawn while the map is built, a raid frame and HUD are drawn, the map is opened and the Undercroft runs, and requires one family; it asks about the family and never the size, since one role shows at three sizes in a frame. Controls: the loot pop must actually have been drawn, found by a marker string the check plants; at least sixty words must have been drawn; and the tracer draws one word in a foreign face and must catch itself. The map is built INSIDE the trace because the ground is baked once and a check arriving later never sees it. Fails on a v10.94 fixture with thirty words in a second typeface. No dial moves |
| HIS NOTE 13: THE TWO CHOICES ON THE UNDERCROFT PAUSE SCREEN | v10.96 | "pausing at the undercroft screen should give an option to RETURN TO CHARACTER SELECTION that takes the player back to the title screen", then his own correction: "actually RETURN TO THE UNDERCROFT AND RETURN TO CHARACTER SELECTION should be the 2 choices", 2026-09-04. REPRODUCED with the box open on the floor and every visible button listed: ONE button, reading Back to the Undercroft, and no route from a running game back to the character screen at all; the only ways there were booting the tab and switching save, which reloads the page. FIX: his two buttons, in his words and his order. The first is the resume button relabelled, because closing the box IS returning to the Undercroft and a second button doing the same would be two controls for one act. The second puts the character screen back over the room, which is what booting does in reverse: no reload, nothing in memory thrown away, and the profile written to storage first so what he just earned shows on the screen he lands on. Hidden in a raid and while bleeding out, so a death cannot be walked away from. The front door is refreshed on the way back, since it is written at boot from the profile as it was then; rather than a second copy of that wording in the pause handler, the boot code hands its own two refreshers out through one file-scope hook. NEW CHECK v10.96 requires exactly two visible buttons carrying exactly his phrases, then presses the second and requires the screen to come up, the box to close, the screen to be DRAWN at 200 pixels or more of rendered height rather than merely marked shown, the start button to put him back in, and the save to be untouched in credits, raids and name. Controls: the character screen must not already have been up before the press, and the raid pause must still offer Resume and Abandon and must NOT offer the character screen. Fails on a v10.95 fixture: one button, neither phrase. No dial moves |
| HIS NOTE 12: A CONTRACT TARGET IS NOT SALVAGE | v10.97 | "anything that can be used to craft or for a contract, etc. should not be classified as salvage", 2026-09-04. REPRODUCED BY ENUMERATION against the tables that do the wanting: three items are wanted by something and were shelved as SALVAGE, described as "salvage, sell it" and cleared by SELL JUNK AND LOOSE SALVAGE. Servo Actuator and Optics Lens, both asked for by name on the contract board, and Data Core, asked for by the board AND burned by the mainframe for intel. CAUSE: the classification was a hard-coded list of five ids, correct about recipes and racks and blind to everything else, because the contract board's shopping list was a literal inside the contract generator where nothing else could read it. MY ERROR, CAUGHT BEFORE SHIPPING: my first pass said the servo is a live repair part again because kills wear a gun and addWear runs on every shot; addWear does run but WEARSTEPS has ONE band, so wearLive() is false and repairCost refuses every gun. The repair economy is dormant as v9.43 left it, and the repair answer is now gated on wearLive so the game cannot promise a use it will not honour; restore a second band and the servo becomes a repair part on its own. FIX: one function, itemWanted, answers what wants an item and why, by asking the recipe table, the rack costs, the repair parts, the mainframe and the contract board; the literals those lived in are named constants now. The stash shelf rule, previously trapped inside its own renderer, is a file-scope function. The sell button consults the same answer and a junk tag still overrides it. MEASURED: before, servo, optic and core all sell; after, all three kept and shelved under PARTS with the reason shown, while ten items including the Titanium Cell, Induction Coil, Bloom Sample, Meridian Reactor Core and Warden Core remain loose salvage and still sell. NEW CHECK v10.97 builds the wanted set from the tables and requires nothing in it is salvage or sellable; controls are at least six items wanted, the contract list readable at all, at least three items still loose salvage and sellable, and a junk tag still selling. Fails on a v10.96 fixture. No dial moves |
| HIS RUN REPORT: A CRASH ON THE CHARACTER SCREEN, AND IT WAS MINE | v10.98 | AND MY FIRST CHECK FOR IT RELOADED THE TAB AND MOVED HIS SAVE POINTER: pressing every button on that screen includes NEW PILLAGER, which writes a new active slot and reloads; it killed a corpus run and left the pointer on slot 4. It is skipped by name now, the pointer is restored in a finally, and a control requires the dangerous buttons to have been found under those names. From his flight recorder of 2026-09-04: "v10.96 error on hub x4: Uncaught ReferenceError: sub is not defined at psv.onclick". I DID THIS AT v10.96 and he hit it four times. Renaming your pillager also updates the name line under the title and did it with a third hand-written copy of that sentence, reading a variable named sub beside it; v10.96 wrapped that sentence in a function so the pause box could reuse it, which moved sub inside the function and left the rename button pointing at a name no longer in its scope. The name still saved, because saveProfile runs first, then the handler threw and the line never changed. FIX, the one v10.96 should have made: the rename button calls the same function everything else calls, one copy instead of three. A crash caused by two copies is not fixed by restoring the second. NEW CHECK v10.98 puts the screen up, types a name the fallback could never produce, presses SAVE and requires no throw, the profile to carry the name and the line to show it; then presses every other button on that screen except the three that leave it, erase a save or need a real gesture. CONTROLS: an error inside a DOM handler does not propagate to the caller, so the check listens on the window and then proves the listener by clicking a button that throws on purpose; and at least one button must have been pressed. Reports his exact words back on a v10.97 fixture. No dial moves |
| NOTE 17: NO PILLAGER HAS EVER WORN A HAT, A BEARD OR A TATTOO | v10.99 | Found at v10.94 while proving the eye instrument: the same rack, on the same call at nine times raid size, changed the operator by 31,978 pixels for headgear, 5,221 for the beard and 801 for the tattoo, and changed a pillager by ZERO. CAUSE: the block drawing her fringe also contains the tattoo, the beard and the headgear, and the whole block sits behind a hero-only branch; hair colour and cut are outside it, which is why the crowd looked varied enough to hide it for months. COST: the Undercroft crowd rolls all three for every member and none were drawn, while two lines of the new-in card promise the pillagers dress from the same racks he does. FIX: the branch closes after the FRINGE, the one thing in there that is genuinely hers; the other three fall outside and reach everybody, and each already read a pillager's look through st, code written for this and never once reachable. AFTER: headgear 32,557 on a pillager, beard 3,233, tattoo 1,418, operator unchanged. NEW CHECK v10.99 requires each rack to change a pillager, each to still change the operator so it cannot be passed by taking a rack off her, and the operator and a pillager in the same things to still differ by thousands, which is her fringe; plus a control that a full-body suit still overrules headgear. INSTRUMENT NOTE: standalone, six consecutive draws are byte identical; inside the corpus the FIRST pair differs by 621 and every pair after is exact, and I did not find what settles. Every number is now the SETTLED reading, the smaller of two back-to-back pairs, after which the noise floor reads 0 and the old build reports all three racks at exactly 0. Before that the drift was larger than the tattoo signal and the tattoo would have passed on a build drawing no tattoo. No dial moves |
| HIS NOTE 16: WEATHER IS A CHOICE, AND THE HARD ONES PAY MORE | v11.00 | "add weather conditions as a selection toggle in the 'Where are you going' screen", then the same day "choose more difficult weather shouild hive small xp boost like 1.1x". REPRODUCED: the sector page had SURFACE with DAY and NIGHT from v9.97 and nothing at all for weather; the weather was one seeded roll at the drop. THE INVISIBLE TRAP: pickWeather draws from the SEEDED stream, so skipping the roll when a weather is pinned would move every roll after it and silently change the map, the loot and the bodies. The roll ALWAYS happens; pinning replaces the answer, never the draw, and three pins on seed 4242 give identical entities, containers and walls. WHICH PAY IS DERIVED: hard means view below 1 or lights below 1, asked of the weather table rather than kept as a list, so rain, fog, blackout and storm pay and a state added later is priced by what it does. His 1.1x is the dial wxXp beside nightXp 1.2, both apply, so a hard night pays 1.32x, and the record carries wxHard the way it carried night. CONTROL: a WEATHER row under his SURFACE row in the same shape with the choice drawn amber; SURPRISE ME is the default and is the old behaviour exactly, and Partly Cloudy is reachable only through it because it exists to turn into another state. NEW CHECK v11.00 presses the buttons rather than writing the profile, requires the raid to come up in what was asked for every pinnable weather, requires the map fingerprint to be identical pinned or not, requires the four hard ones to count and clear and partly not to, and drives two identical runs through the real progress path requiring the XP ratio to be his number. Controls: a way to leave it to the roll, something to pin, a clear run paying something, and a bonus above 1. Fails on a v10.99 fixture. His dial, his number |
| HIS NOTE: THE FEEDBACK BUTTONS AT THE END OF A RAID ARE OLD | v11.01 | "change the feedback buttons at the end of a raid to something more current", 2026-09-04. REPRODUCED BY READING THE LIST, whose own comment dates it to v5.72: "the two music tags went where the music went. These two are the live unknowns instead: the Listener teaching was rewritten at v5.60 and nobody has tested it on a human". EIGHT of the twenty-four were one-machine questions from that era, Listener beatable and unfair, Pillbox worth it and a chore, Bulwark great and unfair, Howler great and unfair; all four machines still exist and he has logged dozens of runs against them, so those are answered by his own log rather than open. NOTHING from the last thirty builds had a tag: not the grid backpack, the hotbar, downed and crawling, the map screen, the Undercroft, the weather he now chooses, and above all not "this crashed" or "this looked wrong", the two things a friend cannot say any other way. WHY IT MATTERS NOW: his friends are about to play and a tag is the only feedback most people ever give. NEW SET of thirty, every one judgeable in one raid, opening with Something crashed, Something looked wrong and Sound was off, then readability, feel, what he carried, who was up there, the three newest systems, the place, and getting out. Old records keep their strings, a tag being just text on a run row. NEW CHECK v11.01 requires a way to say it crashed, looked wrong, sounded wrong and read badly; allows at most two of the eight v5.72 questions to survive; forbids duplicates and over-long labels and holds the count between twelve and forty; then deploys, ends the raid, presses two buttons on the REAL card, presses a third twice, presses the real way out, and requires the two on the logged run and the third absent. Controls: a button drawn for every tag, a way out of the card, and the run reaching the log. Fails on a v11.00 fixture with all five findings. No dial moves |
| HIS NOTE 8: WHY CHANGING SAVE LEAVES FULLSCREEN | v11.02 | "if i click fullscreen and then click to change the save, it kicks me out of fullscreen --why??", 2026-09-04. THE ANSWER IS NOT A BUG I CAN PATCH AWAY: clicking another save writes the slot pointer and calls location.reload, because the profile key is read once at file scope and the whole game is built from it; every browser drops fullscreen on a page load, and it cannot be re-entered on its own because requestFullscreen needs a user gesture and a gesture does not survive a navigation. TWO HONEST FIXES: switch saves without reloading, which means re-reading the profile in place and re-initialising every panel built from it, a deep change I am not making 55 hours from alpha; or stop it being a mystery and put the way back one click away. THIS IS THE SECOND AND I SAY SO. He gets a permanent line under the saves saying changing save reloads the game and that is why it leaves fullscreen, and, if he WAS in fullscreen when he switched, the title screen tells him on the way back with GO FULLSCREEN directly above. The flag is its own storage key, never the profile, since it belongs to the tab and not to a character and must survive a switch between two saves; read once, cleared once. NEW CHECK v11.02 requires the panel to say both reload and fullscreen; requires switching in fullscreen to be remembered and switching outside it to be remembered as nothing; requires the line to appear once, clear its own flag and be gone next boot; and controls that it never fires while he is already in fullscreen. Fullscreen cannot be entered by a check, so the check makes the game believe it is and restores the real answer after. Fails on a v11.01 fixture on both halves. MY CHECK BUG, FIXED SAME BUILD: the missing-memory guard used a return and threw away the panel finding already recorded, so the old build reported half the defect. STILL OPEN FOR HIM: whether he wants the deep fix, switching saves with no reload, which is the only thing that answers his question with a no |
| HIS NOTE 14, FIRST HALF: A CHARACTER YOU CAN GIVE BACK | v11.03 | "when friends give feedback the game should also log their character info -- that way if they lose their character accidentally, we can give them a code to restore it", 2026-09-04. REPRODUCED by reading what a report carries: one summary line of runs, extracts, deaths, best haul, credits, XP, racks, pack, notoriety and stash SIZE. That is a description, not a character; nothing says what they wore, what is in the stash, what they unlocked or their contracts standing. WHY THE CODE IS SMALL: cosmetics are not stored as an owned list, cosOwned DERIVES them from runs, extracts, level, warden kills and the season board, so the code carries those numbers and the worn ids plus anything bought outright; the stash goes in as counts by key; the run log stays out, being the biggest thing in a profile and history rather than identity. CARRIES: name, credits, XP, level, runs, extracts, deaths, best, notoriety, pack, racks, arrays, contracts standing, season tiers, kill tallies, cosmetics bought, junk tags, chosen map, surface and weather, every worn cosmetic, and the stash as counts. One line at the end of every report under a heading. NEW CHECK v11.03 builds a character from values the fallback could never produce, then requires the code in the real report, requires it to name itself, and reads back twenty-three fields exactly. Controls: an empty string, an ordinary sentence and a corrupt code must all be refused, and the code must FOLLOW the profile, checked by changing the credits and requiring the new number, because a reader echoing a fixed object would pass everything else. Fails on a v11.02 fixture. APPLYING IT IS THE NEXT BUILD, behind a typed confirmation |
| HIS NOTE 14, SECOND HALF: PASTING THE CODE BACK IN | v11.04 | v11.03 wrote a RESTORE CODE into every report and could read one; a code nobody can apply is a note in a bottle. Settings, recorder tab, under the report: paste, READ CODE, typed word, REPLACE. IT IS DESTRUCTIVE AND SAYS SO: reading decodes and states in words whose character it is and what it is worth, then a typed word, then the replace; nothing is written before the word, and the contents are on screen before he types it, so a wrong paste is caught by reading rather than by losing a character. KEEP MINE backs out. WHAT IT DOES NOT DO: restore the run log, which is history, is not in the code, and would be a lie in the one place that must be trustworthy; and an item id that no longer exists is dropped rather than resurrected, since a stash key with no row reads undefined in every panel. THE RELOAD IS ARMED, NOT FIRED, and it mattered twice: the page reloads 400ms after, because the floor was built from the replaced profile, and the wait is for the profile WRITE, which can be a promise on a host that provides storage, where reloading first would lose the character just restored. A timer is invisible to a check and would have fired mid corpus and reloaded the tab, so the arming is recorded where anything can read it and the handle kept where a check can cancel it. NEW CHECK v11.04 makes a distinctive character, takes its code, becomes somebody else, then drives the real door: reading writes nothing, REPLACE does nothing empty and nothing on the wrong word, the right word brings back twenty-two fields including two of one item and one of another with the old stash gone, a reload is armed, and the log is untouched. Controls: rubbish must not open the door and must be called rubbish on screen, the word alone with nothing pasted must do nothing, and KEEP MINE must close and disarm. Fails on a v11.03 fixture |
| HIS QUESTION: IS A DAYTIME BLACKOUT ACTUALLY HARDER? NO, AND MY v11.00 PAID FOR IT ANYWAY | v11.05 | "is a daytime blsackout meaningfully harder than normal daytime play?", 2026-09-04. ANSWER: no, and at two times of day it is literally nothing. Lamp brightness is wx().lights * (isDay() ? tod().lights : 1) and the times of day carry 0.7 at dawn, ZERO at 8am, ZERO at noon, 0.25 at 6pm, 1 at dusk; blackout multiplies by 0.18, so at 8am and noon it is zero times 0.18 and the lamps it kills were already off. AND LAMP BRIGHTNESS FEEDS TWO THINGS IN THE FILE: the lit percentage in the recorder and the glow the lamps draw. Nothing in vision, concealment or machine AI reads it, so a blackout is what a HUMAN can see, real difficulty for a person and none for the bot. THAT MAKES MY v11.00 WRONG: it classed a weather hard if it cuts sight OR kills the lamps and paid his 1.1x, so in daylight it paid for killing dark lamps. FIX: killing the lamps counts only when the lamps were on, measured as a real loss of at least 0.15 of the scale, so a blackout pays at night, dusk and dawn and pays nothing at 8am and noon; cutting SIGHT is untouched. The sector page stops promising a bonus it may not deliver and says the daylight case depends on the hour. THE CHECK IS v11.00's, SPLIT BY WHAT THE WEATHER DOES: rain, fog and storm hard whatever the hour; blackout hard at night, hard at dusk, NOT hard at noon. Controls: the build must have something that asks how much lamp light there was before the weather, and the time of day table must actually carry zero at noon and full at dusk, asked of the table rather than remembered. Fails on a v11.04 fixture. NO DIAL MOVED: what a blackout does is unchanged, on his standing order |
| HIS NOTE 20: THE BALLER'S JERSEY IS BEHIND A BLACK BLOCK | v11.06 | "micheal jordan character, can't see his jersey bc its blocked by a black block (maybe supposed to be backpack straps?)", 2026-09-04. NOT THE BACKPACK: the pack is drawn before the torso and the torso covers it. MEASURED, one baller at nine times raid size, every painted pixel in a 125x130 chest box by colour: red 3,222, the jersey's own black side panels 2,384, shadowed red 1,602, white of the 23 1,582, ink outline 1,506, chest rig band 882. The panels alone were 74 percent of the red, 2.4 wide each on a 13 wide chest, thirty-seven percent of the shirt in near-black, which at sprite size reads as straps. Under them the chest rig is a near-black band the FULL width of the chest drawn immediately after the jersey, straight across the lower half of the numeral. FIX: panels 2.4 to 1.4, trim rather than block, and the jersey drawn AFTER the rig so the 23 sits on top of it. AFTER: white 1,582 to 2,735, a 73 percent gain; red 3,222 to 3,661; black 2,384 to 1,994 and its ratio to red 0.74 to 0.54. The black fell less than the width did because that colour appears elsewhere on the figure, which is worth knowing before reading too much into it. NEW CHECK v11.06 finds the chest from the drawing using the jersey red as the marker, then requires 2,000 pale pixels of numeral and a black to red ratio no worse than 0.62; controls are that a figure with no jersey produces almost no jersey red and few pale pixels. Fails on a v11.05 fixture with both findings. AND v10.46 MOVED WITH IT: it wanted 8 ink pixels of panel at raid scale, a floor calibrated on the block he complained about; widening the art back would be fitting the game to the test, so it was measured again, red +58 pale +24 ink +4, and the floor is 2, half the live reading. No dial moves |
| HIS TWO REAL RUNS, 2026-09-04, AUTHENTICATED AND CONSUMED | v10.98 | Run #1 v10.96 COLD STORAGE, fog at dawn, 59s, EXTRACT 2,685c from ONE container, 6 items, 18 shots at 67 percent, 4 crawlers killed, 1 down, revived twice by raiders and three revives total, 2 walls down, 1 story read, contracts haul and kill-crawler, moved 7,594, sprint 14s, crouch 0s, closest extract 1m, ents 105. Run #2 v10.96 COLD STORAGE, clear noon, 13s, ABANDON carrying 460c and 3 items, no shot fired, moved 1,181, closest extract 96m. Both real: real durations, real distance, a named weapon, no fixture signature. Profile after: 2 runs, 1 extracted, 0 died, credits 395,700 which is the cheat box, XP 343, stash 4. HIS 13 SECOND ABANDON IS UNEXPLAINED and is a question for him, not a defect I can measure |
| TWO CHECKS DISAGREED ABOUT THE SERVO | v10.97 | Caught by the full corpus. v9.43 requires the servo to be SELLABLE because there is no repair to keep it for; v10.97 requires it KEPT because the contract board asks for it by name. Both right about their own premise. v9.43's real subject is the REASON and not the shelf, which its own message says: it was written when a dead repair economy was the only thing keeping the servo. It asks about the reason now and fails if the servo's KEEP line mentions repairs while the wear table has one band. Its sibling assertion, that the servo is not a crafting part, and every control around it, are untouched and still pass. No dial moves |
| FOUND BY THE v10.96 CHECK: A PRIMED ABANDON SURVIVES THE PAUSE BOX CLOSING | v10.96 | The control asserting the raid pause box still offers a way to abandon PASSED alone and FAILED on the full corpus, reporting RESUME RUN and NO, KEEP PLAYING. Not a corpus artefact: Abandon run does not abandon, it ARMS, becoming NO, KEEP PLAYING and revealing a red YES, ABANDON THIS RUN beside it, which is the right shape for an irreversible act; but the only thing that disarmed it was pressing Resume. Close the box with Escape while armed, the fastest way anyone closes anything, and the arm is still there next time it opens, one click from ending a raid he came back to finish. A check twenty places earlier had armed it and walked away, which is exactly what a player does; the leak between checks was the leak in the game. FIX: opening the box disarms it, always, through one function both the open and Resume call rather than two copies of the same four lines. The v10.96 check now arms the button on purpose, closes the box, reopens it and requires the confirm to be gone; that assertion also fails on a v10.95 fixture, so the bug predates this build. No dial moves |
| ~~STILL OPEN, measured at v10.68: two fifths of the briefing is below the fold~~ | CLOSED at v10.69: the card counts what is under the fold, says so in a line that scrolls the list when clicked, and goes quiet at the end; the bar for that list alone is 12 pixels | measured on the REAL game at 1920x1080 from an empty browser, not on a fixture. FIRST TIME OUT holds 18 cards in 1558 pixels inside a 912 pixel box: 11 are on screen and SEVEN ARE NOT. The scrollbar is 5 pixels wide and nothing anywhere says there is more, so a new player has no reason to think the card continues. What is hidden: the Undercroft radio, the Pillbox that never chases you, arranging the HUD, THE BULWARK AND ITS SLAB, contracts that judge how you played, junk building the Mainframe, and Settings being a station. The three the card itself calls the ones that get people killed are all above the fold, and so is calling extraction, so this is not fatal; the Bulwark card is the one that costs a life. Two columns does NOT fix it: halving the width roughly doubles each card's height. The fix is a cue that names how many are below plus a scrollbar wide enough to see. Not built yet |
| STILL OPEN, from v10.40: niches plugged by furniture | OPEN | on THE COLD MILE a cells or spine plan sometimes leaves a pocket of interior floor behind a piece of furniture, 12x12 to 84x28 units, one per building on 13 of 15 seeds; the coarse repair cannot see anything narrower than 40 units. Cosmetic for a player; a fine detection with a size floor and the furniture layer would clear them. Not the sealed-building fault, which is closed |
| ONE WORD FOR THE BACKPACK, AND THE HOTBAR RENAME FINISHED | v9.90 | v9.89's own Not verified line said the compact legend still called the backpack a bag. Read off every surface on v9.89 the thing you carry was named FOUR ways: "inventory" (full legend TAB row, controller VIEW row, the HUD hint "TAB  INVENTORY", two refusals), "bag" (compact legend, controller BACK row, "equip gun from bag", the armour rule card, five spoken lines, the Peddler's "SELL BAG", a searched pillager's "'S BAG", two guide cards, a settings hint), "kit" (three refusals "Kit is full"), and "backpack". And both controller legends still called the hotbar a BELT, which v9.89 missed. THE WORD IS BACKPACK, his word and the panel's. Twenty two strings, nothing that reads a profile or draws. Left alone on purpose: BAG OF FRAGS and BIGGER BAG OF FRAGS, which are Progress rewards and a literal bag, and the lore clipboard "Inventory, year one", a document in the world. The armour card line is 29 characters against the 32 it replaces, inside the box v8.4x measured. Check reads the compact legend, the full legend, the HUD hint, the controller table and the panel headings, needles from halves, and fails on a v9.89 fixture on all four surfaces at once. Ten of the 22 strings are proven on screen; the other twelve are spoken lines the harness has no cheap way to raise |
| ONE WORD FOR THE HOTBAR | v9.89 | his rule, one word per thing, and his open line "I opens the BACKPACK, write the matching list of consistent definitions". On v9.88 the same nine keyed cells were named THREE ways to the player: "hotbar" in the legend, the bag hint, the item detail and his own answers 11 and 22; "Tactical belt" on the raid backpack heading and the Undercroft column heading, "your backpack plus your belt" under the raid backpack title, "off the belt and into the backpack" on the drag-off message, and "hotbar belt and inventory" on the ascent summary; "the bar" in the empty-slot prompt. THE WORD IS HOTBAR: his word, the legend's word, the keys' word. Six strings changed, nothing that reads a profile or draws. Belt stays inside the code, the raider-and-snitch trade. The vocabulary memory gains a section for what you carry. The check reads the surfaces as rendered text with needles assembled from halves, and fails on a v9.88 fixture on five surfaces at once |
| HIS ANSWER 22: THE HOTBAR IS VISIBLE IN THE UNDERCROFT | v9.88 | four words of his, between two other floor answers, and it had no row in the status table. v8.96 claimed it in its own comment and delivered it only INSIDE the opened backpack. MEASURED on v9.87 through the real loop on the HUD canvas: backpack closed, 0 opaque pixels on the entire HUD canvas; backpack open, 9 belt cells and 100,047 opaque pixels in the bottom band. FIX: drawHubBelt draws the same file-scope drawBelt against a transient hubBagState swapped in as G for one call, only while the backpack is closed, so exactly one belt is ever on screen; hubBagG is deliberately untouched because closing the backpack is the commit. Cells recorded on HUBBELT for the fixture and for a future click. Display only: editing stays in the opened backpack, answer 11. hubBelt 0 is the control. Check fails on a v9.87 fixture with "with the backpack closed the floor records no belt cells at all" |
| HARNESS LESSON, from the tick before: the hub frame draws the world only | v9.88 | __hubFrame calls drawHubWorld and nothing else; the bag, the belt and the drag ghost are drawn on the HUD canvas (hcv, ctx) by the MAIN LOOP after it. A probe that reads the world canvas through the hub frame reports zero pixels for things that are there. Read on hcv through __loop, the drag ghost paints 1,764 pixels. Any Undercroft drawing check must drive __loop and read hcv |
| CHECKED, ALREADY DONE: two of his STILL OPEN lines | v9.88 | the extraction screen line reads "Next: <tier>, reward N of M, X XP away. Claim it at the Mainframe." and is omitted on a death screen on his v8.91 note, so "x of Y XP does not say what happens at Y" is satisfied. ESC on the Undercroft floor opens the pause box, measured with a real keypress. Both struck through in the table |
| HIS NOTE: THE MUSIC WAS TOO FRIENDLY | v9.87 | "music needs more of a dark and low tone -- it sounds too friendly -- game is supposed to be post-apocalyptic". Nobody here can hear it, so read back what every piece SCHEDULES with the fixture's dry recorder. On v9.86 the tune of all five pieces averaged 73 to 76 (MIDI, C5 is 72) and peaked at 81 to 84, the arpeggio lifted a note to 79 in every group, the lowpass sat open at 3200, two pieces ran at 120 and 130, and THE LAMPLIGHTERS was written in C major and called "bright and walking" in its own comment. Three of five were already in minor keys and it did not help: register, filter and pace are what the ear takes as mood. FOUR LEVERS under one dial, musDark: tune and arpeggio an octave down, the arpeggio's octave lift removed and it quietened, the lowpass 3200 to 1500, and a 100 bpm cap that slows only the two fast pieces. THE LAMPLIGHTERS is played in its relative minor at play time, C to Am, F to Dm, G to Em with the bass roots re-rooted 36/29/31 to 33/26/28, table untouched. AFTER: every tune down exactly 12, arpeggio ceiling 79 to 55, bass unmoved, note counts per voice identical. The check reads all of it back and fails on a v9.86 fixture naming every piece; musDark 0 restores the old register as its own control. WHAT IT SOUNDS LIKE IS HIS TO JUDGE |
| CLOSED, his answer 11: hotbar with the backpack open, all three parts | v9.87 checked | "dragging OFF the belt back into the backpack works only in the Undercroft": the raid side shipped at v9.31 and the Undercroft side at v9.82. "The dragged item is also invisible in the Undercroft": NOT REPRODUCED at v9.87. Driven with a real mousedown on a bag cell and a real mousemove to open floor, through the real loop, reading the HUD canvas: 1,764 pixels change under the cursor and the label "Frag Charge" is drawn. drawHubBag has painted the ghost since v8.96. MY ERROR on the way: my first probe read the WORLD canvas through the fixture's hub frame, which never draws the bag overlay, and reported zero pixels; the ghost is drawn on the HUD canvas by the main loop |
| CALLING THE SHIP CALLED OFF WHATEVER WAS HUNTING YOU | v9.86 | from the raid audit, listed and never worked: "beacon investigate overwrites the Listener's hunt, never applied to the beacon". REPRODUCED with a Listener in hunt and a sentry in alarm, staged well away from the ring so neither can re-acquire by sight, then E held on the pad: the Listener went to INVESTIGATE and was sent to 862,2485 with the player at 850,2530, and the sentry went to investigate too. The Listener hunts by SOUND, so once knocked off there is nothing to re-acquire from and the hunt is simply over; it is the one machine the game says punishes moving badly, and pressing E switched it off. CAUSE: the beacon wakes everything within 2200 and writes state='investigate' on all of it, while the noise waker six thousand lines up has always had the rule "pull in the idle, never overwrite something already on you". FIXED IN TWO PLACES because the pull runs every frame and would re-cancel it on the next one. The idle are still pulled and every alert still raised |
| MY ERROR, same build: my first guard was inert for the machine the finding named | v9.86 | I wrote state!=='chase' and measured no change, because a Listener does not use 'chase': it hunts in 'hunt', and a sentry with the alarm up sits in 'alarm'. My first staging also put a CRAWLER on chase and it kept it, which looked like the fix working; it kept it because it had eyes on the player and re-acquired every frame. The file already spells out chase-or-alarm-or-hunt by hand in four places; it is one function now, called by both beacon sites |
| SUPERSEDED, recorded so nobody works it: "the three in-raid panels are too small" | v9.86 | his v8.88 note asked for the pillager board, the legend and the conditions panel to be twice as large. AT v9.66 HE ASKED FOR THE OPPOSITE for two of them, "current pillagers and conditions should be smaller in the hud compared to the other stuff", and they were measured as the two largest on screen and cut. Only the legend is still short of the old target, 1.5 against a nominal 2.0, and he has not repeated the ask. Also stale in the same block: 'EXTRACT CACHE' should be called 'ELITE CACHE', which was done at v9.19 |
| MY ERROR, WITHDRAWN BEFORE IT SHIPPED: "the beacon promises half the machines it sends" | v9.85 stands | I built v9.86 on it: the beacon says "about 3 machines" and I had measured six arriving, so I made the promise count the ship's hold as well and every setting agreed to the machine. THE FULL CORPUS FAILED IT. The v9.34 check, which drives the REAL loop instead of ticking the siege by hand, said the call promised 14 and 7 arrived. It was right. Traced on the real loop: the siege spawns THREE, all during the 25 second beacon, and STOPS the moment the ship lands; spawned sits at 3 from twenty seconds to sixty. My probe drove __extract.tick by hand with the hold never engaging, so it ran a siege for eighty seconds that the game ends after twenty five. I measured an artefact and corrected the game to match it. REVERTED. Consequence for v9.85: what it changed is still right and the v9.34 pairing check stayed green, but its quoted arrival figures describe the same artefact and must not be cited as what a raid delivers |
| NOTHING FOUND: his "too many footsteps when sprinting" does not reproduce | v9.86 | measured on the floor with the real footstep code: 2.2 sounds a second walking, 3.2 while actually sprinting, 1.6 crouched, and sprint is stamina limited so ten seconds of holding shift averages 2.5. The sprint interval equals the rate the game already uses for a machine chasing you. Tested the burst theory too: tapping movement gives FEWER steps than holding it, because the free step on restart costs less than the time spent stopped. The stutter he reported before, sprint flicking on and off as stamina refilled, was fixed at v8.73 |
| HARNESS: the fixture could not see a single sound | v9.86 | it REPLACES tickPlayerSteps with an empty function and stubs blip to a no-op, so no check has ever been able to observe the player's footsteps or count any sound. The stub now records what it was asked to play and __blipCount reads it back; __setSteps(__stepsReal) puts the real footsteps back. I lost several probes to a silence that was mine, not the game's |
| HEAVY EXTRACTION HEAT WAS WORTH ONE MACHINE, OR NONE | v9.85 | closes the three rows v9.84 left verified only as far as the number arriving. HITS is honest: 20 damage lands as 28/24/20/14 through the real damage path. CLOCK is honest: 900/540/360 reach timeLeft and raidLen. EXT IS NOT. Laid a real siege at a real ring and counted arrivals: Heavy 6 and 15, Standard 6 and 14, Light 4 and 8, for a light bag and a full one. Light is a real choice; HEAVY BUYS ONE MACHINE WITH A FULL BAG AND NONE WITH A LIGHT ONE. CAUSE, and it is v9.84's cause in a second place: siegeVol raises a CEILING and the ceiling is not what limits a siege, the arrival interval is, one every 8-4.6*greed seconds, and the window has room for about six. Raising the cap 6 to 8 changes nothing; lowering it to 4 bites, which is why Light worked. FIX: the dial scales the RATE as well, in both the tick and the beacon announcement so the promise and the arrivals stay in step. After: Heavy 8 and 20, Standard 6 and 14 UNCHANGED, Light 4 and 8 unchanged. Check fails on a v9.84 fixture with "15 against a standard 14, under a quarter more" |
| THE MACHINES SETTING ONLY MOVED HALF THE MACHINES | v9.84 | swept all eight settings rows for his standing "make sure all the modifiers work" item. All 24 options write the CFG keys they claim. Driven to a WORLD consequence, seven rows are honest and this one is not: at seed 4242 sentries read 21/16/10 for Many/Standard/Few and CRAWLERS READ 52/52/52 on COLD STORAGE and 224/224/224 on THE COLD MILE, seed 99 the same at 47/47. Crawlers are most of what is out there, 52 of 73 machines on cold storage, and the row's hint calls the machines what usually kills you, so Few was buying eleven fewer sentries. CAUSE: HIS 5's per-house crawler count is a raised-only FLOOR, houses times crawlerPerHouse, and that floor lands above all three counts the row offers so the row never got a word in. FIX: the row owns the per-house rate too, 3.4/2.5/1.5, the same ratio its counts carry. After: 70/52/32 and 300/224/140, with STANDARD UNCHANGED at 52 in 85 entities and 224 in 374. Check fails on a v9.83 fixture printing the flat rows |
| CLOSED, was named unknown in the full-file audit: nRaider 0 producing an empty map | v9.84 | measured on both the spawn and after 120 simulated seconds: Other pillagers set to None gives 0 raiders at spawn and 0 after, so v8.42's raiderWaves:0 does hold. The four options give 10/7/3/0 at spawn for counts of 15/10/5/0 |
| MY ERROR, same build: my first settings sweep reported a false failure | v9.84 | it said the extraction-heat row could not write raiderWaves:1. My loop reset the CFG between options but NOT P.gameOpts, so the pillager row was still on None from an earlier iteration and v8.74's "None means none" line was correctly forcing raiderWaves to 0. Re-run with the profile cleared per option: all 24 options write their keys. The probe was wrong, not the game |
| THE CONTROLS LEGEND DID NOT GO WHERE YOU DRAGGED IT | v9.83 | REPRODUCED with the gesture at 1920x1080: drag the legend bar 80 right and 150 up and the game stores dx 78.75 dy -151.2 correctly and moves the panel 120 right and 0 UP. It remembered the drag and ignored half of it, so the offset sat in his profile doing nothing forever. TWO CAUSES: vertically, v8.91 pins the legend bottom just above the vitals by measuring last frame and translating, and that correction cancels any dy the panel computes for itself, every frame; horizontally, drawLegend added dx in its own unscaled space and the panel is then scaled 1.5 about x=0, so 80 pixels of hand moved it 120. FIX: the drag is recorded in screen pixels so it is applied in screen pixels, one translate outside the zoom, both axes, riding on top of the anchor instead of fighting it, with dx and dy removed from inside drawLegend. Clamped against last frame's rect to keep 70 pixels on screen and the clamp written back to the profile. After: 80 and -150 exactly. Check fails on a v9.82 fixture naming both halves |
| ~~STILL OPEN, measured: the raiders board runs ahead of the cursor~~ | CLOSED at v10.42, struck at v10.67: both panels now divide the drag by their own zoom and clamp in that space, 100 for 100 | same family as v9.83 but a different panel: a 100 pixel drag moves the CURRENT PILLAGERS board 113, its own 1.15 zoom, because the offset is applied inside the panel and then scaled. body and gear track 1:1 and are correct. The conditions panel moves only 13 of 40 horizontally because it is anchored to the right edge and clamped against it. Neither is as bad as the legend was, which could not be moved at all |
| NOTHING FOUND, three of his items are already correct at v9.83 | v9.83 | ROLLING IN THE UNDERCROFT, his report three times: it WORKS. SPACE sets rollT 0.38, the operator draws as a disc 46x51 with fill ratio 0.78 against a perfect circle's 0.785, and he travels 43 units. I IN THE UNDERCROFT: opens the backpack, not the terminal, and closes on the same key. THE HUD DRAG OFFSET applied differently in drawing versus hit testing, named as unknown in the full-file audit notes: draw and hit agree to the pixel on all five panels at 1080p, 1440p and 2160p. The legend fault above is drag versus DRAWING, which is a different pair |
| HIS REPORT, CLOSED: items would not come off the tactical belt into the backpack | v9.82 | REPRODUCED with the gesture first, at 1920x1080 with a Frag Charge on belt slot 5: the ghost appears so the drag really starts, the release really resolves to kitcol, and NOTHING happens, with no message and no clank, so it reads as a broken drag rather than a refused one. CAUSE, one line: the backpack column handler opens with if(from!=='stash') return, so a drag off the belt arriving as plan:5 is dropped on the floor. IT IS THE MISSING HALF OF v8.72, which made the belt cells drag sources and taught only the STASH to catch what came off them; the same gesture to the stash works today, which proves the gesture and the harness. planPut always pushes into P.kit when it claims a slot, so a belt item is already going up and the backpack list just hides one copy per binding: the move is one thing, release the key, no capacity change. After: key 5 clear, item still in the kit, backpack drawing the cell, counters 1 packed and 0 on keys. The check drives the real gesture and reads BOTH ends off the page before running it; on a v9.81 fixture it fails naming his symptom |
| MY ERROR, same build: the new check passed alone and SKIPPED in the full run, and I guessed twice | v9.82 | first guess, the belt is drawn TWICE by hotPlanHTML() and hotPlanHTML('stage') so querySelector can take the wrong cell: true, worth fixing, NOT the cause. Second guess, a stale menu zoom: not the cause. MEASURED by running the 86 checks that precede it and dumping the page instead of running it: hub on, viewport 1920x1080 alive, exactly one belt cell at the right place, and the element under its centre is `outcome`. AN EARLIER CHECK LEAVES THE EXTRACTION CARD ON TOP, and showScreen cannot clear it because it only closes .modal.on and the outcome panel is not a modal; the title screen keeps its on class too. Staging now closes stagemodal, sectormodal, outcome, title and pausebox first, takes the cell that is on screen, and the failure message NAMES what is covering the cell instead of saying it could not aim |
| AND MY FIX FOR IT POISONED THE NEXT CHECK | v9.82 | closing those panels cleared the skip and broke v9.58, which measures the fullscreen button on the title screen and read 0x0 because I had just shut it. The harness poisoning itself in the direction I had not thought about: a check that CLEANS the page owes the same duty as one that dirties it. Every panel this check closes is now recorded before it opens the Undercroft and restored on every path out, skips included |
| CORRECTION, mine: the check named for his symptom was testing a different gesture | v9.82 | the v8.72 check called itself "an item can be dragged OFF the Undercroft belt and back into the backpack" and its failure line said "after dragging it to the backpack". IT DRAGS TO stashgrid and asserts the item is NOT in the kit and IS in the stash, which is the it-stays-home path and the opposite of going into the backpack. That is why his report sat open and unreproduced for builds while the corpus was green: the one check named for his symptom was passing on another gesture. Assertions untouched because they are correct for what they measure; name and message corrected. Belt to backpack is now the v9.82 check |
| THE SAME FAULT IN A THIRD PLACE: reconcileWindows kept even less | v9.81 | it squares a window against the solid wall behind it by cutting that wall into three, and wrote each piece as {x,y,w,h,d} plus win, dropping ib, _bw, lockWall, lm, furn, wreck, tree and ledge. The ray caster then demotes the middle back to solid when it cannot clear the sight line, so the usual end state is three ANONYMOUS FRAGMENTS in a room. Paired fixture survey by wall index at seed 4242, geometry moved 0, walls 616/2461 and ents 85/374 identical in both arms: 8 walls on COLD STORAGE and 7 on THE COLD MILE got their identity back, of which 4 stood inside building 10 and 3 inside building 7, plus 2 yard walls per map that had lost lm and 3 sticks of furniture on the mile that had stopped being furniture. ASKED OF THE GAME OWN wallHp AND penFactor through new fixture hooks: 8 walls 700 hit points to 320, 3 furniture 700 to 60, and those 3 went from bulletproof to rounds passing at 0.55. 700 is the terrain number. A piece is now a clone of the source wall with new geometry. The check tests the RULE, not the function: no wall inside a building footprint may carry no identity, and none may answer 700 indoors; it fails loudly on a v9.80 fixture naming all seven walls and returns null here |
| CORRECTION, mine: the v9.79 control was counting pieces and the count was a lie | v9.81 | it required MORE lm pieces with the cut on than off, which sounds right and is not. Measured on v9.81, the mile: 66 pieces cut against 82 uncut, and the check failed. Not a regression: with the cut OFF the yard walls run through the houses, lie across their window walls and reconcileWindows chops them into fragments, 28 short pieces off against 16 on, and every fragment used to LOSE its lm flag, holding the off arm near 62. v9.81 gave it back so the off arm legitimately reads 82. Rewritten to ask about LENGTH, which is the actual question: the mile keeps 14648 of 19489 units of yard wall (75 percent) and cold storage 5801 of 6543 (89 percent); the missing quarter IS the span crossing a house. Floor set at 60 percent, measured not remembered. Passes on a v9.80 fixture too, so it is not build-specific |
| CUTTING A WINDOW INTO A WALL MADE IT BELONG TO NOBODY | v9.80 | carveWindows replaces one wall with three and wrote x,y,w,h,d,win,_bw, DROPPING ib. repairInteriors only removes walls carrying a building id, so a carved partition could never be removed by it however badly it sealed a room: the identical hole the yard walls had, sitting in a second place the whole time. Measured at seed 4242: 25 ownerless carved interior walls on THE COLD MILE and 7 on COLD STORAGE, and building 9 (760x520, authored cells) reporting an empty floor. The three pieces now inherit what the wall was. Partitions correctly owned 214 to 292 on the mile and 62 to 82 on cold storage, entity counts unchanged, windows all still there |
| DEAD END, recorded so nobody re-treads it: the small-building plan picker | v9.80 | the picker lists 'open' twice of four for small footprints and 27 of 84 mile buildings share the one small footprint, which looked like the cause of "maps feel samey". IT DOES NOT RUN: the plans are AUTHORED in the map data, 33 cells, 16 core, 16 open, 8 spine, 7 lsplit, 4 pinwheel, matching the built map exactly. The 16 empty boxes on the mile are a content decision and his to keep or change |
| CORRECTION, mine: two of the four "unmeasured thresholds" were not thresholds | v9.80 | v9.08's k<12 and v9.15's f<12 are frame-loop counts, not gates. Of the real ones, v9.07's noise ring gate is MEASURED at last: a ring at birth changes 120 pixels against a threshold of 20, six times the margin, so that gate is sound |
| THE WHAT-IS-NEW CARD WAS SIXTEEN BUILDS STALE | v9.80 | the v9.19 check caught it the moment drift passed its limit: the card read v9.64 against a build at v9.80, still describing the Listener and the bandage cap and saying nothing about being able to rewrite the game's own words. Rewritten newest first across the text editor, the buildings, the surrender, the low health flash, the extraction call and the crawler cap |
| CORRECTION, mine: the v9.78 blocker was not what I said it was | v9.79 | I reverted v9.78 believing a newly reachable container distracted the spotter. Driven properly: a looting pillager WITH a container goal 3,663 units away spots the player at 225 and chases inside 45 frames. Being busy is irrelevant. THE REAL CAUSE: the spotter's sight is 187 and the stage puts him 300 out. With the cut off the first man in the crew list sees 302; with it on a different man is first and sees 187. Third time this week a stage has stood a man beyond his own eyes and I read the silence as a bug. Fixed by giving the spotter's post to the man with the best eyes, moving no distances |
| v9.29 RESTATED, not weakened | v9.79 | it demanded stations add 40 degrees over stations-off, which is right where off is single file, and off measured 14 on the stage it was built against. On this map off measures 109 and on measures 148, so it was calling a crew arriving 148 degrees apart single file because the gap was 39. It now asserts the property he asked for, that the furthest man is at least 40 degrees off the spotter, and keeps the comparison with full teeth wherever the control shows single file |
| THREE OLDER CHECKS PINNED, because this build fixes the cause they mitigate | v9.79 | v9.72's partition peel and v9.73's locked-room exemption both had nothing left to rescue once the yard walls stopped sealing buildings, and read 0 against 0. Both now pin lmCut OFF so they still test their own layer in the world it exists for. v9.77's "the world did not move" compared its dial on against off, which stopped being a fair question once a second dial landed in the same pass, reading 374 against 372; it now asserts the shipped fingerprint of 374 outright, which is the stronger statement |
| A CHECK THAT HAD BEEN ASKING A MAN THE IMPOSSIBLE | v9.78 | v9.25 stands the player on a clear bearing and fires one round to prove a pillager fights back. Three faults, found one at a time: it checked the LINE was clear but never that the GROUND was open, so rounds came from inside a wall; then it stood him at 400 when the man sees 259; then, inside sight, he still would not fire because he carries a RIOT SCATTERGUN and was being asked from 212 units. Sight was never the binding constraint, reach was. The ladder starts at 110 now, inside every weapon and every pair of eyes at once. Verified green on v9.77 too |
| HIS NOTE, second time asked: get rid of "first seen" on the KIA/extracted screens | v9.70 | v8.68 took it off the extracted card and left the death card printing two clocks. The v3.08 comment above it argues for ONE figure, how long the fight had been going; first contact was the evidence for printing that, not a second column. Still recorded, still what the duration is measured from |
| HIS QUESTION: why does it say "still on your feet" under contracts in the raid | v9.70 | because nothing on the panel said what it belonged to. Six of the seven conduct notes name their subject; that one was a compliment, and its BROKEN form already said "you went down", so the rule was invisible only while he was keeping it. Now "no downs yet", the shape of the two rows above it |

STILL OPEN, and this is now the whole list:
- THE BUILDING DEMOLITION, HALF CLOSED AT v9.72. The partition strip is no longer
  all-or-nothing: it peels only the walls next to the unreachable pocket, up to
  four times. THE COLD MILE 16 demolished interiors down to 12 and 171 interior
  walls up to 180, COLD STORAGE 2 down to 1, entity counts identical. WHAT IS
  STILL OPEN is the other half and it is worse: 8 buildings on the mile are still
  sealed AFTER the whole pass, all 8 flagged repaired, two of them with 110 and
  144 unreachable interior cells. Their interiors were destroyed for nothing.
  Every wall within 24 units of the four worst is an UNTAGGED SHELL wall, so
  their doors are bricked by neighbouring geometry, and the pass never re-floods
  after the blanket strip so it cannot see this. Needs shell segments tagged with
  their building id before a doorway can be punched safely. The old stub-wall
  attempt stays reverted; this is a different fix.
  WITHDRAWN AT v9.73, it was my error: that segment was a WINDOW carved into a
  solid wall, 68 units by chance from rnd(52,84), and building 6 was a false
  positive of my own ruler. THE REAL CAUSE IS LOCKED ROOMS, fixed at v9.73: the
  repair pass counted the floor of an authored, named, key-opened strongroom as
  unreachable and demolished the whole building's interior for it. Mile 12 to 10
- and a correction: v9.48 says 45 of 84 buildings share the same footprint, 54
  percent. Wrong, and mine: I bucketed sizes to the nearest 40 and reported the
  bucket as an exact size. The real commonest footprint is 300x220 at 27 of 84
- the nine canvas checks other than v8.85 and v8.89 have had six clean runs each
  in one sweep and nothing more. Six runs is evidence, not proof, and none of them
  has had its thresholds read the way those two now have. v8.99 ned<60,
  v9.07 heardPix<20, v9.08 k<12 and v9.15 f<12 are still numbers nobody measured
- SOMETHING CONTAMINATES A FULL FRAME when decals are pushed. Ruled out: the
  threshold, the camera, a background animation (a null pair taken at the same
  moment agrees exactly), and the game itself (30 hidden spots for footprints and
  24 for ripples, zero leaks at any of them). v8.85 and v8.89 now refuse to report
  a number they cannot reproduce, so it shows as a SKIP rather than a false
  finding, but what draws those pixels is unknown
- the footprint repetition itself: 54 percent of the buildings on THE COLD MILE
  are the same 320x240 box and not one building on either map carries an
  archetype. v9.48 painted them differently; it did not change their shapes,
  because moving building geometry moves every container and spawn on the map
- town centres and destroyed buildings from his map notes (hills, verticality and
  woods stay vetoed)
- FOR HIS RULING: the raid punishes time spent rather than value carried
- FOR HIS RULING: the extraction squeeze barely happens on THE COLD MILE, which
  has 6 rings and closes 2, against COLD STORAGE which has 3 and closes 2

COULD NOT REPRODUCE, said plainly. "Wrecked cars read as suitcases from directly
overhead" was rebuilt at v1.64 and the rebuild is in place and working: four
wheels proud of the body on both sides, a hood, cabin and boot stepping along the
long axis, and 209 of the 487 wrecks on THE COLD MILE standing vertical against
278 horizontal, so they are not all lined up like luggage either. Looked at on
screen as well as measured. If they still read wrong to him it is a contrast and
scale question, not the silhouette that note describes.

## HIS NOTE, 2026-09-03 about 16:45 (machine clock): AN ALPHA FOR HIS FRIENDS

Verbatim: "i want to ship an alpha build of this game to my friends in 72 hours from now -- what do we need to do to get there?"

Deadline by that clock: 2026-09-06 about 16:45. Facts checked at v10.36: DEV_LOCAL is true only on localhost, so the cheat box and the local telemetry drop switch off on itch by themselves; BETA_ONE_MAP is true; PUBLIC_DROP is null, so on the web every second raid downloads a run file into the player's Downloads with no explanation; there is no window.onerror catcher; the publish zip is rebuilt every build (tools/PUBLISH.md). The proposed order is in the report of this tick and in memory (pillagers-alpha-in-72-hours).

## HIS NOTE, 2026-09-03 about 19:15 (machine clock): NIGHT DENSITY

Verbatim: "night mode should have more enemy density since it pays better"

Queued as the next build after v10.47 commits: a night density dial on the machine counts, measured day against night at seed 4242 and by the bot over paired seeds.

## HIS NOTE, 2026-09-03 about 19:20 (machine clock): COSMETICS IN THE DEPOT

Verbatim: "some of the cosmetics look bad, atleast in the discount fashion depot (didn't test in other screens) -- freckles collide with eyes, scar collides with eyes, beard stubble is too high, collides with eyes -- shoes should be separate from pants"

Queued as the build after the night density: the face marks and the stubble measured against the eye band on the sprite at the Depot's scale, moved clear; the boots drawn as their own shape below the trouser line.

## HIS NOTE, 2026-09-03 about 19:30 (machine clock): COLLISION BEHIND THE TERMINAL

Verbatim: "WEIRD COLLISION IN UNDERCROFT, ONLY HAPPENS WHEN PLAYER IS BEHIND THE TERMINAL", with two screenshots of the lift terminal (ENTER RAID!): in one the operator has walked behind the kiosk and is drawn mostly hidden by it, a sliver of hat and pack showing at its edge; in the other he stands in front of it and all is well.

Queued as the build after the Depot cosmetics fix: measure the terminal's collider against its drawn footprint and the draw order behind it; the operator should not be able to stand inside the kiosk's footprint, and if he stands behind it he should read as behind it, not swallowed.

## HIS NOTE, 2026-09-03 about 19:40 (machine clock): UNLOCK ALL COSMETICS IN THE CHEAT BOX

Verbatim: "add something to the dev cheat menu to unlock all cosmetics" and "make it toggleable so if someone cuts it on they can cut it back off"

Queued after the terminal build: a switch in the DEV CHEAT BOX, ALL COSMETICS ON/OFF, that makes every rack read as owned while it is on and gives back the earned state when it is off; nothing is written into the earned counters, so switching it off loses nothing and grants nothing.

## HIS NOTE, 2026-09-03 about 19:45 (machine clock): COLLISION AND RUNNING IN PLACE IN THE UNDERCROFT

Verbatim: "weird collission and running-in-place behaviors are happening in the undercroft"

Folded into the terminal build (v10.51): a sweep of the operator across the whole floor in the fixture, recording every spot where collide() holds him while the keys move, against the drawn geometry (walls, pillars, stations, the crowd). Running in place is the walk cycle advancing while the move is cancelled by an invisible blocker.

## HIS NOTE, 2026-09-03 about 19:50 (machine clock): THE EDITOR IS OFF FOR FRIENDS

Verbatim: "(and obviously when we ship beta we should disable this feature bc we don't want friends modifying in game text)"

Folded into v10.49: the Edit the words switch is his machine only (DEV_LOCAL), and the dial is forced off anywhere else, so a friend on itch never sees the editor.

### HIS NOTE, 2026-09-03 about 19:40 (sound): "also work on improving sound whenever you get a chance -- guns, footsteps, robots, etc -- everything should sound unique and crisp like a triple-A game"

Standing order, not a single build. Every sound the game makes is synthesised
in the page (no files), so "unique and crisp" means one recipe per gun, per
surface underfoot, per machine, with attack, body and tail that differ; not
one bleep with a pitch dial. Queue: audit what each event schedules now
(v2.48 taught that a sound can test green and never play, so the check is
what the play path schedules, never the ear), then rebuild them one family
per build: guns first (each gun its own voice), footsteps by surface (the
fixture stubs tickPlayerSteps; restore before measuring), then the machines
(crawler, sentry, the Listener), then hits, containers, UI. He is not asked
to judge until a family ships.

### HIS NOTE, 2026-09-03 about 19:50 (outfits): "add some fuill-body outfits to the cosmetics that overrule everything else -- like a skeleton, a robot, and a halo spartan"

A new cosmetic slot, OUTFIT, above every other slot: when one is worn the
painter draws the suit instead of skin, hair, beard, face marks, coat, legs
and boots (hats and the mask are the open question; a helmet is part of the
suit). Three to start: a skeleton (bone on black), a robot (plate and joints,
one eye light), and an armoured trooper with a visored helmet (his word is
spartan; the game's own design, not anyone's licensed suit). Each is a rack
item in the Depot, earned like the rest, and the ALL COSMETICS cheat toggle
(his 19:40 note) must cover them. Queued behind the terminal plinth fix and
the cheat toggle, because the toggle is how he will try them.

### HIS NOTE, 2026-09-03 about 19:55 (outfits, more): "2b from nier automata, lara croft, micheal jordan, 2pac"

Four more for the OUTFIT slot. Two are licensed characters and two are real
people, so the game gets its own versions of what they stand for, drawn by
its painter and named in its own words: an android in a black dress and
visor, a tomb explorer in a tank top with a braid and twin holsters, a
baller in a red jersey and shorts, and a rapper in a bandana and vest. No
licensed suit, no real person's face or name.

### HIS NOTE, 2026-09-03 about 20:00: "'Search Crate, 1 Item left -- this text is too small"

The container prompt in the raid. Queue: measure the label's rendered size at
1920x1080 against the HUD scale rule (v10.4x) and raise it to the body size.

### HIS NOTE, 2026-09-03 about 20:00: "sprint footprint glitch is still happening"

"Still": a fix shipped earlier and did not take, or fixed the wrong thing.
Queue: find the earlier footprint fix in DESIGN.md, reproduce the glitch on
the play path with the live stepper (the fixture stubs tickPlayerSteps and
the sim never draws prints), then fix the cause, with a control.

### SOUND AUDIT, 2026-09-03 (from his 19:40 note): what the game plays today

All audio is one synth, blip(type,d,pan,arg), lines ~3417-3823, 26 hand-written
recipes, no shared envelope, no compressor or limiter, no master or SFX volume
(BUS gain is a literal 1). Music has its own chain and plays only in the hub.
- GUNS: 16 weapons, an FV table of 13 voices inside blip('shot'); magnum and
  sniper have no entry and fall back to the rifle, so the two loudest guns are
  the mid rifle. pistol/tacker, smg/sputter, shotgun/scuttle differ only by a
  lowpass corner. Fixed pitch, no randomisation. No reload, dry-fire, or jam
  sound exists at all.
- FOOTSTEPS: tickPlayerSteps ~3134; five surfaces (stone, wood, metal, leaf,
  water) in an SF table, fixed cadence (sprint .31, crouch .64, walk .45), the
  only randomness is the metal ring. Enemy steps are two recipes (step,
  stepHeavy) with no surface at all, one nearest enemy only.
- MACHINES: VOICE table ~3354 (sentry servo, crawler skitter, snitch drone,
  warden hydraul, listener dish, raider clank); bulwark has no voice; no enemy
  death sound (clank only when the corpse is over 620 away); enemy hit = the
  player's own hit sound.
- OVERLOADED: pick (~70 sites: loot, doors, heals, every menu click), clank
  (~35: grenades, roll, ricochet, refused action), alarm (spotted, siege,
  touchdown, clock warning, nuke), hit (dealing and receiving), boom (frag,
  howler, nuke, the player's death), charge (six telegraphs).
- BUG: sfx('cache') at ~31285 and ~31380 names no recipe and plays nothing.
Plan, one family per build: guns (own voice per gun, pitch jitter, reload and
dry-fire), then footsteps (jitter, enemy surfaces), then machines (death, hit,
bulwark), then the overloaded four split by event. Verified by what the play
path schedules (oscillator types, frequencies, durations), never by ear.

### HIS RUN #12, 2026-09-03 19:43, on v10.50 (exports/consumed-run-20260903-194358.txt)

Real: install 4gm5qv8ul7y5, his profile of 12 runs. EXTRACTED, the first of
the twelve: Chatter (owned), 105 s, haul 1100c, 11 items from 7 containers,
49 shots at 47 percent, one crawler and one elite killed, no downs, crouch
17 s, sprint 19 s, COLD STORAGE in rain at golden hour, ents 80. No crash
section, no text edits, no feeling tag. His two notes at 20:00 (the crate
prompt too small; the sprint footprint glitch) come from this run: 7
containers searched and 19 s of sprinting. Answered by v10.52 and v10.55.

### HIS NOTE, 2026-09-03 about 21:20: "pillagers still glitching into walls in the undercroft"

The Undercroft crowd, not the operator: the errands (v8.07) and the pacing
walk a body toward its target with no wall push, so a walker clips the
piers, the counters and the lift housing. His v10.51 note was the operator
behind the terminal; this is the other bodies. Queue: reproduce by stepping
the room and counting crowd positions inside any HB.walls rect, then give the
crowd the same collide against HB.walls the operator has, and a check that
walks every errand and finds nobody inside a wall. Goes ahead of the
remaining sound builds; his notes outrank the queue.

### HIS NOTE, 2026-09-03 about 21:25: "trailing noise is way overdone"

Heard on the play port, which serves the working copy with v10.56's gun
voices: the tail (the room answering the Magnum, the Longshot and the
Lance) is too loud and too long. Queue, next build: tail gain from 0.35 to
0.12 of the crack, length from 1.6 to 1.1 of the crack, lowpass 420 to 320;
measured by the recording context (tail gain and buffer length).

### HIS NOTE, 2026-09-03 about 21:25: "when i find a gun it should go to the next open slot, not kick my scav pistol out of slot 1"

A gun found in a raid is equipped into slot 1, replacing whatever was there.
It should take the first EMPTY weapon slot (slot 2 when slot 1 holds the
pistol), and only when both are full go to the bag, or replace the current
slot. Inventory: full corpus. Queue after the tail and the crowd.

### HIS NOTE, 2026-09-03 about 21:27: "trailing noises need to be much shorter, i can hear them wayy later"

Same complaint, sharper: it is length, not only level. The Longshot's tail
is 12,160 samples (a quarter second) at 0.35 of the crack, the pump clicks
land at 0.28 and 0.42 s after the shot, and the louder crack rings the room
reverb longer. v10.58: tail shorter than the crack and at 0.10 of it, the
big cracks themselves shorter, every action click inside 0.30 s. The check
requires no node to start later than 0.30 s after a shot and no buffer
longer than 6,000 samples.

### HIS NOTE, 2026-09-03 about 21:30: "wheb ny characterr stands behind a wall they change color lol"

The v9.27 see-through pass in a raid paints the operator through a wall as
a flat light-blue cutout at half alpha, coat #9fd8ff and no hero racks, so
behind cover he turns blue. The Undercroft pass (v10.51) already uses the
hero racks. Queue, v10.59: the raid ghost is the real figure, his own coat
and racks, faded, so behind a wall he looks like himself seen through it.

### HIS NOTE, 2026-09-03 about 21:32: "its not clear to me how to melee or if i can at all"

Melee exists only as bare hands: with Bare Hands equipped the trigger
punches (v7.61). With a gun in hand there is no strike at all and nothing
on screen says so. Queue: a melee strike while holding a gun (a butt
stroke on a key, short range, the fists damage, a noise), the legend and
the pause controls saying which key, and the first-raid coaching line
naming it.

### HIS NOTE, 2026-09-03 about 21:32: "if a howler is outside, he shouldn't be able to bomb inside a house"

The Howler's shell lands wherever the target point is, roof or no roof.
Queue: a shell aimed at a point inside a building bursts on the roof:
no damage to anyone under it, the burst drawn on the roof, and the Howler
prefers not to fire at a target it cannot see under a roof. Check: a target
inside a building takes zero damage from a shell aimed at it; the same
target outside takes the full shell.

### HIS RUN #13, 2026-09-03 21:33, on v10.57 (exports/consumed-run-20260903-213337.txt)

Real, and his best raid yet: EXTRACTED with 11,675 credits, five minutes
seventeen, Marksman Rifle from his own armoury, 23 items out of 11
containers at 1,061c a container, 50 shots at 66 percent, two sentries,
seven crawlers and a snitch down, one elite. Two downs and one revive by a
crew mate, 25 hit points regenerated, two caches found, storm at noon on
COLD STORAGE, extraction called once with two missed, out with 2 metres to
spare. He also shot a stray: notoriety is 1 now, which is the rule working.
No crash section, no text edits, no feeling tag. Nothing in it contradicts
a shipped build; the profile is 13 runs, 2 extracted.

### HIS NOTE, 2026-09-03 about 21:50: "undercroft music needs to be darker and gloomier, feels too happy"

The hub theme only: music plays in the Undercroft and never in a raid
(musicWanted returns false whenever a raid exists). Levers already in the
file: HUB_THEME's own notes, musDark (lowpass 1500 dark against 3200
bright, tempo capped at 100 bpm, lead and arpeggio down an octave, the
relative-minor swap in DARK_CHORD and DARK_BASS), and CFG.musicVol at 0.17
of full. Queue: take the hub theme itself down, slower and lower, minor,
fewer bright voices, and verify by what tickMusic SCHEDULES (note numbers,
tempo, filter corner), never by ear, the same way the gun and footstep
builds were verified.
