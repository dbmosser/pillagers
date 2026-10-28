# Player alerts and HUD messaging in top-down, isometric and twin-stick games

Scope: how games with an overhead camera and the player near screen centre place danger warnings, pickups and loot, objective updates, teammate events and system notices, and what that means for a 2.5D 3/4 top-down extraction shooter.

Source quality note for the writer: primary developer material on HUD decisions in these games is thin online. The strongest primary items found are Blizzard's Diablo IV quarterly update (2020, via press summaries), Blizzard's Season 4 "Loot Reborn" statements (2024), Arrowhead's Johan Pilestedt on the PlayStation Blog (2024), Supergiant's Hades II UI job posting, and patch notes or option lists for Vampire Survivors. Much of the rest is reviews, fan wikis and forum threads. Each line below says which kind it is. Lines marked "background, not verified this session" come from the researcher's general knowledge and must not be presented as sourced fact.

## 1. Where do these games put danger warnings, pickups and loot, objective updates, teammate events and system notices? What goes in world space vs fixed HUD corners?

### Takeaway
Documented patterns split cleanly: persistent status (health, skills, ammo, reinforcements, objectives) sits in fixed screen corners or a bottom bar, while per-enemy and per-item information (status words, damage numbers, item labels) is drawn in world space over the thing it describes. The world-space layer is where clutter complaints concentrate.

