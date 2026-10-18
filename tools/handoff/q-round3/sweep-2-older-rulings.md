# Sweep 2: his older rulings (Sept 1 to Oct 12), checked against the newer ones and the game as of 10-18

Read-only sweep. Sources: the 28 older memory files, the 7 newer ones (10-13 to 10-18), the 10-18 questions file (so each numbered answer is read against the question it answered), and greps of dark_raiders.html, DESIGN.md and AUDIT.md.
Memory files named below live in C:\Users\User1\.claude\projects\C--Users-User1-Desktop-dark-raiders\memory\.
Finding types: contradiction (two rulings disagree and the file never says which stands), stale (written for a plan that is gone), unclear (the helpers need a concrete choice), undecided (never decided), reconfirm (old decision worth one more yes).
Line numbers in dark_raiders.html and DESIGN.md move all day because helpers keep editing, so code is cited by grep-able quote, not by line.

40 findings: A) party night (18), B) words and naming (10), C) progression and rules (4), D) after the party (8).

## The 5 that matter most before the 10/26 cutoff
1. S2-02 Two-player score rules: his answers 65 (run ends when both are out), 62 (one board entry per player) and 60 (ending early halves) do not say how the doubling, the halving and the respawn-loses-everything rule combine. The board is the party's headline.
2. S2-04 Settings are open to guests (answer 30) but his fair-board rule (answer 67) and "gameplay identical" rule need the same rules for everyone. The demo also starts from his own saved dials.
3. S2-01 "No tutorial prompts" (answer 70) against the [E] verbs, the controls card, the how-to page and the finisher prompt he asked for on 10-15.
4. S2-06 "Keys go to the window in front" (10-18 afternoon) with player 1 on keyboard and mouse: one stray click puts player 1's keys into player 2's window. "P2 pad or window fails" is his third-worst fear.
5. S2-03 The Forge is paid with score, but in the demo "high score is the only objective", so upgrading lowers your own score.

---

# A) Party night (ask these first)

### S2-01. What counts as a "tutorial prompt"?
- **Type:** contradiction
- **Ruling (pillagers-answers-1-78-2026-10-18.md, #70, 10-18):** "No tutorial prompts. The game must be completely self-explanatory."
- **Against it:**
  - pillagers-polish-answers-2026-10-15.md #14 (10-15): "Finisher: keep. "i didn't see a prompt telling me how to do the finisher", so add a prompt."
  - Same file #30: ""i don't know what all those mean": he never noticed the events, so they need clear alerts, names and map marks." And #48/#49: "make it discoverable".
  - pillagers-arcade-demo-2026-10-11.md: "a big controls card on the demo video and at each spawn".
  - pillagers-answers-third50-2026-10-12.md: "The [E] icon and a verb at the object."
  - pillagers-answers-1-78 #52 (same 10-18 file) keeps "how-to pages" behind the title.
- **What is unclear:** the game today shows the [e] verb at objects, a controls card at spawn, a how-to page on the idle screen, and (from 10-15) a finisher prompt. Answer 70 was the reply to a question that offered one-line hints that vanish after use, so the intent is probably "no hint sentences". But a helper reading it literally will rip out the verbs too.
- **Why it matters:** guests' fourth-worst problem is "guests can't tell how to start" (#27). Removing the verbs breaks that; keeping sentences breaks his rule and the picture judge.
- **Question:** "A first-time guest, what should the game show them? (1) the small button-and-verb label next to a thing, like [e] search or hold v to finish; (2) a controls card when they spawn; (3) the how-to page on the idle screen; (4) one-line hints like 'crouch to search quietly'."
  - a) Only the label next to things (1), nothing else.
  - b) Labels (1), the spawn card (2) and the idle-screen how-to page (3), but never hints (4).
  - c) Only the idle-screen how-to page (3); nothing in the raid at all.
- **Pick: b.** Labels next to things are how Fortnite teaches, the card is a five-second glance, and hints are already ruled out.

### S2-02. Two players: how is the final score worked out?
- **Type:** unclear
- **Rulings:**
  - pillagers-arcade-demo-2026-10-11.md: "Both players drop in and earn a COMBINED score, with a big bonus for extracting."
  - pillagers-fifty-answers-2026-10-12.md #4: "player should only be able to respawn in 2 player demo, should lose all score". #2: "Extracting DOUBLES the whole raid score and ends the run."
  - pillagers-answers-1-78 (10-18): #60 "Ending early halves the score, the same as dying." #62 "One board entry per player." #65 "In 2P the run ends when both players are out."
- **What is unclear:** the game today has one TEAM SCORE and per-player rows on the run-over card. Answer 65 means the player who extracts waits for the partner. Nothing says whether the x2 applies to the team total or to the extractor's own share, or what the other player's later death does (halve the whole team?). "One board entry per player" and "combined score" also point at two different boards.
- **Why it matters:** the scoreboard on the TV is the whole party. Two guests who extract and die in different orders will argue about a number the rules never defined.
- **Question:** "Two players. Player 1 gets out alive, player 2 dies a minute later. What should the final score be?"
  - a) Each player is judged alone: the one who got out gets double their own points, the one who died gets half theirs. The board shows both players, each with their own initials.
  - b) One team score. It doubles if either of them got out. It only halves if both died.
  - c) One team score. It doubles only if both got out, and halves only if both died. Anything in between stays as is.
- **Pick: a.** It matches "one board entry per player" and "respawning player loses all their score", and nobody gets robbed by their partner.

### S2-03. The Forge spends score, but the demo's only goal is a high score
- **Type:** contradiction
- **Rulings:**
  - pillagers-forge-2026-10-12.md: "It is paid with RAID SCORE, the same in DEMO and CAREER." MK II is about 2,500.
  - pillagers-arcade-primary-2026-10-12.md, his mode design: "DEMO ... high score is the only objective".
- **Conflict:** the code takes the Forge price out of the raid score (FORGE_COST 2500 and 6000, "takes FORGE_COST[0] from the RAID SCORE"). A guest chasing the board is punished for upgrading, and the x2 on extraction then doubles a smaller number.
- **Why it matters:** the Forge is one of his favourite ideas ("pack-a-punch"). If it only costs, guests learn to ignore it.
- **Question:** "Upgrading a gun at the Forge costs score points, which lowers your high score. What should it do?"
  - a) Leave it. Spending points is the choice: you upgrade only if it will win you more than it costs.
  - b) Keep the price, but the high score counts everything you earned, including what you spent. Spending never lowers the board.
  - c) Take the Forge out of the demo; keep it in career only.
