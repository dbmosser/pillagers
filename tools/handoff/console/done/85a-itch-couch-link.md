85a-itch-couch-link : inside itch's frame the two windows link over the opener (postMessage bridge), so couch mode works on itch, and a pair that never links says so on screen (coord-06, 2026-10-21)
Queue (coordinator 10-21 02:45): renumbered from 85a to 85a so it goes FIRST, ahead of the pixel jobs: it is release work (his 10-19 answers put the release ahead of party polish), and the skeptic showed it must not wait behind 95. Due before the friends and family private link goes out (answer 73, from Sat 10/31), and in any case before the Thu 11/26 release. The party copy is top level and never runs the bridge.
effort: high
After: none. Build on today's netSamePick (95 comes later and must keep this bridge on the embedded path). Do not run beside 95.

Source (his words, verbatim):
- 71 (q-process/answers.md line 147): "b) itch.io now, Steam later"
- 73 (line 151): "a) Friends and family, private link"
- 76 (line 157): "a) Both, couch mode up front | NOTE: couch mode IS career mode though"
- 2.94 (q-round3/answers.md line 94): "b: The 2-player couch mode (it is the unique thing)"
- 1-78 #27: "Worst problems, in order: stutter or harsh sound; crash or freeze; P2 pad or window fails; guests can't tell how to start"
- coord-06 brief (tools/handoff/console/staging-1020/coord-06-itch-iframe-2p-test.md step 4): a fallback that runs only when reportEmbedded() is true; the localhost path must not change.

Measured (coord-06 2026-10-21, raw files in tools/handoff/console/notes/coord-06/):
- raw-T4-framed.json: the real game in a cross-site frame (top http://127.0.0.1:8871, itch's allow list, no sandbox) DID NOT LINK in 20 s. Player 2 opened and booted with an opener; the host roster stayed 1 and player 2's 0. Nothing on screen said why.
- raw-T2-none.json:
  - BroadcastChannel, localStorage and storage events are partitioned between the frame and the top-level popup.
  - window.opener.postMessage works both ways (handle and event.source).
  - The frame and popup share one process.
- raw-T3 noopener (raw-T2-noopener.json): the opener path is gone. Only Chrome's requestStorageAccess linked them; it is not used here.
- itch-embed-capture-2026-10-21.txt:
  - 8 of 8 game pages frame the game in iframe#game_drop with NO sandbox.
  - The allow list includes gamepad and "fullscreen *", but no clipboard-write.
  - The frame is html-classic.itch.zone, and a top-level load of the game's index.html answers 200.
  - The SharedArrayBuffer frame option sends COOP same-origin, which forces noopener on the frame's popups. Per itch staff it also moves the game to html.itch.zone, so old saves are gone.

Not done (coordinator read of the working tree, VER 33.57; line numbers are about):
- netSameChan (about dark_raiders.html 56691) makes only a BroadcastChannel, which is partitioned in a frame. grep -c window.opener is 0, and no window 'message' listener exists for the pair.
- p2RaidNow and p2LiveNow (about 55924-55925) read localStorage. In the frame they never see player 2's marks (player 2's top-level store is a different store), so the v20.35 guard in netSamePick cannot fire on itch.
- The storage listeners for the sound who and split keys (about 57307, NET_WHO_KEY 57293, NET_SPLIT_KEY 57304) and for the kid key (about 58739, KID_SHARE_KEY 58724) never fire across the two stores.
- When the channel opens and nobody answers, nothing times out and nothing shows (T4). 95 adds an 8 s ready watch only on the noopener path.
- Not in this job, noted: the v13.20 comment over reportEmbedded (about 66899) says itch's sandbox has no allow-downloads, but there is no sandbox today. The clipboard copy in the frame very likely fails in Chrome (no clipboard-write in the allow list). Log both for the report job.

What to do. The top-level path stays exactly what 95 leaves. The BroadcastChannel name, the pair filter and every word stay as they are.
1. One transport seam. netSameChan returns an object with postMessage, close and onmessage:
   - Top level: today's BroadcastChannel.
   - Embedded host (reportEmbedded() true): a window bridge that posts {pg:'pillagers',m} to NET.p2win with targetOrigin location.origin.
   - netP2Url adds &emb=1 when reportEmbedded() is true. A player 2 window with emb=1 bridges to window.opener.
   - One window 'message' listener takes a message only when e.origin===location.origin, e.data.pg==='pillagers', and e.source===NET.p2win (host) or e.source===window.opener (player 2). It then calls netSameOnMsg(e.data.m). Every itch HTML game shares the html-classic.itch.zone origin, so the source test matters.
   - A host with no handle (after a frame reload; player 2 keeps its opener across the reload) takes e.source as NET.p2win.
   - netSamePost and the pad, rumble, snd, hubmate and arc words go through the seam unchanged.
2. A player 2 window with emb=1 and no window.opener (itch turned COOP on, or the window was opened by hand) shows the callout "no link: pick 2 player in the player 1 window" and posts nothing.
3. The marks across the two stores. On the bridge, player 2's p2LiveBeat also posts {t:'beat',raid:0|1}: pair-free, handled before the pair filter, and taken only from the bridge source. The host keeps the times in memory (NET.mateBeat). p2RaidNow and p2LiveNow read the newer of storage and memory, so the v20.35 refusal and 95's p2goto work on itch. Saves and slot pointers are NOT mirrored: player 1's saves stay in the frame's store and player 2's in its own top-level store, so two windows can never open the same save. salvagerun:profile and every save key stay as they are.
4. The settings the pair shares: NET_WHO_KEY, NET_SPLIT_KEY and KID_SHARE_KEY.
   - On the bridge, each window compares the three once a second and posts {t:'kv',k,v} when one changed.
   - The receiver writes the key and runs what its storage listener runs: netSndApply plus renderParty, or kidSync plus renderSettings when Settings is open.
   - On 'ready' the host posts all three, so the host's values win when the pair links.
   - Only those three keys are accepted.
