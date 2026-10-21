# Your 2-player test (checked 10/21 against the newest build)

Player 1: keyboard and mouse in one Chrome window. Player 2: an Xbox pad in a second window. Each window goes full screen on its own TV. A lot has changed since your 10/18 run, so tell me anything that does not match. New: the pixel art look on pillagers and ground. If it stutters, turn it off in each window (settings, experimental, pixel look) and tell me.

## Before you start

1. **Main PC only**, in Chrome, from your party copy (not the VM window: pads cannot reach it). Do the main PC steps first (the Terminal lines headed "Tonight, to play the newest build"): step 1 fetches the newest build, the one this sheet is for; steps 2 and 3 every time.
2. **Keep the PC on wifi or a cable**, or the two windows will not link.
3. If the game stutters, tell me "quiet" and I stop the helpers and robots.
4. **Screens:** both TVs on, Windows key + P, pick **Extend** (not Duplicate). Set each TV's picture size to Just Scan or Screen Fit so the edges are not cut off.
5. **Sound:** both windows use the one Windows sound output (player 1 left, player 2 right; sound per TV was cut on 10/19 to keep it simple). Pick the speakers or TV in Windows sound settings.
6. **Game Bar:** the round Xbox button opens it and takes the game away from the pads. Switch its controller button off for the test (Settings > Gaming > Xbox Game Bar), back on after, and tell players not to press it.
7. **Pads:** plug in player 2's pad FIRST, by USB cable. It goes to player 2 only. One pad is the normal setup: player 1 stays on keyboard and mouse. A second pad plugged in after goes to player 1 only. The order is automatic, nothing to pick. When a window takes a pad, the pad buzzes once (in a raid a small **p2** or **p1** tag also flashes by that pillager for 2 seconds).

## The test, step by step

1. In Chrome open `http://localhost:8802/dark_raiders.html`. If it does not open, do main PC steps 2 and 3 again; still nothing, tell me.
2. On the title, click **2 player arcade demo** with the mouse, not the pad (third row; not 1 player arcade demo below it). It opens player 2's window.
3. **If Chrome blocks it**, the game says "the browser blocked the second window. allow popups for this page, then press retry." Click the blocked pop-up icon at the right of the address bar, pick **Always allow pop-ups and redirects from http://localhost:8802**, Done, then click **retry** under the rows.
4. **What you see:** player 2's window ("Pillagers, player 2") opens in front, over most of player 1's window, and has the keyboard (a key press here joins player 2). It reads "player 2: press any key", then "player 2: press a" once the pad is touched. Player 1's window shows the party screen ("tonight's best" and "how to play" take turns, "press any key" at the bottom). The windows link 5 to 7 seconds after the click; if player 2 presses A before that, player 2's window reads "linking…".
5. **One window per TV.** While setting up, click title bars, not the game picture (a click on the picture starts player 1 or joins player 2).
   - Player 2's window: drag it by its title bar onto TV 2 (or Windows + Shift + Right or Left arrow). Click its title bar, press **F11**.
   - Player 1's window on TV 1: move it, click its title bar, press **F11**. F11 again leaves full screen.
   - Never press F5 in player 1's window during play: the windows lose each other. To start over, see fix step 6.
   - **Never cover or minimize player 1's window.** It runs the world, and player 2's pad reaches the game through it.
   - **The keyboard plays the window in front.** Keep player 1's in front. Once full screen, a click on a TV gives that window the keyboard and also counts (starts or joins on the party screen, fires in a raid). In a raid that window shows a small "keyboard" tag in its top corner.
   - **Keep the mouse on TV 1** (the game does not hold it there yet). Off TV 1 player 1 stops aiming, and a click on TV 2 takes player 2's crosshair and the keyboard.
6. **Start.** Player 1: any key or click. Player 2: **A**. Either can go first; the one waiting sees "join your team". If player 1 starts before the link, player 2's join rebuilds the raid ("player 2 joining": same map, score and clock kept, the map comes up again).
   - Each run opens on the map, frozen. Player 1 clicks (or E), player 2 presses A; "waiting for p2" (or p1) until both have, or 20 seconds.
   - Once the map closes, each window may ask "want easy mode?" (player 1: y or n; player 2: a or b) for what is left of its 12 seconds. No answer means no. A long map can use up the 12 seconds: tell me if you never saw it.
   - Each player ascends in a teal bubble marked "shield". Moving, rolling or shooting takes it off.
7. **Play about 10 minutes** (the demo raid is 10 minutes):
   - Shoot, reload (R), roll (Space), loot (hold E; pad: X).
   - Revive your partner: hold E next to them, about 3 seconds (pad: hold X).
   - Items: hold Q (pad: D-pad down), point with the mouse (pad: right stick), let go, then pull the trigger to use it.
   - Guns: keys 1 to 8 and 0, or F; tap LB or RB on the pad.
   - Air strike: the damage you deal charges it. Once "air strike ready" shows, G (pad: LB + RB together) aims it, and a click (pad: RT) calls it.
   - Extract: in the teal ring hold X about 2 seconds to call for extraction. It comes in about 30 seconds; hold X in the ring again to extract. The first one out sits out until the run ends. Both out: both scores double.
   - Going down: "down", about 17 seconds for your partner to revive you (F or D-pad down gets you up yourself, once per raid). If nobody does: "score lost" (your score to 0, your partner keeps theirs), and you are back after "ascending in 3".
   - Pausing (P; MENU on the pad): the other player keeps playing, and you stand still where you can be hit.
   - 90 seconds touching nothing shows "still playing?"; at 2.5 minutes that player sits out.