- **Pick: b.** The board then rewards earning, and the Forge becomes a power choice instead of a trap.

### S2-04. Settings are open to guests, but the board is meant to be fair
- **Type:** contradiction
- **Rulings (pillagers-answers-1-78-2026-10-18.md):** #30 "All settings are reachable from the demo pause menu. This overrides "Settings out of reach" in 28." #67 "Same kit all night, and a new kit after NEW PARTY." pillagers-answers-third50-2026-10-12.md: "GAMEPLAY ELEMENTS ... SHOULD BE EXACTLY THE SAME IN DEMO AND CAREER". pillagers-polish-answers-2026-10-15.md #1: an EXPERIMENTAL section "where he can turn the new features on and off" (30 switches).
- **What conflicts:** his reasons for the fair-board rule (same kit, same map all night) are undone by a guest flipping a rule-changing row. Rows that change play: damage presets, enemy counts, superhot (pillagers-controller-layout-2026-09-27.md: "Superhot turned on by player 1 applies to the whole party session"), kid mode at 1/20 damage, and the 30 experimental switches. The 10-18 question 30 only described "volume, text size, a game option". Also, the demo starts from a copy of his own saved dials (the sandbox copies CFG), not from fixed party defaults, so the party's difficulty is whatever he last set.
- **Why it matters:** one guest at 11 pm sets kid mode or turns the air strike off and the rest of the night is a different game with the same board.
- **Question:** "Guests can open Settings from the pause menu. Some rows only change how things look or sound, but some change the rules of the game (how hard enemies hit, kid mode, superhot, the new-feature switches). What should guests see?"
  - a) Everything, as you said. A guest who breaks the rules is the operator's problem.
  - b) Only the look and sound rows (volume, text size, brightness, key help). The rule-changing rows are hidden in the demo and fixed at party defaults.
  - c) Everything stays, but NEW PARTY puts the rule-changing rows back to party defaults.
- **Pick: b.** Your own fair-board rule (#67) cannot hold if the rules are one tap away; the look and sound rows are what guests actually need.

### S2-05. "Easy mode": what does it change, if gameplay must be identical?
- **Type:** contradiction
- **Rulings:** pillagers-answers-1-78 #66: "At some point the game asks the players whether they want easy mode." pillagers-answers-third50-2026-10-12.md: "GAMEPLAY ELEMENTS ... EXACTLY THE SAME IN DEMO AND CAREER" (it also ended the softer-enemies DEMO from 10-11; ARCADE_DMG is now 1). pillagers-fifty-answers-2026-10-12.md #30: "No aim assist." pillagers-answers-1-78 #32: "Adults and teens, so no kid switch." Older: pillagers-answers-2026-10-02.md #7 "Add a kid menu".
- **What is unclear:** the question 66 options were "easy switch in the operator menu" or "either player picks it on the join screen". His answer says the game asks players. It never says what easier means. Softer enemies would break "identical"; aim assist breaks "No aim assist"; the old kid options (1/20 damage, kid firing, player 2 comes back after death) are still in Settings even though he said no kid switch.
- **Why it matters:** a pad player on their first game is the likeliest to drown, and the helpers will invent something.
- **Question:** "When the game asks 'want it easier?', what should 'easier' do?"
  - a) Only for the player who says yes: their gun auto-aims a little and they take less damage. Their board entry is marked 'easy'.
  - b) Only a little help for pad players (auto-fire at the closest enemy, as kid firing does now). Damage stays the same.
  - c) More ammo and heals for both players; nothing about aim or damage.
  - d) No easy mode; forget the prompt.
- **Pick: b.** It keeps "no aim assist" for people who want it and "identical rules", and it uses a feature you already built for your son.

### S2-06. Keys go to the window in front, and pads go by plug order
- **Type:** unclear
- **Rulings (pillagers-afternoon-orders-2026-10-18.md):** #3 "keys control whatever screen is to the top". #4 "first controller plugged in always controls p2 only, second controller plugged in always controls p1 only". pillagers-answers-1-78 #24: "P1 on keyboard and mouse, P2 on a pad." #27: "P2 pad or window fails" is the third-worst problem.
- **What is unclear:** with two full-screen windows on two TVs and one mouse, any click or alt-tab that puts the player 2 window in front sends player 1's keyboard and mouse into player 2's window. Player 1 then stands still. The old forwarding (v16.89) was removed on purpose. Also, wireless pads nap; the plug-order rule can swap the players if both reconnect in the other order.
- **Why it matters:** it is the most likely mid-party failure that is not a crash.
- **Question:** "At the party, player 1 uses keyboard and mouse, player 2 a pad. If someone clicks and the player 2 window comes to the front, whose character should the keyboard and mouse move?"
  - a) Whoever's window is in front (your 10/18 rule).
  - b) In the party shortcut mode only: always player 1, whichever window is in front. Pads stay locked to their player.
  - c) As you ruled, plus a small marker on each screen saying 'keyboard and mouse are here'.
- **Pick: b.** Your rule was written for testing one screen; at the party the failure is worse than a missing convenience. It would partially reverse your 10/18 rule, so it needs your yes.

### S2-07. Pad buttons: X and Y each do several jobs, and the "revamp" has no date
- **Type:** unclear
- **Rulings:** pillagers-controller-layout-2026-09-27.md: "X = reload AND loot (loot when something is in reach, reload otherwise); Y = the alternate loot (ring search)". pillagers-fifty-answers-2026-10-12.md #31: "Keep his 2026-09-27 pad layout." pillagers-ten-answers-2026-10-15.md #8: "controller mapping is going to need a revamp, just do what you think is best. Keep hold Y for the finisher for now; a pad revamp comes later."
- **What conflicts:** in the pad legend now, X is reload and search and open and call for extraction; Y is ring search, hold to finish a pillager, and (backpack open) drop an item for a teammate. DESIGN records a bug where a reload press near a box searched instead. Player 2 is pad-only at the party. "Later" has no date and the cutoff is 10/26.
- **Why it matters:** the pad is player 2's whole experience.
- **Question:** "Player 2 plays on a pad at the party. Should the helpers rearrange the pad buttons before 10/26?"
  - a) Yes: reload only on X; one context button (Y) for search, open, extract and pick-up; finisher on another button. I send you the new layout in one picture first.
  - b) Yes, but only the X conflict (reload versus search). Everything else stays.
  - c) No; keep it until after the party.
