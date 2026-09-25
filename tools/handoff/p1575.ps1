$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # every anchor sits among LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE PARTY SEES EACH OTHER ON THE UNDERCROFT FLOOR. Multiplayer, phase 1, build 2 (tools/multiplayer/plan.md section E with
# the corrections in critique.md), his order of 2026-09-25. Raids stay solo; voice is build 3.
# 1. The PARTY window blurb says the others walk the floor with you.
# 2. VER 15.74 to 15.75.
# 3. updateHubWorld calls netHubTick(dt) while a party is on, ahead of the window test, so a man reading the PARTY window at
#    the lift is still seen.
# 4. drawHubWorld puts each of the party into its y-sorted list (netDrawPeers), draws each with drawOp (netDrawPeer), and names
#    them over the darkness (netDrawTags). All three are called only while NET.on.
# 5. The net section: floor fields on NET, a second negotiated data channel (id 1, unordered, never resent) on every link and
#    closed with it, 'st' position messages through netOnMsg, the floor list cleared by netReset, the floor code itself, and
#    the ?netslot test handle reads where a copy stands and where it draws the others.
# Solo play is untouched: every new call site is behind NET.on, and nothing new draws from the seeded stream.

SubRx @'
  <div class="msub">Up to four pillagers, linked by invite code. This first step only links your copies of the game: you see who is in your party here, and every raid is still played alone.</div>
'@ @'
  <div class="msub">Up to four pillagers, linked by invite code. The others in your party walk the Undercroft floor with you, with their names over their heads, and every raid is still played alone.</div>
'@

SubRx @'
var VER='15.74';
'@ @'
var VER='15.75';
'@

SubRx @'
  if(hubModalOpen()){ p.moving=false; HB.near=null; return; }
'@ @'
  // v15.75, HIS ORDER OF 2026-09-25 (multiplayer, build 2): WHERE HE STANDS GOES TO THE PARTY, and the others ease toward
  // where they last said they stood. Ahead of the window test, so a man reading the PARTY window at the lift is still seen.
  // Solo play never gets here: NET.on is false until HOST A PARTY or JOIN A PARTY is pressed.
  if(NET.on) netHubTick(dt);
  if(hubModalOpen()){ p.moving=false; HB.near=null; return; }
'@

SubRx @'
  DR.push({k:p.y-((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y)*0.5:0),pl:1});
  DR.sort(function(a,b){return a.k-b.k;});
'@ @'
  DR.push({k:p.y-((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y)*0.5:0),pl:1});
  // v15.75 (multiplayer, build 2): the party, sorted with the walls, the posts, the crowd and him. Only while a party is on.
  if(NET.on) netDrawPeers(DR);
  DR.sort(function(a,b){return a.k-b.k;});
'@

SubRx @'
    } else {
      // THE CROWD, v6.54. Behind him in the draw order and idle: a slow bob, and the
'@ @'
    } else if(it.np){
      // v15.75 (multiplayer, build 2): one of the party. Only netDrawPeers puts one in this list, and only while a party is on.
      netDrawPeer(it.np);
    } else {
      // THE CROWD, v6.54. Behind him in the draw order and idle: a slow bob, and the
'@

SubRx @'
  hubStationNames(S,ox,oy);
'@ @'
  hubStationNames(S,ox,oy);
  if(NET.on) netDrawTags(S,ox,oy);   // v15.75: the party names, over the darkness like the station names
'@

SubRx @'
  code:'',reply:'',codeLen:0,busy:false,status:'',err:''};
'@ @'
  code:'',reply:'',codeLen:0,busy:false,status:'',err:'',
  floor:[],hubAcc:0,hubN:0,lkSent:''};   // v15.75: who stands where on the floor, by seat, and the send clock
'@

SubRx @'
  peer.dc.onclose=function(){ netDrop(peer,'closed'); };
'@ @'
  peer.dc.onclose=function(){ netDrop(peer,'closed'); };
  // v15.75 (multiplayer, build 2): A SECOND CHANNEL, id 1, for where everyone stands on the floor. Unordered and never resent,
  // so a lost packet is replaced by the next one a tenth of a second later instead of holding up the queue behind it. It is
  // negotiated like the first, so the invite code does not grow. What it carries goes through the same netOnMsg.
  try{
    peer.fc=pc.createDataChannel('fast',{negotiated:true,id:1,ordered:false,maxRetransmits:0});
    peer.fc.onmessage=function(ev){ netOnMsg(peer,ev.data); };
  }catch(e){ peer.fc=null; }
