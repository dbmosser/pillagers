# 116-ui-demo-raid-hud : the party demo's raid screens (drop, move to start, reinforcements alert) read as one designed hud (coordinator 2026-10-25)
Queue (coordinator 10-25 07:30): keeps three jobs waiting for the helpers (the check-in's feed order). Feed order: a screen the critic
scored under 4. Every guest at the Fri 10/30 party plays the demo raid; these scores are from 10-18, before the hud ships v34.24 to
v34.68, and no job has looked at them since.
effort: medium

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 47-arcade-drop-controls-card 2: "the hud is crowded with mismatched panels, type sizes and styles, and the pad focus and hierarchy
  are unresolved".
- 48-arcade-hud-move-to-start 2: "the controls panel buries the start prompt, and six different type sizes, mixed panel styles, and
  washed-out low-contrast text break the guide".
- 51-arcade-alert-reinforcements 2: "pillager reinforcements shows twice (top pill and left log), the left log is a stack of mismatched
  pills".
- Keep 50-arcade-hud-live (3), 20-raid-hud-drop and 21-raid-hud-calm from getting worse: the demo and the career raid share this hud.
Targets: 3 for each. Start with fresh pictures and a fresh critic score on HEAD; if a screen already meets 3, record it and stop on it.

Fix, in this order:
1. Overlap is a defect: if anything still covers the start prompt in 48's state, or any hud text meets other hud text in 47, 48 or 51,
   fix it with a check. (The demo folds the controls list at the start since v34.54, so 48's old finding may be gone: picture first.)
2. HIS RULING rs-2 (10-25, "2 a"): the same alert shows both as the top banner and as a log row. Keep both. Tell the critic it is his
   ruling with every picture, and never count that finding against the target.
3. Then the critic's points the guide agrees with: one panel style and one type scale for the corner panels (style-guide.md,
   shared-style.md), lower contrast text raised to the guide's text tokens. No new readouts, no new controls, no moved panels that his
   rulings placed (rs-1: the controls list mid bottom left, folded, f1 opens it).

Rules: read style-guide.md and shared-style.md first. All player text lower case, short, $ for money, SP for score; log any reworded or
removed line with its reason in notes/ui/changes.md (Q8). Rendering only: no change to the raid's rules, waves, score or the storage
key salvagerun:profile. Both windows look the same apart from their colour (P1 amber, P2 cyan, his r3-13 answer).
Checks (each must FAIL on the old build): the one you write for step 1, and for step 3 that the corner panels share one fill and one
border at 1080p.
Pictures: camera-recipes.json with 47, 48, 50, 51, 20 and 21 at 1080p, then the critic.
TASK DONE when 47, 48 and 51 reach 3 from the critic (never your own grade), or the fixes shipped and the scores are written with the
reason for any point left, and 50, 20 and 21 are not lower; TASK PARTIAL with what is left.