- **Pick: a.** "Just do what you think is best" already covers it, and the first real two-player test today will show which of these bite.

### S2-08. One-button heal (10/11 yes) against the item wheel (10/14 design)
- **Type:** contradiction
- **Rulings:** pillagers-arcade-demo-2026-10-11.md, "He said yes to all five extras": "the one-button quick heal (D-down / G)". The 10/14 wheel plan (tools/handoff/research/wheel-plan-2026-10-14.md, his answers): "EVERYTHING goes through the wheel ... Removed: tap-H heal, hold-H plate, the instant 5-9 keys, U and J cycling, G quick throw". Index entry "BELT REDESIGN 10-13: guns 4 / throwables 2 / heals 2" is also superseded (the bar is now 9 gun slots).
- **What conflicts:** healing now means hold Q, point, release, then click. The pad legend shows D-down held for the wheel. In a 10-minute walk-up game, a first-timer low on health in a fight has four steps.
- **Why it matters:** "stutter" is first on his worry list, but "I died because I could not heal" is what guests will say.
- **Question:** "Healing is done through the wheel (hold Q, point, release, click). Should there also be a one-button heal?"
  - a) No, wheel only.
  - b) Yes: one tap uses the best heal you carry, for everyone. The wheel stays for choosing.
  - c) Yes, but only while you are below a quarter health.
- **Pick: b.** You said yes to it for the party and "Fortnite-level pick-up-and-play" needs a heal that works in a panic.

### S2-09. Everything looks small on a TV 6 to 10 feet away
- **Type:** undecided
- **Rulings:** pillagers-playtest-orders-2026-10-12-night.md: "He also said "everything is wayy too small." That may mean the camera, but his answer 23 says keep the zoom, so ask before changing it." pillagers-fifty-answers-2026-10-12.md #23 "Keep the camera zoom." pillagers-fourth-fifty-answers-2026-10-13.md #42 guns "even bigger". 10-18: "Two TVs, 6-10 ft away." and "TV-size text is on by default in the demo."
- **What is unclear:** the "ask before changing" was never answered. TV-size text only scales the menus and HUD (the demo starts at 150%). The world camera uses whatever zoom is saved in his own profile (P.zoom), which the demo does not set.
- **Why it matters:** characters and bullets the size of a thumbnail across a room make the game look unfinished, however good the art is.
- **Question:** "On the TVs the characters and the world will look much smaller than on your monitor. For the party, should the picture start closer in?"
  - a) No, keep the zoom you play at.
  - b) Yes, one step closer (about 15 percent), as a TV setting you can switch off.
  - c) Yes, closer for everyone, all modes.
- **Pick: b.** You can judge it in today's two-screen test, and a TV setting changes nothing for your desk.

### S2-10. What time of day does the party game use?
- **Type:** unclear
- **Rulings:** pillagers-beta-spec.md (08-29): "NIGHT IS TOO DARK AND HARD - he avoids playing it. Fix before anything else about day/night." pillagers-answers-third50-2026-10-12.md: "Darker, moodier nights." pillagers-fourth-fifty-answers-2026-10-13.md (my note): night darkness left "as they are". pillagers-fifty-answers-2026-09-03.md: day/night toggle "on the map screen (Q21)", "default DAY every ascent (Q24)", and his note that night should have more enemies.
- **What is unclear:** the demo has no lift or map screen to toggle, and does not set time of day itself. I could not confirm what it uses; it looks like it keeps whatever day/night his own save last had. Night also has more enemies, which breaks "identical" for a fair board.
- **Why it matters:** a dark game on a TV in a lit room reads as a broken TV, and a night run is harder than a day run on the same board.
- **Question:** "In the party game, what time of day should it be?"
  - a) Always daytime. Night stays in career.
  - b) A random time of day, picked once per NEW PARTY so every run that night is the same.
  - c) Always night, for mood.
- **Pick: a.** The board is only fair if every run has the same light and the same enemy count, and day is easier to read from across the room.

### S2-11. Where does the party's sound come out?
- **Type:** undecided
- **Rulings:** pillagers-answers-2026-10-02.md #8: "Sound options: both players' sound / player 1 sound only / player 2 sound only (one setting, replaces per-window toggles)." pillagers-fifty-answers-2026-10-12.md #28 "Keep the speaker split: player 1 left, player 2 right." pillagers-answers-1-78 (10-18): #20 "Two TVs, 6-10 ft away." #27 worst problem number one is "stutter or harsh sound".
- **What is unclear:** two game windows on one PC normally share one audio output, so the sound of both windows comes from one place, not from each TV. Whether the split-speaker plan fits a two-TV room was never asked.
- **Why it matters:** harsh doubled sound is on his top-two list.
- **Question:** "Where will the sound come from at the party?"
  - a) One sound system for the room. Both players are heard, player 1 on the left, player 2 on the right.
  - b) One sound system, but only one window's sound (less noise; player 2 events are quieter).
  - c) Each TV plays its own player's sound (needs two separate audio outputs set up).
- **Pick: a.** It is what the code already does and it is the only one that works with one PC and one set of speakers; check that a is not harsh in the first real test.

### S2-12. If the PC cannot keep two windows smooth, what gives up first?
- **Type:** reconfirm
- **Rulings:** pillagers-graphics-program-2026-10-12.md: "Keep 60 fps at 4K". pillagers-fifty-answers-2026-10-12.md #21: "60 fps also on a mid laptop at 1080p (automatic render scale)." pillagers-answers-1-78 #22 "The party runs on this PC" with #20 two TVs, and #27 "stutter" first.
- **What is unclear:** those rules were written for one window. Two full-screen windows at TV size share one graphics card, with all the new effects at full (lighting HIGH, POST FX ON, EFFECT INTENSITY FULL by default). There is an automatic resolution row, but no rule for which to lose first.
- **Why it matters:** stutter is his number-one fear; nobody has measured two windows at TV size on real hardware (#34: no real 2P test yet).
- **Question:** "If the two windows start to stutter at the party, what should the game give up first?"
  - a) Fancy effects first (glow, grain, shadows, light beams), then the picture sharpness.
  - b) Sharpness first (draw smaller, scale up), then effects.
  - c) A steady 30 frames a second instead of an uneven 60.
