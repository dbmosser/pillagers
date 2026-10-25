# Fact check: coop_feel_and_launch.md

Checked Sun 2026-10-25 with web search and web fetch only. Ten claims the conclusions lean on most, each tested against the cited page or a fresh search. Verdicts: confirmed (a page I read supports it), corrected (right fact and source given), unverified (no support found).

Bottom line: 6 confirmed, 3 corrected, 1 unverified. The three corrections change conclusions: the "90 seconds to decide" figure is not on presskit.gg, the Delta Force "25 to 50 s" bleed-out is only the first stage of a longer timer, and the Ubisoft subtitle numbers came from David Tisserand, not Ian Hamilton.

## The ten claims

### 1. itch.io traffic benchmark (169 developers, median 1,582 lifetime views, browser plays 37% of views versus about 7% downloads)
- Verdict: **confirmed**
- Source read: [How To Market A Game, "Benchmark: Itch.io traffic", May 12 2025](https://howtomarketagame.com/2025/05/12/benchmark-itch-io-traffic/)
- The page says "169 developers sent me their stats". Median 1,582; average 54,483 in the text (54,482 in the table); 70th percentile 12,150 in the text (13,380 in the table); 30th percentile 397.5 in the text (418 in the table). Browser plays: 37% at the median and 70th percentile, 27% at the 30th; downloads 6% to 6.9%. "For most games on itch.io, they get 0 traffic after that first month" and "You will not make money from Itch.io" are both on the page. The "3x more people will play your game if it is downloadable" typo is real.
- Caveats: the average row shows browser plays at 44.8% and a broken download figure (58,976, larger than the average views). The 37% versus 7% split is plays and downloads as shares of views across a self-selected sample, not a controlled browser-versus-download comparison, so "browser embed is the single biggest lever" is an inference, not a measured result.

### 2. Steam calendar around Thanksgiving 2026 (Winter Sale Dec 17 2026 to Jan 4 2027, no 2026 Autumn Sale listed)
- Verdict: **confirmed**
- Source read: [Steamworks, Upcoming Events](https://partner.steamgames.com/doc/marketing/upcoming_events)
- Next Fest Oct 19 to 26 2026; Steam Scream V Fest Oct 26 to Nov 2; Auto-Battler RPG Fest Nov 16 to 23; Winter Sale Dec 17 2026 to Jan 4 2027; Couch Co-Op Fest Feb 8 to 15 2027. The only Autumn Sale listed is "Autumn Sale 2027" with TBD dates. Nothing overlaps Thu 11/26.
- Note: dundle.com (reseller, not Valve) still says the 2026 Autumn Sale ran Oct 1 to 8; that remains unconfirmed by Valve. The upcoming events page would not list a sale that has already passed.

### 3. Kao, Ballou, Gerling, Breitsohl, Deterding, CHI 2024 (pre-registered, n = 1,699; success-dependent feedback raised all motives, amplification reduced them, curiosity the strongest enjoyment predictor and only playtime predictor)
- Verdict: **confirmed**
- Source read: [Imperial College Spiral record](https://spiral.imperial.ac.uk/entities/publication/253c32f5-d124-4a23-88b5-9aaaf114608d)
- Title "How does juicy game feedback motivate? Testing curiosity, competence, and effectance", CHI '24, Honolulu, May 2024. Pre-registered, n = 1,699, 2x2 plus control in a dedicated action RPG. Abstract: "Success dependence enhanced all motives, while amplification unexpectedly reduced them", possibly because the tested condition impeded players' sense of agency. Matches the notes exactly.

### 4. Kao 2020, Entertainment Computing (no, medium, high, extreme juice; medium and high beat none and extreme)
- Verdict: **confirmed** (secondary sources only; the paper itself was not read)
- Source read: [Improbable Research, June 1 2020](https://improbable.com/2020/06/01/the-effects-of-juiciness-in-an-action-rpg-new-study/)
- Entertainment Computing vol. 34, May 2020, Dominic Kao and colleagues, Purdue. Four versions: No, Medium, High and Extreme Juiciness. "Overall, both Medium Juiciness and High Juiciness outperform No Juiciness and Extreme Juiciness across all measures." The arXiv survey (2011.09201) PDF did not render as text through fetch. The participant count was not found.

### 5. Nuclear Throne per-shot recipe (camera 6 px back, +4 shake, gun kick 2, 16 px per frame bullet, 3 px per frame knockback, 10 to 20 ms freeze on hit, at 30 fps and 320x240)
- Verdict: **confirmed** (through the contemporary blog quote; the Rock Paper Shotgun original was not found)
- Source read: [Tom Armitage, infovore.org, "Making Game Feel", Oct 22 2013](https://infovore.org/tag/feel/)
- The post quotes Graham Smith's RPS interview with Jan Willem Nijman (URL dated 21 Oct 2013): camera kicked back 6 px, "add 4 to the screenshake", kick 2, shells at "2-4 pixels per frame, at 30fps and a 320x240 resolution", bullet 16 px per frame with 0 to 4 degrees spread, enemy pushed 3 px per frame, and "The game also freezes for about 10-20 milliseconds whenever you hit something."
- Caveat: the values are from the 2013 Early Access build. A search summary said a December 2025 anniversary update added widescreen and 60+ fps, so current values may differ (that update was not checked).

### 6. Sword Arcade tiers (hit stop 35/70/90 ms capped near 120 ms; shake 4/8/12 px decaying over 0.2 to 0.3 s; reduced motion turns both off)
- Verdict: **confirmed** (the page says this; it is a low-authority guide, not a studio source)
- Source read: [Sword Arcade, "Game Feel: Hit-Stop and Screen Shake Explained"](https://swordarcade.xyz/guides/game-feel-hitstop-and-screen-shake/)
- Published Sep 3 2026 by "Alex Morgan". Light 35 ms, heavy 70 ms, perfect 90 ms; capped at about 120 ms because longer "reads as a dropped frame rather than as impact"; shake 4, 8 and 12 px; decay about 0.2 to 0.3 s; both "disabled automatically if your system requests reduced motion", score labels still drawn.
- Caveat: no shipped game or studio is cited for these numbers. Top 15 item 1 leans on them as if they were an industry standard; treat them as one guide's starting values.

### 7. Hades snaps aim up to 90 degrees; Death's Door corrects at most 15 degrees and never shows it
- Verdict: **unverified**
- What I found: only the VoiceTube transcript mirrors (tw. and jp.voicetube.com/videos/173139). Both pages render only "Loading..." through fetch, so I could not read the transcript myself. Search-engine summaries of those pages repeat the 90 and 15 degree figures and say the presenter reverse engineered both games, but the original YouTube video, its creator and its date were not found, and no independent source gives either number. A Steam thread confirms only that Hades has an aim assist toggle in its controls menu.
- Impact: Top 15 item 5 ("at most about 15 degrees") rests on this one unverified figure. The UCSD 2026 config (3 and 8 degree cones) and Venturelli (about 30 degree auto-aim cone) are the checkable references.

### 8. Delta Force downed timer (50 s first, 40 s second, 25 s third and later; carrying pauses it, first timer only)
- Verdict: **corrected**
- Source read: [HiTech Gazette, "Hidden Mechanics Every Delta Force Medic Should Know", Oct 7 2025](https://hitechgazette.com/hidden-mechanics-for-medics-in-delta-force/)
- The numbers are on the page, but they are only the first stage. When that window runs out the player enters a separate "final bleedout" of three minutes in which a teammate can still revive them (at 20 less max health for the round); only after that is the player out. So the full time from down to death in Delta Force is about 3 min 25 s to 3 min 50 s, not 25 to 50 s. Carrying pauses only the first window.
- Impact: the "25 to 50 s bleed-out window used by shipped games" takeaway (section 1 and Top 15 item 9) is overstated. Of the cited games only Project Lazarus (45 s, not rechecked) fits a single 25 to 50 s window. No official Delta Force source or patch note was found to back the fan site either.

### 9. Ubisoft subtitle defaults (97% Far Cry New Dawn and 95% Assassin's Creed Odyssey kept them on by default; about 60% turned them on in Origins when off by default), "relayed by Ian Hamilton"
- Verdict: **corrected** (numbers right, attribution wrong)
- Sources read: [Shazoo, June 27 2019](https://shazoo.ru/2019/06/27/81229/ubisoft-bolshinstvo-gejmerov-igrayut-s-subtitrami); [Can I Play That, May 13 2020](https://caniplaythat.com/2020/05/13/top-five-reasons-games-need-subtitles/); [Ubisoft News (Spanish), May 16 2019](https://news.ubisoft.com/es-es/article/5PU9CjjhOINxTzEQOtQJI0/accesibilidad-en-ubisoft-creando-juegos-para-todos)
- The figures were posted on Twitter in June 2019 by David Tisserand, Ubisoft's accessibility project manager, not by Ian Hamilton. Shazoo gives New Dawn 97%, Odyssey 95%, Origins about 60%, and adds The Division 2: off by default, 75% turned them on at least once. Ubisoft's own article confirms only the Origins 60% (Tisserand quote). The tweet itself was not fetched, so the Odyssey and New Dawn figures rest on press relays.

### 10. "A demo visitor gives you about 90 seconds before deciding whether to keep playing" (cited to presskit.gg)
- Verdict: **corrected**
- Source read: [presskit.gg, "How to build a game demo", Dec 27 2025](https://presskit.gg/field-guides/how-to-build-game-demo); [gtstu.com, June 6 2026](https://gtstu.com/2026/06/06/game-demo-strategy-indie/)
- presskit.gg does not contain "90", "seconds" or "first minute" anywhere; it recommends 15 to 30 minutes of demo content. The sentence actually comes from gtstu.com: "A Steam Next Fest visitor who downloads your demo gives you about 90 seconds before deciding whether to keep playing." That article cites no source for it and is about Steam Next Fest downloads, not walk-up play.
- Impact: section 3's takeaway and Top 15 item 10 use this as a measured figure. It is an uncited rule of thumb. The itch.io TD postmortem (below, confirmed) is the better support for "show the hook in the first two minutes."

## Also checked (not in the ten)
- Arrowhead quote, **confirmed**: "A good co-op game forces players to play together, but a great one makes players want to play together" is Johan Pilestedt (CEO and creative director) in Heidi Kemps' PlayStation Blog piece of Mar 12 2024; the "shares the same reality", "does not allow for more immersive experiences" and "watering hole" lines are his too. [PlayStation Blog](https://blog.playstation.com/2024/03/12/helldivers-2-how-arrowhead-turned-the-twin-stick-shooter-original-into-a-bombastic-ps5-sequel/)
- itch.io Most Recent is one-time, **confirmed**: "It can not be put on the top of the Most Recent page again"; drafts and restricted pages are not eligible for browse; GIF covers must avoid seizure-inducing effects per WCAG. [itch.io Quality guidelines](https://itch.io/docs/creators/quality-guidelines)
- Solo browser TD postmortem numbers, **confirmed**: about 100 players in 2.5 days, 55 on launch day, about 50 completed runs, about 23 hours, sessions 11.6 min on launch day and 80 min on day 3, D1 retention 2%, and "Fix your first session BEFORE the traffic arrives". No absolute post date shown ("created 98 days ago", so about mid July 2026). [itch.io forum](https://itch.io/t/6645181/launch-week-postmortem-solo-browser-td-product-hunt-a-portal-rejection-and-a-flagged-show-hn-numbers-inside)
- Venturelli numbers, **confirmed**: stick noise "0.05 to 0.15", 0.3 dead zone given as an example only, "12 degrees per frame in a 60fps game" as an example, auto-aim "about 30 degrees", "3 or more people independently complain". Aug 17 2015. [Game Developer](https://gamedeveloper.com/design/everything-i-learned-about-dual-stick-shooter-controls)
- itch.io average PWYW donation, **confirmed**: "The average donation is $3.68" and "Most people pay between $1 and $5", for payments to free content; leafo, June 20 2015. The post does not say per payer. [itch.io blog](https://itch.io/blog/2/running-an-indie-game-store-2015)
- MDN playEffect, **partly confirmed**: "dual-rumble" and "trigger-rumble" types, duration and startDelay in ms, magnitudes 0.0 to 1.0, promise resolves "complete" or "preempted", not Baseline. Neither the playEffect nor the vibrationActuator page states a secure-context requirement, so the "needs a secure context" part is not supported by the cited MDN page. [MDN](https://developer.mozilla.org/en-US/docs/Web/API/GamepadHapticActuator/playEffect)