'@

SubRx @'
  try{ if(peer.dc){ peer.dc.onopen=null; peer.dc.onmessage=null; peer.dc.onclose=null; peer.dc.close(); } }catch(e){}
'@ @'
  try{ if(peer.dc){ peer.dc.onopen=null; peer.dc.onmessage=null; peer.dc.onclose=null; peer.dc.close(); } }catch(e){}
  try{ if(peer.fc){ peer.fc.onmessage=null; peer.fc.close(); } }catch(e3){}   // v15.75: the floor channel goes with the link
'@

SubRx @'
  if(!m||typeof m!=='object'||typeof m.t!=='string') return 'bad';
'@ @'
  if(!m||typeof m!=='object'||typeof m.t!=='string') return 'bad';
  // v15.75 (multiplayer, build 2): where one of the party stands, on either side of the star. The roles below never see it.
  if(m.t==='st') return netOnState(peer,m);
'@

SubRx @'
  NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[]; NET.code=''; NET.reply=''; NET.codeLen=0; NET.busy=false;
'@ @'
  NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[]; NET.code=''; NET.reply=''; NET.codeLen=0; NET.busy=false;
  NET.floor=[]; NET.hubAcc=0; NET.hubN=0; NET.lkSent='';   // v15.75: nobody is left standing on the floor
'@

