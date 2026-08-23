# DARK RAIDERS — Handoff to a fresh Claude instance

Read this before touching anything. It is written for an agent picking the project up cold, and it is ordered by what will cost you most if you get it wrong.

Current build: **v1.55**, `dark_raiders.html`, 11,340 lines, one file, no build step, no dependencies.

---

## 0. The sixty-second version

Dark Raiders is a single-player extraction shooter that lives entirely in one HTML file. Open the file in a browser and it runs. A 3/4 overhead canvas renderer draws a flat top-down simulation. Ten-minute raids, loot, get out, keep what you carried. Daniel is the designer and playtester and he is not a coder.

You will do five things over and over:

1. Read new flight-recorder data in `exports/` and act on it.
2. Build or fix something in `dark_raiders.html`.
3. Verify it with the browser harness, because there is no Node on this machine.
4. Bump the version, write a changelog entry in `DESIGN.md`, commit.
5. Report to Daniel in bullet points with a play link at the top and bottom.

---

## 1. The scope boundary. This is the most expensive mistake available

**This project is the 2.5D three-quarter-view version, and only that.**

Daniel runs three separate Claude projects for Dark Raiders. This folder keeps the 3/4 top-down view. The other two are complete independent rewrites as a first-person shooter and a third-person shooter. They share no code and no assets.

Agents from the other two projects have repeatedly written into this folder's `dark_raiders.html`: at various points a first-person raycaster, a WebGL renderer, a "dream state" post-processing layer, and once a committed `v0.29: third person WebGL renderer` on master. **Each incident cost a full working session in recovery.**

So:

- Never convert the renderer here. Never add WebGL, a raycaster, or any 3D.
- Never add an external library or a build step.
- If you open the working file and find 3D code, it arrived by mistake. **Check `git log` first** — another agent may be actively committing and reverting would destroy wanted work that simply landed in the wrong folder. Then park it on a branch, restore the canonical file, and tell Daniel.
- The last known-clean 2.5D line is branch `v2.5d`, tag `v2.5d-last-good`.

---

## 2. Who you are working with

Daniel is the designer and playtester. **He does not write code, run commands, or read git terminology.** Never ask him to.

Ship finished builds. He plays them by clicking a link.

### How he wants to be spoken to

He has been explicit about this, repeatedly. Follow it literally.

- **A play link at the top AND the bottom of every message. Always.**
- **Bullet points and outline format.** Bottom line first, most important thing at the top.
- **Succinct.** He has said long descriptions waste his time.
- **Sim numbers belong in the summary**, not buried.
- **No em dashes or en dashes anywhere.**
- **Never wait to ask.** His words: "NEED YOU TO BE AUTONOMOUS SO NEVER 'WAIT TO ASK'". Make the call and move.
- When two of his requests conflict, **the most recent one wins**.
- Own a mistake in one line and fix it. Do not pad reports. If a check found nothing, say so.

### What he wants from the game

From his own answers, kept because they are the standing brief:

- A raid should feel **tense and frightening**. Horror-adjacent, not a power fantasy.
- The game is about **risk versus greed**.
- Structure should be **seasons or tiers**.
- He wants **neutral characters** in the world: traders, survivors.
- **Losing a raid should be a real gut punch.**
- His top complaint has always been **maps feel samey**. He wants handmade landmarks, themed districts, real interiors, weather and time variety.
- Look: push **brighter**, and push sprites further toward big-headed Toriyama styling.
- His own playtest tags: "Extract too easy" and "Loot boring".

---

## 3. The documents, and which one wins

