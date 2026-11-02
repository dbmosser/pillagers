# Lone-move runner diff: the rule, the window, and what it weakens

Base: `tools/spare/spare-runner.ps1` at 77983f9b (blob 7a01e90f). Apply `runner-lone.diff`; the result is blob affb21b2. Spare PC only.

## What it changes

- One move of the input time alone, with no window change within half a second, is a lone move. It is not a person. It logs a line, restarts the passive signs' 2 hours, and holds new work for at least 65 s, as a window move does.
- A second move within 10 s is a person, seen about 0.7 s after it. The log says "the input time moved again 4 s after a lone move (pair 1 since this copy started)". The stop and pause lines still say "keyboard or mouse".
- A window move within 10 s after a lone move is a person too, so one quick tap that launches something still counts once its window comes, up to 10 s later than on master. That needs the window to move the input time, which is measured only for Chrome and Notepad.
- A move with no window change of its own, within 1 s after a window move, is a person. Without this, a click on a background window with the mouse still was a window move plus a lone move, so nobody. Master caught that case, and the reviewers found this one.
- Lone moves count towards the third in 30 s and the sixth in 10 minutes, shared with window moves.
- Two moves seen together inside half a second are a person, as on master.
- No change to the pad, another account at the screen, the passive signs' own code, or IDLE MODE, which never loads the watch.

## Why 10 s

Measured on 11-02, all with no game and no new window:

- 16:02:48: not logged finely. It stopped the tests.
- 16:05:14: one move on a 100 ms poll. I had just launched a log, so it may be mine. It lengthened that pause.
- 16:22:32: one move on a 10 ms poll, nothing of mine starting. It stopped the tests again.

That gives gaps of 146 s and 1038 s, then none until at least 18:42. Both gaps depend on 16:05:14; without it there is one gap of 1184 s. A robot was running at 16:02:48 and 16:22:32, but not at 16:05:14, and robots ran for hours with no move. A move also came about 6 s after a test window opened, which is why a move over 1 s after a window move isn't a person.

**The data does not pick 10 s.** Anything under 146 s passes every measured gap, so this is a judgment, and 10 s is the top of your "a few seconds". I chose it for a tap followed by a window, since a launched window can take several seconds to appear.

- 5 s is the alternative. It only loses someone who makes exactly two single taps 5 to 10 s apart and then stops, and a window that takes over 5 s after its tap. It also wouldn't pair a 6 s echo if one ever follows a lone move.
- 30 s triples the chance pairs and overlaps the third-in-30 s rule.

Chance pairs a day, each one the old cost of a 15-minute pause and any running gate job. These assume moves at random, which is an assumption over very few gaps:

| Mean gap between moves | 5 s | 10 s | 30 s |
|---|---|---|---|
| 592 s: the 20-minute cluster, 16:02:48 to 16:22:32 | 1.2 | 2.4 | 7.2 |
| 4620 s: the shortest mean that the paused share of 10-28, 10-29, 10-30 and today allows, so the most pairs those days allow | 0.02 | 0.04 | 0.12 |
| 8440 s: 3 moves from 11:40 to 18:42 today | 0.006 | 0.012 | 0.04 |

The weekend is left out: 48% to 96% paused while the runner was on, which may be real use. The table counts two lone moves, not a lone move and then a window; that is listed under costs.

The new line gives the gap of pairs under 10 s, so narrowing can be judged. It has limits:

- It can't show gaps just over 10 s, or tell a chance pair from a person.
- It can't tell a window from a second move, and it names no program, so a false pause from a program's window is the one case where the log hides that program.
- Two pairs between looks show only the latest gap, with the running count showing the drop.

## What it weakens, for your ruling

Two of your limits are not fully kept: the first real person (item 1) and a game always pausing (item 4). Figures come from the runner's own C# on a fake clock unless marked. Most important first.

1. **The first real person is not always seen within seconds.**
   - All input between two looks is one move. A quick tap or short nudge can be one lone move, and with nothing after it the person is never seen by the input time.
   - Tap missed, by how long the key is held, at the poll gap measured here (median 108 ms, longest 134 ms): 20 ms 81%, 50 ms 54%, 90 ms 17%, 110 ms 0% (18% at the longest gap), 140 ms 0%. From memory, a tap is often 70 to 120 ms, so about 35% to 0% of single taps. A wheel notch is probably always one move.
   - After a miss, the next input within 10 s, or any input spanning two looks, is a person about 0.7 s later, then waits for the runner's next look: about 5 s between rounds, longer during one. After a press that changed the window, "within 10 s" holds only within 1 s, so one more single move is missed too.
   - A click on a background window held over 1 s with the mouse still is also missed: the release is a lone move. Master catches it.
   - **Not measured on this PC:** tap lengths, wheel notches, a key's release moving the input time, a click activating a window on the press, and a game or launcher window moving the input time. The tap table, the 1 s rule and the window rule rest on those. Nobody was here, and I won't fake input.
   - Not in this diff: a poll of about 16 ms would make nearly every tap two moves, but not a wheel notch. It needs measuring first (one window, and more samples of the moves), because a window change that moves the time twice would then read as a person.
