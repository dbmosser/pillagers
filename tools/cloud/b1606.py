from gen import patch, fixture
patch(1606, [
("""      wxTick(dt); strikeTick(dt);""",
"""      if(!netEntsPeer()) wxTick(dt); strikeTick(dt);   // v16.06: on a linked window the weather comes from the host (netWorldTake)"""),
("""  if(G.strikeAt<=0){""",
"""  if(G.strikeAt<=0&&!netEntsPeer()){   // v16.06: a linked window makes no bolts of its own; the host bolts come in its world word"""),
("""    var sx=clamp(p.x+Math.cos(ang)*rad,80,WORLD_W-80);
    var sy=clamp(p.y+Math.sin(ang)*rad,80,WORLD_H-80);""",
"""    var _sc=netStrikeAt(p);   // v16.06: the host takes each party member up top in turn as the centre; alone it is always him (no draw)
    var sx=clamp(_sc.x+Math.cos(ang)*rad,80,WORLD_W-80);
    var sy=clamp(_sc.y+Math.sin(ang)*rad,80,WORLD_H-80);"""),
("""    G.strikes.push({x:sx,y:sy,t:STRIKE_WARN,hit:0});""",
"""    G.strikes.push({x:sx,y:sy,t:STRIKE_WARN,hit:0,id:(G.strikeN=(G.strikeN||0)+1)});   // v16.06: numbered, so the party draws the same bolt once"""),
("""    G.strikes.splice(i,1);""",
"""    G.strikes.splice(i,1);
    if(S.rm){ G.lightning=0.34; if(!G.sim) sfx('alarm',S.x,S.y); continue; }   // v16.06: a host bolt on a linked window: the flash and the crack only; the host lands the hit (netAreaHitPeers)"""),
("""      G.beaconT=z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;""",
"""      G.beaconT=z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
      netBeaconCalled(z);   // v16.06: a linked window asks the host, which owns the rings, to call it for the party"""),
("""  if(NET.role==='host') netContTick();   // v15.91: on the same clock, every container that arrived, opened or shut since the last tick""",
"""  if(NET.role==='host') netContTick();   // v15.91: on the same clock, every container that arrived, opened or shut since the last tick
  if(NET.role==='host'&&NET.upN%5===0) netWorldSend();   // v16.06: twice a second, the raid clock, the weather, the bolts and the rings"""),
("""function netEntsHost(){""",
"""// v16.06, MULTIPLAYER: THE HOST OWNS THE RAID CLOCK, THE WEATHER, THE LIGHTNING AND THE EXTRACTION RINGS. Before this each window
// ran its own: the weather turned on its own seeded stream, so two players could stand in rain and in fog; the clocks drifted;
// a bolt the host made could land on a teammate who never saw its warning ring; and a beacon one player called existed on his
// window alone. Twice a second the host sends {t:'wd'}: the seed, time left, the sky, the sky it is turning to and how far, the
// live bolts by number, the active ring, and for every ring whether it is open, the beacon countdown, the hold and when it
// closes. A linked window on that seed takes the clock when it is more than 0.3 s off, the sky outright (it runs no wxTick of its
// own), the rings, and each new bolt as a warning ring that flashes and cracks but never hits: the host lands the hit through
// netAreaHitPeers by the roof and wall rules. A linked window makes no bolts of its own; the host centres each bolt on the next
// member of the party up top in turn, so the storm reaches everyone, with the same two draws. A beacon called on a linked window
// goes to the host ({t:'bcn'}) and is called there for the party; the linked window keeps its own call for 1.5 s so the next
// word cannot cancel it on the way. Each player still boards, extracts, dies or abandons alone. Solo play is untouched.
function netWxOf(id){ var i; if(typeof WEATHER==='undefined') return null; for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id) return WEATHER[i]; return null; }
function netNum(v){ return (typeof v==='number'&&isFinite(v))?+v.toFixed(2):null; }
function netStrikeAt(p){
  var L=[p], i, g;
  if(!netEntsHost()||!netInCount()) return p;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(g&&g.seat!==NET.seat&&!g.dn&&g.sd===(NET.upSeed>>>0)&&netSeatName(g.seat)!==null) L.push(g); }
  G.strikeWho=((G.strikeWho|0)+1)%L.length;
  return L[G.strikeWho]||p;
}
function netWorldSend(){
  var z=[], s=[], i, Z, S, m, n=0;
  if(!netEntsHost()) return 0;
  for(i=0;i<(G.zones||[]).length;i++){ Z=G.zones[i]; z.push([(Z.open===undefined)?null:Z.open,netNum(Z.beaconT),netNum(Z.hold),netNum(Z.holdMax),netNum(Z.closeAt)]); }
  for(i=0;i<(G.strikes||[]).length;i++){ S=G.strikes[i]; if(S.id&&!S.rm&&S.t>0) s.push([S.id,Math.round(S.x),Math.round(S.y),netNum(S.t)]); }
  m={t:'wd',sd:G.seed>>>0,tl:netNum(G.timeLeft),wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:netNum(G.wxT)||0,ai:(G.zones||[]).indexOf(G.active),z:z,s:s};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&netSendFast(NET.peers[i],m)) n++;
  return n;
}
function netWorldTake(peer,m){
  var i, a, Z, w, k, S, have;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netEntsPeer()||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
  if(typeof m.tl==='number'&&isFinite(m.tl)&&Math.abs((G.timeLeft||0)-m.tl)>0.3) G.timeLeft=m.tl;
  w=netWxOf(m.wx); if(w) G.wx=w;
  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
  if(m.z&&typeof m.z.length==='number') for(i=0;i<m.z.length&&i<(G.zones||[]).length;i++){
    a=m.z[i]; Z=G.zones[i]; if(!a||!Z) continue;
    if(typeof Z.netCallAt==='number'&&G.t-Z.netCallAt<1.5&&a[1]===null) continue;
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=a[4];
  }
  if(typeof m.ai==='number'&&m.ai>=0&&G.zones&&G.zones[m.ai]){ G.active=G.zones[m.ai]; G.beaconT=G.active.beaconT; }
  if(m.s&&typeof m.s.length==='number') for(i=0;i<m.s.length&&i<12;i++){
    a=m.s[i]; if(!a||typeof a[0]!=='number') continue;
    have=false; for(k=0;k<G.strikes.length;k++) if(G.strikes[k].rid===a[0]) have=true;
    if(have||(G.netBolts&&G.netBolts[a[0]])) continue;
    (G.netBolts=G.netBolts||{})[a[0]]=1;
    S={x:+a[1]||0,y:+a[2]||0,t:Math.max(0.05,+a[3]||0.05),hit:0,rm:1,rid:a[0]}; G.strikes.push(S);
    if(!G.sim) sfx('charge',S.x,S.y);
  }
  return 'wd';
}
// A beacon called on this window: a linked window asks the host for the party. Returns whether it asked.
function netBeaconCalled(z){
  var i, ix;
  if(!netEntsPeer()) return false;
  ix=G.zones.indexOf(z); if(ix<0) return false;
  z.netCallAt=G.t;
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'bcn',i:ix});
  return true;
}
// On the host: a teammate called the beacon at ring i; it is called here, where the rings live, as his own call makes it.
function netBeaconTake(peer,m){
  var Z;
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(!netEntsHost()||typeof m.i!=='number') return 'off';
  Z=G.zones[m.i|0]; if(!Z) return 'bad';
  if(Z.beaconT!==null&&Z.beaconT!==undefined) return 'called already';
  if(Z.open===false) return 'closed';
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=null; Z.pullN=0; Z.pinged=0;
  G.active=Z; G.beaconT=Z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
  if(G.tel) G.tel.beaconCalls=(G.tel.beaconCalls||0)+1;
  blip('beacon'); say((netSeatName(peer.seat)||'Your teammate')+' called the extraction. Inbound '+Math.ceil(Z.beaconT)+'s.');
  return 'called';
}
function netEntsHost(){"""),
("""  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host""",
"""  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='wd') return netWorldTake(peer,m);   // v16.06: the raid clock, the weather, the bolts and the rings, from the host
  if(m.t==='bcn') return netBeaconTake(peer,m);   // v16.06: a teammate called the beacon; the host calls it for the party"""),
], "THE HOST OWNS THE RAID CLOCK, THE WEATHER, THE LIGHTNING AND THE EXTRACTION RINGS. Multiplayer. Each window ran its own, so two players could stand in different weather, their clocks drifted, a host bolt could hit a teammate who never saw its warning, and a beacon one player called existed for him alone. Twice a second the host now tells the party the clock, the sky, the live bolts and every ring; a linked window follows it, draws the host bolts, and asks the host to call a beacon for the party. The storm now centres on each of the party in turn. Each player still extracts alone. Solo untouched. No number moved. Check 16.06 fails on v16.05",
"# THE HOST OWNS THE RAID CLOCK, THE WEATHER, THE LIGHTNING AND THE EXTRACTION RINGS. Multiplayer, plan phase 2 and 3 (world snapshots; the beacon is shared by the party).\n")
import gen
_fx = gen.fixture
def fixture(new, check, anchor=None):
    _fx(new, check, anchor)
    p = gen.os.path.join(gen.H, 'f%d.ps1' % new); t = open(p, encoding='ascii').read()
    L = open(gen.os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
    k = [n for n, x in enumerate(L) if "var ow2=netOnMsg(H,js({t:'up',s:0,st:'out',how:'dead'}));" in x][0]
    old = '\n'.join(L[k:k+9])
    assert L[k+8].strip() == "var outB=last(sentB,'up');", L[k+8]
    new = '\n'.join(["       sentB.length=0;   // v16.06: since v15.91 the host out word ends this raid as abandon, his ruling (check 15.91): the out word this window sends goes out then",
                     L[k], L[k+1],
                     "       if(G&&G.player&&!G.over){ netUpTick(0); if(frame()!==n0) bad.push('after the host raid ended this window still draws it'); }",
                     L[k+4], L[k+5], L[k+7], L[k+8]])
    extra = gen.sub(old, new)
    t = t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
    open(p, 'w', encoding='ascii', newline='\n').write(t)
fixture(1606, r"""  {v:'16.06',what:'the host owns the raid clock, the weather, the lightning and the rings: the host world word carries the clock, the sky, the live bolts and every ring; a linked window takes them, draws a host bolt that never hits it, runs no weather turn of its own, and a beacon a teammate calls is called on the host',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof WEATHER==='undefined') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster,upN:NET.upN}, keepSt=state, sent=[], p, peer, i, wd=null, TS=5000, oPick=pickWeather, WS=null, WF=null, WR=null, hp0;
     for(i=0;i<WEATHER.length;i++){ if(WEATHER[i].id==='storm') WS=WEATHER[i]; if(WEATHER[i].id==='fog') WF=WEATHER[i]; if(WEATHER[i].id==='rain') WR=WEATHER[i]; }
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function js(o){ return JSON.stringify(o); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={};
       p=G.player; G.sim=0; G.over=false; state='raid';
       if(!G.zones||!G.zones.length||!WS||!WF||!WR) return 'SKIP: no rings or no storm, fog and rain in this build';
       // THE HOST WORD
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       G.timeLeft=123.4; G.wx=WS; G.wxNext=null; G.strikes=[{x:p.x+300,y:p.y,t:0.8,hit:0,id:77}];
       sent.length=0;
       try{ if(typeof netWorldSend==='function') netWorldSend(); }catch(x0){ bad.push('netWorldSend threw: '+x0); }
       for(i=0;i<sent.length;i++) if(sent[i].t==='wd') wd=sent[i];
       if(!wd) bad.push('the host sends the party no word of the clock, the weather, the bolts or the rings, so each window runs its own');
       else{
         if(wd.tl!==123.4||wd.wx!=='storm') bad.push('the world word says clock '+wd.tl+' and sky '+wd.wx+', not 123.4 and storm');
         if(!wd.s||!wd.s.length||wd.s[0][0]!==77) bad.push('the world word does not carry the live bolt: '+js(wd.s));
         if(!wd.z||wd.z.length!==G.zones.length) bad.push('the world word carries '+(wd.z?wd.z.length:0)+' rings, not '+G.zones.length);
       }
       var bc=netOnMsg(peer,js({t:'bcn',i:0}));
       if(!(G.zones[0].beaconT>0)) bad.push('a beacon a teammate called at ring 0 was not called on the host ('+bc+')');
       // THE LINKED WINDOW
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; NET.up=[];
       NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ME'}];
       G.zones[0].beaconT=null; G.strikes=[]; G.wx=WR; G.timeLeft=300;
       var zw=[]; for(i=0;i<G.zones.length;i++) zw.push([null,i===0?30:null,null,null,null]);
       var tk=netOnMsg(peer,js({t:'wd',sd:G.seed>>>0,tl:200,wx:'fog',wn:'',wt:0,ai:0,z:zw,s:[[91,Math.round(p.x),Math.round(p.y),0.04]]}));
       if(Math.abs(G.timeLeft-200)>0.01) bad.push('the linked window clock reads '+G.timeLeft+' after the host said 200 ('+tk+')');
       if(!G.wx||G.wx.id!=='fog') bad.push('the linked window sky is '+(G.wx&&G.wx.id)+' after the host said fog');
       if(G.zones[0].beaconT!==30) bad.push('the linked window ring 0 beacon reads '+G.zones[0].beaconT+' after the host said 30');
       var rb=null; for(i=0;i<G.strikes.length;i++) if(G.strikes[i].rid===91) rb=G.strikes[i];
       if(!rb) bad.push('the host bolt is not drawn on the linked window');
       G.wx=WS; hp0=p.hp; p.downed=false; G.lightning=0;
       strikeTick(0.1);
       if(p.hp!==hp0) bad.push('a host bolt on the linked window hit him there too ('+hp0+' to '+p.hp+'), so the host hit would land twice');
       else if(rb&&!(G.lightning>0)) bad.push('the host bolt did not flash on the linked window');
       // NO WEATHER TURN OF ITS OWN
       pickWeather=function(){ return WR; };
       G.wx=WF; G.wxNext=null; G.wxTurnsLeft=1; G.wxAt=0; G.paused=false;
       for(i=0;i<5;i++){ TS+=16; __loop(TS); }
       if(G.wxNext&&G.wxNext.id==='rain') bad.push('the linked window turned its own weather to rain, on its own stream');
     }
     finally{
       try{ pickWeather=oPick; }catch(_pw){}
       try{ keys={}; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; NET.upN=keepN.upN; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
