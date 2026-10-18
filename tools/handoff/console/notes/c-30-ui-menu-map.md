# c-30-ui-menu-map notes (run 2; run 1 lost its notes, pictures are in notes/shots/c-30-before)
Findings so far (from pictures 01, 25, 42):
- F1 Pause boxes (raid 25, hub 42, arcade 49): a line "Please provide feedback - tell us anything..." sits ABOVE a Feedback button = duplicate of one job + an explaining sentence on screen.
- F2 Title: "Create A new save" (capital A, sentence-case bug). Two "coming later" rows (2 player co-op server, PVP server) = dead ends taking the space of live rows.
- F3 Title mode order: 1 player / 2p co-op same machine / 2p arcade demo / 1p arcade demo / dead / PVP / dead. Party guest cannot tell which is the party game.
- F4 Hub pause: 6 buttons, wide row; raid pause: 5 buttons. Order differs (Settings 2nd both; Leaderboard only hub; What's new before Abandon).
- Settings modal: tabs Display/Rec/Look; Rec tab has "send it to Daniel" + restore code in a settings tab (odd section).
- ESC/B: backOut() -> escCloseTopModal0 finds [data-esc] / button#close* / #stageback / #carryclose / #askno else just removes .on.