| Document | Location | Role |
|---|---|---|
| `DARK_RAIDERS_SPEC.md` | `C:\Users\User1\Desktop\` | **Definitive.** Supersedes everything else where they conflict. |
| `CLAUDE.md` | project root | Working rules for this folder. Read every session. |
| `DESIGN.md` | project root | Source of truth for pillars, systems, config, changelog, telemetry, known limits. 861 lines. Read it before touching anything. |
| `HANDOFF.md` | project root | This file. |

Three mandates from the spec you must not violate:

> **AUTONOMY MANDATE.** Operate with high autonomy. The developer may be unreachable for a day or more at a time. Do not block waiting on approval. Do not maintain an open-questions list. Where this spec is silent or ambiguous, make the call using your best judgment and move forward.

> **ASSET SOURCING.** Map designs referenced below are to be built from your own design knowledge and judgment. Do not attempt to source, datamine, extract, or import proprietary map files, geometry, textures, or asset data from any commercial game.

The asset sourcing rule has been tested in practice. Daniel once asked for a map that "perfectly mimics" a specific commercial game's map. The right answer was to cite his own spec, decline to copy it, and deliver a measured rebuild designed from what that kind of place actually is. He accepted that.

The tone touchstones from the spec: **Chrono Trigger** for viewpoint, **Sea of Stars** for readable verticality, **Super Animal Royale** for top-down shooter feel, **Zero Sievert** for the grimy extraction loop.

---

## 4. The file: how it is laid out

One file, `dark_raiders.html`. The whole game is inside a single `(function(){ 'use strict'; ... })()` IIFE, so **nothing is on `window`**. That matters for testing; see section 6.

Navigate by the banner comments. `grep -n "^// ={10,}" dark_raiders.html` prints the table of contents. The order as of v1.55:

```
config            data              WEAR              profile
contracts         audio             MACHINE VOICES    utils
map               fixed maps        COLD STORAGE      TYPE
geometry          PARLEY            WEAK POINTS       YOUR BODY IS STILL OUT THERE
raid build        THE SEAL          WINDFALLS         MACHINES THAT COOPERATE
THE LISTENER      THE PEDDLER       THE STRAY         WILDLIFE
input             gamepad           throwables        sim core helpers
hotbar            player update     bot player        enemies
end of run        THE TERMS         the season        headless sim runner
2D renderer       HUD               tuning panel      the undercroft
main loop         hub UI            undercroft        wiring
boot
```

### The layer split. Do not blur it

- **Simulation, AI, collision and line of sight run on flat top-down coordinates.** No height exists there.
- **Rendering is a separate layer**: a y-sorted painter's pass, fog, lighting, and the HUD overlay on top.
- **Elevation is a pure render lift.** A platform's perimeter is an ordinary wall with gaps where ramps are. The simulation stays flat and knows nothing about height. This is why the game can have four terraces without a 3D engine.

### Systems worth knowing before you edit

- **Maps are fixed and hand-authored.** `FIXED_MAPS` holds four definitions, compiled by `buildFixedMap(def)`. The procedural generator is gone.
- **Visibility** is a raycast polygon: `buildVisPoly`, `losClear`, `canSee`, `rayHit`. Fog is painted with `destination-out`.
- **Navigation** is A* on a 16-unit grid: `buildNav`, `navPath`, `navSeek`.
- **The bot sim** is headless: `simStep`, `runSim`, `__simBatch`, running at a fixed dt of 0.15.
- **Audio** is WebAudio built from scratch: a Schroeder reverb of four comb delays, stereo panning, per-kind machine voices.
- **Typography** goes through one scale. `TYPE` defines five roles, `FS()` renders them. Never write a raw font string; use `FS(TYPE.micro|label|head|title|huge)`.

### The storage key

`salvagerun:profile` holds Daniel's actual progress. **Never change it without a migration.** Note that Chrome treats every `file://` document as one origin, so a stale copy of the game in another folder shares the same storage.

---

## 5. Workflow rules

1. **Data before changes.** Tuning comes from flight-recorder exports. One batch of tuning changes per feedback cycle, each with a one-line reason. No speculative tuning. New features are welcome unprompted (he asked for that explicitly), but balance changes need data.
2. **One canonical file.** Overwrite `dark_raiders.html` in place. Never create `dark_raiders_v2.html`. Git history is the version trail.
3. **Version discipline, every build.** Bump `var VER` near the top. It flows into all three visible strings automatically (title screen, recorder header, config copy line). Add a `DESIGN.md` changelog entry. Commit as `vX.Y: one-line summary` on `master`.
4. **Verify before done.** See section 6. Do not report a build ready if it has not passed.
5. **Rollback on request.** "Revert" means `git revert` or checkout of the prior commit, then re-verify.
6. **Feel is his call.** The bot sim measures balance, not fun. If a change is risky or untestable (rendering, feel), say plainly what he should watch for in the next playtest.

### Changelog style

Entries in `DESIGN.md` are long-form and explain the *why*, including what was measured and what was not verified. Every entry ends with an explicit **"Not verified: ..."** line naming the thing only a human in the chair can judge. Keep that convention. It is the single most useful thing in the document.

---

## 6. Verification, with no Node on the machine

**There is no JavaScript runtime installed.** `node --check` cannot run. The browser is the runtime. Say so plainly in every report: "browser parse and a drawn frame substituted for `node --check`."

### The harness

`tools/` in the project root holds four PowerShell scripts. They persist across sessions; use them rather than rebuilding your own.

