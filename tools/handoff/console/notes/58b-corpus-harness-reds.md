# 58b-corpus-harness-reds (lane a, 2026-10-20)

Lane b run 10-20: BLOCKED again. slicechk.sh is refused for this worker (not on the allowed command list), so no slice can be reproduced or bisected. Nothing changed, no fix guessed. Alarm written.

Status: NOT reproduced, nothing changed. Reason: this run may not call tools/cdp.ps1 with -Port 9351 -Open/-Match/-Expr (only -Start -Port 9346 is allowed), and runchk.sh runs each check alone after __runPrep, which is exactly the way these five already pass. A leak from earlier checks in a slice cannot be seen that way. No fix guessed (task step 5). Alarm written in alarms.md.

Static clues only (not proof):
- v31.67 (mkfixture.ps1 line 9932): counts settings steppers whose border is not transparent and which are not hover, focus-within or padfocus. Game CSS boxes a stepper also when its row has class dshow (dark_raiders.html line 2037, detail pane row) or hover. A state left by an earlier check (a dshow row, or the mouse over a row) would give "3 idle steppers still boxed". Next run: in the slice [120,240) print document.querySelectorAll('#setlist .row.dshow').length and the last mouse position right before the check, then bisect the checks before index of v31.67.
- v30.91, v31.04, v24.38, v20.89: not read yet.

Next run (needs cdp on port 9351): __regressBg(120, idx31.67+1) first, then bisect.

## Lane a run 10-20 (later): BLOCKED. `bash .../scratchpad/slicechk.sh a find:idle` needs approval and is refused (slicechk.sh is not on this
## worker's command list: only shipq, shipdraft, fixq, genP, runchk, lock, unlock, clearstale, mk-cw-*, cdp -Start 9346). No slice run, no bisect,
## nothing changed. Fix needed from the coordinator: allow slicechk.sh for lane a workers, or run the bisect 120:152,152 yourself and hand me the leaking check.

## Coordinator 10-20 14:57 (slicechk.sh, lane a Chrome 9351, shipped fixture of v32.99; places shift by about 9 per new release, so
## always look a check up with find: first)
- REPRODUCED: `slicechk.sh a 120:229` (places 120 to 228 in order, 42 s) ends with 228 v31.67 "1 idle steppers still boxed". The same
  checks run alone in order (`slicechk.sh a 171,184,152,228`) all PASS, so it is a leak from earlier checks, as job 58 said.
- The same in-order run turned SIX MORE red that the 10-20 12:50 full run did not show (that run had different slice edges):
  152 v32.43 forge "current tier is not labeled"; 155 v32.40 forge "full forge action or dollar price did not draw";
  162 v32.33 map loot tags "missing contract track or status"; 171 v32.24 "the fire keycap was never drawn";
  184 v32.11 "the stamina word was not drawn"; 202 v31.93 J7 pad trials "tag not drawn beside its pillager".
  These are in scope for 58b too: same kind (pass alone, fail after earlier checks). Most say "not drawn", so look first for an
  earlier check that leaves a screen, the scrim, a pause or a stubbed draw function behind. Bisect 120:152,152 first (the first red).

## Coordinator 10-20 15:38: FIXED six (7fda5220); slicechk.sh is on the lane allowed list now
- Bisected on a pinned copy (slicechk.sh a 120:158,158 pin, then trimmed from both ends): place 131 v32.70 "large sixteen-letter pad
  name dialog" alone, then any of v32.43, v32.40, v32.33, v32.24, v32.11, v31.93, turns it red.
