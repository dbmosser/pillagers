# Round 3 sweep 1: the rulebook and process rules

Swept 2026-10-18 about 16:00. Read-only; this is the only file written. Today is Sun 10-18. Cutoff Mon 10/26, lock Thu 10/29 evening, party Fri 10/30 (the weekly reset is Sun 10-25 05:00Z, not "Sat" as one memory file says).

Documents read: tools/handoff/RULEBOOK.md (10-02), tools/handoff/console/RULES.md (10-18), CLAUDE.md (Aug 21), console/questions.md (10-18), console/tasks (02, 03, 04, 05, 12), console/notes/ui/style-guide.md (10-18), the tools/nightly.sh header, tools/party/party.cfg, caps.txt, the status files, and his memory files on pacing, running the PC, helpers, shipping, answers-1-78, afternoon-orders, ui-program, sunday-start, ten-answers, polish-before-more, no-balancing, rulebook.

How to read a finding: TYPE, THE RULE (exact words, file, date), THE CLASH OR GAP, WHY IT MATTERS, DRAFT QUESTION (plain words, options), PICK (my recommendation and a one-line reason). Where round 2 (questions-100-round2.md, still unanswered) already asks the same thing, I say so, so the question is asked once.

## Top 5 (read these first)

1. F3 + F4: the lock has no procedure and "his play window always loads the latest stable" is already untrue (stable is v29.09 from 10:23; he plays live 30.73; many old checks are red only because screens were redesigned).
2. F11 + F12: about $50 of the $198 Console credit is left by estimate with 12 days to go, the caps file is a day out of date (no daily limit), and the real balance cannot be read because the admin key is not set.
3. F14 + F15: nothing stops 13 test Chromes (CPU about 88%) from running while he plays or while the party runs on this same PC, though stutter is his number-one worst problem.
4. F1 + F5: "fixes only" after 10/26 is not defined, and "all-in Thursday to Saturday" lands on lock day, party day and the day he stops everything.
5. F16 + F21: "phone alerts" were promised (Q11) but no channel exists, and his pause-box notes (including a party-critical "settings from the pause menu doesn't work right") are read by nobody until a coordinator session starts.

Count: 36 findings (A 10, B 3, C 2, D 7, E 14), then a settled list and a coordinator-only list that are not counted.

---

# A. Cutoff, lock and the party week

## F1. What "fixes only" means after Mon 10/26
TYPE: undecided
THE RULE: "New features until Mon 10/26, then fixes only; the party version locks Thu 10/29." (RULES.md, 10-18). "Feature cutoff is Mon 10/26." and "Lock the party build on Thu 10/29 evening." (answers-1-78 Q13, Q14, 10-18). CLAUDE.md (Aug 21): "No speculative changes without data. New features only when Daniel asks." RULEBOOK (10-02): "balance the game when I think it needs it".
THE CLASH OR GAP: "fixes" is never defined. Is re-skinning a screen a fix? Is a balance tweak? Is fixing something inside a feature that landed on 10/26? Today no screen scores 4 (one at 1, 36 at 2, 19 at 3 of 56 in accept.json), so the look work is the biggest thing still open at the cutoff.
WHY IT MATTERS: Party, and the game. Helpers read rules literally. Either they stop all look work on Monday and leave a half-new, half-old game, or they keep changing screens up to the lock.
DRAFT QUESTION: After Monday 10/26 no new things get added. What may helpers still change?
a) Only things that crash, freeze or break 2-player play. Everything else waits until after the party.
b) Also look-only changes (colors, spacing, words) until Wednesday 10/28; after that only crash, freeze and 2-player fixes until the lock.
c) Anything that is not a brand new feature, right up to the lock.
PICK: b. The look work is furthest behind and is the safest kind of change, but it stops a day and a half before the lock.

## F2. The exact hour of the cutoff and of the lock
TYPE: unclear
THE RULE: "Feature cutoff is Mon 10/26." "Lock the party build on Thu 10/29 evening." (Q13, Q14, 10-18). RULES.md: "the party version locks Thu 10/29."
THE CLASH OR GAP: No hour for either. "Evening" could be 6 pm or midnight. Helpers and the nightly runner do not know when to switch behavior; some jobs take hours.
WHY IT MATTERS: A late ship at 11 pm on lock night is exactly the build nobody has played.
DRAFT QUESTION: What hour do the two lines fall at?
a) Cutoff Mon 10/26 at 9 pm; lock Thu 10/29 at 8 pm, or earlier the moment you say "locked" in chat.
b) Cutoff Mon 10/26 at midnight; lock Thu 10/29 at midnight.
c) You say each one in chat when you are ready; nothing happens on its own before that.
PICK: a. A fixed hour that you can move earlier gives the helpers something to plan around and leaves Friday morning clear.

## F3. How the lock actually happens
TYPE: process
THE RULE: party.cfg: "Until the 10/29 evening lock use the newest build (dark_raiders.html). After the lock use the locked build: http://localhost:8802/stable.html" while the live line reads URL_BASE=http://localhost:8802/dark_raiders.html. Q14 (10-18): "Lock the party build on Thu 10/29 evening." Q12 (10-18): "his play window always loads the latest stable."
THE CLASH OR GAP: Nobody is assigned to flip the address. stable.html is whatever the hourly promote picked (v29.09 today), not "the build he last played". The stable.freeze file is only made by party-stop on the day. RULES.md gives helpers no instruction for after the lock, so they keep shipping to master and to itch. "Locked build" could mean three different things (newest, last stable, last one he played).
WHY IT MATTERS: Party. The thing guests play on 10/30 could be a build he never touched.
DRAFT QUESTION: On Thursday night, what does "locked" do?
a) You name the build you last played; I copy exactly that into the party copy, point the party start at it, and stop all game changes. Helpers keep testing only.
b) Same, but helpers may still prepare fixes in a separate copy, which you pick up on Friday morning only if you say so.
c) Leave the party on the newest build and just stop the big changes.
PICK: a. One exact build that you have actually played is the only kind of lock that cannot surprise you. (Round 2 Q81 and Q32 ask parts of this; ask this one and drop those.)

