from gen import patch, fixture
patch(1605, [
("""  var downRdr=null;""",
"""  netRevHold(p,dt);   // v16.05: holding E beside a downed teammate picks him up (the net section)
  var downRdr=null;"""),
("""  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host""",
"""  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='rev') return netRevTake(peer,m);   // v16.05: a teammate picked this player up, or (on the host) passes it on"""),
("""function netKillTake(peer,m){""",
"""// v16.05, HIS RULING OF 2026-09-25: TEAMMATE REVIVES IN THE FIRST CO-OP VERSION. Up top, a player on his feet who holds E within
// NET_REV_R of a teammate who is down (the dn flag of his state word, on this raid seed) fills a pick-up for NET_REV_T seconds,
// the time a hire takes to pick you up; letting go or stepping away starts it again. When it fills, the word {t:'rev',s:seat}
// goes to the host, which applies it to itself or passes it to that seat with by:the reviver. The downed window checks it is
// down, not already finished, and that the reviver stands within reach as it last heard, then gets up exactly as a hire picks
// him up: health 40 percent, two seconds of cover, no killer pending, a revive on his tally. His one self-revive is untouched.
// No new number: 64 is the reach of the pillager pick-up and 3.2 the hire pick-up time. Nothing here draws from the seeded stream.
var NET_REV_R=64, NET_REV_T=3.2;
function netMateDown(p){
  var i, g, best=-1, bd=NET_REV_R, d;
  if(!NET.on||!netUpShared()||!p||p.downed||!NET.upSeed) return -1;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i];
    if(!g||!g.dn||g.seat===NET.seat||netSeatName(g.seat)===null||g.sd!==(NET.upSeed>>>0)) continue;
    d=Math.hypot(g.x-p.x,g.y-p.y); if(d<=bd){ bd=d; best=g.seat; }
  }
  return best;
}
function netRevHold(p,dt){
  var s=-1, nm;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  if(s<0||!keys['KeyE']||p.roll>0){ if(G.netRevT){ G.netRevT=0; G.netRevS=-1; } return false; }
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; }
  nm=netSeatName(s)||'PILLAGER';
  if(!G.netRevT) say('Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.');
  G.netRevT=(G.netRevT||0)+dt;
  if(G.netRevT<NET_REV_T) return false;
  G.netRevT=0; G.netRevS=-1;
  if(NET.role==='host') netRevPass(s,NET.seat);
  else for(var i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'rev',s:s});
  say('You pull '+nm+' up.'); blip('pick');
  return true;
}
// On the host: a pick-up for its own player, or passed on to the seat it names.
function netRevPass(s,by){
  var i;
  if(s===NET.seat) return netRevApply(by);
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===s) return netSend(NET.peers[i],{t:'rev',s:s,by:by})?'passed':'lost';
  return 'nobody';
}
function netRevTake(peer,m){
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
  if(NET.role==='host') return netRevPass(m.s,peer.seat);
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netRevApply((typeof m.by==='number')?(m.by|0):0); }
  return 'off';
}
// This player is picked up by seat by, if he is down and that teammate stands within reach of him as this window last heard.
function netRevApply(by){
  var p, g;
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player) return 'no raid';
  p=G.player;
  if(!p.downed||(G.deathBeat!==undefined&&G.deathBeat!==null)) return 'not down';
  g=NET.up[by];
  if(!g||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5) return 'far';
  p.downed=false; p.hp=Math.round(p.maxhp*0.4); p.iv=2; p.pendKiller=null;
  if(G.tel) G.tel.revives=(G.tel.revives||0)+1;
  blip('pick'); say((netSeatName(by)||'Your teammate')+' pulls you up.');
  label(p.x,p.y-22,'PICKED UP','#4de3d0',0,true);
  return 'up';
}
function netKillTake(peer,m){"""),
], "TEAMMATE REVIVES. Multiplayer, his ruling. Up top, hold E beside a downed teammate for 3.2 seconds, the time a hire takes, and he gets up with 40 percent health exactly as a hire picks you up. Letting go starts it again. The word goes through the host, and the downed window checks he is down and the teammate is beside him. His one self-revive is untouched. No new number. Check 16.05 fails on v16.04",
"# TEAMMATE REVIVES. Multiplayer, his ruling of 2026-09-25 (teammate revives in the first co-op version).\n")
fixture(1605, r"""  {v:'16.05',what:'teammate revives: as the host with a linked teammate down beside him, E held for the hire pick-up time sends the pick-up to that seat, and letting go early sends nothing (control: a teammate on his feet is never picked up); as the linked window, down, a pick-up from the host with the teammate beside him puts him on his feet at 40 percent, and one from a teammate far off does not',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof updatePlayer!=='function'||typeof netOnMsg!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], p, i, rv, peer;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function hold(sec){ keys['KeyE']=true; for(var t=0;t<sec;t+=0.05) updatePlayer(0.05); keys['KeyE']=false; }
     function mate(seat,x,y,dn){ NET.up[seat]={seat:seat,x:x,y:y,f:0,tx:x,ty:y,tf:0,n:5,age:0,dn:dn?1:0,sd:NET.upSeed>>>0}; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={};
       p=G.player; G.sim=0; G.over=false;
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       // CONTROL: on his feet, nothing is sent however long E is held
       mate(1,p.x+30,p.y,false); sent.length=0; hold(4);
       if(sent.some(function(m){ return m.t==='rev'; })) bad.push('control: a teammate on his feet was picked up');
       mate(1,p.x+30,p.y,true); sent.length=0; hold(1.5);
       if(sent.some(function(m){ return m.t==='rev'; })) bad.push('E held 1.5 s picked the teammate up before the 3.2 s a hire takes');
       sent.length=0; hold(3.5);
       rv=sent.filter(function(m){ return m.t==='rev'; });
       if(rv.length!==1||rv[0].s!==1) bad.push('E held 3.5 s beside a downed teammate sent '+JSON.stringify(rv)+', not one pick-up for seat 1');
       // THE DOWNED WINDOW
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; NET.up=[];
       NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ME'}];
       p.downed=true; p.hp=0; G.deathBeat=null;
       mate(0,p.x+500,p.y,false);
       netOnMsg(peer,JSON.stringify({t:'rev',s:1,by:0}));
       if(!p.downed) bad.push('a pick-up from a teammate 500 away put him on his feet');
       mate(0,p.x+30,p.y,false);
       var r2=netOnMsg(peer,JSON.stringify({t:'rev',s:1,by:0}));
       if(p.downed) bad.push('a pick-up from the teammate beside him left him down ('+r2+')');
       else if(p.hp!==Math.round(p.maxhp*0.4)) bad.push('picked up with '+p.hp+' health, not the 40 percent a hire gives');
     }
     finally{
       try{ keys={}; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
