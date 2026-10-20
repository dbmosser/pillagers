THE PARTY IS JUST THE DEMO (his order 2026-10-19, verbatim): "'party' and 'demo' need to be synonymous --- you are doing too much
to try to make the party demo polished. for the party demo, we need to just open the game on the localhost and then click the
demo -- don't overengineer this (e.g. no need for desktop 'Pillagers Party')". This REVERSES his Q28 of 2026-10-18 (the one-click
shortcut and the ?party=1 launch mode). On the night he opens http://localhost:8802/dark_raiders.html and clicks the 2 player
arcade demo row on the normal title, the same as any other day. Small job: one or two ships.

What to change (grep the names; line numbers drift):
1. Remove the ?party=1 launch mode, so the address never changes how the game behaves: partyOf, PARTY, PARTY_EXIT,
   partyHostBoot, partyP2Boot, partyReload, partyNav, the 'party' and 'partyhide' classes on <html> and their CSS, the title
   overrides (the start row and ENTER going to arcadePick), the party branch of EXIT DEMO and of leaving the arcade (~line 62926
   "if(PARTY&&!PARTY_EXIT) partyReload()"), and partyClearMarks if nothing else needs it.
   Do NOT touch the online party: the PARTY window, HOST A PARTY / JOIN A PARTY, NET, the pair and invite codes. That is
   multiplayer, not the launch mode.
2. What the launch mode did that the night needs now happens in the plain demo (ARCADE.on / g.arcade), opened from the title:
   - map first: the demo's sector map starts the run by itself after MAPFIRST.auto seconds (today only with PARTY, ~line 16477
     "g.arcade&&PARTY&&g.mapFirstT>=MAPFIRST.auto").
   - F2 (edit the words) and F8 (snip) need Ctrl during the demo: partyKeyOk, partyCtrlGive and the two KEYS_LOCKED labels key
     off the demo instead of PARTY. Outside the demo, plain F2 and F8 stay as they are.
3. The mkfixture checks written for the launch mode (v30.79 "party launch mode", v31.37 cw-partykeys) test code that goes away.
   Rewrite them to the new rule, or delete the ones with nothing left to test, and say which in your notes.
4. No new controls, no new screens, no launcher, no new words on screen.

Checks (the control must FAIL on the old build):
- a demo raid started from the plain title (no ?party in the address): the sector map ends by itself after MAPFIRST.auto
  seconds. (Old build: it waits for a press.)
- the same page: inside the demo a plain F8 does nothing and Ctrl+F8 snips; outside the demo a plain F8 snips.
  (Old build: a plain F8 snips inside the demo.)
- typeof partyHostBoot === 'undefined', and a page opened with ?party=1 shows the normal title with career on it, the same as
  without it.
- 2 players: click the 2 player arcade demo row on the normal title; both windows play a run (a picture from each).

Pictures: the title, and a demo raid's sector map in both windows (camera port: your lane's).
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.

## CLOSED 10-19 23:05 (coordinator): DONE
- The order shipped (v32.01: the party is the plain demo). The party now runs from a frozen copy on the main PC with no ?party page (his 10-19 choice), so the leftover ?party=1 and two-window pictures are moot. His process answer 40: the party is a sideshow; no more party polish.
