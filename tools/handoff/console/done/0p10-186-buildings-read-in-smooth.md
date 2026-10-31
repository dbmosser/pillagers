# 186-buildings-read-in-smooth : a house, an office and a warehouse look different in the smooth look too
Queue (priorities page 10-27): his priorities page batch 2 (https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr, db "answers"), Tue 10-27 about 20:07, item r-buildings (his 10-20 note: is this a house, an office, a warehouse). HIS PRIORITY: MEDIUM.
effort: medium

First check whether the game already does this on HEAD. If it does, record where (line and version), take a picture, end with TASK DONE and change nothing.

Do: the building kind floors and flat details (bldKindFloor, v34.49) are baked only in the pixel ground; the smooth look (default) only got the solid furniture (v34.50). Give each building kind its own floor material and a few flat details in the smooth ground bake, matching what the pixel look shows. Measure frame cost at 4K before and after (it must not grow more than 0.3 ms); pictures of each kind at 1080p and 4K.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows where it applies; smooth look first (default since v34.81); player text all lower case; never change the storage key. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when shipped and his main PC reports the build (spare/JUL26/status.txt party=VER); TASK PARTIAL with what is left.
