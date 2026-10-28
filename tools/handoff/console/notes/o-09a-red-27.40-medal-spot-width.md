
--- codex run 2026-10-28 17:08 ---
2026-10-28: Prepared cw-cx-medalwidth. feedRect now computes fw once at 28 percent and uses it for both the feed return rectangle and MEDALBOX.w. No loot, pickup, or world-generation code changes.
The mk script printed written; its one function anchor matched exactly once. Draft reviewed and regression-check JavaScript parsed with node --check. A local helper-only geometry probe at widths 1882, 1920, 3840 failed equality on the old function and passed on the replacement (1882: 452/527 becomes 527/527). Browser checks remain lane work.
The new check repeats the requirements of 27.40, opens controls and checks their right edge stays within 47 percent, and checks the pillager board avoids the medal rectangle. Please run original 27.40 as well as the normal gate. Existing 27.35 still has an obsolete 26 percent maximum on this checkout; its controls bound is preserved in the new check. No fixture retarget proposed because that old width assertion is unrelated to this fix.
Requested screen 20 before/after and independent critic review. Awaiting preflight, ship gate, ON HIS PC, and pictures.
