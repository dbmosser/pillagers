# The pixel art pass (planning run pixel-pass-plan, 10-20 evening; coordinator edits 23:45)

Jobs: tasks/86a to 86j. Raw run output: tools/handoff/art-survey/pixel-plan/result.json.

Coordinator edits on top of the run:
- Job 79 already shipped (v33.23) with the default camera at 1.05, so 86a ships ZDEFAULT 1.0 first (pixel exact at 1080p, inside 79's measured range).
- Lanes stop at 85% of the week, not 95%: his answer 33 ("keep the 85% stop while he is away") beats the run's suggestion. If the art does
  not all fit before the week resets (about 01:00 Sun 10/25), the cut order in "schedule" applies; nothing is held for the party.
- 86i ship 2 (solid furniture) is not "if time allows": his 23:00 order allows it now, with the reachability repair and the fingerprint rule.

## Approach

Base: the risk plan's per-sprite pixel art, drawn by code at art resolution behind one switch. Merged in: the fast plan's generic adapter, and the quality plan's scale handling, checks and telemetry. No low-res world buffer.

1. One switch. An experimental row "pixel look" (CFG.xfPix in XF_ROWS, scope 'l', default on). Only he flips it. One function, pixOn(), gates every new path. Off is today's game, byte for byte.

2. Two art densities, one constant each.
- PIX_ACT = 1 world unit per art px. This covers everything that moves or is looted: pillagers, the 3 sets, machines, machine wrecks, wildlife, containers, barrels and power-ups.
  - After 79 and 79a a pillager is about 45 to 57 art px tall at 1080p, close to the 1x test figure he saw at raid size (62 px).
  - Machines share the pillagers' density, as in his lineup picture.
- PIX_ENV = 2 world units per art px for the scene: ground, walls, doors, windows, trees, bushes, shadows, cover pieces and furniture. This is the test ground's density.

3. The style test's methods (pillager.js, machine.js, ground.js):
- whole-pixel masks at art resolution
- 4-tone hue-shifted ramps
- banding toward a top-left light
- a 1 art px ink outline (#16121c) on actors only; scene props get only a bottom and right edge in their own dark tone
- no dither and no gradients inside sprites

4. Bake once, blit every frame.
- Sprites are baked per pose key into byte-capped LRU caches. An actor then costs 1 to 3 drawImage calls a frame instead of about 100 vector calls.
- pixBlit snaps to device px. At a whole scale S = Z*DPR it draws nearest-neighbour. Otherwise it uses sharp-bilinear: a cached nearest prescale to ceil(S), then a smooth remainder.
- Rotation happens at art resolution, never on a finished sprite: guns 32 steps, machine parts 16, death topple 8.
- Hit flash, low-health pulse, elite ring and gold come from cached silhouette and outline masks or palette swaps. Nothing is read back and no ctx.filter is set per frame.

5. Fast path: pixWrap, built on the rimOpen pattern.
- It points wc at an art-res scratch canvas, runs today's painter unchanged, hardens the alpha, snaps colours to the ramps, adds the edge and caches the result.
- This covers containers, wrecks, props, furniture and all 9 machines with no hand art.
- Hand-drawn art goes where he looks most: the pillager with the cut, the 3 sets, the ground, walls and trees.

6. Ground. The same bakeGround code runs into a half-density canvas, so every rr() draw stays in its old order. A posterize and texture pass follows, using grit() and its own hashes only.

7. Untouched: simulation, AI, collision, line of sight, seeds, the net protocol and the storage key. The dress-up cut is a read-side map with no profile writes.

8. Safety.
- A pose or kind that is not pixel yet draws today's vector art, so a miss shows the old look, never a hole.
- A throw falls back to vector for that body and logs DRAWERR.
- The fixture pins the switch off, so the ~80 older checks keep their meaning; each pixel job's own check turns it on.

9. Before job 79 ships, the coordinator adds one line to it: land ZC at exactly 1.0 (inside his 1.0 to 1.05 range). Then S is 1 at 1080p and 2 at 4K, pixel exact. 79a's measured standing height sets the pillager grid; the readers disagree (46 against 55 px), so it is measured.

Rejected: the half-size world buffer (DPR/n). It stays a later option if he wants everything chunkier. Through PIX_ACT and PIX_ENV, the same code can bake coarser.

Anchors in the maps are from v33.17. The file is now v33.18 and lines sit about 30 later (SEATCOL is at 35383), so lanes grep by name.

## Why

Size. A half-res buffer leaves a pillager about 24 art px tall after 79 and 79a. That is far coarser than what he approved: the 52x66 test figure, and the 62 px 1x figure in the raid-size shot. At that size, 3 heads x 3 skins x 3 clothes would not read. Per-sprite art keeps the 1x figure he saw, standing on the chunky 2x ground he saw under it. His lineup also draws machines and pillagers at one density, which is why machines use PIX_ACT.

Safety. The buffer moves DPR under:
- 167 getImageData probes in the fixture
- his feedback PNGs, F9 clips and snips
- two click mappings
- Auto resolution
- about 10 text sites and 85 thin strokes
Per-sprite art changes none of these. With the switch off the frame is byte-identical, so the older checks stay green with no retargets.

Speed. Baked sprites cut CPU canvas calls from about 100 per body to 1 to 3. The half-density ground cuts COLD STORAGE from 57 MB to 14 MB. The buffer saves only GPU fill, and the frame time measured from his exports is script time (world 1.76 ms, fog 1.55, HUD 1.12).

Gradual. Each kind switches on its own, so every ship leaves a whole game. Anything that misses the lock keeps today's look.

Merged from the other plans:
- From fast: the generic adapter on the rimOpen pattern, gold as a baked palette swap, INK in the cache key, and drawing the nearest cached pose on a miss.
- From quality: sharp-bilinear, 32 gun steps with the muzzle within 1 unit, the ?pixbench page, the pix telemetry row with his real screen scale, the night readability measure, the lane style sheet, the party guard, and the corpus pass with pixel on.
- From risk: the XF row, the byte-identical off path, the read-side cut, rr() order kept by scaling the same ground code, and the weak-laptop and 2-window measures.

## The dress-up cut

His orders (10-20 22:50 and 23:05) set the cut: 3 heads, 3 skins, 3 clothes each with its own pack, and 3 full sets that override the rest. Today there are 18 slots, 145 items and 5 sets in 19 racks. In pixel mode there are 4 racks and 12 tiles, plus a set-off tile.

KEPT
- head:
  - short: crop with dark hair, the default (his v18.26 order)
  - long: long dark hair tied back; it carries the feminine look
  - hood: hood with cloth mask, the style-test head
- skin: fair (default), tan, umber. These are 3 ramps swapped at bake time, so they need no extra art.
- clothes with pack:
  - scav: tan coat, canvas satchel (default)
  - recon: olive drab, harness, tall frame pack
  - heavy: slate grey with steel plates, big boxy pack with a radio antenna
  - The pack makes each silhouette different. None is red (red means enemy, a18 and a19), and none is a seat colour (orange, cyan, lime, pink).
- set:
  - skeleton: extracts 12; his current look
  - trooper: level 8
  - android: runs 30
  - Unlocks are unchanged. A set overrides head, skin and clothes while worn, the saved picks come back when it is taken off, and the team trim band still shows.
- Heads, skins and clothes are always owned. Party seats keep their colour as a trim band, plus the seat ring and number (a06 A).

OFF THE PIXEL WARDROBE (their rows and profile fields stay)
- build (one lean body)
- scheme as a pick
- hair colour, beard, eyes, face, tattoo, patch, gloves, boots, pack, vest, pads, fit
- the 5 old sets, and 4 of the 8 outfits

NOTHING IS DELETED OR WRITTEN
- All 145 rows, the 18 fields, P.looks, restore codes and NET_LOOK stay exactly as they are.
- pixLook() maps any 18-field look to the 12 at draw time. It reads the raw fields, not cosWorn, so the old unlock rules never hide a pixel pick.
- No profile write is made, and salvagerun:profile is unchanged. Both windows resolve the same look from the same net look.
- Pixel tiles write only valid, always-owned old ids, so either mode reads them:

| tile | ids written |
|---|---|
| short | cosHat none + cosCut crop |
| long | cosHat none + cosCut long |
| hood | cosHat hood |
| scav | cosScheme schsand + cosPack packbrown |
| recon | schdrab + packbrown |
| heavy | schcharcoal + packbrown |
| skins | fair, tan, umber |
| sets | outskeleton, outtrooper, outandroid |
| off | outnone |

- With the switch off he sees his old look and the 19 racks exactly. The hood is warden 2 under the old rules, so in off mode a player without warden 2 sees a bare head, which is today's behaviour.

OLD PICK TO KEPT ITEM
- set:
  - outskeleton becomes skeleton
  - outtrooper and outrobot (The Machine) become trooper
  - outandroid becomes android
  - outnone, outexplorer, outpoet and outballer mean no set
- head, when no set is worn:
  - any hat other than none becomes hood (all 17, crown included)
  - cut long, pigtails, bob, bun or tail becomes long
  - crop, shaved or mohawk becomes short
  - outfits: explorer becomes long, poet becomes hood, baller becomes short
- skin:
  - porcelain and fair become fair
  - olive, tan and bronze become tan
  - umber and ebony become umber
- clothes, by scheme family (cosWorn already turns an old cosFit into a scheme):
  - drab, moss, teal, verdant and toxic become recon
  - ash, charcoal, indigo, frost, royal and night become heavy
  - std, rust, oxblood, sand, bone, ember, crimson, dune and gilded become scav
  - outfits: explorer becomes recon, poet becomes heavy, baller becomes scav
- ownership: a set is owned by its own rule, or by any old item mapped to it, so The Machine (warden 3) grants trooper. No row was ever bought (no buy: items), so no money is involved.

OTHER BODIES
- Pillager bots: raiderLook keeps its hash, so the fingerprint does not move. In pixel mode, head, skin and clothes are picked evenly from that same hash, then drawn in the red ramp with angry brows and red eyes.
- Hires: the 3 clothes by hash, never red.
- The Undercroft crowd and the demo's arcadeLook pick evenly from the 12. arcadeLook includes the sets, as today's cosAll does.
- In pixel mode, unlock toasts never name a cut item.

LOGGED FOR HIM, NOT WAITING
- Gone from the pixel wardrobe and back with the switch off:
  - Spartan Helmet and Ghost Mask (v10.45)
  - the sneakers (v10.47)
  - the 23 jersey, The Baller (v10.46)
  - The Street Poet, The Tomb Explorer and The Machine
  - the 20 schemes
  - the crown and gilded board rewards, shown as hood and scav
- One body shape drops the curved build (his 10-08 order) and a04 C's heights. The long head and the android set carry the feminine look. A curved pixel body is one later job if he asks.

## The switch

One row: Settings, experimental, "pixel look". The key is CFG.xfPix in XF_ROWS, with scope 'l' (local, read live) and the hint "pixel art". It is on by default, under his rule for new switches. Only he flips it; helpers never switch a feature off (process answer 21).

What it covers
- One function, pixOn(), gates every new path: ground, walls, trees, shadows, props, machines, pillagers, sets, wardrobe, effects, and the building floors, skins and flat details.

When it applies
- Figures, machines, props and the wardrobe switch at once.
- Ground, walls and trees re-bake at the next ascend or hub entry, never mid-raid.

What off does
- It brings back today's vector painters, the full-size ground, the 19-rack wardrobe and his old look, exactly.
- 86a's check proves that a staged raid frame with it off hashes the same as on the build before.

Not tied to the switch
- Building kinds and any new solid furniture (86i) are world content and are the same in both windows. Only their pixel floors, skins and flat details follow the switch.

Saves
- The cut writes nothing, so flipping the switch never changes a save.

Two windows
- Each window has its own row. On party night he flips it in both windows if anything looks wrong.

Per-kind safety net (not an off switch)
- A throw draws that body in vector and logs DRAWERR.
- A kind that throws 3 times in one raid stays vector until the raid ends, with one flight-recorder line (86j).

Gate
- The fixture pins xfPix 0 at load, in __resetCfg and in __pinDefaults, next to CFG.gfxScale=1.
- Every pixel check sets it to 1 and restores it in finally.
- The robots run with it on.

Undo
- One ship: git revert of its commit, then back through the gate.
- The art density changes through two constants (PIX_ACT, PIX_ENV), with no new control.

## Speed budget

Today, from 43 runs in his exports (G.tel.gfx; the source machine is not confirmed):
- Frame gap: p50 17.4 ms, p95 22.2 ms. 16 of the 43 runs had p95 over one 60 Hz frame.
- Script time per pass: world 1.76 ms, fog 1.55, HUD 1.12, light 0.14.
- There is no headroom to spend.

Gated in every pixel job's check (deterministic, counted through a wrapped context):
1. 0 getImageData, putImageData or toDataURL per frame after a 3 s warm-up. They happen only at bake time.
2. At most 2 sprite builds or 2 ms of baking per frame. A miss draws the nearest cached pose of that kind, else its vector painter.
3. No per-frame wc.filter. The golden enemy becomes a baked gold palette.
4. Canvas call caps:
   - a standing pillager at most 8 wc calls (about 100 today)
   - a machine at most 4
   - a cached prop 1
   - a whole raid frame at or below the off-mode count, and under the 4,000-call budget (graphics doc M1)
5. Byte-counted LRU caches per window: actors at most 24 MB, scene at most 16 MB.

Read from his exports, not gated (VM timing is noisy):
- World pass script time at or below off mode; target 1.8 ms average or less. It should drop.
- Fog, light and HUD unchanged.
- p95 frame gap no worse than today on the same machine.

Memory per window
- Ground on COLD STORAGE: about 14 MB (2100x1700) instead of about 57 MB.
- Caches at their caps add up to 40 MB, so the total is about even in the worst case and lower in practice.

Load
- The ascend bake is at most 1.5 s per window: ground about 1 s, plus the player, the mate and up to 12 bot looks at about 2.7 ms per look and pose.
- Spawn chunks are done before the first frame. The rest are done at most 4 ms a frame during the ascend countdown.
- There is never a whole-map bake mid-raid. The context-restore rebake uses the same chunk queue.

GPU fill is unchanged, because the canvas size stays the same. The savings are CPU calls and memory.

Weak laptop (coord-07: 1080p, 4x CPU throttle)
- Baseline on HEAD before 86c, then again after 86c and after 86f.
- Pixel on must be within 1 ms of off at p95, with no rise in "resolution stepped down" toasts per 5 minutes.

Party
- One 60 s two-window raid with both windows on: p95 within 1 ms of both off.

Telemetry
- A 'pix' row in G.tel.gfx records builds, bake ms, hits, misses, bytes and the device scale S. His exports then also show his real screen scale.

## Schedule (run estimate)

Before anything else, the coordinator:
- adds to job 79 "land ZC at exactly 1.0" (79 may run tonight)
- writes the 10 task files, 86a to 86j (they sort after 86 and before 87 to 91; a job whose prerequisite is open parks itself with TASK WAITING)
- runs coord-07's weak-laptop baseline

Capacity
- 3 lanes, 23:00 to 06:00, about 1 pixel job per lane-night.
- Memory cuts this: a lane needs 3 GB free, and tonight all 3 waited.
- Total pixel work is about 9.6 lane-nights, on top of the 14 jobs already queued.

Budget
- The week was at about 71%. Tonight's queue costs about 8 points, and a pixel job about 1.25.
- Lanes stop at 95% (likely Fri night), which keeps 5 points for the coordinator. That goes past the 85% checkpoint; his 10-19 order "pacing is off" allows it, but it is his call.
- The week resets about 01:00 Sun 10/25, during the Sat 10/24 night. The task text's "Sat 10/25" is off by one day.

Night by night
- Tue 10/20: the existing queue: rest of 61, 64, 79, 79a, 80, 81, and maybe 81a to 81c.
- Wed 10/21: 81a to 81c and 82 to 86, then 86a on the first free lane.
- Thu 10/22: 86b ground, 86c pillager (night 1), 86d walls and trees.
- Fri 10/23: 86c finish, 86e props, 86f machines (after 80). Lanes stop at 95%.
- Sat 10/24: lanes start about 01:00 after the reset: 86g states, 86h sets and wardrobe (night 1), spill-over.
- Sun 10/25: 86h finish, 86i building kinds, 86j fx and guard.

By Mon 10/26 morning
- Likely in: the switch; the pixel ground; walls, trees and shadows; the pixel pillager with the cut and its gun; red bots; props and containers; all 9 machines.
- Likely but not sure: 86g states and 86h sets with the 4-rack wardrobe.
- May slip to the Mon to Wed nights: 86i (its solid furniture ship most of all) and 86j (fx, power-ups, guard, corpus pass).
- Until each lands, builds mix pixel and vector looks. Reports say so.

Mon 10/26 to Wed 10/28 nights
- His next-play fix batch goes first.
- Then the slips, retargets from 86j's corpus pass, robots with pixel on, and 2-window pictures (the coordinator takes them if the lanes cannot).
- Hand-drawn sentry, crawler and warden only if 86f's pictures fall short.

Thu 10/29 evening: the party copy locks. Anything not pixel by then draws its old vector look, never a hole. The game file keeps moving after the lock (his 23:00 order). Party Fri 10/30.

If it slips, cut in this order (least visible first): 86i's solid furniture ship, 86j's effects, then 86i's flat details. 86a, 86b, 86c, 86e and 86f are never cut.

## Risks

1. Time and budget: about 9.6 lane-nights on top of 14 queued jobs, with about 9 usable before Mon 06:00, a week at about 71%, a stop at 95%, and no lanes before about 01:00 Sun. 86i and 86j may slip to the Mon to Wed nights. A miss shows the old vector look, never a hole.
2. Running lanes to 95% overrides the coordinator's 85% checkpoint plan. If the week hits 100% before the reset, the coordinator cannot answer him either. Brake: read the week at Sat 13:00.
3. Pixel size is a feel call. Actors at 1 art px per world unit look crisp rather than chunky at 1080p; that is the 1x figure he saw. The scene at 2 is the mixed density of the raid-size shot. If he wants chunkier actors, PIX_ACT 2 re-bakes them from the same code (about 27 px tall, and face detail goes). A side-by-side goes to him after 86c as a logged question.
4. Non-whole scales (1440p at 1.333, laptops at 125%, sprint 0.93, ADS 1.25 to 2.3, wheel zoom, auto resolution) make sprites slightly soft through sharp-bilinear, and the ground smooth. If job 79 lands at 1.05 instead of 1.0, 1080p is never pixel exact.
5. Every body changes in 86c and 86g: one bad sprite hits both players, the bots and the demo. Contained by the per-body vector fallback, the 86j guard, the switch and small ships.
6. Feel he picked changes form. The a11 bounce, a12 recoil, a14 kneel bow, a15 topple and a23 fall become baked whole-pixel frames, and aim steps in 32 (guns) and 16 (machines). Timings stay, the body stays front-only with a baked mirror, and he judges the result.
7. Gate blind spot: the fixture pins pixel look off, so the ~80 older checks guard only the off path. Covered by each job's own check, the smoke check, robots with pixel on and the 86j corpus pass.
8. Determinism: the simulation skips the ground bake, so the 4242 fingerprint cannot see a pixel bake that calls rr(), and a real raid would silently re-roll and desync two windows. Rule: grit() and own hashes only. 86b and 86i compare the rr() position on a real build.
9. Readability at night: the style test had no light or fog sheet. Dark clothes and the #16121c ink may sink into night floors, and red bots must stand out. 86j measures 1.8:1 in all 4 districts and tunes the night ramps if it fails.
10. Two painters, vector and pixel, must be kept in step until he decides which one stays. Any look change before then is made twice.
11. Dress-up losses he may notice: Spartan Helmet, Ghost Mask, the sneakers, the 23 jersey, The Street Poet, The Tomb Explorer, The Machine, the 20 schemes and the curved build leave the pixel wardrobe. Nothing is deleted; all return with the switch off, and The Machine grants trooper.
12. Copyright: trooper and android are inspired by Master Chief and 2B. Use original shapes, with no names, logos or traced art, for the itch release.
13. Ship-queue contention: about 20 ships touch drawOp, render2D and the painters, and the map anchors are about 30 lines stale (v33.17 against v33.18). Expect re-anchoring retries. Job 89 (hub floor text) edits drawHubWorld after 86b and 86d.
14. New solid furniture (86i ship 2) changes paths and sight lines. It carries the reachability check, and if it misses the lock it lives in the game file, not the party copy.
15. Machines through the adapter may look like today's machines, hardened and outlined, rather than the hand-drawn tank in his lineup. If 86f's pictures fall short, a hand-drawn sentry, crawler and warden job follows 86j.
16. Two-window pictures (rule 2.86 a) are needed for 86c, 86g and 86h, and coord-08 (the two-window camera) is still open. The coordinator takes them if the lanes cannot.

## What he was told

The whole game goes pixel art for the party: ground, walls, trees, props, machines and every pillager, crisp like the test you liked.
Dress up becomes 3 heads, 3 skins, 3 outfits with packs, plus the skeleton, trooper and android sets; nothing you own or saved is lost.
Work starts Wednesday night and most of it should be in by Monday morning; anything late keeps today's look until it lands.
If anything looks wrong, Settings, experimental, pixel look puts the whole game back to today's look.
On your next play, watch the walk bounce, the aim, and whether pillagers stand out at night.
