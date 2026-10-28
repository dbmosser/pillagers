// cw-fewermsg measuring run (job 186c): a staged real raid through the fixture, about 3 minutes of game time, seed 4242.
// Loot (search boxes), wade, fight, then call extraction and stand in the ring. Counts every line that reaches the screen:
// a new feed line, a new top banner (alert), a new pickup row. Run inside the game scope (window.__gx).
(function(){
  var SECS=window.__ZQSECS||180, FPS=60, out={feed:0,alert:0,pick:0,txt:[],phase:{},end:'',secs:0,said:{}};
  var oSay=say;   // every line said, drawn or not, counted by its words (the how often column of raid-messages.md)
  say=function(m){ try{ var k=String(m); out.said[k]=(out.said[k]||0)+1; }catch(_c){} return oSay.apply(this,arguments); };
  var g, p, t0, f=0, ph='land', phT=0, tgt=null, opened=0, lastAlert=null, seq0=0, seenPick=[], seenFeed={}, i;
  function now(){ return f/FPS; }
  function setPhase(n){ ph=n; phT=now(); tgt=null; keys={}; mouse.down=false; }
  function aimAt(x,y){ var pz=ZOOM(); var cx=(g.camX===undefined?p.x-W/(2*pz):g.camX), cy=(g.camY===undefined?p.y-H/pz*0.54:g.camY); mouse.x=(x-cx)*pz; mouse.y=(y-cy)*pz; }
  function walkTo(x,y){ keys={}; var dx=x-p.x, dy=y-p.y; if(dx>8) keys.KeyD=true; if(dx<-8) keys.KeyA=true; if(dy>8) keys.KeyS=true; if(dy<-8) keys.KeyW=true; }
  function count(){
    var F=g.fd, L=(F&&F.lines)||[], j, r, a=g.alert;
    // a feed line counts once it is drawn (FEEDBOX.rows, written by the frame's feedDraw); one added and pushed off before any frame drew it does not
    for(j=0;j<L.length;j++) if(L[j].id>seq0){ seq0=L[j].id; out.feedAdded=(out.feedAdded||0)+1; }
    var R=(typeof FEEDBOX!=='undefined'&&FEEDBOX&&FEEDBOX.rows)||[];
    for(j=0;j<R.length;j++) if(!(R[j].a>0)) continue; else if(!seenFeed[R[j].id]){ seenFeed[R[j].id]=1; out.feed++; out.phase[ph]=(out.phase[ph]||0)+1; if(out.txt.length<160) out.txt.push(Math.round(now())+' F '+R[j].t); }
    if(a&&a!==lastAlert){ lastAlert=a; out.alert++; out.phase[ph]=(out.phase[ph]||0)+1; if(out.txt.length<160) out.txt.push(Math.round(now())+' A '+a.m+(a.sub?' / '+a.sub:'')); }
    for(j=0;j<(g.pick||[]).length;j++){ r=g.pick[j]; if(seenPick.indexOf(r)<0){ seenPick.push(r); out.pick++; out.phase[ph]=(out.phase[ph]||0)+1; if(out.txt.length<160) out.txt.push(Math.round(now())+' P '+r.m+(r.n>1?' x'+r.n:'')+(r.tag?' / '+r.tag:'')); } }
  }
  function nearestBox(){ var b=null, bd=1e9, j, c, d; for(j=0;j<g.containers.length;j++){ c=g.containers[j]; if(!c||c.opened||c.dropped||c.zqTried) continue; d=Math.hypot(c.x-p.x,c.y-p.y); if(d<bd){ bd=d; b=c; } } return b; }
  function nearestFoe(){ var b=null, bd=1e9, j, e, d; for(j=0;j<g.ents.length;j++){ e=g.ents[j]; if(!e||e.hp<=0||e.downed||e.merc||e.stray||e.peddler||e.friendly) continue; d=Math.hypot(e.x-p.x,e.y-p.y); if(d<bd){ bd=d; b=e; } } return b; }
  function step(){
    __loop(t0+(++f)*(1000/FPS));
    g=__state(); if(!g||g.over){ return false; }
    p=g.player; if(g.mapOpen) g.mapOpen=false; if(g.bagOpen) g.bagOpen=false;
    if(p.hp<35&&!p.downed) p.hp=70;   // a measuring run, not a death run
    if(p.downed){ p.downed=false; p.hp=60; }
    count();
    var T=now();
    if(ph==='land'&&T>4) setPhase('loot');
    if(ph==='loot'){
      if(T>70){ setPhase('wade'); return true; }
      if(!tgt||tgt.opened||now()-tgt.zqAt>14){ if(tgt) tgt.zqTried=1; tgt=nearestBox(); if(!tgt){ setPhase('wade'); return true; } tgt.zqAt=now(); p.x=tgt.x+26; p.y=tgt.y+4; keys={}; }
      keys[__srchKey()]=true; aimAt(tgt.x,tgt.y);
      if(tgt.opened){ opened++; keys={}; }
    }
    if(ph==='wade'){
      var w=(g.map&&g.map.water)||(MAP&&MAP.water)||[];
      if(!w.length||T>92){ setPhase('fight'); return true; }
      if(!tgt){ tgt=w[0]; p.x=tgt.x+tgt.w*0.5; p.y=tgt.y+tgt.h*0.5; }
      walkTo(tgt.x+tgt.w*(0.2+0.6*((Math.floor(T/3)%2))), tgt.y+tgt.h*0.5);
    }
    if(ph==='fight'){
      if(T>145){ setPhase('extract'); return true; }
      if(!tgt||tgt.hp<=0||tgt.downed||g.ents.indexOf(tgt)<0){ tgt=nearestFoe(); if(tgt){ p.x=tgt.x-240; p.y=tgt.y; } }
      if(tgt){ aimAt(tgt.x,tgt.y); mouse.down=(f%20)<14; if(p.ammo<=0&&!p.reloading) keys.KeyR=true; else delete keys.KeyR; }
    }
    if(ph==='extract'){
      if(!tgt){ var zb=null, zd=1e9; for(var z=0;z<g.zones.length;z++){ var Z=g.zones[z]; if(!Z||Z.closed) continue; var dz=Math.hypot(Z.x-p.x,Z.y-p.y); if(dz<zd){ zd=dz; zb=Z; } } tgt=zb; if(tgt){ p.x=tgt.x; p.y=tgt.y; } }
      if(tgt){ p.x=tgt.x; p.y=tgt.y; keys={}; keys.KeyX=(now()-phT)<3; }
    }
    return true;
  }
  return new Promise(function(res){
    try{
      __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
      __deploy({kit:[],safe:null,mapIx:0,seed:4242});
      g=__state(); p=g.player; g.mapFirst=false; g.mapOpen=false; keys={};
      seq0=(g.fd&&g.fd.seq)||0; lastAlert=g.alert;
      t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
    }catch(e){ say=oSay; res('setup threw '+e); return; }
    function chunk(){
      var ok=true, n;
      try{ for(n=0;n<240&&ok&&now()<SECS;n++) ok=step(); }catch(e){ out.end='threw '+e; ok=false; }
      if(ok&&now()<SECS){ setTimeout(chunk,0); return; }
      out.secs=Math.round(now()); out.end=out.end||(g&&g.over?'raid over':'time'); out.opened=opened;
      out.total=out.feed+out.alert+out.pick; out.perMin=Math.round(out.total/(Math.max(1,now())/60)*10)/10;
      keys={}; mouse.down=false;
      say=oSay;
      try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
      try{ __topClear(); }catch(_t){}
      res(JSON.stringify(out));
    }
    chunk();
  });
})()