## F4. Stable is stuck at v29.09 while he plays the live build
TYPE: contradiction
THE RULE: nightly.sh header (10-18): "STABLE (finished test run with no new failure + 30 robot minutes on the same version)". Q12 (10-18): "Tag builds as stable or intermediate, and his play window always loads the latest stable. Tell him what counts as stable."
THE CLASH OR GAP: HEAD is v30.73; stable is v29.09 (10-18 10:23). The newest test runs (v29.90 and v29.32) show 44 and 25 new failures, mostly because redesigned screens leave old checks red. The file that would allow known-red checks (stable-known-red.txt) does not exist, so no later build can become stable. His 15:42-15:47 notes name build 30.73: he plays the live build, so Q12 is already not true.
WHY IT MATTERS: Party and the game. The party plan (F3) leans on "stable", and stable is eleven days of work behind.
DRAFT QUESTION: Many old tests fail only because the screen was redesigned (the test still looks for the old screen). Who may call such a test out of date?
a) The coordinator may, one test at a time, only when the new look is the cause; each one is listed in the evening report, and you bless the final list at the lock.
b) Nothing is waved through: a build is stable only when every test passes. The party would then run on the old v29.09 look.
c) You approve each batch in chat.
PICK: a. It unfreezes stable without hiding real bugs, and you still sign the list at the lock.

## F5. "All-in Thursday to Saturday" lands on lock day, party day and stop day
TYPE: contradiction
THE RULE: Q2 (10-18): "Next week's allowance: d (even, then all-in Thu to Sat)." hard-pacing (10-18): "Bend the line when that week starts." vs Q14 lock Thu evening, party 10/30, Q15 "He stops everything himself on 10/30."
THE CLASH OR GAP: The all-in days are the days with nothing left to build, so the allowance goes unused or is burned on Saturday after the party. There is no mechanism that bends the line (console-lane.sh PLAN_TARGET=85, WEEK_RESET=2026-10-25T05:00Z are fixed). And the weekly reset is Sunday 10-25, not "Sat 10-25" as the memory file says.
WHY IT MATTERS: His money and time. A week of allowance either sits unused at the party or is spent before the cutoff without being checked.
DRAFT QUESTION: Your game locks Thursday night and you stop everything Friday. How should the week's Claude allowance be spent?
a) Most of it Sun 10/25 to Mon 10/26 before the cutoff, light Tue to Thu (fixes only), nothing Friday, all-in again Saturday on whatever you ask for after the party.
b) Even all week, like this week.
c) Save all of it for Friday to Sunday, after the party.
PICK: a. The game stops changing on Thursday, so the work that matters has to be done before it.

## F6. Restart after the party is manual
TYPE: process
THE RULE: RULE NUMBER ONE (10-15): "do whatever you have to in order to continually work on the game and make progress 24 hours a day". The Desktop party-day-stop-list says the runner starts itself again; party-stop turns off the "Pillagers runner" scheduled task.
THE CLASH OR GAP: After party-stop nothing restarts unless he runs party-start. If he forgets, the PC sits idle for days, the opposite of rule number one. (The same list also still tells him to pause the "pillagers-watchdog" task, which was disabled 10-18 11:25.)
WHY IT MATTERS: Time. After the party is when the next round of work starts.
DRAFT QUESTION: After the party, when do the helpers and overnight robots start again?
a) By themselves, Saturday 10/31 at 8 am.
b) Only when you double-click party-start.
c) When you tell me in chat.
PICK: a. He will be tired after the party and rule number one says never idle.

## F7. A half-restyled game at the cutoff
TYPE: undecided
THE RULE: RULES.md (10-18): "His finish line (Q6): 4 or more from the critic on EVERY screen." Q6 (10-18): "The critic finish line is 4 everywhere." Task 04 re-applies the new look to every screen.
THE CLASH OR GAP: 0 of 56 scored screens are at 4; 8 days to the cutoff. Nothing says which screens come first, and half old, half new looks worse than all old.
WHY IT MATTERS: Party. Guests see the title, how to play, the raid screen, the pause box and the run-over card; nobody sees most of the other 50.
DRAFT QUESTION: If not every screen is done by Monday 10/26, which ones get finished first?
a) The ones guests see at the party (title, how to play, raid screen, pause box, run over, scoreboard). The rest stay as they are, consistent with each other.
b) All screens in list order.
c) Stop the restyle on Friday 10/23 and tidy what is there so it looks even.
PICK: a. It puts the effort where the party looks. (Related: F29, F30.)

## F8. Fix jobs that queue themselves after the cutoff
TYPE: process
THE RULE: nightly.sh (7), 10-17: "once a day after 03:00, the half-price code review of the day's game commits (tools/review-nightly.sh)". The review queues HIGH findings as fix jobs by itself; corpus runs are also triaged into fix jobs.
THE CLASH OR GAP: None of these machines is told about the cutoff. After 10/26 they keep producing "fixes" (which can change the game) with nobody deciding.
WHY IT MATTERS: Party and game. Every automatic change after the cutoff is a build that gets less play-testing.
DRAFT QUESTION: After 10/26, what should the night review and test runs do with what they find?
a) Only crash, freeze and 2-player findings turn into fix jobs; everything else goes on an after-the-party list.
b) Everything turns into a job, as now.
c) Nothing turns into a job by itself; it all goes to your morning report.
PICK: a. It keeps the safety net for the things that ruin a party and parks the rest.

