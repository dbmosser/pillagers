from gen import patch, fixture
patch(1613, [
("""  P.mapRunN=(o.mr&&typeof o.mr==='object'&&!Array.isArray(o.mr))?o.mr:null;""",
"""  P.mapRunN=(o.mr&&typeof o.mr==='object'&&!Array.isArray(o.mr))?o.mr:{};   // v16.13, backcheck: a code with no tally starts a clean one ({}), so the next commit never seeds it from the replaced character's log"""),
("""    if(P.mapRunN&&(P.mapRunN[M.name]|0)>_myR) _myR=P.mapRunN[M.name]|0;""",
"""    if(P.mapRunN) _myR=P.mapRunN[M.name]|0;   // v16.13, backcheck: once there is a tally it is the count (seeded from the log, never below it); the log is read only before one exists, so a restored character does not show the replaced character's runs"""),
("""    e=NET.entMap[id]; if(!e) return 'ent:unknown';
    delete NET.entMap[id];""",
"""    e=NET.entMap[id]; if(!e) return 'ent:unknown';
    delete NET.entMap[id];
    // v16.13, backcheck: the host sends the gone word before the kill word on the same ordered channel, so the kill word found no
    // body and a pillager a friend killed was never remembered (grudge, standing, met). The last bodies gone are kept for it.
    if(!NET.entDead||Object.keys(NET.entDead).length>40) NET.entDead={};
    NET.entDead[id]=e;"""),
("""  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||null;""",
"""  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||(NET.entDead&&NET.entDead[m.id|0])||null;   // v16.13: or the body the gone word just took off"""),
("""  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'bcn',i:ix});""",
"""  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'bcn',i:ix,g:+greedOf().toFixed(3)});   // v16.13: with the caller's greed, which sizes the siege"""),
("""  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=null; Z.pullN=0; Z.pinged=0;""",
"""  var _cg=(typeof m.g==='number'&&isFinite(m.g))?clamp(m.g,0,1):null;   // v16.13, backcheck: the siege is sized by the caller's backpack, as his own window promised
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=_cg; Z.pullN=0; Z.pinged=0;
  // and the call is as loud on the host as the host's own: the ping by the caller's greed, and everything within 2200 alerted and
  // sent to the ring, never overwriting a hunt (the rule of the local call). No jitter is drawn: the net code draws nothing seeded.
  try{
    ping(Z.x,Z.y,700*(1+0.8*(_cg===null?0:_cg)),true,false,'env','fire');
    for(var _wi=0;_wi<G.ents.length;_wi++){ var _we=G.ents[_wi]; if(dist(_we,Z)>2200) continue; _we.alert=Math.max(_we.alert,3); if(_we.kind==='raider'&&_we.bag&&_we.bag.length>=5) continue; if(!onYourTail(_we.state)){ _we.state='investigate'; _we.tx=Z.x; _we.ty=Z.y; } }
  }catch(_wk){}"""),
], "THREE BACKCHECK FIXES. A restore code with no tally starts a clean one, and the sector card reads the tally once there is one, so a restored character no longer shows the runs of the replaced character. A pillager a friend kills is remembered again (the kill word came after the gone word had taken the body off). A beacon a friend calls is sized by the backpack of that friend and wakes the map as loudly as a call the host makes. No number moved. Check 16.13 fails on v16.12",
"# THREE BACKCHECK FIXES (findings on v15.88, v15.80 and v16.06).\n")
fixture(1613, r"""  {v:'16.13',what:'three backcheck fixes: a restore code with no tally starts a clean one and the sector card reads the tally, so a restored character does not show the replaced character runs; a pillager killed by a friend is remembered after the gone word; a beacon a friend calls takes his greed and wakes the bodies near the ring',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__P&&window.__applyLoaded)||typeof restoreMake!=='function'||typeof renderSector!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage the profile or a party raid';
     var host=document.getElementById('sectorlist'); if(!host) return 'SKIP: there is no sector list to draw into';
     var bad=[], snap=null, N0=String(FIXED_MAPS[0].name), keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster,entMap:NET.entMap}, peer, i, L=[], Z, e=null, rec, k0;
     function card(ix){ renderSector(); var el=host.querySelector('.sectorpick[data-map="'+ix+'"]'); return el?String(el.textContent||'').replace(/\s+/g,' '):''; }
     function js(o){ return JSON.stringify(o); }
     try{
       __topClear(); __cleanProfile(); snap=JSON.parse(js(__P()));
       // THE TALLY
       for(i=0;i<30;i++) L.push({mapName:N0,outcome:'extract',_committed:1});
       P.log=L; P.mapRunN={}; P.mapRunN[N0]=5;
       if(card(0).indexOf('you: 5 runs here')<0) bad.push('with a tally of 5 and 30 runs of the replaced character left in the log the card reads "'+card(0).slice(0,70)+'"');
       var o=JSON.parse(js(restoreMake())); delete o.mr;
       P.log=L.slice(); P.mapRunN={}; P.mapRunN[N0]=30;
       restoreApply(o);
       if(!P.mapRunN||typeof P.mapRunN!=='object'||(P.mapRunN[N0]|0)!==0) bad.push('a restore code with no tally left the tally as '+js(P.mapRunN)+', so the next commit seeds it from the replaced character log');
       __applyLoaded(snap); __cleanProfile();
       // THE KILL AFTER THE GONE WORD
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false;
       for(i=0;i<G.ents.length&&!e;i++) if(G.ents[i].kind==='raider'&&G.ents[i].ident) e=G.ents[i];
       NET.on=true; NET.role='join'; NET.seat=1; peer={state:'in',seat:0,name:'ZQX HOST',timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'me',name:'ME'}];
       if(e){
         NET.entMap={}; NET.entMap[77]=e; e.nid=77;
         rec=idRec(e.ident); k0=rec.kills|0;
         netOnMsg(peer,js({t:'ent',op:'gone',id:77,how:'dead',n:5}));
         netOnMsg(peer,js({t:'kill',id:77,k:'raider',seat:1}));
         if((idRec(e.ident).kills|0)!==k0+1) bad.push('a pillager this friend killed was not remembered: the kill word after the gone word found no body (kills '+k0+' to '+(idRec(e.ident).kills|0)+')');
       }
       // THE BEACON A FRIEND CALLS
       NET.role='host'; NET.seat=0; peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer];
       Z=G.zones[0]; Z.open=true; Z.beaconT=null; G.active=null;
       var near=null; for(i=0;i<G.ents.length&&!near;i++) if(G.ents[i].kind!=='raider'&&!G.ents[i].dead&&G.ents[i].hp>0){ near=G.ents[i]; }
       if(near){ near.x=Z.x+300; near.y=Z.y; near.state='patrol'; near.alert=0; }
       netOnMsg(peer,js({t:'bcn',i:0,g:0.8}));
       if(!(Z.beaconT>0)) bad.push('a beacon a friend called was not called on the host');
       if(Z.siegeGreed!==0.8) bad.push('a beacon a friend carrying a heavy backpack called was sized by greed '+Z.siegeGreed+', not his 0.8');
       if(near&&!(near.alert>0)) bad.push('a beacon a friend called woke nothing 300 from the ring');
     }
     finally{
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; NET.entMap=keepN.entMap||{}; NET.entDead={}; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderSector(); }catch(_m){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __topClear(); __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