- Cause: v32.70 saved f=ctx.fillText (the PROTOTYPE's function) and in finally did ctx.fillText=f, which left an OWN fillText on ctx.
  The later checks record text by patching PR.fillText (the prototype), and the own property hid that patch: "never drawn".
- Fix (staging only, assertions unchanged): v32.70 remembers whether ctx had its own fillText and deletes it if not.
- Proof: shipped v33.08 fixture, `133,160,163,170,179,192,210` FAIL x6; same on the fixed draft PASS. The six still fail whenever
  the text they look for is really not drawn (that is exactly what the hidden recorder looked like), so they can still go red.
- Whole slice on the fixed draft: `120:240 draft` leaves only v31.67 (place 236 on v33.08: "1 idle steppers still boxed").
- Lesson for any check: to restore a canvas method, delete the own property; never assign the saved prototype function back.

## Coordinator 10-20 16:16: v31.67 FIXED too (32221c82); places for the last four (fixture v33.09)
- v31.67: v31.71 deployed a raid and never ended it; with a raid live every Settings action button is disabled (_rOff) and a
  disabled button is boxed, so the Tuning console OPEN counted as an idle boxed stepper. v31.71's finally now calls
  __endRaid('abandon'). Assertion unchanged; it still fails when idle steppers are boxed (a style boxing every row button: 61).
  Places 120 to 239 in order now all PASS.
- Reproduced on v33.09 (places): v31.04 = 300 and v30.91 = 313 both FAIL in `259:314`; v24.38 = 972 FAILS in `859:973`;
  v20.89 = 1321 not run yet (try `1219:1322`).
- 300 (v31.04): the smallest failing window is `279:300` and no single check or pair in it breaks it alone, so it is a combination
  or build-up inside 279 to 299. Bisect inside that window by dropping checks (e.g. 279:290,291:300,300).
- Lane a and the coordinator share tools/fxpina.html (the pin); the coordinator stops using it now, the job is yours.

## Lane a run 10-20 (evening): ALL FIVE FIXED (commits 32221c82 by another worker, 45094ab9, 735976e0). Staging only, no assertion touched.
Reproduced each in its slice with slicechk.sh (lane a Chrome), bisected on a pinned copy, fixed, then ran the four whole slices on the shipped fixture:
120:240, 240:360, 840:960, 1200:1320 (v33.12): v31.67, v31.04, v30.91, v24.38, v20.89 all PASS.
- v31.67: leaker v31.71 (it deployed a raid and never ended it; the live raid disabled Settings buttons, which draw boxed). Fix: v31.71 ends its raid in finally (32221c82).
  Proof it can still fail: shipped v33.09 fixture `180:236,236` and `232,236` FAIL, same on the fixed draft PASS; a boxed idle stepper still pushes the message.
- v31.04 and v30.91: leaker v31.21 (and any of ~140 checks) that restore ctx.fillText with ctx.fillText=saved. That leaves an OWN property that hides
  the PR.fillText recorders of later checks ("F1 list does not mention Superhot", "did not draw +0.50s"). Fix: __ctxHeal() in __runPrep drops an own ctx method equal
  to the prototype's function. Proof: before the fix `284,301` FAIL, after `240:360 draft` shows neither red; a check whose text is really not drawn still fails (the recorder just sees it).
- v24.38: leaker 25.30 (search sounds) filled/changed the wall sprite store so the sprite baked by v24.38 was not one the mark painter found ("121.6 to 121.6").
  Fix: v24.38 empties WALLSPR first (staging). Proof: `881,973` FAIL before; PASS after; the mark pixel check still compares l0-l1<12, so a painter that does not mark still fails it.
- v20.89: leakers v21.03 and v21.06 (and other 4K checks): they end with __forceSize(1920,1080), leaving the canvas larger than the gate window, so the shop grid reached the answer line.
  Fix: __forceSize remembers the first styles, __runPrep restores them (and 21.03 restores its own). Proof: `1306,1323` FAIL before, `1250:1340 draft` PASS after; a tile under the line still pushes the message.
Open (not mine, pass-alone fails, logged in alarms.md): v31.59 (row height 51,96) and v25.53 fail ALONE on v33.12; v32.77 flaky.
Lesson: slicechk "pin" always pins the SHIPPED fixture, never a draft; places shift by one per ship, so use find: after every ship.
