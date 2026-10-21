95-p2-own-process : on a plain top-level page player 2 opens in its own process (noopener), so the two TVs stop sharing one main thread, without breaking the pick, RETRY or the camera recipes (coord-06 and coord-07, 2026-10-21)
Queue (coordinator 10-21 02:45): AFTER 85a-itch-couch-link (same functions: netSamePick, netSameChan, netSameOnMsg), never side by side. It helps only top-level pages (his own server, the party copy), not itch. His 10-20 23:00 order lets it ship before the Thu 10/29 lock, but only behind a switch (below).
effort: high
After: 85a
If a job named in After is still open (in tasks/, waiting/ or running in a status file), end with TASK WAITING: its file name and what for. Step 1 decides go or stop.

Source (his words, verbatim):
- 1-78 #27 (memory pillagers-answers-1-78-2026-10-18.md): "Worst problems, in order: stutter or harsh sound; crash or freeze; P2 pad or window fails; guests can't tell how to start"
- 2.43 (q-round3/answers.md line 47): "a: Anything under 60 for more than a few seconds"
- 2.11 (q-round3/answers.md line 17): "a: The full size of each TV (sharpest, hardest on the PC) | NOTE: both screens are 4k, 144 or 120 hz"
- 2.94 (q-round3/answers.md line 94): "b: The 2-player couch mode (it is the unique thing)"
- 76 (q-process/answers.md line 156): "a) Both, couch mode up front | NOTE: couch mode IS career mode though"
- 10-20 about 23:00 (CLAUDE.md): "quit queuing stuff for after the party -- just do it all as it naturally arises"

