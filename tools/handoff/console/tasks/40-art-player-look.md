# 40-art-player-look : the player figure (art survey a04, a06, a07, a09, a10)

His art survey, 10-18. He skipped a01 to a10, so these are the coordinator's picks, adjusted for his camera pick (a36 C, 30 percent closer, task 44).
- a04 B: stronger build shapes (broad wider, lean slimmer, curved stronger).
- a06 B: the player-colour edge on the body itself. It replaces the seat ring (drawSeatRing) for both players. P1 and P2 colours stay as shipped (his order: P1 and P2 match everywhere).
- a07 B: a dark outline plus a thin light edge on the lit top-left side. Layering: the dark outline first, the player-colour edge (a06) just outside it. One outline stack, not three.
- a09 B: a bigger, darker shadow.
- a10 D: the mate name plate plus a 36x3 health bar under the name.
- NOT doing a02, a05 or a08 (bigger figure, cosmetics, gun and pack): the closer camera already makes them bigger.

## How
- Each pick has its exact spec in tools/handoff/art-survey/survey.json (question id, then options[key].spec). Build it as written unless the notes here say otherwise. tools/handoff/art-survey/answers.md has his words and the coordinator's calls.
- The look to match: tools/handoff/art-survey/img/<id>-<key>.jpg (lower case key; the "a" picture is today). Motion picks have clips in art-survey/snip/<id>-<key>.html.
- Take before and after pictures of the same scene at 1080. Look at them (Read shows pictures) and fix what looks wrong. The critic (tools/console-sdk/critic.mjs) is for screens and is optional here.
- One ship per task through the queue, with a check that fails on the old build. The fingerprint must not change: these are drawing changes only, so add no random rolls to the map build or spawns.
- Frame cost: 60 fps at 4K is the bar. Measure the frame time before and after with two players on screen, and note both numbers.
