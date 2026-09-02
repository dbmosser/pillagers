// HIS REPORT: "crawlers aren't hitting me when i stand still in some instances".
// A crawler only swings inside e.state==='chase'. Chase is left when it cannot
// see you and its alert has run out, and the state it goes to walks to your last
// known spot and does nothing else. Stand still and that spot is where you are.
(function(){ window.__DBG=null; var mc=new MessageChannel(); mc.port1.onmessage=function(){ try{
 function trial(mode){
   __resetCfg(); __pinDefaults(0); __cleanProfile();
   __deploy({kit:[],safe:null,mapIx:0,seed:4242});
   var g=__state(), p=g.player, i, cr=null;
   for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ cr=g.ents[i]; break; }
   if(!cr) return {skip:'no crawler on this map'};
   g.ents.length=0; g.ents.push(cr);
   p.iv=0; p.downed=false; p.hp=100; g.pCrouch=true;
   // Contact: bodies touching, well inside any melee reach.
   cr.x=p.x+(cr.r+(p.r||11))+2; cr.y=p.y;
   cr.hostile=true; cr.downed=false; cr.cd=0;
   cr.state=mode; cr.tx=p.x; cr.ty=p.y;
   cr.alert=(mode==='chase')?2.4:0;
   // Facing away, which is how it stops seeing you while standing on you.
   cr.face=Math.atan2(cr.y-p.y,cr.x-p.x);
   var hp0=p.hp, states={};
   for(var f=0;f<180;f++){
     __ents(1/60);
     states[cr.state]=(states[cr.state]||0)+1;
     p.hp=Math.min(p.hp,hp0);           // never heal, so damage is cumulative
     if(p.downed){ p.downed=false; p.hp=100; hp0=100; }
   }
   var gap=Math.hypot(cr.x-p.x,cr.y-p.y)-(cr.r+(p.r||11));
   return {startedAs:mode, damage:Math.round(hp0-p.hp), endState:cr.state,
           statesSeen:Object.keys(states).join('+'),
           finalGap:Math.round(gap), cd:+(cr.cd||0).toFixed(2)};
 }
 window.__DBG={chase:trial('chase'), investigate:trial('investigate')};
}catch(x){ window.__DBG='THREW '+(x&&x.message||x); } }; mc.port2.postMessage(0); })();
