from gen import patch, fixture
patch(1604, [
("""  if(CFG.superhot&&G.player&&!G.over&&!G.paused){""",
"""  if(CFG.superhot&&G.player&&!G.over&&!G.paused&&!netUpShared()){   // v16.04: Superhot is off in a shared co-op raid (one world cannot stop for one player)"""),
("""  if(!G.paused&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){""",
"""  if((!G.paused||netUpShared())&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){"""),
("""    var bdt=dt*0.25;""",
"""    var bdt=netUpShared()?dt:dt*0.25;   // v16.04: in a shared co-op raid the slow-down is not put on the world the party is still playing in"""),
("""  else if(!G.paused&&!G.over){""",
"""  else if((!G.paused||netUpShared())&&!G.over){   // v16.04: in a shared co-op raid pause is an overlay: the world and the clock run on"""),
("""      updatePlayer(dt);""",
"""      if(G.paused&&netUpShared()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on
      else updatePlayer(dt);"""),
("""function netEntsHost(){""",
"""// v16.04, MULTIPLAYER: PAUSE, SUPERHOT AND THE DEATH SLOW-DOWN IN CO-OP (tools/multiplayer/plan.md phase 2: Superhot is off, pause
// becomes an overlay, and the death slow-down is local to the dying player). One world is shared by the party, so no one window
// can stop or slow it: in a shared raid (this window on the party seed with someone linked) Superhot never freezes time, the
// pause menu and the tuning console open over a world that keeps running (the raid clock included), and the death beat plays at
// full speed. Paused, his player takes no input: keys, the mouse button and the pad stick are held off for his own step only,
// so bleeding, regen and every timer on him still run. Solo play is untouched: netUpShared is false without a party.
function netUpShared(){ return !!((netEntsHost()||netEntsPeer())&&netInCount()>0); }
function netPausedStep(dt){
  var k=keys, md=(typeof mouse!=='undefined'&&mouse)?mouse.down:false, pm=(typeof PAD!=='undefined'&&PAD)?[PAD.mx,PAD.my]:null;
  keys={}; if(md) mouse.down=false; if(pm){ PAD.mx=0; PAD.my=0; }
  try{ updatePlayer(dt); }
  finally{ keys=k; if(md) mouse.down=md; if(pm){ PAD.mx=pm[0]; PAD.my=pm[1]; } }
}
function netEntsHost(){"""),
], "PAUSE, SUPERHOT AND THE DEATH SLOW-DOWN IN CO-OP. Multiplayer, the plan phase 2 rules. In a shared co-op raid Superhot never freezes time, the pause menu opens over a world that keeps running with the raid clock, your player stands still while paused, and the death slow-down does not slow the world the party plays in. Solo play untouched. No number moved. Check 16.04 fails on v16.03",
"# PAUSE, SUPERHOT AND THE DEATH SLOW-DOWN IN CO-OP. Multiplayer, tools/multiplayer/plan.md phase 2 rules.\n")
fixture(1604, r"""  {v:'16.04',what:'pause, Superhot and the death slow-down in co-op: in a shared party raid with Superhot on and no input the world still runs, paused the world and the clock run on while he stands still with W held, and the death beat runs the world at full speed; control, the same window alone keeps the solo rules (Superhot freezes, pause stops the world)',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET||typeof netInCount!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat}, keepSt=state, TS=1000, peer={state:'in',seat:1,name:'ZQX',timers:[],dc:{readyState:'open',send:function(){}}}, t0, x0, cl0;
     function frames(n){ for(var i=0;i<n;i++){ TS+=16; __loop(TS); } }
     function stage(party){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       state='raid'; G.sim=0; G.over=false; G.deathBeat=null; G.paused=false; pauseOpen=false; keys={};
       CFG.superhot=1;
       NET.on=party; NET.role=party?'host':null; NET.seat=0; NET.peers=party?[peer]:[]; NET.upSeed=party?(G.seed>>>0):0;
       frames(2);
     }
     try{
       // SOLO CONTROL
       stage(false);
       t0=G.t; frames(10); if(G.t!==t0) bad.push('control: alone with Superhot on and no input the world moved ('+t0+' to '+G.t+')');
       CFG.superhot=0; G.paused=true; t0=G.t; frames(10); if(G.t!==t0) bad.push('control: alone and paused the world moved');
       G.paused=false; G.over='abandon';
       // THE PARTY
       stage(true);
       if(!(netEntsHost&&netEntsHost())) return 'SKIP: the staged party raid does not read as the host world';
       t0=G.t; frames(10); if(!(G.t>t0)) bad.push('in a party raid with Superhot on and no input the world stood still, so one player froze it for everyone');
       CFG.superhot=0; G.paused=true; t0=G.t; cl0=G.timeLeft; x0=[G.player.x,G.player.y]; keys['KeyW']=true;
       frames(15);
       if(!(G.t>t0)) bad.push('paused in a party raid the world stood still');
       if(Math.hypot(G.player.x-x0[0],G.player.y-x0[1])>0.5) bad.push('paused in a party raid with W held he walked '+Math.hypot(G.player.x-x0[0],G.player.y-x0[1]).toFixed(1));
       keys={}; G.paused=false;
       G.deathBeat=5; t0=G.t; frames(10);
       if(!(G.t-t0>0.1)) bad.push('in a party raid the death beat slowed the shared world to '+(G.t-t0).toFixed(3)+' s over 10 frames');
       G.deathBeat=null;
     }
     finally{
       try{ keys={}; pauseOpen=false; if(G){ G.paused=false; G.deathBeat=null; } }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
