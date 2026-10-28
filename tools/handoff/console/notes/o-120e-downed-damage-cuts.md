
--- codex run 2026-10-28 00:26 ---
2026-10-28: Read idea 6 and the current damagePlayer path. No existing task notes were present. Prepared cw-cx-downcuts: retain the kid/demo multiplier used on incoming health damage and apply it, CFG.eDmg and easyDmgMul to the base 3-second downed hit. The same path serves live play and G.sim. No seeded random calls added or removed; standing health damage and the normal career 3-second downed hit stay unchanged.

Important ruling conflict in the old brief: ARCADE_DMG is 1 on current HEAD. The adjacent unify1 owner ruling says demo and career gameplay must match. Preserved 1. The regression explicitly probes ARCADE_DMG=0.5 temporarily to verify that a half demo setting costs 1.5 seconds, without restoring the obsolete default. Current easy uses EASY_MUL; joined players use the lower own/host kid factor; host ignores kid mode. Also covers a joined player who took over the raid and both live/sim paths. Compares actual standing HP loss and downed timer loss for the same 8-damage round, plus normal career and forgiving controls. Restores all touched persistent dials.

The draft why text becomes the DESIGN.md entry through gen-draft.ps1 and contains the requested playtest watch line. No fixture retarget appears necessary: existing demo checks already accept the current ARCADE_DMG, and the current downed telemetry checks do not require a flat timer penalty. The check must fail on the old flat-3 build for kid/easy and the half-demo probe.

Local anchor generation and JavaScript syntax verification are recorded in the final response. Browser checks, fingerprint, shipping and ON HIS PC must be run by the lane. Camera recipes provide smooth-look host and joined-role downed damage stages, with numerical assertions before rendering. These are separate staged views, not proof of a connected two-window revive; lane/coordinator must confirm the connected pair separately to satisfy the both-windows rule.