- **Pick: a.** Effects are the cheapest thing to lose and are the hardest to notice across a room.

### S2-13. Can a partner pick you up more than once?
- **Type:** unclear
- **Rulings:** pillagers-fifty-answers.md #7 (09-01): "the player gets exactly one revive." pillagers-multiplayer-2026-09-25.md: "teammate REVIVES from the first co-op version (hold a key next to a downed teammate)." pillagers-fifty-answers-2026-10-12.md #5: "In BOTH DEMO and CAREER: one self-revive, then death ends the raid."
- **What is unclear:** these count the free self-revive. No ruling says if a teammate pick-up is limited. In the 2-player demo it matters: a pick-up keeps your score, a respawn loses it.
- **Why it matters:** this is the main co-op moment the party will show.
- **Question:** "Your partner is down. How many times can the other player pick them up?"
  - a) Any number of times, each takes a few seconds in the open.
  - b) Once per player per run.
  - c) Any number, but each pick-up leaves you with less health.
- **Pick: a.** Two-player fun is saving each other, and the score rule already makes dying costly.

### S2-14. Do your own explosions hurt you?
- **Type:** unclear
- **Rulings:** pillagers-multiplayer-2026-09-25.md: "NO team damage at all (grenades, lightning, nuke never hurt teammates; bullets never do)". pillagers-his-notes-2026-09-05.md: both of his deaths that night were "YOUR OWN CHARGE" and he asked for a countdown and a warning shout.
- **What is unclear:** the rule is about teammates only. In the code the frag can hurt the thrower, the red-barrel fire burns the one who lit it, and the tripwire explicitly hurts nobody ("no team damage and no self damage"). The air strike is not covered in the rulings.
- **Why it matters:** guests will be surprised both ways, and pick-up-and-play games decide this on purpose.
- **Question:** "Should your own grenade, barrel or air strike hurt you?"
  - a) Yes, all of them, but never your partner. The tripwire also hurts the one who sets it off.
  - b) No, never yourself or your partner.
  - c) Yes, but half damage.
- **Pick: a.** You asked for the cook countdown because it hurts; one rule for all explosives is simpler to learn.

### S2-15. The respawn counter says "dropping in" but the lore says you ascend
- **Type:** contradiction
- **Rulings:** pillagers-lore-ascend.md (08-29): "YOU DO NOT DROP. YOU ASCEND." pillagers-100-picks-2026-10-14.md #77: "you don't drop in, you come up from underground". pillagers-arcade-demo-2026-10-11.md: "instant drop-in", "Both players drop in", "drop back in".
- **Conflict:** the 2-player demo respawn countdown is built from the text 'DROPPING IN ' plus a number (grep arcadeDropHud). The lore memory says any "drop in" in the deployment sense is wrong.
- **Why it matters:** it is the most visible line in the 2-player demo and the exact failure he flagged.
- **Question:** "When a player respawns in the 2-player demo, what should the counter say?"
  - a) 'ascending in 3'
  - b) 'back in 3'
  - c) 'rising in 3'
- **Pick: a.** It is your own word and the title already says Ascend.

### S2-16. Music: none in raids since 9/3. Still true for the party?
- **Type:** reconfirm
- **Rulings:** pillagers-fifty-answers-2026-09-03.md Q49: "MUSIC NEVER PLAYS IN A RAID, only in the Undercroft". pillagers-fifty-answers-2026-10-12.md #27: "Music on the TITLE and the DEMO VIDEO only; still none in raids." pillagers-answers-1-78 #54: "No attract clip. Use the live map." Third-50: "Menu music at 60%." and "In the final 60 s: a sting and a red clock."
- **What is unclear:** the demo video is gone, so which screens get music is open (idle screen? run-over card?). The pitch is "fortnite levels of arcadey pick-up-and-play fun" and the bar is CoD/Fortnite, which all have raid music.
- **Why it matters:** a silent room with two TVs is a quiet party; it is also a rule he has repeated for six weeks, so it should be a quick yes.
- **Question:** "Music at the party: still none during the raid?"
  - a) None during the raid. Music on the title, idle screen and run-over card.
  - b) None until the last 60 seconds, then a low pulse with the red clock.
  - c) Add a quiet raid track.
- **Pick: a.** It is your standing rule; the last-minute sting and siren already carry the tension.

### S2-17. Who decides what is "janky", and are all 30 new features on?
- **Type:** unclear
- **Rulings:** pillagers-answers-1-78 #17: "After the rehearsal, switch off janky raid features rather than polish them." #13 cutoff Mon 10/26, #14 lock Thu 10/29. pillagers-polish-answers-2026-10-15.md #1: the EXPERIMENTAL section. Research file experimental-flags-2026-10-15.md: 30 switches, none of them read the mode, so DEMO and CAREER behave the same.
- **What is unclear:** the date of the rehearsal, the test for "janky", and the default state of each of the 30 for the party. In ten minutes a guest sees the raid director, air strike, events, strongholds, golden enemy, overseer, power-ups, medals, mimics, barrels and so on. His own words show he missed several of these when he played (events, combo ring, power-ups).
- **Why it matters:** switching off is the cheapest fix he approved. Nobody has said who flips the switch.
- **Question:** "Who decides which of the new raid features are switched off for the party?"
  - a) You, after you play a rehearsal run.
  - b) The helpers, by a clear rule (crashes, picture judge under 3, or a guest could not tell what it was in one run). They give you the list and you can veto.
  - c) Everything stays on unless you say.
- **Pick: b.** You asked for a stop list; a veto list costs you two minutes.

