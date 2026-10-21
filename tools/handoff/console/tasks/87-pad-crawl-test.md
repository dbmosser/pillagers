87-pad-crawl-test : a pad-only check that walks every hub screen (pad research J3) (planner draft 2026-10-20)
Queue (coordinator 10-20 21:40): renumbered from 70 so the pick order follows the plan (his 10-20 evening play notes took 79 to 86 and come first; lanes pick by number).
effort: high

Source: tools/handoff/q-round3/answers.md 2.91 (pad-only pass over the whole hub): "a: Yes, after the party"; pad-research/best-practices.md line 142: "J3. Pad-only crawl test".
Not done (planner and skeptic, 10-20): grep -n -i "pad only\|pad-only\|padcrawl\|crawl every\|every reachable" tools/mkfixture.ps1 finds
only single-screen pad prompt checks; no task in tasks/, done/, cut/, failed/, waiting/ or stale/ mentions J3, a crawl test or 2.91;
notes/o-05-pad-presets.md still lists "pad-only title/pause entry and B-back checks" as pending.

1. Build the J3 check (best-practices.md lines 142-145), limited to the hub as 2.91 says: title, saves, settings, stash, sector page,
   shop, craft, terms, mainframe, bar, gambler, pause, outcome card, Undercroft floor and backpack. Not the raid HUD.
2. With a stubbed pad and NO keyboard events, on each screen: one focused control exists; A on it does something; B (or the close
   button) leaves; no focusable text field or select lacks a pad route.
3. Today's gaps go into the check as a pinned known-debt list (the way 29.33 pins its literals), so the check PASSES now and FAILS on any
   NEW gap. Its control: remove one known gap from the list and the check must fail.
4. The gaps themselves: list them in notes/87-pad-crawl-test.md as the after-party fix list (his 2.91: the pass is after the party). Fix one
   now only if it is a plain bug that stops a pad player cold (no way back, stuck focus), through the ship queue.
5. Fixture: plan the whole check before you take the lock; hold it at most 8 minutes (RULES.md).
Party risk: none (test only). This week only if the budget allows (see staging README); otherwise it is the first job after 10/30.

TASK DONE when the check is committed, passes on HEAD, fails with one gap removed, and the gap list is written; TASK PARTIAL with what is left.
