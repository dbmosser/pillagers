85b-emb-p2-drops-netslot : in itch's frame, player 2's address never carries the ?netslot test save (coordinator re-test of v33.59, 2026-10-21)
Queue (coordinator 10-21 03:55): found while re-testing 85a; his 10-20 23:00 order: nothing waits for the party.
After: 85a
If a job named in After is still open (in tasks/, waiting/ or running in a status file), end with TASK WAITING: its file name and what for.
effort: low

Source: tools/handoff/console/notes/coord-06.md, "Re-test of v33.59 and v33.60". netP2Url (dark_raiders.html, the v33.58 cw-p2bridge line)
keeps every part of the frame's own query on the embedded path except p2, mode, pair, arc and emb, so itch's ?v= survives (right). It also
keeps ?netslot=A or B. A window with ?netslot is never player 2 (var NETP2=!NETSLOT&&..., his v15.76 rule: netslot wins), so an embedded
test copy opened with ?netslot opens a player 2 window that boots as a second test copy and never links (raw-T4-framed-3360.json:
p2 NET.same '', no word reached player 1). With itch's own query it links in 1.8 s in Chrome and in Edge (raw-T4-framed-3360itch*.json).
Players never have ?netslot, so this is a test-path bug, but every helper's frame test uses ?netslot and would read it as "itch is broken".

1. On the embedded path only, drop netslot from the kept query, the way p2, mode, pair, arc and emb are dropped. The top level address stays
   exactly what it is (v33.58 promise). Nothing else changes: not NETSLOT, not NETP2, not the save keys, never salvagerun:profile.
2. Check (new, must fail on v33.6x before it): drive netP2Url with a stubbed embedded location carrying '?netslot=A&v=123' and assert the
   result keeps v=123, has p2=1 and emb=1, and has no netslot; and with a top-level location the result is byte for byte what it was.
   No timers, no browser windows: call netP2Url with the stubs (reportEmbedded and location are read inside it; give the check a seam if
   it needs one, as v33.58 did for netSameWatch).
3. Watch line: none for him (test path only).
