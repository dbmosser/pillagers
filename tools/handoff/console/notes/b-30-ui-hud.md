# b-30-ui-hud notes

## Done
- v29.61 (cw-runinfopal): Run Info panel headings and goal rows on the shared palette (UIC.acc, tx_1).
- Fixture fix a590d06d: three checks were labelled v29.60, so the ship anchor `{v:'29.60',what:` matched 3 times and every ship STOPped ("check patch did not apply"). Two relabelled 29.59. If a ship adds several checks in one version again, this will recur: give extra checks a different v.
- Pictures: shots/b-30c-before, shots/b-30c-after (19,21,33,37,50).

## Critic on 21-raid-hud-calm (before vs after v29.61): score 2, "same"
P0: no hierarchy - make the extract timer or ammo the one hero (56px), collapse scoreboard and controls cheat sheet by default.
P1: Run Info 7-8 contract lines; show max 3 at 20px with right-aligned counts, fixed 16px wrap indent.
P1: top-right currency block four strings; one row "Credits 900 · XP 0", drop stash/bag line, right edge on 5% margin.
P1: "$" still on scoreboard and weapon panel (rule: SP). Corner grip ticks; panels translucent gradients, not flat --ui-panel 90%, 1px --ui-line-hi, 4px radius.
P1: purple location label clipped behind minimap ("The long ..."), off palette; clip/move it, tx-1 16px.
P2: toast bottom-left low contrast, wrong place (top-centre 40px with 4px left bar). Controls cheat sheet only first raid / F1. "B / I backpack" outranks ammo; shrink to 16px tx-2.

## Remaining (next run)
Order by safety for the 10/30 demo: (1) location label clip/colour (drawLore/loc, G.loc near line 19156), (2) "$" to SP check on scoreboard/weapon panel (check his rulings first), (3) currency block to one row, (4) HUD panel fills flat. Each is its own mk script; look at 19,21,33,37,50 after each.
Not yet audited by critic: screens 19,20,22-24,33,34,36,37,48,50,51,61,78.
