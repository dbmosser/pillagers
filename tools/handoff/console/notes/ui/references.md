# UI references: the menus he loves (study 2026-10-18)
His words: "Games with the best menus/ui: halo reach; halo 4; Diablo iv; arc raiders; Fortnite; destiny 2. I cant exactly tell you why they are so good, they are just reallly compelling and smooth".
Made by 6 web researchers and 1 synthesis (sonnet). Numbers are TARGETS (no source published exact timings).

Part A

All six games share the same habits. Honest note: nobody published exact timings, so the numbers in Part B are targets, not copies.

1. The menu sits on a living picture: your character, a busy market, concept art or the game world. Never a flat grey wall.
2. One star per screen. Your character or gear is biggest. Buttons stay at the edges, with plenty of empty space.
3. Very few styles: one font family, about three sizes, one highlight colour. Colour always means something, like rarity or danger.
4. It answers instantly and settles softly. The highlight moves the moment you press, then eases into place. A press is never ignored.
5. Same rules everywhere: same tabs, same back button, same sounds, same speed.
6. Fewer steps. Common jobs take one to three presses. Destiny 2 and ARC Raiders cut steps instead of polishing them.
7. Every press makes a small, quiet sound, a little different each time.

Reviewers split on ARC Raiders: praised for flow, criticised for icon-only tabs. Copy the flow, label the tabs.

Part B: style-guide addendum

Evidence note: no source published durations, easing or UI sounds for any of the six games, and no typeface is confirmed. Every number below is a target. (read) means a source said it, (inferred) means a study guessed.

Layout
- Design at 1920x1080; scale every number by canvasHeight/1080.
- Content inside a 5 percent margin. Fixed zones: tab bar top centre, actions left, progress bottom right, button prompts along the bottom (Fortnite, read).
- One hero (raider or gear preview) takes 40 to 50 percent of the screen. One list, one detail pane, one backdrop at most (Halo Reach, inferred).
- Backdrop: the live world dimmed 55 percent and blurred 8 px, baked once on open (ARC Raiders, Destiny 2, read).
- Uniform cells, 8 px gutters. Details appear on focus, never behind a second button. Tabs carry words.

Type and color
- One family, two weights, three sizes at 1080p: 44 title, 26 label, 20 body. Halo 4's study guessed 48/24/16; 16 is too small for a couch.
- Hierarchy from size, weight, brightness and +0.04em tracking, never capitals.
- Near-black base, bone-white text, one accent for focus, red for danger. Keep rarity grey/green/blue/purple/gold, also as a border cue (Diablo IV, read).
- Unfocused tiles at 70 percent brightness; only focus, rarity and warnings are loud.

Motion (time-based, never frame-counted)
Ease-out e(t) = 1-(1-t)^3. Ease-in e(t) = t^2.
- Focus ring: x += (target-x)*(1-exp(-dt/0.04)), 95 percent in 120 ms. Focused cell scales to 1.05.
- Open: 240 ms ease-out, alpha 0 to 1, 16 px rise. Close: 140 ms ease-in, no stagger.
- Tab change: 200 ms cross-fade plus 24 px slide in the travel direction.
- Stagger: 35 ms per card, max 8; whole entrance under 500 ms.
- Confirm: scale 1+0.06*sin(pi*t) over 120 ms. Deny: 6 px shake over 100 ms.
- A press mid-transition retargets from the current value; never ignored, never restarted.
- Never static: slow backdrop drift, cursor parallax up to 6 px. New items get a 600 ms glimmer sweep every 4 s instead of a badge (Destiny 2, read).
- Loading hides behind the animated backdrop. Bake panels, shadows and blur offscreen; per frame only drawImage with alpha and translate.

Sound
- Focus: soft tick 30 to 80 ms, 3 to 4 variants, pitch plus or minus 3 percent, at most one per 40 ms.
- Confirm deeper; back lighter, lower, shorter; deny a dull thud; open and close a soft sweep; equip a material sound by item type; purchase, unlock, extract a bigger sting.
- Play on the input frame. Cap three copies of one sound (Diablo IV, read, gameplay audio). Music continues across tabs.

Navigation and focus
- Something is focused on open. If it vanishes, jump to the nearest.
- Pad: stick moves cell to cell; bumpers change tabs from anywhere (Fortnite Common UI, read); A confirm; B back one level; X/Y secondary; prompt strip shows live actions.
- Mouse: hover equals focus, one highlight; hit area 8 px larger than drawn (Destiny, read). Last-used device picks the prompts. Esc and a visible close button equal B.
- Pad grids are slow (Diablo IV, read): add quick-move and sort.
- Depth at most 3 levels. Deploy in 2 presses, equip from stash in 3.
- Two players: each opens and closes their own menu without blocking the other (Diablo IV, read); focus ring tinted per player.
- Destructive actions: hold 500 ms with a filling ring (Destiny, recalled).
- Studies differ: Destiny uses a free cursor on pad; Halo and Fortnite use focus grids. Use the focus grid.

