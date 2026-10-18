# 11b-ui-motion notes
- References numbers: references.md lines 36-50, checks 77-89.
- Existing sound layer: sndUi(kind) ~5004, SND_UI table, 30ms guard, sndUiClick capture ~5022. padSetFocus ~16651 calls sndUi('move'). Test of old sounds at mkfixture 27931-27980 (kinds only, no freqs).
- DON'T grep broad patterns on the game file (data urls blow up output). Use anchored patterns.
- Plan (single mk script mk-cw-uimotion.ps1): 5 edits: (1) SND_UI/sndUi -> uiSndPick pure fn + rate cap 40ms for move, 3 pitch variants; (2) sndUiClick -> UIM.pulse/shake; (3) padSetFocus -> UIM.focus(el); (4) arcadeAttLoop after pg.setAttribute('data-ph',ph) -> UIM.tab(pg,1); (5) UIM layer inserted after titleFit IIFE (before document.addEventListener('wheel'...). 
- UIM: steppable clock (UIM.manual/step), tweens on root opacity + items `translate`/`scale` individual CSS props (compose with transform), observer on #title & #partymodal class 'on' (open 240 out / close 140 in via inline display), stagger 35ms max 8, focus ring div eases k=1-exp(-dt/.04), focus scale 1.05, pulse, shake, tab (200ms, 24px), frame log UIM.log.
- Retarget uses smoothstep from current value, duration scaled by remaining.
