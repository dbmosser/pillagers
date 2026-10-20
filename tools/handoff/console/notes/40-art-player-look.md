# 40-art-player-look notes
- drawOp at dark_raiders.html ~34766 (v31.23). Call sites (v31.23): 36237 (hires?), 38361/38542 (you), 38424 (downed bot), 38449 (bot), 46405, 47418/47438/47466 (hub), 54295 (mate hub), 55616 (mate raid); previews 66654/66693/67074/34090 swap wc=x2 (do NOT scale: only scale when wc.canvas===cv; rimOpen swaps wc to RIM.xa so check must also allow RIM.on).
- Nameplates: netUpTags ~55627 (mate raid: plate y-62, 13 high; DOWN plate y-77), netDrawTags ~54299, raiderGetUpBar ~19294 (by=e.y-37), roleAnchor ~23806, spriteTop ~35685 (humans fallthrough return 40, shared with machine kinds!).
- drawOp structure: shadows 34775-76; down/roll returns 34782-98; legs 34839-97; gun behind 34901; pack 34902-17 (closing } after drawPackExtra line); torso 34918-28; drawRigPC/drawVest 34937-41; bulk plates 34981-35024; patch 35029 drawPatch(wc,_pid,px,py,3.6); hurt flash 35030; head begins 35043 hx2; hair-behind starts 35054 (HERO&&long/pigtails).
- Plan: wrapper drawOp -> scale about feet (FIG_SCALE const * build) + inner drawOp0; head wrap scale 1.2; shadows a09; pack 1.3, vest/pads 1.12, patch 1.6 (no hat/hair rescale); mate plate + 36x3 bar.
- Frame cost: not measured (1 to 4 save/restore pairs per figure, no new draws).

## Run of 2026-10-20 (lane a): SHIPPED v32.64 (cw-figlook, abf82a29)
- One ship did a01 D, a02 B, a04 C, a05 B, a09 B, a10 D. drawOp is now a wrapper (drawOp0 is the old body): scale FIG_SCALE 1.25 times build height about the feet, only when wc is the main canvas or the rim scratch (previews on small canvases stay as they were). Head 1.2 about the neck (FIG_HEAD), pack 1.3, vest and pauldrons 1.12, chest patch 1.6, shadow a09 B values. Role marks scale with the body.
- One number to dial back: FIG_SCALE. FIG_UP (19) lifts plates, the use bar and spriteTop for raiders and survivors.
- Mate plate (netUpTags) lifted FIG_UP+3 with a 36x3 bar (netUpBar: green above half, amber to a quarter, red below). Hub tags lifted FIG_UP, no bar.
- Check cw-figlook reads the transform height of a drawOp at identity for lean, broad and curved. Gate passed, fingerprint unchanged.
- Pictures: notes/shots/40-figlook-before and 40-figlook-after (03 hub floor, 33 fight, 57 party). Figure clearly bigger, shadow bigger, hub plates clear.
- NOT DONE: hit areas untouched, but I did not check whether shots pass through the drawn edge: watch in playtest. No two-window picture of the mate plate and bar. Frame time not measured.
- Gotcha: uishots for lane a uses port 9361; preflight Chrome holds 9351.
