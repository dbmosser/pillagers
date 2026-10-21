86a-pix-kit-switch : pixel look switch, blit, sprite cache, ramps and the read-side look map (his art orders 2026-10-20 22:45 to 23:05)
Queue (coordinator 10-20 23:45): the full pixel art pass for the party build, job 1 of 10. 86a to 86j sort after his play-note jobs 79 to 86
and before 87; lanes pick by name. Not held for the party (his 23:00 order).
effort: medium
After: none (61's experimental menu is in; XF_ROWS exists). Lanes reach it after 86 by name order. Three small ships (0, 1, 2).
If a job named in After is still open (in tasks/, waiting/ or running in a status file), end with TASK WAITING: its file name and what for.

Source (his words, verbatim, tools/handoff/art-survey/answers.md "10-20 evening"):
- "I want to do it all now before the party", then "if we need to reduce the customization to a smaller amount of items/classes etc, that is fine" (10-20 22:45)
- "3 head options, 3 skin options,  3  clothing (with pack) options, and 3 unique full sets" (22:50)
- "lets use that same art style to add more furniture and details inside buildings so as to give the buidlings more identity -- e.g. is this a house, an office, a warehouse, etc" (22:55)
- "quit queuing stuff for after the party -- just do it all as it naturally arises" (23:00)
- "the 3 unique sets i want to be the skeleton, the trooper (heavily inspired by master chief), and the android (heavily inspired by 2b)", then "those should be like full body skins that override whatever else the player had set in terms of customization" (23:05)

Read first: tools/handoff/console/notes/pixel-plan.md (the approach, the dress-up cut table, the switch, the speed budget, the risks).
Style test to match: tools/handoff/art-survey/style-test/ (pix.js, pillager.js, machine.js, ground.js and their preview pictures, style-test.png, style-test-play.png);
his machine lineup: tools/handoff/art-survey/ref-his-lineup.webp. Line numbers in the plan are from v33.17: grep by name.
Rules that bite here: grit() and the job's own hashes only, never rr(); simulation, AI, collision and line of sight untouched; the key stays
salvagerun:profile and the cut writes nothing to the profile; no WebGL, no libraries; player text lower case.

What to do:
Ship 0, first (coordinator 10-20 23:45): job 79 shipped as v33.23 with the default camera at 1.05 (ZDEFAULT, its closest match to
his picture, inside the 1.0 to 1.05 range it measured). Set ZDEFAULT to exactly 1.0 so 1080p is pixel exact (S = 1) and 4K is S = 2. One
line plus the 33.23 check retargeted to 1.0 through the queue, with that reason. A zoom he set himself stays his. Watch line: the camera
is a touch further out than v33.23.

Ship 1, kit and switch:
1. Add the row ['xfPix','pixel look','pixel art','l'] above XF_ROWS_END, plus pixOn(), PIX_ACT=1 and PIX_ENV=2.
2. Add pixBlit(spr,x,y,flip):
   - S=Z*DPR; draw position snapped to device px
   - nearest when S is whole; otherwise a cached nearest prescale to ceil(S), then smooth
   - imageSmoothingEnabled set on every call, because a resize resets it
3. Add PIXSTORE in GFXSTORES:
   - LRU byte caps: actors 24 MB, scene 16 MB
   - build budget: 2 builds or 2 ms a frame
   - on a miss: the nearest cached pose, else the vector painter
   - counters
4. Add the kit from the style test: ramp() (4-tone, hue-shifted), part banding toward the top-left light, harden, 1 px ink outline #16121c, and outline-ring and silhouette masks built with drawImage composites (no per-frame readback). Also a palette swap.
5. Add ramp tables as data, so 86b and 86d can run in parallel: 4 districts day and night (keeping the value bands floor 42-50, wall 54-60, top 72-78, actors 80-94), plants, MBPAL, and the 3 skins.
6. Add a 'pix' row in G.tel.gfx (builds, bake ms, hits, misses, bytes, S), and a ?pixbench view showing every registered asset at 1x and 4x.
7. Fixture: pin xfPix 0 at load, in __resetCfg and in __pinDefaults. Add a pixel smoke check (raid, hub, title, 2 windows, no DRAWERR) that every later job extends.
8. Write the lane style sheet, notes/pixel-style.md.

Ship 2, look map:
- pixLook(look18) returns {head, skin, clothes, set}, and pixOwned(), exactly as in customization_cut.
- No screen change and no profile write.

Check (new, must fail on the build before; it sets xfPix 1 and restores it in finally):
New check (sets xfPix 1). Fails before: no xfPix, no pixBlit, no pixLook.
Kit and switch:
- the row is listed with scope l and default on
- a fresh fixture pins it to 0
- pixBlit draws a 3x3 two-colour sprite at S 1 and 2 and leaves exactly those 2 colours at the exact device positions
- at S 1.333 only edge pixels blend
- the LRU evicts past its cap
- a 3rd build in one frame is refused
- with xfPix 0, a staged raid frame hashes the same as on the build before
Look map:
- every one of the 145 ids resolves to a kept id
- ten fixed profiles resolve exactly per the table (each outfit, crown, spartan, ghost mask, one scheme per family)
- JSON.stringify(P) is identical after load, resolve and save
- a profile owning only The Machine owns trooper
Pictures: the settings row, an empty ?pixbench.

Party risk: low: one settings row; nothing draws differently yet
Size: about 0.7 lane-nights. Small ships, each easy to undo.

TASK DONE when shipped with its check and pictures; TASK PARTIAL with what is left.
