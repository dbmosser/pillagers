# b-30-ui-hud notes (lane b)

## Shipped
- v29.31 cw-hudhero: quiet credits and backpack cue (HUD has one hero: ammo).
- v29.34 cw-runinfo16: run info panel text 13 px micro -> label size (16 px class), row 165->196 wide.
- Pictures: shots/b-30-before, b-30-after, b-30-after2 (screens 21, 33, 36 only).

## Critic (screen 21, after v29.34): still 2
Open P0/P1 findings, in order of value (none done yet):
1. Run info: at most 3 contracts shown + "+N more" (BUT his v6.79 says every contract is shown: ask before changing). Title "Run Info" -> "Run info" (sentence case; Contracts header same weight as rows).
2. Controls cheat sheet: hide after 30 s / first raid, drop to F1 chip. Key caps instead of bare letters. Duplicate LMB row.
3. Pillagers list: "$1,770" -> "SP 1,770" (his rule: score is SP, never $). Collapse to own row until Tab.
4. Minimap zone label: lilac "The long d..." clipped at the map edge; move above the map, palette colour, ellipsis.
5. Weapon panel: shrink to content, remove "5 items $1,770" footer (a $ again), 56 px ammo, key caps B / I.
6. Status cluster: flat HP bar (no gradient), one treatment for Standing / Stamina / HP.
7. "crlers" in a contract line is a typo in the shot ("Destroy 2 crlers 0/2"); grep of the game finds no such string, so it is probably built from a name table (find where the contract noun is made).
Screens 19,20,22-24,34,37,48,50,51,61,78 not yet shot or critiqued.

## Why PARTIAL
Each fix touches a large HUD draw function; one ship per concern needed. Next run: do 3 (SP not $), 4 (zone label), 2 (cheat sheet hide), then re-shoot all screens and run the critic on each.
