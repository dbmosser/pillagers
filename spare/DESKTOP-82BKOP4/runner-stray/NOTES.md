# Stray-mouse runner diff: the rule, the number, and what it weakens

Base: `tools/spare/spare-runner.ps1` at blob affb21b2 (commit ce6e0b3c, and again e67503860). Apply `runner-stray.diff`; the result is blob 220483c04ebde98015a14d767636e180eb9dfdbe. Spare PC only: IDLE MODE never loads this code.

It applies with `runner-onecopy.diff` and `runner-quiet.diff` in all six orders, and every order gives the same file.

## What happened

- 11-02 evening, the input time moved at 21:16:26, 21:22:37, 21:24:16, 21:25:48 and 21:27:33. Each move came with hardware mouse reports, 1, 1, 1, 2 and 1, and no window change. No program reports. Those five are all the moves logged from 16:31 to 21:29, when that log was stopped.
- The 21:25:48 move, the only one with 2 reports, paused the runner at 21:25:56. Most likely two looks saw two moves, which the current rule calls a person.
- The owner, asked about 21:16 to 21:27: "No, nobody". The owner on the cause: "the stray moves are caused by the mouse,its extra sensitive and its on a shaky table".
- That pause should have ended about 21:41 and ended at 21:52. The input time moved at 21:36:46, around a runner restart at 21:36, and the new copy's first look counts what it finds as a person.
- A second pause came from one move at 22:33:48. The runner acted on it at 22:37, after a gate job finished, stopped the full run and held until 22:48. It looks like the same cause, but nothing logged its reports.

## The rule

The watch takes raw input reports for the keyboard and the mouse. From each it uses only the kind, the time and whether it came from a device or a program, and it keeps none of that. It never asks for the input data, so no key and no mouse position reach the code.

- **A keyboard report from a device is a person at once.** This also closes the lone rule's gap, where a quick tap inside one look was missed.
- **5 mouse reports at least a tenth of a second apart, inside 10 s, are a person at once**, for as long as the reports go on. The log calls these "a key press" and "the mouse in use".
- **A move of the input time with a mouse report within half a second, and neither of the above, is a stray.** It isn't a person however many looks it spans. It doesn't count towards the third in 30 s or the sixth in 10 minutes, holds no work and doesn't restart the passive 2 hours.
- **A stray is still a person** if a window changes within half a second of it, or if a window that moved the input time did so within 1 s before it, or if it comes within 10 s after a move that wasn't a stray.
- **A click that launches something:** a window within 10 s after a stray whose last two reports are 40 ms to half a second apart is a person. Two jolts that far apart read the same.
- **A report from a program has no device and isn't used.** Its move goes by today's rules. So does a move with no report near it, which is what every move does if the reports can't open, or if a program at a higher level in front keeps them back.

**A new copy.** A copy restarting itself writes its person time at the four restart sites only (`Save-Watch`, keys `watch_t` and `watch_person`). The new copy takes it if it's under 5 minutes old and this isn't a start after a stale heartbeat (`Load-Hold`), unless the new copy has already seen someone. What the first look found still restarts the passive 2 hours. A crash or a reboot still counts what it finds, as today.

## The number, and why

**5 reports at least 100 ms apart, inside 10 s.**

- Measured strays: 1 or 2 reports each, at least 92 s apart. The two at 21:25 were within about 26 ms, so they count as 1. Two of the worst measured events inside 10 s count as 2, and 5 needs five.
- The 100 ms is for the owner's cause. A jolt can be many reports in a moment, especially at a fast polling rate, and it should count as little more than one. No jolt with more than 2 reports has been measured.
- A hand moving the mouse reaches it in about 0.5 s at 20 reports a second or more, and up to about 0.8 s just above 10 a second. That part is arithmetic.
- One real measurement: real use at 23:42 reached a person 1232 ms after input began, in an earlier build of this diff (see Proof).
- The data does not pick 5 or 100 ms exactly. It only shows that the measured strays are well below them.

