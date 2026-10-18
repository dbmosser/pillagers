// fuzz-pad.js : the SIMULATED XBOX PAD for player 2, injected by tools/fuzz.ps1 (mode demo2p) into the PLAYER 2 window of the 2-player
// arcade demo, through window.__gx (a direct eval in game scope). It is a TOOL: it replaces navigator.getGamepads in THAT page only with a
// fake standard pad on slot 1 ("controller 2", which is what the arcade gives player 2: arcadePadsIn), and plays it like a restless guest:
// both sticks wander, the right trigger fires in bursts, A rolls, B crouches, X reloads / searches / holds, the bumpers change the belt, the
// D-pad uses the wheel and the map, now and then VIEW (backpack) and MENU (pause), each of those closed again a moment later.
// It never touches the game, its code or its seeded random stream (its own tiny random generator is seeded from the raid seed).
// ASCII only. Evaluated once per page load (the text __SEED__ is replaced by the driver); a second evaluation returns 'already'.
// __fzpad.press(btn,ms) forces a press (the driver uses it for the A that joins the raid); __fzpad.on=false parks the pad (all released).
(function(){
  if(window.__fzpad) return 'already';
  var seed=(__SEED__)>>>0;
  function rnd(){ seed=(Math.imul(seed,1664525)+1013904223)>>>0; return seed/4294967296; }
  var NB=17, pad={id:'Xbox 360 Controller (STANDARD GAMEPAD Vendor: 045e Product: 028e)',index:1,connected:true,mapping:'standard',timestamp:0,axes:[0,0,0,0],buttons:[]};
  var i;
  for(i=0;i<NB;i++) pad.buttons.push({pressed:false,touched:false,value:0});
  var Z=window.__fzpad={on:true,calls:0,presses:0,pad:pad,log:[]};
  var ev=[], mv={until:0}, aim={until:0}, fire={until:0}, lastT=performance.now();
  function note(s){ Z.log.push(Math.round(performance.now())+' '+s); if(Z.log.length>30) Z.log.shift(); }
  function setB(b,down,v){
    var o=pad.buttons[b]; if(!o) return;
    o.pressed=!!down; o.touched=!!down; o.value=down?(v===undefined?1:v):0;
    if(down){ Z.presses++; note('b'+b+' down'); }
  }
  function hold(b,now,ms){ setB(b,true); ev.push([now+ms,b]); }
  function stick(o,a,mag,now,len,ix){
    o.until=now+len;
    pad.axes[ix]=Math.cos(a)*mag; pad.axes[ix+1]=Math.sin(a)*mag;
  }
  function rest(){ for(var k=0;k<4;k++) pad.axes[k]=0; for(var j=0;j<NB;j++){ var o=pad.buttons[j]; o.pressed=false; o.touched=false; o.value=0; } ev.length=0; }
  function chance(ratePerSec,dt){ return rnd()<ratePerSec*dt/1000; }
  function step(){
    var now=performance.now(), dt=Math.min(250,now-lastT), k;
    lastT=now; Z.calls++;
    pad.timestamp=now;
    if(!Z.on){ rest(); return; }
    for(k=ev.length-1;k>=0;k--) if(ev[k][1]>=0 && now>=ev[k][0]){ setB(ev[k][1],false); ev.splice(k,1); }
    // left stick: wander, with a pause now and then
    if(now>=mv.until){
      if(rnd()<0.2){ pad.axes[0]=0; pad.axes[1]=0; mv.until=now+300+rnd()*1200; }
      else stick(mv,rnd()*6.2832,0.55+rnd()*0.45,now,300+rnd()*2200,0);
    }
    // right stick: aim somewhere, sometimes let go
    if(now>=aim.until){
      if(rnd()<0.15){ pad.axes[2]=0; pad.axes[3]=0; aim.until=now+300+rnd()*900; }
      else stick(aim,rnd()*6.2832,0.7+rnd()*0.3,now,400+rnd()*1800,2);
    }
    // right trigger: bursts of fire
    if(now>=fire.until){
      if(pad.buttons[7].pressed){ setB(7,false); fire.until=now+200+rnd()*1500; }
      else if(rnd()<0.6){ setB(7,true,0.6+rnd()*0.4); fire.until=now+150+rnd()*1400; }
      else fire.until=now+300+rnd()*800;
    }
    if(chance(0.30,dt)) hold(0,now,80+rnd()*120);                 // A: roll
    if(chance(0.05,dt)) hold(1,now,80+rnd()*120);                 // B: crouch
    if(chance(0.20,dt)) hold(2,now,80+rnd()*150);                 // X: reload / search
    if(chance(0.07,dt)) hold(2,now,1500+rnd()*2000);              // X held: loot, extraction call
    if(chance(0.05,dt)) hold(3,now,80+rnd()*150);                 // Y
    if(chance(0.03,dt)) hold(3,now,1200+rnd()*1500);              // Y held: finisher
    if(chance(0.20,dt)) hold(4,now,60+rnd()*100);                 // LB
    if(chance(0.20,dt)) hold(5,now,60+rnd()*100);                 // RB
    if(chance(0.08,dt)) hold(6,now,400+rnd()*900,1);              // LT: focus aim
    if(chance(0.05,dt)) hold(10,now,800+rnd()*1500);              // left stick click: sprint
    if(chance(0.03,dt)) hold(11,now,100+rnd()*200);               // right stick click
    if(chance(0.05,dt)) hold(12,now,80+rnd()*150);                // D-up: ping
    if(chance(0.02,dt)) hold(12,now,900+rnd()*900);               // D-up held: map
    if(chance(0.10,dt)) hold(13,now,300+rnd()*800);               // D-down: item wheel
    if(chance(0.08,dt)) hold(14+Math.floor(rnd()*2),now,60+rnd()*100);   // D-left / D-right: aim distance
    if(chance(0.02,dt)){ hold(8,now,80+rnd()*100); ev.push([now+1200+rnd()*2500,-8]); }    // VIEW: backpack, closed again later
    if(chance(0.012,dt)){ hold(9,now,80+rnd()*100); ev.push([now+1500+rnd()*2500,-9]); }   // MENU: pause, closed again later
    // a queued "close it again" tap (the negative numbers above)
    for(k=ev.length-1;k>=0;k--) if(ev[k][1]<0 && now>=ev[k][0]){ var bb=-ev[k][1]; ev.splice(k,1); hold(bb,now,90); }
  }
  function snap(){
    step();
    return [null,pad,null,null];
  }
  Z.press=function(b,ms){ var n=performance.now(); setB(b,true); ev.push([n+(ms||250),b]); return true; };
  Z.logText=function(){ return Z.log.join(' | '); };
  try{ Object.defineProperty(navigator,'getGamepads',{value:snap,configurable:true,writable:true}); }
  catch(e){ try{ navigator.getGamepads=snap; }catch(e2){ return 'failed: '+e2; } }
  return 'installed';
})()
