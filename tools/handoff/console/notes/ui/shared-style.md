# 11-ui-shared-style notes
- Guide: notes/ui/style-guide.md (5 sizes 56/32/20/16/14, space 8/16/24/32/48, rad 4, scrim .80).
- Shipped: title (01, 57) and attract (45, 46) rules read the :root tokens; the check "ui-shared has no raw literals" (mkfixture ~6171-6243) fails on a raw px font-size or hex in those blocks. Extend its screen list when later tasks move more screens.
- v29.38 card P11 (stamp), v29.39 board on tokens, v29.41 board card 560 wide + 20px empty line.
- Critic (after): 01 = 2, 57 = 2, 45 = 2 ("same"), 46 not rescored. Scores are stuck at 2 for reasons that are layout/art, not tokens:
  - Title: seven same-weight buttons, no primary action, explaining lore text, runs to the bottom edge. Fix = a structure task (one primary Play button, group the rest, drop the lore lines).
  - Board: flat black void, no world backdrop, empty state card, dim prompt. Fix = dimmed world backdrop, ghost score rows, full accent prompt at 24px (24 is off the 5-size scale; ask).
- Next: do those two structure tasks, then re-run the critic.
