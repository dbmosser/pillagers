# 110-ui-demo-end-screens : the party demo's run over, initials and board cards show what they name, say each event once, and reach their targets (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 15:25): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). Next
known work is screens the critic scored under target. These five are what every guest at the Fri 10/30 party sees at the end of a
demo run, and their scores are five and six days old (12-ui-party-screens, before v34.24 to v34.36).

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 53-arcade-extracted-bonus-initials 2, target 3 (10-18): "still a cluttered in-raid HUD, not the extracted/bonus/initials end card
  the filename promises, and the same extract message appears four times at four different sizes".
- 54-arcade-initials-redrop 2, target 3 (10-18): "the same extraction event appears four times, the top-centre block is cramped and
  overlaps".
- 64-arcade-board-seeded-night 2, target 3 (10-19): "a small, quiet dialog with a tiny 'seeded night' line, a bare 'no scores yet', a
  dim prompt and a blurred, busy backdrop".
- 52-arcade-run-over 3, target 4 (10-18) and 55-arcade-run-over-scored 3, target 4 (10-19): "the prompt is still small and dim",
  "the type is still small for a couch", "the hero still not dominant".
Start with fresh pictures and a fresh critic score on HEAD; if a screen already meets its target, record it and stop on that screen.

Fix, in this order:
1. A picture that does not show what its name says is a broken recipe, not a score: if 53 or 54 still shows the plain raid HUD, fix
   the recipe in ui-screens-js.json so it stages the initials card (job 96 left the card text "tonight's best . enter initials"), and
   score that.
2. One event said once: if the extract or bonus message is still drawn four times (54's state), find what draws the copies and keep
   one place for it, the one the guide gives. A row in the left feed is his 10-15 feed-all order: keep it (question 91 is open).
3. Then the critic's points the guide agrees with: the hero of each card at the guide's hero size, the prompt at the guide's size with
   the live key or pad glyph, secondary text at the guide's sizes, no explaining line.
These cards are DIALOGS (notes/ui/style-guide.md, Window, his Q43: an end card is 720): the size points are docked on purpose; give
the critic the dialog rule with each picture and record any point it still docks for size with that reason.
No new readouts or controls (no ghost score rows, no new stats). Do not change the board's row count (job 96: his answers conflict on
10 or 20; it is named by its title).

Rules: read style-guide.md, shared-style.md and notes/ui/end-cards.md first. All player text lower case, short, SP for score
and $ for money; log any reworded or removed line with its reason in notes/ui/changes.md (Q8). Rendering only: no change to scoring,
the board, the demo's rules or clocks, saves or the storage key. Both windows (P1 amber, P2 cyan) look the same apart from their colour.

Checks (each must FAIL on the old build, or say it was already fixed): the message drawn once in 54's state; measured facts you fixed
(hero size against the rest, the prompt's size, no text under the guide's minimum).
Pictures: camera-recipes.json with the five screens at 1080p, then the critic.
TASK DONE when each reaches its target from the critic (never your own grade), or the fixes shipped and the scores are written with
the reason for any point docked for size; TASK PARTIAL with what is left.

--- COORDINATOR 2026-10-24 17:50: closed as DONE from failed/ by its own finish line ("the fixes shipped and the scores are written with the reason for any point docked for size"): v34.45 shipped; 53, 54 and 64 reach their target 3; 52 and 55 stay at 3 (target 4) with every point left being size or layout against his rulings (the 720 end card, his Q43; the lighter scrim, his Q52 and Q54) or labels the css floors at 16px. His rulings win over the critic, so no question to him. Runs 4 to 8 only re-read the notes.
