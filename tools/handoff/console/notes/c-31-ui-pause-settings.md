# c-31-ui-pause-settings notes (lane c, run 2026-10-19)

Shipped this run (pset12..16 = v31.63 to v31.75): left rail tabs, settings card with rail + list + detail pane, stepper box only on focus, keys table two column pairs with 16px section names, focus row = raised fill + 4px lime bar, pause box feedback / what's new row + quiet abandon, X without border until hover, lists fade at the bottom, detail pane full height.
Pictures: shots/c-31ab-before (start), c-31ag-after (end). Critic scores at the end: 72 = 3, 25 = 3, 74 = 3, 42 = 3 (all "same" or "better" than before, none reached 4).

## Stuck, in order of what the critic repeats (next run starts here)
1. Settings 72: detail pane is a huge empty box. Needs a hero value readout (56px, current value in lime) under the 32px title: JS in setDetailSync, not CSS. Or narrow the pane to ~420px (list then wider, so the stepper cluster must be right-aligned: chevrons 20px, value cell 160px, button flex:0 0 fixed width). A check from 31.61 wants the detail strip fill rgb(30,34,37), so do not set --ui-raised on it.
2. Settings list clip at the footer: snap the list height to whole 56px rows (JS sizing in pauseFrameFit style) and a 6px scrollbar thumb inset 8px.
3. Keys 74/75: no pad focus is visible in the staged shot. The staging in tools/handoff/shots/ui-screens-js.json (screens 74, 75) must set a padfocus on the first chip (add via questions.md ask, rules forbid editing that json). Key caps as raised keys, label column 360px, section bar 3x16px, locked group sentence dropped (Q70 no explaining sentences; Q8 reason needed in changes.md).
4. Pause box 25/42/49: critic wants report a problem + feedback + what's new as one row of three 40px, abandon as a 40px bordered button. An older check ("abandon still has a box") blocks the border; retarget it with fixq.sh first. Report field is a textarea, so a row of three means moving it. Q61 allows moving. Also scrim .80 and a visible pad focus ring on pause buttons (check how the pad focus class draws there).
5. Stray 36x2 lime tick at the card top-left on every window: critic reads it as a glitch. Find which rule draws it (a ::before on .modal and the pause box) and make it a deliberate 3x36 tab or remove it. One shared rule, so one ship.
6. Left rail: idle items 20px tx-2, send play data as a divided utility link.
Not looked at this run: 26-31, 49, 68-71, 73 individual scores (they share the settings CSS, expect the same findings as 72).
- 2026-10-19 run 5 (lane c, VM): BLOCKED again. Write of mk-cw-pausebtn.ps1 refused at the VM scratchpad path. Nothing shipped. Script fully drafted (see run 4 plan; css anchor now html line 2081; fbbtn/wnbtn/abandon min-height btn-h-sm, margin-top sp-3; check scans document.styleSheets for the btn-h-sm rules). Needs the write permission on the VM scratchpad path.

--- coordinator 2026-10-19 22:00 (VM) --- Requeued with fresh tries. The VM save block is FIXED (6dc93534): mk-cw-* writes to the scratchpad work again (the lane rules now also name the VM real path). v32.01 (the plain party demo) was committed and pushed by the coordinator at 21:4x; tools/publish exists. Carry on from your plan.
