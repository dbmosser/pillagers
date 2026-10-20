60-crash-reloads-title : a fault that keeps repeating reloads the game into the title with a short note (planner draft 2026-10-20)
effort: high

Source: memory pillagers-answers-third50-2026-10-12.md, Tech (binding): "A crash reloads into the title with a note."
Not done (planner, 10-20): noteCrash (dark_raiders.html about 49500) and errRow only record the error and say "error saved to your run
report"; CRASH_SAME_MS=5000 (49479) counts repeats; every location.reload (about 5208, 18362, 67841, 68773, 68947) is for saves,
restore or a stale save. Nothing reloads after a repeating fault.

The frame loop cannot die from one thrown error (loop() asks for its next frame first, about line 50316), so "the loop is dead" is the
wrong trigger. Trigger only on the SAME fault repeating: noteCrash already counts repeats (hit.n inside CRASH_SAME_MS).
1. Rule: the same error from the same place, firing on most frames for 5 seconds or more, in a raid or the hub. Then:
   - do not save a profile that may be broken (keep the last good save; the :precrash key exists for this);
   - write the crash to the run report as today;
   - reload into the title, and on the title show one short lower-case callout, for example "restarted after an error" (no full
     stop, no explaining sentence), which fades.
2. Never trigger on: one error, a burst under 5 seconds, errors while the page is hidden, the fixture or gate page, or a 2-player link drop.
3. In the 2-player demo, if one window reloads, the other must not hang: check what a window does today when its partner window closes,
   and make the reload look the same to it.
Checks (control must FAIL on v32.90): a stubbed fault thrown every frame for 6 s asks for exactly one reload (stub location.reload) and
sets the title note; a fault for 3 s does not; a single fault does not.
Party risk: medium. A loose trigger would end live runs. His answer 69: if something breaks mid-party, restart and carry on, which this
automates. It is a FEATURE: ship it by Mon 10/26 only with the strict checks above; otherwise stop, say so in notes, and it waits until
after 10/30. Write in notes what he should watch for in the next playtest.

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
