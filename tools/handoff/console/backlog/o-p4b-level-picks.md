# p4b-level-picks : season zero m4, build 2 of 4: three pick cards per level on the raid-end screen
Queued 11-11 by PILLAGERS-HTML NEW CEO: his season zero plan (answers 11-01, binding) and his 11-10/11-11 orders "no idling" and "keep everything else rolling". Build at HEAD (v37.67 or later; line numbers may be old). Read tools/handoff/console/notes/progression/README.md, notes/progression/stat-sites.md and the m4 section of notes/progression/m4-m10-jobs.md first; the answer numbers below are in tools/handoff/progression-answers-1101.md.
Codex: never change tools/mkfixture.ps1; if an old check must change, put the finding and the exact change in your notes and stop. Owner quotes are binding as written.
Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
effort: high
WAIT ON o-p4a-survival-level: if it is still in tasks/, waiting/ or failed/, end your run with exactly TASK WAITING: o-p4a-survival-level

Do (m4b): on the raid-end screen, one set of three cards per level gained in that raid; keep one (answers 17, 18: never in a raid). A death loses unspent picks. A PICKS table of about 40 small upgrades for this one pillager ("8% faster reload", "kills heal 2", "a third grenade"); their effects go through the same reader as gear (raidWornMods adds them), so every stat site that reads worn gear reads picks too. Taking a card again strengthens it, up to three times; two maxed picks that belong together combine into a stronger one (answer 22). Total near +30% at level 20 with a fixed ceiling per stat (answer 24: "easier, not easy"). Card text is short, lower case.
Check: a raid that gains 2 levels offers 2 sets of 3, a kept pick changes its stat by the stated amount through raidWornMods, the per-stat ceiling holds with picks plus gear, a death drops unspent picks, a reload keeps kept picks.
Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold; the new check must FAIL on the build before; an old save loads and plays (reload check in the new check); both windows (host and join) where the screen exists; all player text lower case, $ for money, SP for score, no explaining sentences; the party demo stays as it is (no bar, no picks in the demo). Pictures at 1080p and 4K of every new screen part.
TASK DONE when it shipped and is ON HIS PC; TASK PARTIAL with what is left.

Lane note 2026-11-11 10:46: NEEDS COORDINATOR, parked by lane p. Codex's last words:
The prerequisite remains unshipped in `failed/`. Its coordinator fixture correction and ship must finish before pick-card work can proceed.

TASK PARTIAL: waiting for o-p4a-survival-level to ship.