2. **Someone whose only input is single moves more than 10 s apart is seen late, or never.**
   - Every 10 s or less: at the second. Over 10 s to 15 s: at the third, 20 to 30 s. Over 15 s to 120 s: at the sixth, 75 to 600 s. Over 120 s: never.
   - Lone moves no longer renew a pause, so tests restart 15 minutes after the last counted input, under someone scrolling that slowly.
   - Full screen, sound and the graphics card still catch a game or a film. The input time alone can't do better: this pattern looks just like the measured moves.
3. **A program or device making at most 5 lone moves in any 10 minutes, with gaps over 10 s and no three in 30 s, is invisible.**
   - Every 120 s: the sixth is a person, and the pause then never ends (from a port of the code). Every 120.1 s: never a person.
   - An anti-idle tool or a flaky device at that pace shows only log lines, and `runner.log` isn't published. Nothing tells anyone off this PC. You could add a status field or a PROBLEM line.
4. **A game started by one lone move with no window inside 10 s no longer stops running tests at once.**
   - This is new ground. Your ruling (1) covered a game with no input; here there was a real key that didn't count, so it needs its own ruling.
   - Running work goes on until the first passive sign. After the hold of at least 65 s, a gate job, robot or full run can start under a game still loading with no sign, where master held 15 minutes from the tap. Stop-Work ends them when the sign shows.
   - A game with no passive sign, played with no input that counts, doesn't pause.
   - It needs a single-look tap with the mouse still and a window over 10 s later or none. A double-click, or a press spanning two looks that didn't change the window, is a person as on master. A window inside 10 s is a person when it comes, up to 10 s later than on master, provided it moves the input time.
5. **A late look merges inputs.** If the runner's thread misses looks for any length of time, everything in that gap is one move, even a whole key press. After 3 s the raw time answers only if the runner asks before looks resume, and then it stops work once with no pause. Low harm: the next input seen in two looks is a person.

## What it costs, and where the benefit stops

- **Clusters.** Irregular clusters averaging about 146 s bring the pause back through the sixth-in-10-minutes rule. A steady pace over 120 s never does. Simulated share of time paused, moves at random, from a port: 62% at a 146 s mean, 14% at 300 s, 2.8% at 592 s, 0.8% at 1038 s.
- **Against master.** Every person it says follows a move master already called a person, at most 10 minutes earlier, so it starts no pause from nothing (249,181 random timelines on a port). But it can say person on a window move master excused, so a pause can end later than master's: up to 10 s for a tap then a window, and up to 10 minutes through a later window's sixth. With lone moves only, it paused no longer in any of 300 random runs at each of those means.
- **A lone move then an unrelated window inside 10 s is a false pause.** That is about 1.7% of windows at a 592 s mean, and there are few windows today, so about 0.03 a day. If the unknown cause ever comes up to 10 s before a program's own window, every such launch would pause the tests. Only one Notepad test has measured that, and it logged no stop. Master calls the lone move a person anyway.
- **Windows with an echo.** If windows bring the 6 s move measured once, three windows in 10 minutes reach the sixth, not six. A window, a lone move and a window inside 30 s is a person.
- **The 1 s rule can still pause falsely** in shapes not yet measured, such as a window closing with the front NULL for a moment, as master does. It has no log line of its own.
- **The hold.** A gate job waits about 100 s after a lone move between rounds, and up to a round longer (4 to 6 minutes when slow) if a round starts meanwhile; `gate-remote.sh` allows 60 minutes. The robot, a stopped run and a full run are asked once a round, so a hold can cost about 5 minutes plus the round. A lone move during a test copy build throws the copy away, and its try is given back.

## Same on master, not from this diff

- A new copy's first look counts the last move as a person, so a restart within 15 minutes of a lone move still pauses for what is left. A runner's own restart only happens with no gate job running; a copy revived after a crash can stop one.
- A lone move restarts the passive signs' 2 hours, as it did when it counted as a person, so the cap doesn't end while moves keep coming.
- Input early in a slow round is only acted on at the next look, or for a short burst more than 30 s before Watch's first look, at the top of the next round, up to about 10 minutes later. So "within seconds" already has this gap on master.
- A taskbar click with the mouse still can read as two window moves, so nobody.
- The 2-player guest daemon has no check for someone at the PC. The camera and guest Chromes aren't exempt from the graphics-card game sign, and the camera isn't from the sound sign either. Nothing has shown either going wrong.

## Proof, and what isn't proved

- `lone-mock.ps1`: 353 checks pass, including master's C# beside the new one over random timelines with no lone move, and the real C# wired behind AwaySec, Arrived and FocusHold.
- `lone-mutants.ps1`: all 77 deliberate breaks are caught, run on this code before a last edit to the comment only. A break that stops the mock counts as missed, and the unbroken runner must pass first.
- Undoing the diff gives master byte for byte, outside the comment above FocusWatch, and that comment zone is checked to hold only comment lines. The older mocks: 17 run, all the same as master (4 fail on both).
- Nothing here opens a window or sends input.
- **Not proved:** a real key or mouse pausing on this code. Nobody has been at the PC, and I won't fake it.
- **Cause of the moves: unknown.** A log with time stamps and hardware-or-program only, and no keys, positions or titles, is waiting for the next move. It tells hardware from program only if the move comes with a mouse report; otherwise it only rules the mouse out. I'll stop it and delete its output once it answers, or at midnight.
