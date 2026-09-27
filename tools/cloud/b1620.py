from gen import patch, fixture
patch(1620, [
("""  if(!G||G.over||(G.paused&&!netUpShared())) return;   // v16.11, backcheck: a pause in a shared raid is an overlay (v16.04), so the storm runs on""",
"""  if(!G||G.over||(G.paused&&!netPauseLive())) return;   // v16.11: a pause in a shared raid is an overlay (v16.04), so the storm runs on; v16.20: unless the whole party is paused"""),
("""  if((!G.paused||netUpShared())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){""",
"""  if((!G.paused||netPauseLive())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){"""),
("""  else if((!G.paused||netUpShared())&&!G.over){   // v16.04: in a shared co-op raid pause is an overlay: the world and the clock run on""",
"""  else if((!G.paused||netPauseLive())&&!G.over){   // v16.04: in a shared co-op raid pause is an overlay: the world and the clock run on; v16.20: everyone paused stops it"""),
("""      if(G.paused&&netUpShared()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on""",
"""      if(G.paused&&netPauseLive()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on"""),
("""       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):''};""",
"""       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):'',pz:G.paused?1:0};   // v16.20: pz, this player is paused"""),
("""  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in""",
"""  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused"""),
("""    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; }   // v15.79: passed on as it came""",
"""    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; }   // v15.79: passed on as it came"""),
("""function netPausedStep(dt){""",
"""// v16.20, HIS ORDER: WHEN THE WHOLE PARTY PAUSES, THE GAME PAUSES. A pause in a shared raid is an overlay (v16.04) so one player
// cannot stop the world on the others; when this player is paused and every teammate up top on the party seed says he is paused
// too (pz in his state word), nobody is playing, so the world, the clock and the storm stop as in solo. Any one unpausing starts it.
function netAllPaused(){
  var i, g, n=0;
  if(typeof G==='undefined'||!G||!G.paused) return false;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; if(!g.pz) return false; n++; }
  return n>0;
}
function netPauseLive(){ return netUpShared()&&!netAllPaused(); }
function netPausedStep(dt){"""),
], "WHEN THE WHOLE PARTY PAUSES, THE GAME PAUSES. His order. In co-op one player pausing still leaves the world running for the others, but when every player in the raid is paused the world, the clock and the storm stop, as in solo. Any one unpausing starts it again. No number moved. Check 16.20 fails on v16.19",
"# WHEN THE WHOLE PARTY PAUSES, THE GAME PAUSES. His order of 2026-09-27.\n")
fixture(1620, r"""  {v:'16.20',what:'when the whole party pauses the game pauses: the state word carries the pause; with this player paused and the teammate paused the world stands still; with the teammate playing it runs on',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepSt=state, TS=7000, peer, t0, p;
     function frames(n){ for(var i=0;i<n;i++){ TS+=16; __loop(TS); if(NET.up[1]) NET.up[1].age=0; } }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false; CFG.superhot=0; p=G.player;
       NET.on=true; NET.role='host'; NET.seat=0; peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       netOnMsg(peer,JSON.stringify({t:'st',k:'r',sd:NET.upSeed>>>0,x:p.x+300,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',pz:1}));
       if(!NET.up[1]) return 'SKIP: the staged state word was not filed';
       if(NET.up[1].pz!==1) bad.push('the state word does not carry that the teammate is paused');
       NET.up[1].n=5; NET.up[1].age=0;
       G.paused=true; t0=G.t; frames(10);
       if(G.t!==t0) bad.push('with the whole party paused the world still ran ('+t0+' to '+G.t+')');
       NET.up[1].pz=0; t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('control: with the teammate playing, the pause stopped the world for him');
     }
     finally{
       try{ keys={}; if(G) G.paused=false; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