### S2-18. The in-raid pillager list ranks by what they carry, while a run is judged by points
- **Type:** unclear
- **Rulings:** pillagers-ten-answers-2026-10-15.md: "OPEN: the in-raid CURRENT PILLAGERS list still ranks by carried haul, because AI pillagers have no score." pillagers-fifty-answers-2026-09-03.md Q25: the "pillager board" is one of the HUD things that bother him most. pillagers-answers-1-78 #71 "No live rank readout, and no scoreboard until the game is over." #59 "$ for money, SP for score."
- **Conflict:** career raids still show a live board that ranks by $ carried while he judges the run in SP; the demo already hides it.
- **Question:** "In career raids, there is a live list of pillagers (you and the AI crews) ranked by what they carry. What should it do?"
  - a) Keep it as is (ranked by $ carried).
  - b) Hide it like in the demo; show it only on the end card.
  - c) Rank everyone by SP, so the AI crews get a score.
- **Pick: b.** It is one of the HUD items you said bother you most and it clashes with "no live rank".

---

# B) Words and naming

### S2-19. Title rows still carry the 9/25 names, not DEMO and CAREER
- **Type:** contradiction
- **Rulings:** pillagers-multiplayer-2026-09-25.md (rows "1 player / 2 player coop (same machine) / ..."). pillagers-fifty-answers-2026-10-12.md #13: "The modes are named DEMO and CAREER." #14 "The title highlights DEMO first." #15 "CAREER supports 2 players."
- **Conflict:** the title markup (grep `id="modearcade1"`) still reads 1 PLAYER, 2 PLAYER CO-OP (SAME MACHINE), 2 PLAYER ARCADE DEMO, 1 PLAYER ARCADE DEMO. "Career" and "Arcade" are not on the title; 1 PLAYER (career) comes first.
- **Question:** "The title rows say '1 player', '2 player co-op', '2 player arcade demo', '1 player arcade demo'. You named the modes demo and career. What should the rows say?"
  - a) Four rows: 2 player demo, 1 player demo, 2 player career, 1 player career. Demo on top.
  - b) Two rows, demo and career; the next step asks 1 or 2 players.
  - c) Leave it.
- **Pick: b.** It matches your two names and keeps the title short.

### S2-20. CLOSE button (9/3) or the X in the corner (10/18)?
- **Type:** stale
- **Rulings:** pillagers-fifty-answers-2026-09-03.md Q1: "Every menu screen gets a CLOSE button and ESC closes it." pillagers-answers-1-78 #43: "Centred card with an X, taking up nearly the entire screen."
- **Conflict:** a lone X is easy to hit with a mouse and impossible to aim at with a pad. Player 2 is on a pad.
- **Question:** "Windows now close with an X. Do pad players also need something to read?"
  - a) X only; esc and b close it.
  - b) X plus a small 'back: esc / b' line on the card (changes with the last input used).
  - c) Put the CLOSE button back.
- **Pick: b.** It follows your glyph-switching order (live prompts) and covers the pad.

### S2-21. All lower case: what about initials, button letters, names?
- **Type:** unclear
- **Rulings:** pillagers-afternoon-orders-2026-10-18.md #1: "change all text shown to player to lowercase only -- i don't like how you have random words capitalized". The note under it (written by a helper) adds "Acronyms and key names go lower case too (sp, hp, esc). ... Typed input boxes show what is typed."
- **What is unclear:** the rule is clear for sentences. Three cases are not: the three arcade initials on the board ("AAA" is the classic), pad button letters ("press a to join" reads like the word 'a'), and proper names (map, Wirt, items).
- **Question:** "In all-lower-case, what about these?"
  - a) Initials and button letters stay capitals (they are icons and the arcade look); everything else lower case.
  - b) Everything lower case, including initials and button letters.
  - c) Initials capitals; button letters shown as button pictures, not letters.
- **Pick: c.** Initials look wrong small, and your live-glyph order already swaps letters for pictures.

### S2-22. Pillager, machine, robot, enemy: which word when it could be either?
- **Type:** unclear
- **Rulings:** pillagers-vocabulary.md: "Pillager (them and you)" never "raider, bot, AI, NPC, enemy"; "Sentry, Crawler, ..." never "robot, machine (as a name)"; "Choir" listed as a machine, but the same file says "Pillbox (was the Organ ...) Code kind stays 'choir'." pillagers-aaa-voice.md lists "ENEMY DOWN" and "SQUADMATE DOWN" as the genre callouts.
- **Conflict:** the game says GOLDEN ENEMY DOWN, MACHINE ALERT, PILLBOX, and the rulings themselves say "enemies". The golden one can be any body (crawler, sentry, howler). There is no entry for Overseer, golden, or the umbrella word for robots.
- **Question:** "What do we call something that is trying to kill you when it could be a machine or a pillager (for example 'golden enemy down')?"
  - a) 'enemy' is allowed as the catch-all, only where it could be either; the specific names stay for specific things.
  - b) Always the specific name ('golden sentry down', 'golden pillager down').
  - c) 'target'.
- **Pick: a.** It is the genre word, and your ban was on calling pillagers 'enemy', not on the catch-all.

### S2-23. 'Party', 'team', 'squad', and the NEW PARTY button
- **Type:** unclear
- **Rulings:** pillagers-answers-1-78 #67 "a new kit after NEW PARTY". pillagers-aaa-voice.md example "SQUADMATE DOWN". pillagers-multiplayer-2026-09-25.md: the PARTY window (co-op link).
- **Conflict:** the game uses TEAM SCORE, PARTY SCORE, the PARTY window (the linked pair), NEW PARTY (reset the board), TEAMMATE DOWN, 'party seed'. "Squad" appears nowhere. 'Party' means the two linked windows and also the real party night.
- **Question:** "Which words?"
  - a) 'team' for the two players in a run (team score, teammate down). 'party' only for the real party night (new party, party board).
  - b) 'party' for both.
  - c) Rename NEW PARTY to NEW NIGHT; keep the rest.
- **Pick: a.** Teammate/team is already everywhere; only the operator ever sees NEW PARTY.

### S2-24. Raid, run, or match?
- **Type:** unclear
- **Rulings:** pillagers-fifty-answers-2026-10-12.md #3: "RUN OVER". pillagers-ten-answers-2026-10-15.md: "career mode should still have a leaderboard that is shown after every match". The modes: "10 minute raids". Nothing in pillagers-vocabulary.md defines it.
- **Question:** "What is one trip up top called on screen?"
  - a) 'run' (run over, run info, run goals, run card). 'raid' stays in the code.
  - b) 'raid' everywhere (raid over, raid info).
  - c) Leave it mixed.
