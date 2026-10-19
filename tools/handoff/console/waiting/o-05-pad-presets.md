o-05-pad-presets : controller layout presets for the party (HIS ORDER 2026-10-19, coordinator job)

His words: "really good controller support ... several preset controller configs, e.g. one for people who are familiar with Minecraft,
one for people who are familiar with Call of Duty". Then: "this game is 2.5 D so I think it always needs to be twin stick".
So every preset keeps the left stick for moving and the right stick for aiming. A preset only moves buttons. The one exception is
lefty, which swaps the two sticks (it is still twin-stick).

Research with sources: tools/handoff/pad-research/presets-and-aim-assist.md. Use its "Preset tables" exactly (each column is a
permutation of the 16 pad actions, by logical action -> physical button).

Build:
1. PAD_PRESETS: six named presets as P.padmap permutations, in this order and with these names (game text, lower case):
   pillagers (the default, no remap), call of duty, fortnite, arc raiders, top-down, lefty.
   Action 11 (RS click today: focus toggle; the crowbar later) is simply moved like any other action. Do not add new actions.
   Use padBind's rules: every preset is a full permutation, so no button ever holds two actions.
2. Stick swap for lefty: a profile field (for example P.padSticks='swap') that swaps axes 0,1 with 2,3 wherever the RAID reads the sticks.
   That covers pollPad (about line 18259 / 18405, where padLogical is applied), and the same-PC hand-over of the other window's
   pad (about line 54914) if it carries axes. Menus, the title, the attract and the Undercroft keep reading the pad as it is,
   like padLogical today. Only the lefty preset turns the swap on. Picking any other preset, or reset to defaults, turns it off.
3. The picker: one "layout" row at the top of the existing CHANGE PAD BUTTONS screen (keysOpen(true)). The row shows the
   preset name, and left/right (D-pad or left stick) or LB/RB changes it. Picking one applies it at once and saves the profile.
   If the player then rebinds a single button, the row reads "custom". One control per job: this row is the only way to pick a
   preset, and the per-action REBIND list below it stays as it is. The whole screen must work with a pad alone. Check that every
   control is reachable and that B backs out. Reaching the screen from the pause menu and from the title settings with a pad
   alone must work too. If it does not today, fix that path.
4. A picture of the pad on that screen: a simple drawn Xbox controller outline, with every button labelled by the action it has
   in the current layout (lower case, short: "roll", "crouch", "reload / search", "ring search", "belt -", "belt +", "focus",
   "fire", "backpack", "pause", "sprint", "focus toggle" or "melee", "ping / map", "item wheel", "aim -", "aim +"). It updates
   live when the layout changes. Show the sticks as "move" and "aim", swapped for lefty. No tutorial text. Keep it legible at 1080p.
5. Each window (P1 and P2 on one PC) has its own profile, so each player's layout is their own. Confirm this with two windows.

Checks (each control must FAIL on the old build):
- PAD_PRESETS has 6 entries. Each is a permutation of 0..15 (no repeats), and applying "call of duty" puts action 5
  (next belt slot) on button 3 (Y), action 13 (item wheel) on button 5 (RB) and action 3 on button 13 (D-down).
- In a raid with "call of duty" applied, a stubbed pad pressing physical Y moves the belt to the next slot, and physical RB
  held opens the item wheel. Under "pillagers", physical RB moves the belt.
- "lefty": a stubbed pad with the RIGHT stick pushed up moves the pillager up, and the LEFT stick aims. Under "pillagers"
  the left stick moves.
- The layout row cycles all 6 names with D-right, and "custom" shows after one REBIND. Reset to defaults gives "pillagers"
  and stick swap off.
- The pad picture's labels follow the layout. Under "fortnite" the label at RS click is "crouch".
- A save without the new fields loads as "pillagers" with no swap.
Pictures (camera, your lane's port): the CHANGE PAD BUTTONS screen under pillagers, call of duty and lefty at 1080p, before and
after. Critic 4 (his 10-18 bar).

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left. Later jobs (not this one): aim assist (o-06), and a
layout chip on the pre-raid page once task 22 ships.

Coordinator note 2026-10-19 13:10: SHIPPED v31.84 (07ef7356). The lane died before the pictures (my edit to codex-lane.sh while it ran). Left: AFTER pictures of the CHANGE PAD BUTTONS screen (pillagers, call of duty, lefty), critic 4, and the two-window check. These are lane-side steps: when this job goes back to tasks, only those remain. Do not rebuild the presets.
