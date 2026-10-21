# coord-06 and the player 2 window (2026-10-21 01:45 to 02:50)

Workflow wf_0eba117f-79c: a code reader, a browser-facts reader, one test agent (headless Chrome on 9371, raw files in
notes/coord-06/), a designer and a skeptic.

Bottom line
- itch: couch mode does NOT link inside itch's frame today. Fix: job 85a-itch-couch-link (first in line). Release blocker.
- Party and home: the two windows share one renderer main thread. A split is possible but touches the pick, RETRY and the
  camera recipes. Job 95-p2-own-process, after 85a, ships behind an Experimental switch that is off by default.

What the tests showed (Chrome, headless, DevTools attached)
- Today (plain window.open, opener kept): one process. A 2000 ms busy loop in one window stalled the other's timer by 2002 ms,
  and one renderer pid burned both loops (raw-T1-plain.json).
- noopener, noopener with the popup features, noreferrer, a rel=noopener link: each gave player 2 its own process (gap 11 to 16 ms
  while the other busy-looped). BroadcastChannel, localStorage and storage events kept working at top level. Costs: window.open
  returns null (the game reads that as "blocked") and a second open with the same name makes a duplicate window (raw-T1-twice.json).
  Cutting window.opener after a normal open, or navigating, does not separate the processes.
- Cross-site frame (top 127.0.0.1:8871, frame localhost:8809, the way itch embeds): BroadcastChannel, localStorage and storage
  events do not reach a top-level popup of the same origin, with or without itch-like sandbox flags. window.opener.postMessage works
  both ways (and a transferred MessagePort), but then the frame and the popup share one process. noopener from a frame separates
  the processes but cuts the only path. requestStorageAccess linked a split pair in Chrome only; not for now.
- The real game (fixture v33.57) framed cross-site: player 2 opened, nothing linked in 20 s, nothing on screen said why
  (raw-T4-framed.json). Top level the same build linked in 1.4 s (raw-T4-control.json).

What the code does (v33.54, function names are the anchors)
- One window.open (netSamePick, features from netP2Features, name pillagers_p2). NET.p2win is used only for the blocked test,
  focus() on a re-pick, .closed for the keyboard chip, and the window name.
- Pairing and side words (pads, rumble, sound, floor body, arcade) run over one BroadcastChannel; the raid runs over WebRTC.
  Shared localStorage carries saves, the 75 s p2live and p2raid marks, and sound and kid settings. No postMessage, no opener use.
- Pads: each window reads its own pads; Chrome feeds pads only to the window in front, so player 2's pad usually reaches it through
  player 1's window (netPadSend). A hitch in player 1's window freezes player 2's controls even after a process split.
- Nothing re-finds a pair after a host reload since v32.01 removed the hostup sender, and a channel that never answers shows nothing.

Skeptic (not safe as first drafted; its must-change list is appended to both jobs and binds the lanes)
- Run the itch fix before the speed job and before the 10/31 link; the speed job helps only top-level pages.
- The speed job's timeout must fully reset the host, re-picks during "opening" must do nothing, the p2live test must use the 75 s
  rule, every timer must be drivable from the gate, checks must hard-fail, and the party copy needs a fallback.
- The itch bridge must check event.origin and event.source, keep itch's ?v= query for player 2, find the live popup again after a
  frame reload with window.open('', 'pillagers_p2'), and be proven on the real itch page in Chrome and Edge.
- Never turn on itch's SharedArrayBuffer option (written into tools/PUBLISH.md).

Also fixed: tools/party/party.cfg URL_OPTIONS back to 0. Option 1 asked the game for ?party=1, which v32.01 retired, so the old
launcher would have opened a spare player 2 window that a click on the demo doubles. The party itself is the plain game (START-HERE).
