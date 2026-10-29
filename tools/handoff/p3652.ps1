$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# PING AND MAP MARK ARE ONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netWpSend(){
  var w;
  if(typeof NET!=='object'||!NET||!NET.on) return false;
  w=(typeof G!=='undefined'&&G)?G.waypoint:null;
  netBroadcast(w?{t:'wp',x:Math.round(w.x),y:Math.round(w.y)}:{t:'wp',clr:1});
  return true;
}
'@ @'
// v28.xx (cw-cx-onemark), his order: "the two need to become the same thing". Waypoint callers use the same mark record and png word.
function netMarkSet(x,y){
  if(typeof G==='undefined'||!G||!isFinite(x)||!isFinite(y)) return null;
  var m={t:'png',x:Math.round(clamp(x,0,WORLD_W)),y:Math.round(clamp(y,0,WORLD_H)),w:'',spot:1};
  netPingPush(NET.seat,m); NET.pingLast=m; NET.pingTarget=null; NET.pingAt=Date.now();
  if(NET.on) netBroadcast(m);
  return G.waypoint;
}
function netMarkClear(){
  netPingPush(NET.seat,{clr:1}); NET.pingLast=null; NET.pingTarget=null; NET.pingAt=0;
  if(NET.on) netBroadcast({t:'png',clr:1});
  return true;
}
function netMarkColour(s){return +s<=0?'#ffc04a':'#6fe0ff';}
function netWpSend(){
  var w=(typeof G!=='undefined'&&G)?G.waypoint:null;
  if(w) netMarkSet(w.x,w.y); else netMarkClear();
  return !!NET.on;
}
'@

SubRx @'
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
'@ @'
// v28.xx (cw-cx-onemark): accept the old map word for late arrival; keep entity identity and remaining time in that snapshot.
function netWpTake(peer,m){
  var r=netPingTake(peer,{s:m.s,x:m.x,y:m.y,w:m.w,id:m.id,dg:m.dg,spot:m.spot===undefined?1:m.spot,age:m.age,clr:m.clr});
  return r==='png'?(m.clr?'wp:clr':'wp'):r;
}
'@

SubRx @'
function netWpFromMap(){
  var MP=mapProj(), w;
  if(!(mouse.x>=MP.ox&&mouse.x<=MP.ox+WORLD_W*MP.sc&&mouse.y>=MP.oy&&mouse.y<=MP.oy+WORLD_H*MP.sc)) return null;
  w=mapScreenToWorld(mouse.x,mouse.y);
  G.waypoint={x:clamp(w.x,0,WORLD_W),y:clamp(w.y,0,WORLD_H)};
  blip('pick'); say('WAYPOINT SET','sys',(typeof NET==='object'&&NET&&NET.on)?{sub:'Your party can see it.'}:null);   // v22.xx (R55): Waypoint, never Marker (his Marked Waypoint)
  netWpSend();
  return G.waypoint;
}
'@ @'
function netWpFromMap(){
  var MP=mapProj(), w;
  if(!(mouse.x>=MP.ox&&mouse.x<=MP.ox+WORLD_W*MP.sc&&mouse.y>=MP.oy&&mouse.y<=MP.oy+WORLD_H*MP.sc)) return null;
  w=mapScreenToWorld(mouse.x,mouse.y);
  netMarkSet(w.x,w.y); say('mark set','sys');
  return G.waypoint;
}
'@

SubRx @'
    if(e.button===2){ G.waypoint=null; say('WAYPOINT CLEARED','sys'); try{ if(NET.on) netWpSend(); }catch(_wc){} return; }   // v22.xx (R55): a system label in caps
'@ @'
    if(e.button===2){ netMarkClear(); say('mark cleared','sys'); return; }   // v28.xx (cw-cx-onemark): clear the same mark in every view and window.
'@

SubRx @'
        G.waypoint={x:clamp(wpt.x,0,WORLD_W),y:clamp(wpt.y,0,WORLD_H)};
        blip('pick'); say('WAYPOINT SET','sys');   // v22.xx (R55): a system label in caps
        try{ if(NET.on) netWpSend(); }catch(_ws){}   // v16.46: your party sees your map marker
'@ @'
        netMarkSet(wpt.x,wpt.y); say('mark set','sys');   // v28.xx (cw-cx-onemark): map clicks and raid pings move one mark.
