# h01c-graveyard-hides-the-money-strip : the money strip ($ / stash / bag) shows over the top edge of the graveyard panel opened from the title
WAIT ON o-h01b-hardcore-toggle-is-a-pill
Queued 11-11 20:0x by the HTML CEO from the o-h01 recipe pictures (v37.69): tools/handoff/console/notes/shots/o-h01-177-hardcore-save-recipes-3/hc-graveyard-ranked-1080.jpg and ...-recipes-3-4k/hc-graveyard-ranked-4k.jpg. Build at HEAD.
Codex: never change tools/mkfixture.ps1; if a check must change, put the finding and exact change in your notes and stop. Owner quotes below are binding as written.
HIS PRIORITY: follows o-h01 (HIGH). A polish fix to a shipped screen.
effort: low

What is wrong: opening the graveyard (#hcgrave, dark_raiders.html about line 3597, hcGraveOpen) from the title saves list brings up the hub money strip at the top right ("$1,000  stash $0  bag $0"), drawn across the graveyard panel's top border at both 1080p and 4K. The title itself shows no money strip, and the graveyard is about the fallen, not the open save's wallet.
Do: while the graveyard is open from the title, the money strip stays hidden (as it is on the title), or, if the strip is shown on purpose for every modal, it must sit clear of the panel's border. Change nothing else on the graveyard (ranking, rows, body, close and esc stay as shipped). Nothing changes in the hub or the raid.
Check (must FAIL on the build before, PASS on the new): on the title with a graveyard record staged, after hcGraveOpen() the money strip element is hidden (or its bounding box does not intersect #hcgrave's panel box); after hcGraveClose() the title is as before. Old save reload; seed 4242 fingerprint holds.
Pictures at 1080p and 4K: hc-graveyard-ranked from .codex-work/o-h01-177-hardcore-save/camera-recipes.json in lane o's worktree.
Rules: player text all lower case; never touch the pickup stack, loot sounds or loot rows; the seed 4242 fingerprint holds.
TASK DONE when shipped and the pictures show a clean panel top; TASK PARTIAL with what is left.
