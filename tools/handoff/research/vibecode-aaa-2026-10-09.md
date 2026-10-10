# Vibecoding an AAA 2.5D action shooter with Claude Code

*Research date: 2026-10-09. Research agents read the sources below, and a separate fact-checker re-read the key ones. Anything the checker could not confirm on the page is marked **(unconfirmed)**. Claims the checker found wrong were dropped. Sources from before 2025 are marked **(older)** with their year. The research agents did not read the game's code, so some suggestions may overlap with things Pillagers already does.*

**A few terms used below**
- **Hook**: a small script that Claude Code runs automatically at a fixed moment, such as before a command, after an edit, or when Claude tries to finish. It runs every time, whether or not Claude remembers the rule.
- **Gate**: a check that has to pass before work counts as done.
- **Draw call**: one instruction to the graphics system, such as one `fillRect` or one `drawImage`.
- **Render scale**: drawing the game picture smaller than the screen and stretching it to fit.
- **TURN server**: a relay that passes traffic between two players whose home networks won't let them connect directly.
- **Snapshot**: a packet describing the game at one moment, sent from the host to a joiner.
- **Hitstop**: a very short freeze on a hit that makes it feel heavy.

---

## 1. The short answer

- **The ceiling so far is "good student".** One Vibe Jam 2026 judge described the best AI-built games as: "Not the top 20%, but a 3rd year student yes!" ([levels.io](https://levels.io/vibe-jam-2026-winners-quality)). What separates them from studio games is feel, animation and art direction, not features.
- **Checks matter more than prompts.** Anthropic's docs say a check Claude can run is what lets you walk away from a session. The firm way to enforce it is a Stop hook that won't let Claude finish until the check passes ([best practices](https://code.claude.com/docs/en/best-practices)). Put the Pillagers ship gate behind one.
- **Don't let the builder grade its own work.** Anthropic found that Claude, used as QA without special setup, spots real problems and then talks itself out of them. A separate, skeptical reviewer helped a lot ([harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps)). Screenshot judgments still can't be the pass: in a 2025 benchmark the best models scored under 50% at spotting visual regressions ([VideoGameQA-Bench](https://arxiv.org/html/2505.15952v2)).
- **Give the game its own clock.** A fixed-step `advanceTime(ms)` that runs the real game update, plus a `render_game_to_text()` state dump, makes checks independent of a hidden or throttled browser tab. Chrome's own frame-by-frame mode only works on Linux ([HeyGen](https://www.heygen.com/research/html-to-video)).
- **Use one simulation for everything.** The live game, the bot and any server should all call the same fixed-step update. World of ClaudeCraft runs one sim core in three places and has a test that guards it ([repo](https://github.com/levy-street/world-of-claudecraft)).
- **Move hard rules out of memory and into hooks.** Only the first 200 lines or 25KB of MEMORY.md load at session start ([memory docs](https://code.claude.com/docs/en/memory)), and anything past that is dropped without warning.
- **"Feel" is a list of specific techniques.** Screen shake driven by a "trauma" value, hitstop on the hit target only, a muzzle flash on frame one, a white flash when something is hit, a hit sound on the same frame, and visible damage on enemies instead of HP bars (ARC Raiders made that last choice).
- **There are concrete rules for TV play at 4K.** Text at least 52 px tall, 4.5:1 contrast, the HUD inside the middle 90% of the screen, and text that can scale to 200% ([Xbox guidelines](https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-101-text-display.md)). Headless checks can measure all of these.
- **Don't change engines yet.** Bake the procedural art into images, add a render-scale setting, then add a cheap light map. WebGL comes later, after the test harness can handle it. Chromium is removing its automatic software fallback for WebGL ([Chromium](https://chromium.googlesource.com/chromium/src/+/da170c2267b2201954efe1c8fa5d2d89ab09f7bf/docs/gpu/swiftshader.md)).
- **Missing animation is what gives a cheap game away.** The Claude Code-built CODEX MORTIS was criticised for characters that slide around as still images ([GIGAZINE](https://gigazine.net/gsc_news/en/20251215-codex-mortis/)).
- **Co-op needs three things:** a TURN relay from day one, a host-run game, and a host game loop that isn't driven by `requestAnimationFrame`. One browser shooter had 15-20% of players unable to connect before adding TURN ([Voidgun](https://voidgun.itch.io/voidgun/devlog/1448660/how-bringing-a-udp-game-to-the-browser-led-me-to-build-a-cross-platform-webrtc-library-for-libgdx)). Chrome stops `requestAnimationFrame` in hidden tabs ([Chrome](https://developer.chrome.com/blog/timer-throttling-in-chrome-88)).
- **Fun comes from your playtests.** Embark rebuilt ARC Raiders from scratch after playtests showed it wasn't fun, even though the tech was strong ([Inven Global](https://www.invenglobal.com/articles/20259/nexon-reveals-arc-raiders-reboot-story-at-gdc-2026-after-massive-aaa-reset)). Agents are reliable at getting things working and catching regressions, so aim them there.

---

## 2. Findings by angle

### 2.1 Claude Code practice

- **Gate the finish with a Stop hook.** The best-practices page gives four ways to enforce a check, lightest first: say it in the prompt, set a `/goal` condition, add a Stop hook that runs a script, or have a fresh agent try to disprove the result so the worker isn't grading itself ([best practices](https://code.claude.com/docs/en/best-practices)). Claude Code overrides a Stop hook after it blocks 8 times in a row with no tool call in between, so the script should exit early when `stop_hook_active` is true. The cap can be raised with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` ([hooks guide](https://code.claude.com/docs/en/hooks-guide), [hooks reference](https://code.claude.com/docs/en/hooks)).
  - *For Pillagers:* make dryrun.ps1 â†’ `__verifySafe` + `__regress` a project Stop hook. On failure it exits with code 2 and names the failing checks. Have it print one unmistakable verdict line (for example `GATE: PASS 21.70` or `GATE: FAIL 3: ...`), because `/goal` and any script can read that line.

- **Hooks are the only rules guaranteed to run.** The docs call hooks deterministic and CLAUDE.md advisory, and warn that a bloated CLAUDE.md makes Claude ignore instructions. Their advice: if Claude already does something right without the rule, delete the rule or turn it into a hook ([best practices](https://code.claude.com/docs/en/best-practices)). How hooks behave:
  - A PreToolUse hook that exits with code 2 blocks the command.
  - A PostToolUse hook that exits with code 2 shows its error output to Claude. Error output from a hook that exits 0 is never shown.
  - Output over 10,000 characters is saved to a file, and Claude sees a 2,000-character preview ([hooks reference](https://code.claude.com/docs/en/hooks)).
  - An `Edit|Write` matcher misses changes made through shell commands ([hooks guide](https://code.claude.com/docs/en/hooks-guide)).
  - Hooks are never compacted away ([steering post, 2026-06-18](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)).
  - *For Pillagers:* most edits go through PowerShell patch scripts, so an Edit|Write hook on its own would see almost nothing. Useful hooks:
    1. Block any command containing `:8802`.
    2. After any Bash, PowerShell, Edit or Write call that changed the game file, run parsecheck and reject non-ASCII bytes in `.ps1` files.
    3. A SessionStart hook with the `compact` matcher that re-adds the HEAD build, card stamp, open drafts, ports and last gate verdict after compaction.

- **Memory has a hard load limit.** Only the first 200 lines or 25KB of MEMORY.md load at session start, and the rest is skipped. CLAUDE.md should stay under 200 lines, and splitting it into imported files doesn't reduce its cost ([memory docs](https://code.claude.com/docs/en/memory)). On 2026-10-09 a research agent measured this project's MEMORY.md at 142 lines and 19,070 bytes, about 76% of the byte limit. New entries go at the bottom, so they are the first to stop loading.
  - *For Pillagers:* trim the index now. Keep lines short, fold older lessons into topic files, and move rules that are really checks into hooks.

- **The builder should not grade itself.** In Anthropic's harness experiments, out-of-the-box Claude found real issues and then decided they didn't matter. A solo run of a retro game maker took about 20 minutes and cost $9, and the result didn't respond to input. The full planner/builder/evaluator setup took about 6 hours and cost $200, and the result was playable. The evaluator drove the live app, scored it against written criteria with hard pass lines, and was calibrated with example score breakdowns. It was weak on musical taste because Claude can't hear ([harness design, 2026-03-24](https://www.anthropic.com/engineering/harness-design-long-running-apps)). The best-practices page warns that a reviewer told to find gaps usually reports some even when the work is sound ([best practices](https://code.claude.com/docs/en/best-practices)).
  - *For Pillagers:* build a reviewer subagent that sees only screenshots, the WHATSNEW line and a short rubric based on your bar: readable from the couch, clear silhouettes, lighting mood, HUD clutter. Anchor it with 3-5 shots you approved or rejected. Run it once per batch of visual builds, and tell it to report only real defects and breaks of your rulings.

- **For long jobs, use a fixed task list and a smoke test first.** Anthropic's long-running harness (2025-11-26) keeps its 200+ features in JSON because the model is less likely to rewrite JSON than Markdown. Agents may only flip a `passes` field, and editing or deleting tests is forbidden. Every session reads git log and the progress file, then runs a basic end-to-end test before new work. Claude couldn't see browser-native alert pop-ups during automation ([effective harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)).
  - *For Pillagers:* move AUDIT.md and the handoff queue into JSON (id, description, verify steps, passes). Start every session with a smoke raid: boot, loot, then endRaid. Keep `alert`, `confirm` and `prompt` out of the game.

- **Keep the main session's context for the edit itself.** A subagent returns only its final message. Anthropic's example has one reading 6,100 tokens of files and returning 420 ([context window](https://code.claude.com/docs/en/context-window)). By default up to 20 subagents run at once, nesting goes 3 levels deep, each can use its own model, and each can work in its own git worktree ([sub-agents](https://code.claude.com/docs/en/sub-agents)).
  - *For Pillagers:* in a 45,000-line file, the expensive part is finding code. Send "where is the hotbar drawn, and on which canvas?" questions to a read-only Explore subagent. Use a cheaper model for vocabulary sweeps.

- **Make your limits settings, not reminders.**
  - Workflows run 16 agents at once by default. `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` sets 1-256 (v2.1.269+). A run is capped at 1,000 agents, and Claude Code warns above 25 agents or 1.5M projected tokens ([workflows](https://code.claude.com/docs/en/workflows)).
  - `/goal` keeps a session going until a small model judges a written condition met. That model doesn't run commands or read files; it only reads what Claude printed. Conditions can be up to 4,000 characters and should include a limit such as "or stop after 20 turns" ([goal](https://code.claude.com/docs/en/goal)).
  - Skills cost almost nothing until used. After compaction, each skill in use is re-attached with only its first 5,000 tokens, inside a shared 25,000-token budget ([skills](https://code.claude.com/docs/en/skills)).
  - *For Pillagers:* set concurrency to 4 whenever agents might start Chrome, since your PC freezes beyond about 4 test Chromes. Use a bounded `/goal` in place of cron loops for long unattended runs. Turn the ship flow into a `/ship` skill that puts the critical steps first and pulls live state (git log, idle time, DEVNOW stamp) from shell commands, not from memory.

- **Session hygiene.** After correcting Claude twice on the same issue, `/clear` and write a better prompt, and tell CLAUDE.md what compaction must keep ([best practices](https://code.claude.com/docs/en/best-practices)). Output styles and `--append-system-prompt` are never compacted ([steering post](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)). Rewind checkpoints cover only Claude's own file-edit tools, not shell edits (from the best-practices page; not separately re-checked).
  - *For Pillagers:* make a git commit before every patch-script run, since `/rewind` can't undo PowerShell edits.

- **Steer the look with names, numbers and a banned list.** Anthropic found that without direction, Claude's visual output drifts to the most common choices in its training data; it calls this "distributional convergence". A steering prompt of about 400 tokens that named references and things to avoid helped right away ([frontend design, 2025-11-12](https://claude.com/blog/improving-frontend-design-through-skills)). That post is about web pages, so applying it to a game is an inference.
  - *For Pillagers:* write a short art-direction skill. Name references (ARC Raiders' muted industrial palette with bright hazard accents, rim-lit silhouettes), give numbers (palette hex values, outline widths at 4K, one shadow direction) and list what's banned (flat fills, pure-black shadows). Compare each change against a stored reference shot, not against the previous build.

- **Claude sees a 4K screenshot at about two-thirds size.** Current models read images up to 2576 px on the long side (4,784 image tokens). A 3840x2160 image is shrunk to 2576x1449, while 1920x1080 is read at full size for 2,691 tokens ([vision docs](https://platform.claude.com/docs/en/build-with-claude/vision)).
  - *For Pillagers:* judge fine 4K detail (outlines, small HUD text, grit) from full-resolution crops. Fifty full 4K frames cost about 240k tokens.

- **One huge file works against Claude Code's scoping tools.** Code-intelligence plugins report errors after each edit, but only for languages they handle. The official list covers TypeScript/JavaScript and has no HTML server, so script inside an .html file may get no diagnostics **(unconfirmed)** ([code intelligence](https://code.claude.com/docs/en/plugins/code-intelligence)). Path-scoped rules load only when a matching file is touched ([memory docs](https://code.claude.com/docs/en/memory)). With everything in one file, every task touches the same path (inference).
  - *For Pillagers:* optional, and not urgent. Develop as about 20 plain JS files that a PowerShell build joins into the single shipped HTML. Whatever the layout, keep lines short: no inlined minified libraries and no giant base64 blobs.

- **Don't adopt a big "AI studio" template.** A May 2026 critique of a 49-agent Claude Code game-studio template points out that its "independent" reviewers are the same model with different prompts, sharing one compacting context. What does work in it: matching model strength to the job, path-scoped rules, review verdicts a script can parse, and a lighter review mode ([Production Alchemist, 2026-05-19](https://www.productionalchemist.com/p/claude-code-game-studios-49-agents)).

- **There's no agent-tooling reason to switch engines.** Unity's official MCP server is an open beta (May 2026). It needs Unity 6+, the AI Assistant package and a trial or subscription, and it lists scene reading, console reading and script editing ([Unity](https://unity.com/blog/unity-ai-mcp-how-to-get-started)). A 2026 Godot roundup says several Godot MCP servers do read console errors; their gaps are screenshots, simulated input and asset generation ([Summer Engine](https://www.summerengine.com/blog/best-godot-mcp-server)). The Pillagers CDP harness already reads live game state. Google's Chrome DevTools MCP has 59 tools, including 14 memory tools, CPU throttling and viewport/DPR emulation, but it needs Node ([tool reference](https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md), [launch post, 2025-09-23](https://developer.chrome.com/blog/chrome-devtools-mcp)).

### 2.2 What other AI-built games learned

- **Quality ceiling.** Vibe Jam 2026 ran April 1 to May 1, required at least 90% AI-written code and drew 945 entries ([press](https://vibejam.com/2026/press)). Pieter Levels said entries are getting close to production-ready, and judge Tim Soret placed them at strong-student level ([levels.io, 2026-06-17](https://levels.io/vibe-jam-2026-winners-quality)).
  - *For Pillagers:* an ARC Raiders x Fortnite x CoD bar sits above anything AI-built games have shown publicly. The remaining distance is polish, which matches your "no more depth" ruling.

- **The 2026 winner's workflow.** An iOS developer won with Claude Code: about 27,000 lines, 188+ commits, 2-3 parallel sessions each owning a different area, a fresh session per feature and one long session for bugs. The 3D map was too hard for the AI, so he built it by hand. These numbers are self-reported via Reddit ([WCCFtech, 2026-07-13](https://wccftech.com/ios-developer-made-capybara-game-using-vibe-coding-and-won-25000/)).
  - *For Pillagers:* where the AI is weak at spatial layout, hand-tune map-generator settings and set-pieces rather than asking for "better maps".

- **Grumbulus, the closest public match.** It is about 15,000 lines of plain JS with Canvas 2D and Web Audio and no engine. Its postmortem lists typical AI bugs ([Gonzo ML, 2026-03-25](https://gonzoml.substack.com/p/how-we-built-a-full-browser-game)):
  - a boss spawn that called a method that didn't exist, so bosses never appeared;
  - 15 behaviour flags defined in data that no code ever read;
  - a wave score read after it had been reset, so players earned zero;
  - a character drawn in world coordinates on the screen, about 3,000 px off-screen;
  - testers seeing old builds because of browser caching.
  - *For Pillagers:* cheap static checks catch most of these (action 7). Show the build number on screen and cache-bust the itch build.

- **Silent skips.** In one weekend roguelike, Claude never implemented the requested sprites and also added design changes nobody asked for ([Barret Blake, 2026-03-16](https://barretblake.dev/posts/development/2026/03/ai-roguelike/)).
  - *For Pillagers:* each build's check should prove the specific thing promised in its WHATSNEW line exists on the real play path. Watch for unrequested balance or wording changes that conflict with your rulings.

- **Animation is the giveaway.** CODEX MORTIS (TypeScript, PixiJS, Electron, Claude Code on Opus 4.1/4.5) was criticised for static sprites drifting around; the developer used a shader wobble instead of real animation ([GIGAZINE, 2025-12-15](https://gigazine.net/gsc_news/en/20251215-codex-mortis/)). Its Steam page reportedly shows 4-player online co-op and about 91 reviews at 80% positive **(read by a research agent, not re-checked)** ([Steam](https://store.steampowered.com/app/4084120/CODEX_MORTIS/)).

- **One simulation core.** World of ClaudeCraft runs the same simulation in the browser, on the server and in a headless bot environment. A test scans the sim files and fails on DOM access, wall-clock calls or `Math.random` ([repo](https://github.com/levy-street/world-of-claudecraft)). The README doesn't confirm it was built with Claude **(unconfirmed)**.
  - *For Pillagers:* this is the structural fix for drift between `__sim`, the bot and `__loop`.

- **Hard visual constraints hold a style together.** Void Balls (Unity C#, not a browser game) shipped about 29,000 lines of code with 88 test files (about 19,000 lines), a locked 7-colour palette and 8 specialised agents ([Looped In, 2026-06-19](https://www.loopedin.games/blog/how-i-built-void-balls-using-ai)).
  - *For Pillagers:* the code equivalent is one named palette table, with a check that flags new inline colour values.

- **QA after every step, with a retry cap.** The game-creator plugin runs a five-phase check after every code change (build, runtime, gameplay, architecture, visual) and stops after 3 auto-fix attempts ([game-creator](https://github.com/opusgamelabs/game-creator)). Its "design-intent" tests are **(unconfirmed)** in the README, but the idea is sound: test that each enemy can actually hurt you and each extract can actually be reached.

- **Genre and money.** Shipped AI-built games are mostly roguelikes, bullet hells and auto-battlers ([Cinevva, 2026-03-23](https://app.cinevva.com/signals/2026-03-23-solo-devs-shipping-not-vibing)). The researchers found no public AI-built extraction shooter with bots and netcode. Levels' own unverified claim of $1M a year in recurring revenue within 17 days for fly.pieter.com came from his audience, not from technical depth ([levels.io, 2025-02-22](https://levels.io/full-multiplayer-python-websockets-game-ai)). Practical jam advice: one change per prompt, a strong first ten seconds, near-instant loading, and testing the hosted link in a fresh browser with no account ([Summer Engine, 2026-06-06](https://www.summerengine.com/blog/cursor-vibe-jam-2026-guide)).

- **AI disclosure is common on Steam.** As of July 2025, 6.9% of all Steam games and about 1 in 5 games released in 2025 disclosed generative AI ([WN Hub](https://wnhub.io/news/stores-and-publishing/item-48292)).

### 2.3 What AAA feel is made of

- **One pistol shot, broken down** (Nuclear Throne; [RPS interview write-up, 2013, older](https://infovore.org/?p=5275)):
  - the camera kicks about 6 px back from the aim direction, a fast-fading shake is added, and the gun sprite kicks back;
  - the first bullet frame is drawn as a circle to fake a muzzle flash, and bullets get 0-4 degrees of random spread;
  - shell casings fly out sideways;
  - a hit enemy is pushed back, flashes white for 1 frame then shows 2 hurt frames, and the game pauses for about 10-20 ms;
  - the hit sound layers a material sound (meat, metal) with the enemy's own sound;
  - stray shots leave marks on props.

  The game runs at 320x240, so convert to screen fractions (my arithmetic): a camera kick of 6/240 is about 2.5% of screen height, roughly 54 px at 2160p. Bullets move about 2 screen heights per second. The source doesn't give units for the shake value.

- **Screen shake should use a "trauma" value.** Each hit adds trauma (0 to 1), which fades over time. Shake equals trauma squared, using smooth noise rather than random jumps. Bevy's example uses +0.4 per event, a fade of 0.5 per second, 10 degrees of roll and 20 px of movement, applied only while drawing ([Bevy](https://bevy.org/examples/camera/2d-screen-shake/), crediting Squirrel Eiserloh's camera talk).
  - *For Pillagers:* keep one trauma value per window, shake only the world draw, and draw the HUD after restoring the camera. Aim and hit tests use the unshaken camera. Use roll near 0 for top-down and add a settings slider.

- **Hitstop rules** from Smash Bros. ([Sakurai via Source Gaming, 2015, older](https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/)): attacker and victim freeze for the same time; the freeze grows with damage and has a cap; projectiles get less; both vibrate with shrinking amplitude. Sakurai keeps it short in multiplayer because a frozen pair hands a third player a free hit.
  - *For Pillagers:* freeze only the victim's pose and animation clock, never the whole simulation, so your partner and the WebRTC peer never stall.

- **Show damage on the body, not in a bar.** Embark removed enemy HP bars, damage numbers and hit indicators from ARC Raiders and replaced them with smoke, sparks, broken armour plates and damage that stays visible ([GamingBolt, 2025-11-05](https://gamingbolt.com/arc-raiders-lacks-enemy-hp-bars-since-embark-doesnt-want-you-playing-the-excel-sheet-of-a-game)).
  - *For Pillagers:* procedural art makes this cheap. Draw damage states keyed to the HP fraction.

- **TV and 4K rules from Xbox:**
  - text body at least 52 px tall at 4K (26 px at 1080p), scalable to 200% with icons scaling too ([XAG 101](https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-101-text-display.md));
  - contrast 4.5:1, or 3:1 for very large text (104 px at 4K), measured against the worst part of the background, with a solid plate behind text recommended ([XAG 102](https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-102-contrast.md));
  - important UI inside the middle 90% of the screen, which is 3456x1944 at 4K ([screen areas](https://devdocs.xbox.com/build/core-features/graphics/overviews/screen-areas)). That page's 1080p pixel numbers don't quite add up, so work from the percentage.

- **A proven HUD layout.** ARC Raiders puts your shields and health bottom-left with squadmates' bars, the weapon and ammo bottom-right, and a compass top-centre that shows extracts only when you head toward them, with the raid timer under it. Map extract icons change colour in the last 5 minutes and turn grey when closed ([community wiki](https://arcraiders.wiki/wiki/Game_UI)).

- **Menu mistakes to learn from.** At Marathon's March 2026 launch, implants, cores and mods had near-identical icons, so players had to hover even mid-raid, and there was no quick way to compare looted gear with equipped gear ([Marathon Hub, 2026-03-03](https://marathonhub.gg/news/bungie-says-marathons-ui-will-improve-but-the-sauce-is-staying/)). Reports of about 20 font combinations on one page are **(unconfirmed)**. Patch 1.0.5 then reduced camera shake from incoming melee hits, softened a full-screen status effect, faded waypoints while aiming, made the revive prompt clearer and let downed players activate exfil beacons ([Shacknews, 2026-03-17](https://www.shacknews.com/article/148342/marathon-update-1-0-5-patch-notes)).
  - *For Pillagers:* there is now AAA precedent for "downed extract". Keep incoming-hit effects weaker than outgoing ones.

- **Mixing a chaotic fight** ([Helldivers 2 interview, 2024, older](https://www.asoundeffect.com/helldivers-2-game-sound-design/)):
  - each sound category has a loudness target, and a priority system decides what ducks what;
  - dialogue ducks only the music's highs, and explosions duck only its lows;
  - off-screen sounds are turned down, and big enemies fade less with distance so you hear them coming;
  - a weapon's sound gets less bright during sustained fire, and bigger threats get longer warning sounds.

  All of this maps onto Web Audio gain and filter nodes.

- **ARC Raiders' sound** ([Embark, 2025-09-03](https://arcraiders.com/news/soundscapes-blog)): guns are recorded with mics on the gun, partway out and hundreds of metres away; hundreds of rules add context sounds; each machine sounds different depending on whether it's searching, fighting or roaming; the backpack sounds different depending on how full it is.
  - *For Pillagers:* crossfade a "close" synth and a "far" synth by distance. Give each enemy type a looping sound per state as an off-screen warning, which matters in top-down where threats sit outside the frame.

- **Warn before attacks.** Add a wind-up delay with a charge-up glow, a sound and, for grounded games, a cocking animation ([Game Developer, 2015, older](https://gamedeveloper.com/design/enemy-attacks-and-telegraphing)).

- **Camera.** Lead the camera toward where you aim, smooth it less when moving fast, and use "attractor" rings that pull the camera toward points of interest ([Itay Keren, 2015, older](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers)).
  - *For Pillagers:* the D-pad aim-distance setting can drive the lead. Add attractors around active extract beacons.

- **Showing sound for TV players.** Fortnite turned on its directional sound rings by default on 23 July 2024 ([Can I Play That, 2024, older](https://caniplaythat.com/?p=14083)). The exact colour scheme is **(unconfirmed)**. Many TV players don't use headphones, so extend the noise rings into an on-screen arc pointing to off-screen sounds.

- **Gun depth without jamming.** SYNTHETIK has an active reload (time it right and the magazine goes in instantly with bonus damage), dropping a magazine early loses its rounds, and accuracy rewards stopping between bursts ([SYNTHETIK, game from 2018, older](https://www.synthetikgame.com/weapons)). Skip its jamming, per your ruling that guns never jam.

- **One-switch HUD sizing.** Black Ops 6 ships ten HUD presets, including one called Magnified, plus colour slots per side ([Insider Gaming, 2024, older](https://insider-gaming.com/how-to-customize-the-hud-in-black-ops-6/)). Its "for players far from the screen" description is **(unconfirmed)**.

- **Lower-authority patterns, still useful:**
  - Apex lets players choose between stacking or floating damage numbers, with colour per category ([Shacknews, ~2019, older](https://shacknews.com/article/110042/how-to-change-damage-numbers-in-apex-legends)).
  - Loot light-beams can grow taller with rarity ([RuneScape wiki](https://runescape.wiki/w/Loot_beam)).
  - Notifications can be tiered by how much you lose by missing them, with caps and "x3" merging ([guide, low confidence](https://app.studyraid.com/en/read/100682/4508374/structuring-notification-layers-for-game-events)).
  - Couch co-op screens get hard to read, and turning shake off helps ([Nintendo Life, 2019, older](https://www.nintendolife.com/reviews/switch-eshop/nuclear_throne)).
  - Claims about exact hit-sound timing in milliseconds are **(unconfirmed)**.

### 2.4 Visuals and performance in the browser

- **Canvas 2D basics still apply** ([MDN, updated 2026-08-25](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)): draw repeated things once to an offscreen canvas and copy them; don't scale inside `drawImage`; use whole-pixel positions; split layers by how often they change; avoid `shadowBlur` and text; batch calls; draw to a smaller canvas and scale it up with CSS.
  - *For Pillagers:* your profile found 3,500 `fillRect`s per frame from wall grit alone. Make baking the default for trees, shadows, props and character poses, and add a draw-call ceiling to the gate.

- **Treat resolution as a quality setting.** Engines pick device pixel ratio at runtime from a startup benchmark or GPU tier and expose it in settings ([PlayCanvas](https://developer.playcanvas.com/user-manual/optimization/runtime-devicepixelratio/)). 4K is about 8.3 million pixels, four times 1080p.
  - *For Pillagers:* draw the world at 0.5-0.75 of 4K and let CSS scale it up. Keep the HUD and text canvas at native 4K. This is likely the biggest frame-budget win per line of code (inference).

- **Blur is expensive.** Its cost grows with image size and blur radius; pre-render blurred copies once ([Chrome, 2017, older](https://developer.chrome.com/blog/animated-blur/)). Firefox is about 28x slower than Chrome when `ctx.filter` is set repeatedly, and the bug is still open ([Mozilla bug 1978851](https://bugzilla.mozilla.org/show_bug.cgi?id=1978851)).
  - *For Pillagers:* replace per-frame glows with baked glow sprites drawn in additive mode, and never set `ctx.filter` inside a draw loop. Friends on itch won't all use Chrome.

- **Lighting without WebGL.** Canvas has 26 blend modes, including `lighter` (adds light) and `multiply` (darkens) ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/globalCompositeOperation)). The common light-map recipe, which is a standard technique rather than an MDN recipe: fill a small offscreen canvas with the ambient colour, add each light as a radial gradient with `lighter`, then multiply it over the scene. Wall shadows and line of sight come from "visibility polygons": rays cast to wall corners, sorted by angle. Soft edges come from blending about 11 slightly offset copies ([Nicky Case, ~2014, older](https://ncase.me/sight-and-light/)).
  - *For Pillagers:* a light map at quarter size (960x540 for 4K) has 1/16 of the pixels and gets soft edges for free. Make sure split walls feed the shadow list too.

- **What the 2D engines say.** Phaser's 2026 rendering guide says to keep draw calls to a few hundred, notes that filters, blend modes and lighting break batching, says screen fill is where the GPU gets stuck, and makes its GPU layers WebGL-only ([Phaser](https://phaser.io/tutorials/phaser-4-rendering-concepts)). The claim that Phaser 4 deprecated its Canvas renderer is **(unconfirmed)**. PixiJS v8 cut CPU time for 100k moving sprites from about 50 to 15 ms, and its team says WebGPU isn't automatically faster for 2D ([Pixi, 2024, older](https://pixijs.com/blog/pixi-v8-launches)). Pixi's tips: turn complex drawn shapes into textures, and use bitmap fonts for numbers that change every frame ([Pixi tips](https://pixijs.com/8.x/guides/concepts/performance-tips)).
  - *For Pillagers:* by plain arithmetic, one full-screen 4K buffer is about 33 MB, so count full-screen passes the way you count `fillRect`s. If you ever move off Canvas 2D, keep the Canvas drawing code as the art tool and hand the results to the GPU as textures.

- **WebGL will break the headless gate first.** Chromium's docs say WebGL creation will fail where it used to fall back to the SwiftShader software renderer, unless Chrome runs with `--use-gl=angle --use-angle=swiftshader-webgl --enable-unsafe-swiftshader` ([Chromium](https://chromium.googlesource.com/chromium/src/+/da170c2267b2201954efe1c8fa5d2d89ab09f7bf/docs/gpu/swiftshader.md)). The exact Chrome versions are not in that doc. Nobody documents the current cost of uploading a 4K canvas to WebGL every frame ([2014 Chromium change, older](https://codereview.chromium.org/735623003); low confidence).
  - *For Pillagers:* before any WebGL build, measure that upload in a scratch page on your GPU, and decide the gate's GPU flags.

- **WebGL basics when you get there:**
  - Calls that wait on the GPU (`getError`, `readPixels`) can stall 1 ms or more; skip mipmaps for 2D; compile shaders up front ([MDN WebGL, 2026-10-07](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices)).
  - WebGPU is now in all major browsers ([web.dev, 2025-11-25](https://web.dev/blog/webgpu-supported-major-browsers)), but WebGL2 is the safer target.
  - Draw thousands of particles in one call with instancing ([WebGL2 Fundamentals](https://webgl2fundamentals.org/webgl/lessons/webgl-instanced-drawing.html)).
  - Bloom should shrink the image step by step ("Dual Kawase") rather than blur at full size ([Frost.kiwi, 2025-09](https://blog.frost.kiwi/dual-kawase/)).
  - Colour grading with a 32x32x32 lookup table plus vignette and grain fits in one final pass ([TU Wien, 2013, older](https://www.cg.tuwien.ac.at/courses/Realtime/repetitorium/VU.WS.2013/Color-Grading.pdf)).

- **The high end of 2D lighting.** A "distance field" of the walls can be built once per seeded map; it makes shadow rays need about 32 steps instead of 256 ([jason.today, 2024, older](https://jason.today/gi)). Soft shadows from it cost almost nothing extra ([Inigo Quilez, older](https://iquilezles.org/articles/rmshadows/)). Full bounce lighting with "radiance cascades" measured 1.85 ms at 512x512 on a laptop RTX 3080 ([arXiv, 2025-05](https://arxiv.org/abs/2505.02041v1)). Browser timings for it are **(unconfirmed)**. Normal maps can come from code-drawn height images instead of being guessed from brightness ([arXiv, 2022, older](https://ar5iv.labs.arxiv.org/html/2212.09692)).
  - *For Pillagers:* this is the last step, not the first.

- **Chrome's renderer can change under you.** Chrome's new Skia Graphite backend launched on Apple Silicon Macs in July 2025 ([Google](https://blog.google/chromium/introducing-skia-graphite-chromes/)). Its Windows status is **(unconfirmed)**.
  - *For Pillagers:* pin a performance baseline scene and record the Chrome version with every performance number.

- **Workers for load-time jobs.** OffscreenCanvas can render inside a Worker ([web.dev, 2023, older](https://web.dev/articles/offscreen-canvas)). It suits baking atlases at map load so the title screen doesn't freeze, not the main game render.

- **Not recommended.** A full three.js 3D rewrite would replace every procedural draw and the whole check suite ([three.js docs](https://threejs.org/docs/pages/OrthographicCamera.html)). If WebGL arrives, check shader link status at load so a broken shader fails loudly rather than showing a black screen ([skill listing, low confidence](https://claudemarketplaces.com/skills/martinholovsky/claude-skills-generator/webgl)).

### 2.5 Art and audio

- **Store rules on AI disclosure differ.**
  - Steam's survey covers AI content that ships to players (artwork, sound, narrative, localization). It says productivity tools are not its focus, and code isn't in its examples ([Steamworks](https://partner.steamgames.com/doc/gettingstarted/contentsurvey), [GamingOnLinux, 2026-01](https://www.gamingonlinux.com/2026/01/valve-tweak-steam-ai-disclosure-form-for-developers-to-clarify-its-for-content-consumed-by-players/)).
  - itch.io staff say code written by a language model counts as generative-AI content. Disclosure is encouraged for games, not required, and a false "No AI" tag costs a game its listing on browse pages ([itch.io, 2024-11-20, older](https://itch.io/t/4309690/generative-ai-disclosure-tagging)).
  - A reported 19.5% of June 2026 Next Fest demos disclosed AI **(secondhand)** ([GamineAI](https://www.gamineai.com/blog/steam-ai-disclosure-debate-what-indies-decide-after-sweeney-2026)).
  - *For Pillagers:* the honest itch answer is at least "Yes: Code". Whether procedural art drawn by AI-written code counts as AI art on Steam is undecided, so pick an answer and write it down.

- **Where players drew the line on AI voice.** ARC Raiders shipped AI text-to-speech voices; after criticism Embark re-recorded many lines with actors and kept licensed TTS mainly for location pings ([Kotaku, 2026-03-13](https://kotaku.com/arc-raiders-replaced-ai-generated-content-human-recorded-dialogue-voices-2000678774)).
  - *For Pillagers:* AI voice is tolerated for short utility callouts, not for characters players care about.

- **Sound-effect generation.**
  - ElevenLabs' API makes 0.5-30 s clips, can loop, and outputs 48 kHz Opus or PCM ([API](https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert)). The quoted credit cost per second is **(unconfirmed)**.
  - The free plan needs attribution; paid plans don't ([ElevenLabs](https://elevenlabs.io/sound-effects/commercial)).
  - Its old local MCP server limits clips to 0.5-5 s and is deprecated in favour of a hosted one ([Glama](https://glama.ai/mcp/servers/elevenlabs/elevenlabs-mcp)).
  - Stable Audio 3.0 released free-to-run "Small SFX" weights. Outputs can be used commercially under $1M a year in revenue ([The Decoder, 2026-05-20](https://the-decoder.com/stability-ai-launches-stable-audio-3-0-with-up-to-six-minute-tracks-and-open-weights/)). Running it locally would compete with your 6 GB free-RAM rule.

- **Music.**
  - Eleven Music's terms, updated 2026-10-09, exempt "Indie Games": under $500k revenue for the game and under $1M a year for the developer ([terms](https://elevenlabs.io/eleven-music-model-specific-terms)). Re-read them before any launch.
  - Suno caps downloads at 20 a month on Pro since 2026-09-03 ([RouteNote, 2026-08-12](https://routenote.com/blog/suno-announces-20-monthly-downloads-and-new-music-industry-models/)).
  - Udio reportedly disabled downloads after its Universal deal **(not re-checked)** ([Digital Music News](https://www.digitalmusicnews.com/2025/10/31/udio-downloads-disabled-umg-deal/)).
  - These would only apply to hub and menu music, since your ruling is no raid music.

- **Consistent characters.**
  - AI image tools drift between animation frames ([Cinevva, 2026-09](https://app.cinevva.com/guides/ai-pixel-art-generators)).
  - Rendering from 3D gets all 8 directions consistent for free. Blender MCP lets Claude run Python in Blender and look at renders ([blender-mcp](https://github.com/ahujasid/blender-mcp)), and free scripts render 8-direction sprite sheets with normal maps ([Foozle](https://foozlecc.itch.io/render-4-or-8-direction-sprites-from-blender)). No source shows the whole pipeline end to end, so pilot it on one prop.
  - 3D-generator licences matter: Tripo's free tier is non-commercial, Hunyuan3D excludes the EU, UK and South Korea, and TRELLIS.2 is MIT ([Cinevva](https://app.cinevva.com/guides/ai-3d-model-generators)).
  - PixelLab has a hosted MCP server for tiles and 8-direction objects ([PixelLab](https://www.pixellab.ai/llms.txt)). It is pixel-art scale, so best limited to icons.

- **Where code-drawn art looks cheapest.** A popular Claude code-art skill calls itself a last resort and rules out realistic fire, smoke and water ([codeart2d](https://skills-hub.ai/skills/agent-sprite-forge-codeart2d)). agent-sprite-forge pairs measured checks (feet planted, colours locked) with a human looking at a contact sheet, and says numbers alone never approve anatomy or motion ([repo](https://github.com/0x0funky/agent-sprite-forge)).
  - *For Pillagers:* turn fire, smoke, explosions and water into baked flipbook animations, and review them with contact-sheet screenshots.

- **Copyright and voice rights.**
  - The US Copyright Office says prompts alone don't make you the author of AI output ([IPWatchdog, 2025-01-29](https://ipwatchdog.com/2025/01/29/part-two-copyright-office-ai-report-says-creative-prompting-doesnt-constitute-authorship/)). Keep a log of each AI asset: tool, plan, date, prompt and file hash.
  - XTTS v2 voice weights are non-commercial; the 2025 SAG-AFTRA agreement covers copies of real performers ([Cinevva](https://app.cinevva.com/guides/ai-voice-acting-games)).
  - The claim that ElevenLabs library voices carry a free commercial licence is **(unconfirmed)**.

- **Audio tech.** Pre-render synth sounds into buffers at boot instead of building them on every shot; building them per note is very CPU-heavy ([Keith Clark](https://keithclark.co.uk/articles/zzfxm/)). Browsers test Web Audio by rendering offline and comparing buffers against thresholds ([W3C, 2013, older](https://lists.w3.org/Archives/Public/public-audio/2013OctDec/0211.html), [WebKit test](https://webkit.googlesource.com/WebKit/+/master/LayoutTests/webaudio/Oscillator/osc-sweep-snr-sine.html)).
  - *For Pillagers:* a scripted event list rendered offline can check that each cue makes sound within N ms, doesn't clip, and isn't silent. That needs no ears; taste stays with you.

### 2.6 Testing

- **The game should own its clock.** A widely mirrored "develop-web-game" agent skill (author attribution to OpenAI **unconfirmed**) builds canvas-game testing on two page hooks ([skills.cat mirror](https://skills.cat/skills/trailofbits/skills-curated/openai-develop-web-game), [Smithery mirror](https://smithery.ai/skills/davila7/develop-web-game)):
  - `advanceTime(ms)` runs the update in fixed 1/60 s steps, then draws once;
  - `render_game_to_text()` returns short JSON of what's on screen, including which way the axes run;
  - its rules: small steps, open and inspect every new screenshot, check the text matches the screen, and fix the first new console error before anything else.
  - Chrome's own frame-by-frame mode works only on Linux and crashes on Windows ([HeyGen, 2026-06-22](https://www.heygen.com/research/html-to-video)).
  - Playwright's clock can take over `requestAnimationFrame` and timers ([Playwright](https://playwright.dev/docs/clock)), but it needs Node, which this PC doesn't have.

- **Freeze before golden images.** Playwright's screenshot assertion waits for two identical shots in a row, compares at CSS scale by default, and its "disable animations" option covers CSS only, not canvas. Baselines differ by OS and hardware, so make them where you compare them ([assertions](https://playwright.dev/docs/api/class-pageassertions), [snapshots](https://playwright.dev/docs/test-snapshots)).
  - *For Pillagers:* pause the sim, capture at device scale for 4K, make baselines only from gate.ps1's Chrome, and mask the version label and FPS readout.

- **Compare objects, not whole frames.** A study of canvas games cut frames into the game's own objects and compared each one. It caught all 24 planted visual bugs, against 44.6% for whole-frame snapshots ([arXiv, 2022, older](https://arxiv.org/abs/2208.02335)).
  - *For Pillagers:* the art is code, so draw one raider, one crate or the belt alone into an offscreen canvas and hash the result. A failure then names the function that changed.

- **Screenshots aren't a pass.** In VideoGameQA-Bench the best visual-regression score was 45.2% and Claude Sonnet 3.7 scored 24.0%. Models invent glitches and do worst on tables, progress bars and minimaps ([arXiv, 2025](https://arxiv.org/html/2505.15952v2)). Only older Claude models were tested.

- **Keep test output short.** In Anthropic's 16-agent C-compiler project, the harness printed a few lines per run, wrote "ERROR" plus the reason on one line, sent details to log files, and offered a fast mode running a fixed random 1-10% sample ([Anthropic, 2026-02-05](https://www.anthropic.com/engineering/building-c-compiler)). Microsoft's playwright-cli saves page snapshots to files instead of putting them in Claude's context ([playwright-cli](https://github.com/microsoft/playwright-cli)). Third-party token-saving figures for it are **(unconfirmed)**.
  - *For Pillagers:* print one line per failure plus a summary. Run a different 5-10% slice each tick and keep the full corpus as the ship gate.

- **Hash the game state.** Factorio's tests run a small map and compare a checksum of the game state against stored values, which are regenerated on purpose when logic changes ([FFF #60, 2014, older](https://factorio.com/blog/post/fff-60)). Their per-tick desync replay is from another post **(not re-checked)** ([FFF #47](https://factorio.com/blog/post/fff-47)). A fixed timestep with an accumulator, capping long frames at 0.25 s, makes the game independent of frame rate ([Gaffer On Games, 2004, older](https://gafferongames.com/post/fix_your_timestep/)).

- **Prove each check by breaking things on purpose.** Meta's ACH system plants small faults and generates tests that catch them; engineers accepted 73% of the 571 tests it produced ([arXiv, 2025-01](https://arxiv.org/abs/2501.12862)).
  - *For Pillagers:* every new check must go red against 1-3 faults planted in a scratch copy before it joins the corpus.

- **Fast sims are good for economy questions.** EA's simplified Sims Mobile simulator ran about 1,000x faster and found a real tuning error ([arXiv, 2018, older](https://ar5iv.labs.arxiv.org/html/1811.06962)). That fits your note that the bot doesn't play like you: use it for loot value and payouts, not combat feel. An LLM test agent for MMOs completed 95% of its tasks ([TITAN, 2025-09](https://arxiv.org/abs/2509.22170)). Occasional menu-exploring runs with a text state dump could find bugs like dead buttons.

- **Seeded maps.** Push hundreds of seeds through the generator and check that every spawn can reach every extract, saving any failing seed ([Bugnet](https://bugnet.io/blog/how-to-fix-roguelike-unbeatable-generated-levels)).
  - *For Pillagers:* route on `map.navD` for all 16 extract points.

- **Performance on real machines.**
  - The Long Animation Frames API reports frames over 50 ms but blames the main loop's entry point, not the slow line inside it ([Chrome](https://developer.chrome.com/docs/web-platform/long-animation-frames)). Pair it with per-system timers inside the loop.
  - CPU throttling doesn't simulate the GPU ([Chrome, 2025-04-04](https://developer.chrome.com/blog/devtools-grounded-real-world)), so a throttled run doesn't prove 4K smoothness.
  - Advice to fail when p95/p99 frame times get about 10% worse than the last build is **(unconfirmed)** ([PerfGuard listing](https://www.fab.com/listings/3af3bee7-22dd-4cf6-be53-364265b4a301)). Measure the noise between two runs of the same build first.

- **Background throttling in test Chromes.** GitLab found headless Chrome skipped animation frames until it added `--disable-backgrounding-occluded-windows` ([GitLab MR](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/193013)). The other flags and the power-draw anecdote are **(unconfirmed)**.
  - *For Pillagers:* close gate Chromes when a run ends, since a window that never idles is extra load on a PC that freezes.

- **Pixel density.** Simon Willison's one-shot browser game drew its canvas at 2x on phones, and only tests at real sizes and densities caught it ([Willison, 2026-08-05](https://simonwillison.net/2026/Aug/5/raccoon-heist/)). Pinning DPR keeps checks repeatable but hides scaling bugs.

- **Crash reports and telemetry.**
  - Install both `error` and `unhandledrejection` listeners before any game code. A throw inside the animation loop silently freezes the canvas ([Bugnet, 2026-03-01](https://bugnet.io/blog/crash-reporting-for-javascript-canvas-games)).
  - Cloudflare Analytics Engine stores up to 20 text and 20 number fields per row and keeps data three months ([limits](https://developers.cloudflare.com/analytics/analytics-engine/limits/)). The free plan includes 100,000 writes a day ([pricing](https://developers.cloudflare.com/analytics/analytics-engine/pricing/)). That's enough for one row per raid in a friends alpha.

- **Network faults.** Chromium's own tests drop packets on purpose through a virtual socket ([WebRTC source](https://webrtc.googlesource.com/src/+/bb4170df2e/pc/data_channel_integrationtest.cc)).
  - *For Pillagers:* put test-only drop, delay and freeze switches around the data channel's `send()`, and assert both clients' state hashes agree again afterwards.

### 2.7 Co-op

- **Let the host's tab be the server.** Voidgun, a browser shooter, runs the authoritative server inside the host's tab at 45 Hz with up to 32 players and bots. The host's own client talks to it in memory, and remote players connect over WebRTC. The host's upload bandwidth, not CPU, is the limit ([Voidgun devlog, about March 2026, date unconfirmed](https://voidgun.itch.io/voidgun/devlog/1448660/how-bringing-a-udp-game-to-the-browser-led-me-to-build-a-cross-platform-webrtc-library-for-libgdx)).
  - *For Pillagers:* P1 and same-PC P2 use the in-memory path, and only online joiners use WebRTC. Keep snapshots small.

- **Two channels and concrete timeouts** (same Voidgun devlog):
  - a reliable, ordered channel for events (chat, kills, flags);
  - an unreliable one for inputs and snapshots, which removed 50-200 ms stalls on packet loss;
  - drop packets when the send buffer passes 64 KB;
  - after an ICE disconnect, wait 3.5 s, then restart ICE (ICE is the step where two browsers find a working network path);
  - retry ICE failures at 2/4/8 s;
  - reconnect fully after 6 s with no snapshot.
  - Without TURN, 15-20% of players couldn't connect at all. The often-quoted 10-25% relay range comes from vendor blogs **(unconfirmed)**.

- **Cheap infrastructure.**
  - Cloudflare TURN costs $0.05/GB to the client, with a free 1,000 GB allowance; incoming traffic and STUN are free ([TURN FAQ](https://developers.cloudflare.com/realtime/turn/faq/)). Whether that allowance is monthly isn't stated on the page. My estimate: a 500-byte snapshot at 30 Hz is about 54 MB per relayed player-hour.
  - TURN credentials must be minted by a server call, never stored in the HTML. The returned list includes a port-53 address that browsers block, so filter it out or connecting can hang ([credentials](https://developers.cloudflare.com/realtime/turn/generate-credentials/)).
  - Durable Objects work on the free plan. Idle "hibernating" WebSocket rooms aren't billed, and incoming messages are billed at 20 per request ([pricing](https://developers.cloudflare.com/durable-objects/platform/pricing)). Every deploy drops all WebSockets ([WebSocket best practices](https://developers.cloudflare.com/durable-objects/best-practices/websockets/), not re-checked).
  - *For Pillagers:* use one tiny Worker with one hibernating room per join code for signaling, plus credential minting. Deploy it outside play sessions.

- **Later PvP needs a neutral host.** A Durable Object allows 1,000 requests per second per object and 30 s of CPU per request by default ([limits](https://developers.cloudflare.com/durable-objects/platform/limits/)). Whether a 30 Hz loop stays steady inside one is unmeasured. Hathora's game hosting shut down in May 2026 ([Supercraft, competitor blog](https://crux.supercraft.host/blog/hathora-shut-down-where-to-go-after-may-2026/)). Avoid any setup that one vendor's closure could switch off.

- **Smooth remote movement** ([Gaffer On Games, 2014 and 2015, older](https://gafferongames.com/post/snapshot_interpolation/)):
  - draw remote players about 3 send intervals in the past, so 150 ms at 30 snapshots per second;
  - send velocity so slow movers don't stutter;
  - don't predict AI movement far ahead.
  - Compression ([snapshot compression](https://gafferongames.com/post/snapshot_compression/)): send only what changed since the last snapshot the joiner confirmed, and 1 bit for each unchanged entity.
  - *For Pillagers:* hundreds of sleeping containers cost about one bit each, and the map never needs sending; the seed rebuilds it.

- **Fair hits for the joiner.** The host rewinds targets to what the shooter saw, roughly render delay plus round-trip time plus one tick. Colyseus 0.18 defaults to a 500 ms maximum rewind and records history at each broadcast ([Colyseus](https://docs.colyseus.io/netcode/lag-compensation)). For co-op with no team damage, keep about 500 ms of AI position history on the host.
  - Skip "rollback" netcode, which needs a perfectly repeatable world. NetplayJS falls back to sending host state when a game isn't repeatable ([NetplayJS](https://github.com/rameshvarun/netplayjs)).

- **Browser throttling can kill co-op.**
  - Hidden tabs get no `requestAnimationFrame` and timers only once a second. An open data channel only exempts a tab from the harsher once-a-minute throttling. Sound played in the last 30 s keeps throttling light ([Chrome, 2021, older](https://developer.chrome.com/blog/timer-throttling-in-chrome-88)).
  - On Windows, a fully covered Chrome window stops rendering, and a partly visible one doesn't ([Chromium](https://chromium.googlesource.com/chromium/src/+/main/docs/windows_native_window_occlusion_tracking.md)).
  - *For Pillagers:* run the host sim on a fixed timer, not `requestAnimationFrame`, and show joiners a "host paused" state. In same-PC mode, never let one window fully cover the other. Electron's `backgroundThrottling: false` fixes this in a desktop port ([Electron](https://www.electronjs.org/docs/latest/api/structures/web-preferences)).

- **Controllers in a second window.** Chromium's gamepad maintainer says some operating-system input APIs only deliver controller input to the focused window, and behaviour differs between controllers ([W3C list, 2024, older](https://lists.w3.org/Archives/Public/public-webapps-github/2024Sep/0476.html)).
  - *For Pillagers:* have one master window read every pad and forward P2's input over BroadcastChannel ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/Broadcast_Channel_API)). Give the channel a per-session name so test tabs don't hear each other. Identify pads by id plus index ([MDN Gamepad](https://developer.mozilla.org/en-US/docs/Web/API/Gamepad_API/Using_the_Gamepad_API)).
  - Rumble (`playEffect`) fails in a hidden page, and a new effect replaces the one already playing ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/GamepadHapticActuator/playEffect)), so fire rumble from a visible window.

- **Small details.**
  - Send the large raid-join state in chunks of 16 KB or less on the reliable channel; one big message blocks everything behind it ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Using_data_channels)).
  - Use 6-digit join codes. Digits avoid look-alikes such as 0/O and 1/I and can be entered with a D-pad ([thoughtbot, 2025-11-10](https://thoughtbot.com/blog/join-code-system-design)).
  - With 4 players, Cloudflare's SFU (a relay that copies one stream to several players) can fan one snapshot stream out, cutting the host's upload ([SFU](https://developers.cloudflare.com/realtime/sfu/datachannels/)).
  - WebTransport shipped in Safari 26.4 ([WebKit, 2026-03-24](https://webkit.org/blog/17862/webkit-features-for-safari-26-4/)). It is only relevant if a dedicated server exists.
  - For Steam, Valve calls the old P2P networking API deprecated ([Steamworks](https://partner.steamgames.com/doc/features/multiplayer/networking)). The exact API surface of the Electron binding steamworks.js is **(unconfirmed)** ([steamworks.js](https://github.com/ceifa/steamworks.js)).
  - Keep transport behind one `send(reliable|unreliable)` interface so it can be swapped later.

---

## 3. Prioritised action list for Pillagers

Effort: **Small** = about one build; **Medium** = a few builds; **Large** = a multi-build project. Risk = chance of breaking play, feel or the harness.

| # | Change | Why | Effort | Risk |
|---|---|---|---|---|
| 1 | Make the ship gate a **Stop hook** that prints one verdict line and exits early when `stop_hook_active` is set. Use the same line in a bounded `/goal` for long runs. | No unattended turn can end on a red build. The harness enforces it instead of memory. | Small | Low. The 8-block cap and the guard stop it looping. |
| 2 | **Rule hooks:** block commands containing `:8802`; after any Bash, PowerShell or Edit call that changed the game file, run parsecheck and reject non-ASCII `.ps1` files; re-add key state after compaction; git commit before every patch run. | Hard rules hold even when memory slips, and shell edits can't be undone with `/rewind`. | Small | Low |
| 3 | **Trim MEMORY.md** well under 200 lines/25KB, fold old lessons into topic files, and move the ship flow into a `/ship` skill. Set workflow concurrency to 4 when agents may open Chrome. | Entries past the limit stop loading without warning. Skills cost nothing until used. | Small | Low. Move entries, never delete them. |
| 4 | Add a fixed-step **`__advance(ms)`** hook that runs the real update, and a **`render_game_to_text()`** state dump. | Removes hidden-pane, `requestAnimationFrame` and DPR flakes. Gives checks and agents a cheap state read. It's the only fully repeatable path on Windows. | Medium | Medium. It must call the real update, not a copy. |
| 5 | **Hash each system's state** every 60 ticks of a seeded, scripted raid. | A red check names the first tick and the system that changed. Later it catches co-op desync. | Medium | Low |
| 6 | **Prove every new check** against 1-3 faults planted in a scratch copy. | Ends "green for the wrong reason" and exposes checks that never go red. | Small | Low |
| 7 | **Static data checks:** every item, flag and setting defined in data is read somewhere in code; every function called by name exists; no new inline colour values outside a palette table. | Catches the most common AI bug types (Grumbulus) and keeps the art style consistent. | Small | Low. Some false alarms. |
| 8 | **Same-PC input routing:** one master window reads every pad and forwards P2's input over a per-session BroadcastChannel; identify pads by id plus index; prevent full window cover; rumble only from a visible window. | Unfocused or covered windows can lose controller input or stop drawing on Windows. Two-player is the current focus. | Medium | Medium |
| 9 | **Harden online co-op:** host sim on a fixed timer, not `requestAnimationFrame`; reliable and unreliable channels; TURN through a tiny Worker that mints credentials; join rooms in a hibernating Durable Object; 6 s without a snapshot promotes the joiner's last checkpoint; a "host paused" state. | Without TURN, about 1 friend in 5 can't join. A hidden host tab freezes the raid. It also implements your ruling that the remaining player picks up the raid. | Medium-Large | Medium-High |
| 10 | **Extend the crash catcher:** make it the first script; catch `error` and `unhandledrejection`; add a watchdog for a frozen loop; record build, seed, mapIx and recent inputs. Send one Analytics Engine row per raid. | Friends' crash reports become replayable, and you get free balance data for the Halloween alpha. | Medium | Low. Send no personal data. |
| 11 | **Menus and inventory:** a distinct silhouette per item class, a looted-vs-equipped comparison on focus, one or two fonts on a fixed size scale, drag-off and bulk actions. | Marathon's 2026 launch was criticised for exactly these problems, and menus are your ship blocker. | Medium | Low |
| 12 | **One notification manager:** priority tiers, merged repeats ("Scrap x3"), a cap per corner and per window. | Stops floods of pickup messages from hiding "partner downed" or "extract closing". | Medium | Low |
| 13 | **TV readability checks** plus a "Large for TV" HUD preset: text at least 52 px at 2160p, 4.5:1 contrast with backing plates, HUD inside the middle 90%, text scale up to 200%. | Concrete Xbox rules for couch play at 4K, all measurable headlessly. | Medium | Low |
| 14 | **Feel pass:** trauma-based shake per window (world only, HUD steady, roll near 0); render-only hitstop on the victim; muzzle flash on frame one; 1-frame white hit flash; casings and decals that stay; hit-confirm sound on the same frame. | These are the specific techniques that make shots feel heavy, and all are cheap in Canvas 2D. | Medium | Medium. Feel is your call, so add sliders. |
| 15 | **Visible damage** on monsters and machines (sparks, smoke, broken plates by HP fraction). Keep crisp hit markers for fights against raiders. | ARC Raiders' approach, and it reads from the couch where thin HP bars don't. | Medium | Low |
| 16 | **Audio mix:** category volume groups, priority ducking, music EQ ducking, slower distance fade for big threats, looping enemy sounds per state, synth voices pre-rendered at boot. Add offline-render cue checks. | The Helldivers 2 and ARC Raiders practices for readable combat sound. The checks catch silent or clipping cues without ears. | Medium | Medium |
| 17 | **Render Scale setting:** world at 0.5-1.0 of 4K with the HUD at native resolution, dropping automatically on slow frames. | The biggest frame-budget win at 4K, and it makes every later effect cheaper. | Medium | Medium. A softer image, so keep text native. |
| 18 | **Finish baking** trees, shadows, props and glows; remove per-frame `shadowBlur` and `ctx.filter`; add a draw-call ceiling to the gate. | MDN's top advice, and your own profile found one source producing 3,500 `fillRect`s per frame. | Medium | Low |
| 19 | **Animation pass:** walk cycles, recoil, hit reactions, downed and death poses, including each BUILD body. | Missing animation is the visible tell of cheap AI-built games. | Large | Medium |
| 20 | **Snapshot efficiency:** send only changes since the last confirmed state, draw remote players 100-150 ms in the past using velocity, and keep about 500 ms of AI history to rewind joiners' shots. | Host upload is the bottleneck. This gives smooth movement and fair hits. | Large | Medium |
| 21 | **One shared fixed-step update** for the live loop, `__sim` and the bot, plus a check that bans `Math.random`, DOM and canvas calls in update code. | Closes the gap between the sim and the real game, and makes A/B tests, replays and co-op exact. | Large | High. It changes timing and seeded streams, so do it after #5. |
| 22 | **Quarter-size light map** (ambient, additive lights, multiply) plus wall visibility polygons for line of sight. | The cheapest route to AAA mood and fog of war without WebGL. | Medium-Large | Medium. Measure frame cost. |
| 23 | **Small DPR check matrix** (1920x1080 at 1x and 2x, 3840x2160 at 1x), checking layout rules only. | Pinning DPR hides real scaling bugs like the one in Willison's game. | Small | Low |
| 24 | **Visual reviewer subagent:** your approved and rejected shots as examples, full-resolution 4K crops, one run per batch, used for polish notes and not as the pass. | Turns "take pictures" into scored feedback without the builder grading itself. | Small | Low |
| 25 | **Before any WebGL:** in a scratch page, time uploading a 4K canvas to WebGL on your GPU; choose GPU or SwiftShader flags for the gate; keep Canvas 2D as a tested fallback. | Headless WebGL can now fail to start, and nobody documents the upload cost. | Small | Low |

---

## 4. What to avoid

- **Treating a screenshot verdict as a pass.** Models score under 50% at spotting visual regressions and invent glitches. Use screenshots for polish and triage, and gate on state and pixel hashes.
- **Letting the builder grade itself, or letting reviewers chase every gap.** Anthropic warns that this leads to over-engineering.
- **Big multi-agent studio templates.** They mean more upkeep than help for a solo developer.
- **Two agents writing the one game file at once.** Keep one writer and make every other agent a read-only auditor. If you ever split the file, use a mechanical script and confirm the rebuilt file is byte-identical. Never let a model rewrite code during the split.
- **Switching engines for agent tooling, a three.js 3D rewrite, or jumping to WebGPU.** None of these is needed, and each would throw away the procedural art or the check suite.
- **Blurring at 4K every frame, or setting `ctx.filter` inside draw loops.** It's especially slow in Firefox.
- **`alert`, `confirm` or `prompt` in the game.** Agents can't see them and they block automation.
- **Rollback netcode** for a 45,000-line game that uses floating-point math everywhere.
- **Driving the host sim from `requestAnimationFrame`, or letting one same-PC window fully cover the other.**
- **STUN-only co-op**, and **putting the TURN key in the HTML**.
- **Vendors that can vanish or hard-cap players.** Hathora closed in May 2026, and Photon's pricing couldn't be verified.
- **Shipping assets under unclear licences:** Udio, Suno without paid counted downloads, Hunyuan3D for a worldwide release, XTTS v2 voices, or free-tier ElevenLabs without attribution.
- **AI voices for characters players care about.** Keep any AI voice to short utility callouts, and disclose it.
- **Ticking "No AI" on itch.** The honest answer is at least "Yes: Code", and a false tag costs discovery listing.
- **A 10-degree camera roll, shaking the HUD, or freezing the whole world for hitstop** in co-op.
- **Very long lines:** inlined minified libraries or huge base64 assets. A GitHub report links them to Claude Code hangs **(unconfirmed)**.
- **Trusting bot-sim numbers for fun or combat balance.** Use the sim for economy questions, and your playtests for feel.
- **Bringing back gun wear or jamming** from games like SYNTHETIK. Your ruling stands.
- **Leading any marketing with "made by AI".** Player sentiment toward that label is still negative.

---

## 5. Sources

**Claude Code practice**
- https://code.claude.com/docs/en/best-practices
- https://code.claude.com/docs/en/hooks-guide
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/memory
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/context-window
- https://code.claude.com/docs/en/workflows
- https://code.claude.com/docs/en/goal
- https://code.claude.com/docs/en/skills
- https://code.claude.com/docs/en/plugins/code-intelligence
- https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more (2026-06-18)
- https://claude.com/blog/improving-frontend-design-through-skills (2025-11-12)
- https://www.anthropic.com/engineering/harness-design-long-running-apps (2026-03-24)
- https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents (2025-11-26)
- https://platform.claude.com/docs/en/build-with-claude/vision
- https://www.productionalchemist.com/p/claude-code-game-studios-49-agents (2026-05-19)
- https://unity.com/blog/unity-ai-mcp-how-to-get-started (2026-05)
- https://www.summerengine.com/blog/best-godot-mcp-server (2026)
- https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md
- https://developer.chrome.com/blog/chrome-devtools-mcp (2025-09-23)

**What other AI-built games learned**
- https://levels.io/vibe-jam-2026-winners-quality (2026-06-17)
- https://vibejam.com/2026/press
- https://wccftech.com/ios-developer-made-capybara-game-using-vibe-coding-and-won-25000/ (2026-07-13)
- https://gonzoml.substack.com/p/how-we-built-a-full-browser-game (2026-03-25)
- https://barretblake.dev/posts/development/2026/03/ai-roguelike/ (2026-03-16)
- https://gigazine.net/gsc_news/en/20251215-codex-mortis/ (2025-12-15)
- https://store.steampowered.com/app/4084120/CODEX_MORTIS/ (not re-checked)
- https://github.com/levy-street/world-of-claudecraft
- https://www.loopedin.games/blog/how-i-built-void-balls-using-ai (2026-06-19)
- https://github.com/opusgamelabs/game-creator
- https://app.cinevva.com/signals/2026-03-23-solo-devs-shipping-not-vibing (2026-03-23)
- https://levels.io/full-multiplayer-python-websockets-game-ai (2025-02-22)
- https://www.summerengine.com/blog/cursor-vibe-jam-2026-guide (2026-06-06)
- https://wnhub.io/news/stores-and-publishing/item-48292 (2025-07)

**What AAA feel is made of**
- https://infovore.org/?p=5275 (2013, older)
- https://bevy.org/examples/camera/2d-screen-shake/
- https://sourcegaming.info/2015/11/11/thoughts-on-hitstop-sakurais-famitsu-column-vol-490-1/ (2015, older)
- https://gamingbolt.com/arc-raiders-lacks-enemy-hp-bars-since-embark-doesnt-want-you-playing-the-excel-sheet-of-a-game (2025-11-05)
- https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-101-text-display.md
- https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-102-contrast.md
- https://devdocs.xbox.com/build/core-features/graphics/overviews/screen-areas
- https://arcraiders.wiki/wiki/Game_UI
- https://marathonhub.gg/news/bungie-says-marathons-ui-will-improve-but-the-sauce-is-staying/ (2026-03-03)
- https://www.shacknews.com/article/148342/marathon-update-1-0-5-patch-notes (2026-03-17)
- https://www.asoundeffect.com/helldivers-2-game-sound-design/ (2024, older)
- https://arcraiders.com/news/soundscapes-blog (2025-09-03)
- https://gamedeveloper.com/design/enemy-attacks-and-telegraphing (2015, older)
- https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers (2015, older)
- https://caniplaythat.com/?p=14083 (2024, older)
- https://www.synthetikgame.com/weapons (game 2018, older)
- https://insider-gaming.com/how-to-customize-the-hud-in-black-ops-6/ (2024, older)
- https://shacknews.com/article/110042/how-to-change-damage-numbers-in-apex-legends (~2019, older)
- https://runescape.wiki/w/Loot_beam
- https://app.studyraid.com/en/read/100682/4508374/structuring-notification-layers-for-game-events (low confidence)
- https://www.nintendolife.com/reviews/switch-eshop/nuclear_throne (2019, older)
- https://www.invenglobal.com/articles/20259/nexon-reveals-arc-raiders-reboot-story-at-gdc-2026-after-massive-aaa-reset (2026-02-26)

**Visuals and performance in the browser**
- https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas (2026-08-25)
- https://developer.playcanvas.com/user-manual/optimization/runtime-devicepixelratio/
- https://developer.chrome.com/blog/animated-blur/ (2017, older)
- https://bugzilla.mozilla.org/show_bug.cgi?id=1978851
- https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/globalCompositeOperation
- https://ncase.me/sight-and-light/ (~2014, older)
- https://phaser.io/tutorials/phaser-4-rendering-concepts
- https://pixijs.com/blog/pixi-v8-launches (2024, older)
- https://pixijs.com/8.x/guides/concepts/performance-tips
- https://chromium.googlesource.com/chromium/src/+/da170c2267b2201954efe1c8fa5d2d89ab09f7bf/docs/gpu/swiftshader.md
- https://codereview.chromium.org/735623003 (2014, older)
- https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices (2026-10-07)
- https://web.dev/blog/webgpu-supported-major-browsers (2025-11-25)
- https://webgl2fundamentals.org/webgl/lessons/webgl-instanced-drawing.html
- https://blog.frost.kiwi/dual-kawase/ (2025-09)
- https://www.cg.tuwien.ac.at/courses/Realtime/repetitorium/VU.WS.2013/Color-Grading.pdf (2013, older)
- https://jason.today/gi (2024, older)
- https://iquilezles.org/articles/rmshadows/ (older)
- https://arxiv.org/abs/2505.02041v1 (2025-05)
- https://ar5iv.labs.arxiv.org/html/2212.09692 (2022, older)
- https://blog.google/chromium/introducing-skia-graphite-chromes/ (2025-07-08)
- https://web.dev/articles/offscreen-canvas (2023, older)
- https://threejs.org/docs/pages/OrthographicCamera.html
- https://claudemarketplaces.com/skills/martinholovsky/claude-skills-generator/webgl (low confidence)

**Art and audio**
- https://partner.steamgames.com/doc/gettingstarted/contentsurvey
- https://www.gamingonlinux.com/2026/01/valve-tweak-steam-ai-disclosure-form-for-developers-to-clarify-its-for-content-consumed-by-players/
- https://itch.io/t/4309690/generative-ai-disclosure-tagging (2024, older)
- https://www.gamineai.com/blog/steam-ai-disclosure-debate-what-indies-decide-after-sweeney-2026
- https://kotaku.com/arc-raiders-replaced-ai-generated-content-human-recorded-dialogue-voices-2000678774 (2026-03-13)
- https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert
- https://elevenlabs.io/sound-effects/commercial
- https://glama.ai/mcp/servers/elevenlabs/elevenlabs-mcp
- https://elevenlabs.io/eleven-music-model-specific-terms (updated 2026-10-09)
- https://routenote.com/blog/suno-announces-20-monthly-downloads-and-new-music-industry-models/ (2026-08-12)
- https://www.digitalmusicnews.com/2025/10/31/udio-downloads-disabled-umg-deal/ (not re-checked)
- https://the-decoder.com/stability-ai-launches-stable-audio-3-0-with-up-to-six-minute-tracks-and-open-weights/ (2026-05-20)
- https://github.com/ahujasid/blender-mcp
- https://foozlecc.itch.io/render-4-or-8-direction-sprites-from-blender
- https://app.cinevva.com/guides/ai-3d-model-generators (2026-07-17)
- https://github.com/0x0funky/agent-sprite-forge
- https://app.cinevva.com/guides/ai-pixel-art-generators (2026-09-04)
- https://www.pixellab.ai/llms.txt
- https://skills-hub.ai/skills/agent-sprite-forge-codeart2d
- https://ipwatchdog.com/2025/01/29/part-two-copyright-office-ai-report-says-creative-prompting-doesnt-constitute-authorship/ (2025-01-29)
- https://app.cinevva.com/guides/ai-voice-acting-games (2026-07-17)
- https://keithclark.co.uk/articles/zzfxm/
- https://lists.w3.org/Archives/Public/public-audio/2013OctDec/0211.html (2013, older)
- https://webkit.googlesource.com/WebKit/+/master/LayoutTests/webaudio/Oscillator/osc-sweep-snr-sine.html

**Testing**
- https://skills.cat/skills/trailofbits/skills-curated/openai-develop-web-game
- https://smithery.ai/skills/davila7/develop-web-game
- https://www.heygen.com/research/html-to-video (2026-06-22)
- https://playwright.dev/docs/clock
- https://playwright.dev/docs/api/class-pageassertions
- https://playwright.dev/docs/test-snapshots
- https://arxiv.org/abs/2208.02335 (2022, older)
- https://arxiv.org/html/2505.15952v2 (2025)
- https://www.anthropic.com/engineering/building-c-compiler (2026-02-05)
- https://github.com/microsoft/playwright-cli
- https://factorio.com/blog/post/fff-60 (2014, older)
- https://factorio.com/blog/post/fff-47 (older, not re-checked)
- https://gafferongames.com/post/fix_your_timestep/ (2004, older)
- https://arxiv.org/abs/2501.12862 (2025-01)
- https://ar5iv.labs.arxiv.org/html/1811.06962 (2018, older)
- https://arxiv.org/abs/2509.22170 (2025-09)
- https://bugnet.io/blog/how-to-fix-roguelike-unbeatable-generated-levels
- https://developer.chrome.com/docs/web-platform/long-animation-frames
- https://developer.chrome.com/blog/devtools-grounded-real-world (2025-04-04)
- https://www.fab.com/listings/3af3bee7-22dd-4cf6-be53-364265b4a301 (low confidence)
- https://gitlab.com/gitlab-org/gitlab/-/merge_requests/193013 (2025)
- https://simonwillison.net/2026/Aug/5/raccoon-heist/ (2026-08-05)
- https://bugnet.io/blog/crash-reporting-for-javascript-canvas-games (2026-03-01)
- https://developers.cloudflare.com/analytics/analytics-engine/limits/
- https://developers.cloudflare.com/analytics/analytics-engine/pricing/
- https://webrtc.googlesource.com/src/+/bb4170df2e/pc/data_channel_integrationtest.cc

**Co-op**
- https://voidgun.itch.io/voidgun/devlog/1448660/how-bringing-a-udp-game-to-the-browser-led-me-to-build-a-cross-platform-webrtc-library-for-libgdx (about March 2026)
- https://developers.cloudflare.com/realtime/turn/faq/
- https://developers.cloudflare.com/realtime/turn/generate-credentials/
- https://developers.cloudflare.com/durable-objects/platform/pricing
- https://developers.cloudflare.com/durable-objects/best-practices/websockets/ (not re-checked)
- https://developers.cloudflare.com/durable-objects/platform/limits/
- https://crux.supercraft.host/blog/hathora-shut-down-where-to-go-after-may-2026/
- https://gafferongames.com/post/snapshot_interpolation/ (2014, older)
- https://gafferongames.com/post/snapshot_compression/ (2015, older)
- https://docs.colyseus.io/netcode/lag-compensation
- https://github.com/rameshvarun/netplayjs
- https://developer.chrome.com/blog/timer-throttling-in-chrome-88 (2021, older)
- https://chromium.googlesource.com/chromium/src/+/main/docs/windows_native_window_occlusion_tracking.md
- https://www.electronjs.org/docs/latest/api/structures/web-preferences
- https://lists.w3.org/Archives/Public/public-webapps-github/2024Sep/0476.html (2024, older)
- https://developer.mozilla.org/en-US/docs/Web/API/Gamepad_API/Using_the_Gamepad_API
- https://developer.mozilla.org/en-US/docs/Web/API/Broadcast_Channel_API
- https://developer.mozilla.org/en-US/docs/Web/API/GamepadHapticActuator/playEffect
- https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Using_data_channels
- https://thoughtbot.com/blog/join-code-system-design (2025-11-10)
- https://developers.cloudflare.com/realtime/sfu/datachannels/
- https://webkit.org/blog/17862/webkit-features-for-safari-26-4/ (2026-03-24)
- https://partner.steamgames.com/doc/features/multiplayer/networking
- https://github.com/ceifa/steamworks.js (API surface unconfirmed)