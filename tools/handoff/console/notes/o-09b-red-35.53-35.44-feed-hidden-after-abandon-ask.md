
--- codex run 2026-10-28 17:18 ---
2026-10-28: Confirmed togglePauseBox only disarmed Abandon when opening. Prepared cw-cx-abandonfeed: disarm on closing too. No text or layout changes. The regression opens and arms the real controls, closes by keyboard Escape, direct close and header x, then checks that asking and the confirmation clear, feedWaits is false, and a feed line actually draws. It also runs existing checks 9.37, 35.53 and 35.44 in that order in one tab, without manually clearing asking between them.
Watch on next play: choose Abandon, press Escape, then loot something; the feed should show the pickup.
The lane must run preflight and ship, confirm ON HIS PC, and photograph the restored feed after Escape. Browser checks cannot run in this sandbox.
Sandbox validation: mk printed written; the draft contains exactly one unique anchor and the intended one-line replacement. Node syntax checks passed for the generated regression check and all inline game scripts after applying the draft in memory. No tracked game or fixture file was edited. Added a camera recipe that exercises Abandon then Escape and requires the restored feed row.

