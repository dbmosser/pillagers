# cw-pausesets and cw-shkey (2026-10-18, his two notes from build 30.73)

His notes (exports/feedback-20261018-154207-508 and -154339-293, now consumed-):
- 15:42, 29 s into a raid: "accessing settings from pauise menu doesn't work right (maybe due to usperhot?)"
- 15:43, 1:31 into a raid: "superhot mode needs a toggle key."

## 1. Settings from the pause menu (v30.99, cw-pausesets)

Not Superhot. I drove the real path in the fixture (P, the Settings button, a row click, scroll, CLOSE, ESC, resume) with Superhot
off and on, a key and the mouse held, the player 2 window simulated, a pad plugged, and with real (trusted) key and mouse input.
Under the pause box and Settings the world stands still with Superhot on (the pause outranks Superhot's "a held key runs time").
ESC and CLOSE shut Settings first, then the box, then the raid runs on. Two real faults:

1. He plays at 4K (the screenshots are 3838x2158). The Settings and Keys cards took their top and bottom air from
   `calc((100vh - ...) / 2)`. 100vh inside a window that is zoomed (menus are zoomed 1.3x on top of the 2.0x screen factor at 4K)
   is NOT divided by the zoom, so on any screen taller than 1080p the padding grew past the screen and squeezed the list to a
   sliver: Settings looked frozen or empty. v30.89 (cw-cardwide) already overrides it with a plain margin; v30.99 removes the dead
   rule so nothing can bring it back, and the check reads the padding (it must be the card's own margin, never a share of the screen).
2. The Settings window is kept in the page and only hidden, so it kept its scroll offset between visits. A second visit from the
   pause box opened half way down the list. A fresh open now starts at the top; a tab or jump inside the open window keeps its
   place (openSettings now knows whether the window is already open).

Check 30.99 (fails on 30.98): first visit at the top, reopen after a scroll at the top, the raid clock and the player do not move
under Settings with Superhot on and keys and mouse held, a Settings row click leaves box and pause up, CLOSE and ESC order, the
player 2 window (NET.same='p2': scroll reset, ESC shuts Settings only and is not handed to player 1), the list and CLOSE fit at
1080p at menu zoom 1.3 and 1.1, no padding from 100vh. Tested by forcing the old formula live: the padding arm fails.

## 2. A toggle key for Superhot (v31.04 cw-shkey, v31.26 cw-shkey2)

The key already existed: the key left of 1 (Backquote) has toggled Superhot since v7.23. It sets the same dial and the same saved
word as the one Settings row, and nothing on screen named it except CHANGE KEYS (LEFT OF 1). So I did NOT add a second key or a
second row (one control per job). Instead:

- the F1 controls list has a row: ` superhot on/off;
- the pane beside the Settings list names the key under the Superhot row: "key: ` (left of 1)" (his edited hint line is untouched);
- one honest line: on, off, on inside a second left SUPERHOT OFF on the message row and last in the left feed with Superhot on (a
  repeat within a second refreshed the older line where it stood; a later one showed a count). shSay keeps one line, the state just
  set;
- 2-player: Superhot stays the host's dial (his v16.74 order; it rides the world word), so only the host window toggles it. A press
  in the linked window says SUPERHOT FOLLOWS THE HOST and changes nothing (as before). New: the linked window now also says
  SUPERHOT ON or OFF when the host flips it mid raid (the first word of a party stays silent).
- v31.26 (cw-shkey2) says the key in words: the F1 row reads "left of 1  superhot on/off" and the pane reads "key: left of 1". v31.04
  showed a lone backquote tick, which the critic called odd and which was hard to see. Check 31.04 was retargeted (fixture commit
  a9178b07) so it accepts the tick or the words, so it held on both builds.
- Checks: 31.04 (fails on 31.03: stale lines on three quick presses, no key on the F1 list or the pane, no host toast on the linked
  window; passes twice on 31.04) and 31.26 (the words, clear of the word beside them).

## Pictures and critic
- Pause: before notes/shots/cw-pausesets-before (26 at 4K is the collapsed window), after notes/shots/cw-pausesets-after. Critic 3,
  better than before. Its remaining findings (steppers float far from the labels, last row cut by the detail pane, thin scrollbar)
  are the Settings row layout and belong to the Settings lanes, not to this bug.
- Superhot key: before notes/shots/cw-shkey-before, after notes/shots/cw-shkey-after (tick) and cw-shkey-after2 (words). The critic
  scored the F1 list 2 ("same"): it is a long pre-existing wall of keys, and the new row is one line in it.

## Left over
- Superhot is still the host's dial in 2 player (his v16.74 order). If he wants the joined window to toggle it too, that is a
  ruling to reverse, so it stays as is.
- The What is New card needed a refresh (v31.08, polish pass 26) before cw-shkey2 could ship; other lanes were shipping at the same time.