'@

SubRx @'
function netPingMake(){
  var w, i, e, bd=NET_PING_SNAP, d, hit=null, m;
  // v28.xx (cw-cx-solopings): only a party needs a shared raid seed. No ping behind a panel, while down, or on the Undercroft floor.
  if(typeof G==='undefined'||!G||G.over||!G.player||G.hubFloor||G.sim||G.paused||G.bagOpen||G.trade||G.forgeUI||G.player.downed||G.player.dying||(NET.on&&!NET.upSeed)) return null;
  // v16.61, stability (co-op review): the double press is read BEFORE the 0.5 s limit. That limit stood first and answered
  // every press inside 0.5 s with nothing, so the 0.4 s double press the controls legend promises (twice: danger) never came.
  if(!G.mapOpen&&NET.pingAt&&Date.now()-NET.pingAt<400){   // v16.46: pressed twice, the last ping becomes DANGER
    if(NET.pingLast&&!NET.pingLast.dg){ NET.pingLast.dg=1; if(NET.on) netBroadcast(NET.pingLast); netPingPush(NET.seat,NET.pingLast,NET.pingTarget); }
    return NET.pingLast||null;
  }
  if(NET.pingAt&&Date.now()-NET.pingAt<500) return null;
  if(G.mapOpen) return netWpFromMap();   // v16.46: a ping on the open map is your map marker, as in Fortnite
  NET.pingAt=Date.now();
  w=mouseWorld();
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if((NET.on&&!e.nid)||e.hp<=0||e.merc) continue; d=dist(e,w); if(d<bd){ bd=d; hit=e; } }
  m={t:'png',x:Math.round(hit?hit.x:w.x),y:Math.round(hit?hit.y:w.y),w:hit?netPingName(hit):''};   // v17.57: the boss by its name
  if(hit) m.id=hit.nid;
  if(NET.on) netBroadcast(m);
  NET.pingLast=m;
  NET.pingTarget=NET.on?null:hit;   // v28.xx (cw-cx-solopings): solo targets have no network id; keep the local body out of the wire word.
  netPingPush(NET.seat,m,NET.pingTarget);
  return m;
}
'@ @'
function netPingMake(){
  var w, i, e, bd=NET_PING_SNAP, d, hit=null, m, own;
  // v28.xx (cw-cx-onemark): spot marks last until moved or cleared; entity pings keep their timer and double-tap danger.
  if(typeof G==='undefined'||!G||G.over||!G.player||G.hubFloor||G.sim||G.paused||G.bagOpen||G.trade||G.forgeUI||G.player.downed||G.player.dying||(NET.on&&!NET.upSeed)) return null;
  if(G.mapOpen) return netWpFromMap();
  w=mouseWorld(); netPingUpdate();
  for(i=0;i<G.ents.length;i++){e=G.ents[i];if((NET.on&&!e.nid)||e.hp<=0||e.merc)continue;d=dist(e,w);if(d<bd){bd=d;hit=e;}}
  own=G.waypoint;
  if(own&&own.spot&&dist(own,w)<=28){netMarkClear();return null;}
  if(hit&&NET.pingAt&&Date.now()-NET.pingAt<400&&NET.pingLast&&!NET.pingLast.spot){
    if(!NET.pingLast.dg){NET.pingLast.dg=1;if(NET.on)netBroadcast(NET.pingLast);netPingPush(NET.seat,NET.pingLast,NET.pingTarget);}
    return NET.pingLast;
  }
  if(hit&&NET.pingAt&&Date.now()-NET.pingAt<500) return null;
  if(!hit) return netMarkSet(w.x,w.y);
  NET.pingAt=Date.now();
  m={t:'png',x:Math.round(hit.x),y:Math.round(hit.y),w:netPingName(hit)};
  if(hit.nid) m.id=hit.nid;
  if(NET.on) netBroadcast(m);
  NET.pingLast=m; NET.pingTarget=NET.on?null:hit;
  netPingPush(NET.seat,m,NET.pingTarget);
  return m;
}
'@

