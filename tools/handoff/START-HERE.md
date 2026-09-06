# START HERE (written 2026-09-05, handoff from Fable to Opus)

## FINAL RUN BEFORE ALPHA (handoff to Fable, 2026-09-06)

**STATE:** HEAD is v11.71 (b0b5377). The tree has **v11.72 APPLIED** (a note
typed in the pause box on the floor is banked instead of riding into the next
raid). It passed parse, its own check four times in a row, __verifySafe, and
its control fails on fx1171. Its FULL CORPUS is running on the Browser pane tab
"seed". FIRST ACTION: poll `JSON.stringify(window.__PROG)` there; when finished
is true, pass is true, fail is [] and only the two known skips are listed:
    bash tools/handoff/ship.sh commit 1172 cm1172.txt
That commit RETIRES THE WHOLE v11.46 AUDIT QUEUE. Then bump the HEAD line in
memory dark-raiders-handoff-state.md.

**NEXT, ALREADY DRAFTED:** 1173, a character who has never saved had no name
(`ship.sh start 1172 1173`). Not yet dry-run: run
`powershell -File tools/handoff/dry.ps1 1173 1173` first.

**THEN, THE ALPHA-PATH ITEMS STILL OPEN** (all from the 2026-09-06 menu audit,
recorded in AUDIT.md under its 2026-09-06 heading, none drafted as builds):
1. TAKE THE FREEBIE KIT wipes a packed backpack and the whole belt plan, with
   no confirmation and no undo. A new player is likely to press it after
   packing. Highest value left.
2. The safe pocket accepts a Frag Charge or an Ammo Box and reads 1/1, but the
   death path cannot bank either, so it silently spends the only death
   protection there is. One line in setSafe, plus clearing an already-saved bad
   P.safe on load.
3. The Undercroft keeps taking E, R, F and T behind the character screen; at
   the lift, R starts a raid under the title. One line in hubModalOpen.

**WHAT SHIPPED TONIGHT (20 builds, v11.52 to v11.71, every one with a green
corpus and a control that fails on the previous build):** all six of his
2026-09-05 in-run notes; the Undercroft HUD erase; the belt-key grenade; and
the entire v11.46 audit queue.

**THE HARNESS BIT FOUR TIMES TONIGHT and every repair is in the drafts:** a
check guarding on a hook from a renumbered build (skipped silently); a control
that required a blank strip only true while the HUD was erased; a check that
judged a multi-item lot by the last stash entry; one that renamed a row of the
shared WEATHER table; one that assumed which button writes the run row; and one
that skipped on a raid left in memory. THE STANDING RULE THAT CAME OUT OF IT:
run every new check three to five times in one page before the corpus, and once
straight after a neighbouring check that ends a raid. A check that is green
alone and red or skipped in the corpus is order-dependent, and the fault is
almost always in the check.

**MID-FLIGHT (2026-09-06, handing back to Fable):** HEAD is v11.56 (5afdc0a).
The tree has v11.57 APPLIED (his note E, LIGHTNING INCOMING at the ring) and
verified on all four gates: parse PASS, check 11.57 PASS, __verifySafe PASS at
1920x1080, control fails on fx1156.html. Its FULL CORPUS is running on the
Browser pane tab "seed". FIRST THING: on that tab run
`JSON.stringify(window.__PROG)`; when finished is true, pass is true, fail is
[] and only the two known skips (v8.88, v11.24) are listed:
    bash tools/handoff/ship.sh commit 1157 cm1157.txt
then bump the HEAD line in memory dark-raiders-handoff-state.md, then
    bash tools/handoff/ship.sh start 1157 1158
and carry on down the list below. Everything from 1158 to 1163 was dry-run
green in sequence at 2026-09-06.

THE ORDER FROM HERE (renumbered twice tonight; this list is the truth):
- 1158 THE UNDERCROFT HUD ERASE. The biggest find of the night and the one to
  get in before alpha. The floor painted its heading, its [E] STATION prompt
  and key list, the H controls panel, the NEW IN card and the line teaching
  WASD, then wiped all of it in the same frame; H has been a dead key. From
  the 2026-09-06 menu audit. NOTE FOR HIM: this makes the NEW IN card visible
  again at boot until he moves, which is that card's original design and may
  not be what he wants now.