- **Pick: a.** It is the word you used for the card and the info box.

### S2-25. Contracts, missions, run goals, objectives: one word?
- **Type:** unclear
- **Rulings:** pillagers-fourth-fifty-answers-2026-10-13.md #22 ""contracts and missions"". pillagers-polish-answers-2026-10-15.md #27 "Run goals: "merge into conditions, maybe rename it run info or something"." pillagers-answers-1-78 #1: "Option b, but ALL contracts move to the map screen."
- **What is unclear:** the run card has OBJECTIVES, the raid has run goals, the Mainframe has contracts, and his "missions" was never named in the game. It is the 3-job box the picture judge calls crowded.
- **Question:** "Choose the words."
  - a) 'goals' for what a raid asks of you; 'contracts' for jobs you take before in career. No 'missions'.
  - b) Everything is 'contracts'.
  - c) Everything is 'goals'.
- **Pick: a.** Two things really exist (automatic and chosen); naming them differently helps.

### S2-26. 'Tactical belt': the bar is now guns only
- **Type:** stale
- **Rulings:** pillagers-vocabulary.md: "Tactical belt (the nine keyed cells at the bottom ... HIS WORD since v10.26)"; hotbar is the never-word. The 10/14 wheel plan: guns only on the bar; grenades, heals, plates in a wheel on hold Q.
- **Conflict:** the pad mini-legend still says 'LB / RB tactical belt'; the in-game GEARRULES text still says "Keys 1 to 4 bring up your guns" (v21.93); the vocabulary file calls plates part of the belt. There is no word for the wheel.
- **Question:** "What do we call what?"
  - a) 'tactical belt' for the gun row, 'item wheel' for the wheel. Plates are items in the wheel.
  - b) 'belt' means both, the wheel opens from it.
  - c) 'guns' for the row, 'items' for the wheel; drop 'tactical belt'.
- **Pick: a.** It keeps your word and names the new thing.

### S2-27. Gold means too many things
- **Type:** reconfirm
- **Rulings:** pillagers-answers-third50-2026-10-12.md: "Rarity colours are GREEN, BLUE, PURPLE, GOLD." "Add a rare GOLDEN enemy with big loot." pillagers-forge-2026-10-12.md: MK II has "a gold finish". pillagers-answers-1-78 #46: "Lime yellow accent, whichever is most visible." pillagers-fifty-answers.md #18 retired "Gilded".
- **Conflict:** gold is now the best-loot colour, the golden enemy, the Forge MK II finish, the gold ring on the gun in hand, and the lime-yellow menu accent is close to it. A glow or ring in gold no longer tells you what it is.
- **Question:** "Should gold stay only for 'best loot'?"
  - a) Yes. Forged guns get their element colour (fire, shock, cryo, acid) or steel; the gun-in-hand ring uses the lime accent.
  - b) Leave it.
  - c) Rename the top rarity to something that is not a colour word.
- **Pick: a.** One colour, one meaning, matches your item-glow idea.

### S2-28. Colour is the only signal for roles and rarity
- **Type:** reconfirm
- **Rulings:** pillagers-beta-spec.md: "Colourblind palette not required for beta." pillagers-polish-answers-2026-10-15.md #17: "Pillager roles: tinted outfits." #18 elites by tint/outline. pillagers-fourth-fifty-answers-2026-10-13.md #45: more distinct colours for pillagers. Rarity: green, blue, purple, gold.
- **What is unclear:** that was for the beta; he now says "Release for others". Roles are tints (red, green, amber, blue, violet) and rarity is green/blue/purple/gold. With under ten guests and TVs, one colour-blind guest is quite possible. The head marks were removed (#73) and the drawn gear is not the same as an icon.
- **Question:** "Should roles and rarity have a second signal besides colour?"
  - a) Not now; revisit before public release.
  - b) Yes, a cheap one: a small shape or letter on rarity glows and role gear (circle, square, triangle, star).
  - c) A colour-blind setting that swaps the palette.
- **Pick: a.** It is a post-party, public-release job; the party has no testers to verify with.

---

# C) Progression, cosmetics, and rules

### S2-29. Level-gated cosmetics, XP, and the Progress track vs "no level-up unlocks"
- **Type:** contradiction
- **Rulings:** pillagers-answers-third50-2026-10-12.md: "#26: NO level-up unlocks (his answer after my explanation)." pillagers-fifty-answers-2026-09-03.md Q15/16: "Cosmetics are EARNED, never bought". pillagers-vocabulary.md: "XP (unlocks the shop)"; "LVL and PROFICIENCY gate nothing and are hidden from every screen since v6.40"; "Progress (the ten rewards)". pillagers-beta-spec.md: heads "earned by achievement AND level AND purchase".
- **Conflict:** in the code about 13 cosmetics still unlock at 'level 2/3/4' (how:'level:N') and the unlock text prints 'level 3'. XP, levels and the ten-step Progress track still exist. A 'buy' unlock path ("$ from the Peddler") exists in code, unused. In the demo nothing is earned (random character).
- **Question:** "A few hats and outfits still unlock by level, and XP and the Progress track are still in career. What should we do with levels?"
  - a) Remove level unlocks; hats and outfits unlock by things you do (extractions, kills, wardens, runs). XP stays only as the shop gate.
  - b) Remove levels, XP and Progress entirely (shop open; cosmetics by deeds).
  - c) Leave it until after the party.
- **Pick: a.** A small change that matches your ruling and doesn't touch the shop.

### S2-30. Two-player career: whose credits?
- **Type:** unclear
- **Rulings:** pillagers-fifty-answers-2026-10-12.md #15 "CAREER supports 2 players (two-window co-op)." #8 "1 score = 1 credit, banked only when you extract." pillagers-playtest-2026-09-27.md: "Player 2 sees only its own save."
- **What is unclear:** each window has its own save, and score is combined in the demo. In career nothing says if each player banks their own score, or the team score is split.
- **Question:** "In a two-player career raid, who gets the credits?"
  - a) Each player banks their own score into their own save.
  - b) The team score is split evenly.
  - c) The host banks all.
