from gen import patch, fixture
patch(1614, [
("""  if(NET.on&&!G.sim){ try{ netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended, and nobody is drawn up top any more""",
"""  if(NET.on&&!G.sim){ try{ if(!netSpecStart(how)) netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended; v16.14: unless the host spectates for the party still up top"""),
("""  pollPad();""",
"""  pollPad();
  if(NET.on&&NET.specG) netSpecTick(dt);   // v16.14: the raid the host left runs on for the party still up top, whatever this window shows"""),
("""function netOnMsg(peer,data){""",
"""// v16.14: while the host spectates, every word is handled against the raid world it keeps running, whatever this window shows.
function netOnMsg(peer,data){
  if(typeof NET==='object'&&NET&&NET.specG&&G!==NET.specG){ var _kg=G; G=NET.specG; try{ return netOnMsg0(peer,data); } finally{ G=_kg; } }
  return netOnMsg0(peer,data);
}
function netOnMsg0(peer,data){"""),
("""function sfx(type,wx,wy,wid){
  if(G&&G.sim) return;""",
"""function sfx(type,wx,wy,wid){
  if(G&&G.sim) return;
  if(typeof NET==='object'&&NET&&NET.specTick) return;   // v16.14: the raid a spectating host keeps running for the party makes no sound in his window"""),
("""  var best=G.player, bd, i, g, b, d, up;""",
"""  var best=G.player, bd, i, g, b, d, up;   // v16.14: a host who is out (spectating) is nobody's target"""),
("""  bd=dist(e,best); up=!best.downed;""",
"""  bd=dist(e,best); up=!best.downed;
  if(best.specOut){ bd=1e9; up=false; }"""),
("""  var d=G.player?dist(pt,G.player):1e9, i, g, q;""",
"""  var d=(G.player&&!G.player.specOut)?dist(pt,G.player):1e9, i, g, q;   // v16.14: not the spectating host"""),
("""function netPlayersList(){ var out=[], i, g; if(G&&G.player) out.push(G.player);""",
"""function netPlayersList(){ var out=[], i, g; if(G&&G.player&&!G.player.specOut) out.push(G.player);"""),
("""  st=(m.st==='in'||m.st==='out'||m.st==='no')?m.st:'';""",
"""  st=(m.st==='in'||m.st==='out'||m.st==='no'||m.st==='spec')?m.st:'';   // v16.14: spec, the host is out and keeps the raid running"""),
("""  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended, so this one ends as abandon for the whole party, his ruling""",
"""  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended with nobody left to run it: abandon for the whole party
  if(NET.role==='join'&&st==='spec'&&s===0){ NET.status='Your host is out. The raid runs on until you are out.'; try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree('Your host is out. The raid runs on until you are out.'); }catch(_sw){} }   // v16.14, his ruling"""),
("""  try{ voiceMicOff(); }catch(_vm){}   // v16.09: the mic is let go with the party""",
"""  try{ voiceMicOff(); }catch(_vm){}   // v16.09: the mic is let go with the party
  NET.specG=null; NET.specHow=''; NET.specTick=false;   // v16.14: a host who ends the party stops running the raid (the party is told bye: abandon, his ruling)"""),
("""function netGuestHeld(){""",
"""function netGuestHeld(){
  if(typeof NET==='object'&&NET&&NET.specG){ netSay('Your party is still up top. The lift waits until they are out.'); return true; }   // v16.14: a spectating host does not go up again"""),
("""function netEntsHost(){ return !!(NET.on&&NET.role==='host'&&typeof G!=='undefined'&&G&&!G.sim&&!G.over&&NET.upSeed&&(G.seed>>>0)===(NET.upSeed>>>0)); }""",
"""function netEntsHost(){ return !!(NET.on&&NET.role==='host'&&typeof G!=='undefined'&&G&&!G.sim&&(!G.over||G===NET.specG)&&NET.upSeed&&(G.seed>>>0)===(NET.upSeed>>>0)); }   // v16.14: or the raid a spectating host runs on
// v16.14, HIS RULING OF 2026-09-26: THE HOST SPECTATES. The host window runs the pillagers, the machines and the boxes for the
// party, so when the host extracted, died or abandoned, every friend up top was ended as ABANDON (v15.91) and lost what he
// carried. Now, if a friend is up top on the party seed when the host run ends, the host run ends for the host as always (his
// card, his save) and the raid world is kept (NET.specG) and run every frame (netSpecTick) whatever the host window shows: the
// clock, the bodies, the bullets and throwables, and the words out to the party (bodies, boxes, the world word without the
// rings, which each friend runs himself). The host is nobody's target. Every word that comes in is handled against that world
// (netOnMsg), so shots, searches and beacons go on working, and it makes no sound in the host window. The party is told spec, not
// out, so nobody is ended; a friend hears Your host is out. The raid runs on until you are out. It stops when no friend is up
// top any more (out, dead, abandoned or gone) for a second and a half, and then the party is told out as before. The host
// cannot go up again meanwhile. The host ending the party or losing the link still ends every friend as ABANDON, his ruling of
// 2026-09-25. Solo play never reaches any of it.
function netSpecStart(how){
  var i, n=0;
  if(NET.role!=='host'||typeof G==='undefined'||!G||G.sim||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)||!netInCount()) return false;
  for(i=0;i<NET.up.length;i++) if(netUpShown(NET.up[i])) n++;
  if(!n) return false;
  NET.specG=G; NET.specHow=String(how||'extract'); NET.specAcc=0; NET.specIdle=0;
  if(G.player) G.player.specOut=1;
  netBroadcast({t:'up',st:'spec',how:netClean(how,12)});
  NET.status='Your party is still up top. The raid runs on until they are out.';
  return true;
}
function netSpecTick(dt){
  var keep=G, S=NET.specG, i, n=0;
  if(!S||NET.role!=='host'){ NET.specG=null; return 0; }
  for(i=0;i<NET.up.length;i++) if(netUpShown(NET.up[i])) n++;
  if(!n||!netInCount()){ NET.specIdle=(NET.specIdle||0)+dt; if(NET.specIdle>1.5||!netInCount()) return netSpecEnd(); }
  else NET.specIdle=0;
  if(!isFinite(dt)||dt<0) dt=0;
  G=S; NET.specTick=true;
  try{
    G.t+=dt; if(raidClockOn()) G.timeLeft=Math.max(0,G.timeLeft-dt);
    refreshVseg(); updateEnts(dt); updateBullets(dt); updateThrowables(dt);
    NET.specAcc=(NET.specAcc||0)+dt;
    if(NET.specAcc>=NET_HUB_STEP){ NET.specAcc=0; NET.upN++; netEntsTick(); netContTick(); if(NET.upN%5===0) netWorldSend(); }
  }catch(e){}
  finally{ NET.specTick=false; G=keep; }
  return n;
}
function netSpecEnd(){
  var keep=G, S=NET.specG, how=NET.specHow||'extract';
  NET.specG=null; NET.specHow=''; NET.specTick=false;
  G=S; try{ netUpEnd(how); }catch(e){} finally{ G=keep; }
  NET.status='Your party is back down. The raid is over.';
  netRefresh();
  return 0;
}"""),
("""  for(i=0;i<(G.zones||[]).length;i++){ Z=G.zones[i]; z.push([(Z.open===undefined)?null:Z.open,netNum(Z.beaconT),netNum(Z.hold),netNum(Z.holdMax),netNum(Z.closeAt)]); }""",
"""  if(!G.over) for(i=0;i<(G.zones||[]).length;i++){ Z=G.zones[i]; z.push([(Z.open===undefined)?null:Z.open,netNum(Z.beaconT),netNum(Z.hold),netNum(Z.holdMax),netNum(Z.closeAt)]); }   // v16.14: a spectating host sends no rings: each friend runs his own"""),
("""If the host leaves, the run ends as abandoned for everyone.""",
"""If the host leaves the party, the run ends as abandoned for everyone; if the host extracts or dies, the raid runs on until the rest of you are out."""),
], "THE HOST SPECTATES. His ruling. When the host extracts, dies or abandons with a friend still up top, the host run ends for the host as always, and the raid keeps running in the host window for the party until the last friend is out: the enemies, the boxes, shots and beacons all work, the host is nobody target, and it makes no sound there. The host cannot go up again until then. The host ending the party or losing the link still ends everyone as abandon. The what is new card says so. No number moved. Check 16.14 fails on v16.13",
"# THE HOST SPECTATES. His ruling of 2026-09-26 (replacing the v15.91 end-as-abandon when the host extracts or dies).\n")
fixture(1614, r"""  {v:'16.14',what:'the host spectates: with a friend up top the host extracting keeps the raid, tells the party spec and not out, runs the world on with the host back in the Undercroft, targets the friend and not the host, calls a beacon a friend asks for, holds the host at the lift, and when the friend is gone ends and tells the party out; a friend told spec runs on; control, with nobody up top the host ending tells out at once',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__hubEnter&&window.__loop)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof endRaid!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepSt=state, sent=[], peer, S=null, t0, e=null, i, TS=9000, oc=document.getElementById('outcome');
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function js(o){ return JSON.stringify(o); }
     function frames(n){ for(var k=0;k<n;k++){ TS+=16; __loop(TS); } }
     function upw(st){ return sent.filter(function(m){ return m.t==='up'&&m.st===st; }).length; }
     function stage(withMate){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false; G.tel.shots=1;
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[]; NET.specG=null;
       NET.roster=[{seat:0,pid:'zqxhost',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       if(withMate) NET.up[1]={seat:1,x:G.player.x+400,y:G.player.y,f:0,tx:G.player.x+400,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,mv:0,roll:0,bob:0,cr:0,sp:0,w:''};
       sent.length=0;
     }
     try{
       // CONTROL: nobody up top, the host ending tells out at once
       stage(false); endRaid('extract');
       if(NET.specG) bad.push('control: with nobody up top the host kept the raid running');
       if(!upw('out')) bad.push('control: with nobody up top the host ending did not tell the party out');
       if(oc) oc.classList.remove('on'); G=null; NET.up=[];
       // THE HOST SPECTATES
       stage(true); S=G;
       for(i=0;i<G.ents.length&&!e;i++) if(G.ents[i].kind!=='raider'&&G.ents[i].hp>0) e=G.ents[i];
       endRaid('extract');
       if(NET.specG!==S) bad.push('with a friend up top the host extracting did not keep the raid running');
       if(upw('out')) bad.push('with a friend up top the host extracting told the party out, which ends the friend as abandon');
       if(!upw('spec')) bad.push('the party was not told the host is out and spectating');
       if(NET.specG!==S) return bad.join('; ');   // nothing below can run: the raid was not kept
       if(oc) oc.classList.remove('on'); G=null; keys={}; __hubEnter(); if(NET.up[1]) NET.up[1].age=0;
       t0=S.t; frames(10); if(NET.up[1]) NET.up[1].age=0;
       if(!(S.t>t0)) bad.push('with the host back in the Undercroft the raid stood still ('+t0+' to '+S.t+')');
       if(e){ var tg=null, kg=G; G=S; try{ tg=netTargetFor(e); }finally{ G=kg; } if(!tg||tg===S.player) bad.push('a machine still goes for the host who is out'); }
       var bc=netOnMsg(peer,js({t:'bcn',i:0,g:0.2}));
       if(!(S.zones[0].beaconT>0)) bad.push('a beacon the friend called while the host spectates was not called ('+bc+')');
       if(ascendNow()!==false||G) bad.push('the spectating host went up again');
       // THE FRIEND IS OUT
       NET.up[1]=null; sent.length=0;
       frames(120);
       if(NET.specG) bad.push('with the friend out the host still runs the raid after 2 s');
       else if(!upw('out')) bad.push('when spectating ended the party was not told out');
       // A FRIEND TOLD SPEC RUNS ON
       NET.specG=null; stage(false); NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer];
       var sw=netOnMsg(peer,js({t:'up',st:'spec',how:'extract'}));
       if(!G||G.over) bad.push('a friend told the host spectates was ended ('+sw+')');
     }
     finally{
       try{ NET.specG=null; NET.specTick=false; keys={}; if(oc) oc.classList.remove('on'); }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