| Script | What it does |
|---|---|
| `tools/mkfixture.ps1` | Builds `tools/fixture.html`: the real game with `window.__*` test hooks injected at the boot banner. **Rebuild after every edit.** |
| `tools/serve.ps1` | Static file server. `-Root <path> -Port <n>`. |
| `tools/collector.ps1` | Telemetry sink on 8799. The game POSTs each run and it lands in `exports/`. |
| `tools/capture.ps1` | Image sink on 8779. The page POSTs a base64 PNG and it writes to disk, so you can actually look at a frame. |

### Ports

| Port | Serving |
|---|---|
| 8802 | The project folder. **This is Daniel's play link:** `http://localhost:8802/dark_raiders.html` |
| 8800 | The `tools` folder, for `fixture.html` |
| 8799 | Telemetry collector |
| 8779 | Image capture sink |

Start them in the background. **Check they are alive at the start of every session** — they die when the machine or session restarts, and the first Daniel knows about it is "link doesn't work".

### The verification sequence

1. Edit `dark_raiders.html`.
2. Rebuild the fixture.
3. Load `http://localhost:8800/fixture.html`.
4. Call `__forceSize(1280,720)` first, or the canvas is zero-sized and `drawImage` throws.
5. For each of the four maps: `__prof().mapIx = n; __startRaid();` then step `__sim(dt)` and `__frame(dt)` for a few dozen frames.
6. **Assert `__state().drawErr` is null.** The renderer catches per-entity faults so one bad entity does not kill the frame; `drawErr` is where the first one is recorded. A silent `drawErr` is a real bug that a clean console will not show you.
7. Run `__simBatch(n)` for balance numbers. It blocks the main thread for roughly 10 seconds per raid, so kick it off with `setTimeout` and poll a global.

### Two hard-won rules about verification

**Rule one: verification must draw a frame.**

v0.98 shipped completely dead. `document.getElementById('verlabel').textContent = 'v' + VER` is set on the line *before* the async profile load, so the version label read correctly on a build whose first frame threw. The exception happened inside a `requestAnimationFrame` callback, and the Claude browser pane **suspends rAF while the pane is hidden**, so the console stayed empty too. Both available signals were structurally incapable of seeing the failure.

Checking the version label and the console is not enough. Drive at least one hub frame and one raid frame and assert nothing throws.

**Rule two: the browser pane suspends animation when hidden.**

Anything time-based fails there and it looks exactly like a catastrophic regression. Verify simulation logic through the headless bot sim, which runs on a `while` loop and is unaffected. Anything that exists only in the render or input layer cannot be verified this way. Say so and flag it for Daniel's playtest.

---

## 7. Traps that have already cost time

These are not hypothetical. Each one has bitten at least once.

### PowerShell here-strings versus file line endings

The file uses CRLF. A here-string passed through the tool layer often contains LF. A multi-line anchor therefore matches **zero** times and the edit silently fails, or worse, half-applies. This has bitten at least four times in one session.

**Use single-line anchors, or do line-index surgery with `ReadAllLines` / `RemoveRange` / `InsertRange`.** Always assert the match count is exactly 1 before replacing.

### `.Replace()` replaces every occurrence

`drawHubWorld` duplicates the raid renderer almost verbatim, so render-pass anchors are routinely non-unique. Count matches first. Every time.

### Never navigate or reload a tab Daniel is playing in

Read it with script instead. He plays in a `file://` tab or on 8802.

### The fixture can leak into his Downloads

The flight recorder POSTs to the collector, and **falls back to a silent browser download if the collector is down**. A fixture that blocks one exit of that chain sends every probe run down the next exit and into `C:\Users\User1\Downloads`. Ten files once appeared there looking like real playtest data.

`mkfixture.ps1` now stubs both `autoExport` and `downloadExport` after hoisting. If you change it, verify the whole chain end to end.

**Authenticate telemetry before tuning on it.** Your own artefacts look like his runs. The tells: `dur:0s`, `moved:0`, `shots:0`, `killer:null`, or a killer of `test`. Also the profile header differs, because the fixture runs on a different origin with its own localStorage.

### Buildings need 90 units of clearance on every side

`makeBuilding` rolls doors onto **one or two of its four walls at random**. A building with 46 units of clearance on its north side seals itself entirely the moment the roll puts its only door there, and the interior becomes floor you can see and never reach.

The first draft of THE QUARRY did not obey this and its conveyor bench measured 84 percent reachable. **Nothing within 90 units of anything else.** The same applies one level down: a locked room inside a building needs clearance from that building's inner walls too.

