o-91b-report-news-style : the public news window and the report recorder reach the finish line of 3 (coordinator 2026-10-21 01:58)
Queue (coordinator): split from o-91 (its goal shipped in v33.43 and v33.49; this style pass did not). Codex lane o.
effort: medium

Source: tools/handoff/q-round3/answers.md 3.51: "a: 4 for the raid, waiting, pause and run-over screens; 3 is enough for the rest"; his
10-20 23:00 order: "quit queuing stuff for after the party -- just do it all as it naturally arises".
Not done (coordinator, 10-21): tools/handoff/console/notes/ui/accept.json scores 91-public-news-window 2 and 91-public-report-recorder 2
(need 3). o-91 wrote but never shipped the key cw-cx-reportnewsstyle: its mk script is
C:/claudecode/pillagers-codex/.codex-work/o-91-circle-only-text/mk-cw-cx-reportnewsstyle.ps1 (CSS only: caps the raw preview, makes copy
the primary button, shared text sizes). Its critic findings are in accept.json under those two names.

1. Start from that mk script; check its anchor still matches exactly once at HEAD (the file moves fast).
2. Act on the critic's findings for the two windows. CSS and layout only: keep every word, every button and what copy and restore do.
3. All lower case, short labels, no explaining sentences, the shared style guide (notes/ui/style-guide.md).
Check (new, must fail on the build before): with the report recorder open at 1920x1080, the raw preview box is at most 240 px tall and
the copy button is the filled primary button; the news window uses the shared body size. The seed 4242 fingerprint holds.
Pictures: both windows at 1080 and 4K, before and after; run the critic on the after pictures (both names above).
Party risk: none (menus outside the raid). Watch line: "the news and report windows look tidier; copy still copies the whole report".
Size: one ship.

TASK DONE when shipped and both windows score 3 or more; TASK PARTIAL with what is left.

Lane note 2026-10-21 02:43: shipped cw-cx-o91b-newsreport and parked: only lane-side steps are left. Codex's last words:
Reviewed both pictures and updated the pending CSS with brighter, wrapped log text and a 6px scrollbar. Local validation passes. Scores remain news 2, recorder 3; the layout fix has not shipped.

TASK PARTIAL: shared ship recovery is still required, followed by the deferred key and 1080p/4K critic reviews.

REQUEUED 10-21 03:08 (coordinator): the stuck cw-pixground v33.57 is cleared (the tree is back at v33.56, and a late STOP now undoes itself), and cw-cx-o91b-windowlayout is back in keys.txt. Left: preflight and ship it, the 1080p and 4k pictures of both windows before and after, both critic scores at least 3.