- **Pick: a.** It matches one save per player and "banked only when you extract".

### S2-31. A better version of the gun in your hands swaps in at once, against 'never in his hands mid-fight'
- **Type:** contradiction
- **Rulings:** pillagers-arcade-demo-2026-10-11.md: "the currently equipped gun (the one the player has out / is actively holding) doesn't get replaced in real time". pillagers-fifty-answers-2026-09-03.md: "when i find a gun it should go to the next open slot, not kick my scav pistol out of slot 1".
- **Conflict:** DESIGN v26.36 (every gun has its own key): "A higher rarity of the same gun swaps in at once: if the old one is in your hands, the new one is in your hands and the rounds in the magazine come with it." It was built from the key-slot order, not from his words about the hands.
- **Question:** "You pick up a better copy of the gun you're holding, mid-fight. What should happen?"
  - a) It never changes what's in your hands; it goes to its key and you switch when you want.
  - b) It swaps in once you've stopped shooting and reloading for two seconds.
  - c) It swaps in at once (today).
- **Pick: b.** You keep the upgrade without losing a magazine in a fight.

---

# D) After the party

### S2-32. The Undercroft: too complicated, frozen, or active?
- **Type:** undecided
- **Rulings:** pillagers-arcade-primary-2026-10-12.md: "the undercroft is too complicated" and "Undercroft (stash, crafting, Mainframe, loadouts): FROZEN. It keeps working as a secondary mode, but nothing new is built on it." His mode design then said CAREER has "all the other career/undercroft features we've already created". pillagers-answers-1-78 #4: "c, keep all areas going: party screens AND the Undercroft, stash and Settings." Afternoon #7: players see each other in the Undercroft.
- **What is unclear:** frozen, then more built on it (pricing, stash sort/filter/lock, trophy case, music, shop re-roll), and the original complaint (too complicated) is not answered. The trader, hire bench, gambler, bar, Fashion Depot, Mainframe and stash are separate stops.
- **Question:** "After the party, what do we do about the Undercroft being too complicated?"
  - a) Name the two things that annoy you most, and the helpers fix those.
  - b) Merge stations: fewer places to walk, fewer screens.
  - c) Drop the walkable hub; career uses a single menu.
  - d) Decide after the party feedback.
- **Pick: d.** The party shows what actually hurts; until then, restyle only.

### S2-33. What comes right after the party?
- **Type:** undecided
- **Rulings:** pillagers-answers-2026-10-02.md: "Release for others (not just him and his son)." "Alpha for friends: Halloween 2026-10-31." pillagers-fifty-answers-2026-10-12.md #46 "Release on itch.", #49 "Steam eventually; not a concern yet." pillagers-ten-answers-2026-10-15.md #4 "don't worrry about itch right now". pillagers-answers-1-78 #16 "There is NO public launch on 10/31. Party feedback gets integrated first, and the launch date is not set." #37 "No new people before the party." #39 "Test the online invite after the party."
- **What is unclear:** the Halloween alpha is dead, nothing replaces it, and the old hosting plan (itch zip, collector) is stale.
- **Question:** "After the party and the feedback fixes, what's next?"
  - a) A private alpha for friends on itch with a secret link.
  - b) Straight to a public itch page.
  - c) No external release yet; keep improving and decide later.
- **Pick: a.** It follows your "no new people before the party" and gives you real feedback first.

### S2-34. Play-data reports: 'telemetry on' or 'off until they say yes'?
- **Type:** contradiction
- **Rulings:** pillagers-fifty-answers-2026-10-12.md #48 "Telemetry on, anonymous." pillagers-hosting-and-feedback.md (09-12): "Consent is off by default and must stay that way. A stranger clicking a link has not agreed to send play data." pillagers-answers-1-78 #61 "Keep the feedback line, button and Send play data."
- **Question:** "When strangers play, should the game send anonymous play reports?"
  - a) Ask once at first start; off until they say yes (how it works now).
  - b) On by default, anonymous, with a clear off switch.
  - c) Never; only a feedback button.
- **Pick: a.** Strangers have not agreed, and the collector is not set up anyway.

### S2-35. Which parked features return first?
- **Type:** undecided
- **Rulings:** pillagers-multiplayer-2026-09-25.md: "PvP should also be an option later" and the server rows "WE WILL WORK ON THIS LATER". pillagers-answers-1-78 #72 "Hide PvP." #39 online invite after the party. pillagers-polish-answers-2026-10-15.md #33 clue hunt "CUT". pillagers-ten-answers-2026-10-15.md #6 magnet removed. Arcade primary: bigger map "Freeze".
- **Question:** "After the party, which comes back first?"
  - a) None; polish only until public.
  - b) Online co-op with a friend by invite code.
  - c) PvP.
  - d) The bigger map.
- **Pick: b.** You already ordered the invite test after the party.

### S2-36. How many players, ever?
- **Type:** stale
- **Rulings:** pillagers-multiplayer-2026-09-25.md: "PLAYERS: up to 4 in one raid." and voice: "both push-to-talk and open mic as options; a mute button per teammate; proximity chat for PvP enemies". pillagers-answers-1-78 #33: "No more than 2 players."
- **Question:** "Player count and voice chat, long-term?"
  - a) Two players for everything. Drop four-player and voice chat.
  - b) Two for the demo; up to four for online career later, with voice chat.
  - c) Up to four everywhere.
- **Pick: b.** The demo, scoring and air strike are built around two; online can grow later.

### S2-37. The old maps: keep frozen or remove?
- **Type:** undecided
- **Rulings:** pillagers-arcade-primary-2026-10-12.md: "Freeze the bigger map ... Disable the bigger map in the game for now." pillagers-fifty-answers-2026-10-12.md #16 "THE COLD MILE is disabled.", #42 "YES, delete dead code, but after a backup branch.", #43 file split yes; pillagers-answers-1-78 #19 these wait until after the party.
- **Question:** "After the party, what do we do with the disabled maps?"
  - a) Keep them frozen until career returns.
  - b) Remove them after a backup branch to shrink the file.
  - c) Bring The Cold Mile back for career.
- **Pick: a.** Disabling was "for now", and removing is easy later.

