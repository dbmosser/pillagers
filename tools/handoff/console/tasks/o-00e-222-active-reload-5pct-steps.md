# o-222 active-reload-5pct-steps : active reload pays 5% a stack, 15% at most
HIS WORDS 10-29 about 02:00 (in the Gameplay Edit Intaker chat): "active reload should only give an extra 5% of damage per stack for a total of 15%"

What is on HEAD (v36.23): dark_raiders.html ~26239 AR_BONUS=1.15, ~26244 AR_STEP=0.10 AR_STK_MAX=5, ~26268 p.arMul=AR_BONUS+AR_STEP*(p.arStk-1). So today x1.15, x1.25 ... up to x1.55. The status entry (~43979) prints '+N% damage'.

Build: the chain pays x1.05, x1.10, x1.15 and stops there (3 stacks of 5%). AR_BONUS 1.05, AR_STEP 0.05, AR_STK_MAX 3. Keep the narrowing sweet spot (AR_NARROW) and the break rules (a miss, a reload left to run, a gun change) as they are; with the cap at 3 the spot stops narrowing at the third. Fix the comments and any key list or help text that says 15/25/55 percent. Check the arcade and P2 paths read the same numbers.
Check (must FAIL on the current build): first active reload p.arMul 1.05, third 1.15, a fourth still 1.15; the status reads '+15% damage' at the cap.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "active reload adds 5% a stack, 15% at most". Model: Sonnet 5.5 high (numbers and text).
TASK DONE when it shipped and is ON HIS PC.
