import os, gen
from gen import patch, fixture
HOSTFWD = "  if(NET.role==='host'){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'png',s:s,x:o.x,y:o.y,w:o.w,id:o.id}); }"
LBL = "    lbl=nm+(p.w?(': '+p.w):'')+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'M';"
patch(1646, [
# controller: tap D-UP pings (co-op) or opens the map (solo); hold D-UP opens the map
("""  if(pressed(12)&&!bagNav&&!PAD.prev[12]&&G&&!G.over) G.mapOpen=!G.mapOpen;""",
"""  // v16.46, HIS ORDER: PING ON D-PAD UP. A tap pings for the party (in solo it opens and shuts the map as before); a hold of 0.4 s
  // opens or shuts the map; a tap with the map open shuts it.
  (function(){
    var du=pressed(12)&&!bagNav&&G&&!G.over, now=netPadNow();
    if(du&&!PAD.prev[12]){ PAD.duAt=now; PAD.duHeld=0; }
    if(du&&PAD.duAt!=null&&!PAD.duHeld&&now-PAD.duAt>=0.4){ PAD.duHeld=1; G.mapOpen=!G.mapOpen; }
    if(!du&&PAD.prev[12]&&PAD.duAt!=null&&!PAD.duHeld&&G&&!G.over){
      if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;
    }
    if(!du) PAD.duAt=null;
  })();"""),
("""  if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();   // v16.43: both bumpers ping; the two belt steps cancel""",
"""  // v16.46: the ping moved to D-UP on his order; both bumpers no longer ping."""),
("""  ['D-UP','map'],['MENU','pause']""",
"""  ['D-UP','ping, hold: map'],['MENU','pause']"""),
("""  ['WORLD',[['X','search / call for extraction'],['DPAD UP','map'],['MENU','pause']]]""",
"""  ['WORLD',[['X','search / call for extraction'],['DPAD UP','ping (twice: danger); hold: map'],['MENU','pause']]]"""),
# ping: 10 s as Fortnite; on the open map it is your marker; a second press within 0.4 s is DANGER
("""var NET_PING_T=8, NET_PING_SNAP=70;""",
"""var NET_PING_T=10, NET_PING_SNAP=70;   // v16.46: 10 s, the length Fortnite gives a ping"""),
("""  NET.pingAt=Date.now();""",
"""  if(G.mapOpen) return netWpFromMap();   // v16.46: a ping on the open map is your map marker, as in Fortnite
  if(NET.pingAt&&Date.now()-NET.pingAt<400){   // v16.46: pressed twice, the last ping becomes DANGER
    if(NET.pingLast&&!NET.pingLast.dg){ NET.pingLast.dg=1; netBroadcast(NET.pingLast); netPingPush(NET.seat,NET.pingLast); }
    return NET.pingLast||null;
  }
  NET.pingAt=Date.now();"""),
("""  netPingPush(NET.seat,m);""",
"""  NET.pingLast=m;
  netPingPush(NET.seat,m);"""),
("""  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24)};""",
"""  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24),dg:m.dg?1:0};"""),
(HOSTFWD, HOSTFWD.replace("id:o.id}","id:o.id,dg:o.dg}")),
("""  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,at:Date.now()});""",
"""  if(o.dg){ var _pi; for(_pi=NET.pings.length-1;_pi>=0;_pi--) if(NET.pings[_pi].s===s&&Math.abs(NET.pings[_pi].x-o.x)<2&&Math.abs(NET.pings[_pi].y-o.y)<2) NET.pings.splice(_pi,1); }
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,at:Date.now()});"""),
("""    c=p.w?'#ff8a3c':'#6fe0ff';""",
"""    c=p.dg?'#ff4a3a':(p.w?'#ff8a3c':'#6fe0ff');"""),
(LBL, "    lbl=nm+(p.w?(': '+p.w):(p.dg?': DANGER':''))+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'M';"),
("""  if(!NET.pings||!NET.pings.length) return 0;""",
"""  netWpDraw();   // v16.46: the party's map markers, in the world
  if(!NET.pings||!NET.pings.length) return 0;"""),
# map markers shared
("""        blip('pick'); say('Waypoint marked');""",
"""        blip('pick'); say('Waypoint marked');
        try{ if(NET.on) netWpSend(); }catch(_ws){}   // v16.46: your party sees your map marker"""),
("""    if(e.button===2){ G.waypoint=null; say('Waypoint cleared'); return; }""",
"""    if(e.button===2){ G.waypoint=null; say('Waypoint cleared'); try{ if(NET.on) netWpSend(); }catch(_wc){} return; }"""),
("""  if(G.waypoint){""",
"""  try{ if(NET.on) netWpMapDraw(ox,oy,sc); }catch(_wm){}   // v16.46: the party's map markers on the map
  if(G.waypoint){"""),
("""  if(m.t==='png') return netPingTake(peer,m);   // v16.43: a ping from one of the party""",
"""  if(m.t==='png') return netPingTake(peer,m);   // v16.43: a ping from one of the party
  if(m.t==='wp') return netWpTake(peer,m);   // v16.46: a teammate map marker"""),
("""      ping:function(){ return netPingMake(); },""",
"""      ping:function(){ return netPingMake(); },
      wps:function(){ return JSON.parse(JSON.stringify(NET.wps||{})); },
      mark:function(x,y){ if(typeof G==='undefined'||!G) return false; G.waypoint={x:+x,y:+y}; return netWpSend(); },"""),
("""var NET_FEED_T=6;""",
"""var NET_FEED_T=6;
// v16.46, HIS ASK: A MAP MARKER THE OTHER PLAYER CAN SEE, AND HOW IT MEETS THE PING (Fortnite's rule). The map marker is yours
// and lasts until you clear it or place another: set by a click on the map, or by pinging while the map is open. Your party sees
// it on their map and in the world, with your name and how far it is. A ping is short (10 s) and says look here, now; pressed
// twice it says DANGER. One marker per player.
function netWpSend(){
  var w;
  if(typeof NET!=='object'||!NET||!NET.on) return false;
  w=(typeof G!=='undefined'&&G)?G.waypoint:null;
  netBroadcast(w?{t:'wp',x:Math.round(w.x),y:Math.round(w.y)}:{t:'wp',clr:1});
  return true;
}
function netWpTake(peer,m){
  var s, i, o;
  if(!peer||peer.state!=='in') return 'ignored';
  if(NET.role==='host') s=peer.seat; else { s=(m.s===undefined)?0:m.s; if(typeof s!=='number'||s!==(s|0)) return 'bad'; }
  if(s===NET.seat) return 'ignored';
  if(!NET.wps) NET.wps={};
  if(m.clr) delete NET.wps[s];
  else { if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad'; NET.wps[s]={x:clamp(m.x,0,WORLD_W),y:clamp(m.y,0,WORLD_H)}; }
  if(NET.role==='host'){ o=m.clr?{t:'wp',s:s,clr:1}:{t:'wp',s:s,x:NET.wps[s].x,y:NET.wps[s].y}; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],o); }
  try{ if(typeof G!=='undefined'&&G&&!G.sim&&!m.clr) blip('pick'); }catch(_b){}
  return m.clr?'wp:clr':'wp';
}
function netWpFromMap(){
  var MP=mapProj(), w;
  if(!(mouse.x>=MP.ox&&mouse.x<=MP.ox+WORLD_W*MP.sc&&mouse.y>=MP.oy&&mouse.y<=MP.oy+WORLD_H*MP.sc)) return null;
  w=mapScreenToWorld(mouse.x,mouse.y);
  G.waypoint={x:clamp(w.x,0,WORLD_W),y:clamp(w.y,0,WORLD_H)};
  blip('pick'); say('Marker placed. Your party can see it.');
  netWpSend();
  return G.waypoint;
}
function netWpDraw(){
  var s, w, q, x, y, M=LH(30), nm, n=0;
  if(!NET.wps) return 0;
  for(s in NET.wps){
    if(!Object.prototype.hasOwnProperty.call(NET.wps,s)) continue;
    w=NET.wps[s]; q=w2s(w.x,0,w.y); if(!q) continue;
    x=clamp(q.x,M,W-M); y=clamp(q.y,M,H-M);
    ctx.strokeStyle='#bfe0ff'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(x,y,LH(9),0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(x-LH(14),y); ctx.lineTo(x-LH(4),y); ctx.moveTo(x+LH(4),y); ctx.lineTo(x+LH(14),y); ctx.moveTo(x,y-LH(14)); ctx.lineTo(x,y-LH(4)); ctx.moveTo(x,y+LH(4)); ctx.lineTo(x,y+LH(14)); ctx.stroke();
    nm=netSeatName(+s)||'PILLAGER';
    ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle='#bfe0ff';
    ctx.fillText(nm+' MARKER  '+((G&&G.player)?metres(dist(G.player,w)):0)+'M',clamp(x,LH(70),W-LH(70)),y-LH(18)); ctx.textAlign='left';
    n++;
  }
  return n;
}
function netWpMapDraw(ox,oy,sc){
  var s, w, px, py, n=0, i, p;
  if(NET.wps) for(s in NET.wps){
    if(!Object.prototype.hasOwnProperty.call(NET.wps,s)) continue;
    w=NET.wps[s]; px=ox+w.x*sc; py=oy+w.y*sc;
    ctx.strokeStyle='#bfe0ff'; ctx.lineWidth=2; ctx.beginPath(); ctx.arc(px,py,7,0,6.2832); ctx.stroke();
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#bfe0ff'; ctx.fillText(netSeatName(+s)||'PILLAGER',px+10,py+4);
    n++;
  }
  for(i=0;i<(NET.pings||[]).length;i++){   // live pings show on the map too
    p=NET.pings[i]; px=ox+p.x*sc; py=oy+p.y*sc;
    ctx.fillStyle=p.dg?'#ff4a3a':(p.w?'#ff8a3c':'#6fe0ff'); ctx.beginPath(); ctx.moveTo(px,py-6); ctx.lineTo(px+5,py); ctx.lineTo(px,py+6); ctx.lineTo(px-5,py); ctx.closePath(); ctx.fill();
  }
  return n;
}"""),
("""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp; NET.sum={};""",
"""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp; NET.sum={}; NET.wps={}; NET.pings=[];"""),
("""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp; NET.sum={};""",
"""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp; NET.sum={}; NET.wps={}; NET.pings=[];"""),
], "PING ON D-PAD UP, SHARED MAP MARKERS, DANGER PINGS. His orders: ping on d-pad up; a map marker the other player can see; read the Fortnite ping and map practice. Tap D-UP pings (solo: map as before), hold D-UP 0.4 s for the map; both bumpers no longer ping. The map marker (a click on the map, or a ping with the map open) is sent to the party and shown on their map and in the world with the owner name and distance, until cleared or replaced. A ping lasts 10 s, shows on the map too, and pressed twice becomes DANGER in red. Check 16.46 fails on v16.45",
"# PING ON D-PAD UP, SHARED MAP MARKERS, DANGER PINGS (his orders; Fortnite's practice).\n")
fixture(1646, r"""  {v:'16.46',what:'map markers reach the party through the host and clear; a danger ping replaces the plain one; D-UP pings and holds for the map',
   run:function(){
     if(typeof netWpTake!=='function'||typeof netWpSend!=='function') return 'this build shares no map marker';
     var keep={role:NET.role,seat:NET.seat,peers:NET.peers,wps:NET.wps,pings:NET.pings,roster:NET.roster}, oS=netSend, sent=[], bad=[], r;
     try{
       netSend=function(q,m){ sent.push(m); return true; };
       var P1={state:'in',seat:1}, P2={state:'in',seat:2};
       NET.role='host'; NET.seat=0; NET.peers=[P1,P2]; NET.wps={}; NET.pings=[]; NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'},{seat:2,name:'REED'}];
       r=netWpTake(P1,{t:'wp',x:300,y:400});
       if(r!=='wp'||!NET.wps[1]||NET.wps[1].x!==300) bad.push('the host did not keep the marker from seat 1 ('+r+')');
       if(sent.length!==1||sent[0].s!==1||sent[0].x!==300) bad.push('the host did not pass the marker on ('+JSON.stringify(sent)+')');
       r=netWpTake(P1,{t:'wp',clr:1});
       if(r!=='wp:clr'||NET.wps[1]) bad.push('a cleared marker stayed');
       netPingPush(1,{x:10,y:10,w:''}); netPingPush(1,{x:10,y:10,w:'',dg:1});
       if(NET.pings.length!==1||!NET.pings[0].dg) bad.push('a danger ping did not replace the plain one ('+JSON.stringify(NET.pings)+')');
     } finally { netSend=oS; NET.role=keep.role; NET.seat=keep.seat; NET.peers=keep.peers; NET.wps=keep.wps; NET.pings=keep.pings; NET.roster=keep.roster; }
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;")<0) bad.push('D-UP does not ping');
     if(src.indexOf("if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&G&&!G.over&&NET.on) netPingMake();")>=0) bad.push('both bumpers still ping');
     return bad.length?bad.join('; '):null; }},
""")
