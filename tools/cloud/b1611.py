from gen import patch, fixture
OLD_REV = """function netRevHold(p,dt){
  var s=-1, nm;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  if(s<0||!keys['KeyE']||p.roll>0){ if(G.netRevT){ G.netRevT=0; G.netRevS=-1; } return false; }
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; }
  nm=netSeatName(s)||'PILLAGER';
  if(!G.netRevT) say('Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.');
  G.netRevT=(G.netRevT||0)+dt;
  if(G.netRevT<NET_REV_T) return false;
  G.netRevT=0; G.netRevS=-1;"""
NEW_REV = """// v16.11, backcheck: THE PICK-UP TAKES E. It returns true while E is working a pick-up, and the caller takes E off the other
// E acts for that step (the loop gives it back after), so holding E over a teammate beside an open ring no longer calls the
// extraction or searches a box as well. After a pick-up is sent, E held on stays on that teammate (G.netRevDone) until it is
// let go, so the line is not written over by a fresh Picking up and a second pick-up is never sent.
function netRevHold(p,dt){
  var s=-1, nm;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  if(!keys['KeyE']) G.netRevDone=-1;
  if(typeof G.netRevDone==='number'&&G.netRevDone>=0&&keys['KeyE']&&s===G.netRevDone) return true;
  if(s<0||!keys['KeyE']||p.roll>0){ if(G.netRevT){ G.netRevT=0; G.netRevS=-1; } return false; }
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; }
  nm=netSeatName(s)||'PILLAGER';
  if(!G.netRevT) say('Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.');
  G.netRevT=(G.netRevT||0)+dt;
  if(G.netRevT<NET_REV_T) return true;
  G.netRevT=0; G.netRevS=-1; G.netRevDone=s;"""