- 1159 his note F, the four sounds that bypassed the heard-not-seen noise ring.
- 1160 the belt-key grenade fix (a throwable on a tactical belt key was a dead
  key that also deleted the working grenade cell).
- 1161 to 1172 the v11.46 audit queue, unchanged.

**AFTER ANY MACHINE RESTART, in this order, or every measurement is void:**
1. `powershell -ExecutionPolicy Bypass -File tools/start-servers.ps1`
2. CronList; re-arm the build tick if it is gone (it dies with the process).
3. `preview_start` at http://localhost:8800/parsecheck.html, then
   `resize_window 1920x1080` on tab "seed". A fresh pane is 0x0 and every DOM
   measurement skips or lies.
4. `git status --short` to see what was mid-flight, and `grep "^var VER=" dark_raiders.html`
   to see which build the tree is carrying.

**HIS TELEMETRY OF 2026-09-05 22:26 and 22:35 (exports/consumed-run-20260905-2226*.txt
and -2235*.txt; two real runs on v11.51, both DEAD, both lastHit YOUR OWN CHARGE,
killer other) OUTRANKS THE DRAFTED QUEUE. His notes, verbatim, in the order to
build them (one thing per build, his words on screen):**

A. "COOKING A GRENADE SHOULD COUNT down, NOT UP!!!" and "cooking grenades should
   give more warning before exploding in your hand, need a message with 1 sec
   left like COOKED GRENADE! THROW GRENADE NOW". He died to his own charge in
   BOTH runs (downs 2, rev 1, lastHit YOUR OWN CHARGE). One build: the cook
   readout counts down to the burst and at one second shouts his line.
B. "activating sprint should automatically stop crouching" and "rolling should
   automatically stop crouching". One build: sprint (hold Shift, v10.87) and the
   roll both leave the crouch toggle (v10.07).
C. "'EXTRACTION - OPEN' IS CONFUSING... POSSIBLE STATES FOR AN EXTRACTION POINT
   SHOULD INSTEAD BE: 'EXTRACTION POINT - SOUND THE ALARM TO BEGIN COUNTDOWN' /
   'EXTRACTION POINT - 30S UNTIL EXTRACTION BEGINS' / 'EXTRACTION POINT - EXTRACT
   NOW! 30S UNTIL EXTRACTION ENDS' / 'EXTRACTION POINT - CLOSED FOR THE REMAINDER
   OF THIS RAID'". His four strings, with the live seconds where he wrote 30S.
D. "lightning shouldn't strike inside buildings". The storm strike placement
   must reject any point inside a building interior.
E. "when lightning is about to hit, it should say like 'lightning incoming' at
   the circle." A label on the strike warning ring (v11.35 drew it in screen space).
F. "how lightning shows red noise, I want ALL noises to do that when they are
   outside the player's vision but within earshot, eg visualize noises with red
   circles!" A feature: every heard noise source outside the view cone draws a
   red ring at its position while audible. Design it small first (gunshots,
   footsteps, doors), prove it with a check that fires a shot out of view and
   reads the ring, and keep the CFG dial noiseSee in mind (it exists).

Then the chat note already shipping as v11.52 (credits and XP top right), then
the drafted queue 1153 to 1164.

READ BEFORE BUILDING A AND B (Fable read the code 2026-09-05 23:20):
- A. FRAG_FUSE is 1.1 SECONDS (var FRAG_FUSE=1.1, ~line 11367). The in-hand
  readout (drawHUD ~23312-23340) already prints "COOKING 0.8s" counting DOWN
  and a shrinking bar; startCook/releaseCook/cookOff are ~11447-11471; the
  cook clock runs in updatePlayer ~14263-14268 and cookOff fires at 1.1 s.
  That fuse is why it went off in his hand twice: a beat too long on the
  button and it is gone. A "one second left" warning on a 1.1 s fuse would
  appear the instant he presses. The fuse is a balance number and his order
  is no in-raid balancing before alpha, so DO NOT move it silently: build his
  shout (at <=1.0 s left, honest even if it is immediate), make the readout
  bigger and unmistakably a countdown, and put the 1.1 s figure in the report
  in plain words as the real cause with a request for HIS number. If he gives
  one, it is a one-line change to FRAG_FUSE. Also check what he saw counting
  UP: the only cook readout counts down, so it may be the landed grenade or
  a fill-direction of bar(); look at bar()'s fill argument (1-cf) before
  claiming it counts down on screen.