Signature moves
- Living scene behind everything: ARC Raiders.
- Hero preview updates on focus, not confirm: Halo 4, Fortnite (inferred).
- Card expands in place, neighbours slide: Halo 4 (read).
- Sticky targets, pop on hover: Destiny 2.
- Loot panel opens itself, loot on the left: ARC Raiders.
- Quiet until it matters: Diablo IV.
- Visible progress, emblem or room: Halo Reach, ARC Raiders.

Never
- Capitals, explaining sentences, a second row for a job one control does.
- Ignore a press during animation; animate a common action over 300 ms; linear easing; overshoot beyond 6 percent.
- Info behind a second press (Halo 4 criticism, read); icon-only tabs (ARC Raiders criticism, read); extra steps for tidiness (Fortnite Locker backlash, read).
- Silent focus changes, spinners, black loading screens.

How to check it
Add a steppable debug clock and a per-frame log of each animated element's alpha, offset and scale.
1. Open: capture at 0/50/100/200/300 ms. Expect about 50, 80, 99 percent of travel at 50, 100, 200 ms (plus or minus 8).
2. Close: gone within 150 ms.
3. Focus: ring 30 percent along at 16 ms, 80 at 66, 95 at 120; tick logged on the same frame.
4. Stagger: start gaps 35 ms plus or minus one frame.
5. Interrupt: press 30 ms into an open and mid tab change; handled within one frame, no per-frame jump above 12 percent of travel.
6. Confirm pulse peaks 1.06 near 60 ms, 1.0 by 120.
7. Frame time through every 4K transition: p95 under 16.7 ms, none over 25.
8. Sound log: at most one tick per 40 ms; 20 ticks show 3 or more pitches; confirm, back, deny distinct.
9. Static audit: at most 3 font sizes and 1 accent per screen; backdrop differs between frames 2 s apart.
10. Fuzz: 200 random presses never leave nothing focused; B goes exactly one level.
11. Critic contact sheet: strip per screen at 0/50/100/200/300/600 ms, 1080p and 4K, plus a hover and pad-focus pair that must look identical.

## Reference screenshot URLs (not downloaded)

### Halo: Reach
- https://www.halopedia.org/images/a/a4/HR_Menu_Iron_Skulls.png?6347a : READ: original-file URL. Campaign Skulls option menu, Xbox 360 original, captured in the Xenia emulator, 1152x720. This is the best verified look at original Re
- https://www.halopedia.org/images/d/df/Loadouts.png?4c277 : READ: original-file URL. Loadout selection menu, 328x427, uploaded Oct 15, 2010. Small, but it is the only loadout screen found.
- https://www.halopedia.org/images/3/37/HTMCC-HR_ControllerLayoutDefault_Menu_Screenshot.png : INFERRED URL: original derived by removing 'thumb' and the size prefix from the read thumbnail https://halo.wiki.gallery/images/thumb/3/37/HTMCC-HR_ControllerLa
- https://www.halopedia.org/images/a/a1/HTMCC-HR_ConfigureGamepad_Menu_MergingMultipleScreenshots.png : INFERRED URL (same pattern; read thumbnail is https://halo.wiki.gallery/images/thumb/a/a1/HTMCC-HR_ConfigureGamepad_Menu_MergingMultipleScreenshots.png/120px-HT
- https://www.halopedia.org/images/7/73/HTMCC-HR_ThumbstickLayoutDefault_Inverted.png : INFERRED URL (read thumbnail: https://halo.wiki.gallery/images/thumb/7/73/HTMCC-HR_ThumbstickLayoutDefault_Inverted.png/200px-HTMCC-HR_ThumbstickLayoutDefault_I

### Halo 4
- https://www.halopedia.org/images/1/11/HTMCC_-_H4_-_Loadout_system_%28Xbox_One%29.png : Loadout screen, 1920x1080, Master Chief Collection (before the Nov 2020 update). URL read from the file page. I could not view the image.
- https://halo.wiki.gallery/images/f/f1/HTMCC_-_H4_-_Loadout_system_%28Xbox_One%2C_updated%29.png : Loadout screen after the update, 3840x2160. URL derived by the fetch tool from thumbnails, not verified.
- https://halo.wiki.gallery/images/e/ed/H4_-_Armor_permutation_menu_%28Xbox_360%29.png : Armor permutation (customization) menu, Xbox 360, 1920x1080. Best match for the live 3D character preview idea. URL derived, not verified.
- https://halo.wiki.gallery/images/f/fe/HTMCC-H4_ControllerLayoutDefault_Menu_Screenshot.png : Settings: the default controller layout screen, 1920x1080. URL derived, not verified. The same category also has the Forge, Theater and Iron Skulls menus.
- https://davidtauro.wordpress.com/wp-content/uploads/2012/11/structure.png : Menu hierarchy: Spartan and level as the focal point (as captioned on the blog). URL listed by the fetch tool, not verified.
- https://davidtauro.wordpress.com/wp-content/uploads/2012/11/simplicity.png : Campaign HUD, minimal layout with health and ammo on top. URL listed by the fetch tool, not verified. I found no direct main-menu or post-match image URL.

