
--- codex run 2026-11-07 10:38 ---
2026-11-07 - First implementation prepared at v37.48. LOCAL: no linked review. Each window settles only its own save; no packets or shared raid rewards changed.

Prepared mk-cw-cx-hardcore.ps1 and the cw-cx-hardcore key. New-save creation has an off-by-default shared switch; only new player 1 saves in slots 2-8 can consume its one-shot marker. Player 2 keeps the current numbered-save behavior and hides the creation switch. Both roles show the save tag and enforce death on an already-hardcore save.

Death snapshots the stash sale value before settlement, current cosmetics including build, living pillager level and name, career totals, date, killer, clock and day/night. Closing KIA archives once, removes only that slot and its undo, adjacent boot-crash and daily keys, waits for the second-copy deletion callback and reloads onto slot 1. An archived identity rejects old second copies and loaded raw backups; pending second-copy writes are checked again after the database opens. Closing the browser on a saved KIA finishes the archive at boot. Slot 1 is excluded by the storage-key guard.

The repository has newer account/lineage rules: pilRaidEnd already ends a living pillager on death or abandon, while preserving its account. This change leaves those rules in place. A hardcore abandon preserves the save as required by this job, and only an actual career death deletes it. Capturing the grave before pilRaidEnd preserves the living pillager and level.

Validation: all 21 anchors matched exactly once; the mk script printed written; local draft application succeeded; node --check passed on the full candidate JavaScript, the new check, and camera builder; the mk script is ASCII. No tracked game or fixture edits. Browser checks cannot run in this sandbox. The new gate check snapshots/restores every salvagerun key in finally and suppresses second-copy/export side effects while staging. It exercises on/off create into slot 5, death and backups, untouched slot 1 bytes, ranked grave rows, both role guards, sim/demo exclusions, normal death, hardcore extraction and abandon.

Camera: camera-recipes.json contains six scenes, with smooth look pinned: title off, title on, player 2 tagged saves with hidden toggle, KIA fallen line, saves after death, and three graves staged out of order. The lane recipe camera runs 1080 and 4k. Critic scores and ON HIS PC are pending. No old fixture check has been changed or identified as needing retargeting.

Watch: a hardcore death removes that save for good; verify stash value is the graveyard score and that a normal save or slot 1 is never touched.

--- codex run 2026-11-07 11:04 ---
2026-11-07 - Retry after spare-PC preflight produced no report for 281-300 minutes (job preflight-cw-cx-hardcore-b1ce1b579131). This is an unavailable test worker, not a reported game, lint or check failure. No script behavior was changed without a diagnostic.

Revalidated against refreshed master v37.48: mk printed written, all 21 anchors match exactly once, draft application passes, and node --check passes for the full candidate JavaScript, regression check and camera builder. The mk remains ASCII. cw-cx-hardcore remains in keys.txt for another preflight attempt. Existing six-scene camera recipe is unchanged. No tracked game or fixture edits.

LOCAL: no linked review. Remaining work belongs to the lane: obtain an actual preflight result from the spare PC, ship, confirm ON HIS PC, then photograph at 1080/4k and run the critic. No build is reported shipped.

--- codex run 2026-11-07 11:35 ---
2026-11-07 - Continued from the prior notes; no newer preflight, ship or camera result was supplied. The current game remains v37.48 without this feature. Reviewed the deletion guards against the current daily-save key format, IndexedDB second-copy deletion callback and COSKEY mapping (which includes build). No game behavior changed in this retry.

Strengthened the new regression check to stage a later-inserted grave with equal stash value and an earlier death; it must rank ahead of grimtest. This directly covers the required leaderboard tie rule in addition to the existing three-record stash ranking test.

Revalidated the revised mk script: written; 21 unique anchors; 8 unique helper names; ASCII script; successful draft application and node syntax checks for the full candidate, check and camera builder. No tracked game or fixture edits. cw-cx-hardcore remains ready in keys.txt, and the six-scene smooth-look camera recipe remains ready for 1080p and 4k. The browser regression has not run here.

LOCAL: no linked review. Remaining lane work: obtain a real preflight result, ship with ON HIS PC confirmation, then capture both roles and run the critic. Earlier notes report a spare-PC job that returned no result; no passing gate or shipped build is claimed.

--- codex run 2026-11-07 12:13 ---
2026-11-07 - Continued from the three earlier run notes. No completed lane preflight, ship, ON HIS PC or camera result was supplied, and the current workspace remains v37.48 without hardcore. The existing 21-edit draft and six-scene camera recipe remain ready; no speculative game change was made in response to a missing gate report.

Added validate-hardcore-helpers.js, an offline harness that executes the actual draft helpers with isolated storage. PASS: one-shot new-save choice, rejection for slot 1/existing careers/player 2/test slots, off choice, deletion of only slot 5 and its adjacent/daily backups, byte preservation of slot 1 and unrelated keys, waiting for the second-copy deletion callback, idempotent repeated close, and rejection of archived backups while allowing a new career in the reused slot. This supplements the prepared browser regression and does not replace it.

Regenerated the draft successfully (written). All 21 anchors are unique; eight helper names are unique; mk script is ASCII; full candidate, browser regression and camera builder pass node syntax checks. No tracked game or fixture changes. cw-cx-hardcore remains in keys.txt.

LOCAL: no linked review. All implementation and camera artifacts are handed over. Remaining work belongs to the lane/test worker: a completed preflight result, ship with ON HIS PC, then 1080p/4k pictures and graveyard critic. Do not report this build shipped until those results arrive.

--- codex run 2026-11-07 12:38 ---
2026-11-07 - The lane returned preflight-cw-cx-hardcore-97e454bd55f9 with only spare-PC availability messages, ending with no report for 37 minutes. No browser assertion, lint error or code failure was returned. The mk script and check were therefore kept unchanged; changing their behavior would not address the reported failure.

Revalidated against refreshed master v37.48: mk prints written; all 21 anchors match once; eight helper names are unique; mk is ASCII; candidate and browser regression pass node syntax checks. Isolated helper regression passes creation guards, exact deletion and backup rejection again. cw-cx-hardcore remains in keys.txt; the six-scene camera recipe remains ready. No tracked game or fixture changes.

LOCAL: no linked review. Lane/coordinator must obtain a completed spare-PC preflight result, then ship with ON HIS PC confirmation and capture 1080p/4k pictures for critic review. This run does not claim a preflight pass or shipment.
