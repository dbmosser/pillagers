49-corpus-figure-art : 8 old checks on the human figures went red after the v32.64 to v32.67 figure art (coordinator 2026-10-20, from tools/handoff/corpus-fails-v32.83.txt)
effort: medium

These 8 passed at v32.16 and fail at v32.83. All measure the human figures, which v32.64 to v32.67 redrew (bigger, shaped, action poses, pillager bots). Some may be REAL losses a player would see: worn headgear that no longer draws (v10.00, v28.16), racks and packs that no longer change the outline (v28.12, v28.13), the ground shadow direction (v28.85), the Peddler's hat (v24.32), shoulder caps (v24.37), sprite sharpness (v18.48). Check REAL first: if the wardrobe or racks a player picks no longer show, that is a game fix, not a retarget. His art survey picks (DESIGN.md v32.64: head 1.2, figure 1.25, build heights, bigger pack and vest, a bigger darker shadow) are his taste and win over an old check on size or darkness; what a player picks to wear must still show.

For each check: find it in tools/mkfixture.ps1 ({v:'NN.NN'), run it on the current fixture (runchk.sh; a check that passes on HEAD is FIXED SINCE), then decide:
- REAL: the game broke something no ship meant to change. Fix the game through the ship queue, with a new check whose control FAILS on the old build.
- STALE: a later ship changed it on his order or on purpose with its own check. Retarget the old check so it keeps its intent under the new rule
  (bash S/lock.sh, edit, runchk.sh, HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds, a few checks at a time). Delete only if its feature was removed.
- HARNESS: flaky staging (window size, timing). Fix the staging.
Never weaken a check to make it pass. Write one line per check in tools/handoff/console/notes/49-corpus-figure-art.md: version, REAL / STALE / HARNESS / FIXED SINCE, one-line reason.

The checks (version what it checks -> what it saw at v32.83):
v28.85 the operator ground shadow is cast to the lower right (light top-left): the shadow pixels under the feet lean right and reach past the old 10 px edge -> the shadow reaches -11.2 px left (want no further than -10.6)
v28.16 the head layer: six new headgears that change the head shape at raid size, in the scheme accent, yours alone -> the hero wearing the Heavy Helmet draws differently from the same helmet on a body (4956 pixels)
v28.13 the body layer: a vest rack and a shoulder rack that change the chest and shoulders of the silhouette, in the scheme colours, across the link and in looks -> the hero draws the racks differently from a body that carries them (1200)
v28.12 pack and boot shapes: four packs and two boots that change the outline, in the scheme colours, across the link -> the hero draws the racks differently from a body that carries them (4990)
v24.37 graphics program gfxsil (his #24, silhouettes for readability): every body has inked shoulder caps standing out past its torso, wide on Broad and narrow on Curved; in a raid they wear the team colour (ally blue on you, danger red on 
v24.32 spr20: the Peddler has a wide hat and a pack frame, wears his own outfit and his lantern glow is baked -> no wide hat brim: the widest row at the brow is 19.3 (want 22 or more; the head is 20.3)
v18.48 the baked sprites are sharp at any scale: the sprite scale rounds up (2.6 gives 3) and reaches 4 for 4K, a shadow stamp takes the scale of the canvas it is drawn on, and a lost canvas drops every sprite store -> a shadow on a canvas 
v10.00 every headgear in the wardrobe is drawn on the operator, and every hair and clothing colour has a swatch -> headgear that draws nothing on the operator: band (0 px), mask (0 px)

TASK DONE when every check above is green on HEAD or explained in the notes; TASK PARTIAL with the ones left.