### Cited Findings
- Diablo IV (isometric ARPG): Blizzard's first quarterly update listed "consideration of the positioning of the in-action game UI to accommodate PC/console players and the isometric camera" as a design task, which shows the camera angle was an explicit input to HUD placement. Press summary, not a direct quote of a named developer. [RPG Site](https://www.rpgsite.net/news/9492-diablo-iv-discusses-ui-design-coop-controller-support-and-cannibals-in-first-quarterly-update) (2020)
- Diablo IV moved the skill (action) bar from bottom-left back toward bottom-centre after BlizzCon feedback; PC players can choose left or centre, console stays left. [Android Central](https://www.androidcentral.com/diablo-iv-february-2020-quarterly-update) (2020)
- Diablo IV two-player couch co-op lets each player open menus on their own side of the shared screen so one player does not block the other. [Android Central](https://www.androidcentral.com/diablo-iv-february-2020-quarterly-update) (2020); [RPG Site](https://www.rpgsite.net/news/9492-diablo-iv-discusses-ui-design-coop-controller-support-and-cannibals-in-first-quarterly-update) (2020)
- Diablo IV inventory: icon backgrounds toned down and rarity indicators made subtler; item icons changed from painterly art to 3D model renders for visibility. [KitGuru](https://www.kitguru.net/gaming/matthew-wilson/blizzard-shares-new-diablo-iv-details-in-quarterly-developer-update/) (2020); [Android Central](https://www.androidcentral.com/diablo-iv-february-2020-quarterly-update) (2020)
- Diablo IV world-space text: during the 2023 beta, players reported status words floating above monsters across the whole screen ("Fortified" repeating over every monster roughly every 0.5 s; "VULNERABLE" popping up everywhere; "immune", "absorbed"), and a "that skill is not ready" banner in the middle of the screen. Forum thread, player reports. [Blizzard forums](https://us.forums.blizzard.com/en/d4/t/please-please-remove-the-floating-combat-text/13017) (2023-03-28)
- Helldivers 2 (third-person, used here only as a contrast case for corner layout): equipment and health with a player tag such as "A1" in the bottom-left; stratagem list with reinforcement counter and main objectives in the top-right; a compass across the top showing map markers relative to the player. Fan wiki. [Helldivers wiki](https://helldivers.wiki.gg/wiki/Heads-Up_Display) (accessed 2026)
- Helldivers (2015) is an overhead co-op twin-stick shooter (PS3, PS4, Vita in March 2015; Windows December 2015); almost every weapon or tool can hurt teammates. [Wikipedia](https://en.wikipedia.org/wiki/Helldivers) (accessed 2026)
- Hades keeps a fixed 16:9 frame and pillarboxes at wider ratios; a fan mod (Hephaistos) is needed to stretch the HUD horizontally. This implies its corner HUD is laid out for a 16:9 safe frame. [WSGF](https://www.wsgf.org/dr/hades) (year not stated)
- Supergiant's Hades II UI illustrator posting describes the job as making UI and HUD mock-ups "based on gameplay requirements" and asks for experience with accessibility standards. Primary, but a job ad, not a design statement. [Supergiant Games](https://www.supergiantgames.com/blog/job-opportunity-ui-illustrator-for-hades-ii) (year not stated on the snippet)
- Diablo III console port: a "completely redesigned user interface" built for controller play, with a tab and radial menu system that reviewers said made gear and skill swaps quick in couch co-op. Press coverage. [God is a Geek](https://godisageek.com/2013/02/diablo-iii-coming-ps3-ps4/) (2013); [Co-Optimus](https://co-optimus.com/article/10204/diablo-3-console-port-designed-around-controller-interaction.html) (2013)

### Inferences
- Across the documented cases, the split is: things that belong to an entity go on the entity (status words, numbers, labels), things that belong to the player's run go in a corner. A 3/4 top-down extraction shooter can follow that split, but should keep the world-space layer to a strict minimum (see question 3 and 4).
- Diablo IV's choice to bring the skill bar back to bottom-centre on PC suggests that, with the character at screen centre, the most glanced-at persistent element sits on the vertical line below the character, a short eye travel from the action. Inference from the move, not a stated Blizzard reason.
- Diablo IV's per-player menu halves for couch co-op are directly relevant to a same-screen 2-player game: each player's notices should live on that player's side or on that player's character, not in one shared central feed.
- Background, not verified this session: Enter the Gungeon puts hearts, blanks and keys top-left and the gun with ammo bottom-right; Diablo III and IV show ground item names on hover or while holding Alt; Diablo III and IV mark top-rarity drops with a light beam and a sound. These are commonly described but no source was retrieved.

### Gaps
- No primary source found on where Helldivers (2015) puts teammate, objective or reinforcement notices on screen. The wiki page retrieved covers Helldivers 2 only.
- No HUD layout source retrieved for Zero Sievert, Enter the Gungeon, Alienation, The Ascent (layout, as opposed to complaints), Ruiner, Synthetik, Hotline Miami, Halls of Torment, Shadowrun or XCOM. Game UI Database is the right place to check screens; its own guidance asks contributors to capture gameplay in several states (low and high health, cooldowns). [Game UI Database](https://www.gameuidatabase.com/about.php) (2024)

## 2. How do they keep the area around the player clear while still warning about threats off screen (edge indicators, minimap pings, sound)?

### Takeaway
The one primary developer statement found (Arrowhead) says the top-down view gives every player the same picture of the fight, which is why overhead games need far fewer directional threat cues than first or third person games. Where off-screen cues exist, the standard technique is an edge-clamped arrow that appears only while the target is off screen.

### Cited Findings
- Johan Pilestedt (Arrowhead CEO and creative director) on Helldivers 1 vs 2: "In a top-down perspective, everyone knows what the team members are doing and shares the same reality," while in Helldivers 2 "each player has their own perception of events." He also said the top-down distance "does not allow for more immersive experiences" and "you gain some and lose some from both approaches." Primary interview. [PlayStation Blog](https://blog.playstation.com/2024/03/12/helldivers-2-how-arrowhead-turned-the-twin-stick-shooter-original-into-a-bombastic-ps5-sequel/) (2024)
- First and third person shooters commonly flash the screen or part of it when the player is hit and show arrows pointing toward the threat. [Wikipedia, HUD (video games)](https://en.wikipedia.org/wiki/HUD_(video_games)) (accessed 2026)
- Off-screen indicator tooling used for top-down shooters offers an "offscreen only" mode (marker hidden while the target is visible) and an edge clamp that pins the marker to the screen border nearest the target, rotated toward it; the border can be a rectangle or an oval inset from the edges. Engine and asset documentation, not a shipped game. [HutongGames PlayMaker docs](https://hutonggames.com/playmaker/docs/guides/ui-widgets/target-managers/offscreen-indicator/) (year not stated); [Fab listing](https://www.fab.com/listings/b9382d55-1ce7-4025-a5b3-95e55708a8b4?lang=fr) (year not stated)
- Developers implement the edge clamp by projecting the target to screen space and clamping it to anchor points at the camera edges. Forum discussion. [Unity Discussions](https://discussions.unity.com/t/offscreen-enemy-indicator/420943) (old thread, year not stated); [Construct forum](https://construct.net/en/forum/construct-2/how-do-i-18/create-hud-icons-show-83014) (old thread, year not stated)

### Inferences
- With the player at screen centre and a 360 degree view, any threat that is on screen is already visible; a directional hit marker is only needed for threats beyond the view (shots from off screen, noises, alarms). That argues for edge-clamped markers that exist only while the source is off screen and vanish as soon as it enters view.
- An oval clamp inset from the screen edge keeps markers out of the corner HUD panels. A rectangle clamp puts markers right where corner panels sit. Inference from the tooling options above.
- In a 3/4 view the camera sees more ground above the character than below it only if the camera is offset; if the character is truly centred, top and bottom threats get equal warning distance. Worth checking the game's camera offset before tuning marker range. Inference.
- For a shared-screen 2-player game, Pilestedt's "shares the same reality" point suggests teammate state (downed, low health, carrying loot) is best shown on the teammate's own character, since both players can see it, rather than as a text feed. Inference.

### Gaps
- No source found on minimap pings or sound cues in Helldivers (2015), Zero Sievert, Alienation or The Ascent.
- No developer talk found that compares edge arrows with minimap pings or with audio-only warnings in a top-down game.
- No source found on how Hotline Miami (which uses a look-ahead camera rather than a fixed centre) handles off-screen threats.

## 3. How do they handle loot text (item labels on the ground, pickup feeds) without clutter? Filters, rarity colour, merging?

### Takeaway
Two documented fixes exist: player-side filtering (Path of Exile's item filters, carried into Path of Exile 2 with strictness levels) and designer-side reduction (Diablo IV Season 4 cut how many items drop so that players "spend more time obliterating and less time sorting"). Guides on both agree that loud signals should be saved for drops that change what the player does next.

### Cited Findings
- Path of Exile item filters let players customise how the client displays items on the ground; they were introduced with Path of Exile: The Awakening, version 2.0.0. Fan wiki. [Path of Exile Wiki (Fandom)](https://pathofexile.fandom.com/wiki/Loot_filter) (accessed 2026; release year of 2.0.0 is 2015 by background, not verified this session)
- The game ships a default filter but has no in-game filter editor; players write filters in a text editor or use third-party tools. Fan wiki. [Path of Exile Wiki (Fandom)](https://pathofexile.fandom.com/wiki/Guide:Item_filter_guide) (accessed 2026)
- Path of Exile 2: NeverSink's FilterBlade filter launched for early access with seven strictness levels from soft to uber-plus-strict, semi-strict recommended for beginners; filters are chosen in Options, Game tab, Item Filter. Third-party site. [Maxroll](https://maxroll.gg/poe2/news/filterblade-launch-for-path-of-exile-2) (2024, inferred from the PoE2 early access launch)
- A community PoE2 filter author describes a minimalist approach close to default label styles that hides Normal and Magic items and unusable gear halfway through the campaign; players in the thread asked for a global label-size control and clearer explanations. Official forum, player content. [Path of Exile forum](https://ru.pathofexile.com/forum/view-thread/3630063) (2025, inferred from a 0.3 reference)
- A console guide for PoE2 recommends reserving large text, bright colours and loud sounds for drops that change the player's next action. Guide site, opinion. [jeu.video](https://jeu.video/en/guide/path-of-exile-2-loot-filter-visibility-performance-controller) (year not stated)
- Diablo IV Season 4 "Loot Reborn": Blizzard said "by making items more individually impactful, we've significantly decreased the number of items that drop when slaying Monsters" and "the goal here is to spend more time obliterating and less time sorting through the many items that drop." Developer quotes as reported. [GameSpot](https://Gamespot.com/articles/how-diablo-4-loot-reborn-update-will-make-its-items-and-players-more-powerful-than-ever/1100-6523061/) (2024); [MMOs.com](https://mmos.com/news/diablo-4-season-4-loot-reborn-item-revamp) (2024)
- Season 4 also cut affix counts (3 on legendaries, 2 on rares) and moved legendary aspects into the Codex of Power on salvage so they no longer clog stash and inventory. [MMOs.com](https://mmos.com/news/diablo-4-season-4-loot-reborn-deep-dive) (2024); [Mein-MMO](https://mein-mmo.de/en/diablo-4-season-4-patch-notes-show-what-gets-better-less-loot-but-stronger,1121161/) (2024)
- Diablo IV's 2020 update made rarity indicators on inventory icons subtler and toned down icon backgrounds. [KitGuru](https://www.kitguru.net/gaming/matthew-wilson/blizzard-shares-new-diablo-iv-details-in-quarterly-developer-update/) (2020)

### Inferences
- For a game with a fixed loot table per container (rather than ARPG-scale showers of items), Diablo IV's designer-side fix (fewer, better drops) is cheaper and more reliable than a player-side filter, and it keeps the ground near the player readable without asking the player to configure anything.
- The PoE2 filter culture shows a tiered signal ladder: hidden, plain label, coloured label, larger label plus sound, beam plus sound. A small game can hard-code three rungs (quiet, coloured, loud) and reserve the loud rung for the few items that change the run (for example, an item worth extracting early). Inference.
- Players asking for a "global label size" control in PoE2 suggests label size is a common pain point even with filters. A single label-scale setting is a low-cost accessibility win. Inference.
- Background, not verified this session: Diablo III's 2014 "Loot 2.0" made the same "fewer, better drops" change Diablo IV repeated in 2024; pickup feeds in ARPGs usually merge repeated currency pickups into one running total.

### Gaps
- No primary Grinding Gear Games statement (talk, interview or official post) on why filters exist or on label clutter was retrieved; the poewiki.net page was blocked by bot protection.
- No source found on pickup feeds (the scrolling "you picked up X" list) in any of the listed games, or on merging repeated pickups.
- No source on Diablo IV ground labels, Alt-to-show behaviour, or loot beams.

## 4. Damage numbers and combat text: shown, hidden, merged, optional?

### Takeaway
The pattern in the documented games is "on by default, optional, and the option grows finer over time": Vampire Survivors has a damage numbers switch and a separate flashing effects switch; Diablo IV ended up with a three-way combat text mode after players complained that hiding damage numbers still left status words everywhere.

### Cited Findings
- Diablo IV's "display mode for combat texts" (Gameplay tab) offers three states: show all combat text, hide damage numbers, or hide all numbers for damage and status effects. Players on Reddit said the game reads better with numbers off and that hit strength can be judged from the enemy health bar; a minority enjoy the numbers or use them only on training dummies. No Blizzard comment in the article. [Mein-MMO](https://mein-mmo.de/en/the-best-builds-in-diablo-4-deal-billions-of-damage-players-say-its-much-better-without-numbers,1118780/) (2024-04-25)
- During the Diablo IV beta the only toggle hid damage numbers but left status words ("Fortified", "VULNERABLE", "immune", "absorbed") and the centre "that skill is not ready" banner on screen; players asked for a toggle for all combat text and for size and colour options, and said icons and health bar markers would be enough. [Blizzard forums](https://us.forums.blizzard.com/en/d4/t/please-please-remove-the-floating-combat-text/13017) (2023-03-28); [Blizzard forums, "Vulnerable be gone"](https://us.forums.blizzard.com/en/d4/t/vulnerable-be-gone/158183) (year not stated)
- Vampire Survivors has a "Damage Numbers" switch ("enable or disable displaying damage numbers"); a 0.9.0 fix (21 July 2022) made it hide recovery numbers too. A separate "Flashing VFX" switch exists, and in 1.6.0 (17 August 2023) the pentagram flash was made to respect it; 1.6.0 also added "Disable Blood", "Pixel Font" and a transparent border option. "Weapons ScreenShake" is its own switch. Fan wiki citing patch notes. [Vampire Survivors Wiki](https://vampire.survivors.wiki/w/Options) (2022, 2023)
- Vampire Survivors players report that turning off damage numbers and impact flashes "helped tremendously" with busy screens, and ask for a weapon effect opacity slider, a cap on displayed projectiles and a way to hide one weapon's effects. Player requests, not shipped features; the specific thread for each quote was not opened individually. [Steam discussion](https://steamcommunity.com/app/1794680/discussions/0/4631482569784862180); [Steam discussion](https://steamcommunity.com/app/1794680/discussions/0/3820781363199330417) (years not stated)
- A small survivors-style indie game made its damage numbers smaller, more muted and shorter-lived after finding they distracted from play. Developer devlog. [Castle Survivor devlog, itch.io](https://indieben.itch.io/castle-survivor/devlog/661003/improved-some-animations-and-visual-effects) (year not stated)
- Hades II: no vanilla damage number or screen shake toggle was found; a community mod adds reading damage numbers aloud for screen reader users. [Thunderstore](https://thunderstore.io/c/hades-ii/p/Lirin/Hades_2_TOLk_Compatibility/changelog) (year not stated)

### Inferences
- The Diablo IV sequence (one toggle in beta, complaints that status words remained, a three-state mode later) is a warning for any game that adds status words above enemies: plan the "hide all floating words" state from the start.
- The forum suggestion that icons and health bar markers are enough points to a cheaper design: show state changes on the enemy's health bar or as a small icon, not as a repeated word. Inference.
- "Fortified" repeating every 0.5 s over every monster is the clearest documented example of a rate problem: a status that is always true should be shown once (or as a persistent mark), not re-announced. Inference.
- Splitting "flashing effects" and "screen shake" from "damage numbers" (Vampire Survivors) matches what players actually complain about: the numbers, the flashes and the shake are three different discomforts. Inference.

### Gaps
- No source confirmed whether Hades, Enter the Gungeon, The Ascent, Ruiner, Synthetik, Alienation or Halls of Torment have damage number options or what their defaults are. A Halls of Torment Steam thread appeared in search but its content was not read. [Steam discussion](https://steamcommunity.com/app/2218750/discussions/0/3801652929323026410)
- No source on merging damage numbers (stacking hits into one rising total) in any of the listed games.
- The exact Diablo IV patch that introduced the three-state combat text mode was not found in official patch notes.

## 5. Developer talks, postmortems or interviews on HUD decisions (Blizzard Diablo IV UI, Supergiant on Hades UI, Grinding Gear on loot filters, Arrowhead on Helldivers 1)

### Takeaway
Only partial primary material was found: Blizzard's 2020 quarterly update on UI (via press), Blizzard's 2024 Loot Reborn rationale, and Arrowhead's 2024 comments on the top-down camera. No Supergiant or Grinding Gear HUD talk was located, and the best-known Diablo III GDC talk covers systems, not UI.

### Cited Findings
- Diablo IV quarterly update, February 2020 (UI section): inventory colour scheme tuned to balance "ease of use and the game's gritty art style"; primary skill can be rebound off left click to separate movement from attack; in-action UI placement considered for PC, console and the isometric camera; native PC controller support with menus for both inputs. Press summaries of Blizzard's post. [RPG Site](https://www.rpgsite.net/news/9492-diablo-iv-discusses-ui-design-coop-controller-support-and-cannibals-in-first-quarterly-update) (2020); [Gematsu](https://gematsu.com/2020/02/diablo-iv-quarterly-update-ui-design-controller-support-co-op-and-cannibal-tribes) (2020)
- Diablo IV Season 4 rationale for fewer drops ("less time sorting"). [GameSpot](https://Gamespot.com/articles/how-diablo-4-loot-reborn-update-will-make-its-items-and-players-more-powerful-than-ever/1100-6523061/) (2024)
- Arrowhead (Pilestedt) on top-down vs third-person team awareness. [PlayStation Blog](https://blog.playstation.com/2024/03/12/helldivers-2-how-arrowhead-turned-the-twin-stick-shooter-original-into-a-bombastic-ps5-sequel/) (2024)
- Diablo III: Wyatt Cheng's GDC 2013 talk "Through the Grinder: Refining Diablo III's Game Systems" covered health recovery, combat controls and skills, not HUD. [Game Developer](https://gamedeveloper.com/game-platforms/diablo-iii-sets-the-standard-for-console-ports) (2013); a GDC panel on the console version focused on direct movement and a right-stick evade. [GameBanshee](https://www.gamebanshee.com/xffa) (2013)
- Hades: a behind-the-scenes piece on Hades effects names Josh Barnett as visual FX and UI artist; the retrieved snippet does not cover HUD readability. [80.lv](https://80.lv/articles/a-behind-the-scenes-look-at-the-effects-in-hades/) (year not stated). A secondary write-up claims Hades controls brightness and detail density so gameplay information stays readable at speed; this is the author's interpretation, not a developer statement. [GeekChamp](https://geekchamp.com/the-art-of-hades-showcases-the-talent-that-went-into-this-beautifully-vibrant-game/) (year not stated)

### Inferences
- The Diablo IV note that rarity marks were made "subtler" in 2020 and the 2024 cut in drop count point the same way: Blizzard moved toward less shouting on screen over time. Inference from two separate decisions.
- Pilestedt's trade-off framing ("gain some and lose some") is useful for a 3/4 top-down game: the view gives shared awareness for free, so the HUD does not have to rebuild it with feeds and markers the way a third-person game must. Inference.

### Gaps
- No Blizzard GDC talk specifically on Diablo IV HUD or combat text was found in this session.
- No Supergiant talk, postmortem or interview on Hades or Hades II HUD design was found.
- No Grinding Gear Games talk or post on item filter design was retrieved (official "Item Filter Information" post referenced by a forum author was not found).
- No Arrowhead material on Helldivers (2015) HUD, stratagem prompts or reinforcement notices was found.
- No postmortems found for Zero Sievert, Enter the Gungeon (two interviews surfaced, [Game Developer Q&A](https://www.gamedeveloper.com/design/q-a-the-guns-and-dungeons-of-i-enter-the-gungeon-i-) and [Gameranx](https://gameranx.com/features/id/48447/article/enter-the-gungeon-interview-with-dodge-rolls-dave-crooks-the-past-present-and-future/), but their HUD content was not visible), Alienation, The Ascent, Ruiner or Synthetik.

## 6. Common complaints of clutter in these games and the fixes that followed

### Takeaway
The documented complaints fall into three groups: floating status words over many enemies (Diablo IV, fixed with a finer combat text mode), too many items on the ground (Diablo IV, fixed by dropping fewer items; Path of Exile, handled with filters), and text too small to read on a TV (The Ascent, no UI fix found in its first patches).

### Cited Findings
- Diablo IV beta: status word spam above monsters and a centre-screen "skill not ready" banner. [Blizzard forums](https://us.forums.blizzard.com/en/d4/t/please-please-remove-the-floating-combat-text/13017) (2023). Later state: a three-way combat text mode. [Mein-MMO](https://mein-mmo.de/en/the-best-builds-in-diablo-4-deal-billions-of-damage-players-say-its-much-better-without-numbers,1118780/) (2024)
- Diablo IV high-level play: damage numbers in the billions called "number diarrhoea" that "really ruins the experience" by some players. [Mein-MMO](https://mein-mmo.de/en/the-best-builds-in-diablo-4-deal-billions-of-damage-players-say-its-much-better-without-numbers,1118780/) (2024)
- Diablo IV loot volume: fixed by fewer drops in Season 4. [GameSpot](https://Gamespot.com/articles/how-diablo-4-loot-reborn-update-will-make-its-items-and-players-more-powerful-than-ever/1100-6523061/) (2024)
- The Ascent (isometric twin-stick shooter): Windows Central called the UI "generally awful" and said "the text on the UI is absolutely tiny"; GamingBolt reported fan complaints about small text and "excessive screen clutter" with no developer response at the time; another reviewer said text on a TV was hard to read. [Windows Central](https://windowscentral.com/ascent-review) (2021); [GamingBolt](https://gamingbolt.com/the-ascent-players-raising-concerns-over-accessibility-issues-with-the-game) (2021); [Player2](https://www.player2.net.au/2021/08/the-ascent-a-mountain-too-great/) (2021)
- The Ascent's first two patches targeted stability, stutter, saves, co-op and PC graphics options, with no UI or text size entries. [DSOGaming](https://www.dsogaming.com/patches/second-patch-for-the-ascent-released-reduces-stuttering-hitching-in-both-dx11-dx12) (2021); [TheSixthAxis](https://www.thesixthaxis.com/?p=384742) (2021)
- Vampire Survivors: weapon effects can bury the screen; players turn off damage numbers and flashing to cope; flashing and blood switches were extended in 1.6.0. [Vampire Survivors Wiki](https://vampire.survivors.wiki/w/Options) (2023); [Steam discussion](https://steamcommunity.com/app/1794680/discussions/0/3194745319522730122) (year not stated)
- Path of Exile 2: players still ask for a global label size control and clearer filter explanations. [Path of Exile forum](https://ru.pathofexile.com/forum/view-thread/3630063) (2025, inferred)

### Inferences
- For a 2.5D 3/4 top-down extraction shooter played by two people on one screen at 1080p, the documented complaints suggest a short checklist:
  - Keep player-run status in fixed corners or a bottom bar, inside a 16:9 safe frame (Hades, Helldivers 2, Diablo IV pattern).
  - Keep the ring around each character for direction-only cues (off-screen threat arrows, the teammate's direction when separated), not words. Words near the character compete with enemies and bullets converging on the centre.
  - Show enemy states on the enemy's health bar or as an icon, never as a repeated word; announce a state once when it changes (Diablo IV "Fortified" lesson).
  - Draw off-screen markers only while the source is off screen, on an oval inset that avoids corner panels.
  - Show teammate events on the teammate's character first, since both players see the same picture (Arrowhead), and give each player their own side for any text (Diablo IV couch co-op).
  - Prefer fewer, more meaningful pickups over a filter; keep a three-rung loot signal (quiet, coloured, loud) and reserve the loud rung for run-changing items.
  - Make every floating number or word optional, with a "hide all floating text" state, and keep flashes and screen shake as separate switches.
  - Test text size at TV distance; tiny text was the top documented complaint about The Ascent.
- These are applications of the cited cases, not findings from any study of this genre. Feel and readability need a playtest.

### Gaps
- No documented clutter complaints or fixes found for Hades, Enter the Gungeon, Zero Sievert, Helldivers (2015), Alienation, Ruiner, Synthetik, Hotline Miami or Halls of Torment.
- No quantitative data (for example telemetry on how many players turn damage numbers off) was found for any listed game.
- Whether The Ascent later added a text size or HUD scale option was not confirmed; only its first two patches were checked.