8. **At the end** both TVs show "run over" ("extracted x2", "kia -50%" or "ended early -50%"), then "tonight's best". Time running out with someone still in, or end run from the pause box, halves both scores, even for one who got out (your 10/18 pick was that each player's own result counts; not built yet). A run that ends because nobody touched anything keeps its score (your answer was that it should halve too). A run that makes tonight's board asks for initials, player 1 first.
9. **To stop:** when no run is going (both screens on the party screen, nobody in a raid), press **Ctrl + Shift + F10** (during a run it leaves the demo at once). "operator" has "new party" and "exit demo". Or close both windows. The demo never writes your real save.

### Player 2's pad ("pillagers" layout)

| Button | Does |
|---|---|
| Left stick | move (click: sprint) |
| Right stick | aim, pick on the item wheel (click: crowbar) |
| RT | fire, or use the item in your hand |
| LT | focus aim (hold) |
| A | roll |
| B | crouch |
| X | reload; near a box, body, door or the teal ring: search, open or extract (hold); next to a downed partner: revive (hold about 3 seconds) |
| Y | hold: patch up a partner who is standing (uses the heal picked on your belt), or finish a downed pillager bot |
| LB / RB | switch gun (tap); both together: aim the air strike (when ready) |
| D-pad down | item wheel (hold); revive when down |
| D-pad up | ping (twice: danger); hold: map |
| VIEW | backpack |
| MENU | pause |

Buttons feel wrong? MENU, settings, change pad buttons: the layout row picks another (this table is "pillagers"). F1 shows player 1's keys in a raid.

## If player 2's pad or window does not work (in this order)

**Never links** (player 2 still reads "linking…" 20 seconds after A): check the PC is on wifi or a cable, then do steps 5 and 6.

1. Press **A** while a game window is in front. Chrome hides a pad until a button is pressed.
2. Open Start, type game controllers, pick "set up USB game controllers". If the pad is not listed there, it is the pad, cable or battery.
3. Wrong pad (player 1 moves)? Unplug both, plug player 2's in first. Swap pads between runs, not in a raid.
4. No game window in front (a click on the desktop, another program, the Xbox button)? The pads go quiet: "pad lost", or "controller paused: click one of the game windows". Click player 1's window, then press A.
5. Click player 2's screen, press **F5**. Wait about 5 seconds, press F11, then A on the pad. Then click player 1's screen once so the keyboard and mouse come back (in a raid that click fires).
6. Still nothing: click player 2's screen, press **Ctrl + W** to close it. Click player 1's screen, press F5 (if Chrome asks, pick reload). Click 2 player arcade demo again, then redo test step 5.

## What to watch for (in your order of worry)

Look hardest at the pads and the link.

1. **Stutter or harsh sound.** Where: a big fight, a menu, the first seconds? Both windows share one Chrome, so **a stutter in player 1's window also freezes player 2**, controls too. Settings, show fps puts a number top left (in player 1's window it covers the keyboard tag); under 60 for a few seconds is janky. Each shot is heard twice on purpose, once from each side: tell me if one plays twice from the same side, crackles or hurts.
2. **Crash or freeze.** The frozen map at the start of a run is not one. If both freeze, it can be either window: note the time. If player 2's screen says "host disconnected", the link dropped and player 2 plays on alone. Crash signs: "error saved to your run report", "restarted after an error", or a blank or "Aw, Snap!" page. Restart as in fix step 6.
3. **Player 2's pad or window fails.** The pad does nothing, drifts or has buttons in the wrong place. "linking…" on player 2's screen that stays past 20 seconds. Player 2 sees pillager bots or loot in different places than player 1.
4. **Guests cannot tell how to start.** From 6 to 10 feet, can you read "press any key" and "player 2: press a"? Text starts at TV size in the demo: big enough (settings, text size changes it)? Could a first-time guest work out reload, loot and extract with nobody telling them?

## How to report a problem

- **In the game:** pause, click the "report a problem" box, type, press **Ctrl + Enter**. The game says "feedback saved" and keeps your words, the build, the time and a picture. For player 2's window: MENU on the pad, click its "report a problem" box, type, press Ctrl + Enter and wait for "feedback saved", then click player 1's screen on TV 1.
- It lands in `C:\claudecode\pillagers-party\exports\` and reaches me within about 5 minutes. Each finished run also saves its own report there, frame rate included, by itself. If pillagers_feedback files show up in Downloads instead, tell me in chat.
- **Or tell me in chat:** which window, how many minutes in, what you pressed, what you saw.
