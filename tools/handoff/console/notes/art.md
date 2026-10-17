# art.md (see also c-01-art.md)

SHIPPED (run 3, 10-17 ~12:00): step 1, cw-helmbar = v28.79 (commit 3620a47c). The Heavy helmet crest is now a low steel ridge, the scheme
accent is a small brow lens (ink housing + white glint). Check measures pixels on schtoxic: accent column run <= 4.5 px and >= 20 accent pixels.
Gate passed, fingerprint held (85/374, 165/593). The earlier blocker (dirty game file, orphan 28.79 fixture check) was cleared by other workers.

NEXT (brief order), each its own cw- key with a pixel/draw-call check:
2. Ink outline (1 px) + four-step hue ramps lit top-left on the player body (drawOp in the game file; headgear code near line 33195).
3. Pouches and bandolier.
4. Goggle/visor glint.
5. Soft cast shadow + gun shadow.
6. Heavy/Raider set plates (chipped paint, panel stripes, chunkier pauldrons).
7. Bake each look to an offscreen sprite per facing and walk frame (biggest, riskiest; gun and arms stay live).
Notes: older check 28.16 tests the Heavy helmet by pixel difference between schemes, so keep a full-strength accent somewhere on it.
Check pattern: paint drawOp(0,0,0,0,'#242832',0,0,'none',0,st) onto an offscreen canvas at 3x with wc swapped (see mk-cw-helmbar.ps1).
Draft key numbers: next ship is 28.80.
