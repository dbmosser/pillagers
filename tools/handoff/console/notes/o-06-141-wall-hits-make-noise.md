
--- codex run 2026-10-28 13:45 ---
2026-10-28: Prepared cw-cx-wallnoise for lane preflight and shipping. No tracked game or fixture files were edited.

Player bullets now make a 200-unit AI noise at the entry face of a wall, including penetration and stop/ricochet branches. Impacts within 220 units of the firing point are skipped. G.impNzT limits impacts to one every 0.2 seconds per window. Glass, rockets and enemy rounds are excluded. Noise setting and weather apply once, with pre=1 preventing rig rattle. Player 2 uses the existing NET.nzQ path to the host. No text, visual assets, audio layers or random draws were added.

The regression check stages a sentry 120 units behind a concrete wall 600 units from the shooter, with blocked sight. It fires a real pistol shot and checks investigate coordinates near the contact point in solo, host and join roles. Join noise goes through netFxStep and netFxTake before checking the host sentry. The open-ground control expires at the normal pistol range without waking the sentry. Additional cases cover penetration, near walls, glass, enemy rounds, rockets, scaling, ping flags and the shared rate cap. Smooth look is selected. The real pistol has only 420 range, so the staged distant shot clones it with 900 range and zero spread, retaining 330 firing noise; gameplay weapon values are unchanged. Penetration samples stop after the first wall crossing so a later body hit cannot mask the investigation result.

Local validation passed: mk prints written; all three anchors occur once; generated draft edits inspected; patched game inline JavaScript and new check compile; isolated impact helper passes radius, flags, 220-unit boundary and rate-cap checks; mk script is ASCII. The browser fixture check cannot be run in this sandbox. Lane must run preflight, ship, seed fingerprint gate and ON HIS PC confirmation. Both network roles are covered by the fixture check; a real linked-window playtest is still useful. No UI camera requested because this changes AI hearing only.

The draft why field includes the requested DESIGN.md watch line; gen-draft.ps1 places that field in the DESIGN entry: shooting a far wall now pulls machines as intended, and stray fire wakes more of the map; watch stealth raids and whether the demo gets busier.

