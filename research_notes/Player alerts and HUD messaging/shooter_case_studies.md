# Shooter case studies: where HUD messages and alerts go, and how they behave

Scope: ARC Raiders, Escape from Tarkov, Hunt: Showdown 1896, Helldivers 2, Apex Legends, Call of Duty (MWII/MWIII, Warzone, Black Ops 6), Fortnite, Destiny 2, The Division 2. Research done 2026-10-27. Several primary pages (Prima Games, ProGameGuides, esports.gg, uxdesign.cc, Epic help, PC Gamer) returned 403 or empty bodies to the fetch tool; where a claim rests only on a search-engine summary of such a page, it is marked "(search summary)". Nothing here was checked against screenshots, because the research tools could not view Game UI Database images. Anything from the researcher's own familiarity with these games is kept out of Cited Findings and marked "unverified" under Inferences.

## Q1. Screen location of each kind of message, per game

### Takeaway
Where it is documented, the layout converges on a small set of fixed homes: direction and objective markers on a compass across the top centre, the player's own vitals and squad bars bottom left, weapon, ammo and quick item bottom right, objectives in a top corner, and global events (banish, extraction state) shown as marks on the map rather than as text. ARC Raiders, Tarkov and Hunt (the three closest to an extraction shooter) put the least text on screen, and two of them hide extraction status until the player asks for it.

### Cited Findings

