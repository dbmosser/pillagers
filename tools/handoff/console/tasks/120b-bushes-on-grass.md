# 120b-bushes-on-grass : a bush stands on paving bricks
Queue (coordinator 10-25 11:50): HIS NOTE on the photo of v34.78, Sun 10-25 about 11:47: "Why do we have bricks on the floor but a bush
on top of the bricks, makes no sense." Party fix. He said the same in v2.86 ("bushes should only spawn on grass") and v3.90 ("bushes are
spawning on roads"); the road cull (bushRoadR, about line 12528) only knows roads, so in the pixel look bushes sit on concrete slabs.
effort: medium

The picture: notes/his-photo-notes-1025/bulwark-and-wallet-v3478-1080.jpg (top middle and bottom left: bushes on the slab floor).

Do (render layer only): give every bush a patch of grass under it. In the pixel ground bake (pixGroundTex, pixGroundChunk, about line
51741 to 51811) paint the turf family (4) in a ragged disc a little wider than each bush (bush r plus about 8 to 14 world units, edge
from grit() so it is not a perfect circle), so the existing turf teeth draw its edge. Do the same in the vector look's ground. If trees
stand on slabs the same way, give them the same patch.
- Do NOT move, add or remove bushes: they are concealment (gameplay), and moving them changes stealth. Nothing from rr/rnd/pick; the
  bake uses grit() only, so the seed 4242 fingerprint (ents 85/374, containers 165/593) and both windows stay identical.
- Bake cost: the patch is part of the chunk bake; measure PIXG.ms before and after and keep a chunk under the 4 ms budget.
Pictures: before and after at 1080p and 4K (the recipe in notes/his-photo-notes-1025/recipes-bc.json, screen gfx-b-machine-damage, shows
two bushes), and one wider shot of a street with several bushes. Check (must FAIL on v34.78): the ground pixel under a bush's centre is
turf, in the pixel look.
TASK DONE when it shipped with pictures; TASK PARTIAL with what is left.

Coordinator 10-25 12:55: his 10-25 order turned the pixel look OFF ("I want the graphics smooth"). Do the SMOOTH look first: in the smooth look bushes also sit on bare concrete and asphalt (picture: scratchpad shot look-smooth-z1, same staging), so give each bush its grass patch in the smooth ground. The pixel ground part is optional now.
