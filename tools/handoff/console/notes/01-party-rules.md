# 01-party-rules (lane e) notes

"Demo" in code = ARCADE (ARCADE.on, G.arcade). Title rows in dark_raiders.html ~2360.

## Shipped (all with a check; preflight PASS then SHIPPED)
- Q72 v30.25 cw-nopvp: both PvP rows hidden on the title (kept in the DOM, display:none, arrows skip them)
- Q21 v30.29 cw-tvtext: ARCADE_SBX uiScale 1.5 + menuZoom 1.25 (HUD size 150 percent); his own size comes back on leaving the demo
- Q65 v30.33 cw-bothout: in a live 2P run the first extractor stands out (host: benched, ARCADE.xOut 'h', cannot unbench; P2: arcx while host plays sets xOut 'p'), the second extraction doubles both and ends the run. P2 that extracted stops sending its body. LIMIT: a 2P death still respawns (feat0f ruling), so "dead" does not take a player out; the run also ends on END RUN or the idle out.
- Q62/Q63 v30.36 cw-iniplayer: the initials card runs twice in a 2P run (Player 1, then Player 2, row.i and row.i2, board shows "ABC . XYZ"); ARCADE_INI_RUDE list refused on done (letters reset, "Pick other initials"), ??? on a timeout
- Q29 v30.42 cw-pausehold: an open pause box counts as activity in arcadeOwnAt, so a long pause never idles/benches/ends the demo
- Q71 v30.45 cw-noliverank: arcadeHiTick (mid-run NEW HIGH SCORE) is off; a window out of a live run skips the board page (arcadeAttLive)
- Q67 v30.47 cw-partykit: the two random guns live in the party record (kit {a,b}); arcadeKitApply uses them, NEW PARTY draws the next pair
- Q70 v30.50 cw-notutor: arcadeCardOn returns 0 (no controls card at the drop), shield tag is just "Shield". HOW TO PLAY attract page and F1 keep the rows.
- cw-cardP19 v30.39: What's New card stamp refresh (needed to unblock the ship)

## Q30: no ship needed
v25.xx (demosettings) already shows #pausesetbtn in the demo pause box (togglePauseBox sets _psb.style.display=''), and it opens the same Settings screen as a career raid. Restore code, backup file and tuning console are greyed in ANY raid (career too), not demo-specific. Nothing to change.

## For corpus triage (old checks that these changes make stale; not in the gate's newest 80)
- title mode rows: mkfixture ~58526 / 58530 (ArrowDown/Up land on the pvp row)
- arcade18 (v23.41) NEW HIGH SCORE mid-run; arcade9 (v23.30) shield tag "SHIELD . MOVE TO START"; arcade19 (v23.42) controls card at the drop; arcade2 random kit varying per drop
- v24.90 (feat0g) arcx case still passes because its host has no live teammate (arcadeMateLive false)
