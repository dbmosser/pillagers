from gen import patch, fixture
patch(1628, [
("""    var _bR=390*(HUDZ.body||1)*_hz;        // vitals block, inner edge
    var _gL=W-252*(HUDZ.gear||1)*_hz;      // gear stack, inner edge""",
"""    // v16.28, his note: the HP bar ran under the belt. These edges ignored the size and place he gave each block, so a vitals block
    // made bigger or moved right went under the slots. They now read both (hudUserZ, hudOff), and the slots shrink to fit.
    var _bR=390*(HUDZ.body||1)*_hz*hudUserZ('body')+Math.max(0,hudOff('body').dx);        // vitals block, inner edge
    var _gL=W-252*(HUDZ.gear||1)*_hz*hudUserZ('gear')+Math.min(0,hudOff('gear').dx);      // gear stack, inner edge"""),
("""    bw=clamp(bw,LH(52),LH(112));""",
"""    bw=Math.max(20,Math.min(bw,LH(112)));   // v16.28: the slots fit the room between the blocks, smaller if they must be, never over the vitals or the gear"""),
("""  return {dx:o.dx||0,dy:o.dy||0,c:!!o.c};""",
"""  return {dx:o.dx||0,dy:o.dy||0,c:!!o.c&&id!=='body'};   // v16.28, his note: the vitals block (health) never folds away"""),
], "THE HP BAR IS ALWAYS THERE AND THE BELT NEVER COVERS IT. His notes. The health block can no longer be folded away, and the tactical belt now fits between the health block and the gear readout as you have sized and moved them, with smaller slots if it has to, instead of drawing over your health. No number moved. Check 16.28 fails on v16.27",
"# THE HP BAR IS ALWAYS THERE AND THE BELT NEVER COVERS IT. His notes of 2026-09-27.\n")
fixture(1628, r"""  {v:'16.28',what:'the HP bar is always there and the belt never covers it: the vitals block does not fold; with the vitals block made twice as big the belt slots start right of it and end left of the gear readout',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof drawHUD!=='function'||typeof hudOff!=='function') return 'SKIP: this fixture cannot draw the HUD';
     var bad=[], keepHud=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined, c, z, bR, gL, last;
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false;
       P.hud={body:{c:true}}; if(hudOff('body').c) bad.push('the vitals block (health) can still be folded away');
       P.hud={body:{z:2},gear:{z:1}};
       try{ drawHUD(); }catch(e){ bad.push('drawHUD threw: '+e); }
       c=G.hotCells||[]; if(!c.length) return 'SKIP: no belt cells drawn';
       z=hudRes(); bR=390*(HUDZ.body||1)*z*2; gL=W-252*(HUDZ.gear||1)*z;
       last=c[c.length-1];
       if(c[0].x<bR) bad.push('with the vitals block twice as big the first belt slot starts at '+Math.round(c[0].x)+', under the vitals block (which reaches '+Math.round(bR)+')');
       if(last.x+last.w>gL+1) bad.push('the last belt slot ends at '+Math.round(last.x+last.w)+', under the gear readout (from '+Math.round(gL)+')');
     }
     finally{
       try{ if(keepHud===undefined) delete P.hud; else P.hud=keepHud; }catch(_h){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