### S2-38. 'No new systems' (10/2), and what the rule is after the party
- **Type:** reconfirm
- **Rulings:** pillagers-answers-2026-10-02.md #6: "no bugs, smooth menus, look and feel. The game does not need more depth right now. No new systems." Then pillagers-fifty-answers-2026-10-12.md and pillagers-100-picks-2026-10-14.md added dozens (Forge, director, events, strongholds, power-ups), pillagers-polish-before-more-2026-10-15.md froze new batches, and pillagers-answers-1-78 #13 sets a cutoff of Mon 10/26.
- **Question:** "After the party, may new systems start again?"
  - a) Polish and fixes only until the first outside feedback is in.
  - b) One new system at a time, only after the last one is polished.
  - c) Open again.
- **Pick: a.** "Party feedback gets integrated first" is your own ruling.

### S2-39. Stash selling and loot-filter controls
- **Type:** reconfirm
- **Rulings:** pillagers-fifty-answers-2026-09-03.md Q2: "sell bar and hint stay ... no search box". pillagers-answers-third50-2026-10-12.md: "Sell by RIGHT-CLICK and choosing SELL." pillagers-100-picks-2026-10-14.md #34: stash sort, filter and lock. pillagers-one-control-per-job.md: "Never add a parallel row or panel".
- **What is unclear:** the code carries the sell bar, the right-click SELL, a JUNK tag with 'sell all', and the filter/lock chips. I did not verify which ones are still visible.
- **Question:** "How should you sell items in the stash?"
  - a) Right-click SELL only; junk tag and sell-all go.
  - b) Right-click SELL plus a 'sell all junk' button.
  - c) Leave as is.
- **Pick: b.** One way per job, and sell-all is useful.

### S2-40. Two-player party: window closes during a run
- **Type:** stale
- **Rulings:** pillagers-multiplayer-2026-09-25.md: "if the host drops mid-raid it COUNTS AS ABANDON for everyone (all come back empty)". It was replaced on 2026-10-02 (DESIGN: "His ruling of 2026-10-02, replacing host drop means abandon": the teammate keeps the raid and runs it alone). pillagers-answers-1-78 #31: "If a run sticks, reload the browser."
- **What is unclear:** the memory still says the old rule. In the demo it also isn't said what happens to the board entry when a window reloads mid-run.
- **Question:** "In the demo, a window crashes or someone closes it mid-run. What should happen?"
  - a) The other player carries on alone; the run is scored when it ends.
  - b) The run ends for both; the score halves like a death.
  - c) The run ends for both and is thrown away.
- **Pick: a.** It matches the 10/2 ruling and loses no one's score.

---

# Settled (do not ask)

- Controller support out of beta v1 (08-29): superseded by 09-27 layout, 10-12 #31 and the 10-18 afternoon orders.
- No minimap (08-29, 09-03 Q31): his own order "add minimap" on 10-12 built it.
- Melee not worth building (08-29): crowbar, V melee, "viable ... think Halo" (10-13 #25).
- Pillagers taunt audibly (08-29): reversed; pillagers say no words (10-12).
- Voice barks and announcer: reversed 10-13, no spoken sounds anywhere.
- Target raid 4-9 minutes (08-29): 10 minutes (10-12).
- Safe pocket (08-29): gone since v12.35 (his order). Death loses everything; reaffirmed 10-13 #21.
- Loadout presets (08-29): save slots removed (09-03 Q5), "No loadout presets" (10-12).
- Two equipped guns (08-29) and four-gun belt (10-13): 9 gun slots plus a wheel (10-14).
- Credits and points synonymous (10-11): "$ for money, SP for score" (10-18 #59).
- Softer-enemy demo (10-11): gameplay identical (10-12 third-50); ARCADE_DMG is 1.
- Controller 1 = player 1 (10-11 arcade build): first pad = P2 (10-18).
- Halloween dressing and 10/31 alpha: "forget and remove this concept" (10-12 #22), no public launch (10-18 #16).
- 3-2-1 GO and attract video: removed; live map instead (10-18 #54).
- Sentence case (10-18 morning) and ALL CAPS callouts (10-09): lower case everything (10-18 afternoon).
- Host drop = abandon (09-25): replaced 10-02 (teammate keeps the raid).
- Weak spots: machines keep them, pillagers have none (10-13 #31; DESIGN v27.xx pillager flank bonus removed).
- Block rejoining after dying or extracting (10-01): "Never re-open this."
- Coming back empty (09-11), guns never wear or jam (09-01): reaffirmed 10-13 #21; the Forge keeps the gun's tier only through an extraction.
- Cosmetics are earned, never bought, and rank by deeds (09-03): see S2-29 for the leftover level gates only.
- "A pause stays paused until a player unpauses" (10-18 #29): his choice over my 30-second auto-resume.
- Same level all night (party seed, 10-14 #38 and 10-18 #67): accepted.
- Trading is dropping (10-03) and share by drop with auto-ping (10-14 #48): consistent.
- Helpers may shorten his lines with a logged reason (10-18 #8): overrides "an edited line is a key".
- Idle policy "audit continuously" (08-30): superseded by the hard pacing rule (10-18).
- Version numbers restart at v0.0001 (10-12 #47): done; internal VER is 30.73.

# Stale notes helpers can fix without asking him

- memory/pillagers-multiplayer-2026-09-25.md still says host drop = abandon.
- memory/pillagers-vocabulary.md: Safe pocket, LVL/PROFICIENCY, 'Backpack (I or TAB opens it)' (TAB now backs out like ESC, v13.44), the nine-cell tactical belt, 'Choir' as the name of the Pillbox machine.
- memory/pillagers-beta-spec.md: almost all of it is superseded (see Settled).
- memory/pillagers-aaa-voice.md: the top section still says ALL CAPS callouts (reversed twice).
- memory index: "BELT REDESIGN 10-13" and "pillagers-menus-are-the-blocker" are superseded.
- pillagers-arcade-primary-2026-10-12.md still says the Undercroft is FROZEN; 10-18 #4 reopened it.
- In the game: GEARRULES says "Keys 1 to 4 bring up your guns" (v21.93); the pad mini-legend says 'tactical belt'; 'DROPPING IN n' (S2-15); the BACKPACK FULL message is a dead path (PACKCAP is 99999) next to the ruling "no bag limit, no weight, ever".
