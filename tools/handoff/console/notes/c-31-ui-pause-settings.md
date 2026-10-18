# c-31-ui-pause-settings notes (run 2026-10-18 night, lane c)
Shipped: v31.49 cw-pset8, v31.54 cw-pset9 (see ui/changes.md). Critic after: 72 = 3, 25 = 3, 74 = 2 (no gain over 2 follow-ups).
Stuck (the critic repeats these every round):
- Settings 72/18: wants a wider list (1400) or left tab rail; conflicts with Q43 / cw-cardwide2 (label next to stepper, 960 column). Next try: left category rail 280px (needs a layout change in openSettings tabs), snap list to whole 56px rows, 20px arrows.
- Pad buttons 74/75: no chip is focused in the shot (needs a pad-focus staging entry in ui-screens-js.json, ask in questions.md), locked line still cut by the scroll end, wants 16px sub-label for "(hold: ...)" text.
- Pause 25/42/49: wants report/feedback/what's new as a row of three quiet buttons, resume with esc hint, focus outline. Not done.
Never judged yet: 27-31, 68, 69, 71, 73.
