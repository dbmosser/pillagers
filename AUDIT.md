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
| Extraction screen: the "first seen" line is cheesy, remove it | |
| Extraction screen: "x of Y XP" does not say what happens at Y | |
| Extraction screen: "Claim it at the board" should read "Complete contract at mainframe" | |
| Extraction screen: why is there no proficiency rating | |
| Extraction screen: "the Mainframe, 4 racks fenced the data" should read "Mainframe bonus: $XXX", moved to the bottom in a dimmer colour, it is not that important | |
| Cannot move items from the tactical belt to the backpack in the Undercroft | his report, not yet reproduced |
| Remove crafting of purple, blue and gold strength guns; they should only come from the Peddler or raid loot | |
| Superhot mode: remove the text "moving the mouse to aim is free" | |
| Make sure all the modifiers in the settings menu work as intended | a sweep, not one item |
| INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both | a model change, affects the belt assignment map |
| Too many footsteps when sprinting | his report, not yet reproduced |

## HIS QUEUE, updated end of v8.68

DONE in v8.68: EXTRACTION IN PROGRESS wording; superhot hint; "Complete contract at mainframe"; first-seen line removed; "Nearest extraction is Xm away" on the downed screen.

STILL OPEN:

| Ask | Note |
|---|---|
| Extraction screen: "x of Y XP" does not say what happens at Y | |
| Extraction screen: why is there no proficiency rating | |
| Extraction screen: "the Mainframe, 4 racks fenced the data" -> "Mainframe bonus: $XXX", moved to the bottom in a dimmer colour | |
| Cannot move items from the tactical belt to the backpack in the Undercroft | his report, not yet reproduced |
| Remove crafting of purple, blue and gold strength guns; Peddler or raid loot only | |
| Make sure all the modifiers in the settings menu work as intended | a sweep, not one item |
| INVENTORY = BACKPACK + HOTBAR. An item is in one or the other, never both | model change; affects the belt assignment map |
| I opens the BACKPACK. Write the matching list of consistent definitions | vocabulary, pairs with pillagers-vocabulary memory |
| Too many footsteps when sprinting | his report, not yet reproduced |
| ESC should pause in the Undercroft | |
| The roll graphic is WRONG in the Undercroft | |

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
- I IN THE UNDERCROFT should open the simple inventory, not the stash.
- ROLL GRAPHIC IN THE UNDERCROFT still wrong: "player doesn't turn into a rolly
  ball" on space. Third time he has reported this; whatever I fixed was not it.
- DOWN SCREEN WORDING, his exact replacements:
  "Crawl or bleed out" and
  "You are bleeding out.  Crawl to open extraction point if possible"
- EXTRACTED SCREEN: "Claim it at the Mainframe".
- EXTRACTED/DEATH SCREEN: drop "Anything you drank or took is gone".
- XP CEILING: "what happens at 1.2m XP? death screen isn't clear".
- TITLE SCREEN WASTES THE SCREEN. His shot on a wide monitor: the whole thing is
  a narrow column in the middle with empty space either side. It is DOM, so the
  v8.81 canvas HUD scaling does not touch it.
- SOMETHING AT THE START OF COLD STORAGE IS BROKEN. His screenshot shows a long
  trench/wall run. Note he saw it every raid because of the v8.82 spawn bug, so
  re-ask him which part is broken now that the start point moves.
- FOOTPRINTS THROUGH WALLS. "i can see pillager footprints when i can't see the
  pillager -- intentional? I wanted sound visualization for stuff we couldn't
  see". So: footprint DECALS should be gated on sight; the sound ping is the
  thing that is meant to show through.
- I IN THE UNDERCROFT still wrong, and ROLLING IN THE UNDERCROFT still broken.
  Both reported three times now. Whatever I changed before was not it: reproduce
  on the Undercroft floor itself before touching anything.

## OPEN AND RED, as of v8.88
- THE UNDERCROFT BELT DRAG DOES NOT WORK. His note: "I don't understand why I
  can't move items from the tactical belt to the backpack in the undercroft".
  v8.72 claimed to fix it; the check that passed it was silently testing nothing
  because the stash panel had not opened. Made deterministic at v8.88 and it now
  fails on v8.88 AND on v8.87 alike: the belt slot still holds the item after the
  drag. NEXT BUILD. Reproduce the drag by hand before touching the fix.
- STANDING LABEL COLLIDES WITH STAMINA. His screenshot, v8.89. The status chip is
  placed with raw pixel offsets (_up = 22 with no armour, 44 with) while its own
  box height is LH-scaled, so the two stop clearing each other as the text size
  grows. Measure both rects at several text sizes before touching it. NEXT.
- THE THREE IN-RAID PANELS ARE TOO SMALL. His words: "these menus are still WAY
  TOO SMALL -- need to be twice as large as they are now", with shots of the
  CURRENT PILLAGERS board, the controls legend, and the CONDITIONS/CONTRACTS
  panel. None of them are in HUDZ, so v8.81 never touched them. He has named the
  target: twice the size. NEXT BUILD.
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
| 11 hotbar with the backpack open | PARTIAL | Drag onto the belt works in both places. Dragging OFF the belt back into the backpack works only in the Undercroft. The dragged item is also invisible in the Undercroft. |
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

STILL OPEN, and this is now the whole list:
- THE GAME DEMOLISHES A FIFTH OF ITS OWN BUILDINGS. 16 of the 84 on THE COLD MILE
  and both of the two empty ones on COLD STORAGE are built with an authored
  interior and then stripped at load by the sealed-room repair pass, which
  rewrites their plan to 'open' and leaves a bare room. Every building in the game
  is authored, so a designer's choice is being discarded silently on every load.
  I tried the fix and REVERTED it: giving a stripped building two stub walls works
  (empty buildings 31 to 15 on the mile) but broke v9.47 and v9.14
  deterministically, and my explanation for the v9.47 break was wrong. Full
  evidence in the DESIGN.md investigation entry
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
