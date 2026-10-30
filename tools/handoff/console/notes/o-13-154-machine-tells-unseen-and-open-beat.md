
--- codex run 2026-10-30 13:45 ---
2026-10-30: Prepared cw-cx-machineopen for task o-13-154-machine-tells-unseen-and-open-beat against v36.64. No game file was edited.

The draft adds the approved hidden-machine streak at the local target's feet, plain warden openings of 0.9 seconds, and every fourth actual bulwark shot with a 0.7 second windup, 2.5x damage, an 8-unit aim lane, and a 1 second opening. Existing aim scatter and cooldown random draws stay in their original order. No generation or spawn code changes. The Overseer gets the hidden warning but keeps its existing armour and vent cycle.

Open machines bypass front soak and its clank. Warden belly plates part around an orange/white core; the bulwark slab lowers and compresses vertically inside the existing body scale. Open bodies bypass the closed pixel sprite cache, so the opening is also visible if the owner changes looks. No player text or switches added.

LINKED REVIEW NEEDED: synced. The shared fields are netEntRow r[8] bit 8 (opening) and bit 16 (big windup), reconstructed by netEntFlagsApply. Bits 1, 2 and 4 remain intact. Bits 32 and above are untouched. Peer rounds use the copied opening before their damage is forwarded.

Validation available in the sandbox: mk script prints written; all 18 anchors occur exactly once; the actual draft reconstructs parsable game scripts; its fixture check and six camera recipes parse; mk output is ASCII. Browser checks, the seed fingerprint, preflight, ship and ON HIS PC are the lane's remaining work. No old fixture check was found that requires retargeting.

The new fixture check runs actual machine AI and front-round collisions, including the 0.3s and 1.2s warden timing, all four bulwark shots, peer damage forwarding, ninth-field round trips, the ground-pass stroke near the feet, and local/teammate target filtering in host and join roles. It fails on the original game, which lacks the opening and unseenTell.

camera-recipes.json supplies six views: warden open, bulwark big windup, and an unseen warden across a real wall, each in host and reconstructed join roles. Use both 1080p and 4k (uishots default). These are staged role pictures, not a claim that two live linked windows have been reviewed. The lane must return the pictures and critic findings; linked play still needs the CEO review above.

Watch: the bulwark's new 2.5x shot changes its rhythm. Check that its charge is readable, it avoids cheap deaths, and the opening is noticed. Check that the red streak reads as incoming danger rather than the player's aim, is noticed mid-fight, and never warns the wrong target. This Watch line is also in draft.why for DESIGN.md.

