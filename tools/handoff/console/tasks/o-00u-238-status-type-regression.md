# 238-status-type-regression (was o-229, number clashed with o-00k-229; moved to the front) : the active reload and stim status text fell under its size floor between v36.23 and v36.27
Queue (JTPC Correspondent 10-29 00:55; spare PC run corpus-1028-2325 on v36.27, red there, green in corpus-1028-2206 on v36.23). Fix, MEDIUM: he reads this status in every fight, and both checks are new (his readability passes of 10-28) and block stable.
effort: medium (Opus high; bisect first)

The two checks (fail text from the spare PC):
- 36.20 active reload and stim share readable status type, about 20px titles and 16px values at 1080p -> "active reload x3 title is below the shared callout size (14.429 logical px); stim title is below the shared callout size (14.429 logical px); +35% damage detail is below the shared label size (11.839 logical px); 5s detail is below the shared label size (11.839 logical px)".
- 36.22 active reload damage and stim time share a real 16px detail floor -> "+35% damage detail below 16px (15.391); 5s detail below 16px (15.391)".
Suspects, in order: v36.27 (1283480e5, steady hand and beast mode: a third status may now share the row, so the row shrinks its type to fit), v36.25 (633d1c4e6, active reload 5% a stack, 15% at most), v36.26 (28cf4bb47, the name tag stack cap; only if the status labels share that layout). Find which ship it was before working.
Do: keep the 20px titles and the 16px detail floor at 1080p with every status that can show at once (active reload at full stack, stim, steady hand, beast mode); make room by wrapping or stacking the panels, never by shrinking the type. Pictures at 1080p and 4K, solo and the 2 player demo, with all statuses up, looked at.
Check (must FAIL on v36.27): with active reload x3, stim, steady hand and beast mode all showing at 1080p, every status title is at least the shared callout size and every detail at least 16px. Then 36.20 and 36.22 pass.
Rules: HUD rendering only, no simulation change; player text lower case; no storage key change; seed 4242 fingerprint unchanged.
TASK DONE when shipped and ON HIS PC.
Evidence (CEO check-in 10-29): v36.27 (1283480e5) added STATUSL rows 'sh' (steady hand) and 'bm' (beast mode) right after 'ar', so up to 5 pills (stim, active reload, steady hand, beast mode, more) can share the column and the fit step shrinks type: 14.4 px titles and 11.8 px labels at the same viewport where v36.23 held 20 and 16. Both checks were green on v36.23 and red on v36.27 and are not outdated: his readability floor still stands. Not added to stable-known-red.

NOTE 10-29 02:25 (JTPC Correspondent): 36.20 and 36.22 PASSED in spare PC run corpus-1029-0048 on v36.30 (red on v36.27). Before working, rerun both alone on the current build with all five pills staged: if they stay green there, the 5 pill shrink may only show with a full column; prove it with the check below either way.
