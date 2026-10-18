# 42-art-pillager-bots : the AI pillagers (art survey a18 to a23, his picks)

Words: on screen the AI ones are "pillager bots" (his order 10-18; task 08 does the text).
- a18 A, his note "always in red clothes and always have angry eyebrows", and a19 D (one crew colour): every hostile pillager bot wears the same dark red coat (#7a2f2a, raiderCoat) and always has angry brows, whatever its role or state. Roles show through gear only. Hires on your side keep their own colours (red means enemy). The golden enemy stays gold. Elites keep the purple ring (a20 A, no change) on top of the red.
- a21 B: the golden enemy has a solid gold body with a shine sweeping across it.
- a22, his words "A and B -- exclamation mark plus body tell": keep the red mark over the head AND add option B's body tell (a 0.45 s hop, a red eye flare, tighter brows). Ignore the line in B's spec that says the mark is not drawn.
- a23 B: on death the pillager bot tips over flat and fades, with a small light puff. No body stays (his old ruling).

## How
- Each pick has its exact spec in tools/handoff/art-survey/survey.json (question id, then options[key].spec). Build it as written unless the notes here say otherwise. tools/handoff/art-survey/answers.md has his words and the coordinator's calls.
- The look to match: tools/handoff/art-survey/img/<id>-<key>.jpg (lower case key; the "a" picture is today). Motion picks have clips in art-survey/snip/<id>-<key>.html.
- Take before and after pictures of the same scene at 1080. Look at them (Read shows pictures) and fix what looks wrong. The critic (tools/console-sdk/critic.mjs) is for screens and is optional here.
- One ship per task through the queue, with a check that fails on the old build. The fingerprint must not change: these are drawing changes only, so add no random rolls to the map build or spawns.
- Frame cost: 60 fps at 4K is the bar. Measure the frame time before and after with two players on screen, and note both numbers.
