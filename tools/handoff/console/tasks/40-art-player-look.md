# 40-art-player-look : the human figures (art survey a01 to a10, HIS picks)

His picks, pasted 10-18 evening: a01 D, a02 B, a03 A, a04 C, a05 B, a06 A, a07 A, a08 A, a09 B, a10 D.
These replace the coordinator's earlier picks (an earlier version of this task said not to do a02 or a05: he picked them, so do them).
- a01 D: the mascot head, scaled 1.2 about the neck point. Hats and hair scale with it.
- a02 B: the whole figure 1.25 about the feet, at every human draw site: you, your mate, the pillager bots (both drawOp calls) and hires. Shadow and gun scale with the body, as the spec says.
- a04 C: different heights. Lean wc.scale(0.92,1.08), broad (1.1,0.96), curved (1,1), about the feet. Shadows scale with it.
- a05 B: bigger cosmetic pieces: the pack 1.3, the vest and pauldron plates 1.12, the chest patch 1.6. Do NOT scale the hat and hair again: a01 D already scales them with the head, and doing both would make hats 1.4 times the head.
- a09 B: a bigger, darker shadow.
- a10 D: the mate name plate, plus a 36x3 health bar under the name.
- No change: a03 (face), a06 (the seat ring and number stay), a07 (the dark outline stays), a08 (gun and pack size).

Watch for:
- With his closer camera (task 44, zoom 1.3), figures end up about 1.6 times today's size on screen. That is his choice; keep the 1.25 in one named constant, so it is one number to dial back.
- Nameplates, name tags, the alert mark and the downed bar must clear the bigger head. Raise them with the figure.
- Hit areas do not change. Check whether shots visibly pass through the drawn edge of a bigger body. If they do, write it in your notes and in questions.md, and do not change any hit area.
- Doorways and the narrow gaps in the map must still look passable.

## How
- Each pick has its exact spec in tools/handoff/art-survey/survey.json (question id, then options[key].spec). Build it as written unless the notes here say otherwise. tools/handoff/art-survey/answers.md has his words and the coordinator's calls.
- The look to match: tools/handoff/art-survey/img/<id>-<key>.jpg (lower case key; the "a" picture is today). Motion picks have clips in art-survey/snip/<id>-<key>.html.
- Take before and after pictures of the same scene at 1080. Look at them (Read shows pictures) and fix what looks wrong. The critic (tools/console-sdk/critic.mjs) is for screens and is optional here.
- One ship per task through the queue, with a check that fails on the old build. The fingerprint must not change: these are drawing changes only, so add no random rolls to the map build or spawns.
- Frame cost: 60 fps at 4K is the bar. Measure the frame time before and after with two players on screen, and note both numbers.
