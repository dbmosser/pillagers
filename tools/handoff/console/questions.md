# Questions for him

- 10-18 (c-30-ui-menu-map): (1) The pause box has "Please provide feedback anything that went or felt wrong." over the FEEDBACK button: an explaining sentence and the same job twice. It looks like your wording from v10.41, so I left it. Drop it, or keep? (2) The title mode list has the two "coming later" server rows between live rows. Move them to the bottom (after PVP same machine)? Left in your order.

- 10-17 09:40 (b-11-lean8-fewer-guns): dark_raiders.html is DIRTY (uncommitted VER 28.79 + a gun-weight edit) after a cw-fewerguns STOP ("container fingerprint moved") that was not mine. shipone.sh does not revert the game file on a STOP, and I may not run git checkout, so every ship (cw-helmbar already, then mine) now STOPs "uncommitted changes" or MK FAILs. Please run `git checkout -- dark_raiders.html` (check first that no wanted work is in the diff: it is only that gun edit and VER/DEVNOW 28.79). Then run: bash S/shipq.sh cw-fewerguns. The mk script is ready (the fixed version: split rows, totals unchanged).

- 10-20 (b-20-quality-pass): the Current pillagers board and the end card rows still draw $ for values (for example $2,950, about 20 places in dark_raiders.html). Your rule is score in SP, never $. Are those haul and credit values meant to stay $ (credits are $ in the shop), or should the pillager board read SP? Left as is.
