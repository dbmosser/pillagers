# shipkit: a backup of the ship pipeline scripts (copied 2026-10-18)

The live copies run from the coordinator session's scratchpad:
C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad
Every helper's RULES.md (tools/handoff/console/RULES.md) names that path. A session ending does not delete it, but a temp cleanup could.

If that folder is ever gone:
1. Make a new folder (the new session's scratchpad), copy these files into it, and replace the old scratchpad path inside every .sh here, and in RULES.md, with the new one (grep for 8a09e991).
2. The lock is S/shipq.lock (a folder) plus S/shipq.owner ("pid key time"). Only clearstale.sh clears a stale one.
3. shipq.sh KEY needs S/mk-KEY.ps1, which writes tools/handoff/drafts/draft-KEY.json. Three examples of draft makers are here (mk-cw-*.ps1).

What each does: shipq.sh queues one draft through the gate (it calls tools/handoff/shipone.sh; a copy is here); lock.sh / unlock.sh take and release the
shared lock (unlock refuses a running owner's lock); fixq.sh commits an edit to tools/mkfixture.ps1 and rebuilds the fixture (HELD=1 when you
already hold the lock); preflight-i.sh runs a draft on a private lane before shipping; genP.sh makes a What's New card draft; runchk.sh runs chosen
checks; corpq.sh runs the whole corpus; clearstale.sh clears a lock whose owner died over 30 minutes ago; governor.sh paces the helpers.

cardrefresh.sh [S] (2026-10-19): ships the next POLISH PASS what is new card refresh when WHATSNEW_VER trails VER by 0.10 or more (the card check fails past 0.15). codex-lane.sh calls it when a preflight or ship says the card is stamped behind; its template is mk-cw-cardP31.ps1 here.
