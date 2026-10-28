# o-00a crates-both-holding-e : the 1.5x two-player box search only while BOTH players are holding E (fix of v35.92)
HIS WORDS 10-28 about 15:10, right after v35.92 shipped ("boxes search 1.5 times faster with a nearby teammate"): "teammate next to you?? no I said both players need to be actively looting" and then "e.g. holding E". This beats the brief of o-08-144 (done) wherever they differ. First in line: he is waiting for it.

What is wrong on HEAD: duoAt(ct,seat) (dark_raiders.html, "v28.xx (cw-cx-duosearch)", var DUO_SRCH=1.5, DUO_R=200) returns true when the OTHER player merely stands within 200 of the box. Standing near must give nothing.

Build: the box search gets DUO_SRCH 1.5x only while the other player is ALSO actively looting right now, that is holding the search input (E on the keyboard, or the pad's search button) within DUO_R of the box. Count it whether that player's own search is on this same box (today a box one player holds is refused to the other: count the held key anyway, so two players at one crate both holding E get the speed) or on a box next to it. Let go of E, walk off, get downed or open the menu and the speed drops back to 1x at once. Keep all three doors in step: the host's own search (near.prog), the host running a partner's hold (netSrchTick ct.prog), and the partner's predicted bar (s.ok near.prog). If the partner's held-key state is not in its up packet yet, add it; keep the packet change small and backward safe.

Check (must FAIL on v35.92 or later HEAD before the fix): partner standing at the box NOT holding E gives 1x; partner holding E on the same box gives 1.5x; partner holding E on a box beside it gives 1.5x; releasing E returns 1x in the same tick; both windows agree.
Retarget the v35.92 duosearch check under the lock if it asserts the old "standing near" rule.
Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold; both windows; no new player text. Never touch the pickup stack, loot sounds or loot rows (his 10-27 order). DESIGN.md watch line: "two players holding E together search faster; one standing by does nothing".
TASK DONE when it shipped and is ON HIS PC.
