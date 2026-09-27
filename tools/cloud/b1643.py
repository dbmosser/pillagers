import os, gen
from gen import patch, fixture
ST = "      stand:function(x,y){ if(typeof G==='undefined'||!G||!G.player) return false; G.player.x=+x; G.player.y=+y; return true; },"
patch(1643, [
(ST, ST + """
      feed:function(){ var o=[], i; for(i=0;i<(NET.feed||[]).length;i++) o.push(NET.feed[i].txt); return o; },   // v16.43: the kill feed, for the live test
      pings:function(){ var o=[], i; for(i=0;i<(NET.pings||[]).length;i++) o.push({s:NET.pings[i].s,x:NET.pings[i].x,y:NET.pings[i].y,w:NET.pings[i].w}); return o; },
      ping:function(){ return netPingMake(); },"""),
("""  if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();""",
"""  if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();
  if(code==='KeyN'&&G&&!G.over&&!repeat&&NET.on) netPingMake();   // v16.43: ping for the party"""),
("""  if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }""",
"""  if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }
  if(e.button===1){ if(G&&!G.over&&NET.on){ netPingMake(); e.preventDefault(); } return; }   // v16.43: the middle button pings for the party"""),
("""  PAD.prev[4]=_lbN; PAD.prev[5]=_rbN;""",
"""  if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();   // v16.43: both bumpers ping; the two belt steps cancel
  PAD.prev[4]=_lbN; PAD.prev[5]=_rbN;"""),
("""  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed""",
"""  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings"""),
("""  if(m.t==='kf') return netFeedTake(peer,m);   // v16.42: a line for the kill feed, from the host""",
"""  if(m.t==='kf') return netFeedTake(peer,m);   // v16.42: a line for the kill feed, from the host
  if(m.t==='png') return netPingTake(peer,m);   // v16.43: a ping from one of the party"""),
("""var NET_FEED_T=6;""",
"""var NET_FEED_T=6;
// v16.43, THE CO-OP LIST (item 3): A PING. N or the middle mouse button (both bumpers on a controller) marks the point under the
// cursor for the party, or the enemy nearest it within NET_PING_SNAP. Everyone sees a marker with who pinged it for NET_PING_T
// seconds, pulled to the screen edge when it is off screen, and hears a blip. One ping every half second.
var NET_PING_T=8, NET_PING_SNAP=70;
function netPingMake(){
  var w, i, e, bd=NET_PING_SNAP, d, hit=null, m;
  if(typeof G==='undefined'||!G||G.over||!G.player||!NET.on||!NET.upSeed) return null;
  if(NET.pingAt&&Date.now()-NET.pingAt<500) return null;
  NET.pingAt=Date.now();
  w=mouseWorld();
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(!e.nid||e.hp<=0||e.merc) continue; d=dist(e,w); if(d<bd){ bd=d; hit=e; } }
  m={t:'png',x:Math.round(hit?hit.x:w.x),y:Math.round(hit?hit.y:w.y),w:hit?((hit.kind==='raider'&&hit.name)?netClean(hit.name,24):String(hit.kind).toUpperCase()):''};
  if(hit) m.id=hit.nid;
  netBroadcast(m);
  netPingPush(NET.seat,m);
  return m;
}
function netPingTake(peer,m){
  var s;
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  if(NET.role==='host') s=peer.seat; else { s=(m.s===undefined)?0:m.s; if(typeof s!=='number'||s!==(s|0)) return 'bad'; }
  if(s===NET.seat) return 'ignored';
  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24)};
  if(typeof m.id==='number') o.id=m.id|0;
  if(NET.role==='host'){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'png',s:s,x:o.x,y:o.y,w:o.w,id:o.id}); }
  netPingPush(s,o);
  return 'png';
}
function netPingPush(s,o){
  if(!NET.pings) NET.pings=[];
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,at:Date.now()});
  if(NET.pings.length>6) NET.pings.shift();
  try{ if(typeof G!=='undefined'&&G&&!G.sim) blip('pick'); }catch(_bp){}
  return NET.pings.length;
}
function netPingDraw(){
  var i, p, now=Date.now(), s, M=LH(30), e, nm, lbl, x, y, n=0, c;
  if(!NET.pings||!NET.pings.length) return 0;
  for(i=NET.pings.length-1;i>=0;i--){
    p=NET.pings[i];
    if((now-p.at)/1000>NET_PING_T){ NET.pings.splice(i,1); continue; }
    e=(p.id&&NET.entMap)?NET.entMap[p.id]:null;
    if(e&&e.hp>0){ p.x=e.x; p.y=e.y; }   // a pinged enemy is followed while it lives
    s=w2s(p.x,0,p.y); if(!s) continue;
    x=clamp(s.x,M,W-M); y=clamp(s.y,M,H-M);
    c=p.w?'#ff8a3c':'#6fe0ff';
    ctx.save(); ctx.globalAlpha=0.55+0.45*Math.abs(Math.sin(now/180));
    ctx.strokeStyle=c; ctx.lineWidth=2.5;
    ctx.beginPath(); ctx.moveTo(x,y-LH(12)); ctx.lineTo(x+LH(9),y); ctx.lineTo(x,y+LH(12)); ctx.lineTo(x-LH(9),y); ctx.closePath(); ctx.stroke();
    ctx.restore();
    nm=(p.s===NET.seat)?'YOU':(netSeatName(p.s)||'PILLAGER');
    lbl=nm+(p.w?(': '+p.w):'')+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'M';
    ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; ctx.fillText(lbl,clamp(x,LH(60),W-LH(60)),y-LH(16)); ctx.textAlign='left';
    n++;
  }
  return n;
}"""),
], "PING. Co-op list item 3. N or the middle mouse button (both bumpers on a controller) marks the point under the cursor for the party, or snaps to the enemy nearest it and follows him while he lives. Everyone sees a pulsing marker with who pinged it and how far it is for 8 seconds, pulled to the screen edge when off screen, with a blip. One ping every half second. Check 16.43 fails on v16.42",
"# PING (co-op list item 3).\n")
fixture(1643, r"""  {v:'16.43',what:'ping: a ping reaches the party through the host with who made it, and snaps to an enemy near the cursor',
   run:function(){
     if(typeof netPingTake!=='function'||typeof netPingPush!=='function'||typeof netPingMake!=='function') return 'this build has no ping';
     var keep={role:NET.role,seat:NET.seat,peers:NET.peers,pings:NET.pings,roster:NET.roster}, oS=netSend, sent=[], bad=[], r;
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       var P1={state:'in',seat:1}, P2={state:'in',seat:2};
       NET.role='host'; NET.seat=0; NET.peers=[P1,P2]; NET.pings=[]; NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'},{seat:2,name:'REED'}];
       r=netPingTake(P1,{t:'png',x:100,y:200,w:'CRAWLER',id:7});
       if(r!=='png'||!NET.pings.length||NET.pings[0].s!==1||NET.pings[0].w!=='CRAWLER') bad.push('the host did not keep the ping from seat 1 ('+r+', '+JSON.stringify(NET.pings[0])+')');
       if(sent.length!==1||sent[0].s!==1||sent[0].x!==100) bad.push('the host did not pass the ping to the other teammate only ('+JSON.stringify(sent)+')');
       NET.role='join'; NET.seat=2; NET.pings=[];
       r=netPingTake(P1,{t:'png',s:1,x:5,y:6,w:''});
       if(r!=='png'||NET.pings[0].s!==1) bad.push('a teammate did not keep a passed on ping');
       if(netPingTake(P1,{t:'png',s:2,x:5,y:6})!=='ignored') bad.push('a window kept its own ping passed back');
       if(netPingTake(P1,{t:'png',x:'a',y:6})!=='bad') bad.push('a ping with no place was kept');
     } finally { netSend=oS; NET.role=keep.role; NET.seat=keep.seat; NET.peers=keep.peers; NET.pings=keep.pings; NET.roster=keep.roster; }
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(code==='KeyN'&&G&&!G.over&&!repeat&&NET.on) netPingMake();")<0) bad.push('N does not ping');
     if(src.indexOf("if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();")<0) bad.push('a controller cannot ping');
     return bad.length?bad.join('; '):null; }},
""")
