# 189-extract-no-pop-up : after sinking into the ground on extraction, the pillager never pops back up
Queue: his note 10-27 ~20:45 in chat (verbatim): "when player extracts into the ground, player pops back up and is shown fully visible for a moment before the 'extracted' screen comes up.  this should not happen". Bug fix, allowed before 11/1.
effort: medium
Worked in: a Claude session started from his orders thread. Lanes skip in-session/.

Likely cause (found 10-27, verify first): ascentSink (dark_raiders.html ~17562, cw-ascent, his pick 77) sinks him while an extraction zone's pullT runs, but its zone loop is gated on `!g.over`. The frame the extraction ends the raid sets G.over (and the zone's pullT may reset), so ascentSink returns 0 and he is drawn whole, standing on the ring, until the outcome card covers the screen.
Fix direction: once his extraction completes, he stays fully sunk (or is not drawn) until the outcome card is up; never redrawn whole. Same for a teammate who extracts in co-op (their figure in the other window) and the 2 player demo. A death or an abandon is not changed. Drawing only: no seeded draw, no change to when the raid ends or what it pays.
Check (must FAIL on v35.28 or newer at the time): stage an extraction to the boarding moment, run frames across the end of the raid until the outcome card shows, and measure ascentSink (or the drawn figure) on each frame: it never drops back toward 0 after the pull reached full. Control: the rise at the raid start still runs.
Pictures: if a frame grab of the last raid frame before the card is possible, look at it.
Ship: preflight on lane d (check no other preflight runs on d first, and that no console lane d worker is running), then shipq. Rules: no storage key change; seed fingerprint unchanged.
TASK DONE when shipped and his main PC reports the build (git show origin/spare-results:spare/JUL26/status.txt, game=VER). Then move this file to console/done/ and report one line: build, on his PC, what to watch for.
