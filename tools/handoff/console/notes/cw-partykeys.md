# cw-partykeys (lane h) - at the party F2 and F8 need Ctrl held
SHIPPED as v31.37 (commit 76455d0b, check 31.37, fails on v31.36, passes twice on v31.37). It waited about 50 minutes in the ship queue behind other lanes (shipq is unfair), nothing else was wrong.
The coordinator's job (2026-10-18): at the party player 1 is a guest on keyboard and mouse at localhost. The F keys sit right above the gun number keys, so a stray F2 (edit the words) or F8 (snip)
froze the raid in a state the guest cannot read. Follows the hidden-operator pattern of the Ctrl+Shift+F10 operator card.

- Party mode = the page runs with ?party=1 (the PARTY flag; the 2 player arcade demo played from it too). The P2 window carries the same address, so it is the same there.
- In party mode a plain F2 or F8 is not taken at all (nothing changes, nothing is swallowed, no toast). Ctrl+F2 and Ctrl+F8 do the job. Ctrl with Shift or Alt does nothing.
- Outside party mode nothing changes: plain F2 and F8 work, a Ctrl chord still does nothing (one function, partyKeyOk, replaces the two modifier tests in the F2 and F8 listeners).
- A snip that is up in party mode ends on ESC or Ctrl+F8; a plain F8 is eaten and does nothing (the rest of the keys are eaten while a snip is up, as before).
- The tag in party mode reads "edit words: on (ctrl f2)". The Keys window locked rows read "ctrl + f2" and "ctrl + f8" in party mode (guests cannot reach the Keys window, so this is for him), and the Settings
  row hint says "Ctrl with F2 turns it on and off". The toast text is unchanged ("edit words on" / "snip ..."), it names no key.
- Found on the way: Ctrl is the crouch key and flips the stance on its press (raidKey, one change per press). So the chord Ctrl+F2 would have crouched the player. partyCtrlGive gives that one change back,
  the same way Ctrl with the wheel does (v15.65, G.ctrlUndo). It tests `'ctrlUndo' in G`, not `!= null`, because a stance that was never set is undefined and that is a stance too (the first draft of the
  check caught this: the chord left the crouch flipped on a fresh raid).
- Check (31.xx, key cw-partykeys): ONE control outside party (plain works, Ctrl chord does nothing); TWO party menu: plain F2/F8 do nothing, Ctrl+Shift and Ctrl+Alt do nothing, no toast; THREE party: Ctrl+F2 on with the
  tag, plain F2 does not turn it off, Ctrl+F2 off, Ctrl+F8 snip, plain F8 does not end it, ESC and Ctrl+F8 end it; FOUR party raid: plain F2/F8 leave the raid running, Ctrl+F2 and Ctrl+F8 freeze it and the crouch
  is given back. It sets the PARTY flag from the check (the fixture is not opened with ?party=1) and restores it in finally; fails on the build before (plain F2 under party changed the mode).
- Real-address proof (camera, notes/shots/cw-partykeys-after, 97/98/99 on http://localhost:8808/fixture.html?party=1): plain F2 and F8 leave no tag and no snip; Ctrl+F2 raises "edit words: on (ctrl f2)"; Ctrl+F8 starts the snip. The key name cw-partykeys was used once before (v29.93, party page key caps); this job is unrelated.