SubRx @'
function netPingTake(peer,m){
  var s;
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  if(NET.role==='host') s=peer.seat; else { s=(m.s===undefined)?0:m.s; if(typeof s!=='number'||s!==(s|0)) return 'bad'; }
  if(s===NET.seat) return 'ignored';
  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24),dg:m.dg?1:0,pl:m.pl?1:0};   // v32.xx (cw-droppings): pl marks a pile ping
  if(typeof m.id==='number') o.id=m.id|0;
  if(NET.role==='host'){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'png',s:s,x:o.x,y:o.y,w:o.w,id:o.id,dg:o.dg,pl:o.pl}); }
  netPingPush(s,o);
  return 'png';
}
'@ @'
function netPingTake(peer,m){
  var s, o, i;
  if(!peer||peer.state!=='in') return 'ignored';
  if(NET.role==='host') s=peer.seat; else {s=m.s===undefined?0:m.s;if(typeof s!=='number'||s!==(s|0)||s<0||s>=NET.max)return 'bad';}
  if(s===NET.seat) return 'ignored';
  if(!m.clr&&(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y))) return 'bad';
  // v28.xx (cw-cx-onemark): the host owns the sender seat, including clears. No target objects cross the wire.
  o=m.clr?{t:'png',s:s,clr:1}:{t:'png',s:s,x:clamp(m.x,0,WORLD_W),y:clamp(m.y,0,WORLD_H),w:netClean(m.w,24),dg:m.dg?1:0,pl:m.pl?1:0,spot:m.spot?1:0};
  if(!m.clr&&typeof m.id==='number') o.id=m.id|0;
  if(!m.clr&&typeof m.age==='number'&&isFinite(m.age)) o.age=clamp(m.age,0,NET_PING_T*1000);
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],o);
  netPingPush(s,o);
  return 'png';
}
'@

SubRx @'
function netPingPush(s,o,target){
  if(!NET.pings) NET.pings=[];
  if(o.dg){ var _pi; for(_pi=NET.pings.length-1;_pi>=0;_pi--) if(NET.pings[_pi].s===s&&Math.abs(NET.pings[_pi].x-o.x)<2&&Math.abs(NET.pings[_pi].y-o.y)<2) NET.pings.splice(_pi,1); }
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,pl:o.pl?1:0,at:Date.now(),target:target||null});
  if(NET.pings.length>6) NET.pings.shift();
  try{ if(typeof G!=='undefined'&&G&&!G.sim) blip('pick'); }catch(_bp){}
  return NET.pings.length;
}
'@ @'
function netPingPush(s,o,target){
  var i,p;
  if(!NET.pings) NET.pings=[];
  // v28.xx (cw-cx-onemark): one deliberate mark per seat; automatic dropped-item notices stay separate.
  if(!o.pl) for(i=NET.pings.length-1;i>=0;i--) if(NET.pings[i].s===s&&!NET.pings[i].pl) NET.pings.splice(i,1);
  if(o.clr){
    if(NET.wps) delete NET.wps[s];
    if(s===NET.seat&&typeof G!=='undefined'&&G) G.waypoint=null;
    return NET.pings.length;
  }
  p={s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,pl:o.pl?1:0,spot:!o.pl&&(!!o.spot||(!o.id&&!target&&!o.w)),at:Date.now()-(o.age||0),target:target||null};
  NET.pings.push(p);
  if(!p.pl){
    if(s===NET.seat&&typeof G!=='undefined'&&G) G.waypoint=p;
    else {if(!NET.wps)NET.wps={};NET.wps[s]=p;}
  }
  if(NET.pings.length>6) for(i=0;i<NET.pings.length;i++) if(NET.pings[i].pl){NET.pings.splice(i,1);break;}
  try{if(typeof G!=='undefined'&&G&&!G.sim)blip('pick');}catch(_bp){}
  return NET.pings.length;
}
'@

