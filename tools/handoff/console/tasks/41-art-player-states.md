# 41-art-player-states : players in action (art survey a11 to a16, his picks)

- a11 B: a bouncy walk and sprint (bigger bob, a little squash and stretch).
- a12 B: the hit reaction is a white flash for about 66 ms, then red, with a small recoil.
- a13 D: at low health, option B's body changes plus option C's edge pulse. The edge is task 40's player-colour edge (a06) if 40 has shipped; if not, pulse the body outline. The screen-side low-health look (menu survey q23 D) stays as shipped.
- a14 B: downed means kneeling, head dropped, gun on the ground, a red ring pulsing. The downed bar with +0.50s and the two-decimal clock (v30.91) stay.
- a15 B: at player death the body drops flat, then breaks into rising points of light. No body stays.
- a16 B: a faint dotted line from the gun to 40 px short of the crosshair, always on while a gun is held. His note: "the better/rarer version of each gun can also have the red laser". So guns at the game's two highest rarity tiers, and the golden gun, show option C's red laser while the sights are held. The dotted line hides while the laser shows (one aim mark at a time). Find the rarity tiers in the code and name them in your notes.
- a17 A: crouch as now, no change.

## How
- Each pick has its exact spec in tools/handoff/art-survey/survey.json (question id, then options[key].spec). Build it as written unless the notes here say otherwise. tools/handoff/art-survey/answers.md has his words and the coordinator's calls.
- The look to match: tools/handoff/art-survey/img/<id>-<key>.jpg (lower case key; the "a" picture is today). Motion picks have clips in art-survey/snip/<id>-<key>.html.
- Take before and after pictures of the same scene at 1080. Look at them (Read shows pictures) and fix what looks wrong. The critic (tools/console-sdk/critic.mjs) is for screens and is optional here.
- One ship per task through the queue, with a check that fails on the old build. The fingerprint must not change: these are drawing changes only, so add no random rolls to the map build or spawns.
- Frame cost: 60 fps at 4K is the bar. Measure the frame time before and after with two players on screen, and note both numbers.