## F9. Plan B if the game page will not open at the party
TYPE: undecided
THE RULE: party.cfg (10-18): URL_BASE is an http://localhost:8802 address; the party launcher requires an http localhost address.
THE CLASH OR GAP: Everything runs off one local server on this PC. If :8802 does not come up (port taken, server crashed), there is no stated fallback. The two-window rig cannot run from a plain file.
WHY IT MATTERS: Party. This is the single point of failure on the night.
DRAFT QUESTION: If the game page will not open at the party, what is the backup?
a) A second copy of the locked build on a different local address, started by one button on the desktop.
b) The itch page.
c) No backup; you restart the PC.
PICK: a. One button is something a guest can press; the itch page would not give the two-window set-up.

## F10. The "feature freeze" list versus "new features until 10/26"
TYPE: contradiction
THE RULE: polish-before-more (10-15): "FREEZE new-feature work until the polish pass is done. That covers the 100-pick batches B6 audio, B7 visuals, B8 heat/nemesis and B9 HUD/meta, plus #14 elemental combos." RULES.md (10-18): "New features until Mon 10/26". Q5 (10-18): "Do a, b, c and d all this week, and the helpers set the order".
THE CLASH OR GAP: Round 2 R1-R5 (heat dial, combos, extras, Experimental settings, missions) are exactly what the 10-15 freeze listed. Meanwhile his pause-box notes keep adding ideas (15:42-15:47: a "superhot" toggle key, other exploding barrels, "get rid of the mimics"). Nobody knows which are allowed through before 10/26.
WHY IT MATTERS: Game and party. Every extra feature in cutoff week is something the party build has not been played with.
DRAFT QUESTION: Until Monday 10/26 new things may go in. Which ones?
a) Only the work lists you picked on 10-18 (Q5) and the raid HUD redesign. New ideas, including the ones in your notes, go on an after-the-party list.
b) Any idea you give in chat, small ones first.
c) Also the round 2 extras (heat dial, combos, extras, experimental settings, missions).
PICK: a. The party is about a solid 2-player demo, and a long list of untested extras works against that.

---

# B. Money and weekly usage

## F11. The Console credit is nearly three quarters spent, with no daily limit
TYPE: stale, undecided
THE RULE: caps.txt (10-18): "END_DATE=2026-10-17, PACE=0, DAY_USD=200, TOTAL_USD=198". console-worker memory (10-17): "10-17 14:25 PACING OFF ... you can spend it all today ... efficiently" versus the noon note "pace the $200 between now and launch, which is halloween". Q3 (10-18): "No paid extra usage."
THE CLASH OR GAP: The end date is yesterday, there is no daily limit (PACE=0), "launch" no longer exists. By my estimate about $147 of $198 is spent ($126 today alone), so about $50 is left for 12 days, including the lock week. The credit resets Nov 1, so leftovers are lost, but running out on 10/22 leaves the lock week with no helpers. Round 2 Q82 (daily cap) assumed more was left.
WHY IT MATTERS: His money and time. Helpers stop in the middle of the week that matters most.
DRAFT QUESTION: The helpers' credit has about $50 left by my estimate. How should it be spread?
a) A small daily limit now (about $4 a day) and keep about $20 for 10/27 to 10/29, only for crash and 2-player fixes.
b) Spend freely until it is gone, then helpers run on your plan only.
c) Spend it all before the 10/26 cutoff.
PICK: a. The lock week is when a crash fix is worth the most, and unspent credit only disappears on Nov 1 anyway.

## F12. The real balance cannot be read, and two safety checks are his alone
TYPE: process
THE RULE: real-spend.err (15:23): "NO ADMIN KEY: PILLAGERS_ADMIN_KEY is not set". Memory "REAL NUMBERS, NOT GUESSES" (10-18): numbers that steer helpers come from the real source. RULEBOOK (10-02): "I never: ... handle his keys or passwords".
THE CLASH OR GAP: The balance number steering all spending is an estimate that was once 1.76x too high (rescaled by 0.569). The dashboard showed $89.92 left at 08:20 and nothing real since. Only he can create the admin key, check that auto-reload is off, and set the monthly spend limit (Q3 says no paid extra usage). The Console key itself expires 11-16.
WHY IT MATTERS: His money. If auto-reload is on, "no paid extra usage" is not true.
DRAFT QUESTION: Can you spend 5 minutes in the Console (I give you the steps) to turn off auto-reload and create the key that lets me read the real balance?
a) Yes, tonight.
b) No key; instead you type the dashboard balance in chat each morning.
c) No; trust my estimate.
PICK: a. It makes "no paid extra usage" certain and puts a real number behind every spending decision.

## F13. Who gives way on the weekly meter: his chat or the helpers
TYPE: contradiction
THE RULE: hard-pacing (10-18): "Game work goes to the Console helpers by default: they spend his API credits, not his weekly usage." and the 85% target (PLAN_TARGET=85). Same file also gives "at or below the share elapsed minus 5".
THE CLASH OR GAP: Two formulas for the line. And the first sentence is not true: lanes e and f run on his plan (CLI_ALWAYS=e,f) and the coordinator also runs agents there. At 15:34 the week was 11% used against a line of 7.4%, so the plan helpers were paused, while his own chat and the coordinator use it fastest.
WHY IT MATTERS: His time. He may find helpers stopped exactly when he is chatting a lot, or his chat throttled to feed helpers.
DRAFT QUESTION: When the week meter runs ahead of the line, what gives way first?
a) The plan helpers (lanes e and f) pause; your chat and the coordinator always continue.
b) The coordinator slows down first; the helpers continue.
c) Whichever costs least per hour.
PICK: a. Talking to you must never wait on a background job. (Use the 85% target as the one formula.)

