# c-30-ui-menu-map: menu map (run 3; pictures in notes/shots/c-30-before and c-30-after)

## The screens and how you get in and out
- TITLE (#title): mode rows (1 player, 2 player co-op same machine, 2 player arcade demo, 1 player arcade demo, 2 player co-op server [dead], 2 player PVP same machine, PVP server [dead]), Go fullscreen, key line, Saves list, Change name, Create a new save. Out: pick a mode.
  - Start a 2-player party game: 1 click (2 player arcade demo or co-op same machine) + the player 2 window opens. 2 clicks if a save change is wanted first.
- UNDERCROFT floor (hub): ESC / P / TAB opens the PAUSE BOX (Resume, Settings, Leaderboard, Feedback, What's new, Return to character selection). 1 key to open, 1 key (ESC) to close.
- RAID: ESC / P / TAB opens the pause box (Resume run, Settings, Feedback, What's new, Abandon run). ARCADE: Resume, Feedback, What's new, End run.
- SETTINGS (#settingsmodal, tabs from #settabs): from the pause box (2 clicks: ESC, Settings) and from the title? (only through the pause box). Close button = CLOSE (UIFRAME footer), ESC closes.
- Controls: F1 in play (cycles the list), the key line on the title, the pause box key list (ESC = 1 press, no click). 1 press.
- Leave a raid: ESC, Abandon run, confirm = 3 steps. Extraction = X / hold E in a ring.
- Find an item in the stash: stash filter box (#stashq, ESC clears it, a second ESC leaves).
- Modals (all close with ESC/TAB through escCloseTopModal0, which clicks [data-esc], button#close*, #stageback, #carryclose or #askno, else just hides): fb, wn, lb, trader, gamble, appear, bar, trophy, codex, terms, party, dev, op, ask, sector, cheat, carry, stage, welcome, share, settings, crate, tune, sim.
- B no longer backs out (his ruling v13.45); TAB = ESC (v13.44). B and I are the backpack.

## Badly organized (found)
1. FIXED v29.30: title key line said "H controls", but H is heal since keyswap; F1 is the controls list. A guest pressed H and healed.
2. FIXED v29.32: title button read "Create A new save" (one-letter A stayed capital in the no-all-caps door).
3. Pause box: "Please provide feedback anything that went or felt wrong." is an explaining sentence over a FEEDBACK button (the same job twice), and it is ungrammatical. It is probably his own wording from v10.41, so NOT changed. Question asked.
4. Title mode list: two dead "coming later" rows sit in the middle of the live rows (server co-op above PVP same machine). The rows are in his order (v15.76), NOT changed. Question asked.
5. Settings Rec tab holds the send-to-Daniel and restore code (a settings tab used for something that is not a setting). Not moved yet.
6. Hub pause has 6 buttons in one wide row; raid pause 5. Order is the same on all three (Resume, Settings, Leaderboard, Feedback, What's new, then the leave button), so it is consistent. Fine.
7. ESC/TAB back-out: every modal closes, because a modal with no known close button is just hidden. No dead end found by reading. Not probed live (no screen path to test every one).
8. Controls reachable only by F1 in play; no button for it in the pause box (the key list is printed there instead). Fine.

## Fixes shipped (five)
v29.28 first Settings tab is Game, not Display. v29.30 title key line F1 controls. v29.32 Create a new save. v29.33 title and mode menu on the shared look. v29.36 title has a Settings button (before: Settings only reachable inside a game's pause box; after: beside Go fullscreen, ESC closes). Pictures: shots/c-30b-before and c-30c-after. Critic on the title: it wants the whole title rebuilt (left column, drop lore and steps, group the modes); that is a redesign, not a menu fix. Left for a title redesign task.

## Not done
- Items 3, 4, 5 need his answer (3 and 4 are his wording and order). The task asked for five fixes; two shipped, so PARTIAL.
