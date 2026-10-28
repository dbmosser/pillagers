# 187-impact-puffs-by-material : a bullet hit throws a small puff that matches the material: splinters, dust or sparks
Queue (priorities page 10-27): his priorities page batch 2 (https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr, db "answers"), Tue 10-27 about 20:07, item r-splinters (his 10-14 pick 80, material-aware impacts). HIS PRIORITY: LOW.
effort: small

First check whether the game already does this on HEAD. If it does, record where (line and version), take a picture, end with TASK DONE and change nothing.

Do: impact sounds by material shipped in v23.84. Add the matching visual: wood throws a few splinters, concrete and brick a dust puff, metal a short spark, using the same material lookup the sound uses. Few particles, short life, capped per frame; gate them with fowLive like other live action. Pictures of all three.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows where it applies; smooth look first (default since v34.81); player text all lower case; never change the storage key. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when shipped and his main PC reports the build (spare/JUL26/status.txt party=VER); TASK PARTIAL with what is left.
