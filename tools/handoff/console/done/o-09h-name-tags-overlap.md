# a04-name-tags-overlap : name tags of enemies standing together print over each other
Queued 10-28 by the CEO from the Auditor's handoff (his "All of it" on the audit). Take pictures at 1080 and 4K with several machines standing together.
From the cloud audit of 2026-10-28 (tools/handoff/cloud/audit-2026-10-28.md, item 9). Polish of what the game already has.

What: two crawlers side by side drew their tags on top of each other, read as "craw crawler c-73", next to a pillager bot's tag
(picture: tools/handoff/cloud/audit-2026-10-28-shots/raid-name-tags-overlap.jpg, Cold Storage, day, 1080p).

Do: when two world name tags overlap, stack the later one above the earlier (or show only the nearest), the way hudPrompt stacks
the REVIVE and FINISH prompts. Rendering layer only; no simulation change. Check: two tagged enemies one body apart draw tags whose
boxes do not overlap. Pictures before and after. Say in DESIGN.md what he should watch for in a fight.
TASK DONE when shipped and ON HIS PC.

ALSO (CEO 10-28 18:40, from the o-09e critic, P0): at the right screen edge a cache name is overprinted by a distance chip. Picture: notes/shots/o-09e-damage-numbers-merge-and-yours-red-recipes-1/ (incoming-p1). Same cause family as the tag overlap: give the distance chip and the cache name their own lines, or stack them, at 1080 and 4K.
