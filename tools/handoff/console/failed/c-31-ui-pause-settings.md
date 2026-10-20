UI STEP 6: PAUSE AND SETTINGS SCREENS. Same method as 12-ui-party-screens (read its notes and the style guide). Notes:
notes\ui\pause-settings.md. Screens: 18, 25-32, 42, 49, 68-75. TASK DONE when each scores 4 or more from the critic (never your own grade), or PARTIAL.

--- RE-QUEUED 2026-10-18 evening (coordinator). Read first; where it disagrees with the text above, this block wins. ---
Why it is back: it ran out of tries (5 runs, twice) and most runs ended "still waiting on his word". He has answered since (memory file pillagers-answers-1-78-2026-10-18.md; the same lines are under "Resolved" in questions.md). Do not wait on a ruling and do not ask again.
His settling answers:
- Q7: the style guide overrules his older layout and size orders. The "Send play data" chip in the tab strip and the five equal pause-box buttons may be moved or restyled to follow the guide.
- Q61 still binds: KEEP the feedback line, the feedback button and Send play data. Restyle or move them, never remove them.
- Q8: you may shorten or delete a line he wrote (for example the pad button labels that wrap to three lines), but only with the reason logged in notes\ui\changes.md. His words: "If it overrides my language, it better have a damn good reason".
- Q43: Settings and Keys are a centred card with an X that takes up nearly the entire screen (v30.89 did the card). The pause box is a dialog (480 wide) with the same X.
- Q59: $ for money, SP for score, if a settings row ever shows a price or a score.
- Also binding: ALL text shown to the player is lower case; Q29 (a pause stays paused); Q30 (every setting is reachable from the demo pause menu).
Already shipped since this job failed at 09:34 (git log; do not redo): v30.85 menus bounce on open, v30.89 settings and keys fill the screen as a card, v30.95 settings steppers sit next to their labels, v30.99 settings from the pause menu opens at the top every time, v31.01 the arcade pause box has no hosting line, v31.02 windows close with an x in the corner (whether it reached the Settings card: unverified), v31.04 the superhot toggle key is named beside the settings row. Shoot new "before" pictures from the current build.
Critic now (none is 4): 25, 26, 32, 42, 49, 72 = 3; 18, 70, 74, 75 = 2; never judged: 27, 28, 29, 30, 31, 68, 69, 71, 73.
Still yours (from your notes): snap the settings list to whole rows (6 x 56px), pad focus staging for 74 and 75, key cap elements for the hints, pad glyph chips, the pause box button hierarchy (feedback and what's new as rows, abandon as a quiet link, all within Q61), shorter wrapped labels, the 4px scrollbar.

## RE-QUEUED 10-18 night (coordinator)
- Why your camera and critic were refused: the command did not match the one exact form (most likely a different port, e.g. 9352, or extra bits on the line). It is fixed now: a trailing "2>&1" or "| tail -N" is allowed, and a refused command now tells you the exact form with your lane's port. Lane a uses -Port 9361, b 9362, c 9363. Take pictures and run the critic again.
- His new finish line (3.51 a): critic 4 for the raid, waiting, pause and run-over screens, and 3 for the rest. Screens already at 3 that are not one of those four are done.
- Your run count was reset. Start from your notes and do not redo shipped work.
