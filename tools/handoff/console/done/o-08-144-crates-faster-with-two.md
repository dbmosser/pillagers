# 144-crates-faster-with-two : a box searches 1.5x faster while both pillagers stand at it
CEO 10-28 15:15: STOP HERE. This shipped as v35.92 and is ON HIS PC; he then corrected it ("both players need to be actively looting", "e.g. holding E"), and that correction is job o-00a-crates-both-holding-e.md. No more camera or critic rounds on this one: say TASK DONE and move on to o-00a.
HIS DECISION 10-28 about 08:40 (his reply to the ranked list of 32; this beats anything below in this file): #9 "yes". Build it as written.
He approved 13 of the 32 in one reply and asked for them to be made, then polish. Ship it, then the next o- job.
Queue (coordinator 10-25 16:30): his 10-25 answer g-57, "Crates open faster with two" (notes/answers-100-1025.md; line numbers read on v34.83, check them on HEAD). Party fix (Fri 10/30 first): a reward for two players staying close.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: low

Do: today search speed has no two-player factor at any of its three doors: the host's own search near.prog+=dt/buzzSlow()*(ARCADE_SRCH 1) at 29648; the host running a partner's hold ct.prog+=dt/r.slow at 63087; the partner's local bar at 62897. The team combo (teamKill 67097, called only from arcadeKill) is the only reward for being close, and only in the demo. Build: var DUO_SRCH=1.5, DUO_R=200. Helper duoAt(ct,seat): true when another party member who is up (not downed, not specOut or out, word fresh by netUpShown, same raid seed) stands within DUO_R of the box; on the host, the host's own player counts for a partner's hold. Multiply the progress step by DUO_SRCH when true at all three doors (29648, 63087 and 62897); the partner's bar uses the same test so it does not lag the host. Every searchable box. Demo and career co-op; solo unchanged. No new words, no text. Check (fails today): pair fixture (host window), a crate, the host 30 from it holding E, a fresh NET.up partner word 120 from it; after 1.0 s near.prog is 1.5 times a control run with the partner 600 away. Today both are equal. Watch line for DESIGN.md: two players may stack on every box; watch that searching alone does not start to feel slow.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.

HIS PRIORITY 10-27 (priorities page): LOW
