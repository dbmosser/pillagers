
--- codex run 2026-11-07 14:03 ---
2026-11-07, run 1, baseline v37.50.

Prepared cw-cx-blastnudge. Job 147 already shipped: BIG_HIT=30 and amt0 captured before damage cuts exist, so this draft reuses them. No game file or fixture was edited.

The draft adds the 300 units/s, 0.14 second radial shove after a survived standing hit. It reuses kickVx/kickVy/kickT and the existing collide path. Six direct blast sites retain their current range, sight, roof and ownership guards: explosive barrel, damaging barrel kinds, frag/rocket, Howler, host debris and peer debris. Cryo still skips damage. Lightning and lingering fire/acid pools stay out. Blast context is scoped with try/finally and restored even if damage throws.

netHitPlayer now accepts an optional eighth argument for blast radius, forwards bl in hit packets, and scopes local damage. netAreaHitPeers forwards opt.bl, frag and Howler supply it, volatile elites supply R, and netHitTake validates bl and scopes received damage. No new packet type or random draw.

Big non-blast hits use the existing incoming threshold, replace a signed 0.06-0.09 radian nudge, and decay for 0.25 seconds while the item wheel is shut. The source-angle sign pushes aim away; no source or a source dead ahead uses +1. The mouse reticle stays fixed. Gun facing drives the existing dotted line and actual rounds. No text, option, motion-setting dependency or seed-generation change.

Sandbox verification: mk script printed written; all 17 exact anchors matched once and applied without overlap in memory. The patched game inline JavaScript and fixture check parse with Node. The baseline lacks BLAST_SHOVE_V, so the check fails before the change. Browser execution remains the lane responsibility. No existing fixture check needing retarget was identified.

The regression check stages a real seed-4242 raid, tests both host and received-hit join roles, near/distant/occluded blasts, wall collision, shields, i-frames, downing hits, simulation exclusion, nudge side/threshold/replacement/recovery, wheel pause, actual trigger-fired round direction, and blast/non-blast packet fields. The test restores input, options, profile and networking state.

Four camera recipes request smooth-look host/join shove and aim-nudge snapshots. They freeze player updating after a real hit and steps to preserve the short effect for the camera. These fixture role pictures do not replace the connected two-window review. Camera outputs and critic findings are pending.

LINKED REVIEW NEEDED: synced. The existing hit word gains m.bl, with centre in m.x/m.y. Please verify host and peer blast delivery in connected windows, and a peer round fired during the nudge. Task remains partial until gate, ship, ON HIS PC and the required pictures/review return.

Watch: being shoved by your own frag or rocket up close must feel fair, and a shove next to deep water or a doorway must read; the aim nudge is felt most in long duels and must never read as input lag or a bad mouse. This line is also in the draft why for DESIGN.md.


--- codex run 2026-11-07 14:08 ---
2026-11-07, run 2: corrected the new check after spare-PC preflight failed twice identically on drafted v37.51. The production edits are unchanged.

The missing-round failures were caused by the check replacing p.wep with a zero-spread clone: drawTick correctly treated the new object as a gun switch and imposed the rifle draw delay of 0.825 seconds, longer than the 0.25-second nudge. The check now marks that test rifle as already drawn using p.drawRef and p.drawT=0, then still fires through the real updatePlayer trigger path and examines the real projectile direction. Each reset also restores drawRef to the baseline weapon.

The replacement failures were caused by the check dealing 90 then 30 damage to a 100-health player. The second hit downed the player, and the implementation correctly withheld a new nudge. The check now deals 45 then 30 from opposite sides so both hits are survived, and explicitly requires positive health while checking replacement magnitude and timer. The separate downing-blast exclusion check remains.

Regenerated the draft: written. All 17 anchors again applied once without overlap in memory; the patched inline game script and fixture check parse. Browser execution and all ship gates still belong to the lane. Please retry cw-cx-blastnudge with the corrected check, then capture the existing four smooth role recipes.

LINKED REVIEW NEEDED: synced (m.bl added to hit packets). Pending preflight, ship, ON HIS PC, camera/critic results and connected two-window review.
