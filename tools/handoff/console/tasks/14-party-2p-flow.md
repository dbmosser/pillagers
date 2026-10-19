# 14-party-2p-flow : how two players share the party demo (his round 2 and 3 answers)

- Window dies mid-run (2.1, 3.9): the other player carries on alone. The dead window reloads by itself, and the next demo run starts as a 2-player run again.
- 2.7: player 2 may join at ANY time in a run.
- 2.23 a: End run takes out only the player who pressed it, and the run ends when both are out. Same for both seats.
- 2.24 a: a paused player's character stays in the raid; pausing is at their own risk.
- 2.25 b: once one player extracts, their TV shows the partner's view live, with a small line saying they are waiting.
- 2.29 a: a 2-player raid is the same raid as a 1-player raid (no extra enemies).
- 2.60 b: the two players pass through each other.
- 3.19 a: a partner can pick up a downed player any number of times; each pick-up takes a few seconds in the open.
- 3.12 b: each window keeps its own settings. 3.15 a: the party demo plays from a fixed set of party settings that never changes with his own game. 3.14 a: guests may change everything. A guest's change lasts until the attract screen comes back, and then the party set returns.
- 3.4 a: the run starts right away for whoever pressed; player 2 joins by pressing A (check that this is how it works now).
- 3.5 c: a small marker on each screen shows which window the keyboard is driving.
- 3.6 c: both characters stand side by side on the waiting screen (no walking).
- 2.72 a: when your partner goes down, a clear alert sound plays and the edge arrow pointing at them pulses.

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.