**ARC Raiders (Embark, 2025)**
- Compass at top centre; extraction points and raider hatches appear on it only when the player is heading toward them and is "within about 400m"; map waypoints stay on the compass at any distance when the player faces them. [ARC Raiders Wiki, Game UI, 2025-26](https://arcraiders.wiki/wiki/Game_UI)
- The round countdown sits directly below the compass. It shows the time left in the round, not how long a given extraction stays open; that is shown on the map. [ARC Raiders Wiki, Game UI](https://arcraiders.wiki/wiki/Game_UI)
- Shields and health bottom left, with bars for every squad member in a squad; equipment panel bottom right (current weapon, ammo, last used quick-use item); reticle centre only when aiming (shotguns show a spread circle). [ARC Raiders Wiki, Game UI](https://arcraiders.wiki/wiki/Game_UI)
- Extraction status lives on the map: each extraction point carries its own countdown, its symbol changes colour when "only five minutes remaining", and turns grey when the lift closes. [ARC Raiders Wiki, Game UI](https://arcraiders.wiki/wiki/Game_UI)
- Each elevator has its own clock; when it hits zero that exit shuts for the rest of the match. Calling an elevator triggers a loud alarm that broadcasts the caller's position and draws ARC and other raiders, so the extraction "alert" to other players is a sound in the world, not a HUD message. [All Things How, 2025](https://allthings.how/arc-raiders-extraction-elevators-hatches-and-timers-explained/); [Broken Builds, 2025](https://brokenbuilds.gg/arc-raiders/guides/arc-raiders-extraction-mechanics-guide). Sources disagree on the exact departure timing (one says 90 s automatic), treat timings as unverified.
- Pings are a radial wheel (one of three wheel menus) used to talk to the squad or to other raiders depending on settings; not a fixed HUD element. [ARC Raiders Wiki, Game UI](https://arcraiders.wiki/wiki/Game_UI)
- Looting: opening a container opens the inventory automatically with the loot listed on the left; the wiki describes no pickup toast. [ARC Raiders Wiki, Game UI](https://arcraiders.wiki/wiki/Game_UI)
- No enemy health bars, damage numbers or hit indicators in the shipped game; an earlier PvE-only build had all three. Machines show damage physically (smoke, sparks, shattered armour, persistent damage). [GamingBolt, 5 Nov 2025, reporting a GamesRadar interview with CCO Stefan Strandberg](https://gamingbolt.com/arc-raiders-lacks-enemy-hp-bars-since-embark-doesnt-want-you-playing-the-excel-sheet-of-a-game)
- Spatial audio is used so players sense distance and threats "without relying on UI elements". [Unreal Engine developer interview, 2025 (zh-CN page, search summary)](https://www.unrealengine.com/zh-CN/developer-interviews/embark-studios-build-the-award-winning-arc-raiders-with-unreal-engine)

**Escape from Tarkov (Battlestate)**
- Extraction list is on demand only: double-tapping O shows the available extraction points plus the time left in the raid. Only the extracts listed there are usable that raid; entries with a question mark have conditions (pay, key, power). [ProGameGuides](https://progameguides.com/escape-from-tarkov/how-to-extract/); [GGRecon](https://www.ggrecon.com/guides/escape-from-tarkov-how-to-extract/); [AFK Gaming](https://afkgaming.com/esports/guide/extracts-in-escape-from-tarkov-what-are-they-how-to-extract) (guides, undated in summary)
- Conflict on placement: one guide puts the raid timer in the top right of the inventory (Tab) screen; another describes a top-right box that appears only when standing in an extract, naming the extract and the wait time. Corner placement of the countdown is unconfirmed. [same three guides, search summary]
- Health is per body part with bleeds, fractures, pain, blacked limbs, hydration and energy, not a single bar. [Bamboo Gaming, Tarkov health](https://www.bamboogaming.net/tarkov/health)
- Giant Bomb lists "Extremely few HUD Elements" as a defining feature. [Giant Bomb wiki](https://giantbomb.com/wiki/Games/Escape_From_Tarkov) (descriptive, not a developer statement)

**Hunt: Showdown 1896 (Crytek)**
- Main HUD is "a compass, and your health and equipment"; ping markers change icon to match the object pinged (weapons, traps, healing, resupply, barrels, noise traps, etc.), and Solos can ping too. [Hunt Showdown Wiki (wiki.gg), HUD](https://huntshowdown.wiki.gg/wiki/HUD)
- Teammate state is shown as distinct icons: downed, downed and burning, dead, dead but revivable with a bounty token. [Hunt Showdown Wiki, HUD](https://huntshowdown.wiki.gg/wiki/HUD)
- Some HUD elements are hidden while Dark Sight is active and others show extra information. [Hunt Showdown Wiki, HUD](https://huntshowdown.wiki.gg/wiki/HUD)
- Global events are drawn on the map, not printed: a banish shows as a blue-and-black scorch mark that grows at the banish site while the rest of the boss region darkens; a dropped bounty token shows a periodic lightning-strike icon that then follows the carrier. [Hunt Showdown Wiki, HUD](https://huntshowdown.wiki.gg/wiki/HUD)
- When a banish starts every hunter is notified, and the bounty token in the top left of the screen shows banish completion as a percentage. [Hunt: Showdown Wiki (fandom), Game Modes](https://huntshowdown.fandom.com/wiki/Game_Modes)
- Clue proximity is a world cue: clues glow red when an enemy hunter is within 30 m. [Hunt wiki search summary, fandom Game Modes/Tips](https://huntshowdown.fandom.com/wiki/Tips)
- Locked extraction points are shown on both map and compass (a display bug for them was fixed in patch 2.5.0.1). [MP1st, Oct 2025](https://mp1st.com/title-updates-and-patches/hunt-showdown-1896-update-1-000-033-out-for-patch-2-5-0-1-brings-bug-fixes)
- Update 2.2 added scorch marks on the map for Dark Sight events, signalling position. [GINX, 2025](https://www.ginx.tv/en/2-2-update-patch-notes-details)

**Helldivers 2 (Arrowhead, 2024)**
- Bottom left: grenades, stims, selected weapon, health bar, player tag (for example A1), backpack item. [Helldivers Wiki, Heads-Up Display](https://helldivers.wiki.gg/wiki/Heads-Up_Display)
- Top right: stratagem data with remaining reinforcements counter, and the current mission's main objectives. [Helldivers Wiki, Heads-Up Display](https://helldivers.wiki.gg/wiki/Heads-Up_Display)
- Top: compass with cardinal points and the bearing of map markers; undiscovered minor points of interest within 75 m show as "?". [Helldivers Wiki, Heads-Up Display](https://helldivers.wiki.gg/wiki/Heads-Up_Display)
- Stratagem list opens on a button hold (L1 / Ctrl+T in one guide) and the input creates a throwable marker in the world. [Helldivers Wiki, Stratagems search summary](https://helldivers.wiki.gg/wiki/Strategems); [EIP.gg](https://eip.gg/guides/helldivers-2-stratagems/)
- Scrapped design: each helmet was to carry its own HUD ("medics would be able to see health, recon would get enemy outlines"), cut to ship on time. [VideoGamer, 2024](https://videogamer.com/news/scrapped-helldivers-2-helmet-mechanic-would-have-made-armor-more-unique); [SVG, 2024](https://www.svg.com/1582635/helldivers-2-content-cutting-room-floor-deleted/)

**Apex Legends (Respawn)**
- Pings are context sensitive with one button: ping an enemy and your character voices a spotted enemy; ping a crate and the character calls out the items; teammates instantly see an icon of what was pointed at, and items can be claimed ("dibs") at any distance. [GameRevolution, 2019](https://www.gamerevolution.com/?p=493241); [Stevivor, 2019](https://stevivor.com/features/interviews/rainbow-six-siege-wants-an-apex-legends-contextual-ping-system)
- Season 23 (2024-25) put low-state warnings on existing elements: the healing HUD icon flashes at low health, the clip counter pulses red at critical ammo, and the Low Ammo prompt was moved lower on the HUD. [Siege.gg, Season 23 patch notes](https://siege.gg/news/apex-legends-season-23-patch-notes); [GameRiv](https://gameriv.com/apex-legends-season-23-patch-notes/)
- Kill feed carries system notices: from the 31 Oct 2023 patch it reports players banned by anti-cheat, and Respawn said it would not fire for quits, disconnects or AFK kicks. [Apex Legends Wiki, October 31 2023 Patch](https://apexlegends.fandom.com/wiki/October_31,_2023_Patch)

**Call of Duty (MWII/MWIII, Warzone, Black Ops 6)**
- Black Ops 6 introduced gameplay HUD layout presets plus minimap colour options; Activision suggests the Target Tracker or Central Command presets for less clutter. [Call of Duty blog, Oct 2024 (search summary; fetch failed)](https://www.callofduty.com/blog/2024/10/call-of-duty-black-ops-6-accessibility-updates-features)
- BO6 Classic preset: minimap and objective counter top left, health bottom left, ammo bottom right; Standard moves the field upgrade and equipment indicator from the centre to bottom right beside ammo; Magnified enlarges all icons. [ProGameGuides, 2024 (search summary; fetch 403)](https://progameguides.com/call-of-duty/best-hud-settings-presets-and-colors-in-black-ops-6/)
- BO6 Gameplay HUD also sets the minimap round or square, rotating or not, and the compass at the top of the screen, above the minimap, or off. [Charlie INTEL, 2024](https://www.charlieintel.com/call-of-duty/black-ops-6-best-hud-preset-337026/)
- Season 02 (Jan 2025) lets players keep a separate HUD preset per mode (Multiplayer vs Zombies). [Call of Duty blog, Jan 2025](https://www.callofduty.com/blog/2025/01/call-of-duty-black-ops-6-warzone-zombies-season-two-maps-modes-announcement)

**Fortnite (Epic)**
- "Visualize Sound Effects" draws a radial indicator for certain sounds, colour coded: orange/red for explosions and gunshots, gold for chests, white for footsteps, animals and vehicles; one guide places the icons on a ring around the aim reticle at screen centre. It persists across matches until turned off; added in Chapter 3 mainly for hard-of-hearing players, also used competitively. [Epic Games Help](https://www.epicgames.com/help/fortnite-battle-royale-c-202300000001636/a202300000009892); [Esports.net](https://www.esports.net/news/fortnite/visual-sound-effects-fortnite/); [Dot Esports](https://dotesports.com/fortnite/news/how-to-turn-on-visual-sound-effects-on-fortnite)
- HUD settings on PC/console sit under Game UI, split into "Reticle & Damage Feedback" and "HUD"; on mobile a HUD Layout Tool lets players move icons and buttons, with Combat and Build modes laid out separately. [Epic Games Help, HUD](https://www.epicgames.com/help/fortnite-battle-royale-c-202300000001636/gameplay-c-202300000001721/hud-a202300000011110) (search summary); [Epic Help, mobile HUD](https://www.epicgames.com/help/c-202300000001636/c-202300000001721/how-do-i-customize-my-hud-in-fortnite-on-mobile-a202300000016543); [Game Accessibility patterns, Personal Interface](https://accessible.games/accessible-player-experiences/access-patterns/personal-interface/)
- Fortnite added an Apex-style ping system shortly after Apex launched (2019). [PCGamesN, 2019](https://www.pcgamesn.com/fortnite/fortnite-ping-system)

**Destiny 2 (Bungie)**
- HUD Opacity setting with four values: Full (default), High, Low, Off; no dynamic or combat-aware mode found. [Bungie Help, Accessibility Settings](https://help.bungie.net/hc/en-us/articles/360049200911); a 2021 player thread says the crosshair cannot be disabled, only dimmed via HUD opacity. [Steam discussion, 2021](https://steamcommunity.com/app/1085660/discussions/0/2951537622585309605)

**The Division 2 (Massive)**
- HUD can be set to stay on permanently or hide when not needed; minimap position and group display size are adjustable; incoming reinforcement-request notifications can be switched off (SHD map view or Gameplay settings). [Mein-MMO, 15 tips for The Division 2 (search summary)](https://mein-mmo.de/en/i-wish-i-had-known-these-15-tips-for-the-division-2,326622/)
- The original Division's HUD was described in its reveal as built into the environment rather than framing the screen, with a wrist display as the diegetic example. [HUDs and GUIs, 2013](https://www.hudsandguis.com/2013/06/26/tom-clancys-the-division-interface-design/) (fan analysis of a trailer, not shipped game)

### Inferences
- For a top-down game, the ARC and Helldivers compass pattern (markers only within a radius, here 400 m and 75 m) translates to edge-of-screen arrows for things off screen within a radius, and nothing for things beyond it.
- Unverified (researcher familiarity, not checked this session): Apex kill feed sits top right; CoD MW-era kill feed sits lower left near chat; Fortnite's elimination feed sits on the left side; Tarkov has no kill feed and no hit markers; Hunt has no global kill feed (only teammate events and the banish notice); Destiny 2 item pickups list on the left. These should be confirmed on Game UI Database screenshots before being quoted as fact.
- Extraction status splits two ways: on-demand list (Tarkov O, ARC map) versus always-on timer (ARC round timer under the compass). Both keep the per-exit detail off the main HUD.

### Gaps
- No source found for exact positions of kill feed, XP/score popups, medal popups, tutorial hints or system notices for Apex, CoD, Fortnite, Destiny 2 or Division 2. Game UI Database pages are image based and could not be read.
- No source on how ARC Raiders shows a teammate downed or revived, being spotted, incoming damage direction, or map-condition (event) announcements.
- No reliable source on Tarkov's in-raid notifications (quest progress, item found) or their position.
- Helldivers 2 teammate death, reinforcement and extraction-timer placement not documented in the wiki page fetched.

## Q2. How many show at once, duration, stacking and merging, combat suppression, and what moves into the world

### Takeaway
Hard numbers (max lines, seconds on screen, queue rules) are almost never documented publicly; what is documented is the direction of travel: games move information off text and into the world (pings with voice lines, map scorch marks, sound rings, physical damage on enemies), put warnings on the element that already shows that stat, hide HUD parts in special states, and give players sliders or toggles for the noisiest feeds.

### Cited Findings
- Apex pings carry their own voice line and world icon, so one action produces both a world marker and an audible callout without a text message; Respawn playtested a month with voice chat off and fake names to tune it. [WN Hub, 2019](https://wnhub.io/news/other/item-15272); [GameRevolution, 2019](https://www.gamerevolution.com/?p=493241)
- Hunt replaces "boss is being banished at X" text with a growing scorch mark on the map and a percentage on the bounty token in the top left; the token's lightning icon then follows its carrier on the map. [Hunt Wiki HUD](https://huntshowdown.wiki.gg/wiki/HUD); [Hunt Wiki Game Modes](https://huntshowdown.fandom.com/wiki/Game_Modes)
- Hunt hides some HUD elements during Dark Sight. [Hunt Wiki HUD](https://huntshowdown.wiki.gg/wiki/HUD)
- ARC Raiders replaces enemy HP bars and damage numbers with physical damage on the machine, and an elevator call is announced to others by an alarm in the world. [GamingBolt, Nov 2025](https://gamingbolt.com/arc-raiders-lacks-enemy-hp-bars-since-embark-doesnt-want-you-playing-the-excel-sheet-of-a-game); [All Things How, 2025](https://allthings.how/arc-raiders-extraction-elevators-hatches-and-timers-explained/)
- ARC Raiders patch 1.22.0 (31 Mar 2026) added HUD visibility modes: Visible, Crosshair and Interactions Only, Crosshair Only, Hidden (F10 on PC, Gameplay Options on console). [PSU, 2026](https://www.psu.com/news/arc-raiders-flashpoint-update-1-22-0-adds-arc-vaporizer-canto-wasp-hunter-set-more-full-patch-notes-listed); [Mein-MMO, 2026](https://mein-mmo.de/en/arc-raiders-flashpoint-alle-patch-notes-1-22-00,1559623) (search summary)
- Apex Season 23 puts low health and low ammo warnings on the existing heal icon and ammo counter (flash, red pulse) instead of adding a new banner, and moved the Low Ammo prompt lower. [Siege.gg](https://siege.gg/news/apex-legends-season-23-patch-notes)
- Fortnite turns sound into direction-coded icons on a ring around the reticle. [Epic Games Help](https://www.epicgames.com/help/fortnite-battle-royale-c-202300000001636/a202300000009892); [Esports.net](https://www.esports.net/news/fortnite/visual-sound-effects-fortnite/)
- BO6 Zombies gained visibility sliders to fine-tune or disable Score Feed, Medals & Notifications, Minimap Opacity, Weapon & Equipment Information and more (Oct 2024). [Dexerto, Oct 2024](https://www.dexerto.com/call-of-duty/treyarch-promised-black-ops-6-map-and-hud-changes-after-cod-next-concerns-2924608/)
- Division 2 lets the HUD hide when not needed and lets players switch off reinforcement-request notifications. [Mein-MMO](https://mein-mmo.de/en/i-wish-i-had-known-these-15-tips-for-the-division-2,326622/)
- ARC and Helldivers 2 limit compass markers by distance (ARC extracts within about 400 m; HD2 "?" POIs within 75 m). [ARC Wiki](https://arcraiders.wiki/wiki/Game_UI); [Helldivers Wiki](https://helldivers.wiki.gg/wiki/Heads-Up_Display)
- Apex's kill feed only reports anti-cheat bans, not quits, disconnects or AFK kicks: a deliberate filter on a system notice. [Apex Wiki, Oct 31 2023 patch](https://apexlegends.fandom.com/wiki/October_31,_2023_Patch)

### Inferences
- The shared rule in these sources is "say it where it already lives": warnings modify the element that shows the stat (Apex), global events modify the map (Hunt, ARC), direction goes on the compass or a ring (HD2, ARC, Fortnite), and social events come as voice plus world icon (Apex). Text banners are the last resort.
- Distance filters on markers (400 m, 75 m) are a cheap way to cap how many markers show at once.
- Per-feed sliders (BO6) and on/off toggles for social prompts (Division 2) suggest the noisiest channels are score feed, medals and notifications, and requests from other players.

### Gaps
- No public source found for maximum simultaneous messages, on-screen durations, or merge rules ("x3" stacking of identical pickups) for any of the nine games.
- No documented "suppress during combat" rule found for any title, apart from Hunt hiding elements during Dark Sight and Division 2's hide-when-not-needed HUD.
- Apex ping duration and timeout not found (the PC Gamer and uxdesign.cc pages could not be fetched).

## Q3. Praise and criticism for HUD clutter or clarity, and what changed after

### Takeaway
Most of the documented backlash is about menus rather than the in-raid HUD (MWII 2022, Hunt 1896 in 2024); the clearest in-game HUD clutter case is BO6 Zombies at COD Next 2024, which led to per-element sliders. ARC Raiders is the main praise case, for both the minimal raid HUD and the plain menus.

### Cited Findings
- ARC Raiders' menus praised as "simple and functional" compared with the "Netflix-style" layouts in other big shooters. [Pocket Tactics review, 2025](https://www.pockettactics.com/arc-raiders/review)
- ARC Raiders: Strandberg says HP bars and damage numbers on top of the world are "redundant" ("Now you're playing the Excel sheet of a game!"); the author notes it may not satisfy players who want precise numbers. [GamingBolt, Nov 2025](https://gamingbolt.com/arc-raiders-lacks-enemy-hp-bars-since-embark-doesnt-want-you-playing-the-excel-sheet-of-a-game)
- ARC Raiders later added full HUD hide modes (1.22.0, Mar 2026). [PSU, 2026](https://www.psu.com/news/arc-raiders-flashpoint-update-1-22-0-adds-arc-vaporizer-canto-wasp-hunter-set-more-full-patch-notes-listed). Patch 2.2.0 (20 Oct 2026) lists only "assorted performance, audio and UI fixes". [ArcStatus](https://arcstatus.com/patch-notes.php)
- Black Ops 6 Zombies: after COD Next (28 Aug 2024) fans called the HUD cluttered, singling out enemy health bars; by 17 Oct 2024 changes included character portraits moved to lower left by default, colour and alignment passes across the HUD, perk icons grouped, and visibility sliders for score feed, medals and notifications, minimap opacity and weapon info. [Dexerto, Oct 2024](https://www.dexerto.com/call-of-duty/treyarch-promised-black-ops-6-map-and-hud-changes-after-cod-next-concerns-2924608/)
- Modern Warfare II (2022): menus compared to Hulu or streaming apps, called cluttered and hard to navigate (Gunsmith, loadouts); Infinity Ward acknowledged UX issues during the beta it could not fix in time; later reports said changes would come piecemeal. [Kotaku AU, Oct 2022](https://kotaku.com.au/2022/10/call-of-duty-modern-warfare-2-players-abhor-the-new-hulu-like-menus); [Charlie INTEL, 2022](https://www.charlieintel.com/call-of-duty-modern-warfare-2/modern-warfare-2-ui-overhaul-reportedly-coming-after-major-backlash-208315/); [Gfinity, 2022](https://www.gfinityesports.com/gaming-news/modern-warfare-2-ui-changes/)
- MWII in-game: players complained about new white ping marks (Nov 2022); Infinity Ward had not commented at the time of the report. [PiunikaWeb, 17 Nov 2022](https://piunikaweb.com/2022/11/17/cod-modern-warfare-2-new-ui-white-pings-marks-face-backlash/)
- Hunt: Showdown 1896 (Aug 2024): Steam reviews went "mostly negative"; players called the new UI cluttered, hard to navigate and full of unhelpful information, with nearly every element moved; Crytek answered reviews, posted a developer video, then shipped UI updates (Bounty Hunt lobby in the top nav, owned items listed first; update 2.1 added a dedicated play button and a key binding pass), and concurrents rose to just over 26,000 the day after 2.1. [Prima Games, 2024 (search summary)](https://primagames.com/news/crytek-responds-to-hunt-showdown-1896s-ui-backlash); [PCGamesN, 2024](https://www.pcgamesn.com/hunt-showdown/1896-ui-fix); [Destructoid, 2024](https://www.destructoid.com/crytek-addresses-ui-concerns-and-thanks-fans-for-the-biggest-player-count-hunt-showdown-1896-has-ever-seen/); [PCGamesN, update 2.1](https://www.pcgamesn.com/hunt-showdown/update-2-1); [80.lv](https://80.lv/articles/hunt-showdown-1896-receives-its-largest-update-but-gets-criticized/)
- Apex's ping system is widely praised and copied: Fortnite added a near-identical system in 2019, and Rainbow Six Siege's director said he wanted context pings. [PCGamesN, 2019](https://www.pcgamesn.com/fortnite/fortnite-ping-system); [Stevivor, 2019](https://stevivor.com/features/interviews/rainbow-six-siege-wants-an-apex-legends-contextual-ping-system)
- Escape from Tarkov: in Aug 2026 Nikita Buyanov said things that are hard to understand without adding depth are the biggest hurdle for beginners and pledged to simplify; no HUD-specific change named. [Gamewave, Aug 2026](https://gamewave.fr/escape-from-tarkov/escape-from-tarkov-va-enfin-devenir-plus-accessible-nikita-buyanov-veut-arreter-d-ecoeurer-les-nouveaux-joueurs/); [PCGamesN](https://www.pcgamesn.com/escape-from-tarkov/new-player-accessibility-complexity)
- Fortnite's sound visualiser is called controversial by some competitive commentators, though not cheating. [Esports.net](https://www.esports.net/news/fortnite/visual-sound-effects-fortnite/)

### Inferences
- The fix that keeps recurring is not a redesign but player control: sliders per feed (BO6), hide modes (ARC), opacity (Destiny 2), hide-when-idle (Division 2). The default still has to be quiet; options are a pressure valve.
- Moving every element at once (Hunt 1896) is what drew the anger, more than any one element: change one region at a time and keep old homes stable.

### Gaps
- No review or patch found that criticises Apex, Helldivers 2, Destiny 2 or Division 2 specifically for in-raid HUD clutter.
- No source on Warzone HUD clutter complaints or changes (search did not surface any).

## Q4. Developer talks and postmortems on HUD and notification design

### Takeaway
The public record is thin: two GDC UI talks (Destiny 2016, The Division 2017) whose content is mostly about tooling and menus, Embark's interview statements on removing combat UI, Respawn's voice-off ping playtests, and Arrowhead's scrapped helmet HUD. No GDC talk on Apex's ping system was found.

### Cited Findings
- GDC 2016, David Candland (Bungie UI design lead), "Tenacious Design and The Interface of Destiny": making the interface inviting to newcomers while giving veterans depth; early prototypes were far more stylised per screen; details like how "sticky" an element is under the cursor. [GDC Vault](https://www.gdcvault.com/play/1023460/); [Kotaku, 2016](https://kotaku.com/watch-the-evolution-of-destiny-s-user-interface-1782289001); [Game Developer](https://gamedeveloper.com/art/video-building-the-user-interface-for-bungie-s-i-destiny-i-); [TweakTown, 2016](https://www.tweaktown.com/news/51678/early-destiny-user-interface-prototypes-amazing/index.html)
- GDC 2017, Christian Savoie (Ubisoft Massive), "Lessons Learned Creating UI for 'The Division'": a UI system built from scratch; the write-up names no HUD or notification lessons. [GDC Vault](https://gdcvault.com/play/1024026/Lessons-Learned-Creating-UI-for); [Game Developer, Mar 2018](https://gamedeveloper.com/design/video-designing-a-new-ui-system-for-i-the-division-i-)
- Embark (ARC Raiders): HP bars, damage numbers and hit indicators are "something you can autopilot to as a developer"; "There are so many cues in the sound, in the VFX, in everything"; "Why am I getting all the answers in a 2D format on top of 3D?"; the team chose to "trust the players more". [GamingBolt, Nov 2025](https://gamingbolt.com/arc-raiders-lacks-enemy-hp-bars-since-embark-doesnt-want-you-playing-the-excel-sheet-of-a-game). The official docuseries "The Evolution of ARC Raiders" ep. 2 frames this as "active immersion" through gameplay. [TechJuice summary](https://www.techjuice.pk/arc-raiders-ditches-health-bars-physics-creates-true-immersion/)
- Respawn (Apex): a month of internal playtests with voice off and fake names, to tune pings for random squads (2019 tweet). [WN Hub](https://wnhub.io/news/other/item-15272)
- Arrowhead (Helldivers 2): Pilestedt on the scrapped per-helmet HUD [VideoGamer](https://videogamer.com/news/scrapped-helldivers-2-helmet-mechanic-would-have-made-armor-more-unique); moving from top-down to third person because "the distance in top-down viewpoints ... does not allow for more immersive experiences" and "each player has their own perception of events"; designing "watering hole" gathering points (resupply, dropped samples, reinforcement placement) to pull the squad together. [PlayStation Blog, 12 Mar 2024](https://blog.playstation.com/2024/03/12/helldivers-2-how-arrowhead-turned-the-twin-stick-shooter-original-into-a-bombastic-ps5-sequel/)

### Inferences
- Arrowhead's quote is directly relevant to a top-down game: top-down already gives every player the same full view, so the HUD there has less need to tell a player what is happening around them than a first-person HUD does; spend messages on what is off screen or hidden.

### Gaps
- No GDC or blog postmortem found on Apex HUD or ping UX, Fortnite HUD, CoD HUD, Helldivers 2 HUD, Hunt HUD or Tarkov HUD.
- Talk videos (Destiny, Division) were not watched; their HUD-specific content is unknown beyond press write-ups.

## Q5. Patterns shared by most of them

### Takeaway
Across the documented games: top centre is direction (compass plus markers, with the round timer under it in ARC), bottom left is "me and my squad", bottom right is "my weapon", a top corner holds objectives, the centre is kept for the reticle and short-lived combat feedback, global events go on the map, and the loudest feeds are optional.

### Cited Findings
- Compass top centre with markers: ARC Raiders [ARC Wiki](https://arcraiders.wiki/wiki/Game_UI), Helldivers 2 [Helldivers Wiki](https://helldivers.wiki.gg/wiki/Heads-Up_Display), Hunt [Hunt Wiki](https://huntshowdown.wiki.gg/wiki/HUD), BO6 optional compass at top [Charlie INTEL](https://www.charlieintel.com/call-of-duty/black-ops-6-best-hud-preset-337026/).
- Own vitals bottom left: ARC (plus squad bars), Helldivers 2, BO6 Classic. [ARC Wiki](https://arcraiders.wiki/wiki/Game_UI); [Helldivers Wiki](https://helldivers.wiki.gg/wiki/Heads-Up_Display); [ProGameGuides (search summary)](https://progameguides.com/call-of-duty/best-hud-settings-presets-and-colors-in-black-ops-6/)
- Weapon and ammo bottom right: ARC, BO6 Classic. [ARC Wiki](https://arcraiders.wiki/wiki/Game_UI); [ProGameGuides (search summary)](https://progameguides.com/call-of-duty/best-hud-settings-presets-and-colors-in-black-ops-6/)
- Objectives in a top corner: Helldivers 2 top right [Helldivers Wiki](https://helldivers.wiki.gg/wiki/Heads-Up_Display); BO6 objective counter top left with minimap [ProGameGuides (search summary)](https://progameguides.com/call-of-duty/best-hud-settings-presets-and-colors-in-black-ops-6/); Hunt bounty token top left [Hunt Wiki Game Modes](https://huntshowdown.fandom.com/wiki/Game_Modes).
- Centre reserved for reticle, shown only when aiming in ARC [ARC Wiki](https://arcraiders.wiki/wiki/Game_UI); Fortnite's sound ring wraps the reticle [Esports.net](https://www.esports.net/news/fortnite/visual-sound-effects-fortnite/).
- Global events on the map rather than text: Hunt banish and bounty [Hunt Wiki](https://huntshowdown.wiki.gg/wiki/HUD); ARC extraction colour states [ARC Wiki](https://arcraiders.wiki/wiki/Game_UI).
- Optional or hideable noisy feeds: ARC hide modes, BO6 sliders, Destiny opacity, Division hide-when-idle and request toggle. [PSU](https://www.psu.com/news/arc-raiders-flashpoint-update-1-22-0-adds-arc-vaporizer-canto-wasp-hunter-set-more-full-patch-notes-listed); [Dexerto](https://www.dexerto.com/call-of-duty/treyarch-promised-black-ops-6-map-and-hud-changes-after-cod-next-concerns-2924608/); [Bungie Help](https://help.bungie.net/hc/en-us/articles/360049200911); [Mein-MMO](https://mein-mmo.de/en/i-wish-i-had-known-these-15-tips-for-the-division-2,326622/)

### Inferences (for a top-down extraction shooter; not sourced as such)
- Keep five fixed homes and never move them mid-raid: top centre direction and round timer; bottom left own and squad vitals; bottom right weapon and belt; one top corner for the objective or extraction line; centre only for brief combat feedback near the player.
- One banner at a time is not documented by any source here, but every documented change trends toward fewer banners; a single short centre callout slot plus world and map cues fits the evidence.
- Put danger on the player and the edges: a ring or edge arrows for off-screen threats and sounds (Fortnite pattern), warnings on the vitals bar itself (Apex pattern), no enemy bars over machines if the art can carry damage (ARC pattern).
- Extraction: the ARC model (timer under the compass, per-exit state on the map, alarm in the world when called) and the Tarkov model (list on a key press) both keep the main HUD quiet; a party demo audience may need the ARC "always visible" timer.
- Teammate events: icon states (Hunt downed / burning / dead / revivable) and context pings with a voice or sound (Apex) carry more than a text line, and work for local co-op where both players share one screen.

### Gaps
- No single cross-game survey of message counts or durations was found; "one banner at a time" and "centre kept clear" remain inferences from layouts, not documented rules.
- Positions for kill feed and XP popups across games need screenshot checks on Game UI Database (gameuidatabase.com) before being stated as a pattern.
