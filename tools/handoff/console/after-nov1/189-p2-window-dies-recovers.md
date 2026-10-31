# 189-p2-window-dies-recovers : if one window dies mid-run the other plays on, and the next demo run is 2 player again
Queue (priorities page 10-27): his priorities page batch 2 (https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr, db "answers"), Tue 10-27 about 20:07, item c-windowdies (his round 2 and 3 answers 2.1 and 3.9, from cut/14-party-2p-flow.md line 5). HIS PRIORITY: LOW.
effort: medium

First check whether the game already does this on HEAD. If it does, record where (line and version), take a picture, end with TASK DONE and change nothing.

Do: in the 2 player demo, when one window closes or crashes mid-run, the other player carries on alone; the dead window reloads by itself and the next demo run starts as a 2 player run again. Test by closing player 2's window mid-run in the fixture pair.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows where it applies; smooth look first (default since v34.81); player text all lower case; never change the storage key. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when shipped and his main PC reports the build (spare/JUL26/status.txt party=VER); TASK PARTIAL with what is left.
