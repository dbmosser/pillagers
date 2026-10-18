# HUD in play: audit (b-30-ui-hud, 2026-10-18)
Pictures: notes/shots/b-30-before (21, 33, 36 viewed). Critic before scores: 21 = 2, 33 = 2 (no after yet, nothing shipped).

## Findings, with where the code is
1. Same line three times (33, 36): "Codex entry . Scav pistol", "Contract Item nearby" show in the centre message row AND the feed (bottom left). By his order v27.24 (feed1) the feed takes every line and "the next builds move the old places out" (say() 19617 keeps feedSay AND the rows). Fix = stop drawing the centre info/obj rows while FEEDBOX.on, keep crit/warn/ext alerts. Touches many fixture checks on drawn text (needs its own task with a fixture sweep).
2. Controls legend (40345-40411, G.legendOn 0/1/2, F1 cycles): a 12-row table over the play space on raids 1-3. Style guide wants it hidden except F1 and the first 30 s. Already collapsed after 3 raids (line 14962). Proposed: collapse after 30 s of the first raids, not a full raid.
3. Run info (39197): 7 contracts at 14 px, a wrapped line ("Search 4 containers in the / long dock or scrap line"). Proposed: 3 lines max, rest behind the chevron; measure wrap to the panel width instead of a hard break.
4. Pillagers board (41395-41510): "$" is loot VALUE (same as stash and bag), not score; left as is. Row pitch LH(11) is tight; chevron + resize tick on the corner; title 'CURRENT PILLAGERS' micro size (10) under the 16 label floor.
5. Hierarchy: ammo 12/24 (40px) and HP 100 (huge) and credits 900 (30px, amber) all shout. Guide: ammo is the one hero; credits 20 px tx-1; backpack hint 16 px tx-2 not bold amber.
6. World name label (purple "The long...") sits under the minimap at the top right: a world label covered by the minimap, not a minimap bug.
7. Stamina label floats right of its bar; slot 1 amber and slot 4 blue frame both read as selected in 21.
8. Extraction chip hugs the Run info panel (about 4 px gap) and the right screen edge.

## Why no ship this run
The HUD layout is locked by hundreds of fixture checks (HUDBOX overlap and text-drawn checks), every item above is a multi-edit change, and 1 and 3 undo or reshape lines he ordered (feed1, feedall). One safe sequence for a later run: (a) legend 30 s rule, (b) run info 3 lines, (c) type floor 16 on board and run info, (d) one hero number. Each as its own cw- ship with preflight on lane b.
