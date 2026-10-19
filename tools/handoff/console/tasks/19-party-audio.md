# 19-party-audio : sound for the night (his round 2 answers)

- 2.12, his words: "put a hard cap on loud sounds". Put a hard limiter on the master output, always on, so nothing can go past a set ceiling. In party mode, also lower the loudest sounds (explosions, heavy guns, the boss) by a few decibels.
- 2.73 a: a measured loudness pass that levels the sounds against each other, then fixes.
- 2.69 b: rain about a third quieter. 2.71 a: the deep bass stays as it is.
- 2.70 c: the idle loop's music cycles through three variations of the piece in turn.
- 2.5 b: each TV plays only its own player's sound. That means a sound-device choice per window (Chrome's setSinkId), saved by the launcher. If the saved device is missing, fall back to the default and say so on the operator card.
- 2.18 b: the operator card gets a "play a test sound in both windows" button.

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.