Measured (coord-06 2026-10-21, raw files in tools/handoff/console/notes/coord-06/; coord-07 in notes/coord-07.md finding 3):
- raw-T1-plain.json: with the game's own window.open, a 2000 ms busy loop in window A gave window B a 2002.3 ms gap (baseline 11.2). Same renderer pid.
- raw-T1-noopener.json and raw-T1-noopenerpopup.json: with noopener (alone or with the game's popup features) B's gap was 11.1 and 11.5 ms, with separate pids. BroadcastChannel, localStorage and storage events all worked. window.open returned null.
- raw-T1-twice.json: two noopener opens with one name gave TWO windows (the name no longer finds the live one).
- raw-T1-cut.json, raw-T1-cutnav.json: cutting the opener after the open does not move B to another process.
- raw-T4-control.json: the real game top-level links in 1.4 s.
- coord-07: unthrottled the pair needs 17 to 18 ms of main-thread work per window on the VM (1 player: about 8). Budgets: 16.7 ms at 60 Hz, 8.3 at 120, 6.9 at 144.
- The robots already run player 2 with no opener every night (tools/fuzz.ps1 Start-2P line 307; Target.createTarget line 189), and the pair links.

Not done (coordinator read of the working tree, VER 33.57; line numbers are about, function names are the anchors):
- netP2Features (about dark_raiders.html 56712) has no noopener, so Chrome keeps both pages in one renderer process.
- netSamePick (about 56736): window.open at about 56760; a null return is read as "the browser blocked the second window" at 56761; NET.p2win is set at 56762; focus() on a re-pick while linked at 56747. RETRY reloads an unlinked player 2 by reusing the name 'pillagers_p2' (comment at about 56743-56746). With noopener the name no longer finds that window.
- kbMarkTick (about 56991-56993) reads NET.p2win.closed for the keyboard chip.
- The hostup receiver (about 56866) has no sender since v32.01, so after a host reload nothing re-finds the pair until player 1 picks again. That stays as is: this job does not bring hostup back.

What to do. The embedded path (reportEmbedded() true) keeps the opener and today's behaviour, because 85a needs it. No new Settings row. No change to pads, rumble, sound, the 75 s p2live and p2raid marks, the pad lost and press a flow, the WebRTC link or the HID worker.
1. Measure first (go or stop; no ship). Use your lane's camera port (9361-9363, never 8802) with --disable-popup-blocking (uishots -NoPopupBlock does this).
   - Run coord-07's runC (notes/coord-07/c-stage.js) as it is. It swaps netP2Features to a string with no noopener, so it measures today's shared case.
   - Then run a copy, notes/95/c-stage-split.js. It swaps in the step 2 string and finds the guest through CDP Target.getTargets (url has p2=1), not NET.p2win.
   - 3 repeats each, unthrottled and at the coord-07 throttle. Also coord-06's stall test: a 2000 ms busy loop in the host, then player 2's largest 10 ms interval gap.
   - Go when: separate pids, a stall gap under 50 ms, and a player 2 p95 gap at least 20 percent better at the throttle. Otherwise stop: write the numbers in notes/95/ and report TASK PARTIAL.
2. netP2Features: append ',noopener' only when !reportEmbedded(). It stays one function, so a recipe or a measurement can swap it back (c-stage already does).
3. netSamePick, the opening state:
   - If window.open returns a window (a stub, a recipe without noopener, or the embedded path), do exactly what happens today and return 'opened'.
   - If it returns null and the features asked for noopener, return 'opening'. Run the same host setup as today (NET.same='host', NET.mode, netStartHost, netSameChan, netPadInit, netSndInit, netSameHostLink), but go() waits. The title stays up with the modemsg callout "opening player 2" and no RETRY.
   - The first 'ready' word from this pair clears the note and runs go() once.
   - No ready within 8 s: back to today's blocked state. Clear like netSameStop, show the existing popup sentence and RETRY, and the title stays. Run the timer through a netSameWatch(now) function the check can drive.
   - Safety net: a RETRY pressed after an 'opening' timeout opens with today's features (no noopener). The worst case is then today's one-process pair, which links.
4. No second window:
   - On the noopener path, when netInCount()===0 and p2live is under 6 s old (it is written every 2 s), first post a pair-free word on the channel: {t:'p2goto',pair,mode,arc}. Wait up to 1 s; Chrome's user activation lasts 5 s, so a later open still works.
   - A player 2 window that is not linked (NET.role empty) and not in a raid answers {t:'p2going',pair:<the new pair>}. It then moves itself with location.replace through a small seam, netP2Go(url). The url is netP2Url(mode,pair) built on its own side, never a URL taken from the word.
   - Host on p2going: no window.open; go to 'opening' as in step 3. No answer in 1 s: open as in step 3.
   - The v20.35 refusal (p2RaidNow, about 56756) still runs first.
   - Handle p2goto in netSameOnMsg before the pair filter, and only when NET.same==='p2'.
5. Without a handle:
   - A re-pick while linked (about 56747) posts {t:'focus'}. Player 2 calls window.focus(); a browser may ignore it, and nothing depends on it. Keep NET.p2win.focus() when a handle exists.
   - kbMarkTick: partner up = handle ? !closed : (netInCount()>0 || p2live under 6 s).
6. Player text: "opening player 2" only, lower case. The existing popup sentence and RETRY stay word for word.
7. Tests and recipes that need a change (rerun all the others):
   - mkfixture v15.76, step THREE (about tools/mkfixture.ps1 70483-70497). openRet=null now gives 'opening', not 'blocked'. Expect 'opening', the title up and no start. Drive netSameWatch(+8.5 s), then keep its blocked asserts as they are. The RETRY step with openRet=win stays.
   - notes/shots/62-share-drop/camera-recipes.json stageDropPair reads NET.p2win after a real popup, so it breaks. Swap netP2Features to the plain string before the pick, as c-stage does: pictures do not care about processes.
   - coord-07 c-stage.js: no change. It stays the "before" measurement; c-stage-split.js is the "after".
   - Expected unchanged, rerun to confirm: v17.35 (about 63506; it sets NET.p2win, so the handle path still focuses), v20.35 (about 57123; the refusal comes before the open), v23.54 (about 45191), v15.77 (about 69889), v33.16 (about 7428; the party callouts list must accept "opening player 2"), the 30.79 group (SKIP).
   - tools/fuzz.ps1 Start-2P (line 320) stubs window.open with a window object, so it keeps the old path. Its player 2 already has no opener. No change.

Check (new, must fail on the build before):
- On the top-level fixture page, netP2Features() contains noopener. With reportEmbedded stubbed to return true, it does not. Fails today: no noopener.
- window.open stubbed to record and return null, plus a channel stub. netSamePick('coop',start) returns 'opening'; the title stays on; start count 0; modemsg reads "opening player 2"; RETRY hidden. Then netSameOnMsg({t:'ready',pair:NET.pair}) gives start count 1, the note gone, NET.same 'host'. Fails today: 'blocked'.
- null and no ready: netSameWatch(t0+8500) shows the popup sentence and RETRY, NET.same is '' and start count 0. A RETRY then opens with features that have no noopener.
- p2live set to now, no link: the pick posts p2goto and calls window.open 0 times. A p2going within 1 s gives 'opening' and 0 opens; no answer gives 1 open after 1 s.
- Player 2 side: p2goto with NET.role empty calls the stubbed netP2Go with netP2Url built locally. While in a raid, or when linked, it does nothing.
- kbMarkTick with NET.p2win null and p2live fresh puts the chip up.
- Two-window camera (lane camera port, popups allowed, never 8802):
  - a real CDP mouse click on 2 PLAYER CO-OP in the top-level fixture; both rosters 2 within 5 s
  - Target.getTargets shows 2 pages
  - the stall test: the host busy for 2000 ms gives player 2 a largest gap under 50 ms (before: about 2000)
  - Browser.getWindowForTarget shows the 90 percent popup size
  - both windows ascend into a raid; the c-stage fake pad moves player 2; "p2 pad lost" shows 1.5 s after the fake pad stops and goes away when it comes back
  - a second click on the row while unlinked still leaves 1 player 2 page
  The seed 4242 fingerprint holds.
Then write the step 1 numbers and the after numbers beside coord-07's in notes/coord-07/.

Party risk: medium-high. This is the exact pairing path he uses at the party. The RETRY fallback in step 3 means the worst case is today's one-process pair.
Watch line: "when you pick 2 player, the second window should open once, in under 2 seconds; if the title sits on opening player 2, press retry and tell me. in raids, watch whether one tv still hitches when the other loads or saves."
Size: about 0.5 lane-nights:
(a) step 1, the measure and the go or stop note (no ship)
(b) steps 2 to 7 in one ship: they only work together

TASK DONE when step 1 says go, the ship passed with its check, the two-window camera passed and the before and after numbers are written; TASK PARTIAL with the numbers if step 1 says stop or something is left.
Coordinator corrections 10-21 (skeptic verify of the plan, binding; they override the steps above where they differ):
- Party safety: the own-process path ships behind a switch in the Experimental menu (job 61's menu), OFF by default, lower case label, so the party copy behaves exactly as today unless he turns it on. It goes on by default only after he has tried it on his two TVs (the Wed 10/28 rehearsal) or his own export shows the pair over budget. Say so in the watch line.
- step 3: do not call netStartHost or netSameHostLink until the first ready arrives. Otherwise the timeout must run netReset(true) as well as netSameStop. Add asserts after the timeout: NET.on false, NET.role null, NET.pend null, and arcadeSoloPick() returns 'solo'.
- while 'opening', a re-pick or RETRY returns 'opening' and does nothing. RETRY after a timeout runs the step 4 p2goto first and opens with opener features only after the 1 s with no answer. Test a double click within 300 ms and a late window that boots at 9 s: 1 player 2 page each time.
- shorten the ambiguous wait. Treat a fresh p2live, or a pair-free 'booting' word, as proof of open, and drop the timeout to about 4 s. Say in the job that a popup block now takes that long to show.
- step 4: send p2goto whenever netInCount()===0 (not only when p2live is under 6 s), or use the existing 75 s p2LiveNow. Player 2 accepts p2goto whenever it has no live link and no raid (netInCount()===0 && !raid), not only when NET.role is empty. kbMarkTick uses the same 75 s rule, or the handle.
- Every timer in 95 and 85a (the 8 s, the 1 s) runs through drivable seams ticked from the frame loop, with no raw setTimeout. Each check resets NET and the seams so its two gate runs and the checks after it are clean. Checks hard-fail (never skip) when a function is missing, and stub reportEmbedded both ways.
- camera: click the 2 PLAYER ARCADE DEMO row as well as co-op. Run the pad in forward mode (fake pad in the HOST window, handed over to player 2) during the 2000 ms host stall, and state plainly that player 2's controls still freeze with a host hitch. Add host F5 then re-pick (1 player 2 page), and P2 sound starting without --autoplay-policy.
- go or stop: decide on unthrottled numbers and the stall test, not cross-model throttled p95. Add a passive in-game record (each window's largest frame gap and the other window's at the same moment) to the flight recorder, so his party export shows whether the split really happened on his PC.
- Party copy: before 95 ships, tag the last commit without it (for example party-pre95), so -Prepare -Ref can fall back. Put 95 in the party copy only after he has played a two-TV rehearsal on his PC with the watch line. Fix or retire party.cfg URL_OPTIONS=1.
- His pads: Chrome feeds pad data only to the window in front, so player 2's pad reaches it through player 1's window (netPadSend). A hitch in player 1's window still freezes player 2's controls after the split. Write that plainly in the result; do not claim the split ends all stalls.
