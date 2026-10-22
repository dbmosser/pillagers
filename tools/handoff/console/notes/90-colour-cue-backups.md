
--- codex run 2026-10-22 06:10 ---
2026-10-22 task 90, lane o, first audit pass (v34.00).
No game changes prepared: the job explicitly asks for greyscale picture audit first.
Requested six original-colour baseline photos through camera-recipes.json: stocked stash with one gun per rarity, raid backpack, HUD including minimap, sector map with intel enabled, combat warnings, low health. Next run: desaturate into local output copies, inspect, finish the cue list, then prepare small ships.

Source findings for the requested notes/73-colour-cue-backups.md audit (the original numbered task path is outside the writable worktree):
- Rarity: dispR/gunRarity choose the correct rank, RCOL and rfill encode ranks with colour/tint. Inspect tile, backpack, belt and world loot drawings for existing rank names; assign a shared non-colour rank treatment where absent.
- Minimap mmMarks: visible foes and teammates are filled circles; teammate facing line disappears while downed and downed changes only colour. Doors open/locked use identical squares. Danger/weapon/location pings use identical diamonds. Distant extraction/seal/forge/waypoint/teammate objectives all use mmArrow with colour as the type distinction.
- Minimap extraction points already have letters and closed points have a cross. Open versus closing depends on colour; inbound/live pulse at different rates. Seal completion also changes only colour. These states still need a static backup.
- Full map keys already have a key drawing plus key label; exits have an extraction glyph, letter and state/countdown text. Locked rooms have open/locked labels. Seal has percentage/broken text, forge has anvil, hot ground has warning glyph and text. Do not add redundant marks to these.
- Full map intel elites are plain purple dots: inspect against teammate dots, then give a distinct shape if needed.
- World side marks TEAMCOL are the same little coloured rectangles/lamps on both sides; role ornaments differ by role, not allegiance. Inspect both figure renderers before changing.
- Low HP has hp number/bar plus edge pulse; combat callouts use text. Inspect pictures for warning states with only a colour difference before expanding scope.

Settings cbApply only swaps tables; keep all new shape cues always on and keep the existing single setting row.
Next-play watch line for eventual ships: check marker overlap at the minimap edge, enemy versus teammate marks during a fight, and rarity marks on small belt tiles. No simulation or timing change is planned.


--- codex run 2026-10-22 06:20 ---
2026-10-22 audit completed for the six captured views; minimap remains a camera gap to fill before changing it.
Converted all six baseline JPGs to greyscale copies in .codex-work/90-colour-cue-backups/greyscale-before and inspected them. The detailed cue list is .codex-work/90-colour-cue-backups/notes/73-colour-cue-backups.md (the requested legacy 73 name, inside the writable output folder).
Prepared two independent small ships in keys.txt:
- cw-cx-raritypips: the shared item painter adds one to five cream square pips on an ink strip below every ranked item/gun icon. Both DOM menu images and cached HUD sprites inherit the same marks. Variants use displayed rank; fists and unknown keys get none. Always on, no setting. Watch: pips on the smallest belt/shortcut icons must remain separate from counts and key numbers.
- cw-cx-inteltriangle: full-map elite intel is a purple triangle with a cream outline, separate from round peddler/party points. Watch: triangle edges near dense map labels.
Both mk scripts printed written against the sandbox v34.00. Drafts were read back, all anchors occur once, both check bodies parse, and the patched main game script parses. Browser gates remain for the lane. The rarity check samples real pixels for 1-5 pips in all four colour modes through direct drawing, cached sprites and the menu-canvas path. The intel check records the actual triangle path and cream edge from the deployed map pass. No fixture retarget requested.
Updated six camera recipes for colour/greyscale rarity review, greyscale elite map review and the missing minimap baseline. The existing minimap setting is enabled only in this fixture recipe; his later cw-mmoff default-OFF order remains untouched.
Remaining after these ships: minimap door/state/ping/objective and ally/foe backups; world side marks; check any appearance-only rarity frames. Existing key/exit glyphs, labels, seat numbers, warning triangles/text and loot-shaft heights already provide backups. No gameplay or pulse timing changes prepared.


--- codex run 2026-10-22 06:28 ---
2026-10-22 follow-up on v34.01: cw-cx-raritypips shipped. cw-cx-inteltriangle was refused before preflight because the JavaScript identifier iex matched the forbidden PowerShell alias. Renamed the local variables to eliteX and eliteY; no drawing or check behaviour changed. The repaired mk script prints written, its anchor occurs once, its check parses, and the patched game script parses. Both keys remain in keys.txt; the lane skips the shipped rarity key.
No second camera round arrived because of that refusal. Updated camera-recipes.json to spend the six views on greyscale rarity stash/backpack, greyscale elite map, the enabled-minimap baseline, and world allegiance baselines in fixture seat 1 and seat 2 contexts. The world recipe stages nearby hostile and friendly human pillager bots and a local roster/peer stub, with no peer connection or channel created. These are renderer baselines, not a claim that live two-window networking has been tested.
Remaining source audit: pixDrawOp also uses the same team-coloured lamp, and pixel bot clothing mainly changes palette. The eventual world backup must cover both pixel and vector body paths. Numbered player seat badges must stay as they are; unnumbered friendly hires and hostile human pillager bots need distinct simple signs.
Appearance-only colour rarity frames are in the legacy vector wardrobe, reached when pixel rendering is OFF. The active pixel wardrobe has no data-rar colour cue; it shows names and owned/worn/unlock text. The vector fallback still needs a rank backup, so do not discard that remaining audit item as dead code.
Still pending after the repaired intel ship and pictures: world side signs; minimap ally/foe, door, extraction state, seal, ping and distant-objective shape backups; legacy cosmetic rarity backup; critic review of changed cues.

