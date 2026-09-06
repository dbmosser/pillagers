# START HERE (written 2026-09-05, handoff from Fable to Opus)

HEAD is v11.49 (109d380). The tree is clean. Fourteen builds are fully drafted
and DRY-RUN GREEN in order on scratch copies (every anchor applies, end state
parses as v11.63): p/f/d/a/cm 1150 to 1163 in this folder.

## What each draft fixes (all from the v11.46 read-only audit in AUDIT.md,
## section "STILL OPEN, found 2026-09-05")

- 1150 closing the Undercroft backpack overwrote loadout edits made at the Mainframe (P0)
- 1151 my v11.42 sector-line pattern regression (wrong map name printed) (P1)
- 1152 Wirt Buy sold the clock-at-click lot, not the shown lot (P1)
- 1153 a merc who boards an earlier extraction was never paid (P1)
- 1154 the outcome card printed base XP while the profile banked more (P1)
- 1155 byPlayer never cleared on revive: a saved pillager was still your kill (P1)
- 1156 tags and a note chosen after Copy report were dropped (P1)
- 1157 the restore code left the armoury behind (P1)
- 1158 the restore code was blank for a name above U+00FF (P1)
- 1159 the notoriety banner said the Peddler was done with you (P2)
- 1160 belt drop on the stash said back in the backpack (P2)
- 1161 with pillagers None the extraction-heat row read CUSTOM (P2)
- 1162 [+] on a collapsed pillager board started an invisible resize (P2)
- 1163 a note typed in the pause box on the floor rode into the next raid (P2)

## The per-build procedure (one build at a time, never two)

Servers first: powershell -ExecutionPolicy Bypass -File tools/start-servers.ps1
(:8802 is his PLAY port and shares his profile: NEVER test there. :8800
serves the tools folder: fixture.html, parsecheck.html, fx<prev>.html.)

1. Dry-run what is left before each ship (uses copies, touches nothing real):
     powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/dry.ps1 1150 1163
2. Start the build (applies p and f, rebuilds fixture.html and fx<prev>.html,
   inserts d into DESIGN.md and a into AUDIT.md):
     bash tools/handoff/ship.sh start 1149 1150
3. In the Browser pane (resize_window 1920x1080 first; a fresh pane is 0x0):
   - http://localhost:8800/parsecheck.html must show PASS v11.50 in its title.
   - http://localhost:8800/fixture.html: find the corpus array (window key
     whose value is an array of {v,what,run}), run the entry with v==='11.50',
     require null (PASS). Then run __verifySafe() and require summary PASS:
     ents 85/374, containers 165/593, parity identical, loot both maps, the
     three endings EXTRACTED / KILLED IN ACTION / ABANDONED, hub.
   - http://localhost:8800/fx1149.html: run the same 11.50 entry; it MUST
     return a failure string (the control). A PASS there means the check
     does not test the fix.
   - Back on fixture.html: __regressBg() then poll window.__PROG every few
     minutes ({done,cur,finished,res:{pass,checked,fail,skipped}}). It takes
     nine to ten minutes. Green = pass true, fail [], and ONLY the two known
     skips (v8.88 pane height, v11.24 feud unmeasurable). Never navigate that
     tab while it runs.
4. Commit (archives, rebuilds the publish zips, git commit -F cm<n>.txt):
     bash tools/handoff/ship.sh commit 1150 cm1150.txt
   Pass the BARE filename; an absolute path gets mangled by MSYS.
5. Bump HEAD in the memory file dark-raiders-handoff-state.md, then
   ship.sh start 1150 1151, and so on to 1163.
6. Report to him in plain language, play link http://localhost:8802/dark_raiders.html
   top and bottom, bullets, no em or en dashes, own mistakes in one line.

## Standing rules that bit this week

- No non-ASCII in any .ps1 (PowerShell 5.1 reads them as ANSI).
- Bash heredocs broke twice on apostrophes; write files with the Write tool.
- A SKIP is not a PASS. A control must FAIL on the previous fixture.
- No in-raid balancing before alpha: bug fixes, crashes, menus, saves and
  text continue; dials do not move.
- Never change the salvagerun:profile storage key without a migration.
- The cron dies with the process: CronList first every tick, re-arm if gone.
- One solo build at a time; no agent swarms (the 5-hour session limit).

## After 1163

The v11.46 audit queue is then fully shipped. The older audit memories
(full-file audit, RAID audit queue) are HISTORY, not queues: fourteen of
their sixteen named items were already shipped when re-checked at v9.43, and
their task-output files no longer exist on disk. Do not work a line from them
without checking the live file. The pool for new builds is:

1. AUDIT.md under STILL OPEN (anything not struck through).
2. DESIGN.md "Not verified:" lines, newest first; drive each one and either
   close it with a check or leave it as his ruling.
3. A fresh read-only audit: ONE bounded Workflow of read-only agents (Grep and
   Read only, never the browser, never Bash or Edit), each finding refuted by
   a skeptic before it is queued. The v11.46 one found 18 real defects in one
   pass; that is the highest-yield source there is.
4. His telemetry in exports/ and Downloads outranks all of the above when it
   is real (dur:0s or killer:test is a fixture leak, not him).
