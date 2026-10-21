# Your first real 2-player test (Sunday 10/18)

Player 1 plays on keyboard and mouse. Player 2 plays on an Xbox pad. Each player has their own window, and each window goes full screen on its own TV.

This sheet is checked against the game's code (build 30.70, which has your two rules of 10/18: the keyboard goes to the window in front, and the first pad is player 2's, the second is player 1's). Nobody has run this on the real TVs yet, so tell me anything that does not match.

---

## Before you start (5 minutes)

1. **Free the PC a little.** The overnight robots and the helpers share this PC, and the robots keep running even while you are here. If the game stutters, that is the first suspect. Tell me "quiet" and I will have the robots and helper lanes stopped for the test.
2. **Screens.** Turn on both TVs. Press **Windows key + P** and pick **Extend**, not Duplicate, so each TV is its own screen. In Settings > System > Display, the "Identify" button shows the number on each screen.
3. **Pads: the first pad you switch on is player 2's, and the second pad is player 1's.** (Your order of 10/18: the first controller plugged in controls player 2 only, the second controller plugged in controls player 1 only.)
   - Switch on the pad player 2 will hold FIRST. The game calls it Controller 1 and gives it to player 2 only.
   - **One pad alone goes to player 2.** Player 1 then plays on keyboard and mouse. This is the normal setup for today.
   - If you want player 1 on a pad as well, switch on a second pad AFTER the first. The game calls it Controller 2 and gives it to player 1 only.
   - A window never plays the other player's pad, even when both windows are full screen and showing at the same time.
   - On an Xbox pad the ring of light shows its number: usually one segment lit means Controller 1, and two segments lit means Controller 2.
   - If you used the CONTROLLER row in the party window before (it picks a pad for a window by hand), the game clears that old pick once, the first time the new build loads. Pick again there only if you want to override the order.
4. Use **Chrome**. The second window and full screen are built for it.
5. **No shortcut.** Your order of 10/19: the party is just the demo. Use the steps below.

## The test, step by step

1. Open Chrome and go to your normal address: `http://localhost:8802/dark_raiders.html`.
   - This is the newest build, so it may change between reloads. `stable.html` on the same address is steadier but older (currently 29.09).
   - If the page does not open, the little game server is not running. Tell me, or run `tools\start-servers.ps1`.
2. On the title screen, click **2 PLAYER ARCADE DEMO**. It is the third row, under 1 PLAYER and 2 PLAYER CO-OP (SAME MACHINE).
   - It may read "2 player arcade demo". The words are being tidied.
   - The row opens the second window by itself. You do nothing else to open it.
3. **If Chrome blocks the second window:** a small "pop-up blocked" icon appears at the right end of the address bar, and the game says "The browser blocked the second window". Click the icon, choose **Always allow pop-ups from localhost:8802**, click Done, then click **RETRY** on the game's title screen.
4. What you should see now:
   - Window 1 turns into the party screen: a scoreboard, a how-to-play page, and PRESS ANY BUTTON.
   - Window 2, called "Pillagers, player 2", appears over most of your MAIN screen at its top-left corner. It shows PLAYER 2: PRESS A.
5. **Put each window on its own TV.**
   - Drag the player 2 window by its title bar onto TV 2. Or click it and press **Windows + Shift + Left or Right arrow** to jump it to the next screen.
   - Click inside it once, then press **F11**. The game handles F11 itself in this window, and it goes full screen on that TV.
   - Do the same with the player 1 window onto TV 1: move it, click it, press F11.
   - Do this AFTER step 2. A page reload always drops full screen, so start the game first.
   - **Never cover one window with the other.** The player 1 window runs the whole world for both players. If it is covered or minimized, Chrome slows it down and the raid freezes for both players.
   - **The keyboard controls whichever window is in front.** Click a window to give it the keyboard. At the party, keep player 1's window in front (click on TV 1) so the keyboard stays with player 1. (Your order of 10/18: keys control whatever screen is to the top. When you click player 2's window, the keyboard plays player 2 until you click player 1's window again.)
   - Keep the mouse on player 1's screen. The mouse is not shared between the windows: it works in the window it is over. With player 2's window in front, moving or clicking the mouse over it takes player 2's crosshair off the pad until the stick moves again, and while the mouse is over player 2's screen player 1 stops aiming.
6. **Start playing.**
   - Player 1 presses any key or clicks, in the player 1 window (the one in front, with the keyboard).
   - Player 2 presses **A** on the pad (on the title attract, a key or a click in the player 2 window also joins player 2). Either can go first. The one waiting sees JOIN YOUR TEAM.
   - Both land in a teal shield bubble. Moving takes the shield off. (The controls card that used to come up at every drop is gone, by your order of 10/18: no tutorial prompts.)
7. **Play about 10 minutes** (the demo raid is 10 minutes):
   - Shoot, reload, roll, and loot (hold E on keyboard; hold X on the pad).
   - Heal, throw and use items through the item wheel: hold Q (hold D-pad down on the pad), point at an item, and pull the trigger.
   - Switch guns (keys 1 to 8 and 0, a key for each kind of gun, or F for the next gun; LB/RB on the pad).
   - Call the extraction: hold X (keyboard or pad) inside the teal ring.
   - Die once on purpose, to see the respawn and the score reset.
   - Pause once (P on keyboard; MENU on the pad). Open Settings from there, and leave a FEEDBACK note.