### Props can seal a map

Wrecked cars and ruins are placed against the finished wall list, but a car 50 units wide dropped in a 70-unit doorway is a wall. The build now floods the finished nav grid and removes any wreck or ruin touching unreachable ground. Authored geometry is never cut. If you add another kind of scatter prop, put it through the same guard.

### Watch for dangling `else`

The v1.55 crash was one: the raider draw was written as the `else` of the weak-point test, so every entity kind *without* weak points ran the raider path and threw on `e2.bag.length`. It fired on essentially every raid Daniel played for two versions.

It was worse than a missing nameplate. The throw skipped the `wc.restore()` that pairs with the deck lift, so **every entity drawn after it slid upward for the rest of the frame**. On a map whose top terrace lifts 132 units, that is the whole world jumping.

---

## 8. What the bot sim can and cannot prove

This is the section most likely to make you draw a wrong conclusion, so it has real numbers behind it.

Extract rate is a binomial proportion, and the sim is noisier than almost any change you will make.

**Simulated, 20,000 build comparisons per row, two builds that are genuinely identical:**

| Raids per arm | Shows a 5+ point gap | Shows a 10+ point gap | Average false gap |
|---|---|---|---|
| 30 | 68.5% | 49.8% | 9.8 points |
| 100 | 50.4% | 15.5% | 5.3 points |
| 200 | 32.3% | 4.2% | 3.8 points |
| 500 | 10.5% | 0.1% | 2.4 points |

Read the first row twice. **Change nothing at all, run 30 raids against 30, and half the time you will see a ten point difference.**

**A real 10-point improvement, how often you catch it:**

| Raids per arm | Points the wrong way | Significant, unpaired | Paired: winner is correct |
|---|---|---|---|
| 30 | 25.3% | 11.9% | 79.4% |
| 100 | 8.7% | 30.8% | 95.1% |
| 200 | 2.2% | 53.0% | 99.3% |

### What to do about it

- **Never compare two single sim runs.** This mistake has been made in this project already.
- The practical rule is not "run 373 raids". It is: **run the same seeds through both builds and ship the winner.** The sign of a paired difference is right 95 percent of the time at 100 seeds and 99 percent at 200, which is far cheaper than chasing statistical significance.
- Paired testing requires **seeded randomness, which the game does not currently have.** There are 45 raw `Math.random()` calls. Seeding them with a mulberry32 generator is roughly four lines plus a mechanical sweep, and it is the single change that unlocks honest A/B testing, raid replay, and golden-fixture regression tests. It is the top open item.
- Report the **flips**, not just the rate. "37 of 500 seeds flipped from death to extract" names the cases to go and look at.
- **The bot is not Daniel.** It does not loot greedily the way a player does. Treat its output as guardrails ("is this reachable, unwinnable, or degenerate") not as a difficulty target.
- Guard any telemetry target with a second metric. An extract rate that rises because the bot learned to rat the nearest exit with nothing reads as success in the data and as boredom in the chair.

---

## 9. Diagnosing the thing he complains about most

A low extract rate is three different problems wearing one number, and each has a different fingerprint.

| Cause | Signature in the data | What to change |
|---|---|---|
| **Difficulty** | Deaths spread across the map at all loot values, short time to death, dying with unused consumables | Time to kill, enemy damage, enemy count |
| **Legibility** | Deaths cluster at specific geometry, or right after committing to a route, or from threats never perceived | Telegraphing, audio cues, sight lines, alert feedback. Do not touch numbers |
| **Economy** | Deaths cluster on high-value runs while low-value runs extract fine; kit value trending down over a campaign | Insurance, safety nets, sinks, the loot value curve |

**The single most diagnostic split is extract rate against loot value carried at time of death.** Flat means difficulty. Rising death rate with loot value means the risk curve is working as intended. That field is not in the recorder yet. Adding it is cheap and it settles an argument that has been running for weeks.

For target rates: Tarkov sits around 20 to 30 percent survival, but that is player-versus-player with full loot loss and a large anti-death-spiral apparatus. **In a PvE game, death by bot at a 25 percent rate reads as the game cheating.** The defensible shape is two rates: roughly 55 to 70 percent overall, with the highest-value zone deliberately near 35 to 45 so the deep push stays a real gamble.

---

## 10. Where the build stands

### The four maps

| Map | Size | Identity |
|---|---|---|
| DAM BATTLEGROUNDS | 5200x4000 | Nine zones stacked vertically; the crest is the one deliberately exposed crossing |
| BURIED CITY | — | Desert ruins, the densest named ground in the game |
| COLD STORAGE | 4200x3400 | Built with no open ground in it |
| THE QUARRY | 4600x3600 | Five terraces, 132 units rim to floor, eight haul ramps, staggered |

