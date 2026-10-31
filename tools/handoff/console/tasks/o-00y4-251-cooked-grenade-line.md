# o-00y4-251 cooked-grenade-line : the "cooked grenade! throw grenade now x6" line never shows when you are not holding a live grenade
party-breaking: yes
camera: 1
HIS WORDS 10-31 (in the Gameplay Edit Intaker chat), with a screenshot of a red danger line "cooked grenade! throw grenade now x6": "this si a glitch, i am not near any cooked grenades"
PARTY RELEVANT (a false red danger line in the demo); CEO decides under his 10-30 order.

What is on v36.55: cookShout(p) (dark_raiders.html ~44063) returns 'COOKED GRENADE! THROW GRENADE NOW' while p.cooking a frag with 1.0 s or less left on FRAG_FUSE; the draw (~46138) calls cookFeed(p) EVERY FRAME, which feedAdds a danger line keyed 'cookshout' (cw-feedall). The line is meant for HIS OWN grenade in hand, but it reads like a grenade near him, and a per-frame feedAdd on one key likely counts each refresh as a repeat (the "x6") and keeps the line up for the feed's 5 s after the throw.
Build:
1. Find the real trigger of his screenshot first: reproduce (a) a normal cook and throw, (b) the belt instant grenade keys 5/6, (c) the wheel grenade (p.hand), (d) going down, swapping or rolling mid-cook, (e) player 2 cooking in a party (does the host window show the partner's shout as his?). Any case where p.cooking stays set with no grenade in hand is a bug: clear it.
2. Take the shout OUT of the feed and the danger lane entirely (his standing wish for fewer messages): the last-second warning stays only where it was born, flashing over his own pillager's countdown while he holds the cooked frag. Never a feed line, never a count.
Check (must FAIL on v36.55): cook a frag past its last second and throw: no feed line contains "cooked grenade"; the over-the-head shout still flashes while held; player 2 cooking never shows a shout in the host's feed.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. Retarget the cw-feedall check that expects the feed copy (fixq). DESIGN.md watch line: "the cooked grenade warning stays over your head only". Model: Codex or Sonnet 5.5 high.
TASK DONE when it shipped and is ON HIS PC.

CEO 10-31 05:15: party relevant (a false red danger line misleads players), so Codex builds it third, after o-00y-246 and o-00y3-248, past its reserve. Must be ON HIS PC before Sat 12:00; if it cannot pass the gate by 11:30, ship nothing.
