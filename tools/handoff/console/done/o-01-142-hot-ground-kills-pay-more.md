# 142-hot-ground-kills-pay-more : a kill inside the hot ground pays 1.5x sp
HIS DECISION 10-28 about 08:40 (his reply to the ranked list of 32; this beats anything below in this file): #1 "That's too much, should just be 1.05". A kill inside the hot ground pays 1.05x SP, not 1.5x.
He approved 13 of the 32 in one reply and asked for them to be made, then polish. Ship it, then the next o- job.
Queue (coordinator 10-25 16:30): his 10-25 answer g-47, "Yes, more SP there" (notes/answers-100-1025.md; line numbers read on v34.83, check them on HEAD). Party fix (Fri 10/30 first): demo scoring, both windows.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: low

Do: today hot ground (G.hotZone r 620, built at 16473, moved every HOT_EVERY 115 s by tickHot 45762) pays only at boxes: two extra LOOT.safe rolls on a box opened inside it (26248-26258), and netHotBonus (63064) for a partner. Kill SP has no position factor: careerKill (66499) pays scoreKill (66487), and arcadeKill (66509) pays arcadeKillPts (66290) times the streak, nothing else. Build: var HOT_KILLX=1.5. In scoreKill (career) and in arcadeKill (demo), right after the streak multiplier (n*=mx): if G.hotZone and x,y are finite and Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r, then n=Math.round(n*HOT_KILLX) and the kill popup label reads '+'+arcadeCr(n)+' hot' (lower case through the text door). It applies on whichever window credits the kill (host and partner, both modes; the partner already has the host's hot ground through the world word). Style medals, power-ups and the team combo are unchanged. No seeded draw. Picture: a hot kill popup at 1080p, both windows. Check (fails today): career fixture (?career=1): set G.cs.streak=null, careerKill('sentry',0,0,x,y) at a point inside G.hotZone returns 150; set G.cs.streak=null again, the same kill outside returns 100. Today both return 100. Watch line for DESIGN.md: is the hot ground now worth its two extra machines; watch demo SP totals on the board.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.

HIS PRIORITY 10-27 (priorities page): MEDIUM
