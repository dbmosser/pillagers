113b-end-cards-and-window-reds : ten checks newly failing on v34.53 on the end cards, Wirt and the party window pass again
Queue (coordinator 10-24 21:10): the full test run corpus-1024-1829 on v34.53 has 46 failing, 40 newly (14 on v34.18); split by
screen so the helpers work them at once after the reset. Feed order: checks newly failing in the newest full run.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 19:51). Run file:
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1024-1829.txt
Your FAIL lines (check -> what it saw):
- v29.95 end cards title and loss tiles -> "the card title is 32px, not 40px; a loss tile is 80px, not 72"
- v29.83 killed in action card -> "a tile is 80px, not 72"
- v29.53 end card hero total and quiet feedback -> "the feedback prompt still has a box"
- v21.00 the two boxes at wirt are one width -> "the two boxes start 847.1 px apart"
- v9.94 wirt has two counters -> "neither outline nor left edge distinguishes the two sections; the two sections are -685 px apart"
- v31.62 terms, party, gamble and bar windows draw the 90 percent card -> "partymodal frame is 960 x 320 at 1044,540 in a window
  2089 x 1080, not the 90 percent card; partymodal frame is shifted by matrix(1, 0, 0, 1, -481.102, -161.102)"
- v20.00 the party frame clears the corner readout -> "the Party frame does not keep its five percent vertical insets"
- v19.42 party window trading line -> "the TRADING line starts left of the window text"
- v32.22 party intro one short line -> "party msub 16px"
- v32.82 invite code keeps its case -> "the paste box placeholder does not name the code as it looks: invite code"
Likely ships: v34.32 end cards (32px title, tiles under the loss, ghost feedback button), v34.34 and v34.36 wirt window and panels.
His rulings to weigh: a WINDOW is the 90 percent card, a DIALOG stays small (his Q43; style-guide.md). The party window is a WINDOW.

Steps:
1. Run each check alone on the current build; drop any that pass (the run went short on memory at times, two robots at once).
2. For each left, find the ship that broke it (git log v34.18..HEAD; the last full run where it passed was corpus-1023-2304 on v34.18)
   and say which of two it is:
   a. the game really broke (a player sees it wrong): fix the game in an mk script;
   b. a newer ship changed the screen on purpose (a critic job, his later order) or the check reads an old layout: re-aim the check at
      what the screen draws now and name the ship and the order in the DESIGN.md section. Never loosen a check just to make it pass;
      where a newer critic change goes against one of his own orders named in the check, his order wins: fix the game back.
3. One batch per cause, through preflight.sh and shipq.sh as usual. For anything a player sees, take pictures (tools/uishots.ps1) and look.
Pictures: the extract, killed in action and abandoned cards, Wirt and the party window at 1080p, both windows.

TASK DONE when the ten pass on the drafted build or are fixed in a shipped batch; TASK PARTIAL with the ones left and why.

--- COORDINATOR 2026-10-24 21:25: step 1 is done for you. Each check was rerun alone on v34.53 (fresh tab of the corpus Chrome, as a full-run slice runs it).
All ten fail alone (real): v29.95, v29.83, v29.53, v21.00, v9.94, v31.62, v20.00, v19.42, v32.22, v32.82.
--- COORDINATOR 2026-10-25 01:45: causes found for all ten (read-only search, each finding checked by a second reader; line numbers
are as of v34.55, so grep again). Two are real game breaks, eight need the check re-aimed.
a. FIX THE GAME (v34.22, 36fca4824, cw-wpcard, job 100): v31.62 and v20.00. dark_raiders.html about line 884
   `#root #partymodal.ui-win:not(#zz1):not(#zz2)::before{ inset:50% auto auto 50%; width:min(960px,...); ...transform:translate(-50%,-50%) }`
   has 4 ids and beats the 90 percent card at about line 2084 (3 ids), so the party window became a fitted 960 card (height from the
   CARDFIT 320 floor). His Q43 ("centred card with an X, taking up nearly the entire screen") and style-guide.md line 62 name party as a
   90 percent WINDOW; job 100 said so too, and changes.md about line 379 shows the helper followed the critic instead. One mk script:
   remove the party parts of about lines 880 (the #partymodal selector), 883, 884 and 885 so 2083, 2084 and 2086 apply; keep the lime
   host and the one line field and let the content fill the card; re-aim check 34.22's "fitted 960 card" assert (mkfixture about line
   6944) at the 90 percent card, naming Q43. v20.00 then passes with no check change. Pictures: party window at 1080p and 4K, both windows.
b. RE-AIM, v34.32 (3a5f642ef, cw-endcards2; style-guide.md line 74, end cards: title --fs-title 32, one primary + one ghost). The old
   numbers were critic asks (cw-endcard-clean), never his order, and check 34.32 itself contradicts them:
   - v29.95: expect the 32px title and the 80px loss tile; keep the 24px loot line half.
   - v29.83: expect the 80px tile (mkfixture about line 22440); keep the 56px figure, hidden lost lines and one row parts.
   - v29.53: the feedback prompt is now the one ghost (1px --ui-line-hi border, transparent, not lime) instead of no border (check 34.32
     fails when it has NO border). Keep the 56px hero and .9 scrim halves.
b. RE-AIM, v34.34 (c5400ac5d, cw-gamblecard: the gamble and offer panels side by side, filling the card):
   - v21.00: keep the same-width test; replace the same-left-edge test with the same top edge when the two share a row.
   - v9.94: v34.34 dropped the offer's lime left tab on purpose (changes.md about line 390, "so gamble is the one lime"; lime is the one
     primary). His 09-03 note asks only for "a more clear delineation"; today the two are bordered panels with their own 20px labels and a
     24px gap. Keep "each section has its own solid border" and the head text test; replace the colour/edge test with "each panel opens
     with its own visible label at 19px or more and the two do not overlap"; measure the clear air on the split axis (ro.left-rg.right>=8
     side by side, ro.top-rg.bottom>=8 stacked). Name v34.34 and changes.md. (The first reader called this a game break; the second
     refuted it.) Tell him to look at the side by side wirt window in his next playtest.
b. RE-AIM, v34.22 again (logged in changes.md about line 379):
   - v19.42: the trading line is hidden on purpose (`#partytrade{ display:none }`, not a party action), so its box is all zeros; test the
     line only when it is shown.
   - v32.22: party .msub is 16px on purpose (about line 887); expect 16.
   - v32.82: the paste box placeholder is now "invite code" (all lower case, his voice order); the check still wants "PTY1o" (mkfixture
     about line 12586). Re-aim it to the placeholder naming the code ("invite code") and keep the keeps-its-case test.
