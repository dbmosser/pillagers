# b-00a-rocket-launcher notes
## Findings (run 1)
- Gun keys: HOTBAR_N=9 (l.2268), GUNKEYS=9 (2274), BELT_CLASS 9x'gun' (2278), GUN_CLASSES (23147) 9 classes, GUN_CLASS_OF (23148): dmr,whisper -> marksman.
- gunKeyTable accepts P.gunKeys only if length==GUN_CLASSES.length, else falls back (auto migration of saved plan).
- Digit handler raidKey ~15509 (dn 1..9, setHot(dn-1)); Digit0 = zoom 100% at ~15608 (+ controls lists 17183,17230); stall digits 15441.
- Plan: 10 keys. GUN_CLASSES = pistol,smg,rifle,carbine,lmg,shotgun,sniper,energy,spare,rocket (key 9 = overflow, key 0 = rocket). HOTBAR_N=GUNKEYS=10. Digit0 -> index 9. Key labels (i+1) need %10.
- Weapons in WEAPONS ~2766; WTIER 2810; explodeFrag 18411; reload code ~25295; p.reserve is the ammo reserve.
- Gate: recent.ps1 reruns 80 checks; fingerprint ents 85/374 must not move.
## Status
- nothing shipped yet
