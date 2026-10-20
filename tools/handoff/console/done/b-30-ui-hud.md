UI STEP 4: THE HUD IN PLAY (his order 2026-10-18, see 10-ui-look-book). Read notes\ui\style-guide.md, look-book.md and
shared-style.md first; if the guide is not READY yet, do this task's audit part (pictures and notes) and end TASK PARTIAL.
Notes: notes\ui\hud.md. Screens: 19-24, 33, 34, 36, 37, 48, 50, 51, 61, 78. The HUD must read at a glance from a couch and stay
out of the way of the fight: fewer, clearer elements, the same type and colors as the menus. Same method as
12-ui-party-screens: before, change, preflight, ship, after, compare, fix again. TASK DONE when each scores 4 or more from the critic (never your own grade), or PARTIAL.

--- RE-QUEUED 2026-10-18 evening (coordinator). Read first; where it disagrees with the text above, this block wins. ---
Why it is back: it ran out of tries (5 runs, twice) and most runs ended "still waiting on his word". He has answered since (memory file pillagers-answers-1-78-2026-10-18.md; the same lines are under "Resolved" in questions.md). Do not wait on a ruling and do not ask again.
His settling answers:
- Q7: the style guide overrules his older layout and size orders.
- Q8: you may shorten or delete a line he wrote, but only with the reason logged in notes\ui\changes.md (old text, new text, reason). His words: "If it overrides my language, it better have a damn good reason".
- Q43: windows are a centred card with an X that takes up nearly the entire screen. (HUD panels and dialogs are not windows; guide section 2.)
- Q59: $ for money, SP for score. Money keeps the "$" (item value, bag, stash, prices). A score drawn with a "$" is a bug and becomes "sp". Check what each "$" on your screens means before you change it, and log it.
- Also binding: ALL text shown to the player is lower case.
DO NOT TOUCH THE TOP-RIGHT BLOCK. His newest order (chat, 10-18 afternoon): "everything in the right hand upper corner should be in a vertical 1 by 1 list and they should all be the same size". It supersedes Q58 ("one row"). Another helper is building it under key cw-trcol (not shipped as of v31.23). Leave the credits, xp, stash and bag lines, #topright, syncTopRight and their CSS alone. A critic finding about that corner is logged once as "waits on cw-trcol" and skipped. If you are unsure whether an element sits in that corner, leave it.
OVERLAP WITH TASK 02-raid-hud-redesign (lane a, running now): it has the same screens (19-24, 33, 34, 36, 37, 48, 50, 51, 61, 78) and owns the redesign. Read notes\02-raid-hud-redesign.md first; its Log says what has shipped and what it plans next. Take only what it does not list as done or NEXT. If you and 02 want the same element, leave it to 02. Look at git log --oneline -8 before every ship.
Already shipped since this job failed at 08:20 (git log; do not redo, and shoot new "before" pictures from the current build): v30.49 run info shows the 3 closest contracts (Q1), v30.51 demo hides credits, xp, stash and bag, v30.53 demo gun card hides item value and backpack hint, v30.59 ammo is the hero number, v30.62 resize hatch only on hover, v30.67 run info title is white, v30.73 one lime tab and a shorter demo gun card, v30.83 score label clear of the top edge, v30.87 flat hud bars, v30.93 calmer left feed, v30.96 score plate at the top, v31.03 flat hud panels, v31.17 vitals bars one width, v31.21 vitals bars 300 wide.
Critic now: 50 = 3; 19, 21, 22, 23, 33, 37, 48, 61 = 2; never judged: 20, 24, 34, 36, 51, 78.
Still yours: the follow-up pass on the screens 02 has finished, the critic on the six screens nobody has judged, and fixes for P0/P1 findings that are not on 02's list. Do not repeat the audit in notes\ui\hud.md.

## RE-QUEUED 10-18 night (coordinator)
- Why your camera and critic were refused: the command did not match the one exact form (most likely a different port, e.g. 9352, or extra bits on the line). It is fixed now: a trailing "2>&1" or "| tail -N" is allowed, and a refused command now tells you the exact form with your lane's port. Lane a uses -Port 9361, b 9362, c 9363. Take pictures and run the critic again.
- His new finish line (3.51 a): critic 4 for the raid, waiting, pause and run-over screens, and 3 for the rest. Screens already at 3 that are not one of those four are done.
- Your run count was reset. Start from your notes and do not redo shipped work.

Coordinator note 10-19 23:59: the runs of 22:55 and 23:05 only waited on c-02 and no longer count as tries (3 of 5 used). Parked in blocked/ on c-02-raid-hud-redesign: it comes back by itself when c-02 is finished. Next run: re-shoot the 15 HUD screens after c-02 and fix the P0/P1 findings that are not on c-02's list.

Coordinator note 10-20 01:00: c-02-raid-hud-redesign (the raid screen redesign on the same screens) ran out of tries at 00:31 and is parked until you end, so you own the raid HUD screens now. Read notes\02-raid-hud-redesign.md and notes\ui\changes.md for what it shipped (up to v32.25). Its open list: 37 one big extract timer (old banner checks need a retarget first), 61 the wheel's muddy focus wedge, 78 mixed 14px and 18px button text. Critic last: 19, 21, 36, 37 at 2; 50 and 22 at 3.

Coordinator note 10-20 01:55: CLOSED, superseded by c-02-raid-hud-redesign (same raid screens; it is back in tasks/ and running). Shipped here tonight: v32.35 cw-extbig, v32.36 cw-extscrim, v32.39 cw-extlegend, v32.38 cw-cardP35. Its open list moved to c-02.
