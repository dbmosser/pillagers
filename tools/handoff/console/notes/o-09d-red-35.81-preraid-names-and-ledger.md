
--- codex run 2026-10-28 17:45 ---
2026-10-28: Read the four checks and v35.81 diff. Ledger value is intact: its label changed from KILLS to KILLS (4), so 28.71 misses it. Base pack CSS is byte-identical on v35.80, v35.81 and v36.04; recipe replays 33.48 with the condition stylesheet disabled/enabled and both exact historical ocLedger functions. Results will be in camera report notes. The map change also raised the shrink floor 14 to 20 and exit/key labels 18 to 22. Prepared 20/24 comparisons with the required 14 floor and 18 secondary labels, photographed at both 1080p and 4K by recipe camera. No game change submitted before seeing the comparisons.


--- codex run 2026-10-28 17:48 ---
2026-10-28: Recipe round 1 failed staging: game functions are inside its closure, so global renderSector and ocLedger do not exist. The resulting blank/hub pictures do not show the requested screen; their critic findings are staging artifacts, outside this task. Corrected all game-scope access to the fixture __gx hook (mkfixture.ps1 line 111535), including direct lexical eval of historical functions and map variants. Requested the same comparisons again. No game change yet.


--- codex run 2026-10-28 17:55 ---
2026-10-28: Round 2 replay at 1920x1080 confirmed 33.48 passes with the v35.80 component CSS and fails with v35.81 (BURST CARBINE (FIELD) cut to dots). Both exact historical ledger functions draw 600 SP: v35.80 label KILLS passes the old selector, v35.81 label KILLS (4) fails it. Thus both regressions start in v35.81, not 35.82 or 35.83. At 4K the old pack CSS also clipped names before 35.81.
Looked at both 1080p comparisons and both 4K pictures. Choose 20 px: 24 px places the long dock label across a room outline at both sizes, while 20 px fits in the clear strip above. Restore floor 14 and secondary labels 18 as requested. Comparison paths are in the ship description for DESIGN.md.
Prepared cw-cx-preraid-names: names wrap without ellipsis beside the same controls, rows grow, pack regains 150 px minimum and flexible scroll space, section gap 24 to 16, kit descriptions wrap, unavailable price opacity 0.65 to 1. Terms and reward sizes unchanged. Fixture retarget changes only the KILLS selector, accepts both labels and still requires exactly 600 SP. Ship check stages all packable item names and the real career extraction ledger. Final camera recipe runs 33.48, 32.53, 17.82 and 28.71 separately, then photographs actual shipped styling at both resolutions.
Critic round 2: both comparisons score 3 (pre-raid finish line met), but map labels and pack crowding are addressed in this patch. Keep the chosen blue map, map-first hierarchy and 18 px secondary names; do not follow requests to recolor the chosen map or enlarge its secondary names. Keep red only for unaffordable purchases and blank slots for items the counter does not sell; free would be false. Unrelated HUD/board game code untouched. No ON HIS PC confirmation yet.