---

# C. The PC

## F14. Helpers while he is at the PC: three rules say three things
TYPE: contradiction
THE RULE: go-light (09-25): "please reduce your use of my pc when you detect that I am here and working". rule-number-one (10-15): "if you aren't doing anything else and even if i'm at my pc". RULEBOOK (10-02): "use the PC freely for tests", "six test Chromes at most". nightly.sh header: "at most two test Chromes of its own". RULES.md (10-18): "never start more than one extra Chrome".
THE CLASH OR GAP: The newest rule wins, but the numbers disagree (1, 2, 6) and reality is 13 headless test Chromes, 10.7 of 31.9 GB free and CPU about 88% (one reading, 15:40). The party rig is on this same PC. His own Q27 ranks "stutter or harsh sound" as the number-one worst problem.
WHY IT MATTERS: Party and game. His playtests are the fun checks; stutter from our own robots spoils them.
DRAFT QUESTION: When you are playing on this PC, what should the robots and helpers do?
a) Keep going at half: one robot only, no big test run, no AI model, while a game window is open.
b) Full speed always; you accept some stutter in test sessions.
c) Pause everything while you play.
PICK: a. It follows rule number one and still keeps your sessions smooth; set one limit (6 test windows at most, 2 while you play).

## F15. Nothing pauses the robots for the rehearsal, the soak or the party
TYPE: undecided
THE RULE: nightly.sh header (10-15): "Every 5 min, whether or not he is at the PC". Q27 (10-18): "Worst problems, in order: stutter or harsh sound; crash or freeze; P2 pad or window fails; guests can't tell how to start." Q22: "The party runs on this PC."
THE CLASH OR GAP: The scheduled task restarts the runner every 15 minutes; only party-stop (run by hand on the day) turns it off. A rehearsal or a long test on Wednesday gets robots running too. Round 2 Q31 (rehearsal date) is not answered.
WHY IT MATTERS: Party. A test that stutters because of the robots proves nothing, and the night itself must be quiet.
DRAFT QUESTION: When should the robots and helpers stop by themselves?
a) Automatically whenever the party launcher window is open, and completely from the Thursday lock until party-start.
b) Only when you run party-stop on Friday morning.
c) Never automatically.
PICK: a. It protects every real test and the party without you having to remember.

---

# D. How he hears about problems and how questions reach him

## F16. The phone alert was promised but no channel exists
TYPE: undecided
THE RULE: Q11 (10-18): "Phone alerts when stuck or nothing has shipped for 2 h, only from 9 am to 9 pm."
THE CLASH OR GAP: No alert code exists (searches for push/text/email tools found nothing). The channel was never asked. Round 2 Q84 proposes "publish to itch or send anything off the PC without your yes", so sending the alert out needs his yes anyway.
WHY IT MATTERS: Time. A stuck pipeline is found hours late (it was jammed from 13:32 to about 15:00 today).
DRAFT QUESTION: How should the phone alert reach you? It would say only "stuck" or "nothing shipped for 2 hours", never game content.
a) A free push-notification app on your phone (you install one app; I set it up).
b) A text message.
c) An email to dbmosser@gmail.com.
d) No alert; the morning and evening reports only.
PICK: a. It is free, quick, and shows on the lock screen.

## F17. A jammed build line needs a human
TYPE: process
THE RULE: questions.md (10-18 13:32 and 15:10): "Owner: delete .git/index.lock ..." and "Workers cannot git checkout." RULES.md (10-18): "If the lock S\shipq.lock looks stale ... use bash S/clearstale.sh. Nothing else." CLAUDE.md (Aug 21): "Never ask him to edit code, run commands, or debug."
THE CLASH OR GAP: Two jams today (a leftover git lock, then deleted tracked files) stopped every ship and the workers' only allowed move was to write to him. His own rule says never ask him to run commands.
WHY IT MATTERS: Time. Each jam is hours of helpers working for nothing.
DRAFT QUESTION: When the build line jams, who fixes it?
a) A small automatic repair, narrowly limited to removing a git lock older than 30 minutes and restoring deleted tracked files, each use logged in the report.
b) The coordinator fixes it when it sees it; helpers only report; if no coordinator is awake it waits.
c) You do, from written steps.
PICK: a. Both of today's jams were of this kind and a narrow script cannot break the game.

## F18. questions.md mixes alarms, stale items and questions to him
TYPE: stale
THE RULE: questions.md (10-18): both "URGENT" items; Open #1 (two "coming later" rows), Open #2 (empty scoreboard rows), Open #3 (arcade Undercroft walk).
THE CLASH OR GAP: Both URGENT items are fixed (index.lock is gone, p3069/f3069 are back) and are addressed to "Owner" with git steps. Open #1 duplicates round 2 R6. Open #2 was decided by a helper (v29.93). Only #3 is a real question for him.
WHY IT MATTERS: Time. The one real question hides among stale ones, and he asked for few competent questions (ten-answers 10-15).
DRAFT QUESTION: Should the questions file hold only things for you?
a) Yes. Pipeline alarms go to a separate alarms file the coordinator reads, and answered or fixed items are deleted the same day.
b) Keep one file as it is.
PICK: a. A short file is one he will actually read.

