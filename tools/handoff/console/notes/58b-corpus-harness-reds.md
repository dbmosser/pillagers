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

## Coordinator 10-20 15:00 (slicechk.sh, lane a Chrome 9351, shipped fixture of v32.99; places shift by about 9 per new release, so
## always look a check up with find: first)
- REPRODUCED: `slicechk.sh a 120:229` (places 120 to 228 in order, 42 s) ends with 228 v31.67 "1 idle steppers still boxed". The same
  checks run alone in order (`slicechk.sh a 171,184,152,228`) all PASS, so it is a leak from earlier checks, as job 58 said.
- The same in-order run turned SIX MORE red that the 10-20 12:50 full run did not show (that run had different slice edges):
  152 v32.43 forge "current tier is not labeled"; 155 v32.40 forge "full forge action or dollar price did not draw";
  162 v32.33 map loot tags "missing contract track or status"; 171 v32.24 "the fire keycap was never drawn";
  184 v32.11 "the stamina word was not drawn"; 202 v31.93 J7 pad trials "tag not drawn beside its pillager".
  These are in scope for 58b too: same kind (pass alone, fail after earlier checks). Most say "not drawn", so look first for an
  earlier check that leaves a screen, the scrim, a pause or a stubbed draw function behind. Bisect 120:152,152 first (the first red).

## Coordinator 10-20 15:40: FIXED six (7fda5220)
- Bisected on a pinned copy (slicechk.sh a 120:158,158 pin, then trimmed from both ends): place 131 v32.70 "large sixteen-letter pad
  name dialog" alone, then any of v32.43, v32.40, v32.33, v32.24, v32.11, v31.93, turns it red.
- Cause: v32.70 saved f=ctx.fillText (the PROTOTYPE's function) and in finally did ctx.fillText=f, which left an OWN fillText on ctx.
  The later checks record text by patching PR.fillText (the prototype), and the own property hid that patch: "never drawn".
- Fix (staging only, assertions unchanged): v32.70 remembers whether ctx had its own fillText and deletes it if not.
- Proof: shipped v33.08 fixture, `133,160,163,170,179,192,210` FAIL x6; same on the fixed draft PASS. The six still fail whenever
  the text they look for is really not drawn (that is exactly what the hidden recorder looked like), so they can still go red.
- Whole slice on the fixed draft: `120:240 draft` leaves only v31.67 (place 236 on v33.08: "1 idle steppers still boxed").
- Lesson for any check: to restore a canvas method, delete the own property; never assign the saved prototype function back.

## Coordinator 10-20 15:45: FIXED six (7fda5220); slicechk.sh is on the lane allowed list now
- Bisected on a pinned copy (slicechk.sh a 120:158,158 pin, then trimmed from both ends): place 131 v32.70 "large sixteen-letter pad
  name dialog" alone, then any of v32.43, v32.40, v32.33, v32.24, v32.11, v31.93, turns it red.
- Cause: v32.70 saved f=ctx.fillText (the PROTOTYPE's function) and in finally did ctx.fillText=f, which left an OWN fillText on ctx.
  The later checks record text by patching PR.fillText (the prototype), and the own property hid that patch: "never drawn".
- Fix (staging only, assertions unchanged): v32.70 remembers whether ctx had its own fillText and deletes it if not.
- Proof: shipped v33.08 fixture, `133,160,163,170,179,192,210` FAIL x6; same on the fixed draft PASS. The six still fail whenever
  the text they look for is really not drawn (that is exactly what the hidden recorder looked like), so they can still go red.
- Whole slice on the fixed draft: `120:240 draft` leaves only v31.67 (place 236 on v33.08: "1 idle steppers still boxed").
- Lesson for any check: to restore a canvas method, delete the own property; never assign the saved prototype function back.