- B. Crouch is a toggle flag G.crouchTog (keydown ~10447, crouchHeld() ~3415).
  Sprint is computed in updatePlayer ~14057-14059 as
  `_shHeld && stam>2 && !stamLock && !stamRelease && !crouch && mg>0`, so
  today holding Shift while crouched simply does not sprint: crouch wins.
  His rule: sprint wins. Fix: when _shHeld and mg>0 and G.crouchTog, clear
  G.crouchTog before computing crouch (and say nothing; the stance readout
  already changes). The roll is tryRoll() ~11311-11331: clear G.crouchTog
  there too. One build, one check that sets crouchTog, holds Shift with W
  and requires crouchTog false and sprint true, then sets it again, rolls
  and requires it false; control fails on the previous fixture.

NEW, 2026-09-06 (Opus): a second read-only audit ran over the IN-RAID
subsystems (14 agents, 27 raw findings, top 8 refute-tested, none refuted;
19 raw findings were NOT verified and are listed in the run output at
tasks/wgxerrwcf.output). Its strongest finding is DRAFTED AND DRY-RUN GREEN
as 1159 and ships after his notes: a throwable put on a tactical belt key was
a dead key that also deleted the working grenade cell (the v8.31 stim hole,
one item type later). The audit queue moved again to 1160 to 1171
(renumber1160.ps1 then fixdev1160.ps1) to make room. The other seven
confirmed findings are written into AUDIT.md under the 2026-09-06 heading:
a frozen cook while downed that throws itself on revive, Q desyncing the
throw selector from the belt, a pinned weather burning seeded rolls every
frame, the fulgurite cache glowing the rarity it discarded, a second open
ring hijacking the extraction pointer, and a 3-second boarding window when
the raid clock is OFF.

NUMBERING (done 2026-09-05 23:45): the audit queue was shifted to 1159 to
1170 (renumber1159.ps1 then fixdev1159.ps1), so his note builds take 1153 to
1158. STATUS: B = v11.53 (sprint and roll leave the crouch) verified on all
four gates; check git log for whether its corpus committed it. DRAFTED and
dry-run green in sequence: C = 1154 (extraction point states in his words),
A = 1155 (the cooked-grenade shout; the 1.1 s fuse NOT moved, his number
requested in the report), D = 1156 (no strike point inside a building), E =
1157 (LIGHTNING INCOMING at the ring), F = 1158 (the four sounds that
bypassed the heard-not-seen ring: strike telegraph, extraction inbound pulse,
touchdown, last call, now positioned through sfx; the ring system noiseMark
already existed since v9.07). Ship them in order with `ship.sh start PREV
NEW`, each through the full procedure below. The audit queue 1159 to 1170
follows directly; no further renumbering is needed. The old crash line in his report (v10.96, sub
is not defined) is history, fixed at v10.98.

**HIS NOTE, 2026-09-05 ~22:30, OUTRANKS THE DRAFTED QUEUE:** "credits and xp
should be shown at all times in the upper right hand corner." Build it as the
very next build after whatever is mid-flight: a persistent readout of credits
and XP in the upper right of the screen, in the Undercroft AND in a raid AND
under every panel that does not cover that corner; one word per thing from
the vocabulary memory (Credits, XP). Prove it with a check that reads the two
figures off the real canvas or DOM in both places and requires them to track
P.credits and P.xp after a change; the control fails on the previous fixture.
If the drafted numbers collide, renumber the drafts UP by one with
tools/handoff/dry/renumber3.ps1 as the template (it bumps VER, WHATSNEW,
DEVNOW and the f-file anchors) and dry-run again before shipping.

WHERE WE ARE: run `git log --oneline -5` in C:\claudecode\dark raiders. The
newest "vX.YY:" subject is HEAD. Fourteen builds were fully drafted and
DRY-RUN GREEN in order on scratch copies (every anchor applies, end state
parses as v11.63): p/f/d/a/cm 1150 to 1163 in this folder. THE NEXT BUILD is
the lowest number in that range whose cm<n>.txt subject line is NOT yet in
git log. Confirm the tree is clean first (`git status --short` prints
nothing); if it is not, a build is mid-flight: read DESIGN.md's top entry to
see which, and carry it through the procedure below from step 3.

