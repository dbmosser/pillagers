# 19-party-audio : sound for the night (his round 2 answers)

- 2.12, his words: "put a hard cap on loud sounds". Put a hard limiter on the master output, always on, so nothing can go past a set ceiling. In the demo, also lower the loudest sounds (explosions, heavy guns, the boss) by a few decibels.
- 2.73 a: a measured loudness pass that levels the sounds against each other, then fixes.
- 2.69 b: rain about a third quieter. 2.71 a: the deep bass stays as it is.
- 2.70 c: the idle loop's music cycles through three variations of the piece in turn.
- CUT 2026-10-19 (2.5 b, his order 2026-10-19: "'party' and 'demo' need to be synonymous --- you are doing too much to try to make the party demo polished. for the party demo, we need to just open the game on the localhost and then click the demo -- don't overengineer this"): no sound-device choice per window and no launcher. Each window plays where Windows sends it; keep today's left and right split.
- CUT 2026-10-19 (2.18 b): no operator test-sound button.

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.
