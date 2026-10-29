
--- codex run 2026-10-28 21:57 ---
2026-10-28: Prepared cw-cx-reloadswitch against v36.22. Every held-gun assignment now goes through arSetHeldGun, which clears that player's arStk, arBonus, arGun and arHot before assigning a different weapon object. Covered ordinary swaps (next gun, belt keys and pad), pickup replacement, bag equip/stow, same-class replacement, forge upgrades, arcade kit and initial dev/free kit assignments. Re-selecting the same weapon object keeps the chain. Crowbar swings do not change p.wep and keep their existing behavior.

The only pickup-path edit replaces the held-gun assignment with this helper. Pickup stacking, sounds, rows, ammo, loot and seeded generation are unchanged. Corrected the two stale comments saying a chain survives a swap.

The new regression stages actual x2 reloads and checks immediate zero and hidden status on A-to-B and B-to-A, the next hit at x1/+15%, switching during a reload, a partner's independent chain, same-object selection, another copy of the same gun, melee weapon changes, bag equip to held/stowed slots, and stowing the held gun. It follows the existing 36.17 staging and runs under host and p2 identities. Control returns a specific failed chain assertion before reaching the new helper. No older fixture check needs a retarget: the old manually cancelled reload check never changes p.wep.

Local validation: mk printed written; all 13 anchors matched once; the drafted game's inline JavaScript and regression check parsed; static scan found every player held-gun assignment uses the helper. Game file and fixture were not edited. Chrome gates and seed fingerprint verification belong to the lane.

Handed over four camera recipes using the already working real linked-window setup from the reload-status task. Both windows start at x2; player 1 switches, then player 2 switches in separate scenes, with a picture from each window. Each scene asserts the switching seat has no chain/status and the other seat retains x2/+25%. Needs lane preflight, ship, ON HIS PC, pictures and critic. DESIGN watch text is in the draft's why field: switching guns ends the active reload chain.