SubRx @'
function netPingUpdate(){
  var i, p, e, now=Date.now();
  if(!NET.pings) return 0;
  for(i=NET.pings.length-1;i>=0;i--){
    p=NET.pings[i];
    if((now-p.at)/1000>NET_PING_T){ NET.pings.splice(i,1); continue; }
    e=p.target||(p.id&&NET.entMap?NET.entMap[p.id]:null);
    if(e&&e.hp>0&&G&&G.ents.indexOf(e)>=0){ p.x=e.x; p.y=e.y; }
  }
  return NET.pings.length;
}
'@ @'
function netPingUpdate(){
  var i,p,e,now=Date.now();
  if(!NET.pings) return 0;
  for(i=NET.pings.length-1;i>=0;i--){
    p=NET.pings[i];
    if(!p.spot&&(now-p.at)/1000>NET_PING_T){
      NET.pings.splice(i,1);
      if(NET.wps&&NET.wps[p.s]===p)delete NET.wps[p.s];
      if(typeof G!=='undefined'&&G&&G.waypoint===p)G.waypoint=null;
      continue;
    }
    e=p.target||(p.id&&NET.entMap?NET.entMap[p.id]:null);
    if(e&&e.hp>0&&G&&G.ents&&G.ents.indexOf(e)>=0){p.x=e.x;p.y=e.y;}
  }
  return NET.pings.length;
}
'@

SubRx @'
    w=NET.wps[s]; q=w2s(w.x,0,w.y); if(!q) continue;
'@ @'
    w=NET.wps[s]; if((NET.pings||[]).indexOf(w)>=0)continue; q=w2s(w.x,0,w.y); if(!q) continue;
'@

SubRx @'
    w=NET.wps[s]; px=ox+w.x*sc; py=oy+w.y*sc;
'@ @'
    w=NET.wps[s]; if((NET.pings||[]).indexOf(w)>=0)continue; px=ox+w.x*sc; py=oy+w.y*sc;
'@

SubRx @'
      q=NET.wps[_ws]; if(!q||!isFinite(q.x)) continue; s=at(q.x,q.y);
'@ @'
      q=NET.wps[_ws]; if(!q||!isFinite(q.x)||(NET.pings||[]).indexOf(q)>=0) continue; s=at(q.x,q.y);
'@

SubRx @'
      q=NET.pings[i]; if(!q||!isFinite(q.x)) continue; s=at(q.x,q.y); if(s.out) continue;
'@ @'
      q=NET.pings[i]; if(!q||!isFinite(q.x)||(q===G.waypoint&&q.spot)) continue; s=at(q.x,q.y);
      if(s.out){if(!q.pl)mmArrow(s,R,netMarkColour(q.s),q.s===NET.seat?'waypoint':'partywaypoint');continue;}
'@

SubRx @'
      ctx.fillStyle=q.dg?'#ff4a3a':(q.w?'#ff8a3c':'#6fe0ff');
'@ @'
      ctx.fillStyle=q.pl?'#ff8a3c':netMarkColour(q.s);
'@

