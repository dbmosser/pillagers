from gen import patch, fixture
patch(1610, [
("""function voiceVol(peer){ if(peer&&peer.vGain&&peer.vGain.gain) peer.vGain.gain.value=(P&&P.netMute&&peer.pid&&P.netMute[peer.pid])?0:1; }""",
"""function voiceVol(peer){ if(peer&&peer.vGain&&peer.vGain.gain) peer.vGain.gain.value=(P&&P.netMute&&peer.pid&&P.netMute[peer.pid])?0:voiceProx(peer); }
// v16.10, MULTIPLAYER: VOICES CARRY BY DISTANCE UP TOP (plan.md: in the raid, voices get quieter with distance; net.md section 4
// gives the curve). When this player and the teammate are both up top on the party seed, his voice is full out to 120, falls
// to -30 dB at 900 on a straight decibel line, fades out by 1,100, and is halved with a wall between them. Anywhere else (the
// Undercroft, one of them still below) it is full, as before. Every window works it out for itself ten times a second from the
// state words (netUpTick) and again when a raid ends; MUTE still wins.
function voiceProx(peer){
  var g, p, d, v;
  if(typeof G==='undefined'||!G||G.sim||!G.player||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)||!peer) return 1;
  g=NET.up[peer.seat];
  if(!g||g.sd!==(NET.upSeed>>>0)||!(g.n>0)) return 1;
  p=G.player; d=Math.hypot(g.x-p.x,g.y-p.y);
  if(d<=120) v=1;
  else if(d<=900) v=Math.pow(10,(-30*(d-120)/780)/20);
  else if(d<1100) v=Math.pow(10,-1.5)*(1100-d)/200;
  else v=0;
  try{ if(v>0&&G.map&&G.map.segs&&!losClear(p.x,p.y,g.x,g.y,G.map.segs)) v*=0.5; }catch(e){}
  return v;
}
function voiceProxAll(){ var i; for(i=0;i<NET.peers.length;i++) voiceVol(NET.peers[i]); }"""),
("""  if(NET.upAcc<NET_HUB_STEP) return 0;""",
"""  if(NET.upAcc<NET_HUB_STEP) return 0;
  try{ voiceProxAll(); }catch(_vp){}   // v16.10: voices by distance, on the same clock"""),
("""function netUpEnd(how){
  if(!NET.on) return false;""",
"""function netUpEnd(how){
  if(!NET.on) return false;
  setTimeout(function(){ try{ voiceProxAll(); }catch(_vp){} },0);   // v16.10: back to full voices once the raid is let go"""),
], "VOICES CARRY BY DISTANCE UP TOP. Multiplayer. When you and a teammate are both up top, his voice is full out to 120, falls to about a thirtieth by 900, is gone past 1,100, and is halved with a wall between you. In the Undercroft voices stay full. Mute still wins. No number moved in the game. Check 16.10 fails on v16.09",
"# VOICES CARRY BY DISTANCE UP TOP. Multiplayer, plan.md and net.md section 4 (proximity volume).\n")
fixture(1610, r"""  {v:'16.10',what:'voices carry by distance up top: with both up top on the party seed a teammate at 60 is heard full, at 500 quieter, at 1,200 not at all; muted he is silent; with no raid in hand (the Undercroft) he is full again',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof voiceVol!=='function') return 'SKIP: this build has no voice';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepMute=P.netMute, p, peer, keepV=null, v;
     function at(d){ NET.up[1]={seat:1,x:p.x+d,y:p.y,f:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0}; voiceVol(peer); return peer.vGain.gain.value; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); p=G.player; P.netMute={};
       keepV=G.map.segs; G.map.segs=[];
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.up=[];
       peer={state:'in',seat:1,pid:'zqxpid01',name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}},vGain:{gain:{value:1}}};
       NET.peers=[peer]; NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxpid01',name:'ZQX MATE'}];
       v=at(60); if(v!==1) bad.push('a teammate 60 away is heard at '+v+', not full');
       v=at(500); if(!(v>0&&v<0.6)) bad.push('a teammate 500 away is heard at '+v+', not quieter');
       v=at(1200); if(v!==0) bad.push('a teammate 1,200 away is heard at '+v+', not silent');
       P.netMute={zqxpid01:1}; v=at(60); if(v!==0) bad.push('a muted teammate beside him is heard at '+v);
       P.netMute={}; G.map.segs=keepV; keepV=null; G=null; voiceVol(peer);
       if(peer.vGain.gain.value!==1) bad.push('with no raid in hand a teammate is heard at '+peer.vGain.gain.value+', not full');
     }
     finally{
       try{ if(keepV&&G&&G.map) G.map.segs=keepV; }catch(_s){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ P.netMute=keepMute; }catch(_pm){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
""")
