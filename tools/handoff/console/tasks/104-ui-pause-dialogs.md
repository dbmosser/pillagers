# 104-ui-pause-dialogs : the four pause boxes the critic holds at 3 reach 4 as dialogs (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 13:30): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
newly failing checks are handled, the robots found no problems and no checker lead is confirmed, so this is the next known work:
screens the critic scored under their target. c-31 (pause and settings, 20 screens at once) failed on its size; this is only the
four pause boxes.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json), all at 3, target 4:
- 25-raid-pause-box (10-20): "a small 480px box on a 1920 screen, with a mismatched button stack and a dead gap above a tiny abandon link".
- 78-raid-pause-box-full-kit (10-20): "a small box on a very dark screen, with no pad focus state shown and no run info".
- 42-hub-pause-box (10-19): "the buttons are weakly graded, the secondary row is tiny, and the card does not follow the near-full-screen
  window rule".
- 49-arcade-pause-box (10-20): "the card is small and generic, and it breaks the rule that windows are a big centred card".

The size complaint is the critic's mistake, not yours to fix: notes/ui/style-guide.md (Window, his Q43) says a DIALOG (ask, confirm,
pause 480, end card 720) is NOT a window and stays a small card sized to its content; the style guide beats the judge's taste (his 54).
Keep the pause boxes dialogs. When you run the critic, give it the guide's dialog rule with the picture, and record any score it
still docks for size with that reason.

Fix what the critic is right about, within the dialog:
- one button stack with one graded order (the lime primary, then ghost secondaries at the guide's size, then the red abandon), no
  dead gap, no tiny link or tiny secondary row;
- a visible pad focus ring on the focused button in every pause box (couch play is career, his note on 76);
- the four pause boxes share one layout (raid, raid with full kit, hub, arcade) where their buttons allow.
Do not add run info or anything new to the pause box (no new controls, no new readouts: one control per job).

Rules: read style-guide.md, shared-style.md and notes/ui/pause-settings.md first. All player text lower case, short, no explaining
sentence; log any reworded or removed line with its reason in notes/ui/changes.md (Q8). Rendering only: no change to the simulation,
saves or the storage key; pausing works exactly as it does now.

Checks (each must FAIL on the old build): the measured button heights and order in each pause box, a focus ring box drawn on the
focused button with a pad, no gap over N px between the stack and the abandon button.
Pictures: camera-recipes.json with the four screens at 1080p, then the critic.
TASK DONE when each reaches 4 from the critic (never your own grade), or the fixes shipped and the scores are written with the reason
for any point docked for size; TASK PARTIAL with what is left.
