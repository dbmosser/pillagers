// coord-07 frame-time sampler (measurement only). Loaded into a fixture page by fetch + indirect eval.
// It never edits the game: it reads G, GFXT, DRS, CFG through __state / __gx, and drives the player like a test robot
// (keys[] held in turn, mouse aim circling, hp kept full) so the camera scrolls and the world draws.
(function(){
  var C7=window.__c7={ver:3};
  function gx(s){ try{ return window.__gx(s); }catch(e){ return null; } }
  function q(arr,f){ if(!arr.length) return null; var a=arr.slice().sort(function(x,y){return x-y;}); return +a[Math.min(a.length-1,Math.floor(a.length*f))].toFixed(2); }
  C7.calib=function(){ var t0=performance.now(), s=0, i; for(i=0;i<2e7;i++) s+=Math.sqrt(i); var t1=performance.now(); C7._sink=s; return +(t1-t0).toFixed(1); };
  C7.canv=function(){ return [].slice.call(document.querySelectorAll('canvas')).filter(function(c){ return c.width*c.height>=40000; }).map(function(c){ return (c.id||'?')+' '+c.width+'x'+c.height+' css '+c.offsetWidth+'x'+c.offsetHeight; }); };
  C7.drs=function(){ return gx("({scale:DRS.scale,applied:DRS.applied,q:DRS.q|0,moves:DRS.moves,said:DRS.said,min:DRS.min,gfxScaleNow:gfxScaleNow(),gfxAuto:CFG.gfxAuto,gfxScale:CFG.gfxScale,gfxLight:CFG.gfxLight,gfxPost:CFG.gfxPost,fxLevel:CFG.fxLevel,fpsCap:CFG.fpsCap,DPR:DPR,W:W,H:H,state:state})"); };
  C7.hist=function(){ var h=gx('GFXT.h'); return h?h.slice():null; };
  function histPct(h,n,f){ var want=Math.max(1,Math.ceil(n*f)), c=0, i; for(i=0;i<=200;i++){ c+=h[i]; if(c>=want) return (i>=200)?100:(i+0.5)/2; } return 0; }
  C7.deploy=function(seed,fw,fh){
    try{ __pinDPR(1); }catch(e){}
    try{ __runPrep(); }catch(e){}
    if(fw){ try{ C7.forced=__forceSize(fw,fh); }catch(e){ C7.forced='err '+e.message; } }
    gx('DRS.scale=1;DRS.applied=1;DRS.q=0;gfxqApply();DRS.slowT=0;DRS.fastT=0;DRS.bounce=0;DRS.upAt=0;DRS.last=0;DRS.ema=0;DRS.said=0;DRS.moves=0;1');   // a fresh session: auto resolution starts at full
    var r=__deploy({kit:[],safe:null,mapIx:0,seed:seed||4242});
    var G=__state();
    return {ver:gx('VER'),forced:C7.forced||null,deploy:String(r).slice(0,80),raid:!!(G&&G.player&&!G.over),ents:G&&G.ents?G.ents.length:null,containers:G&&G.containers?G.containers.length:null,drs:C7.drs(),canvases:C7.canv(),dpr:window.devicePixelRatio,inner:[innerWidth,innerHeight]};
  };
  C7.end=function(){ var s='ok'; try{ var G=__state(); if(G&&!G.over&&!G.sim) __endRaid('abandon'); }catch(e){ s='end err '+e.message; } try{ __topClear(); }catch(e){ s+=' top err '+e.message; } return s; };
  // opts: warm (s), sec (s), move (bool), label
  C7.sample=function(opts){
    opts=opts||{}; var WARM=(opts.warm||3)*1000, SEC=(opts.sec||20)*1000, MOVE=opts.move!==false;
    var cal0=C7.calib();
    return new Promise(function(res){
      var t0=performance.now(), last=t0, gaps=[], frames=0, phase=0, h0=null, drs0=null, gfx0=null, dirs=[['KeyD'],['KeyD','KeyS'],['KeyS'],['KeyA','KeyS'],['KeyA'],['KeyA','KeyW'],['KeyW'],['KeyD','KeyW']], di=0, dirT=t0, kref=null, path=0, px=null, py=null, stuck=0, alive=1, raidLost=0, busy=[], mc=new MessageChannel();
      mc.port1.onmessage=function(ev){ if(phase===1) busy.push(performance.now()-ev.data); };
      function setDir(){ kref=gx('keys'); if(!kref) return; ['KeyW','KeyA','KeyS','KeyD'].forEach(function(k){ kref[k]=false; }); dirs[di].forEach(function(k){ kref[k]=true; }); }
      if(MOVE) setDir();
      (function tick(ts){
        var now=performance.now(), d=now-last; last=now; frames++;
        if(ts) try{ mc.port2.postMessage(ts); }catch(_){}
        var G=null; try{ G=__state(); }catch(_){}
        if(!G||!G.player||G.over){ raidLost=1; }
        else {
          var p=G.player;
          try{ p.hp=p.maxhp||100; p.downed=0; }catch(_){}
          if(opts.arc&&frames%10===0) gx('ARCADE.ownAt=Date.now();1');   // the arcade idle clock sees a player at the keys (a robot holding keys[] is not input to it)
          if(opts.drift){ var da=Math.floor(now/1500)*2.2; var dt0=Math.min(0.1,d/1000); try{ p.x+=Math.cos(da)*opts.drift*dt0; p.y+=Math.sin(da)*opts.drift*dt0; }catch(_){} }
          if(opts.drift||MOVE){ if(px!==null){ path+=Math.hypot(p.x-px,p.y-py); } px=p.x; py=p.y; }
          if(MOVE){
            if(now-dirT>1500){ di=(di+3)%dirs.length; dirT=now; setDir(); }
            try{ var m=gx('mouse'); if(m){ var a=now/900; m.x=(gx('W')||1920)/2+Math.cos(a)*300; m.y=(gx('H')||1080)/2+Math.sin(a)*220; } }catch(_){}
          }
        }
        if(phase===0&&now-t0>=WARM){ phase=1; h0=C7.hist(); drs0=C7.drs(); try{ gfx0=JSON.parse(JSON.stringify(__state().tel.gfx||null)); }catch(_){} last=now; }
        else if(phase===1) gaps.push(d);
        if(phase===1&&now-t0>=WARM+SEC){ finish(); return; }
        if(raidLost&&phase===1&&gaps.length>30){ finish(); return; }
        requestAnimationFrame(tick);
      })();
      function finish(){
        if(MOVE&&kref){ ['KeyW','KeyA','KeyS','KeyD'].forEach(function(k){ kref[k]=false; }); }
        var h1=C7.hist(), hd=null, hn=0, hslow=0, i;
        if(h0&&h1&&h0.length===h1.length){ hd=[]; for(i=0;i<h1.length;i++){ var v=h1[i]-h0[i]; hd.push(v); hn+=v; if(i>50) hslow+=v; } }
        var gfx=null; try{ gfx=JSON.parse(JSON.stringify(__state().tel.gfx||null)); }catch(_){}
        var cal1=C7.calib();
        var o={label:opts.label||'',frames:gaps.length,secs:+((performance.now()-t0-WARM)/1000).toFixed(2),
          gap:{p50:q(gaps,0.5),p95:q(gaps,0.95),p99:q(gaps,0.99),worst:q(gaps,1),mean:gaps.length?+(gaps.reduce(function(a,b){return a+b;},0)/gaps.length).toFixed(2):null,
               over16_7:gaps.filter(function(x){return x>16.7;}).length,over20:gaps.filter(function(x){return x>20;}).length,over25:gaps.filter(function(x){return x>25;}).length,over33:gaps.filter(function(x){return x>33.4;}).length},
          fps_p50:null, gfx_end:gfx, gfx_at_warm:gfx0,
          gfx_window:hd?{n:hn,p50:histPct(hd,hn,0.5),p95:histPct(hd,hn,0.95),slow25:hslow}:null,
          drs_start:drs0, drs_end:C7.drs(), canvases:C7.canv(), dpr:window.devicePixelRatio, inner:[innerWidth,innerHeight],
          busy_ms:{p50:q(busy,0.5),p95:q(busy,0.95),worst:q(busy,1),n:busy.length,over16_7:busy.filter(function(x){return x>16.7;}).length},
          calib_ms:{before:cal0,after:cal1}, moved_px:Math.round(path), raid_lost:raidLost,
          ents:(function(){ try{ return __state().ents.length; }catch(_){ return null; } })()};
        o.fps_p50=o.gap.p50?+(1000/o.gap.p50).toFixed(1):null;
        res(JSON.stringify(o));
      }
    });
  };
  return 'c7 loaded';
})();