8. **At the end** you get the RUN OVER card, then the scoreboard. A top-10 run asks for initials.
9. **To stop:** on the party screen press **Ctrl + Shift + F10**. The operator card has New party and Exit demo. Or just close the two windows. The demo never writes your real save.

### Player 2's pad (Xbox)

| Button | Does |
|---|---|
| Left stick | move |
| Right stick | aim |
| Right trigger (RT) | fire |
| A | roll |
| B | crouch |
| X | reload (tap); search and extract (hold) |
| LB / RB | switch gun |
| D-pad down | item wheel (hold) |
| VIEW | backpack |
| MENU | pause |

Player 1's keyboard keys are listed by F1 in the raid and in the pause screen, and the how to play page that comes round on the party screen shows the keyboard and the pad side by side.

## If player 2's pad is not picked up (try in this order)

1. Press **A** on the pad while a game window is in front. Chrome hides a pad from a page until a button is pressed.
2. Test it outside the game: press Windows+R, type `joy.cpl`, press Enter. If the pads do not show there, it is the pad, cable, or battery.
3. Is it the wrong pad? The first pad switched on is player 2's and the second is player 1's. If player 1 moves when you move this pad's stick, it is the second pad. Turn both pads off, then switch player 2's on first (and the spare second, or leave it off).
4. Is a game window in front? If you clicked the desktop or another program, the pad goes quiet and the game says **CONTROLLER PAUSED: click one of the game windows**. Click either game window.
5. Only one pad? That is fine: one pad alone goes to player 2, and player 1 plays on keyboard and mouse (see "Before you start"). Check that the pad is the first one switched on, and press **A** on it once.
6. Press **F5** in the player 2 window. It links back up by itself within a few seconds. Then press A.
7. Still nothing: close the player 2 window, press F5 in player 1's window, and start again from step 2.

## What to watch for (in your order of worry)

1. **Stutter or harsh sound.**
   - Stutter: where does it happen? A big fight, opening a menu, or the first seconds of a raid? Which window?
   - Both windows play sound through the same speakers. Player 1's sounds sit on the left and player 2's on the right (split speakers is on by default). Does anything sound doubled, crackly, too loud, or sharp when both players shoot?
2. **Crash or freeze.**
   - Does either window stop moving? If both freeze, the player 1 window is the cause. If only player 2 freezes, the link or the second window is.
   - A blank page or error means a crash. Write down the time and press F5.
3. **Player 2's pad or window fails.**
   - The pad does nothing, drifts, or has buttons in the wrong place.
   - The window opens in the wrong place, or does not link (a LINKING message that stays).
   - Player 2 sees enemies or loot in different places than player 1.
   - Pausing: when ONE player pauses, the other keeps playing (the world only stops when both are paused). Is that what you expect?
4. **Guests cannot tell how to start.**
   - From 6 to 10 feet away, can you read PRESS ANY BUTTON and PLAYER 2: PRESS A?
   - TV-size text is on by default in the demo now. Is it big enough?
   - Hand it to someone who has never seen it. Do they work out reload, loot, and extract without being told?

## How to report a problem

- **In the game:** pause (P, or MENU on the pad), click **FEEDBACK**, type a note, and press **Ctrl + Enter**.
  - It saves your words, the version, the time, how far into the run you were, and a screenshot of that moment.
  - The files land in `C:\claudecode\dark raiders\exports\` as `feedback-DATE.txt` and `.png`, as long as the little collector program is running (it normally is). If not, two files named `pillagers_feedback_...` appear in your Downloads folder.
  - A text box right in the pause menu is coming (task c-03).
- **Or tell me in chat.** The useful bits: which window (player 1 or 2), how many minutes in, what you pressed, and what you saw.

---

## Do 1P and 2P share the raid code? (Does a 2P fix also fix 1P?)

Yes, mostly: roughly four fifths of the raid code is the same code in 1P and 2P (I measured by lines of the game file). Player 2 is a second browser window running the same game file, so it builds the same map from the same seed and runs its own player (movement, guns, loot, HUD, drawing and sound) with the exact code 1P uses. The first window runs the whole world for both players (pillagers, machines, boxes and weather), and the second window does not think for the pillagers at all: it draws the copies the host sends about ten times a second and tells the host what it shot. Only the link between the two windows (about 4,600 lines) and the party rules (joining with A, the team score, joining late, the run ending when both players are out; about 1,500 lines) run in 2P alone, out of about 65,000 lines in the whole game. So a fix to guns, pillager brains, loot, the HUD, the map or the sound fixes 1P too, but a bug that only shows in the second window (enemies jumping around, hits not counting, the pad, the window link) lives in the 2P-only part and does nothing for 1P. That 2P-only part is also the newest and least tested code, so expect most of today's findings there.