## F19. Do the two players walk the Undercroft in the arcade demo?
TYPE: unclear
THE RULE: questions.md Open #3 (10-18): "Should the arcade demo also let the two walk the Undercroft before the drop, or keep the straight drop? I changed nothing there." afternoon-orders (10-18): "players 1 and 2 should be able to see each other in the undercroft" (cw-p1p2).
THE CLASH OR GAP: In the arcade demo the Undercroft is a blurred picture behind the party screen and nobody walks there; in the same-PC co-op mode they walk it and see each other (v30.64). The order does not say which mode it meant. (An agent is working on this now; this may be settled by the time you read it.)
WHY IT MATTERS: Party. The demo is the arcade mode.
DRAFT QUESTION: Your order was that the two see each other in the Undercroft. In the party demo (arcade mode)?
a) Keep the straight drop; the order applies to same-PC co-op only.
b) Add a short walk in the Undercroft in the demo too.
c) Show both characters standing side by side on the party screen before the drop.
PICK: c. It gives "they see each other" without new walking code before the cutoff.

## F20. How many questions, and how often, in the last twelve days
TYPE: process
THE RULE: ten-answers (10-15): "ask me 10 only" ("alot of them ask shit that i've already answered repeatedly"). RULEBOOK rule 2 (10-02): "Never carry a trivial question across reports." afternoon-orders (10-18): "100 new questions".
THE CLASH OR GAP: Round 1 had 100 (Q79-95 skipped, Q96-100 unanswered), round 2 has 100 more and is unanswered, and this is round 3. Q89 ("Is your itch page private?") never got an answer.
WHY IT MATTERS: His time in the busiest week.
DRAFT QUESTION: Until the party, how should questions reach you?
a) One page of at most 10 each evening at 7 pm; the rest are decided by the coordinator with the default shown in the report.
b) Longer batches, weekends only.
c) One at a time in chat as they come up.
PICK: a. It matches what he said on 10-15 and still gets answers in time.

## F21. How fast his pause-box notes are acted on
TYPE: undecided
THE RULE: Q61 (10-18): "Keep the feedback line, button and Send play data." RULEBOOK start-of-session step 3: "Check exports/ and Downloads for his notes and run reports."
THE CLASH OR GAP: His notes land in exports/feedback-*.txt. Only collector.ps1 touches them; no job reads them. They are seen only when a coordinator session starts. Latest (15:42-15:47, build 30.73): "accessing settings from pauise menu doesn't work right", "superhot mode needs a toggle key", "get rid of the mimics", "add other exploding barrels". The first is party-critical (Q30: all settings reachable from the demo pause menu). Round 2 Q39 asks how to sort reports.
WHY IT MATTERS: Party and game. A broken pause menu can sit unseen for hours.
DRAFT QUESTION: When you send a note from the pause box, how soon should it be acted on?
a) A helper job is made within the hour: crash, 2-player and menu problems first; ideas for new things go on the after-the-party list.
b) It waits until the coordinator next wakes up (could be hours).
c) You tell me in chat when one matters.
PICK: a. The pause menu is where the party's trouble will show up first.

## F22. Round 2's priority order contradicts his own list
TYPE: contradiction
THE RULE: Q27 (10-18): "Worst problems, in order: stutter or harsh sound; crash or freeze; P2 pad or window fails; guests can't tell how to start." Round 2 Q80 proposes a priority order that puts performance 4th.
THE CLASH OR GAP: His order puts stutter first; the draft default puts it fourth. If he accepts the default without noticing, helpers will rank speed below polish.
WHY IT MATTERS: Party. Stutter is his own number-one problem.
DRAFT QUESTION: When two jobs compete in the last week, which comes first?
a) Your 10-18 list, in your order: stutter or harsh sound, crash or freeze, P2 pad or window, guests understanding how to start; then everything about looks.
b) Crash or freeze first, then the rest of your list.
c) Looks first, since the polish pass is still open.
PICK: a. It is your own list, in your own order.

---

# E. Rules that clash for helpers

## F23. Every ship pushes to itch; nobody answered whether the page is private
TYPE: contradiction
THE RULE: RULES.md (10-18): "Every ship also pushes GitHub and itch on its own." ten-answers (10-15): "don't worrry about itch right now". RULEBOOK (10-02): "Itch updates only through ship.sh on his PC." tools/PUBLISH.md: Visibility "Restricted (secret URL)". Round 2 Q84 proposes "publish to itch or send anything off the PC without your yes".
THE CLASH OR GAP: The ship script pushes to itch about 30 times a day, and itch-daily.sh pushes again daily. The proposed never-do list would forbid it. Round 1 Q89 ("Is your itch page private?") was never answered, and there is no public launch.
WHY IT MATTERS: Party and the game. A half-restyled build goes out many times a day to a page whose privacy nobody confirmed.
DRAFT QUESTION: Should every passing build go to your itch page automatically?
a) Yes, the page is private (secret link only); keep it automatic.
b) Once a day only (the daily backup already does that).
c) Stop until after the party. GitHub backup stays.
PICK: b. The backup still happens, ships go faster, and nothing half-done is posted all day.

## F24. "The remaining player picks up the raid" versus the party rig
TYPE: contradiction
THE RULE: RULEBOOK (10-02): "The remaining player picks up the raid when the host is gone (his order 2026-10-02; replaces host drop = abandon)." Q65 (10-18): "In 2P the run ends when both players are out."
THE CLASH OR GAP: In the party rig the first player's window is the host; if it crashes, the second player loses everything. Round 2 Q1 (what happens when the P1 window dies) does not mention the takeover rule at all.
WHY IT MATTERS: Party. Windows crash. A guest on the pad needs one clear outcome.
DRAFT QUESTION: At the party, if the first player's window closes or crashes mid-raid, what happens to the second player?
a) The raid ends for both and both go back to the title, same every time.
b) The second player carries on alone (your 10-02 order).
c) The second player is shown a "player 1 left" card and chooses.
PICK: a. A simple outcome that always works beats a takeover nobody has proven with the party rig. (If the two-window test already proves takeover, b.)

