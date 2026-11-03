# 265-extract-pays-2x-sp-as-cash : check whether an extraction still pays 2x raid SP as $, against his 11-01 call
Queue (reported by the FnP chat 11-02, not yet confirmed). Treat as a possible REAL BUG until proved otherwise.
effort: low to medium

His words 11-01: "it shouldn't pay cash beyond just selling what you have and maybe some sort of bonus, but most the money should come from selling gear."
v37.25 and v37.26 (m1b, cw-m1nocash, cw-m1bonusgap) were meant to end cash in raids: an extraction pays "extraction bonus +$N" (10 percent of the secured haul). See tools/handoff/console/notes/progression/log.md.
Where to look: dark_raiders.html about line 67704 `G.careerCash=(how==='extract')?s*2:0;` and about line 37169, where `cash=(G.careerCash===undefined)?...` reads it. Find out whether this path is live in career after m1b, or is only left over for the demo.
Do: follow one career extraction through to the bank on the current build and read what pays. If raid SP still reaches the account as $, remove it through the ship queue with a check that fails on the build before. If it is dead or demo only, say so in notes and close the job.
Rules: through shipq; seed 4242 fingerprint holds; never touch the pickup stack, loot sounds or loot rows.
TASK DONE when a career extraction pays only sold gear and the extraction bonus, proved by a check, or the code is shown to be dead.
