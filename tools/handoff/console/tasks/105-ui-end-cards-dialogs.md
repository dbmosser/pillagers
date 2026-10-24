# 105-ui-end-cards-dialogs : the four raid end cards the critic holds at 2 and 3 reach 4 as dialogs (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 13:55): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
next known work is screens the critic scored under their target. 13-ui-end-cards (all end cards and more at once) failed on its size;
this is only the four raid end cards, which a player sees after every raid.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json), target 4 (raid screens):
- 35-kia-card 3 (10-18): "the hero is a banned '$' figure, the secondary text is tiny and dim, and the item tiles are too small and
  confusingly placed above the number".
- 60-abandoned-card 2 (10-19): "a weak hero, tiny stats, a loss that does not read as a loss, and an xp line that explains too much".
- 59-raid-abandon-confirm 3 (10-19): "the x is still stranded mid-card at the title line and the title, danger button and padding are
  unchanged".
- 38-extracted-card 3 (10-21): "a weak hero, too many stacked small lines" (v34.23 since changed it: start from a fresh picture).
All verdicts are three to six days old: start with fresh pictures and a fresh critic score on HEAD; if a card already meets 4,
record it and stop on that card.

The size complaint is not yours to fix: notes/ui/style-guide.md (Window, his Q43) says an end card (720) and a confirm are DIALOGS,
not windows, and stay small cards sized to their content; the style guide beats the judge's taste (his 54). Give the critic the
guide's dialog rule with each picture and record any point it still docks for size with that reason.

Fix what the critic is right about: one hero per card from the guide (read what it says the hero of each end card is, and whether
money may be the hero; his rule is $ for money), secondary text at the guide's sizes, item tiles placed under the hero, the loss
reading as a loss on the abandoned and killed cards (his rule: dead or abandoned comes back empty), the x in the header row, no
explaining line. No new readouts, no new controls.

Rules: read style-guide.md and shared-style.md first. All player text lower case, short, $ for money and SP for score; log any
reworded or removed line with its reason in notes/ui/changes.md (Q8). Rendering only: no change to what a raid pays or takes, the
simulation, saves or the storage key. A visible pad focus ring on each card's primary.

Checks (each must FAIL on the old build): measured facts you fixed (for example the hero's size against the rest, no text under the
guide's minimum, the x inside the header row).
Pictures: camera-recipes.json with the four cards at 1080p, then the critic.
TASK DONE when each reaches 4 from the critic (never your own grade), or the fixes shipped and the scores are written with the reason
for any point docked for size; TASK PARTIAL with what is left.