## F25. The kid-mode rows are still reachable in the demo
TYPE: contradiction
THE RULE: RULEBOOK (10-02): "Build: a kid menu (which also lets player 2 come back after death)". Q32 (10-18): "Adults and teens, so no kid switch." Q65: "In 2P the run ends when both players are out." Q30: "All settings are reachable from the demo pause menu."
THE CLASH OR GAP: The Settings screen still has KID MODE, auto-fire and "PLAYER 2 COMES BACK AFTER DEATH" (P.kidBack). Q30 puts all settings in the demo pause menu, so a guest can switch on a rule that breaks Q65.
WHY IT MATTERS: Party. A guest toggling it changes how the run ends for everyone after.
DRAFT QUESTION: Should kid mode, auto-fire and "player 2 comes back" show in the demo's settings?
a) Hide them in the demo; they stay in the career game.
b) Show them, but say what each does in a few words.
c) Remove kid mode from the game.
PICK: a. It satisfies both Q30 and Q32 and loses nothing in the game.

## F26. What "leave the raid" takes in the demo
TYPE: unclear
THE RULE: style-guide.md (10-18): "Destructive (Abandon, Sell all): hold 500ms with a filling ring, or a confirm dialog 480x240 (title "Abandon run?", one line, Abandon danger ghost + Keep playing primary focused)." Memory ONE CONTROL PER JOB: never a second row doing an existing control's job.
THE CLASH OR GAP: The guide offers two controls for one job. The title is also capitalized against the all-lower-case order. Leaving ends the raid for both players (Q65).
WHY IT MATTERS: Party. A stray press by a guest should not end both players' raid.
DRAFT QUESTION: To leave a raid in the demo, what should it take?
a) A confirm box ("leave the raid?") with "keep playing" already selected.
b) Hold the button for half a second.
c) One press.
PICK: a. It works the same with the mouse, the keys and the pad.

## F27. Four failed screen jobs are stuck on end-card choices
TYPE: process
THE RULE: RULES.md (10-18): "NEVER end a run because a question is open". failed/ holds 13-ui-end-cards, b-30-ui-hud, b-31-ui-undercroft, c-31-ui-pause-settings. The 13-ui-end-cards notes show runs 8-17 all "no ship", "waiting on his word" about the $ versus SP hero line, the close X, "Copy report" and the baked buttons.
THE CLASH OR GAP: The helpers were told never to stop for a question, yet they stopped ten times on one. Parts are already answered: Q7 (style guide overrules layout), Q8 (may shorten or delete his lines with a logged reason), Q43 (centred card with an X, nearly the full screen), Q59 ("$ for money, SP for score"). Only "Copy report" and the baked buttons are really open. These are career cards; the demo has its own run-over card.
WHY IT MATTERS: His money. Ten failed runs spend credit for nothing.
DRAFT QUESTION: The end-of-raid career cards keep failing because the helpers wait on a few choices. What now?
a) Park the career end cards until after the party; only the demo run-over card gets finished.
b) Tell the helpers to apply Q7, Q8, Q43 and Q59, and decide "Copy report" and the baked buttons themselves, logging the reason.
c) You decide "Copy report" and the buttons now in chat.
PICK: b. Q8 already allows exactly this, and it ends the loop.

## F28. Which of his lines and buttons are truly off limits
TYPE: unclear
THE RULE: Q8 (10-18): "Helpers may shorten or delete lines he wrote: 'If it overrides my language, it better have a damn good reason'. Log the reason." Q61 (10-18): "Keep the feedback line, button and Send play data." RULEBOOK (10-02): "I never: ... reword a line he edited".
THE CLASH OR GAP: RULEBOOK says never, Q8 says may with a reason, Q61 keeps one line. Buttons are not covered by Q8 at all, and no list exists of what is his untouchable.
WHY IT MATTERS: The game and trust. Each helper guesses, and one deleted line he valued costs more than it gains.
DRAFT QUESTION: Is there anything of yours that helpers must never change, even with a reason?
a) Just the feedback line, its button and Send play data.
b) Those plus a short list you give me in chat.
c) Nothing; Q8 covers it.
PICK: a. It matches Q61 and costs you nothing; add to the list whenever you notice a line you love.

## F29. The critic's bar of 4 has not been reached by any screen
TYPE: undecided
THE RULE: RULES.md (10-18): "A screen is done at 4 or more. After two follow-ups that do not raise the score, write what is stuck in your notes and move on." Q6: "The critic finish line is 4 everywhere."
THE CLASH OR GAP: Of 56 scored screens, one is at 1, 36 at 2, 19 at 3, none at 4. The critic costs about 4 cents a call, does not know his rulings and sometimes contradicts itself (c-31 notes). One helper note listed "'$' in ammo panel" as a finding, though Q59 says $ is for money. Round 2 Q83 asks how many critic tries.
WHY IT MATTERS: His money, and the party. Helpers keep retrying a bar that may be unreachable, or stop for no good reason.
DRAFT QUESTION: No screen has reached 4 yet (best is 3). What does "done" mean for the party?
a) 4 only for the raid HUD, title, pause box and run-over card; 3 is enough for everything else.
b) Keep 4 everywhere until the cutoff.
c) You look at before and after pictures and judge screen by screen.
PICK: a. It keeps your bar where guests look and stops spending on the rest.

