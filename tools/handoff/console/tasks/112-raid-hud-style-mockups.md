# 112-raid-hud-style-mockups : three picture mockups of one shared panel style for the raid HUD, for him to pick from on his phone (coordinator 2026-10-24)
Queue (coordinator 10-24 17:20): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). Feed
order: a screen the critic scored under 4. This is the critic's most repeated point, on twelve raid screens at 2: 19, 20, 21, 33, 36, 37,
47, 48, 51, 61, j7-raid-p1-pad-owner, j8-p1-sees-p2-lost. In its words: "a pile of mismatched boxes fighting each other for the eye",
"the score, minimap, vitals and ammo panels share no common panel, type scale or padding", "the left log is a stack of mismatched pills".
effort: high

Why mockups and not a ship: jobs 102, 103 and c-02 each shipped HUD changes and the scores stayed at 2. Job 103's notes end: "one panel
style for tags, the left tag stack and the hint strip ... Needs a fresh design pass with 2 or 3 mockups he picks from", and his 10-19
order is that redesigns go by mockups he picks (memory: pillagers-orders-2026-10-19). He is away until Sun 10-25 evening and answers
picture questions from his phone.

Make three mockups, each a different answer to "one panel style for every raid HUD widget":
- A. quiet: every widget is the guide's Panel P (notes/ui/style-guide.md, Components) at one padding and one radius; tags and the left
  log rows are the same panel at chip height; one type scale (hero, label, body from shared-style.md).
- B. bare: no panel behind the low-priority widgets (run info, left log, hint strip): text on a soft shadow only, Panel P kept for the
  hero (ammo) and the vitals; one type scale.
- C. one rail: the corner widgets join into as few panels as the layout allows (his 10-18 placement stays: top-right column, minimap top
  right, ammo bottom right, left log), one shared fill, border and padding.
Each keeps every line it shows now: no widget removed, no feed row removed (his 10-15 feed-all order, question 91 open), the controls card
kept on (it waits on his answer about the key legend), no new readouts. Both windows (P1 amber, P2 cyan) look the same apart from colour.

How: draft each as its own mk script applied to a scratch copy only (a draft page like the tools/fxdryNN.html pages preflight builds),
served on a test port (8803 to 8810, never 8802). Never ship a mockup; never edit dark_raiders.html; keep the three mk scripts so the
picked one can ship later.
Pictures: for each of A, B and C plus the current build, screens 19-raid-hud-drop-first-raid, 33-raid-fight-alerts and
37-raid-extracting-countdown at 1080p (camera-recipes.json). Put them in notes/shots/112-mockups/<A|B|C|now>/ and run the critic on each
set, writing its scores in notes/112-raid-hud-style-mockups.md (not in accept.json: they are not builds).
Write in the notes, per mockup: one line in plain words a non-coder can read, which shared draw functions change (hudPanel, hudPlate,
the toast and tag drawing), and what a player would see differently.

Rules: read style-guide.md, shared-style.md and notes/ui/end-cards.md first. All player text lower case. Rendering only. 2.5D canvas only.
Never test on port 8802.
TASK DONE when the three mockups and the current build are pictured on the three screens, critic-scored and written up; the coordinator
puts the pick in front of him. TASK PARTIAL with what is left.
