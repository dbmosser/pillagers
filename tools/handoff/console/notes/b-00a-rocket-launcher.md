# b-00a notes
Plan: step1 key cw-gunkeys0 (S/mk-cw-gunkeys0.ps1): GUN_CLASSES drop marksman, add 'rocket' as 9th (key 0 via slotKeyName/slotKeyCode helpers), Digit0 zoom -> Numpad0, Digit9 nothing, labels.
Step2 cw-rocket: WEAPONS.rocket + ITEMS.gun_rocket, class 'rocket' (GUN_CLASS_OF), rocket bullet w/ blast (explodeFrag-like at ~18411; bullets in updateBullets ~29319; splice at ~29721), reload via p.reserve (30 ammo per rocket, mag 2).
Step3 cw-nomarksman: remove dmr + whisper everywhere (grep dmr|whisper|marksman), saves convert. Old fixture checks using dmr (25632,36400,38062,74559 wear) may need retarget by fixq.
Known: fixture check at 12130 uses keysBind('Digit0') + legend row '0' - may fail after step1; retarget to Numpad0 / 'NUM 0'.
Status: step1 mk script written.