Reachability at v1.55: Buried City and Cold Storage 100.00 percent, Quarry 99.22 worst case, Dam 99.15.

### Recently shipped

The Seal (a door too big to cut in one raid), gun wear and repair, machines that cooperate, The Terms, machine voices, weather that turns mid-raid, The Listener, your body stays where you fell, The Stray, scopes, weak points, armour tiers, contracts paying in gear, emotes and parley, bushes you can hide in, seasons.

### Open, roughly in order of value

1. **Seed the randomness.** Unlocks paired A/B, replay, and regression fixtures. Cheap.
2. **Paired-seed A/B at 200 shared seeds**, ship the winner. Retires the 30-raid comparison entirely.
3. **Loot value at death in the recorder.** One field; settles the difficulty-versus-legibility-versus-economy question.
4. **Index the wall segments.** `rayHit` is a linear scan over every segment in the map, roughly 2,300 on the dam. `segsNear` already fixes this for the visibility polygon but is applied nowhere else, and `G.vseg` is the full list plus smoke rather than a narrowed set. A uniform grid at 128 to 192 units, built once per map, benchmarks at 16x on total ray work with bullet rays alone at 103x, and it is provably exact. Note that a comment in the file claiming `vseg` caches only walls near the player is **stale and wrong**.
5. **Bake the light falloff.** Radial gradients are built inside the frame loop, one per light per frame. Baking them measures about 19x.
6. **Small hardening.** No `visibilitychange` handler, so every tab return simulates a clamped 50ms of phantom time. No canvas context-loss handler, so a GPU memory event blanks the game permanently with no recovery.

### Deliberately not doing

No OffscreenCanvas worker, no atlas rebuild, no dirty rectangles, no quadtree, no structure-of-arrays rewrite, and **no splitting the file**. At 11,340 lines it is inside the proven band for single-file projects, and a build step would reintroduce exactly the toolchain rot the single file exists to avoid.

A fixed-timestep accumulator would make the played game and the simulated game identical and is structurally the right answer, but it touches every rendered entity and **will change how movement feels**. Do it only with a real playtest cycle budgeted for feel alone.

### His outstanding complaints, not yet addressed

- "raiders should drop better loot"
- "not enough enemies, boring, looting"
- Wrecked cars read as suitcases from directly overhead rather than as vehicles

---

## 11. A worked example of the standard you are held to

Daniel reported: *"pushing the thing to start extraction process isn't working."*

That was **four** separate bugs, and finding only the first would have left him still unable to extract:

1. Calling extraction takes **1.6 seconds of held E**, and nothing on screen said so. A crate gets a labelled prompt and a filling progress bar; the way out of the raid had neither, so a tap on E was indistinguishable from a dead button.
2. A container within 46 units **ate the keypress outright**. Measured: 3 containers sat inside dam extraction rings every single raid, so those points could never be called, ever.
3. A closed extraction point was **completely silent**. No message, no sound, no refusal.
4. All three places that draw a zone coloured it by "the last zone you walked into" rather than by whether it was open, so a **closed point painted itself teal and captioned itself EXTRACTION**.

The lesson: when he reports something, reproduce it from the code, then keep looking after you find the first cause. His reports are accurate and usually understated.

---

## 12. Session checklist

**At the start:**

- [ ] Read `CLAUDE.md`, `DESIGN.md`, and the spec.
- [ ] Confirm the working file has no 3D code in it.
- [ ] Start the servers on 8802, 8800, 8799, and confirm they respond.
- [ ] Check `exports/` for files without a `consumed-` prefix, and check his Downloads. Authenticate them before using them.

**Before reporting a build ready:**

- [ ] Fixture rebuilt from the current file.
- [ ] All four maps build, step, and draw with `drawErr` null.
- [ ] `VER` bumped.
- [ ] `DESIGN.md` changelog entry written, including an explicit "Not verified" line.
- [ ] Committed on `master` as `vX.Y: summary`.
- [ ] Play link confirmed to serve the new version number.
- [ ] Consumed telemetry renamed with a `consumed-` prefix.

**In the report to Daniel:**

- [ ] Play link at the top and the bottom.
- [ ] Bullet points, bottom line first.
- [ ] Sim numbers in the summary.
- [ ] No em dashes or en dashes.
- [ ] Say plainly what could not be verified and what he should watch for.
