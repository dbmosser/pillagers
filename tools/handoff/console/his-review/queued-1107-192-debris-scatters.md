# 192-debris-scatters : papers, boxes and bolts scatter when you sprint, shoot or blast nearby
Queue (priorities page 10-27): his priorities page batch 2 (https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr, db "answers"), Tue 10-27 about 20:07, item r-debris (his 10-14 pick 79, physical debris reaction). HIS PRIORITY: LOW.
effort: medium

First check whether the game already does this on HEAD. If it does, record where (line and version), take a picture, end with TASK DONE and change nothing.

Do: add light floor debris (papers, small boxes, bolts) that scatters away from a sprinting body, a nearby hit and a blast, and stays where it lands for the raid. Draw-only (no collision, no noise), capped count, frame cost under 0.3 ms at 4K.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows where it applies; smooth look first (default since v34.81); player text all lower case; never change the storage key. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when shipped and his main PC reports the build (spare/JUL26/status.txt party=VER); TASK PARTIAL with what is left.
