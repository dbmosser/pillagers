# 17-party-easy-mode : easier play (his round 2 and 3 answers)

- 2.28 c: in the demo only, each player chooses easy or normal before their run starts. In Career it is off unless the player switches it on in Settings.
- 3.16 b: easier means 30 percent less damage taken, plus a free medkit.
- 2.90 b: Career offers Forgiving on a card after a few deaths, the same offer as the demo.
- The board tag and the 30 percent points cut are in task 15 (2.47 c); make the two agree.

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.

Coordinator note 10-20 01:30 (in the VM): every build of this job shipped (3.16 b v32.07, 2.28 c v32.15, 2.90 b v32.23, 2.47 c v32.31). Only the pictures were left, and the camera had no stage for the two cards; the coordinator wrote one (tools/handoff/shots/easy-cards-recipes.json: 17-demo-easy-card, 17-career-easy-card) and photographs them into notes/shots/17-easy-cards/ when memory allows. Parked in waiting/ (no more helper runs); the coordinator closes it after looking at the pictures.
