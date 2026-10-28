# Accessibility guidelines and sound design for in-game alerts, notifications and HUD text

Scope note: researched 2026-10-27. Xbox Accessibility Guidelines (XAG) pages were read directly on learn.microsoft.com (current XAG version 3.2, published 2023-06-08; pages last updated 2026-06-17). Where a page carries no date it is marked "undated". Numbers below are copied from the source, not estimated.

## 1. Xbox Accessibility Guidelines: which XAGs cover alerts, and what they require

### Takeaway
Six XAGs bear directly on HUD alerts: 101 (text display), 102 (contrast), 103 (every critical cue on at least two senses, never colour alone), 104 (captions for important sounds, with direction), 116 (players can lengthen on-screen durations to 10x or dismiss on input) and 117/118 (no uncontrollable blinking; flash limits). The hard numbers for a PC game at 1080p are: text at least 18 px tall, contrast at least 4.5:1 (3:1 for text 36 px and up), 7:1 in a high contrast mode, flashes no more than about 3 per second over about 20% of the screen.

### Cited Findings

**XAG 101 Text display** ([XAG 101](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101), ms.date 2022, updated 2026)
- Explicitly names "error messages, toasts, and other notifications" and HUD text as key areas; any text setting the player changes (size, weight, contrast) should carry over to all important text, including overlay windows.
- Minimum default text size, measured as body height (lowest descender to highest ascender): console 26 px at 1080p / 52 px at 4K; PC/VR 18 px at 1080p / 36 px at 4K; mobile/streaming 18 px at 100 DPI, 36 px at 200 DPI, 72 px at 400 DPI, linear above.
- When measuring outlined text, edge pixels count toward the height only if their contrast to the background is above 2:1.
- Platform screen magnifiers are not an acceptable fix for small text.
- Text inside icons/glyphs (button prompts) must also meet the minimum size, and icons should scale with text up to 200%.
- Players should be able to scale text to 200% of the minimum (example: console 26 px to 52 px at 1080p) without losing content; scaled text must not need scrolling in two directions; scaling below the minimum is allowed at the player's choice.
- Provide at least one sans serif option; if a stylised font is used, offer a plain one.
- For blocks of more than two lines: line width at most 80 characters (40 for CJK), line spacing at least 1.5, paragraph spacing at least 2x line spacing, letter spacing at least 0.12x font size, word spacing at least 0.16x.
- Case: provide sentence case rather than full caps or full lower case for lines of text; the page states that a one- or two-word label is exempt.
- Alignment: left/right per language, not centred or justified (or player-adjustable).
- Example cited: Immortals Fenyx Rising puts a black outline on in-world prompt text so it reads on any background.

**XAG 102 Contrast** ([XAG 102](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102), ms.date 2023, updated 2026)
- Lists "toast messages, or other title-specific notifications" and HUD elements (health meters, directional cues, map elements, damage "halo" indicators) as areas to test.
- Standard-size text and important visual elements: at least 4.5:1 against background.
- Large text and large visual elements: at least 3:1. Large = PC 36 px at 1080p / 72 px at 4K; console 52 px at 1080p / 104 px at 4K.
- Inactive (greyed) element text: at least 3:1.
- High contrast mode should be offered; when on, all UI elements at least 7:1.
- Over non-solid backgrounds (the normal case for a HUD over gameplay), measure against the lowest-contrast area behind the text.
- Recommended fixes: optional solid plate behind on-screen text with adjustable opacity, player-chosen text/element colours, borders/outlines. For Honor example: icons get a black outline plus a white outer outline so they read on both dark and light ground.
- Avoid relying on colour alone; where unavoidable let players pick the colour of key elements (Battlefield 2042 custom HUD colour picker with a preview in dark, mid and bright scenes).

**XAG 103 Additional channels for visual and audio cues** ([XAG 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103), ms.date 2022, updated 2026)
- Any visual content critical to gameplay must also be expressed through at least one other sense (spatial audio or haptics); any critical audio must also be expressed visually (example given: gunfire shown with a graphic that indicates type and direction).
- Colour alone should never carry information; critical colour-coded content needs a second signifier (shape, pattern, icon or text label).
- Haptics must always be paired with at least one other cue, because players may disable rumble or use devices without it (keyboard and mouse, Xbox Adaptive Controller).
- Symbols plus a text label: an exclamation mark reads as "alert" quickly, but the guideline says the accompanying label matters equally.
- Examples: Grounded plays an audio cue when a new objective appears; Grounded uses distinct sounds for a missed swing, a hit, and a kill; Gears 5 "Fabricator Ping" grows louder and faster as the player approaches.
- Greyed-out unavailable controls need a second indicator (lock icon or "not available" text), not just the grey.