## What it weakens, for your ruling

1. **Some real use isn't seen until a key or sustained mouse use:** one click, a double click, a nudge under about half a second, a short wheel flick, a held mouse button, or clicks and notches under 5 in 10 s. On master a second move within 10 s was a person, so someone scrolling a notch every 3 s, or clicking every 5 s, was seen and now isn't. Passive signs still catch a game or a film, but only within 2 hours of the last person or window move. A window after a click is seen only if it comes with the click, or if the click's last two reports are 40 to 500 ms apart.
2. **About 0.4 s of shaking in total within 10 s reads as a person.** A table that keeps wobbling can still cause a false pause. Moving the mouse off the shaky table would fix it, and no threshold can tell a long shake from a slow hand. Two jolts can also pass as a click if a program's window follows within 10 s.
3. **A stray with a program's window, or within 1 s after a window that moved the input time, is a person.** It's rare at the measured pace.
4. **A person in the gap around a restart.** A key or mouse move after the old copy's last write and before the new copy's first look isn't carried over. The next key or sustained mouse use counts at once. The next single stray-sized input doesn't.
5. **The first look after a crash, a reboot or a stale heartbeat** still counts what it finds, as today.
6. **A key report is a person even if it's a stray itself.** Nothing points to stray key reports, but only mouse reports were logged, so that isn't ruled out.

## Not measured, and can't be without more real use

- **The landed runner with a real person.** Real use has gone through this diff's C# in a side process, and through master's runner. It hasn't gone through the patched runner's own pause, because that can only happen once it lands. The mock covers that path with the runner's own code.
- **A game in front at a higher level.** Raw reports may be kept back from a lower-level process then. Moves then have no report, so today's rules apply, which still see a press across two looks and any second move inside 10 s.
- **A game's anti-cheat.** The runner now listens for raw keyboard and mouse reports in the background while a game with anti-cheat may be running. Many ordinary programs do the same and it reads no key, but I can't test how anti-cheat treats it. The owner should hear this.

## Proof

- **`stray-mock.ps1`: 560 checks, 0 wrong.** It runs the runner's own C# on a fake clock and the runner's own AwaySec, Load-Hold, Save-Watch, FocusHold and Arrived, wired together. Undoing the diff gives master byte for byte, outside the comment above FocusWatch.
- **`stray-mutants.ps1`: 109 deliberate breaks of the added lines, 109 caught, 0 missed, 0 stopped.** The list, and which checks caught each, is in `mutants.txt`. Run on this exact build, 11-03 05:31 to 06:28.
- **With no report at all,** the new C# answers exactly as master's over random timelines, lone moves, pairs and late looks included (r1b). That's the case if the reports never open.
- **The evening is replayed** at its real gaps and report counts: nobody, five strays, no burst, nothing held (S3).
- **Part 5 of the mock** opens the real reports on this PC and runs the real thread, with no window, no focus change and no input.
- **Real use, 11-02 23:42.** Someone used the PC. I did not fake any input.
  - Master's runner on the live PC: input began 23:42:33, paused 23:42:38, about 5 s. A running ship gate job stopped and reran at 23:58.
  - This diff's C#, an earlier build, running beside it: keys +4, mouse reports +3103, strays +1, a person seen 1232 ms after input began, by the mouse rule. So real reports do flow through the code and a real hand reaches the number.
  - That side process logged only time stamps and counts. It stopped at 23:59 and its output was deleted, as you asked.
  - Both runner copies were alive then (see `../onecopy/`). That doesn't touch the side process, but the 5 s can't say which copy acted.
- **An independent read-only review** ran at 23:07. Its findings are fixed in this build, listed above as weakenings, or were ruled out by the 23:42 real use.
- **Not repeated on the final build:** the live real-use reading, because it needs someone at the PC.
