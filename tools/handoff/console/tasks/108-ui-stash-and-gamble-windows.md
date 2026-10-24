# 108-ui-stash-and-gamble-windows : the stash terminal and the gamble window reach 3 as windows (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 14:50): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
newly failing checks are handled (fixture retargets since run corpus-1023-2304), the robots found no problems, and the three checker
leads were not confirmed (G.player.wep is never set to nothing: bare hands is a weapon). So this is the next known work: two Undercroft
screens a player opens every run that the critic holds at 2. b-31-ui-undercroft (20 screens at once) failed on its size; this is two.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json), target 3:
- 04-stash-terminal 2 (10-20): "overcrowded and flat. Almost every label is the same small size, the key map and legend compete
  with the item grid, and the lime 'take' button is the only thing the eye lands on".
- 11-wirt-gambler 2 (10-22): "the 'the gamble' panel is a big title over a void with a small grey button, nothing on screen is the
  clear primary action, and the bottom third is dead space".
Both verdicts are two to four days old: start with fresh pictures and a fresh critic score on HEAD; if one already meets 3, record it
and stop on that screen.

These are WINDOWS (notes/ui/style-guide.md, Window, his Q43): a centred card of about 90 percent with the x top-right, so filling the
card is right here (unlike the pause boxes and end cards, which are dialogs).

Fix what the critic is right about:
- Stash: one hero figure (read the guide for what it is; money is shown with $), section labels and the muted stats at the guide's
  sizes, the gun keys and item wheel blocks spaced and headed so they stop competing with the item grid, empty grid slots drawn the
  way the backpack draws them. Do not fold the two blocks into a tab or toggle: that is a new control (one control per job).
- Gamble: one clear primary (the guide's lime button when the player can pay, its disabled style when not), at the guide's height,
  with a visible pad focus ring; one title (the window title, not a second big heading); the panels laid out to use the card instead
  of a dead bottom third. Do not add past results, odds tiles or any other new readout.
No new features, controls or readouts on either screen; no explaining sentences.

Rules: read style-guide.md and shared-style.md first. All player text lower case, short, $ for money and SP for score; log any
reworded or removed line with its reason in notes/ui/changes.md (Q8). Rendering and layout only: no change to what the stash holds,
what the gamble costs or pays, saves or the storage key.

Checks (each must FAIL on the old build): measured facts you fixed (for example the hero's size against the rest, the gamble button
height and fill when affordable, a focus ring box on the focused button with a pad, no text under the guide's minimum).
Pictures: camera-recipes.json with 04 and 11 at 1080p, then the critic.
TASK DONE when each reaches 3 from the critic (never your own grade), or is stopped at 6 tries with its best two versions noted;
TASK PARTIAL with what is left.