## F30. Nobody shows him the biggest look changes before they go in
TYPE: process
THE RULE: Q7 (10-18): "The style guide can overrule his existing guidance (layout and size)." Q50: "Keep the normal title screen. No party version." Q57 (10-18): the whole raid HUD is redesigned.
THE CLASH OR GAP: Helpers may overrule his layout orders and redo the raid HUD, title and end cards, with no step where he sees them before they are in the party build. A dislike on 10/27 is too late.
WHY IT MATTERS: Party. These are the screens everyone sees.
DRAFT QUESTION: Do you want to see the biggest screens before they are in the party build?
a) Yes: before and after pictures of the HUD, title and run-over card in the evening report; if you do not reply by Sun 10/25 noon, they stay.
b) Only if I am unsure.
c) No; helpers go ahead.
PICK: a. It uses a few minutes of your time and a hard date stops it from blocking anything.

## F31. The "what's new" card and the "Polish pass" lines in the demo pause menu
TYPE: unclear
THE RULE: Q70 (10-18): "No tutorial prompts. The game must be completely self-explanatory." Memory GAME TEXT VOICE (10-18): all lower case, short callouts, never explaining sentences. Memory TWO VERSION STAMPS: WHATSNEW_VER rots.
THE CLASH OR GAP: The pause menu in the demo still carries the What's New card and "Polish pass N" filler lines, which are developer notes, not guest text. WHATSNEW_VER is 30.58 against VER 30.73, a drift of 0.15; the ship STOPs at 0.16, so ships block after one more version unless the card is touched.
WHY IT MATTERS: Party and time. Guests would read internal notes; the stamp rule can stop the build line at any moment.
DRAFT QUESTION: Should guests see the "what's new" card in the party demo?
a) Hide it in the demo; keep it for the career game.
b) Show it, cut to three plain lines.
c) Leave as is.
PICK: a. It removes a source of stray text and an automatic stop in one move.

## F32. "All text also goes into the feed" versus one tidy toast
TYPE: contradiction
THE RULE: his-orders-2026-10-15-evening.md (tools/handoff/research): "All text shown to the player on screen also goes into the player feed." (shipped v29.03, with a check). style-guide.md (10-18) toast rules: one toast at a time, de-duplicated.
THE CLASH OR GAP: The order says everything goes in the feed; the guide says keep it quiet. The raid HUD redesign (task 02) will decide how the feed looks, and the v29.03 check will fail if the redesign drops lines.
WHY IT MATTERS: Game. A cluttered feed in a 2-player fight, or a red check at the next stable run.
DRAFT QUESTION: Should every message that appears also be listed in the feed?
a) Yes, the feed keeps everything (small, fading); pop-ups stay one at a time.
b) Only the important ones (loot, kills, downed, extract) go in the feed.
c) No feed.
PICK: a. It is your standing order, already built and tested; the redesign only has to place it well.

## F33. "No tutorial prompts" versus key hints
TYPE: contradiction
THE RULE: Q70 (10-18): "No tutorial prompts. The game must be completely self-explanatory." afternoon-orders (10-18): "Fortnite-style live key/pad prompts". Q27 #4: "guests can't tell how to start".
THE CLASH OR GAP: Live key and pad hints, a how-to-play attract screen and "E loot" style prompts are all prompts. The line between a "tutorial prompt" and a "label" is not drawn.
WHY IT MATTERS: Party. Guests need to know what to press without being lectured.
DRAFT QUESTION: Guests must understand it without a tutorial. What may the screen show?
a) One-word action hints beside things you can use (with the live key or pad button), plus the how-to-play attract screen.
b) No hints at all.
c) Hints for the first minute only.
PICK: a. That is the live-prompt style you ordered, with nothing that reads like a lesson.

## F34. When are the real 2-player test sessions
TYPE: undecided
THE RULE: Q35 (10-18): "First real 2P test: TODAY, 10/18." Q36: "As many sessions as he can."
THE CLASH OR GAP: No days or times, and no say on which build he plays (the live one today). Round 2 Q31 (rehearsal date) is not answered. These sessions are the only evidence the party will work.
WHY IT MATTERS: Party. Sessions found today's real problems.
DRAFT QUESTION: When do you and your son test the 2-player demo?
a) Each evening 10/19 to 10/23 for about 30 minutes; a full dress rehearsal Wed 10/28 on the lock candidate.
b) Weekends only.
c) When it happens; you tell me.
PICK: a. A set time means helpers can have a fresh build ready and fixes come back before the next session.

## F35. What may ship without his yes
TYPE: undecided
THE RULE: RULEBOOK (10-02) rule 1: "A QUESTION NEVER HOLDS UP WORK. Ask, then keep going on the best default. If he rules differently, switch." And: "I ask first, then keep going on the best default: design changes that change how the game plays, removing a feature, anything he may dislike the feel of." Q8 (10-18): lines may be cut with a logged reason. Memory DECIDE SMALL THINGS: found a defect = fix it, report done.
THE CLASH OR GAP: "Keep going on the best default" lets a gameplay change ship before he answers. Before the cutoff that is fine; in the last week the build may be played at the party before he rules. Round 2 Q85 (what counts as small) and Q40-42 (what is cut, who decides) ask pieces of this.
WHY IT MATTERS: Party and game.
DRAFT QUESTION: In the last twelve days, which changes may ship without your yes?
a) Bug fixes, looks and words inside the style guide, and test fixes. Anything that changes how the game plays (damage, speed, loot, the map) waits for your yes.
b) Everything except removing a feature.
c) Everything; you tell me what you dislike.
PICK: a. It keeps the helpers fast on the safe things and keeps the feel of the game in your hands.

