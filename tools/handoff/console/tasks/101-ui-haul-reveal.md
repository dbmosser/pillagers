# 101-ui-haul-reveal : the haul reveal after an extraction, which the critic still scores 2, reaches 3 (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 11:20): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
newly failing checks are handled, the robots found no problems and no checker lead is confirmed, so this is the next known work:
screens the critic scored under their target. 99 and 100 took four Undercroft screens from 2 to 3 the same way today.

His answers: career screens get polished too (56); restyling an existing screen needs no mockups (53); the style guide beats the
judge's taste and his taste beats both (54, 22). Finish line (3.51 a): critic 3 for this one (it is not a raid screen). No queued,
failed or cut job lists it. The player sees it after every extraction, so it is worth the care.

Screen (name as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 76-haul-reveal-mid (target 3). Judged 10-19 23:10 at 2: "reads clean at a glance but contradicts its own success check and is
  missing half the component polish the style guide requires". Five days old: start from a fresh picture and a fresh critic score
  on HEAD; if it already meets 3, record it and stop.

Rules:
- Read notes/ui/style-guide.md and shared-style.md first. All player text lower case, short, no explaining sentence, $ for money
  and SP for score. Log any reworded or removed line with its reason in notes/ui/changes.md (Q8).
- Layout and look only: do not change what the haul pays, how it is counted or how long the reveal takes. No new controls.
- Rendering and HUD only: no change to the simulation, saves or the storage key. Coming back dead or abandoned still shows an
  empty haul (his rule), so look at that state too.
- Work it through pad focus too (a visible focus ring on the continue action), since couch play is career (his note on 76).

Checks (each must FAIL on the old build): measured layout facts you fixed (for example the reveal and its success line agree, one
primary action drawn in lime with a focus ring).
Pictures: camera-recipes.json with the screen at 1080p, then the critic.
TASK DONE when it reaches 3 from the critic (never your own grade) or is stopped at 6 tries with its best two versions noted;
TASK PARTIAL with what is left.
