from gen import patch, fixture
l1=open('/tmp/l1').read().rstrip('\n'); l2=open('/tmp/l2').read().rstrip('\n'); l3=open('/tmp/l3').read().rstrip('\n')
patch(1627, [
("""  if(CFG.superhot&&G.player&&!G.over&&!G.paused&&!netUpShared()){   // v16.04: Superhot is off in a shared co-op raid (one world cannot stop for one player)""",
"""  if(CFG.superhot&&G.player&&!G.over&&!G.paused){   // v16.27, his note: in co-op time runs while ANY player up top is acting (v16.04 had it off)"""),
("""    if(!_shAct) dt=0;""",
"""    G.shAct=_shAct;
    if(!_shAct&&!netAnyActing()) dt=0;"""),
(l1, l1.replace("dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0};","dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0,sa:(!CFG.superhot||G.shAct)?1:0};")),
(l2, l2.replace("g.dt=+m.dt||0; }","g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }")),
(l3, l3.replace("out.dt=g.dt; }","out.dt=g.dt; out.sa=g.sa; }")),
("""  if(typeof G==='undefined'||!G||!G.paused) return false;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; if(!g.pz) return false; n++; }
  return n>0;
}""",
"""  if(typeof G==='undefined'||!G||!G.paused) return false;
  // v16.27, his note: any time every player is paused the game pauses. A teammate who is not up top (in the Undercroft, on the
  // run card, out) is not playing, so with nobody up top and unpaused the pause stops the world as in solo.
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; if(!g.pz) return false; n++; }
  return true;
}
// v16.27: Superhot in co-op. Is any teammate up top acting (moving, shooting, rolling, reloading) and not paused? Then time runs.
function netAnyActing(){
  var i, g;
  if(typeof NET!=='object'||!NET||!NET.on||!netUpShared()) return false;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(netUpShown(g)&&g.sa&&!g.pz) return true; }
  return false;
}"""),
("""    y=by-96-n*40; n++;""",
"""    y=Math.round(H*0.30)+n*44; n++;   // v16.27, his note: the rows sat on the belt help line; they now run down the left edge, clear of it"""),
], "PAUSE AND SUPERHOT IN CO-OP, AND THE TEAMMATE ROWS MOVED. His notes. Any time every player is paused the game pauses, including when your teammate is not in the raid (before, a teammate in the Undercroft kept your world running). In Superhot, time runs while any player in the raid is acting and stops when nobody is. The teammate rows moved to the left edge, clear of the belt help line. No number moved. Check 16.27 fails on v16.26",
"# PAUSE AND SUPERHOT IN CO-OP, AND THE TEAMMATE ROWS MOVED. His notes of 2026-09-27.\n")
fixture(1627, r"""  {v:'16.27',what:'pause and superhot in co-op: paused with the teammate not up top the world stops; paused with the teammate up top and playing it runs; with superhot on and nobody acting time stops, and a teammate acting keeps it running',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepSt=state, TS=11000, t0;
     function frames(n){ for(var i=0;i<n;i++){ TS+=16; __loop(TS); if(NET.up[1]) NET.up[1].age=0; } }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false; CFG.superhot=0;
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[{state:'in',seat:1,name:'ZQX',timers:[],dc:{readyState:'open',send:function(){}}}]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       G.paused=true; t0=G.t; frames(10);
       if(G.t!==t0) bad.push('paused with the teammate not up top, the world still ran');
       NET.up[1]={seat:1,x:G.player.x+300,y:G.player.y,f:0,tx:G.player.x+300,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,pz:0,sa:1};
       t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('control: paused with the teammate up top and playing, the world stopped for him');
       G.paused=false; CFG.superhot=1; NET.up[1].sa=0;
       t0=G.t; frames(10);
       if(G.t!==t0) bad.push('superhot with nobody acting: time still ran');
       NET.up[1].sa=1; t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('superhot with the teammate acting: time stood still');
     }
     finally{
       try{ keys={}; if(G) G.paused=false; CFG.superhot=0; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
import os, gen
_p = os.path.join(gen.H, 'f1627.ps1'); _t = open(_p, encoding='ascii').read()
MK = open(os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
UP = "NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}]; NET.up=[]; NET.up[1]={seat:1,x:G.player.x+300,y:G.player.y,f:0,tx:G.player.x+300,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,pz:0,sa:1};"
extra = ''
a = "       NET.on=party; NET.role=party?'host':null; NET.seat=0; NET.peers=party?[peer]:[]; NET.upSeed=party?(G.seed>>>0):0;"
ln = [x for x in MK if x == a]; assert len(ln) == 1
extra += gen.sub(a, a + "\n       if(party){ " + UP + " }   // v16.27: the world runs under a pause only while a teammate is up top and playing; this one is, acting")
b = "       party('host'); G.wx=W1; G.paused=true; G.strikes=[{x:p.x+900,y:p.y,t:0.05,hit:0,id:5}];"
ln = [x for x in MK if x == b]; assert len(ln) == 1, len(ln)
extra += gen.sub(b, b + "\n       " + UP.replace("G.player","p") + "   // v16.27: a teammate up top and playing")
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
