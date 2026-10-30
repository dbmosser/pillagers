# o-00z guest-slow-home-after-extract : in the online party the guest stays up top about a minute after extracting
Part of his 10-30 order (2 player critical, Codex only): "Over the next 30 hours, Make any edits you see as critical for two player play, and test them".
Found by the two-PC auto test 202610301231-JUL26 (PASS 10 of 10; host his main PC JUL26, guest the spare PC DESKTOP-82BKOP4, both v36.57; text in the spare-results branch, spare/JUL26/p2-online-test.txt; harness tools/p2online/p2.mjs). Its one note: the guest was "still up top a minute after extracting" before it reached the undercroft.
Find out why. Possibilities:
- the run over card and the haul reveal play out for both players (normal), and the test just waited them out;
- the guest waits for the host's raid to end (a teammate who has left is never waited for; an extracted guest should not be held either);
- a packet is missed and a timeout carries the guest home.
If it is the normal end card at normal length, write that in notes/o-00y-findings.md and ship nothing. If the guest is held or waits for a timeout, fix it so an extracted guest goes home on the same beat as a solo extract, in both windows, through the full gate and the 2-window checks. Add the time from extract to undercroft to the p2.mjs result line if that is easy.
Rules: seed 4242 fingerprint; no team damage; never the pickup stack, loot sounds or loot rows. Model: Codex high.
TASK DONE when it is shipped and ON HIS PC, or written down as normal.