patch(1611, [
("""function strikeTick(dt){
  if(!G||G.over||G.paused) return;""",
"""function strikeTick(dt){
  if(!G||G.over||(G.paused&&!netUpShared())) return;   // v16.11, backcheck: a pause in a shared raid is an overlay (v16.04), so the storm runs on"""),
("""document.getElementById('confirmabandon').onclick=function(){""",
"""document.getElementById('confirmabandon').onclick=function(){
  // v16.11, backcheck: THE CONFIRM REFUSES A DOWNED OR DYING PLAYER TOO. In solo the world stands still while the pause box is
  // open, so nothing can put him down between ABANDON and YES; in a shared co-op raid the world runs on under the box (v16.04),
  // so ABANDON armed on his feet and YES pressed after he went down turned the death into an abandon, the swap v9.37 closed.
  if(G&&!G.over&&(G.nuking||(G.player&&(G.player.downed||G.player.hp<=0||(G.deathBeat||0)>0)))){ this.style.display='none'; var _blq2=document.getElementById('pausebleed'); if(_blq2&&!G.nuking&&G.player&&G.player.downed) _blq2.style.display=''; return; }"""),
(OLD_REV, NEW_REV),
("""  netRevHold(p,dt);   // v16.05: holding E beside a downed teammate picks him up (the net section)""",
"""  if(netRevHold(p,dt)&&keys['KeyE']){ keys['KeyE']=false; G.netRevEat=1; }   // v16.05: holding E beside a downed teammate picks him up; v16.11: and takes E for this step"""),
("""      else updatePlayer(dt);""",
"""      else updatePlayer(dt);
      if(G&&G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; }   // v16.11: E given back after the step a pick-up took it (netRevHold)"""),
("""    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=a[4];
  }
  if(typeof m.ai==='number'&&m.ai>=0&&G.zones&&G.zones[m.ai]){ G.active=G.zones[m.ai]; G.beaconT=G.active.beaconT; }""",
"""    // v16.11, backcheck: a pull this player began is left to finish as the v11.98 order says, not cut by the host word; and a
    // ring that never closes keeps closeAt undefined (null read as a closing time of 0 warned and showed a countdown).
    if(Z.pullT!==null&&Z.pullT!==undefined&&G.player&&dist(G.player,Z)<Z.r) continue;
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=(a[4]===null)?undefined:a[4];
  }
  // v16.11, backcheck: the pointer to the ring this window called moves only when it has no call of its own running (v12.57).
  if(typeof m.ai==='number'&&m.ai>=0&&G.zones&&G.zones[m.ai]&&!(G.active&&G.active.beaconT!==null&&G.active.beaconT!==undefined)){ G.active=G.zones[m.ai]; G.beaconT=G.active.beaconT; }"""),
("""  G.active=Z; G.beaconT=Z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
  if(G.tel) G.tel.beaconCalls=(G.tel.beaconCalls||0)+1;""",
"""  if(!(G.active&&G.active!==Z&&G.active.beaconT!==null&&G.active.beaconT!==undefined)){ G.active=Z; G.beaconT=Z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0; }   // v16.11: never taken off a call of the host's own (v12.57)
  if(G.tel) G.tel.beaconCalls=(G.tel.beaconCalls||0)+1;"""),
("""      NET.roster=netRosterClean(m.roster);
      hn='';""",
"""      NET.roster=netRosterClean(m.roster);
      for(i=0;i<NET.roster.length;i++) if(NET.roster[i].host&&NET.roster[i].pid) peer.pid=NET.roster[i].pid;   // v16.11, backcheck: the link to the host knows his id, so MUTE beside the host works
      hn='';"""),
], "CO-OP FIXES FROM THE BACKCHECK. Paused in a shared raid the storm now runs on with the world. YES, ABANDON refuses a player who went down after arming it, as ABANDON already did. Holding E over a downed teammate takes E, so it no longer calls the extraction or searches a box too, and holding on after the pick-up sends nothing twice. The host world word no longer cuts a pull you began, no longer makes a ring that never closes look like it closes, and no longer moves your called ring. MUTE beside the host works. No number moved. Check 16.11 fails on v16.10",
"# CO-OP FIXES FROM THE BACKCHECK of 2026-09-26 (findings on v16.04, v16.05, v16.06 and v16.09).\n")
fixture(1611, r"""  {v:'16.11',what:'co-op fixes from the backcheck: a shared-raid pause lets the storm land its bolt; YES, ABANDON refuses a player who went down after arming it; holding E over a downed teammate inside an open ring calls no extraction, and E held on after the pick-up sends nothing more; the host world word leaves a never-closing ring open-ended, leaves a pull this player began alone and does not move his called ring; the link to the host learns the host id',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof updatePlayer!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], p, peer, i, Z, W1=null, ca=document.getElementById('confirmabandon');
     for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id==='storm') W1=WEATHER[i];
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function js(o){ return JSON.stringify(o); }
     function party(role){ NET.on=true; NET.role=role; NET.seat=(role==='host')?0:1; peer=mk(role==='host'?1:0); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[]; NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}]; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; p=G.player; G.sim=0; G.over=false; G.t=200;
       if(!W1||!G.zones||!G.zones.length||!ca) return 'SKIP: no storm, rings or confirm button';
       // THE STORM UNDER A SHARED PAUSE
       party('host'); G.wx=W1; G.paused=true; G.strikes=[{x:p.x+900,y:p.y,t:0.05,hit:0,id:5}];
       strikeTick(0.1);
       if(G.strikes.length) bad.push('paused in a shared raid the storm held its bolt, so the party saw it land late or not at all');
       G.paused=false; G.strikes=[];
       // THE PICK-UP TAKES E
       Z=G.zones[0]; Z.open=true; Z.beaconT=null; Z.hold=null; Z.callT=0; p.x=Z.x; p.y=Z.y;
       NET.up[1]={seat:1,x:p.x+30,y:p.y,f:0,n:5,age:0,dn:1,sd:NET.upSeed>>>0};
       sent.length=0;
       for(i=0;i<40;i++){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
       if(Z.beaconT!==null&&Z.beaconT!==undefined) bad.push('holding E to pick up a teammate inside an open ring called the extraction too');
       var rv=sent.filter(function(m){ return m.t==='rev'; }).length;
       if(rv!==0) bad.push('a pick-up was sent after 2 s of holding, before the hire time');
       for(i=0;i<60;i++){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
       rv=sent.filter(function(m){ return m.t==='rev'; }).length;
       if(rv!==1) bad.push('holding E 5 s over a downed teammate sent '+rv+' pick-ups, not one');
       keys={}; Z.beaconT=null; NET.up=[];
       // THE HOST WORD ON A LINKED WINDOW
       party('join');
       var zw=[]; for(i=0;i<G.zones.length;i++) zw.push([true,null,null,null,null]);
       G.zones[0].closeAt=undefined;
       netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:W1.id,wn:'',wt:0,ai:-1,z:zw,s:[]}));
       if(G.zones[0].closeAt!==undefined) bad.push('a ring that never closes came through the host word with closeAt '+G.zones[0].closeAt);
       if(G.zones.length>1){
         Z=G.zones[1]; p.x=Z.x; p.y=Z.y; Z.open=true; Z.pullT=0.5; zw[1]=[false,null,null,null,100];
         netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:W1.id,wn:'',wt:0,ai:-1,z:zw,s:[]}));
         if(Z.open===false) bad.push('the host word shut a ring while this player was pulling in it');
         Z.pullT=null;
         G.zones[0].beaconT=12; G.active=G.zones[0]; zw[1]=[true,30,null,null,null];
         netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:G.timeLeft,wx:W1.id,wn:'',wt:0,ai:1,z:zw.map(function(a,k){ return k===0?[true,12,null,null,null]:a; }),s:[]}));
         if(G.active!==G.zones[0]) bad.push('the host word moved the ring this player called');
       }
       // THE HOST ID
       NET.role='join'; NET.seat=-1; peer=mk(0); peer.state='open'; NET.peers=[peer];
       netOnMsg(peer,js({t:'welcome',you:1,roster:[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ME'}],ver:VER}));
       if(peer.pid!=='zqxhost') bad.push('the link to the host does not know the host id ('+peer.pid+'), so MUTE beside the host does nothing');
       // THE CONFIRM WHILE DOWN (last: on the old build it ends the raid)
       NET.on=false; NET.role=null; NET.peers=[];
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; p=G.player; G.sim=0; G.over=false; G.t=200;
       p.downed=true; ca.style.display=''; ca.onclick.call(ca);
       if(!G||G.over) bad.push('YES, ABANDON pressed while down ended the run'+(G?' as '+G.over:'')+', turning a death into an abandon');
     }
     finally{
       try{ keys={}; if(G){ G.paused=false; G.netRevEat=0; } if(ca) ca.style.display='none'; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
import gen, os
_p = os.path.join(gen.H, 'f1611.ps1'); _t = open(_p, encoding='ascii').read()
_extra = gen.sub("""     function hold(sec){ keys['KeyE']=true; for(var t=0;t<sec;t+=0.05) updatePlayer(0.05); keys['KeyE']=false; }""",
"""     // v16.11: held the way the loop holds it: a pick-up takes E for its step (netRevHold) and the loop hands it back after; one
     // step with E up at the end lets go, so the next hold starts a fresh pick-up
     function hold(sec){ for(var t=0;t<sec;t+=0.05){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat) G.netRevEat=0; } keys['KeyE']=false; updatePlayer(0.05); }""")
_t = _t.replace("\n$src = [IO.File]", "\n" + _extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
