UI STEP 3: THE PARTY DEMO SCREENS (his order 2026-10-18; the party is 10/30, these are what his guests see). Read
notes\ui\style-guide.md, look-book.md and shared-style.md first. Notes: notes\ui\party-screens.md.
Screens: 46, 47, 48, 49, 52, 53, 54, 55, 56, 58, 62, 63, 64. Move each onto the shared look and fix what look-book.md says,
worst first: before pictures, change, preflight, ship, after pictures, compare, fix again if not clearly better. Also make them
consistent with each other (same title spot, same buttons, same spacing). Log in notes\ui\changes.md and the Changes section of
notes\ui\index.html. TASK DONE when every listed screen scores 4 or more from the critic (node tools/console-sdk/critic.mjs, never your own grade), or TASK PARTIAL with the rest.

--- SCREEN HANDOVER 2026-10-18 evening (coordinator). Read first; where it disagrees with the text above, this block wins. ---
Screens 46 and 56 were also on task 03-title-and-backdrop. Task 12 now owns both, and 03 has dropped them from its list.
- Yours: 46 (how to play page), 56 (tonight's best with a scored row) and the rest of the list above. The cards on these pages (rows, buttons, close X, any-key prompt, spacing) are yours, and so is the card code of screen 45, because 45, 46 and 56 are one attract card in three states. Task 03 keeps 45 only for the title and the backdrop.
- Not yours: the live backdrop behind these pages (the dimmed map with the fight; shipped v30.69, v30.82, v31.19; 4K frame rate not measured). If a critic finding is about the backdrop, log it in notes\03-title-and-backdrop.md and leave it.
- Settled by his answers of 10-18 since you last ran: Q7 (the style guide overrules his older layout and size orders), Q8 (you may shorten or delete a line he wrote, only with the reason logged in notes\ui\changes.md; his words: "If it overrides my language, it better have a damn good reason"), Q59 ($ for money, SP for score: the arcade score is "sp", never "$"), and ALL text is lower case.

## Coordinator, 10-18 evening: re-queued with its blockers cleared (run 3)
- Screen 47 (the arcade drop with the controls card) is gone. The controls card was removed in v30.50, and since v31.09 every raid opens on the sector map first, so there is no party card at 47. Drop 47 from this task; the map start belongs to the cw-mapstyle helper.
- Screen 53 is restaged in tools/handoff/shots/ui-screens-js.json. It now ends the arcade raid with the game's own extract ending (__endRaid('extract')) and shows the run over card (#attract). The test shot is in tools/handoff/shots/restage-53/. The TOP 10 initials card needs a score that makes the board. If you want it in the shot, stage kills first; otherwise leave it out.
- The footer prompt is settled, with no question for him. His 10-11 instant-start order (any key or button starts) and his 10-18 live-prompt order settle it, so the walk-up screens keep the live "press any key" / pad-button prompt as their primary action, and no filled "got it" button is added. tools/console-sdk/critic.mjs now tells the critic this, so it should stop flipping on it.
- These rulings settle the rest:
  - Q7: the style guide overrules his older layout orders.
  - Q8: helpers may shorten or delete his explaining lines, but only with a reason logged in notes/ui/changes.md.
  - Q43: a centred card with an X, taking nearly the whole screen (v31.10 made windows a 90 percent card).
  - Q59: $ for money, SP for score.
  - All text is lower case, the accent is lime, and the finish line is a critic score of 4.
- Screens 46 and 56 belong to this task only, because 03 handed them over.
- Order: the screens guests see most come first (46, 52, 55, 56, 58, 62, 63, 64), then 48, 49, 53 and 54.
