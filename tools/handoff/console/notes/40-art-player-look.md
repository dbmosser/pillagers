# 40-art-player-look notes (lane a)
Plan (decided after reading code):
- ONE door: drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st) at ~34763 is called from every human site (hero raid, mate, bots x2, hires, hub crowd, peddler, tsk, netDrawPeer). Rename body to drawOpBody and make drawOp a wrapper that does save/translate(x,y)/scale/translate(-x,-y) with HUMAN_SCALE (1.25) * build factor (lean .92,1.08; broad 1.1,.96; curved 1,1). Shadow, seat ring, gun scale with it.
- a01 D: head block wrapped scale 1.2 about (hx2,ty-22). a05 B: pack 1.3 about (x-fl*9,ty-16.5), vest/pauldron plates 1.12 about (x,ty-17), chest patch 1.6 (hat/hair NOT again).
- a09 B: shadowE(x+1.5,y+2,12.5,5,.5), shadowE(x+7,y+3,8,3,.28).
- a10 D: netUpTags (~55624) plate y-62 (13 high) exists; add 36x3 bar under it (track #14171a, fill #5fae6f >50, #d0a13c to 25, #c8452f below, 1px black outline). Raise plates for bigger figure.
- Nameplates: ne plates use spriteTop(ne)+8 (~38607); party tags g.y-62; netDrawTags (hub) y-62. Raise with figure.
Status: (update below)