5. No link, said on screen, on every path (top level too): if nobody is 'in' 15 s after the pick, NET.status reads "player 2 not linked" where "waiting for player 2" shows today, and RETRY is offered. Run it through 95's netSameWatch so the check can drive it.
6. Player text: only the two callouts above, lower case, short.
7. A note for him in the ship line: on itch, never turn on "SharedArrayBuffer support". Embed in page and click to launch in fullscreen both work.

Check (new, must fail on the build before; the gate's fixture is top level, so the frame is stubbed through reportEmbedded, which was made stubbable for this):
- reportEmbedded stubbed to return true. window.open returns a fake popup {closed:false, posted:[], postMessage(m,o), focus()}. BroadcastChannel is a recorder.
- netSamePick('coop',start):
  - the features have no noopener and the url has emb=1
  - padpick and snd reached the fake with targetOrigin location.origin
  - the BroadcastChannel recorder got nothing
- window.dispatchEvent(new MessageEvent('message',{data:{pg:'pillagers',m:{t:'ready',pair:NET.pair}},origin:location.origin,source:fake})): the offer (netHost stubbed to give a code) is posted to the fake. The same event with another origin, or another source, is ignored. Fails today: nothing reaches the fake.
- Player 2 side: netSameBootP2 with emb on and window.opener set to a fake for the check (window.opener is writable in a top-level page; restore it after) posts ready to the fake. With window.opener null it shows the step 2 callout.
- A bridged beat with raid:1 makes netSamePick, with no link, return 'p2raid'.
- A bridged kv for NET_SPLIT_KEY writes the key and runs netSndApply once. A kv for salvagerun:profile is ignored and the save is untouched.
- netSameWatch(t0+15500) with nobody in shows "player 2 not linked" and RETRY, in both the embedded and the top-level stub runs.
- The real cross-site frame: copy coord-06's T4 setup into a lane script (notes/85a/frame2p.mjs, from notes/coord-06/c6drive.mjs and top2.html). It is a throwaway node server on 127.0.0.1:8871 that serves only the top page and closes at exit. The lane's HTTP.sys servers answer only to localhost, and 127.0.0.1 is cross-site to localhost the way itch.io is to itch.zone. The top page frames http://localhost:LANEPORT/fixture.html with itch's allow list and no sandbox. Use your lane's camera port, never 8802, with a real CDP mouse click inside the frame on 2 PLAYER CO-OP.
  - Before: DID NOT LINK in 20 s (raw-T4-framed.json is already on file).
  - After: both rosters 2 within 5 s; both ascend into a raid; a sound split change in one window shows in the other; closing player 2 shows "p2 pad lost" or "player 2 not linked" as today.
  - Then T4 control (top level) still links on 95's two-process path.
  - Check after each run that 8871 is no longer listening.
- Then, once his itch page exists (coordinator with him; a lane cannot sign in to itch): a restricted draft upload. In Chrome, Edge and Firefox: the pair links, pads work in the frame and in player 2's window, and fullscreen works on both TVs.

Party risk: low. The bridge runs only when reportEmbedded() is true, and the party copy is top level. The parts that do run at the party are the netSameChan seam and the 15 s no-link callout.
Watch line: "if the party line ever says player 2 not linked while both windows are open and playing, tell me."
Size: about 0.7 lane-nights, in 2 ships:
(a) steps 1, 2 and 6, with the bridge check and the frame camera
(b) steps 3, 4, 5 and 7

TASK DONE when both ships passed with their checks and the cross-site frame camera linked and played a raid; TASK PARTIAL with what is left (the real itch draft test is logged as his item, not a lane item).
Coordinator corrections 10-21 (skeptic verify of the plan, binding; they override the steps above where they differ):
- on the embedded path, before any navigation, call window.open('', 'pillagers_p2'). That returns the existing popup without navigating it, so the frame gets the handle back after a reload. Then ask over postMessage whether player 2 is in a raid, and keep the v20.35 refusal. Player 2 also pushes its p2live and p2raid marks to the opener every 2 s.
- accept a bridge word only when event.origin===location.origin and event.source is the opener or the known handle. Keep the frame's own query string (itch ?v=) in netP2Url on the embedded path.
- proof before it is called release-safe: an end-to-end link (WebRTC both rosters 2, a raid, pad, sound) on the real itch restricted page through a secret link with no password typed by a lane, in Chrome and Edge at least. Firefox and Safari count as not working, with the on-screen 'player 2 not linked' callout, until tested. Add a Firefox check that player 1's frame saves are still there after player 2 has been used.
- Never enable itch's SharedArrayBuffer option: write that into tools/PUBLISH.md, the itch page settings section.
- Every timer in 95 and 85a (the 8 s, the 1 s) runs through drivable seams ticked from the frame loop, with no raw setTimeout. Each check resets NET and the seams so its two gate runs and the checks after it are clean. Checks hard-fail (never skip) when a function is missing, and stub reportEmbedded both ways.
- Step order: ship the "player 2 not linked" callout first (a small ship of its own), so a stranger on itch at least sees why nothing happens, then the bridge.
- Evidence on disk: tools/handoff/console/notes/coord-06/ (raw-T2-*.json: partitioned, opener postMessage works both ways; raw-T4-framed.json: the real game does not link in a cross-site frame; c6drive.mjs: the cross-site rig on 127.0.0.1:8871, since the static servers refuse Host 127.0.0.1).