**XAG 104 Subtitles and captions** ([XAG 104](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/104), ms.date 2022, updated 2026)
- Captions must cover all important sounds not already shown visually, with spatial indicators (arrows such as < >) when the source is off screen. Examples: Minecraft Java directional sound subtitles; Far Cry New Dawn "explosion" caption with arrow; Gears 5 "<music intensifies>".
- Different caption types (main dialogue, background chatter, ambient sounds) should toggle independently. The Outer Worlds splits conversation, bark and cinematic subtitles.
- Caption text: minimum size per XAG 101 (larger encouraged because it is on screen briefly), scalable to 200%, lines under 40 characters, no more than 2 lines (3 in exceptional cases), mixed case, sans serif option, player-configurable solid background with opacity 0 to 100%, placed toward the bottom so it does not cover key UI.
- Provide a live preview of the caption settings, ideally in a game context (Forza Horizon 4).

**XAG 105 Audio accessibility** ([XAG 105](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/105), ms.date 2022, updated 2026)
- Independent volume or mute for at least: music, voice-over, active (gameplay-critical) sound effects, background/ambient effects, narration, voice chat. Grounded example adds a separate UI slider.
- Mono audio toggle (for single-sided hearing loss) and optional spatial audio.
- Option to automatically lower or mute game audio while a screen reader speaks (the only ducking rule in the XAGs).

**XAG 116 Time limits** ([XAG 116](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/116), ms.date 2023, updated 2026)
- Scope explicitly includes on-screen tutorials, notifications and chat windows that disappear after a set time; core gameplay timers (race clocks, match timers) and real-time multiplayer lobby countdowns are exempt.
- For elements whose on-screen time is limited (tutorial text, dialogue, chat, speech-to-text): players can set the duration in settings before meeting it, up to at least 10x the default; or durations can be turned off and the element dismissed or advanced on input.
- For UI time limits: warn in multiple ways; at least 20 seconds to extend with a simple action, extendable at least 10 times; or turn the limit off.
- Examples: Halo Infinite text chat display time 5 to 120 s; Gears 5 text chat up to 60 s; The Outer Worlds "Notification Duration" slider.

**XAG 117 Visual distractions and motion** ([XAG 117](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/117), ms.date 2022, updated 2026)
- Blinking, scrolling, flashing or auto-updating content shown with text needs a way to pause, hide or fully disable it, and auto-updates need a frequency control.
- Ancillary gameplay around in-play text is exempt, but an adjustable-opacity plate behind in-play text is recommended (Sea of Thieves).
- Avoid camera shake, head bob, motion blur, or give an off switch; Halo Infinite has 0 to 100% sliders for blur, screen shake and full-screen effects.

**XAG 118 Photosensitivity** ([XAG 118](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118), ms.date 2022, updated 2026)
- About 1 in 4,000 people can have a photosensitive seizure; removing triggers is preferred over warning screens.
- General flash = 10% luminance change with the darker state below 0.8; fails at roughly more than 3 flashes per second over roughly 20% or more of the screen, or lower-intensity flashing sustained a long time.
- Red flash: applies when either state is saturated red (R/(R+G+B) >= 0.8), a lower threshold than general flashes; fix by desaturating, lowering contrast, frequency or size.
- Spatial patterns: high-contrast bands (over 10% contrast difference) covering about 20% or more of the screen fail.
- Recommended test tool: Harding FPA.

### Inferences
- For a PC 2.5D shooter at 1080p, the binding size floor for alert text is 18 px body height (36 px at 4K), and every prompt glyph inside a key cap must meet it too.
- Alert text drawn straight over the moving world will rarely hold 4.5:1 everywhere; the XAG-endorsed fixes are an outline (dark plus light), or a plate whose opacity the player can raise.
- A "how long alerts stay" setting (default, plus up to 10x, or "until dismissed") is the cheapest way to satisfy XAG 116 for transient HUD messages.
- Pulsing or blinking alert frames (e.g. a red low-health border) are subject to both XAG 117 (needs an off switch) and XAG 118 (keep pulse below 3 Hz and below 20% of screen, take care with saturated red).

