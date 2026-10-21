# 86b-pix-ground (lane a, 10-21 02:30)

## State
- Ship 1 key cw-pixground (mk in the scratchpad, draft tools/handoff/drafts/draft-cw-pixground.json): PASSED preflight and the whole gate except the last step. ship.sh start applied it as v33.57 (game, fixture, DESIGN, AUDIT in the working tree), then verifySafe printed TIMEOUT on gate Chrome 9346 and shipone stopped before the commit. The tree is left patched and uncommitted. Alarm written in alarms.md (02:25): the coordinator either finishes it (gate -Fix, then ship.sh commit 3357 cm3357.txt; the message copy is /tmp/cm3357.txt) or undoes it with git checkout of the four files. I cannot do either (no git write or gate.ps1 in my list).
- Then I re-ship nothing for pixground until the tree is clean. If the coordinator undid it: bash tools/handoff/preflight.sh a cw-pixground, then shipq.sh cw-pixground (the mk is unchanged and works).

## What ship 1 does (v33.57 when it lands)
- bakeGround with pixOn(): canvas ceil(W/2) by ceil(H/2) on a CPU canvas (willReadFrequently), ctx.scale(1/PIX_ENV): the very same drawing code, so rr() order is unchanged (check compares RNGS after the bake in both modes).
- Thin lines widened to one art pixel (interior floor lines, manhole rings), shed number alpha x2.4 so it survives the snap.
- pixGroundQueue / pixGroundStep / pixGroundChunk / pixGroundFinish / pixGroundFinal: the pass runs in 64x64 art pixel chunks (256 took 5.8 ms and 128 took 4.1 ms on the VM, the check wants 4 ms or less; 64 passed). Chunks under the camera at once, the rest at most PIXG.budget (4 ms) a frame from render2D. When the last chunk is done the CPU canvas is copied to a plain canvas (G.ground is swapped).
- Snap: per district and day/night a palette of 5 families x 4 tones (open floor from PIXRAMPS.districts floor band, building floor, road, water, turf). A pixel goes to the family of its nearest reference colour (the bare ground colour and district floor, with darker shades, count as open floor), the tone by lightness. So fades and halos become steps.
- Texture (grit() and own hashes of the absolute art pixel only): slab seams (vertical every 24 px, jittered per 20 row band, horizontal every 20th row), 1x2 and 1x3 strokes in 1 of 5 eight pixel cells, water strokes, grass teeth on the turf edge, bitten notches and light blades.
- Blit: render2D halves the source rect; smoothing off when Z*PIX_ENV is whole, on otherwise.
- Scars: scarOn scales the context by 1/pe, stamps snap to the 2 unit grid, bounds use the world size. gfxScarReplay uses scarOn.
- onCtxRestored needs no change: it calls bakeGround, which now returns a queued ground, then the scar replay paints onto it before the chunks run.
- Check (new, fails before: no pixGroundFinish): rr position equal, off = full size, on = half size, 64x64 open floor window per present district at most 8 colours (control window with the look off must hold more than 8), no chunk over 4 ms, whole bake under 1500 ms, a far corner scar accepted, a real raid built with the look on has the half floor.

## Next ships (written or planned)
- cw-pixhub (mk written, not run): bakeHubGround at half density snapped to the 8 tones of two ramps (cool plating and the warm lift glow), follows the switch at the next floor frame, check included. Needs ship 1 in HEAD (it calls pixGroundNear / pixGroundHex).
- cw-pixdecal (not written): footprints and decals snap their draw position to the 2 unit grid in pixel mode (render2D around G.prints and G.decals, translate/fillRect).
- Pictures still to take: raid at 1080 and 4K, day and night, the hub. The camera (uishots) runs the fixture, which pins xfPix 0, so it shows the OLD ground; a staging that sets CFG.xfPix=1 needs a camera recipe (tools/handoff/console/notes/camera-recipes.json style) or a questions.md ask. Not done.

## 10-21 later run (lane a)
- Tree still dirty (v33.57 applied, uncommitted, not in git log). Nothing new done; no git write or gate.ps1 in my list. Waiting on the coordinator: finish (gate -Fix, ship.sh commit 3357) or undo (git checkout of the four files). Then: preflight and shipq cw-pixground, then cw-pixhub, cw-pixdecal and the pictures.

## Watch lines for him
- Any hitch at the start of a raid (chunks of the floor finish in the first seconds; the ones under the camera are done in the first frame).
- Pillagers or machines blending into the floor at night (the night ramps follow PIX_BANDS.night; 86j measures it).
- Scars and brass casings keep soft edges on the floor (they are painted after the snap).

## 10-21 02:42 run (lane a)
- Tried shipq cw-pixground: MK FAIL, anchor matches 0, because the dirty tree already holds the v33.57 pixground patch. Still waiting on the coordinator: commit it (gate -Fix, ship.sh commit 3357) or git checkout the four files, then I re-ship.