## F36. Side-agents on his plan versus the standing "no agent teams" rule
TYPE: contradiction
THE RULE: RULEBOOK (10-02) rule 3: "no agent teams or workflows unless he asks". Memory FOCUS: TWO-PLAYER: "no agent teams unless asked". Memory PACE THE SESSION LIMIT: fan-outs burn the window; WORKFLOWS SHARE BUDGET: never two workflows at once. RULES.md (10-18): "Never start agents, workflows, cloud sessions or scheduled tasks." (for Console helpers).
THE CLASH OR GAP: The coordinator itself runs Sonnet agent lanes (d, g, h) and several background agents at a time on his plan today, plus CLI lanes e and f. The standing rule says none unless he asks, and F13 shows the plan meter is ahead of the line.
WHY IT MATTERS: His time and usage. The plan is also what he wants to keep for "other stuff".
DRAFT QUESTION: May the coordinator run several side-agents on your plan at the same time?
a) Yes, up to 3 at a time while under the weekly line, none when over it.
b) No; only the coordinator and plan lanes e and f.
c) Any number.
PICK: a. It is how work is getting done now, and the weekly line keeps it from eating the week.

---

# Settled (older rule overridden by a later ruling; no question asked)

- RULEBOOK 10-02 "alpha for friends at Halloween (2026-10-31)" and "Release for others" -> Q16 (10-18): no 10/31 launch. Party 10/30 only.
- RULEBOOK 10-02 "Co-op first, PvP later, up to four" -> Q33 "No more than 2 players" and Q72 "Hide PvP".
- RULEBOOK 10-02 "I never: ... reword a line he edited" -> Q8: may shorten or delete with a logged reason (F28 only asks about the protect-list).
- The burn memos (BURN 100% IN 48H, BURN THE WEEK, SPEND THE WEEK IN A DAY, PACE MEANS PACE) and ten-answers "HARD CAP 70%" then "80%" -> hard-pacing 10-18: 85% of the week by the reset.
- "$10 extra usage" notes -> Q3: "No paid extra usage."
- The Cloudflare collector in the hosting memory -> the local collector at :8799. The cloud credit is gone; never use cloud.
- BETA IN 40 HOURS, ALPHA TO FRIENDS and the 09-14 ship flow are history.
- "Balancing before alpha" -> balancing is allowed now (no-balancing memory, RULEBOOK 10-02).
- Style guide "Credits 900 · XP 0 ... Never '$'" -> Q59: "$ for money, SP for score". Style guide "sentence case" -> afternoon-orders 10-18: all lower case. Style guide "amber" focus and accent -> Q46: the lime accent. Style guide "No ui-refs pictures exist yet" -> arc-raiders-1..5.jpg now exist.
- Task 05 item 5 (pad rule) -> already shipped as cw-p2pads (v30.70).
- Both URGENT items in questions.md -> fixed (lock file gone, p3069/f3069 restored).
- Q7 close-X versus the old CLOSE-footer order -> Q43: centred card with an X; the style guide wins (Q7).
- hard-pacing "Sat 10-25" -> the reset is Sunday 10-25 05:00Z.
- local-llm memory "corpus ONLY from 22:00 to 07:00" -> obsolete; nightly.sh runs the corpus at most every 4 hours on a new HEAD.
- Round 2 Q82's pick (a daily Console cap) was written for more credit than is left (see F11).

# Coordinator-only fixes (no question needed; not counted)

1. CLAUDE.md: rewrite the stale parts (says "Dark Raiders" and "Daniel"; "Read DESIGN.md at the start of every session" for a 5.3 MB file; version steps; "node --check"; "New features only when Daniel asks"). Plan-lane `claude -p` runs from this repo probably auto-load it.
2. nightly.sh header: fix (2) corpus wait text (code says at most every 4 h), "at most two test Chromes" (real count 13), (5) "Console worker ... one Claude task at a time" (now lanes), and the light.flag/he-is-here wording.
3. RULES.md: lanes a to h, the Chrome count, the stale pointer to pillagers-sunday-start-2026-10-18.md, a vetoes list for helpers, and the post-lock behavior once F3 is answered.
4. Party day stop list: step 12 (watchdog task already disabled 10-18 11:25) and the claim that the runner restarts itself.
5. PC-HANDOFF.md (last touched 10-14, 112 KB) and START-HERE pointers.
6. style-guide.md: put Q59, lower case, the lime accent and "ui-refs exist" into task 04 so helpers stop copying the old text.
7. Tasks 03 and 12 both include screens 46 and 56 and run in lanes b and c at once: split them.
8. Re-queue failed jobs 13-ui-end-cards, b-31 and c-31 with pointers to Q7, Q8, Q43 and Q59 (after F27).
9. The queue holds only UI and party-launch tasks; there is no 2-player bug-fix task from today's real 2P test.
10. Move the ship pipeline scripts out of the session scratchpad (tied to session id 8a09e991) into a tracked folder.
11. Memory fixes: the console-worker memory says "3 runs" but MAXRUNS=5; sunday-start and ui-program states are stale (HEAD v28.78, "no Claude fixes before the reset", "skip LLM"); decide whether the local LLM audit stays (it still runs with 20+ GB free).
12. Round 2 text: fix Q80's order (F22) and Q82's pick (F11) before it is asked; fold Q1, Q31, Q32, Q39-42, Q43, Q81, Q83-85 and Q99 into the findings above so each is asked once.
13. Task 05 "tell the session" about the fuzz pad slot has no channel; use a note in the report.
14. Update the What's New stamp (drift is 0.15, the ship STOPs at 0.16).
15. changes.md has an entry dated 2026-10-19; check its date.
16. Add stable-known-red.txt or its equivalent (needed for F4 whatever he answers).