### Gaps
- The XAG index page did not list all guideline titles; XAG 112 (UI navigation), 114/115 and others were not fetched, so any rule there about notification focus or menu navigation is not covered here.
- XAGs give no default duration (in seconds) for a transient notification; they only require it be adjustable.

## 2. Game Accessibility Guidelines, AbleGamers, PlayStation, Ubisoft, CVAA

### Takeaway
Game Accessibility Guidelines (GAG) mirror the XAG rules at three tiers and add two alert-specific rules: keep temporary essential information near where the player is looking, and never rely on sound alone or text alone. CVAA only legally covers communication features (chat), not HUD alerts. Public PlayStation and Ubisoft developer rules were not found.

### Cited Findings
- GAG items relevant to alerts, with tier, from the full list ([gameaccessibilityguidelines.com full list](https://gameaccessibilityguidelines.com/full-list/), undated page):
  - Basic: use simple clear text formatting; use an easily readable default font size; use simple clear language; ensure no essential information is conveyed by a fixed colour alone; provide high contrast between text/UI and background; avoid flickering images and repetitive patterns; allow players to progress through text prompts at their own pace; ensure no essential information is conveyed by sounds alone; separate volume controls or mutes for effects, speech and background/music.
  - Intermediate: avoid placing essential temporary information outside the player's eye-line; ensure no essential information (especially instructions) is conveyed by text alone, reinforce with visuals and/or speech; offer a choice of text colour; option to adjust contrast; important supplementary audio information (e.g. direction you are being shot from) replicated in text/visuals; captions or visuals for significant background sounds; sound/music choices for each key object/event distinct from each other; option to hide background movement; customisable subtitle presentation.
  - Advanced: allow font size to be adjusted; option to turn off / hide all non-interactive elements; subtitles cut to an appropriate words per minute; distinct sound/music design for all objects and events.
- Eye-line rule detail: peripheral vision loss makes edge-of-screen temporary messages easy to miss; persistent HUD on the edges is acceptable because players learn where it is, but temporary, gameplay-essential items should not sit far from the player's focus; it also states audio cues alone are not sufficient. God of War 3 quick-time prompts are cited as a poor example, Tony Hawk HD prompt placement as good ([GAG: eye-line](https://gameaccessibilityguidelines.com/avoid-placing-essential-temporary-information-outside-the-players-eye-line/), undated).
- Simple clear language: 14% of adults in the USA and UK have a reading age below 11; low reading ability is described as the most common impairment creating barriers in games; preferred wording example is the short imperative "Click below to save your character" over a longer conditional sentence ([GAG: simple clear language](https://gameaccessibilityguidelines.com/use-simple-clear-language/), undated).
- XAG 101 links AbleGamers' Accessible Player Experiences patterns "Clear Text" and "Distinguish This From That" as supporting resources ([XAG 101 resources](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101), 2022/2026).
- CVAA: the FCC's last waiver for video game software expired 2018-12-31; games released from 2019-01-01 (and substantial upgrades of older ones) must make advanced communications services, i.e. in-game text and voice chat, accessible; developers must keep records and certify annually ([Fenwick, 2018](https://www.fenwick.com/insights/publications/cvaa-compliance-waiver-for-video-games-set-to-expire-in-december-2018); [Patent Arcade, 2019](https://www.patentarcade.com/2019/01/video-games-with-advanced-communications-services-must-now-be-accessible-to-players-with-disabilities.html)).
- One editorial site gives a 2013 expiry date for the waiver; this conflicts with the law-firm sources above and should be treated as unreliable ([disabilityworld.org editorial, 2026](https://www.disabilityworld.org/articles/game-accessibility-2026/)).

### Inferences
- A HUD alert feed in a corner (e.g. top right) is fine for persistent status, but one-shot critical alerts (being hit from off screen, extraction closing) should also appear near the crosshair or the player's character, per the eye-line rule.
- CVAA does not apply to a local same-PC co-op game without chat; it becomes relevant only if text or voice chat between players is added.

### Gaps
- No public PlayStation developer accessibility guideline document was found (Sony's guidance appears to be partner-only); not verified.
- Ubisoft's internal accessibility standards and AbleGamers' Includification (2012) were not fetched; their exact rules on notifications are not covered.
- The GAG words-per-minute page was not fetched, so its recommended reading rate is not recorded here.
- The GAG site shows no publication or revision date.

## 3. How accessible AAA games handle alerts, and settings to filter or move them

### Takeaway
Leading games turn sound into directional HUD indicators (Fortnite, TLOU Part II), let players pick which alert classes fire (Diablo IV loot cues, The Outer Worlds subtitle classes), let players set how long messages stay (Halo Infinite, Gears 5, The Outer Worlds), and make non-verbal team alerts the default channel (Apex pings).

### Cited Findings
- The Last of Us Part II ships more than 60 accessibility settings. Alert-relevant ones: Awareness Indicators (HUD warning when an enemy is about to spot you, with direction), Damage Indicators (HUD spikes toward the damage source), Pick-Up Notifications (HUD message for ammo and resources), hints after being stuck, HUD scale, HUD colour and background darkness, High Contrast Display, text-to-speech for on-screen text, extra traversal and combat audio cues, combat vibration cues, and an Audio Cue Glossary where players can browse and hear each cue ([PlayStation Blog, Matthew Gallant, Naughty Dog, 2020](https://blog.playstation.com/2020/06/09/the-last-of-us-part-ii-accessibility-features-detailed/)).
- Fortnite's "Visualize Sound Effects" (Audio menu) draws on-screen icons for nearby footsteps, gunfire and chests; Epic's help page lists visual cues for hearing-impaired players ([Epic Games help, undated](https://www.epicgames.com/help/en-US/fortnite-battle-royale-c-202300000001636/gameplay-c-202300000001721/are-there-any-accessibility-settings-for-fortnite-a202300000015585); [esports.gg guide, undated](https://esports.gg/guides/fortnite/how-to-turn-on-visual-sound-effects-in-fortnite)).
- A 2024 report said Epic was considering removing sound visualisation from competitive modes only; not confirmed ([FRVR, 2024](https://frvr.com/blog/news/fortnite-removing-visual-audio)).
- Diablo IV (pre-launch details, 2023): three in-game font sizes (small, medium, large), resizable cursor, built-in screen reader with volume/speed/voice options plus JAWS/NVDA support, subtitle colour/scale/background opacity, and loot-drop audio cues that players can disable or limit to chosen gear types, plus ambient cues that signal rarity of items on the ground ([Can I Play That, 2023](https://caniplaythat.com/2023/05/23/diablo-iv-accessibility-detailed-by-blizzard/)).
- Halo Infinite text chat display time 5 to 120 s; Gears 5 text chat up to 60 s; The Outer Worlds notification duration slider and separate conversation/bark/cinematic subtitle toggles; Gears 5 Fabricator Ping audio beacon; Forza Horizon 4 colour-blind presets and subtitle preview; Battlefield 2042 custom HUD colours with preview ([XAG 116](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/116), [XAG 104](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/104), [XAG 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103), [XAG 102](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102); 2022 to 2023, updated 2026).
- Halo Infinite: 0 to 100% sliders for radial blur, screen shake, full-screen effects and speed lines ([XAG 117](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/117), 2022/2026).
- Apex Legends: Respawn playtested the context-sensitive ping system for about a month with voice chat off and fake names to simulate strangers; pings mark loot, enemies, looted areas and ammo requests ([PC Gamer, 2019](https://www.pcgamer.com/au/apex-legends-ping-system-is-a-tiny-miracle-for-fps-teamwork-and-communication/); [Mein-MMO, undated](https://mein-mmo.de/en/the-ping-system-of-apex-legends-is-so-good-that-other-shooters-want-to-copy-it,331956/)).

### Inferences
- The common pattern is per-class control: each alert family (loot, threat, team, objective) gets its own on/off, and sometimes a filter (Diablo IV by gear type). This maps to a small settings block rather than one "notifications" switch.
- An "audio cue glossary" (TLOU2) is a low-cost way to teach distinct alert sounds; it doubles as a test page for the sound set.
- Directional threat alerts (awareness, damage spikes, sound icons) are drawn around the player or screen centre, not in a corner feed, which matches the GAG eye-line rule.

### Gaps
- Gears 5, Forza and Apex HUD notification repositioning settings (moving the feed) were not confirmed from primary sources; no source found that a major shooter lets players drag the alert feed.
- Can I Play That reviews of individual shooters were not read beyond the Diablo IV news item.
- Apex's own accessibility settings for alerts were not checked.

## 4. Pairing alerts with sound: when, priority, ducking, fatigue, earcons

### Takeaway
Primary sources support three rules: every critical alert needs a second sense (sound for visuals, visuals for sound); alert sounds must be distinct per event family; and the mix must rank sounds by gameplay importance so threats cut through (Overwatch threat scoring, DICE loudness-as-priority with culling). No game-audio primary source on "alarm fatigue" was found.

### Cited Findings
- Overwatch (GDC 2016, Scott Lawlor and Tomas Neumann): goal was a shooter you can "play by sound"; pillars included a clean mix, pinpoint accuracy, sounds that carry gameplay information, and descriptive hero voice-over. Each player in a 6v6 match gets an importance score in the mix based on how large they appear on the listener's screen; enemies not aiming at you get fewer "threat points" and sit lower; path distance (how long an enemy's route to you is) adjusts threat, so enemies behind walls without a quick path are quieter or muffled; every hero has a distinct footstep ([PCGamesN, Mathew Kumar, 2016](https://pcgamesn.com/overwatch/overwatch-devs-on-creating-a-game-you-can-play-by-sound-and-announcing-dolby-atmos-support); talk listing [GDC Vault, 2016](https://gdcvault.com/play/1023010/Overwatch-The-Elusive-Goal-Play)).
- DICE HDR audio (Battlefield: Bad Company, GDC 2009, Anders Clerwall): loudness at the listener is computed and the mix window slides to fit, covering roughly 130 dB; loudness is used as priority and as a culling rule, so quiet sounds drop out when loud important ones play; output is then mastered for three device presets (hi-end, hi-fi, TV). DICE's Stefan Strandberg described the intent as a film-style mix where a gunshot can briefly dominate an engine ([Frostbite news, 2009](https://www.ea.com/frostbite/news/how-hdr-audio-makes-battlefield-bad-company-go-boom); [DICE slides on SlideShare, 2009](https://www.slideshare.net/slideshow/adaptive-mixing-in-frostbite/3128152); [MCV/UK interview, undated](https://mcvuk.com/?p=146207)).
- A designer write-up notes HDR systems' loudness values often end up tuned far from real-world dB figures in practice ([Designing Sound, 2013](https://designingsound.org/2013/06/21/finding-your-way-with-high-dynamic-range-audio-in-wwise/)).
- Distinct sounds per event: GAG Intermediate "sound/music choices for each key object/event distinct from each other" and Advanced "distinct sound/music design for all objects and events" ([GAG full list, undated](https://gameaccessibilityguidelines.com/full-list/)); XAG 103's Grounded example uses different sounds for miss, hit and kill, and an audio cue when a new objective appears ([XAG 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103), 2022/2026).
- Earcon design research (Brewster, Wright and Edwards, Glasgow): build earcon families from timbre, register and rhythm; give each family its own timbre (and default register), use rhythm for sub-groups; musical timbres beat simple tones in their 1993 experiments; varying the number of notes in a rhythm is an effective differentiator; register is unreliable for absolute judgements and needs gross differences for relative ones ([Glasgow earcon guidelines, undated, c. 1995](https://www.dcs.gla.ac.uk/~stephen/earcon_guidelines.shtml); [Brewster et al., CHI 1993](https://www.dcs.gla.ac.uk/~stephen/papers/CHI93.PDF)).
- Separate volume for active (gameplay-critical) effects vs ambient effects vs music vs voice, and an optional UI channel, lets players keep alerts audible while lowering the rest ([XAG 105](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/105), 2022/2026).
- Haptics may supplement but never replace an alert cue ([XAG 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103), 2022/2026).
- Gears 5 Fabricator Ping encodes distance as rising volume and repeat rate, an example of a continuous sonified alert rather than a one-shot ([XAG 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103), 2022/2026).
- Diablo IV lets players switch loot-drop cues off entirely or limit them to selected gear types, i.e. player-side filtering of a frequent alert class ([Can I Play That, 2023](https://caniplaythat.com/2023/05/23/diablo-iv-accessibility-detailed-by-blizzard/)).
- Fortnite's sound visualiser shows that frequent world sounds (footsteps, gunfire) can be carried as icons rather than extra alert sounds ([Epic Games help, undated](https://www.epicgames.com/help/en-US/fortnite-battle-royale-c-202300000001636/gameplay-c-202300000001721/are-there-any-accessibility-settings-for-fortnite-a202300000015585)).

### Inferences
- A workable rule set for a shooter HUD: (a) threat and life-or-death alerts get a sound plus a visual, and top mix priority; (b) objective and economy alerts get a short, quieter earcon from a different timbre family; (c) high-frequency events (each pickup, each coin) get either no sound or a very soft tick, and may be filtered by the player, because Diablo IV and Fortnite both move frequent events away from loud one-shots.
- Overwatch and DICE both rank by gameplay importance rather than playing everything: a cap on concurrent alert sounds plus priority by class is consistent with both, though neither source gives a specific voice cap.
- Using one timbre per alert family and rhythm (note count) per alert within the family follows the Brewster earcon guidelines directly.

### Gaps
- No primary game-audio source on "alarm fatigue" was found; the concept is documented in clinical alarm literature, which was not fetched.
- The Overwatch GDC Vault page was in maintenance (redirected), so the talk's slides on voice-line priority (e.g. enemy vs friendly ultimate lines being louder) could not be confirmed; the Audiokinetic Overwatch blog returned HTTP 403.
- No source gave concrete ducking amounts (dB) or durations for alert sounds in shooters.
- Apex and Fortnite audio GDC talks were not located.

## 5. Wording: short callouts, verbs first, consistent terms, case

### Takeaway
Guidelines favour short, plain, direct wording (GAG) and sentence case for lines of text (XAG 101, XAG 104), but XAG 101 exempts one- and two-word labels from the case rule. Lab evidence (Arditi and Cho 2007) shows all-caps is more legible than mixed case at small sizes and for low vision; no study was found on all lower case for game HUD text.

### Cited Findings
- XAG 101: offer sentence case instead of full caps or full lower case for lines of text; one- or two-word labels are exempt ([XAG 101](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101), 2022/2026).
- XAG 104: subtitle and caption font should be mixed case, described as much easier to read than all one case ([XAG 104](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/104), 2022/2026).
- XAG 103: pair symbols with a short text label; text labels "take the guesswork out" of what an icon means (Forza "new" label under map icons) ([XAG 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103), 2022/2026).
- GAG Basic: use the most straightforward language the style allows, keep text concise, but do not oversimplify; example favours a short imperative over a longer conditional sentence; 14% of USA/UK adults read below age 11 level ([GAG: simple clear language](https://gameaccessibilityguidelines.com/use-simple-clear-language/), undated).
- GAG Intermediate: instructions should not be conveyed by text alone; reinforce with visuals or speech ([GAG full list, undated](https://gameaccessibilityguidelines.com/full-list/)).
- Arditi and Cho, Vision Research 2007: using one font in all upper, all lower and mixed case, lower-case size thresholds were about 0.1 log unit higher than upper case; reading speed was higher for upper than mixed case at about twice acuity size (F(1,20) = 5.53, p = 0.029); at large sizes the upper-case advantage disappeared. Authors conclude upper case is more legible for low-vision readers and for anyone when text is visually small, at a fixed point size ([Arditi and Cho, 2007, PMC2016788](https://pmc.ncbi.nlm.nih.gov/articles/PMC2016788)).

### Inferences
- Short HUD callouts of one or two words sit inside the XAG 101 case exemption, so an all-lower-case house style for callouts does not conflict with XAG; longer lines (tips, tutorial sentences, captions) are where XAG asks for sentence case as an option.
- The legibility cost of lower case appears mainly at small sizes: lower-case letters are physically smaller at the same point size, so lower-case callouts should be set at or above the 18 px body-height floor, ideally larger for alerts read in a glance.
- Verb-first imperatives ("reload", "extract now") follow the GAG plain-language example pattern, but no source tested verb-first word order specifically.

### Gaps
- No primary study found on verb-first ordering, or on consistent vocabulary effects, for game alerts.
- No study found comparing all lower case against sentence case for very short game callouts; Arditi and Cho compared upper vs lower vs mixed for words, strings and running text, not HUD callouts.
- No primary source found for a recommended maximum word count per HUD alert.
- A separate Arditi and Cho 2005 study on serifs (reported in search results as finding little effect on reading speed) was not fetched, so it is not cited.
