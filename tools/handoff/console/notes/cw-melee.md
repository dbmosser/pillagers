# cw-melee notes (2026-10-18)
His orders: chat "melee should be really strong and a viable combat option, should one-shot a crawler"; in-game note 11:42 "melee should damge world elements like windows, walls etc" (exports/consumed-feedback-20261018-114224-673.txt and .png, renamed after the ship).

SHIPPED
- v31.14 cw-meleeone (commit 7c5d0d1e): crowbarDmgOn(e) works the blow out from the body it lands on. MELEE_SWINGS {crawler:1, snitch:1, raider:3}: blow = max(30, ceil(hp / swings)), +1 swing for an elite, hp = max(maxhp, hp) so CFG.eHp and the player 2 copy both work. Boss (Overseer) keeps CROWBAR_BOSS 18, golden and every other machine take the flat CROWBAR_DMG 30 (was 18). Arc 0.9 to 1.2 rad (wep.arc). crowbarFeel(): hit marker, damage number, bleed on a pillager, hit stop on a body left standing, kill = shake 3.4 + white sparks + meleeFoley('kill'). Player 2: netShotSend carries the number and a hs flag (arg 8).
  Reach (60), the 420 ms clock, the bare hands punch, the blow from behind and the bot (meleeStrike refuses in a sim raid) are unchanged.
- fixture f0a0de97: check 26.09 (crowbardmg) accepts 1 to 3 swings so it holds on the old and the new build. 26.06, 27.89, 29.07, 25.67, 13.84 pass untouched on v31.14 and v31.22.
- v31.22 cw-meleebreak: crowbarWalls(p,base), called from the same melee branch of fireWeapon only when the swing struck no body. crowbarWallAt casts 5 rays (0, +-0.4, +-0.8 rad, reach 46, middle first) through wallsNear(G.wgrid). The blow is CROWBAR_WALL 40 through damageWall (nothing new: wallHp tiers, bar, rebuildGeometry, debris, wallsDown, netWallAsk to the host, netWallGone to every window). wallHp null (map edge, stronghold shell, locked room, keyed door, ledge) and CFG.destruct 0 only ring (clank + sparks, nothing counted). A break pings 340.
  Swings to break: window 1, furniture 2, tree 3, wreck 4, building wall 8, terrain 18.

CHECKS: 31.14 (one real meleeStrike per case) and 31.22 (A window, B building wall + control by shot, C0-C2 border, locked room, keyed door, D destruction off, E body in the way, F player 2 asks and host tells). C3 (stronghold shell) is staged only when the seed has one; seed 4242 map 0 has none, so it never ran in the gate (the shell is noDes, same path as C0).

LEFT / CAVEATS
- No before picture: a fixture built from an older archived build (builds/v31.13.html with the current mkfixture.ps1) does not load, so only the after pictures exist: tools/handoff/shots/melee-20261018/.
- In the second window the wall keeps the local damage bar until the host's word arrives, as with bullets.
- The crowbar can break walls near the player at 46 reach: a swing at a body in the same line takes the blow instead (body first).
