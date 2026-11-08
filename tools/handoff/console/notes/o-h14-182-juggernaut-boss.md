
--- codex run 2026-11-08 05:50 ---
2026-11-08: Prepared cw-cx-juggernaut at v37.58. No tracked game or fixture files were changed.

The script adds the authority-only, once-per-raid juggernaut from t=4 in arcade/career. It tries the map spawns plus 40 free spots, checks wall clearance 50, minimum Overseer distance 1800 and ring/spawn distance 900, then takes the farthest eligible spot. Both selection and mkBulwark borrow the effects random stream. No candidate means no second boss. CFG.boss=0 suppresses it like the Overseer.

Body: bulwark, boss2 only, name the juggernaut, radius 31, 3000*CFG.eHp health, 22 damage, 420 range, speed 52, no elite or residual elite shield. Smooth art scales 1.3 times the existing 1.5 bulwark multiplier; radius alone does not enlarge the smooth bulwark art, so machMul explicitly handles boss2.

The four leash sites named by the brief are all inside the warden-only AI branch at HEAD. Extending those expressions would leave this bulwark unrestrained. Instead, juggernautTick handles its 1600 leash, patrol, last-seen target, home return, and existing fourth-shot big shot/open beat. Job 154 is present. No job 159 solid wreck-cover code was found; the existing normal bulwark wreck path remains intact. The boss also leaves its guaranteed four-item hoard with 3-second search and the requested objective callout.

Base kill SP is 1000 through normal arcade/career scoring and shared-machine credit, keeping existing difficulty/hot-ground multipliers. netEntNewWord already sends name, radius, health and reach; it now also sends the lair. netEntFill restores boss2 by name. Ping names and takeover are extended, retaining the original lair, last position and health share. Late-join replay already sends post-build bodies.

Validation: mk script prints written against this worktree. validate.cjs confirms all 20 anchors are unique, non-overlapping and apply in order; patched game JS and fixture check parse; mk script is ASCII; baseline lacks bossTick2. The browser check has not run in this sandbox. It stages a seed-4242 career, checks spawn once, distance, stats, random-stream isolation, mirrored identity/lair, art scale, SP, and hoard/death once. No fixture-retarget file is supplied and no known old check was changed.

Four camera recipes stage smooth body comparison and real hoard output, including a netEntFill mirror for the body view. They are representation checks, not proof of a live two-window session. The hoard peer recipe shows the same real container output locally; actual transfer must be verified in the linked review. Request 1080p and 4K for both actual windows; the camera defaults may cover only 1080p.

LINKED REVIEW NEEDED: synced. Shared fields are ent name/radius/hp/lx/ly, generated hoard containers, shared SP kill words (boss2), and takeover boss reconstruction. Review both actual windows including a late join and host departure, and retain their body-comparison and hoard pictures. Lane still owes preflight, ship, ON HIS PC, pictures and critic results.

Watch: a second boss can crowd the map and cost frames; watch whether players find it and whether it reads as different from the Overseer. This line is in draft why for DESIGN.md.


--- codex run 2026-11-08 05:56 ---
2026-11-08: Follow-up to failed preflight for cw-cx-juggernaut (zero boss2 bodies on both runs). Kept all production edits and all placement distances unchanged. Fixed the check and camera staging to pin FXS=24241 after deployment; the game seed alone does not pin this separate effects stream. The check restores the prior effects state in finally and now diagnoses an invalid career/authority/disabled/already-done setup separately.

Why this matters: an offline grid over authored Cold Storage found only 857 of roughly 33000 points eligible before walls (about 2.6 percent) after excluding every spawn/ring by 900 and the centre by 1800. Forty unpinned random free spots can therefore legally yield no boss, which the job explicitly allows in play. The successful-spawn check needs a reproducible effects seed as well as world seed 4242. No placement restriction was loosened and no retry loop was added to gameplay.

FXS 24241 proposes (122.78,3290.29) first. Static-map inspection places that point 1341.79 from the nearest authored spawn, 1059.34 from the nearest authored ring, and 2537.40 from map centre, outside all authored walls and building footprints padded by 50. The browser gate must still confirm the final built map and the actual spawn/death path; this sandbox cannot run it. The check continues to require exactly one boss, required distances/stats, peer identity/lair, 1.3 art scale, SP, and exactly one four-item hoard.

Regenerated draft and four camera recipes. Script prints written. All 20 unique non-overlapping edits still apply sequentially; patched game and check parse; mk script is ASCII. No tracked files changed. No fixture retarget requested. Await lane preflight/ship/ON HIS PC and camera/critic. Previous synced linked-review handoff remains required, including actual two-window and 4K pictures; local camera representation staging is not a linked-session test.
