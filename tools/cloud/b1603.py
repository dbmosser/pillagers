from gen import patch, fixture
patch(1603, [
("""if(sees&&p.downed&&e.kind!=='raider') sees=false;""",
"""if(sees&&p.downed&&e.kind!=='raider') sees=false;
    // v16.03, HIS ORDER: A LIGHTNING FLASH SHOWS YOU TO THEM FROM FARTHER, NOT ACROSS THE WHOLE MAP. While the flash is up
    // (G.lightning, set by the bolt) anything looking your way sees you out to FLASH_SEE times its own sight, through its own
    // cone and walls (canSee), and not under a roof on either side. Crouching does not hide you in the flash inside that range.
    // Blinding still cuts it (wkSight is in _fSee). Nobody sees you down. No draw is made here.
    if(!sees&&G.lightning>0&&!p.downed&&!roofAt(p.x,p.y)&&!roofAt(e.x,e.y)) sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee*FLASH_SEE,e.cone,_aSee*FLASH_SEE);"""),
("""function canSee(px,py,face,tx,ty,segs,far,cone,amb){""",
"""var FLASH_SEE=2;   // v16.03, his order: how many times farther a machine or pillager sees you while a lightning flash is up
function canSee(px,py,face,tx,ty,segs,far,cone,amb){"""),
("""  wxTick(dt); strikeTick(dt); try{ tickHot(dt); }catch(_th){}""",
"""  wxTick(dt); strikeTick(dt); if(G.lightning>0) G.lightning=Math.max(0,G.lightning-dt); try{ tickHot(dt); }catch(_th){}   // v16.03: the flash counts down headless too (render2D, its only countdown, never runs in the sim), or a sim bolt would show the bot for the rest of the storm"""),
("""   line:'Storm. Lightning strikes, and every flash shows you the whole map for a moment.'}   // v16.01, weather audit finding: the old line promised the flash shows you to everything out there, and nothing on the map reads it""",
"""   line:'Storm. Lightning strikes, and every flash shows you the map and shows you to them from farther off.'}   // v16.03, his order: the flash shows you to them, farther, not across the whole map"""),
("""    if(MW.lightning) wv.push('lightning strikes, and a flash shows you the map');   // v16.01: the flash lifts the fog for you; nothing on the map reads it""",
"""    if(MW.lightning) wv.push('lightning strikes, and a flash shows you to them from farther');   // v16.03: the flash lifts the fog for you and doubles how far they see you"""),
("""      // for you (above). Nothing on the map reads it; whether it should is his call (v16.01)""",
"""      // for you (above), and updateEnts reads it: they see you FLASH_SEE times farther while it is up (v16.03, his order)"""),
], "A LIGHTNING FLASH SHOWS YOU TO THEM FROM FARTHER. His order. While a flash is up, anything looking your way sees you out to twice its own sight, through its own cone and walls, not under a roof, and crouching does not hide you inside that range. Not the whole map. The flash counts down in the sim too. The storm line and the CONDITIONS row say so. Map building untouched. Check 16.03 fails on v16.02",
"# A LIGHTNING FLASH SHOWS YOU TO THEM FROM FARTHER, NOT ACROSS THE WHOLE MAP. His order, answering the question parked at v16.01.\n")
fixture(1603, r"""  {v:'16.03',what:'a lightning flash shows you to them from farther, not across the whole map: an enemy facing you at 1.6 times its sight on open ground sees you in the flash and not without it (control), one at 3 times its sight does not see you even in the flash, and a sim step counts the flash down',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof updateEnts!=='function'||typeof roofAt!=='function') return 'SKIP: this fixture cannot stage a raid';
     var bad=[], keepE=null, keepV=null, e=null, p, i, a, r;
     function look(d,flash){
       e.x=p.x+d; e.y=p.y; e.face=Math.PI; e.state='patrol'; e.alert=0; e.seenYou=false; e.blind=0; e.cd=9; e.overheat=0;
       G.lightning=flash; G.pCrouch=false; G.pConceal=1;
       try{ updateEnts(0.001); }catch(x){ bad.push('updateEnts threw: '+x); }
       return !!(e.seenYou||e.state==='chase'||e.alert>0);
     }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: no raid staged';
       p=G.player; p.downed=false;
       for(i=0;i<G.ents.length&&!e;i++) if(G.ents[i].kind==='sentry'&&G.ents[i].rng>0) e=G.ents[i];
       if(!e) return 'SKIP: no sentry on this map';
       keepE=G.ents; keepV=G.vseg; G.ents=[e]; G.vseg=[];
       r=e.rng;
       for(a=0;a<40;a++){ if(!roofAt(p.x,p.y)&&!roofAt(p.x+r*1.6,p.y)&&!roofAt(p.x+r*3,p.y)) break; p.x+=137; p.y+=91; }
       if(roofAt(p.x,p.y)||roofAt(p.x+r*1.6,p.y)) return 'SKIP: no open ground found';
       if(look(r*1.6,0)) return 'SKIP: the sentry sees him at 1.6 times its sight without a flash, so this staging cannot tell';
       if(!look(r*1.6,0.3)) bad.push('in a lightning flash a sentry facing him on open ground at '+Math.round(r*1.6)+' (1.6 times its sight of '+r+') did not see him');
       if(look(r*3,0.3)) bad.push('in a lightning flash a sentry at '+Math.round(r*3)+' (3 times its sight) saw him, so the flash shows him across the map');
       G.sim=1; G.lightning=0.34;
       try{ simStep(0.15); }catch(x2){}
       if(!(G.lightning<0.34)) bad.push('a sim step left the flash at '+G.lightning+', so the bot would be seen for the rest of the storm');
     }
     finally{
       try{ if(keepE) G.ents=keepE; if(keepV) G.vseg=keepV; }catch(_k){}
       try{ G=null; keys={}; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