### Diablo IV
- https://bnetcmsus-a.akamaihd.net/cms/gallery/B2I91UC3N7Q31582662150361.jpg : Reorganized inventory layout (inventory / loadout screen). Pre-release 2020 build. Described from the article text; I did not view the image.
- https://bnetcmsus-a.akamaihd.net/cms/gallery/NC9DXF73C74Z1582662150907.jpg : Item icon style exploration: icons based on the 3D models, with the lower-saturation backgrounds and border-decoration rarity cue.
- https://bnetcmsus-a.akamaihd.net/cms/gallery/2MQ4LLY0WQ8V1582662150330.gif : Animated GIF of the unified UI for controller and keyboard/mouse. This is the best look at how focus moves in the grid.
- https://bnetcmsus-a.akamaihd.net/cms/gallery/1O4YU7H4PLPH1582662144832.jpg : HUD: left-corner action bar layout (the console / couch layout).
- https://bnetcmsus-a.akamaihd.net/cms/gallery/AC63RWTR66G61582662147884.jpg : Couch co-op UI with core progression screens open for two players.
- https://mir-s3-cdn-cf.behance.net/projects/404/c2bfb6208191515.Y3JvcCw4MzMsNjUxLDAsMA.png : Cover image of Fernando Forero's Diablo IV UI art project (24,050 views). Full-size UI frames and panels are on the gallery page. No main-menu, settings or post

### ARC Raiders
- https://arcraiders.wiki/w/images/e/e3/Inventory_%28default%29.jpg : In-raid Inventory menu (default layout): loot on the left, player gear and pockets alongside. Caption on page: 'Inventory menu'. Not visually checked.
- https://arcraiders.wiki/w/images/c/c4/Crafting_%28default%29.jpg : In-game crafting menu (second tabbed screen). Not visually checked.
- https://arcraiders.wiki/w/images/0/04/Settings.jpg : In-game settings menu (keybinds, graphics, audio tabs). Not visually checked.
- https://arcraiders.wiki/w/images/a/ab/Quick_use_wheel.jpg : Quick Use radial wheel over the first-person view, the closest thing to a HUD screenshot found (the wiki had no plain HUD image). Not visually checked.
- https://arcraiders.wiki/w/images/4/44/In-game_map.jpg : In-game map tab with player arrow, extraction countdown and waypoints. Not visually checked.
- https://arcraiders.wiki/w/images/9/98/Speranza.png : Lead image of Speranza, the hub town behind the main menu. The wiki gives no caption, so it may be location art rather than a true menu screenshot. No post-raid

### Fortnite
- https://interfaceingame.com/wp-content/uploads/fortnite/fortnite-lobby.png : Lobby with the character, tabs and quest/stats elements. READ: the URL comes from the page's Download link as reported by WebFetch; I did not open the image. No
- https://www.dexerto.com/cdn-image/wp-content/uploads/2023/10/10/FortniteMenu.jpg : Header image of the Oct 2023 UI revamp article, the post-redesign menu with options on the left. READ as a URL; I did not open the image.
- https://interfaceingame.com/wp-content/uploads/fortnite/fortnite-item-shop.png : Item Shop (menu/store). INFERRED URL from the naming pattern of the lobby image; the page URL is confirmed from the Fortnite listing. 2022-era layout.
- https://interfaceingame.com/wp-content/uploads/fortnite/fortnite-controller.png : Controller settings screen (tagged Menu, Settings). INFERRED URL by pattern; page confirmed.
- https://interfaceingame.com/wp-content/uploads/fortnite/fortnite-your-results.png : Post-match results overlay (tagged In game, Overlay, Progress, Stats). INFERRED URL by pattern; page confirmed.
- https://interfaceingame.com/wp-content/uploads/fortnite/fortnite-inventory.png : In-game inventory/HUD overlay (tagged In game, Inventory, Overlay, Stats). INFERRED URL by pattern; page confirmed. Other pages to try: /screenshots/fortnite-ba

### Destiny 2
- https://i.imgur.com/UWgHBXC.png : Destiny 2 'Enhanced travel UI' (Director) screen, from the article section on one-step travel. Identified by section, not viewed.
- https://i.imgur.com/UbABxSH.png : Destiny 2 Vault and Collection screen (inventory), from the section on Vault management. Identified by section, not viewed.
- https://i.imgur.com/HoGpRvJ.png : Destiny 2 challenges as shown on the Ghost screen, right side. Identified by section, not viewed.
- https://i.imgur.com/bxDGLqh.png : Destiny 2 HUD enemy health bar split into thirds (caption: adjusted bar helps see damage already dealt). Identified by caption, not viewed.
- https://images.mein-mmo.de/magazin/medien/2016/06/destiny-cursor.gif : Animated GIF of the Destiny cursor slowing and the icon popping on hover (the 'sticky' behaviour from Candland's talk). Destiny 1 era. Identified by filename an
- https://images.squarespace-cdn.com/content/v1/5438bd1be4b0446f6692b906/1432767784498-J2ZHBGUFA5E8XUYJKKGA/d_hud.jpg : Destiny 1 HUD screenshot (identified by filename d_hud.jpg only, not viewed). The same page has d_missions.jpg and a cursor GIF. No main menu, settings or post-
