# 138-hud-size-row-does-nothing : the settings row hud size (large for tv) does nothing
Queue (coordinator 10-25 15:25): found while checking his 100 gameplay questions (notes/questions-100-1025-changes.md). Party fix (Fri 10/30 first): the party plays on TVs.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: low

Do: the HUD SIZE row (GAMEOPTS k hudTv, about line 71062) saves CFG.hudTv but nothing in the game reads it. The TEXT SIZE row already scales raid text. One control per job (his rule): if text size already makes the raid text and panels readable across the room, remove the HUD SIZE row (a saved index stays harmless); if it does not reach the panels (bars, minimap, belt, partner row), make LARGE FOR TV scale those panels and reword the hint. Take 1080p pictures of a raid at both settings and a TV distance check (the 1080p picture at half size).

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
