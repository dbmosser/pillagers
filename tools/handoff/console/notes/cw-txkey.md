# cw-txkey (lane h) - a toggle key for Edit the words, with the raid frozen
His order (2026-10-18): a toggle key for text editing mode so he can edit text at any time, e.g. in the middle of a raid, and the game should pause when it is on.

SHIPPED as v31.05 (check 31.05, fails on v31.04, passes twice on v31.05).

- Key: F2 (the Windows "rename" key). Window capture listener placed early in the file, edge press only (a held key does not toggle twice),
  never reaches the game as a key. Only on this machine (DEV_LOCAL), same as the Settings row. F2 cannot be bound to an action (KEYS_FIXED.F2)
  and the Keys window lists "edit the words  f2" among the locked keys.
- ONE setting: the key calls cycleGameOpt('textEdit'), i.e. the Settings row's own click, so the row, the profile, the key and the tag cannot disagree.
- The freeze: devFreeze() is true while the mode is on in a live raid and syncPause() ORs it into G.paused (the one pause the pause box and tuning console use).
  Per frame the loop also syncs it, so the Settings row or a check turning the mode on freezes too. The pause box is NOT opened (it would cover the HUD).
  Turning it off clears keys and mouse.down and the heavy-hold arm (devLetGo), so nothing walks or fires on resume.
- 2 player: each window has its own profile and its own mode. In a shared raid it is the pause-box rule (v16.04): the window whose F2 is on stands still, the world
  keeps running for the other window until every window is paused, so press F2 in both windows to stop everything.
- The tag: a page element top left (left 8, top 38), pointer-events none, shows only while on. Toast: "edit words on" / "edit words off".
- Also found and fixed: a word edited in the arcade demo was lost at leave (P is a sandbox there, swapped for his own profile string). txArcMirror writes the one edit
  into ARCADE.realJs as well, so leaving the demo keeps it.
- NOTE for the next worker: the ship printed SHIPPED but its `git add -A` failed on a vanished art-survey file, so the game file stayed uncommitted and the next three
  ships STOPped with "uncommitted changes". I took the lock and committed dark_raiders.html + AUDIT.md + DESIGN.md by hand (eb37c8ba). The check had already been swept into tools/mkfixture.ps1 by 7dd304e2.
- Not done: no pad button for it (a keyboard key by his order).