## What each draft fixes (all from the v11.46 read-only audit in AUDIT.md,
## section "STILL OPEN, found 2026-09-05")

(Renumbered 2026-09-05 late: his readout note took 1152 and everything after
it moved up one. The shift tool renumber1152.ps1 plus fixdev1153.ps1 did it;
the escaped "11\.NN" inside each p-file's DEVNOW regex needs the second tool.)

- 1150 closing the Undercroft backpack overwrote loadout edits made at the Mainframe (P0) SHIPPED
- 1151 my v11.42 sector-line pattern regression (wrong map name printed) (P1) SHIPPED
- 1152 HIS NOTE: credits and XP in the upper right at all times, raids and Undercroft
- 1153 Wirt Buy sold the clock-at-click lot, not the shown lot (P1)
- 1154 a merc who boards an earlier extraction was never paid (P1)
- 1155 the outcome card printed base XP while the profile banked more (P1)
- 1156 byPlayer never cleared on revive: a saved pillager was still your kill (P1)
- 1157 tags and a note chosen after Copy report were dropped (P1)
- 1158 the restore code left the armoury behind (P1)
- 1159 the restore code was blank for a name above U+00FF (P1)
- 1160 the notoriety banner said the Peddler was done with you (P2)
- 1161 belt drop on the stash said back in the backpack (P2)
- 1162 with pillagers None the extraction-heat row read CUSTOM (P2)
- 1163 [+] on a collapsed pillager board started an invisible resize (P2)
- 1164 a note typed in the pause box on the floor rode into the next raid (P2)

The range in every command below is therefore 1150 to 1164, and the dry run
is `dry.ps1 NEW 1164`.

## The per-build procedure (one build at a time, never two)

Below, PREV is HEAD's four-digit tag (v11.50 = 1150) and NEW is PREV+1.

Servers first: powershell -ExecutionPolicy Bypass -File tools/start-servers.ps1
(:8802 is his PLAY port and shares his profile: NEVER test there. :8800
serves the tools folder: fixture.html, parsecheck.html, fx<PREV>.html.)

1. Dry-run what is left before each ship (uses copies, touches nothing real):
     powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/dry.ps1 NEW 1163
2. Start the build (applies p and f, rebuilds fixture.html and fx<PREV>.html,
   inserts d into DESIGN.md and a into AUDIT.md):
     bash tools/handoff/ship.sh start PREV NEW
3. In the Browser pane (resize_window 1920x1080 first; a fresh pane is 0x0).
   One tab is enough; chain these in one browser_batch:
   - http://localhost:8800/parsecheck.html: wait 4 s; document.title must be
     "PASS v<NEW> parse check".
   - http://localhost:8800/fixture.html: wait 6 s. Find the corpus array (the
     window key whose value is an array of {v,what,run} objects longer than
     50), run the entry whose v is the new version, require null (PASS).
     Then `await __verifySafe()` and require summary PASS: ents {0:85,1:374},
     containers {0:165,1:593}, parity identical on both maps, loot on both,
     endings EXTRACTED / KILLED IN ACTION / ABANDONED, hub thrown null.
   - http://localhost:8800/fx<PREV>.html: wait 6 s; run the same new entry.
     It MUST return a failure string (the control). A PASS there means the
     check does not test the fix: stop and fix the check.
   - Back on fixture.html: wait 6 s, `__regressBg()`. Then poll
     `window.__PROG` ({done,cur,finished,res:{pass,checked,fail,skipped}})
     every few minutes; a `sleep 540` Bash call in the background is the
     timer. Nine to ten minutes. Green = pass true, fail [], and ONLY the two
     known skips (v8.88 pane height, v11.24 feud unmeasurable). Never
     navigate that tab while it runs.
4. Commit (archives, rebuilds the publish zips, git commit -F cm<NEW>.txt):
     bash tools/handoff/ship.sh commit NEW cm<NEW>.txt
   Pass the BARE filename; an absolute path gets mangled by MSYS.
5. Bump the HEAD line in the memory file dark-raiders-handoff-state.md.
6. Report to him in plain language, play link http://localhost:8802/dark_raiders.html
   top and bottom, bullets, no em or en dashes, own mistakes in one line.
7. Start the next one immediately. Never park on a wakeup while a build is
   available; a tick that ships nothing is a failed tick.

