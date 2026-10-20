# 54-corpus-reds-c (lane c, 2026-10-20)

All 18 green on the rebuilt fixture (fixture commit a35c3910). No game change needed: nothing was REAL. None of the 22 of o-02 touched.

- v29.55: STALE. cw-pausegap/cw-pausefb: the pause stack is a wrapping row with full-line buttons and a 16px gap (no extra Abandon margin). Check wants column or full-line basis, and a 16px gap or margin.
- v29.61: STALE. Style guide: accent only for focus; run info headings read tx_1 and tx_2. Check accepts tx_1 or tx_2 and still fails on the old off-palette colours.
- v29.63: STALE. His Q43 keeps the near full screen card. Check wants a card inset 16px or more and even on both sides (Settings and Keys).
- v29.64: STALE. His 10-18 all lower case order (cw-pset7 removed the first-letter capital). Check now fails if the capital comes back.
- v29.67: STALE. Settings is now three panes (rail, list, detail beside). Check wants the detail beside the list.
- v29.72: STALE. The list is about 910 wide beside the rail and detail. Limit 830 to 960.
- v29.75: STALE. Same list width; stepper edge gap 41 against 40 (row padding), limit 48.
- v29.77: STALE. The section strip is a vertical rail. Check wants the tabs on one left edge.
- v29.80: STALE. Q43 near full screen card. Check wants the title and list inside the screen with a 16px margin.
- v29.94: STALE. cw-partylook6: labels never under 16px, so at scale 0.903 a label is 16, not 14.4. Check uses max(16, 16 x scale).
- v29.98: STALE. Ghost X has a clear border; Keys section labels are tx-2 (cw-keysclean). Check updated to both.
- v30.20: STALE. cw-title-sharp took the blur to 2px (his Q52 and Q54, 60 fps at 4K). Floor 4px to 2px; the hub label guard is unchanged.
- v30.24: STALE. cw-partylook8: the empty line is left aligned. Check wants left.
- v30.37: HARNESS. The box is 56 high by layout; the rect was read while the card scaled in (51). Check reads offsetWidth and offsetHeight.
- v30.91: FIXED SINCE (passes on HEAD).
- v30.97: STALE. cw-partylook9: no ring; the focused New party is one amber fill with an amber edge. Check wants that and no white.
- v31.04: FIXED SINCE.
- v31.67: FIXED SINCE.
