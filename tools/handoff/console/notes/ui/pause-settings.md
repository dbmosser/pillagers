# pause-settings (c-31-ui-pause-settings)
Before shots: notes/shots/c-31-before (screens 18,25,26,32,42,49,68-75, 1080).
Code map: .pausebox CSS at html line ~714 (old look: rgba(17,19,21,.9), h3 25px uppercase-class, gap 11px); .modal at ~720 (padding 22px).
Settings = #settingsmodal, #setwrap > #setlist + #setdetail; openSettings(tab) at ~64242.
Shared look: <style id="ui-shared"> ends at line ~1401, tokens --fs-*, --sp-*, --rad, --btn-h*; the check 29.33 forbids raw color/px literals inside ui-shared (only 1px/3px allowed).
Pattern to copy: S/mk-cw-uishared-board.ps1 (append rules before </style> of ui-shared).
Before pictures: pause box (25, 42) = small panel mid-screen, "Paused" title 25px amber, key chips line, 6 buttons in one row, wasted panel height.
Keys window (32): 2-column rebind grid with huge empty space right, intro text 2 lines duplicated.