## Standing rules that bit this week

- v11.58 ALSO REPAIRED CHECK 9.88, whose control required the bottom of the HUD
  canvas to be blank with the belt dial off. That was only true because the
  floor HUD was being erased, so it fired on correct behaviour. A pixel COUNT
  cannot separate the belt from the floor HUD behind it (91809 against 91809);
  the control now compares a CHECKSUM of the real pixels with the dial on and
  off and requires them to differ. inkSum and unionOf live in that check.
- AFTER ANY RENUMBER, check hook dependencies. A check that guards on a
  window.__ hook added by a LATER build returns SKIP forever, on the new
  fixture AND on the control, and a skip reads like a pass. Compare
  `grep -oh "window\.__[a-zA-Z]*=" tools/mkfixture.ps1` (installed) against
  `grep -oh "window\.__[a-zA-Z]*" tools/handoff/f*.ps1` (used). As of v11.56
  the only unshipped hooks are __wirtLot, __identityIds and __wxHard, and each
  is installed by the same f-file that uses it, so the queue is clean.
- After patching a check, REBUILD fx<prev>.html
  (`mkfixture.ps1 -Src tools/prev<PREV>.html -Dst tools/fx<PREV>.html`), or the
  control still runs the old check text and skips instead of failing.
- A control that reads a function's SOURCE (fn.toString()) reads its comments
  too. Check 11.54's "no old badge phrase in drawHUD" control failed on a
  stale comment; fixcm1154.ps1 reworded it and p1154 carries the edit. Before
  writing such a control, grep the function body for the phrase in comments.

- No non-ASCII in any .ps1 (PowerShell 5.1 reads them as ANSI).
- Bash heredocs broke twice on apostrophes, and sed ate backslashes in a
  Windows path; write files with the Write tool.
- A SKIP is not a PASS. A control must FAIL on the previous fixture.
- No in-raid balancing before alpha: bug fixes, crashes, menus, saves and
  text continue; dials do not move.
- Never change the salvagerun:profile storage key without a migration.
- The cron dies with the process: CronList first every tick, re-arm if gone.
- One solo build at a time; no agent swarms (the 5-hour session limit).
- His telemetry in exports/ and Downloads outranks everything when it is
  real (dur:0s or killer:test is a fixture leak, not him).

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

Concrete leads swept from the "Not verified:" lines on 2026-09-05 (most of
those lines are "his own eye" or "his own play" and are not builds; these
are the testable ones):
- v11.04: a restore code from a much older build pasted into a newer one; the
  code carries v:1 and nothing reads it. Decide what a future v:2 does.
- v10.91 / v10.78 / v10.79: the HUD grip pinning, the two window overflow
  sweeps and the four draw-signal floors were measured at 1080p only; the
  pane DOES resize to 1440p and 2160p (resize_window), so run them there.
- v10.12: an old profile with P.loadouts is inert but never cleaned; a
  migration that deletes the field, with a check, is a small honest build.
- v11.27 / v11.28 / v11.30: the pad paths (belt buttons, D-pad through the
  backpack grid, strike and heal as separate buttons) were never pressed; the
  fixture can synthesise pad state through the PAD object.
- v11.36: "seven other combat-agent findings still queued" at that build; the
  memory dark-raiders-handoff-state lists them under QUEUED unbuilt agent
  findings. Several shipped since (v11.37 to v11.41); check AUDIT.md first.

## How a draft is written (for builds after 1163)

p<n>.ps1 patches the game with SubRx exact-match asserts (each anchor must
match exactly once) plus an edit-count assert, and bumps VER, WHATSNEW_VER,
the WHATSNEW line and the DEVNOW `now:'v..:'` stamp. f<n>.ps1 inserts a
{v,what,run} check into tools/mkfixture.ps1 before the previous version's
entry; the check runs INSIDE the game's closure, so internal functions and
variables (P, G, CFG, state, restoreCode, togglePauseBox, HUDBOX...) are
reachable directly, and window.__* hooks are the fixture's instruments.
d<n>.txt is the DESIGN.md entry (ends with "Not verified:"), a<n>.txt the
AUDIT.md table row, cm<n>.txt the commit message. Copy any of 1150 to 1163
as the template. Reproduce the defect in the page BEFORE writing the fix.
