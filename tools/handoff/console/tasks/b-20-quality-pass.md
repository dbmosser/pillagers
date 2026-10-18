QUALITY PASS on the helpers' own work (his standing verdict on rushed features: "more fun but janky ... polish to a AAA level").
List the cw- ships since v28.78 (git log --oneline, subjects starting v28.79 and later). For each, read its diff (git show) and
look for jank a player would notice: text overlapping or cut off, a new panel that duplicates an existing control (his rule: one
control per job), a feature drawn on top of walls or in the wrong layer, inconsistent fonts or colours versus the rest of the HUD,
missing pad support, a value that cannot be reached, leftover debug or temporary probes in tools\mkfixture.ps1. Fix what is real
as cw- keys (preflight first). Write a verdict per ship in your notes. TASK DONE when every ship since v28.78 has a verdict.
