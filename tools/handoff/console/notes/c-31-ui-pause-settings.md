# c-31-ui-pause-settings (lane a/b)
Run 1 shipped: v30.03 card P16, v30.05 cw-setnote, v30.09 cw-setname.
Run 2 shipped: v30.13 cw-sethint (key-hint line, 98% backdrop), v30.15 cw-sethint2 (hint 20px, 24px fade, row air).
Run 3 (lane a) shipped: v30.17 cw-setvis (pane follows rows in view), v30.19 cw-setvis2 (pane skips rows under the sticky tab strip: it named a Controller row after the Display jump), v30.21 cw-setsechd (section label rows are bare anchors, no 13px label repeating the tab). Old 30.17 check retargeted (1c85cb44).
Critic scores (never mine): 18:3, 25:3, 72: 2 -> 3 (run 3), 74:2, 75:2, 26/32/42/49:3. 27-31, 68-71, 73 share the shell of 72/74 and were not scored separately.
Critic contradicts itself: asks for a 55% dimmed world and also hide HUD; asked to remove the Display label, then asked to restore it; near-black backdrop called a loss. Stuck (no rise after 2+ follow-ups):
- no pad cursor in staged shots so focus state shows only as hover look.
- key hint is ::after text, a real keycap needs an element/JS; pad glyph swap by last input.
- pad button labels wrap (3 lines) - shortening is wording, not touched.
- 4px scrollbar; "Send play data" chip sits in tab strip (moving it changes his layout).
- Pause box: five equal buttons; critic wants Feedback/What's new as list rows and Abandon as a link (would move his buttons; not done).
- Row type 18px vs critic's 20px, stepper 400px from label, list cut by detail pane at a half row: next try = row names 20px, snap list height to whole rows (6 x 56px), chevrons 32px hit areas amber on focus.
Run 4 (lane a): no ship. Re-shot the current build (shots/c-31y-before) and re-ran the critic on 72 (3) and 74 (2). Same findings as before, all in the stuck list. Row names are already 20px (--fs-body) and rows 56px, so that item is done. Still open: whole-row snap of the list, pad focus staging for 74/75, keycap elements, pad glyph chips. Each of these needs a layout choice or a staging change, not a CSS tweak.
Next run (if any): those three, then keycap elements for hints, a pad-focus staging for 26/74.

## 2026-10-18 evening (coordinator): the stuck items are settled
- Moving the Send play data chip and re-ranking the pause box buttons: allowed (Q7, the guide overrules his older layout orders), but Q61 still binds: keep the feedback line, the feedback button and Send play data.
- Shortening the pad labels that wrap to three lines: allowed (Q8), with the reason logged in notes\ui\changes.md.
- Settings and Keys are a centred card with an X, nearly the entire screen (Q43; v30.89 shipped the card). Q59: $ for money, SP for score.
See the RE-QUEUED block at the end of the task file.
