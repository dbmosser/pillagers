
--- codex run 2026-10-28 17:33 ---
2026-10-28: Prepared cw-cx-pausesp-gold for lane validation and shipping.
- Added --score-gold:#ffc04a beside the rarity tokens and used it in both pause SP gold rules. No pause layout, text, behaviour, storage, loot, or world changes.
- Current v36.02 also has three newer raw-colour rules in ui-shared from cw-cx-overmomentlook: the run-over scrim and two seat colours. These would still stop 29.33 after the requested pause fix. Included the minimum identical-colour token replacements in the same key: existing --scrim for rgba(6,7,8,.80), plus --seat-one:#ffb454 and --seat-two:#53d9e8. No visible changes and no debt-list edits.
- Local draft generation prints written. All six anchors match exactly once. Applying the draft in memory brings the exact 29.33 literal scan from 25 to the pinned 20 (the earlier flat scan counted selector text too). Both pause rules use the token and no new raw colours remain. Check JS passes node --check and the mk script is ASCII. Tracked files remain untouched.
- New regression fails immediately on the original raw pause gold. On the patched build it checks the computed root gold, unchanged seat tokens, invokes all of check 29.33 (including its mode, button, font and panel assertions), then stages a seeded live raid and verifies computed headline, non-muted setting factor, and end-rule gold are rgb(255, 192, 74). Raid and profile cleanup follows existing pause checks.
- No screenshots requested because this is an exact-colour token refactor with no visible change. No fixture retarget is needed.
- Remaining lane work: preflight, ship gate, fingerprint, and ON HIS PC confirmation. Do not report the build as shipped until those results arrive.
