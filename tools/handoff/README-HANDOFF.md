# HANDOFF, 2026-09-03 evening, written for a model switch he asked for

Read this first, then the memory files (dark-raiders-handoff-state,
pillagers-fifty-answers-2026-09-03, dark-raiders-harness-poisons-itself,
dark-raiders-green-for-the-wrong-reason). Everything the old session kept in
its scratch folder is in THIS folder now: the queued patches, the check
scripts, the docs, the ship chain and the dry chain. The scratch folder of a
new session is a different path, so use these copies.

## Where the game stands

HEAD is v10.58 unless the last step below ran. Committed this evening, in
order: v10.49 text edits ride in every report; v10.50 Depot cosmetics; v10.51
plinth see-through and no running in place; v10.52 crate prompt bigger;
v10.53 ALL COSMETICS switch in the cheat box; v10.54 OUTFITS; v10.55
footprints by ground covered; v10.56 gun voices with reload and dry-fire;
v10.57 footsteps; v10.58 the gun tail short.

v10.59 (behind a wall you look like yourself, faded; his 21:30 note) is
APPLIED to the working copy: parse PASS, control fails on tools/fx1058.html
by a measured 30 blue-over-red, batch and verifySafe green, full corpus was
running in the fixture tab at the switch. If the working copy still says
VER 10.59 and git log says v10.58 on top, run the full corpus once more
(fixture.html, `__pinDPR(1); __cleanProfile(); __regressBg();` and poll
window.__PROG) and, on PASS, commit it:

    bash "tools/handoff/ship.sh" commit 1059 cm1059.txt

## The queue, in his order (his notes outrank everything else)

1. **1060 nobody in the Undercroft walks through a wall** (his 21:20 note).
   p1060.ps1 and f1060.ps1 written and dry-applied to tools/dry1060.html;
   d1060/a1060/cm1060 written but the control number in a1060 is a
   placeholder ("N times"): run the 10.60 check on tools/fx1059.html after
   `ship.sh start 1059 1060`, put the real message into the AUDIT row.
   Touches the hub crowd only: batched corpus (10.60, 10.51, 10.23, 8.83,
   10.36) plus verifySafe.
2. **1061 a found gun takes the next open slot** (his 21:25 note: "when i
   find a gun it should go to the next open slot, not kick my scav pistol
   out of slot 1"). Not written. Design: equipFromBag(ix,slot) with slot 1
   should route to slot 2 when the second slot is empty and the hand holds a
   real gun; look in buildRaid (function at about line 8439) for how the
   player's `sec` is built to learn what "empty" is (fists or none). Check:
   start a raid, put 'gun_smg' in G.bag with a pistol in hand and no second
   gun, equipFromBag(0,1), require the pistol still in hand and the SMG in
   the second slot. Inventory: FULL corpus.
3. **Howler must not bomb inside a house** (his 21:32 note). Not written.
   Design in AUDIT.md under HIS NOTE 21:32.
4. **A melee strike while holding a gun** (his 21:32 note). Not written.
   Design in AUDIT.md under HIS NOTE 21:32.
5. **1062 the machines** (deaths per kind, plate hit vs man hit, Bulwark
   grind, jitter) and **1063 one chirp did seventy jobs**. Both dry-passed
   earlier under older numbers; their VER anchor and now-line anchor name
   the build before them and must be re-aimed at whatever ships before
   them (memory: renumbering drafts rewrites anchors).
6. Then the cosmetics queue regenerated from cos/ (paper doll, next piece,
   earned this raid, three gates, capstones), the day-vs-night bot A/B, and
   the rest of the sound families (alarm/clank/charge splits).

## How to ship one build (the chain in this folder)

    bash "tools/handoff/ship.sh" start PREV NEW     # prevPREV from HEAD, apply pNEW + fNEW, build fxPREV + fixture, insert dNEW/aNEW
    # parse: http://localhost:8800/parsecheck.html must say PASS
    # control: load http://localhost:8800/fxPREV.html, run the NEW check, it must FAIL
    # batch: fixture.html, the NEW check + neighbours + __verifySafe(); full corpus if drawing/AI/map/inventory/profile or every fifth build
    bash "tools/handoff/ship.sh" commit NEW cmNEW.txt

Dry chain: `powershell -File tools/handoff/dry/dry.ps1 FIRST LAST` applies
pFIRST..pLAST and fFIRST..fLAST to copies, then
`powershell -File tools/handoff/dry/mk.ps1 -Src tools/handoff/dry/game.html -Dst tools/dryNNNN.html`
builds a fixture to test on :8800 (never :8802). Dry fixtures share the
saved profile with fixture.html on :8800.

## Fixture facts learned tonight

- `__drawHUD()` draws the HUD alone (`__hud` is the box reporter).
- `__enemyAudioReal` is the real enemy step audio; the fixture stubs
  tickEnemyAudio and tickPlayerSteps (`__stepsReal`) and blip (`_realBlip`,
  set `blip=_realBlip` inside a check that drives a game path).
- `__cleanProfile()` resets P.cond to day and P.cosOutfit to outnone.
- The parse gate's bracket counter reads a regex written right after
  `return` as a division: write `return (/x/).test(s)`.
- A pixel or size floor must be measured on BOTH builds first; the pane
  multiplies HUD type by 1.56, not 1.3.
- The 1080p pane is 1918x1078 CSS at DPR 1; resize a fresh pane before any
  DOM check.

## His open notes with no build yet (AUDIT.md, HIS NOTE headings)

Sound is a standing order (unique and crisp); the sprint footprint glitch
may or may not be the wall pile-up fixed at v10.55 (ask him for the
symptom if he says it persists); outfits done; melee and howler above.

## Servers

tools/start-servers.ps1: :8802 play (serves the working copy), :8800
fixture, :8799 local collector. The tick cron is session-only: run
CronList first every tick and re-arm the PILLAGERS build tick prompt.
