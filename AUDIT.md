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
