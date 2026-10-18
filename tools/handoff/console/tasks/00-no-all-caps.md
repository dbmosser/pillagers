HIS HARD RULE (2026-10-18): "NOTHING should be in all caps -- all text shown to the player, should never ever ever be in all caps".
This REVERSES the older "terse caps HUD callouts" voice. Make every piece of player-facing text sentence case or title case:
canvas text (fillText of literal caps strings, .toUpperCase() on display strings), HTML menus (CSS text-transform:uppercase,
literal caps in markup), feed callouts (MACHINE ALERT becomes Machine alert), medals, cards, prompts, the What's New card.
Keep real acronyms and units as they are: SP, XP, HP, LMG, SMG, 2P, KIA, HUD, DMR, FPS, KB+M. Keep it short and punchy, only the
case changes. Work in batches by area (feed and callouts, HUD, menus, end-of-raid, stash and crafting, What's New), one cw- key
per area, each with a check that scans that area's drawn or rendered text for a word of 3+ letters in all caps that is not an
acronym above. Retarget old checks that assert caps text (fixq.sh). Track areas in notes. This task spans several runs: TASK DONE
only when a whole-game scan finds no all-caps words left.
