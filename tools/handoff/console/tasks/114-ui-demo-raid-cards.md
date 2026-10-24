# 114-ui-demo-raid-cards : the party demo's in-raid cards (want easy mode, initials, press a after a lost pad) read as designed cards, with no overlap (coordinator 2026-10-24)
Queue (coordinator 10-24 17:55): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). Feed
order: a screen the critic scored under 4. Every guest at the Fri 10/30 party meets these cards mid-raid; their scores are from
10-21 and 10-22, before the HUD ships v34.24 to v34.50.
effort: medium

Screens (names as in notes/ui/accept.json; recipes from jobs 96 and 93/o-07, reuse them):
- 96-easy-after-map-p1 2 and 96-easy-after-map-p2 2 (recipes tools/handoff/codex/work/96-demo-easy-card-and-board-words/recipes.json):
  "a small, low-contrast teal-outlined box in the middle of a busy live raid. Its text is tiny, the y/n choice isn't a clear action, and
  the box is transparent enough that the map shows through it".
- 96-initials-in-raid-p2 2 (same recipes): "sits on top of the controls legend with no scrim, its hint line collides with the legend
  text".
- j8-p1-press-a 2 and j8-p2-press-a 2 (recipes tools/handoff/codex/work/o-07-pad-lost/recipes.json and 93-pad-lost-tag/recipes.json):
  "the screen's real job, 'press a' after a pad was lost, is a small title above a pause menu, so the player can't tell what happened or
  what to do".
Targets: 3 for each. Start with fresh pictures and a fresh critic score on HEAD; if a screen already meets 3, record it and stop on it.

Fix, in this order:
1. Overlap is a defect: if the initials card's hint line still meets the controls legend text in 96-initials-in-raid-p2's state, fix it
   (the card above the legend, or the legend dimmed under the card as the guide's scrim rule says) with a check.
2. The easy mode card: the guide's DIALOG (style-guide.md: small card, solid Panel P fill, not see-through), the question as its title,
   the two answers as the guide's primary and ghost buttons with the live key or pad glyph (his 10-18 orders, never a fixed letter).
   Keep its words (job 96's) and its timing (after the opening map); no change to what each answer does.
3. The press a screen after a lost pad: what happened as the card's title in the player's colour (P1 amber, P2 cyan) and the press a
   action as the hero with the pad glyph; the pause choices under it stay as they are. Keep every line it shows now.
These are DIALOGS (an end card or a confirm stays small, his Q43): give the critic the dialog rule with each picture and record any
point it docks for size with that reason.

Rules: read style-guide.md, shared-style.md and notes/ui/end-cards.md first. All player text lower case, short, no explaining sentence;
log any reworded or removed line with its reason in notes/ui/changes.md (Q8). Rendering only: no change to the demo's rules, clocks,
the board, pad handling, saves or the storage key. Both windows look the same apart from their colour. Do not touch the controls card
itself (his key legend answer is open) or remove any feed row (question 91).
Checks (each must FAIL on the old build): the initials hint line and the legend text do not intersect; the easy mode card's fill is
opaque; the press a title names the lost pad.
Pictures: the recipes above for all five at 1080p, then the critic.
TASK DONE when each reaches 3 from the critic (never your own grade), or the fixes shipped and the scores are written with the reason
for any point docked for size; TASK PARTIAL with what is left.
