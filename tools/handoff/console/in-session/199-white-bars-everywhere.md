# 199-white-bars-everywhere : no white rarity bars under items, on every screen
His order 10-27 afternoon (priorities page id o-whitebars, MEDIUM): "Remove the white bars under items everywhere". v35.12 (cw-undercroft
fixes) took them out of the shop, craft and wirt windows only; the rest was dropped twice (found by the CEO chat 10-27 22:20). Worked by a
CEO chat helper (Sonnet, high). Lanes skip in-session/.

Do:
- Find every place an item icon is drawn with the white rarity bar under it (stash grid, backpack in the raid and in the Undercroft, the
  pre-raid screen and its belt, the hotbar row, the extracted card, the gun cards, tooltips). Read how v35.12 removed it from shop, craft
  and wirt (git show 12136fc17) and do the same everywhere else, so the bar is gone on every screen a player reads.
- Do NOT touch the container search rows, the pickup stack or loot sounds (his 10-27 21:35, binding: "I really like how looting feels
  and looks"). If those rows draw the same white bar, leave them and name them in the report as left on purpose.
- Other rarity colours: keep them unless the v35.12 change removed them too; match v35.12 exactly.
Check (must FAIL on the current build): on every screen above, no item cell draws the white rarity bar (use the same hook v35.12's check used).
Pictures at 1080 of the stash, the raid backpack, the pre-raid screen and the extracted card, before and after; look at them.
Ship through preflight + shipq. TASK DONE only with the ON HIS PC line; then move this file to console/done/ with one result line, and mark
the order SHIPPED in console/open-orders.md (line "White bars gone everywhere").

HIS NOTE 10-27 ~22:25 in the orders chat, with a picture of the raid belt (verbatim): "the higher white bars need to be removed as they are not helpful".
What he means (read in the code and his picture): on each belt slot the UPPER bars are the cream rarity pips in a black box beside the ammo count (rarityPips(), drawn by drawItemIcon and itemIconURL without np). Those go, on the belt too. The LOWER thin bar along the bottom of each belt slot (white or amber, partly filled) is a different thing: keep it exactly as it is. The slot border colour (purple, gold) stays as the rarity cue.