SubRx @'
function netRefresh(){ var m=document.getElementById('partymodal'); if(m&&m.classList.contains('on')) renderParty(); }
'@ @'
function netRefresh(){ var m=document.getElementById('partymodal'); if(m&&m.classList.contains('on')) renderParty(); }
// v15.75, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 2 OF PHASE 1. THE PARTY SEES EACH OTHER ON THE UNDERCROFT FLOOR.
// (tools/multiplayer/plan.md section E, build 2, with the corrections in critique.md.)
//   WHAT GOES OUT. About ten times a second each copy in a party sends where its man stands: x, y, facing, walking or not,
//   and what is left of a roll; and in its first packet, once a second after that and whenever it changes, what he is
//   wearing, one rack id per kind. A friend sends to the host. The host sends its own under seat 0 and passes each friend on
//   to the others, never back to him, filed under the seat the host gave his link: a seat a friend claims is never read.
//   THE CHANNEL. The second data channel, id 1, unordered and never resent. A link without it open uses the reliable one.
//   WHAT IS DRAWN. Each of the others is drawn with drawOp, the body the crowd and the pillagers use, dressed from his own
//   racks, eased toward where he last said he stood (the first word from him, a jump past 160 units or a word after three
//   seconds of silence puts him there at once), sorted into the floor with the walls, the crowd and the player, and named
//   over his head above the darkness, like the station names. Nobody is drawn who is not in the roster, and nobody who has
//   said nothing for three seconds (up top in a raid, or his window hidden). A bye or a lost link takes his seat out of the
//   roster, and the next floor tick takes him off the floor.
// SOLO PLAY IS UNTOUCHED. The floor calls in here only while NET.on, so a solo frame draws, sends and changes nothing new.
// Nothing here draws from the seeded stream (rr, rnd, ri, pick, rollTable) or reads G.
var NET_HUB_STEP=0.1, NET_HUB_SNAP=160, NET_HUB_STALE=3, NET_HUB_EASE=12;
var NET_LOOK=['hair','hat','skin','fit','cut','beard','eyes','face','boots','gloves','pack','patch','tattoo','outfit'];
// What he is wearing, one rack id per kind, read the way his own body is drawn.
function netLook(){
  var lk={}, i;
  for(i=0;i<NET_LOOK.length;i++) lk[NET_LOOK[i]]=cosWorn(NET_LOOK[i]);
  return lk;
}
// A look off the wire keeps only ids the racks know, each under its own kind, so nothing from another copy reaches drawOp
// but a real rack id. Owning it is his business, on his own copy.
function netLookClean(lk){
  var out={}, i, k, v, c;
  if(!lk||typeof lk!=='object') return null;
  for(i=0;i<NET_LOOK.length;i++){
    k=NET_LOOK[i]; v=netClean(lk[k],24); c=v?cosFind(v):null;
    if(c&&c.kind===k) out[k]=v;
  }
  return out;
}
function netSeatName(s){
  var r=NET.roster||[], i;
  for(i=0;i<r.length;i++) if(r[i].seat===s) return r[i].name;
  return null;
}
function netInCount(){ var n=0, i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') n++; return n; }
// A floor packet goes on the fast channel when it is open, and on the reliable one when it is not.
function netSendFast(peer,msg){
  if(!peer||peer.state!=='in') return false;
  if(peer.fc&&peer.fc.readyState==='open'){ try{ peer.fc.send(JSON.stringify(msg)); return true; }catch(e){ return false; } }
  return netSend(peer,msg);
}
// A position: from a friend, on the host, filed under the seat of his link and passed on to the others; or passed on by the
// host, on a friend, filed under the seat it names. Returns what it did, so a check can read the answer.
function netOnState(peer,m){
  var s, x, y, f, g, lk, out, i;
  if(peer.state!=='in') return 'ignored';
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  if(NET.role==='host') s=peer.seat;
  else if(NET.role==='join'){
    if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
    s=m.s;
  } else return 'off';
  if(s<0||s>=NET.max||s===NET.seat||netSeatName(s)===null) return 'ignored';
  x=clamp(m.x,0,HUBW); y=clamp(m.y,0,HUBH);
  f=(typeof m.f==='number'&&isFinite(m.f)&&m.f>-100&&m.f<100)?m.f:0;
  f=f-6.2832*Math.floor(f/6.2832);
  lk=(m.lk!==undefined)?netLookClean(m.lk):null;
  g=NET.floor[s]||null;
  if(!g){ g={seat:s,x:x,y:y,f:f,tx:x,ty:y,tf:f,mv:0,roll:0,bob:0,age:0,n:0,lk:null}; NET.floor[s]=g; }
  else if(g.age>=NET_HUB_STALE||Math.sqrt((x-g.x)*(x-g.x)+(y-g.y)*(y-g.y))>NET_HUB_SNAP){ g.x=x; g.y=y; g.f=f; }
  g.tx=x; g.ty=y; g.tf=f; g.mv=m.m?1:0; g.roll=clamp(+m.r||0,0,0.38); g.age=0; g.n++;
  if(lk) g.lk=lk;
  if(NET.role==='host'){
    out={t:'st',s:s,x:+x.toFixed(1),y:+y.toFixed(1),f:+f.toFixed(2),m:g.mv,r:+g.roll.toFixed(2)};
    if(lk) out.lk=lk;
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSendFast(NET.peers[i],out);
  }
  return 'state';
}
// Called from updateHubWorld while a party is on, every floor frame, with the PARTY window open or not. Eases the others
// toward where they last said they stood, takes anyone who left the roster off the floor, and about ten times a second sends
// where he stands. Returns how many links it sent to.
function netHubTick(dt){
  if(!NET.on) return 0;
  if(!isFinite(dt)||dt<0) dt=0;
  var k=1-Math.exp(-NET_HUB_EASE*dt), i, g, dx, dy, da, sp, p, msg, lk, ls, sent=0;
  for(i=0;i<NET.floor.length;i++){
    g=NET.floor[i]; if(!g) continue;
    if(g.seat===NET.seat||netSeatName(g.seat)===null){ NET.floor[i]=null; continue; }
    g.age+=dt;
    dx=(g.tx-g.x)*k; dy=(g.ty-g.y)*k;
    g.x+=dx; g.y+=dy;
    da=g.tf-g.f;
    if(da>Math.PI) da-=6.2832; else if(da<-Math.PI) da+=6.2832;
    g.f+=da*k; g.f=g.f-6.2832*Math.floor(g.f/6.2832);
    sp=(dt>0)?Math.sqrt(dx*dx+dy*dy)/dt:0;
    g.bob+=dt*(g.mv?((sp>200)?15:9):1.2);
    if(g.roll>0) g.roll=Math.max(0,g.roll-dt);
  }
  p=(typeof HB!=='undefined'&&HB)?HB.player:null;
  if(!p||!netInCount()) return 0;
  NET.hubAcc+=dt;
  if(NET.hubAcc<NET_HUB_STEP) return 0;
  NET.hubAcc=Math.min(NET.hubAcc-NET_HUB_STEP,NET_HUB_STEP);
  msg={t:'st',x:+(+p.x||0).toFixed(1),y:+(+p.y||0).toFixed(1),f:+(+p.face||0).toFixed(2),m:p.moving?1:0,r:(p.rollT>0)?+(+p.rollT).toFixed(2):0};
  if(NET.role==='host') msg.s=NET.seat;   // a friend names no seat: the host files him under the seat of his link
  lk=netLook(); ls=JSON.stringify(lk);
  if(ls!==NET.lkSent||NET.hubN%10===0){ msg.lk=lk; NET.lkSent=ls; }
  NET.hubN++;
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&netSendFast(NET.peers[i],msg)) sent++;
  return sent;
}
function netShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null; }
// Called from drawHubWorld while a party is on: each of the others goes into the y-sorted floor list, and the list draws
// him with netDrawPeer. Returns how many went in.
function netDrawPeers(DR){
  var i, g, n=0;
  if(!NET.on||!DR) return 0;
  for(i=0;i<NET.floor.length;i++){ g=NET.floor[i]; if(netShown(g)){ DR.push({k:g.y,np:g}); n++; } }
  return n;
}
// One of the party: the body the crowd and the pillagers use, in his own fit and racks, walking, standing or rolling as he
// said. Wrapped, because a fault in one body must never cost the frame.
function netDrawPeer(g){
  try{
    var lk=g.lk||{}, fit=FITCOL[lk.fit]||FITCOL.slate, rl=g.roll>0;
    drawOp(g.x,g.y,g.f,rl?(1-g.roll/0.38)*12.6:g.bob,fit[1],0,0,rl?'roll':'none',0,
      {hero:0,moving:!!g.mv,sprint:false,ads:false,hurt:0,rl:0,
       skin:lk.skin,hair:lk.hair,hat:lk.hat,cut:lk.cut,beard:lk.beard,eyes:lk.eyes,faceMark:lk.face,boots:lk.boots,
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit,own:g});
  }catch(e){}
}
// Their names over their heads, drawn after the darkness like the station names, with the same camera.
function netDrawTags(S,ox,oy){
  var i, g, nm, tw, n=0;
  if(!NET.on) return 0;
  wc.save();
  try{
    wc.scale(S,S); wc.translate(-ox,-oy);
    wc.textAlign='center'; wc.font=FS(TYPE.micro);
    for(i=0;i<NET.floor.length;i++){
      g=NET.floor[i]; if(!netShown(g)) continue;
      nm=netSeatName(g.seat)||'PILLAGER';
      tw=wc.measureText(nm).width;
      wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62,tw+8,13);
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52);
      n++;
    }
  }catch(e){}
  wc.textAlign='left';
  wc.restore();
  return n;
}
// Where the others stand on this floor, for the test page handle.
function netFloorView(){
  var out=[], i, g;
  for(i=0;i<NET.floor.length;i++){ g=NET.floor[i]; if(g) out.push({seat:g.seat,name:netSeatName(g.seat),x:g.x,y:g.y,tx:g.tx,ty:g.ty,n:g.n,shown:netShown(g)}); }
  return out;
}
'@

SubRx @'
      reset:function(){ netReset(); }};
'@ @'
      reset:function(){ netReset(); },
      // v15.75: where this copy stands, where it draws the others, and how many fast channels are open.
      me:function(){ var q=(typeof HB!=='undefined'&&HB)?HB.player:null; return q?{x:q.x,y:q.y,face:q.face||0,seat:NET.seat}:null; },
      floor:function(){ return netFloorView(); },
      fast:function(){ var c=0, j; for(j=0;j<NET.peers.length;j++) if(NET.peers[j].fc&&NET.peers[j].fc.readyState==='open') c++; return c; }};
'@

$pat = "(?m)^  now:'v15\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.75: THE PARTY SEES EACH OTHER ON THE UNDERCROFT FLOOR. Multiplayer build 2. Every copy in a party sends where its man stands about ten times a second on a second channel that never resends, the host passes each friend on to the others, and each of the others is drawn on the floor with the same body the crowd uses, dressed from his own racks, eased between packets, sorted with everyone else and named over his head. A bye or a lost link takes him off the floor. Solo play is untouched: the floor calls the net code only while a party is on, so a solo frame draws, sends and changes nothing new, and the net code never draws from the seeded stream. Check 15.75 fails on v15.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
