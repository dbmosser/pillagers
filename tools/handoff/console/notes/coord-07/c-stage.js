// coord-07 run C staging: a real linked pair (window.open + BroadcastChannel) in the 2 player arcade demo, built from the
// stageDropPair seat 1 demo path in notes/shots/62-share-drop/camera-recipes.json (the linking part only, no drop).
// Test page only: the player 2 window is opened at 1920x1080 (netP2Features is swapped in THIS page) instead of 90 percent of the screen.
(function(){
  var wait=function(ms){ return new Promise(function(r){ setTimeout(r,ms); }); };
  async function until(fn,label,ms){ var t0=Date.now(); ms=ms||30000; while(Date.now()-t0<ms){ try{ if(fn()) return; }catch(_){} await wait(100); } throw Error(label); }
  // a minimal fake standard pad for the player 2 window: the left stick turns slowly in a circle, nothing is pressed
  window.__c7pad=function(w){
    var pad={id:'Xbox 360 Controller (STANDARD GAMEPAD Vendor: 045e Product: 028e)',index:0,connected:true,mapping:'standard',timestamp:0,axes:[0,0,0,0],buttons:[]}, i;
    for(i=0;i<17;i++) pad.buttons.push({pressed:false,touched:false,value:0});
    w.__c7padObj=pad; w.__c7padOn=false;
    function snap(){ var now=w.performance.now(); pad.timestamp=now; if(w.__c7padOn){ var a=Math.floor(now/1500)*1.3; pad.axes[0]=Math.cos(a)*0.9; pad.axes[1]=Math.sin(a)*0.9; } else { pad.axes[0]=0; pad.axes[1]=0; } return [pad,null,null,null]; }
    try{ Object.defineProperty(w.navigator,'getGamepads',{value:snap,configurable:true,writable:true}); }catch(e){ w.navigator.getGamepads=snap; }
    return 'pad in';
  };
  window.__c7stage=async function(pair){
    var host=window, guest=null;
    try{ __pinDPR(1); }catch(e){}
    try{ var t=document.getElementById('title'); if(t) t.classList.remove('on'); }catch(e){}
    try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(m){ m.classList.remove('on'); }); }catch(e){}
    try{ __topClear(); }catch(e){}
    localStorage.removeItem('salvagerun:p2raid'); localStorage.removeItem('salvagerun:p2live');
    host.__gx("netP2Features=function(){ return 'popup=yes,width=1920,height=1080,left=0,top=0'; };1");
    host.__gx("NET.pair='"+pair+"'");
    var opened=host.__gx('arcadePick()');
    if(opened!=='opened') throw Error('host did not open a real player 2 window: '+opened);
    guest=host.__gx('NET.p2win');
    window.__c7guest=guest;
    await until(function(){ return guest&&guest.__net&&guest.__gx&&guest.__deploy; },'player 2 fixture did not boot',60000);
    try{ guest.__pinDPR(1); }catch(e){}
    window.__c7pad(guest);
    await until(function(){ return host.__gx('PLOADED')&&guest.__gx('PLOADED'); },'both profiles did not finish loading');
    await until(function(){ return host.__net.state().roster.length===2&&guest.__net.state().roster.length===2; },'both real windows did not link');
    await until(function(){ return host.__gx('!!ARCADE.on')&&guest.__gx('!!ARCADE.on'); },'both windows did not enter demo');
    if(!host.__gx('arcadeDropIn()')) throw Error('demo host could not ascend');
    if(!guest.__gx('arcadePadAtt(true,true)')) throw Error('demo player 2 could not request entry');
    var peers=[host,guest];
    await until(function(){ return peers.every(function(w){ var g=w.__state(); return g&&g.player&&!g.over; }); },'both real windows did not enter a raid',60000);
    peers.forEach(function(w){ w.__gx("keys={}; mouse.down=false; mouse.x=W/2; mouse.y=H/2; G.player.iv=999; G.player.ads=false; G.adsZ=1; G.anchX=undefined; G.anchY=undefined; document.querySelectorAll('.modal.on').forEach(function(e){e.classList.remove('on');});1"); });
    var p=host.__state().player;
    try{ guest.__net.stand(p.x+60,p.y+40); }catch(e){}
    var fs=peers.map(function(w){ try{ return w.__forceSize(1920,1080); }catch(e){ return 'err '+e.message; } });
    peers.forEach(function(w){ w.__gx('DRS.scale=1;DRS.applied=1;DRS.q=0;gfxqApply();DRS.slowT=0;DRS.fastT=0;DRS.bounce=0;DRS.upAt=0;DRS.last=0;DRS.ema=0;DRS.said=0;DRS.moves=0;1'); });
    guest.__c7padOn=true;
    await wait(1500);
    return JSON.stringify({ver:host.__gx('VER'),roster:peers.map(function(w){ return w.__net.state().roster.length; }),arcade:peers.map(function(w){ return w.__gx('ARCADE.role'); }),
      urls:peers.map(function(w){ return w.location.href; }),inner:peers.map(function(w){ return [w.innerWidth,w.innerHeight]; }),forced:fs,
      raid:peers.map(function(w){ var g=w.__state(); return !!(g&&g.player&&!g.over); }),ents:peers.map(function(w){ return w.__state().ents.length; })});
  };
  window.__c7unstage=function(){
    var g=window.__c7guest, s=[];
    [window,g].forEach(function(w){ try{ w.__gx("if(G&&!G.over&&!G.sim)__endRaid('abandon');1"); s.push('ended'); }catch(e){ s.push('end err '+e.message); } });
    try{ g.__gx('netSameStop();1'); }catch(e){}
    try{ window.__gx('netSameStop();1'); }catch(e){}
    try{ g.close(); s.push('closed p2'); }catch(e){}
    try{ localStorage.removeItem('salvagerun:p2raid'); localStorage.removeItem('salvagerun:p2live'); }catch(e){}
    return s.join(' ');
  };
  return 'c-stage loaded';
})();