SubRx @'
  if(G.waypoint&&isFinite(G.waypoint.x)){
'@ @'
  if(G.waypoint&&(!G.waypoint.at||G.waypoint.spot)&&isFinite(G.waypoint.x)){
'@

SubRx @'
    if(s.out)mmArrow(s,R,UIC.acc,'waypoint');
'@ @'
    if(s.out)mmArrow(s,R,netMarkColour(NET.seat),'waypoint');
'@

SubRx @'
      ctx.strokeStyle=UIC.acc; ctx.lineWidth=1.6*R; ctx.beginPath(); ctx.arc(s.x,s.y,4.5*R,0,6.2832);
'@ @'
      ctx.strokeStyle=netMarkColour(NET.seat); ctx.lineWidth=1.6*R; ctx.beginPath(); ctx.arc(s.x,s.y,4.5*R,0,6.2832);
'@

SubRx @'
    p=NET.pings[i]; px=ox+p.x*sc; py=oy+p.y*sc;
'@ @'
    p=NET.pings[i]; if(p===G.waypoint&&p.spot)continue; px=ox+p.x*sc; py=oy+p.y*sc;
'@

SubRx @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,2*Math.max(1,hudRes()),p.dg?'#ff4a3a':p.w?'#ff8a3c':'#6fe0ff'); // v28.xx (cw-cx-pingmerge): match the minimap 24px ping and dark backing.
'@ @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,2*Math.max(1,hudRes()),p.pl?'#ff8a3c':netMarkColour(p.s)); // v28.xx (cw-cx-onemark): the same seat colour in all three views.
'@

SubRx @'
    c=p.dg?'#ff4a3a':(p.w?'#ff8a3c':((p.s===NET.seat)?HUDC.warn:HUDC.ally));   // v22.70 (R27): a teammate ping in the teammate colour, your own in amber like your Waypoint
'@ @'
    c=p.pl?'#ff8a3c':netMarkColour(p.s);   // v28.xx (cw-cx-onemark): p1 amber, p2 cyan in either window.
'@

SubRx @'
  if(G.waypoint){
    var wpx=
'@ @'
  if(G.waypoint&&(!G.waypoint.at||G.waypoint.spot)){
    var wpx=
'@

SubRx @'
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(wpx
'@ @'
    ctx.strokeStyle=netMarkColour(NET.seat); ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(wpx
'@

SubRx @'
    ctx.fillText('WAYPOINT',wpx,wpy-14*_MZ); ctx.textAlign='left';
'@ @'
    ctx.fillText('mark',wpx,wpy-14*_MZ); ctx.textAlign='left';
'@

SubRx @'
    _tgt=G.waypoint; _lbl='WAYPOINT'; _col='#ffc04a';
'@ @'
    _tgt=G.waypoint; _lbl='mark'; _col=netMarkColour(NET.seat);
'@

SubRx @'
'R STICK move marker
'@ @'
'R STICK move mark
'@

SubRx @'
D-UP place marker'
'@ @'
D-UP set mark'
'@

SubRx @'
'CLICK set waypoint
'@ @'
'CLICK set mark
'@

SubRx @'
'CLICK to set a waypoint'
'@ @'
'CLICK to set a mark'
'@

SubRx @'
['KeyN','ping'],['Mouse1','ping (mouse)']
'@ @'
['KeyN','mark'],['Mouse1','mark (mouse)']
'@

SubRx @'
[12,'ping (hold: the map)','WORLD']
'@ @'
[12,'mark (hold: the map)','WORLD']
'@

SubRx @'
[n(12),'ping (twice: danger); hold: map']
'@ @'
[n(12),'mark; hold: map']
'@

SubRx @'
[n(12),'ping, twice for danger']
'@ @'
[n(12),'mark']
'@

SubRx @'
'ping / map'
'@ @'
'mark / map'
'@

SubRx @'
[b(12),'ping, hold: map']
'@ @'
[b(12),'mark, hold: map']
'@

SubRx @'
s('Mouse1')+' ping &nbsp; '
'@ @'
s('Mouse1')+' mark &nbsp; '
'@

SubRx @'
to ping a spot or an enemy for your party;
'@ @'
to mark a spot or an enemy;
'@

SubRx @'
+' WAYPOINT  '+
'@ @'
+' mark  '+
'@

SubRx @'
  if(G.waypoint&&typeof G.waypoint.x==='number') netSend(peer,{t:'wp',x:Math.round(G.waypoint.x),y:Math.round(G.waypoint.y)});
'@ @'
  netPingUpdate();
  if(G.waypoint&&typeof G.waypoint.x==='number') netSend(peer,{t:'wp',x:Math.round(G.waypoint.x),y:Math.round(G.waypoint.y),w:G.waypoint.w,id:G.waypoint.id,dg:G.waypoint.dg,spot:G.waypoint.spot===false?0:1,age:G.waypoint.at?Date.now()-G.waypoint.at:0});
'@

SubRx @'
  if(NET.wps) for(id in NET.wps) if(Object.prototype.hasOwnProperty.call(NET.wps,id)&&(id|0)!==peer.seat&&NET.wps[id]&&typeof NET.wps[id].x==='number') netSend(peer,{t:'wp',s:id|0,x:Math.round(NET.wps[id].x),y:Math.round(NET.wps[id].y)});
'@ @'
  if(NET.wps) for(id in NET.wps) if(Object.prototype.hasOwnProperty.call(NET.wps,id)&&(id|0)!==peer.seat&&NET.wps[id]&&typeof NET.wps[id].x==='number'){var lateMark=NET.wps[id];netSend(peer,{t:'wp',s:id|0,x:Math.round(lateMark.x),y:Math.round(lateMark.y),w:lateMark.w,id:lateMark.id,dg:lateMark.dg,spot:lateMark.spot===false?0:1,age:lateMark.at?Date.now()-lateMark.at:0});}
'@

SubRx @'
var VER='36.51';
'@ @'
var VER='36.52';
'@

$pat = "(?m)^  now:'v36\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.52: Middle mouse, N, pad and map clicks move one mark. Ping your spot again or right click the map to clear it everywhere. Check 36.52 fails on v36.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
