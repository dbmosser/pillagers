# 40-art-player-look notes
- drawOp at dark_raiders.html ~34766 (v31.23). Call sites (v31.23): 36237 (hires?), 38361/38542 (you), 38424 (downed bot), 38449 (bot), 46405, 47418/47438/47466 (hub), 54295 (mate hub), 55616 (mate raid); previews 66654/66693/67074/34090 swap wc=x2 (do NOT scale: only scale when wc.canvas===cv; rimOpen swaps wc to RIM.xa so check must also allow RIM.on).
- Nameplates: netUpTags ~55627 (mate raid: plate y-62, 13 high; DOWN plate y-77), netDrawTags ~54299, raiderGetUpBar ~19294 (by=e.y-37), roleAnchor ~23806, spriteTop ~35685 (humans fallthrough return 40, shared with machine kinds!).
- drawOp structure: shadows 34775-76; down/roll returns 34782-98; legs 34839-97; gun behind 34901; pack 34902-17 (closing } after drawPackExtra line); torso 34918-28; drawRigPC/drawVest 34937-41; bulk plates 34981-35024; patch 35029 drawPatch(wc,_pid,px,py,3.6); hurt flash 35030; head begins 35043 hx2; hair-behind starts 35054 (HERO&&long/pigtails).
- Plan: wrapper drawOp -> scale about feet (FIG_SCALE const * build) + inner drawOp0; head wrap scale 1.2; shadows a09; pack 1.3, vest/pads 1.12, patch 1.6 (no hat/hair rescale); mate plate + 36x3 bar.
- Frame cost: TBD
