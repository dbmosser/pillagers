
--- codex run 2026-10-30 13:01 ---
2026-10-30: HEAD v36.62 does not share machine SP: updateEnts gives host SP only for byPlayer, and netEntGone sends kill credit only to bySeat. Prepared cw-cx-sharedmachine for his approved 2.5 seconds, inclusive. Tracks real machine damage on host via arcadeBmDamage in arcade and career; settles at death before snapshot delay; gives other recent contributors full SP through addressed kill packet share:1. Finishing player keeps kill count, contracts, streaks and rewards. Duplicate shared packets are ignored. No seeded draws or storage changes. Draft anchors match once; patched game script and fixture check pass node syntax checking. Browser gates cannot run in this sandbox. Camera recipes stage each receipt separately; they do not prove a linked run.
LINKED REVIEW NEEDED: synced (kill packet share:1; machine sharedHits host field). Review both real windows, then confirm ON HIS PC. Watch line is in draft why for DESIGN.md.


--- codex run 2026-10-30 13:02 ---
2026-10-30 preflight repair: the drafted behavior checks passed through the arcade score assertion, but the final source-text wiring assertion inspected the fixture timing wrapper for updateEnts (tools/mkfixture.ps1:1584). Replaced that assertion with a real mkCrawler death processed by updateEnts(0). The check now requires removal, sharedPaid settlement, full contributor SP, and unchanged host kill count when the partner finished. All earlier cutoff, duplicate, routing, career, human exclusion and environment exclusion checks remain. Regenerated the same cw-cx-sharedmachine draft: anchors match once and full patched game plus check pass node syntax checking. No game behavior changed in this repair. Browser preflight remains the lane responsibility.
LINKED REVIEW NEEDED: synced. Still needs ship, both-window review and ON HIS PC confirmation.

