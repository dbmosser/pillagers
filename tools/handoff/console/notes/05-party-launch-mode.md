# 05-party-launch-mode notes (lane e)
Code map (post v30.73): PARTY/partyOf near NETP2 (~3915); partyClearMarks before the NETP2 beat block; partyHostBoot/partyP2Boot/partyHostUp/partyReload/partyNav/arcadeOpLeave
just before netTitleInit; hostup handled in netSameOnMsg p2 branch; arcadeLeave end hook; op chord + op card exit call arcadeOpLeave.

Draft: mk-cw-party.ps1 (scratchpad), one key cw-party, 6 checks (a,b,c,d,f,g). Item 5 (pad rule) was already shipped by cw-p2pads (arcadePadsIn puts both on pick -1),
so no pad edit and no pad check in this key (check f asserts picks stay -1).
Gotcha found: every SubRx replacement must END WITH A NEWLINE like its anchor, or a trailing // comment swallows the next code line (parse FAIL, no message).
mk-cw-bisect.txt = "off" disables the bisect subset code in mk-cw-party.ps1.
Card stamp was 0.16 stale: shipped as cw-card22 (mk-cw-card22.ps1) first.

## THE EXACT ADDRESSES (game file = C:\claudecode\dark raiders\dark_raiders.html, or the served address of it)
Host window  (player 1, keyboard and mouse):  <game>?party=1&pair=CODE
Player 2 window (pad):                        <game>?p2=1&mode=coop&arc=1&party=1&pair=CODE
CODE = [a-z0-9]{4,16}, the SAME in both, new at every launch, e.g. pty4821x. Example on the play server:
  http://localhost:8802/dark_raiders.html?party=1&pair=pty4821x
  http://localhost:8802/dark_raiders.html?p2=1&mode=coop&arc=1&party=1&pair=pty4821x
(file:// works the same: file:///C:/claudecode/dark%20raiders/dark_raiders.html?party=1&pair=pty4821x)
The shortcut sets URL_OPTIONS=1 in tools\party\party.cfg and opens both windows itself (no window.open from the game).
Plain address (no ?party) = the full title: only the operator (Exit demo, Ctrl+Shift+F10) goes there.

## Behaviour
- ?party=1 off: nothing changes (check f).
- Host with pair: title never shown (html.partyhide + display none), arcade entered at boot, hostup posted at boot and every 5 s while unlinked.
- Host without pair: title shows only the 2 PLAYER ARCADE DEMO row (CSS html.party hides 1 PLAYER, co-op, 1 player arcade, saves, settings button); ENTER and the hidden start both run arcadePick.
- Player 2: no title, arcade attract at once; answers hostup with ready (only when not linked).
- Any arcadeLeave except the operator exit reloads (max 4 per 30 s via sessionStorage) back into the party; operator Exit demo goes to the plain address.
- Stale p2raid/p2live marks are cleared at party boot in both windows.
- Pause menu unchanged (Q30), no operator volume/end-run controls added (Q31).

## For the session
The 2-player robots (tools\fuzz.ps1 + tools\fuzz-pad.js) put their fake pad on slot 2; with cw-p2pads (player 2 = FIRST pad) that slot number must change to 0.
Not covered: a hung (not crashed) page; the tab-level watchdog is the operator reloading the browser (Q31).
