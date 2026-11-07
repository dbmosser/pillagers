
--- codex run 2026-11-07 12:47 ---
2026-11-07: Prepared cw-cx-healrisk at v37.48. LOCAL: no linked review.
Owner answers g-2 and g-5: medical wind-ups halve walking, cancel sprint in hold/toggle/pad-default modes, and preserve crouch. The existing movement floor follows the slow. Teammate medical aid uses the same prep field. Plates and flowing heals keep their movement.
Captured amt0 before the current cw-cx-downcuts kid/demo factors. Shared BIG_HIT=30 and bigHit(a) stop only a standing medical wind-up after a landed hit, with one lowercase heal interrupted callout outside simulation. The consumed item stays spent. Shield and invulnerability returns stay ahead of interruption; plates and the heal queue are untouched.
Anchor generation printed written. All eight edits match exactly once. Applied the draft in memory and parsed the complete game script and new regression check with Node. Runtime checks cannot run in this sandbox; lane preflight and shipping remain.
Check stages both local seats, all three sprint modes, 0.5 s movement controls, bandage, medkit, teammate aid, crouch, plate speed, flowing-heal speed, 10/29/30/40 incoming damage, roll invulnerability, spawn shield, demo and kid damage cuts, and item loss. No fixture changes identified or requested.
Two camera recipes stage the local host and join medical wind-ups in the smooth look, after real useMedical and updatePlayer calls. The camera holds the player timer for the picture; the gameplay check measures movement without that hold.
Watch: healing in the open gets riskier; check the 1.5 s half-speed wind-up for stickiness, whether the slow should extend through the 4.2 s bandage or 9.6 s medkit heal, and whether losing the item on a big hit feels too harsh. Included in draft why for DESIGN.md.


--- codex run 2026-11-07 12:59 ---
2026-11-07 follow-up: cw-cx-healrisk SHIPPED in v37.49, ON HIS PC v37.49 confirmed (51 s after ship). LOCAL: no linked review. Camera round 1 failed before staging because my minimal helper omitted the required U.prep method. Attached pictures are title-screen fallbacks and provide no medical-wind-up evidence. Added the same prep method used by the project camera (pin DPR 1), regenerated both recipes, and parsed the complete wrapper that tools/uishots.ps1 executes. No gameplay changes or new ship key. Request camera rerun for both seats; critic review still remains.


--- codex run 2026-11-07 13:05 ---
2026-11-07 completion: cw-cx-healrisk shipped in v37.49; ON HIS PC v37.49 confirmed by the lane. Both round-2 smooth-look medical camera scenes staged successfully at 1080p and 4k. Opened and inspected both 1080p pictures: host shows applying bandage, join shows applying medkit, each with the existing use bar; staging also asserts active prep and no sprint. These are local seat scenes, not a linked-network test. LOCAL: no linked review.
Critic score 2/5 for both complete raid HUD pictures. The critic reports existing expanded controls, duplicate extraction distance, scoreboard, contract banner, panel grouping and input label issues; it reports no defect in the medical use bar. The full HUD has NOT met its visual finish line. Logged those unresolved P0/P1 findings in alarms-new.md for separate coordinator HUD work, following the rule against mixing feel changes and UI/art changes. No additional healing code is needed or queued. Closing this mechanics task on its shipped change, both-seat regression, pictures, and ON HIS PC confirmation.
Verified pictures: tools/handoff/console/notes/shots/o-h02-147-heal-slows-big-hit-stops-it-recipes-2/heal-windup-host-1080.jpg and heal-windup-join-1080.jpg. Round 1 title-screen fallbacks are invalid and should not be treated as before pictures.

