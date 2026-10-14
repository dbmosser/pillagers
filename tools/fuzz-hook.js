// fuzz-hook.js : injected by tools/fuzz.ps1 into a fixture copy of the game, through window.__gx (a direct eval in GAME SCOPE),
// so the poll below can read G, P, state, ARCADE and the rest. It is a TOOL: it only watches (error hooks, a frame heartbeat, a
// poll that returns a compact state object) and never changes the game, its code or its seeded random stream.
// ASCII only. Evaluated once per page load; a second evaluation returns 'already'.
(function(){
  if(window.__fz&&window.__fz.v===3) return 'already';
  var Z=window.__fz={v:3,errs:[],raf:performance.now(),frames:0,lastPoll:performance.now(),cmap:{},dead:0};
  function push(k,m,w){
    if(Z.errs.length>=40) return;
    Z.errs.push({k:k,m:String(m==null?'':m).slice(0,400),w:String(w||'').slice(0,400)});
  }
  function safeJ(x){ try{ return JSON.stringify(x); }catch(e){ return String(x); } }
  // 1. errors: the same three doors the game's own crash catcher watches, plus console.error
  window.addEventListener('error',function(ev){
    var er=ev&&ev.error;
    if(!er&&(/^ResizeObserver loop/).test(String(ev&&ev.message||''))) return;
    push('error',(ev&&ev.message)||(er&&er.message),(er&&er.stack)||((ev&&ev.filename)+':'+(ev&&ev.lineno)));
  });
  window.addEventListener('unhandledrejection',function(ev){
    var r=ev&&ev.reason;
    push('rejection',(r&&r.message)||String(r),(r&&r.stack)||'');
  });
  try{
    var ce=console.error;
    console.error=function(){
      var a=[],i,x;
      for(i=0;i<arguments.length;i++){ x=arguments[i]; a.push((x&&x.stack)?x.stack:(typeof x==='object'?safeJ(x):String(x))); }
      push('console.error',a.join(' ').slice(0,300),'');
      return ce.apply(console,arguments);
    };
  }catch(e){}
  // 2. frame heartbeat of the page itself (the game has its own, HID.lastRaf, read in poll)
  (function beat(){ Z.raf=performance.now(); Z.frames++; requestAnimationFrame(beat); })();
  // 3. the game's own crash list: what it caught is read as seen, so only new entries (or a repeat count that grew) are reported
  try{ (P.crashes||[]).forEach(function(c){ Z.cmap[c.kind+'|'+c.msg]=c.n||1; }); }catch(e){}
  // 4. watchdog: if the driver stops polling (killed when he came back), the page lets go of the CPU on its own
  setInterval(function(){
    if(Z.dead||performance.now()-Z.lastPoll<45000) return;
    Z.dead=1;
    try{ if(G&&!G.over&&state==='raid') endRaid('abandon'); }catch(e){}
    try{ location.href='about:blank'; }catch(e){}
  },5000);
  function bad1(n,v,out){ if(typeof v==='number'&&!isFinite(v)&&out.length<12) out.push(n); }
  // 5. the poll: one compact object per call
  Z.poll=function(){
    var now=performance.now(), o={}, g=null, p=null, i, k, bad=[], oc, c, e, cells, hc;
    Z.lastPoll=now;
    o.raf=Math.round(now-Z.raf); o.fr=Z.frames;
    try{ o.gl=(HID&&HID.lastRaf)?Math.round(now-HID.lastRaf):-1; }catch(x){ o.gl=-2; }
    try{ o.st=state; g=G; }catch(x){ o.st='?'; }
    try{ o.ver=VER; }catch(x){}
    o.errs=Z.errs.splice(0,Z.errs.length);
    try{
      (P.crashes||[]).forEach(function(c){
        var key=c.kind+'|'+c.msg, n=c.n||1;
        if(n>(Z.cmap[key]||0)) push('game-crash',c.msg,(c.where||'')+' [screen '+c.screen+']');
        Z.cmap[key]=n;
      });
      if(Z.errs.length) o.errs=o.errs.concat(Z.errs.splice(0,Z.errs.length));
    }catch(x){}
    try{ o.heap=Math.round(performance.memory.usedJSHeapSize/1048576); }catch(x){}
    try{ o.ae=(typeof ARCADE==='object'&&ARCADE&&ARCADE.over)?1:0; o.aon=(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)?1:0; }catch(x){}
    o.raid=0;
    if(o.st==='raid'&&g){
      p=g.player; o.raid=1; o.over=g.over?1:0;
      o.arc=g.arcade?1:0; o.car=g.career?1:0;
      try{ o.solo=(typeof ARCADE==='object'&&ARCADE&&ARCADE.solo)?1:0; }catch(x){}
      try{ o.clk=raidClockOn()?1:0; o.tl=Math.round(+g.timeLeft); }catch(x){}
      o.ents=g.ents?g.ents.length:-1;
      try{ o.sc=g.arcade?(ARCADE.mine|0):((g.cs&&g.cs.s)|0); }catch(x){}
      if(p){
        o.x=p.x; o.y=p.y; o.hp=p.hp; o.ar=p.armor; o.mhp=p.maxhp;
        o.dn=(p.downed||p.dying)?1:0; o.am=(typeof p.ammo==='number'&&isFinite(p.ammo))?p.ammo:null;
        bad1('p.x',p.x,bad); bad1('p.y',p.y,bad); bad1('p.hp',p.hp,bad); bad1('p.armor',p.armor,bad);
        if(typeof p.x!=='number') bad.push('p.x type '+typeof p.x);
        if(typeof p.hp!=='number') bad.push('p.hp type '+typeof p.hp);
        o.gb=[];   // generic non-finite numbers on the player object: the driver compares them with the raid start
        for(k in p){ if(typeof p[k]==='number'&&!isFinite(p[k])&&o.gb.length<12) o.gb.push('p.'+k); }
      }
      if(g.ents){
        for(i=0;i<g.ents.length&&bad.length<12;i++){
          e=g.ents[i]; if(!e) continue;
          if(typeof e.x==='number'&&!isFinite(e.x)) bad.push('ent'+i+'.x '+e.kind);
          else if(typeof e.y==='number'&&!isFinite(e.y)) bad.push('ent'+i+'.y '+e.kind);
          else if(typeof e.hp==='number'&&e.hp!==e.hp) bad.push('ent'+i+'.hp '+e.kind);
        }
      }
      try{ if(!isFinite(camX)||!isFinite(camY)) bad.push('camera'); }catch(x){}
      oc=document.getElementById('outcome');
      o.menu=(pauseOpen?1:0)|(g.paused?2:0)|(g.mapOpen?4:0)|(g.bagOpen?8:0)|(g.trade?16:0)|((oc&&oc.classList.contains('on'))?32:0)|((p&&(p.downed||p.dying))?64:0)|((typeof ARCADE==='object'&&ARCADE&&+ARCADE.holdT>0)?128:0);
      if(g.bagOpen&&!g.over){   // the cells a random drag can pick up and drop on
        cells=[]; hc=[];
        (g.bagCells||[]).slice(0,40).forEach(function(c){ if(isFinite(c.x)&&isFinite(c.y)) cells.push([Math.round(c.x+c.w/2),Math.round(c.y+c.h/2)]); });
        (g.hotCells||[]).slice(0,12).forEach(function(c){ if(isFinite(c.x)&&isFinite(c.y)) hc.push([Math.round(c.x+c.w/2),Math.round(c.y+c.h/2)]); });
        o.bc=cells; o.hc=hc;
      }
    }
    o.bad=bad;
    return o;
  };
  return 'installed';
})()
