# 43-art-machines-world : machines and effects (art survey a27, a28, a30, a31, a34, a35, his picks)

- a27 B: before a machine shoots, a charging ring shrinks onto the gun and flashes white at the end. It replaces the glow.
- a28 B: a machine dies in a small blast and smoke (the existing boomFx), plus a few metal chunks.
- a30 B: a moonlit blue night (NIGHT_SHEET .45, a blue sheet, fog .50).
- a31 B: lighter fog (day .30, night .42). Enemies are still only drawn where you can see them.
- a34 B: chunkier hit sparks and blood.
- a35 B: the explosion is 60 percent bigger and leaves a scorch mark. This is a look change only. The damage radius does not change, and the blast ring must not draw past the real damage radius, so the picture never promises damage that is not there.
- No change: a24, a25, a26 (machines), a29 (palette), a32 (loot), a33 (muzzle flash), a37 (finishing look).

## How
- Each pick has its exact spec in tools/handoff/art-survey/survey.json (question id, then options[key].spec). Build it as written unless the notes here say otherwise. tools/handoff/art-survey/answers.md has his words and the coordinator's calls.
- The look to match: tools/handoff/art-survey/img/<id>-<key>.jpg (lower case key; the "a" picture is today). Motion picks have clips in art-survey/snip/<id>-<key>.html.
- Take before and after pictures of the same scene at 1080. Look at them (Read shows pictures) and fix what looks wrong. The critic (tools/console-sdk/critic.mjs) is for screens and is optional here.
- One ship per task through the queue, with a check that fails on the old build. The fingerprint must not change: these are drawing changes only, so add no random rolls to the map build or spawns.
- Frame cost: 60 fps at 4K is the bar. Measure the frame time before and after with two players on screen, and note both numbers.
