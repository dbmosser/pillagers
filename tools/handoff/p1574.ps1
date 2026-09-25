$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# TWO COPIES OF THE GAME LINK UP BY INVITE CODE. Multiplayer, phase 1, build 1 (tools/multiplayer/plan.md section E with the
# corrections in critique.md), his order of 2026-09-25. Text only: no voice and no drawing of the others yet.
# 1. CSS and HTML for a PARTY window, framed like the Terms.
# 2. ?netslot=A or ?netslot=B gives a copy a save of its own (salvagerun:profile:netA or :netB, its crash list beside it); such a
#    copy never writes salvagerun:activeSlot. salvagerun:profile and the save slots keep their keys and format.
# 3. F at the lift opens the PARTY window (F is free at the lift; Y on a controller).
# 4. One NET section: a host-authoritative star for up to four, invite and reply codes (deflate-raw plus base64url behind PTY1),
#    a reliable data channel carrying hello, welcome, reject, roster and bye, STUN only. Nothing runs until HOST or JOIN is
#    pressed, and the net code never draws from the seeded stream and never touches a raid.

SubRx @'
  #termsmodal .plist{ flex:0 1 auto; }
'@ @'
  #termsmodal .plist{ flex:0 1 auto; }
  /* v15.74: THE PARTY WINDOW, framed like the Terms. It scrolls inside itself, so a small window can still reach the codes. */
  #partymodal{ align-items:center; justify-content:center; justify-content:safe center; overflow-y:auto; }
  #partymodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(760px,calc(100% - 28px)); transform:translate(-50%,-50%); }
  #partymodal .msub, #partymodal .plist, #partymodal .pbox{ max-width:1060px; width:100%; }
  #partymodal .plist{ flex:0 0 auto; }
  #partymodal textarea{ font-family:ui-monospace,Consolas,monospace; font-size:12px; word-break:break-all; }
'@

SubRx @'
    <button id="termsclear" style="padding:8px 22px">Sign nothing</button>
    <button id="closeterms" style="padding:8px 22px">CLOSE</button>
  </div>
</div>
'@ @'
    <button id="termsclear" style="padding:8px 22px">Sign nothing</button>
    <button id="closeterms" style="padding:8px 22px">CLOSE</button>
  </div>
</div>

<!-- v15.74, HIS ORDER OF 2026-09-25: THE PARTY WINDOW, multiplayer build 1. F at the lift opens it. Nothing in it touches the
     network until HOST A PARTY or JOIN A PARTY is pressed, and closing it keeps the party. No button but CLOSE carries a word
     controller B looks for (leave, close, back, done, return), so B always closes the window and never ends the party. -->
<div class="modal" id="partymodal">
  <h3>Party</h3>
  <div class="msub">Up to four pillagers, linked by invite code. This first step only links your copies of the game: you see who is in your party here, and every raid is still played alone.</div>
  <div class="msub" id="partystat" style="color:var(--amber);font-weight:700"></div>
  <div class="msub" id="partyerr" style="color:var(--hazard);font-weight:700;display:none"></div>
  <div class="plist" id="partyroster" style="border:1px solid var(--steel-hi);display:none"></div>
  <div class="pbox" id="partystart" style="display:flex;gap:14px;margin-top:10px;align-items:flex-start;flex-wrap:wrap">
    <button id="partyhost" style="padding:8px 22px">HOST A PARTY</button>
    <div style="flex:1;min-width:260px">
      <textarea id="partyin" rows="2" spellcheck="false" autocomplete="off" placeholder="To join, paste the invite code your host sent you. It starts PTY1o."></textarea>
      <button id="partyjoin" style="padding:8px 22px;margin-top:6px">JOIN A PARTY</button>
    </div>
  </div>
  <div class="pbox" id="partycodebox" style="display:none;margin-top:10px">
    <div id="partylen" style="font-size:12px;letter-spacing:.14em;color:var(--amber);font-weight:700;margin-bottom:6px"></div>
    <textarea id="partycode" rows="3" spellcheck="false" readonly></textarea>
    <button id="partycopy" style="padding:8px 22px;margin-top:6px">COPY CODE</button>
  </div>
  <div class="pbox" id="partyreplybox" style="display:none;margin-top:10px">
    <textarea id="partyreplyin" rows="2" spellcheck="false" autocomplete="off" placeholder="Paste the reply code your friend sends back. It starts PTY1a."></textarea>
    <button id="partyaccept" style="padding:8px 22px;margin-top:6px">LET THEM IN</button>
  </div>
  <div class="pbox" style="display:flex;gap:8px;margin-top:14px">
    <button id="partyinvite" style="padding:8px 22px;display:none">NEW INVITE CODE</button>
    <button id="partyquit" style="padding:8px 22px;display:none">END THE PARTY</button>
    <button id="closeparty" style="padding:8px 22px;margin-left:auto">CLOSE</button>
  </div>
</div>
'@

SubRx @'
var VER='15.73';
'@ @'
var VER='15.74';
'@

SubRx @'
var SKEY=(SLOT==='1')?'salvagerun:profile':('salvagerun:profile:'+SLOT);
'@ @'
var SKEY=(SLOT==='1')?'salvagerun:profile':('salvagerun:profile:'+SLOT);
// v15.74, HIS ORDER OF 2026-09-25 (multiplayer, build 1): TWO COPIES ON ONE PC KEEP TWO SAVES. Two copies of the game on one
// origin share one save, so a test page could never run a host and a friend side by side. ?netslot=A or ?netslot=B on the
// address plays a save of its own under salvagerun:profile:netA or :netB (netSlotKey, in the net section), and its undo copy
// and boot crash list sit beside that key. Nothing else moves: salvagerun:profile and every save slot keep their keys and their
// format, and a copy opened this way never writes salvagerun:activeSlot. Without the override SKEY is exactly what it was.
var NETSLOT=netSlotOf((typeof location!=='undefined'&&location.search)||'');
if(NETSLOT) SKEY=netSlotKey(NETSLOT);
'@

SubRx @'
           KeyT:['the terms',function(){ renderTerms(); openModal('termsmodal'); }]}},
'@ @'
           KeyT:['the terms',function(){ renderTerms(); openModal('termsmodal'); }],
           // v15.74, HIS ORDER OF 2026-09-25 (multiplayer, build 1): THE PARTY WINDOW, beside the terms. F is free at the lift
           // (its other acts are E, R and T, and F is the melee key only in a raid), and on the floor it is Y on a controller.
           // Opening the window links nothing: only its HOST and JOIN buttons do.
           KeyF:['party',function(){ openParty(); }]}},
'@

SubRx @'
var PLOADED=false, PRECRASH='salvagerun:precrash';
'@ @'
var PLOADED=false, PRECRASH=NETSLOT?(SKEY+':precrash'):'salvagerun:precrash';   // v15.74: a ?netslot copy keeps its boot crash list beside its own save
'@

SubRx @'
document.getElementById('closeterms').onclick=function(){
  document.getElementById('termsmodal').classList.remove('on');
};
'@ @'
document.getElementById('closeterms').onclick=function(){
  document.getElementById('termsmodal').classList.remove('on');
};
// ================================================================ net
// v15.74, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 1 OF PHASE 1. TWO COPIES OF THE GAME LINK UP BY INVITE CODE, TEXT ONLY.
// The plan is tools/multiplayer/plan.md, section E, with the corrections in critique.md. The shape every later build keeps:
//   A STAR, HOST AUTHORITATIVE, UP TO FOUR. The host is seat 0 and holds one browser peer connection (WebRTC) per friend, seats
//   1 to 3; friends never link to each other. NET.peers is the host list of links, or on a friend the one link to the host.
//   INVITE CODES BY COPY AND PASTE, NO SERVER. HOST makes an offer with one data channel and no audio, waits for the browser to
//   finish gathering its addresses (ICE) and packs it: deflate-raw through CompressionStream when the browser has it, then
//   base64url, behind PTY1 plus o (invite) or a (reply) and z (packed) or p (plain). The friend pastes it into JOIN and sends
//   back a reply code made the same way, and the host pastes that in. PTY1 is not PIL1, the restore code, on purpose. STUN
//   only (Cloudflare, one Google server behind it), so some pairs of home routers will never link; the window says so.
//   ONE RELIABLE ORDERED CHANNEL, negotiated as id 0, carrying JSON: hello {proto,ver,pid,name} from the friend; welcome
//   {you,roster}, reject {why} or roster from the host; bye from either side. A copy on another version or protocol is turned
//   away, because two versions cannot share a raid. pid is a hash of the install id and names nobody.
// SOLO PLAY IS UNTOUCHED, and this is the rule for every build after it:
//   Nothing here runs at boot. No peer connection, no request and no microphone until HOST A PARTY or JOIN A PARTY is pressed.
//   The net code never draws from the seeded stream (rr, rnd, ri, pick, rollTable) and never touches G or a raid. Its only
//   chance is Math.random, once, for a session id when the save has no install id yet.
//   NET.made counts every peer connection this code makes, so a check can hold boot to zero.
var NET={on:false,proto:1,max:4,role:null,seat:-1,pid:'',name:'',sess:'',peers:[],roster:[],pend:null,made:0,sid:0,
  code:'',reply:'',codeLen:0,busy:false,status:'',err:''};
var NET_ICE=[{urls:'stun:stun.cloudflare.com:3478'},{urls:'stun:stun.l.google.com:19302'}];
var NET_TAG='PTY1', NET_WAIT_ICE=5000, NET_WAIT_HELLO=10000, NET_WAIT_HOST=30000, NET_WAIT_JOIN=180000, NET_MSG_MAX=16384;
// The ?netslot override (read at the save key above, long before this section runs; both are hoisted declarations).
function netSlotOf(q){ var m=(/[?&]netslot=([AB])(&|$)/).exec(String(q||'')); return m?m[1]:''; }
function netSlotKey(s){ return 'salvagerun:profile:net'+s; }
function netClean(s,n){
  return String((s===undefined||s===null)?'':s).replace(/[\u0000-\u001f\u007f]/g,'').replace(/^\s+|\s+$/g,'').slice(0,n||16);
}
function netErrText(e){ return netClean((e&&e.message)||e||'unknown',120); }
function netSess(){
  if(!NET.sess){ var s='', i; for(i=0;i<12;i++) s+='abcdefghijklmnopqrstuvwxyz0123456789'.charAt(Math.floor(Math.random()*36)); NET.sess=s; }
  return NET.sess;
}
function netPidOf(s){
  var h=0x811c9dc5, i;
  s=String(s||'');
  for(i=0;i<s.length;i++){ h=(h^s.charCodeAt(i))>>>0; h=Math.imul(h,0x01000193)>>>0; }
  return ('0000000'+h.toString(16)).slice(-8);
}
function netMe(){ NET.name=netClean(P&&P.pname,16)||'PILLAGER'; NET.pid=netPidOf((P&&P.iid)||netSess()); }
// THE CODE. Plain is the whole offer as UTF-8 in base64url; packed is the same bytes through deflate-raw. The plain half is
// synchronous, so a check can hold it to an exact round trip; the packed half needs the browser streams and is async.
function netUtf8(str){
  if(typeof TextEncoder==='function') return new TextEncoder().encode(str);
  var b=unescape(encodeURIComponent(str)), out=new Uint8Array(b.length), i;
  for(i=0;i<b.length;i++) out[i]=b.charCodeAt(i);
  return out;
}
function netUnUtf8(bytes){
  if(typeof TextDecoder==='function') return new TextDecoder('utf-8',{fatal:true}).decode(bytes);
  var s='', i;
  for(i=0;i<bytes.length;i++) s+=String.fromCharCode(bytes[i]);
  return decodeURIComponent(escape(s));
}
function netB64u(bytes){
  var s='', i;
  for(i=0;i<bytes.length;i++) s+=String.fromCharCode(bytes[i]);
  return btoa(s).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
}
function netUnB64u(t){
  t=String(t).replace(/-/g,'+').replace(/_/g,'/');
  while(t.length%4) t+='=';
  var s=atob(t), out=new Uint8Array(s.length), i;
  for(i=0;i<s.length;i++) out[i]=s.charCodeAt(i);
  return out;
}
// A chat window may break the code over lines or put words round it: spaces and line breaks are dropped, the code starts at
// PTY1 and runs to the first character base64url does not use. A code cut short fails the shape test, not the browser.
function netCodeParts(code){
  var t=String(code||'').replace(/\s+/g,''), at=t.indexOf(NET_TAG);
  if(at<0) return null;
  var k=t.charAt(at+4), m=t.charAt(at+5), body=((/^[A-Za-z0-9_-]+/).exec(t.slice(at+6))||[''])[0];
  if((k!=='o'&&k!=='a')||(m!=='p'&&m!=='z')||body.length<8) return null;
  return {type:(k==='o')?'offer':'answer',mode:m,body:body};
}
function netSdpOk(sdp){
  sdp=String(sdp||'');
  return sdp.indexOf('v=0')===0&&sdp.indexOf('m=application')>0&&sdp.indexOf('a=ice-ufrag:')>0&&sdp.indexOf('a=fingerprint:')>0;
}
function sdpPackPlain(desc){
  if(!desc||typeof desc.sdp!=='string'||(desc.type!=='offer'&&desc.type!=='answer')) return '';
  return NET_TAG+((desc.type==='offer')?'o':'a')+'p'+netB64u(netUtf8(desc.sdp));
}
function sdpUnpackPlain(code){
  var c=netCodeParts(code), sdp='';
  if(!c||c.mode!=='p') return null;
  try{ sdp=netUnUtf8(netUnB64u(c.body)); }catch(e){ return null; }
  return netSdpOk(sdp)?{type:c.type,sdp:sdp}:null;
}
function sdpPack(desc){
  var plain=sdpPackPlain(desc);
  if(!plain) return Promise.resolve('');
  try{
    if(typeof CompressionStream!=='function'||typeof Response!=='function'||typeof Blob!=='function') return Promise.resolve(plain);
    var st=new Blob([netUtf8(desc.sdp)]).stream().pipeThrough(new CompressionStream('deflate-raw'));
    return new Response(st).arrayBuffer().then(function(ab){
      var z=NET_TAG+plain.charAt(4)+'z'+netB64u(new Uint8Array(ab));
      return (z.length<plain.length)?z:plain;
    },function(){ return plain; });
  }catch(e){ return Promise.resolve(plain); }
}
function sdpUnpack(code){
  var c=netCodeParts(code);
  if(!c) return Promise.resolve(null);
  if(c.mode==='p') return Promise.resolve(sdpUnpackPlain(code));
  try{
    if(typeof DecompressionStream!=='function'||typeof Response!=='function'||typeof Blob!=='function') return Promise.resolve(null);
    var st=new Blob([netUnB64u(c.body)]).stream().pipeThrough(new DecompressionStream('deflate-raw'));
    return new Response(st).text().then(function(sdp){ return netSdpOk(sdp)?{type:c.type,sdp:String(sdp)}:null; },function(){ return null; });
  }catch(e){ return Promise.resolve(null); }
}
// THE LINKS. One peer is {id,pc,dc,state,seat,pid,name,timers}; state runs new, offer (host, code out) or answer (reply made or
// applied), open (channel up), in (said hello and was let in), rejected, gone.
function netSupported(){ return typeof window.RTCPeerConnection==='function'; }
function netNewPc(){ NET.made++; return new window.RTCPeerConnection({iceServers:NET_ICE}); }
function netLater(peer,ms,fn){ peer.timers.push(setTimeout(function(){ if(NET.peers.indexOf(peer)>=0) fn(); },ms)); }
function netClearTimers(peer){ var i; for(i=0;i<(peer.timers||[]).length;i++) clearTimeout(peer.timers[i]); peer.timers=[]; }
function netClose(peer){
  netClearTimers(peer); peer.state='gone';
  try{ if(peer.dc){ peer.dc.onopen=null; peer.dc.onmessage=null; peer.dc.onclose=null; peer.dc.close(); } }catch(e){}
  try{ if(peer.pc){ peer.pc.onconnectionstatechange=null; peer.pc.close(); } }catch(e2){}
}
function netPeerNew(){
  var pc=netNewPc(), peer={id:++NET.sid,pc:pc,dc:null,state:'new',seat:-1,pid:'',name:'',timers:[]};
  NET.peers.push(peer);
  peer.dc=pc.createDataChannel('rel',{negotiated:true,id:0,ordered:true});
  peer.dc.onopen=function(){ netDcOpen(peer); };
  peer.dc.onmessage=function(ev){ netOnMsg(peer,ev.data); };
  peer.dc.onclose=function(){ netDrop(peer,'closed'); };
  pc.onconnectionstatechange=function(){ var cs=pc.connectionState; if(cs==='failed'||cs==='closed') netDrop(peer,cs); };
  return peer;
}
function netGather(pc){
  return new Promise(function(res){
    var done=false, t=0;
    function fin(){ if(done) return; done=true; clearTimeout(t); res(); }
    if(pc.iceGatheringState==='complete'){ fin(); return; }
    pc.addEventListener('icegatheringstatechange',function(){ if(pc.iceGatheringState==='complete') fin(); });
    pc.addEventListener('icecandidate',function(ev){ if(!ev.candidate) fin(); });
    t=setTimeout(fin,NET_WAIT_ICE);
  });
}
function netStartHost(){ NET.on=true; NET.role='host'; NET.seat=0; NET.err=''; netMe(); NET.roster=netRosterBuild(); }
function netStartJoin(){ NET.on=true; NET.role='join'; NET.seat=-1; NET.err=''; netMe(); NET.roster=[]; }
function netFreeSeat(){
  var used={}, i, s;
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') used[NET.peers[i].seat]=1;
  for(s=1;s<NET.max;s++) if(!used[s]) return s;
  return -1;
}
function netRosterBuild(){
  var r=[{seat:0,pid:NET.pid,name:NET.name,host:true}], i, q;
  for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q.state==='in') r.push({seat:q.seat,pid:q.pid,name:q.name,host:false}); }
  r.sort(function(a,b){ return a.seat-b.seat; });
  return r;
}
function netRosterClean(r){
  var out=[], i, e, st;
  if(!r||typeof r.length!=='number') return out;
  for(i=0;i<r.length&&out.length<NET.max;i++){
    e=r[i]; if(!e||typeof e!=='object') continue;
    st=e.seat|0; if(st<0||st>=NET.max) continue;
    out.push({seat:st,pid:netClean(e.pid,16),name:netClean(e.name,16)||'PILLAGER',host:!!e.host});
  }
  return out;
}
function netSend(peer,msg){
  if(!peer||!peer.dc||peer.dc.readyState!=='open') return false;
  try{ peer.dc.send(JSON.stringify(msg)); return true; }catch(e){ return false; }
}
function netBroadcast(msg){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],msg); }
// HOST A PARTY, and NEW INVITE CODE: one invite code, for one friend. An unanswered one is replaced by the next.
function netHost(){
  if(NET.role==='join') return Promise.resolve({err:'You are in a party already. Quit it before you host one.'});
  if(!netSupported()) return Promise.resolve({err:'This browser cannot link up with another copy of the game.'});
  if(!NET.role) netStartHost();
  if(netFreeSeat()<0) return Promise.resolve({err:'Your party is full. Four is the most.'});
  if(NET.pend) netDrop(NET.pend,'replaced');
  var peer=null;
  try{ peer=netPeerNew(); }catch(e){ return Promise.resolve({err:'Could not start a link: '+netErrText(e)}); }
  NET.pend=peer; NET.code=''; peer.state='offer';
  return peer.pc.createOffer().then(function(o){ return peer.pc.setLocalDescription(o); })
    .then(function(){ return netGather(peer.pc); })
    .then(function(){ return sdpPack(peer.pc.localDescription); })
    .then(function(code){
      if(peer.state!=='offer'||NET.pend!==peer) return {err:'That invite code was replaced.'};
      if(!code) return {err:'The browser made no invite code.'};
      NET.code=code; NET.codeLen=code.length;
      NET.status='Send this invite code to one friend. When they send a reply code back, paste it below and press LET THEM IN.';
      return {code:code};
    },function(e){ netDrop(peer,'failed'); return {err:'Could not make an invite code: '+netErrText(e)}; });
}
// LET THEM IN: the host pastes the reply to the invite code that is out.
function netAccept(code){
  var peer=NET.pend;
  if(NET.role!=='host'||!peer||peer.state!=='offer'||!NET.code) return Promise.resolve({err:'Make an invite code first, then paste the reply to it here.'});
  return sdpUnpack(code).then(function(d){
    if(!d) return {err:'That is not a reply code. A reply code starts PTY1a.'};
    if(d.type!=='answer') return {err:'That is an invite code. Paste the reply code your friend sends back.'};
    if(peer.state!=='offer'||NET.pend!==peer) return {err:'That invite code was replaced. Make a new one.'};
    peer.state='answer'; NET.pend=null; NET.code='';
    return peer.pc.setRemoteDescription(d).then(function(){
      NET.status='Linking up. This takes a few seconds.';
      netLater(peer,NET_WAIT_HOST,function(){ if(peer.state==='answer') netDrop(peer,'timeout'); });
      return {ok:true};
    });
  }).then(null,function(e){ netDrop(peer,'failed'); return {err:'That reply code did not work: '+netErrText(e)}; });
}
// JOIN A PARTY: a friend pastes the invite code and gets a reply code to send back.
function netJoin(code){
  if(NET.role==='host') return Promise.resolve({err:'You are hosting a party. End it before you join another.'});
  if(NET.role==='join') return Promise.resolve({err:'You are in a party already. Quit it first.'});
  if(!netSupported()) return Promise.resolve({err:'This browser cannot link up with another copy of the game.'});
  return sdpUnpack(code).then(function(d){
    if(!d) return {err:'That is not an invite code. An invite code starts PTY1o.'};
    if(d.type!=='offer') return {err:'That is a reply code. Paste the invite code your host sends you.'};
    if(NET.role) return {err:'You are in a party already. Quit it first.'};
    netStartJoin();
    var peer=netPeerNew();
    peer.state='answer'; peer.seat=0;
    return peer.pc.setRemoteDescription(d)
      .then(function(){ return peer.pc.createAnswer(); })
      .then(function(a){ return peer.pc.setLocalDescription(a); })
      .then(function(){ return netGather(peer.pc); })
      .then(function(){ return sdpPack(peer.pc.localDescription); })
      .then(function(rc){
        if(NET.role!=='join'||peer.state==='gone') return {err:'The link was closed.'};
        if(!rc) return {err:'The browser made no reply code.'};
        NET.reply=rc; NET.codeLen=rc.length;
        NET.status='Send this reply code back to your host. You are linked a few seconds after they paste it in.';
        netLater(peer,NET_WAIT_JOIN,function(){ if(peer.state==='answer'){ NET.err='No link three minutes after the reply code was made. Ask your host for a new invite code, or try from another network.'; netDrop(peer,'timeout'); } });
        return {code:rc};
      });
  }).then(null,function(e){ if(NET.role==='join') netReset(true); return {err:'That invite code did not work: '+netErrText(e)}; });
}
function netDcOpen(peer){
  if(peer.state==='gone') return;
  netClearTimers(peer);
  peer.state='open';
  if(NET.role==='join'){
    NET.status='Linked. Saying hello to the host.';
    netSend(peer,{t:'hello',proto:NET.proto,ver:VER,pid:NET.pid,name:NET.name});
    netLater(peer,NET_WAIT_HELLO,function(){ if(peer.state==='open'){ NET.err='The host never answered.'; netDrop(peer,'silent'); } });
  } else {
    NET.status='Linked. Waiting for their hello.';
    netLater(peer,NET_WAIT_HELLO,function(){ if(peer.state==='open') netDrop(peer,'silent'); });
  }
  netRefresh();
}
// EVERY MESSAGE, from a real channel or a stand-in. Returns what it did, so a check can read the answer.
function netOnMsg(peer,data){
  if(!peer||peer.state==='gone'||NET.peers.indexOf(peer)<0) return 'gone';
  if(typeof data!=='string'||data.length>NET_MSG_MAX) return 'bad';
  var m=null, seat, hn, i;
  try{ m=JSON.parse(data); }catch(e){ return 'bad'; }
  if(!m||typeof m!=='object'||typeof m.t!=='string') return 'bad';
  if(NET.role==='host'){
    if(m.t==='hello'){
      if(peer.state!=='open') return 'ignored';
      if(m.proto!==NET.proto||m.ver!==VER){
        netSend(peer,{t:'reject',why:'version',ver:VER,proto:NET.proto});
        peer.state='rejected';
        NET.err=(m.ver!==VER)?('A copy on v'+netClean(m.ver,12)+' tried to join. Both copies need to be on the same version, v'+VER+'.')
               :'A copy that links up a different way tried to join. Both copies need to be the same build.';
        netLater(peer,1500,function(){ netDrop(peer,'rejected'); });
        netRefresh();
        return 'reject';
      }
      seat=netFreeSeat();
      if(seat<0){
        netSend(peer,{t:'reject',why:'full'});
        peer.state='rejected';
        netLater(peer,1500,function(){ netDrop(peer,'rejected'); });
        return 'full';
      }
      netClearTimers(peer);
      peer.state='in'; peer.seat=seat; peer.pid=netClean(m.pid,16); peer.name=netClean(m.name,16)||'PILLAGER';
      NET.roster=netRosterBuild();
      netSend(peer,{t:'welcome',you:seat,roster:NET.roster,ver:VER});
      netBroadcast({t:'roster',roster:NET.roster});
      NET.status=peer.name+' joined your party.'; NET.err='';
      netSay(NET.status);
      netRefresh();
      return 'welcome';
    }
    if(m.t==='bye'){ netDrop(peer,'left'); return 'bye'; }
    return 'ignored';
  }
  if(NET.role==='join'){
    if(m.t==='welcome'){
      if(peer.state!=='open') return 'ignored';
      netClearTimers(peer);
      peer.state='in';
      NET.seat=Math.max(1,Math.min(NET.max-1,m.you|0));
      NET.roster=netRosterClean(m.roster);
      hn='';
      for(i=0;i<NET.roster.length;i++) if(NET.roster[i].host) hn=NET.roster[i].name;
      NET.reply=''; NET.err=''; NET.status='You are in the party hosted by '+(hn||'your host')+'.';
      netSay(NET.status);
      netRefresh();
      return 'welcome';
    }
    if(m.t==='roster'){
      if(peer.state!=='in') return 'ignored';
      NET.roster=netRosterClean(m.roster); netRefresh();
      return 'roster';
    }
    if(m.t==='reject'){
      NET.err=(m.why==='version')?((m.ver!==VER)?('The host is on v'+netClean(m.ver,12)+' and you are on v'+VER+'. Both copies need to be on the same version.')
                                                  :'The host copy links up a different way. Both copies need to be the same build.')
             :((m.why==='full')?'That party is full. Four is the most.':'The host turned the link down.');
      netReset(true);
      return 'rejected';
    }
    if(m.t==='bye'){ NET.err='The host ended the party.'; netReset(true); return 'bye'; }
    return 'ignored';
  }
  return 'off';
}
function netDrop(peer,why){
  var ix=NET.peers.indexOf(peer);
  if(ix<0) return;
  var was=peer.state;
  NET.peers.splice(ix,1);
  netClose(peer);
  if(NET.pend===peer) NET.pend=null;
  if(NET.role==='join'){
    if(!NET.err) NET.err=(was==='in')?'The link to the host was lost.':'Could not link up with the host. One of your routers may be blocking a direct link; ask for a new invite code, or try from another network.';
    netReset(true);
    return;
  }
  if(NET.role==='host'){
    if(was==='in'){
      NET.roster=netRosterBuild();
      netBroadcast({t:'roster',roster:NET.roster});
      NET.status=peer.name+' left your party.';
      netSay(NET.status);
    } else if(why==='failed'||why==='timeout'||why==='silent'){
      NET.err='No link to your friend. One of your routers may be blocking a direct link. Make a new invite code, or try from another network.';
    }
  }
  netRefresh();
}
// QUIT THE PARTY and END THE PARTY: a bye to every link, every link closed, and the section back to off.
function netReset(keepErr){
  var ps=NET.peers.slice(), i;
  NET.peers=[];
  for(i=0;i<ps.length;i++){ if(ps[i].state==='in'||ps[i].state==='open') netSend(ps[i],{t:'bye'}); netClose(ps[i]); }
  NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[]; NET.code=''; NET.reply=''; NET.codeLen=0; NET.busy=false;
  NET.status='';
  if(!keepErr) NET.err='';
  netRefresh();
}
// Who joined or left is said on the floor, never over a raid.
function netSay(t){ try{ if(state==='hub'&&!G) say2(t); }catch(e){} }
function netRefresh(){ var m=document.getElementById('partymodal'); if(m&&m.classList.contains('on')) renderParty(); }
// THE PARTY WINDOW.
function openParty(){ renderParty(); openModal('partymodal'); }
function renderParty(){
  var g=function(id){ return document.getElementById(id); };
  var st=g('partystat'), er=g('partyerr'), ro=g('partyroster'), sb=g('partystart'), cb=g('partycodebox'), rb=g('partyreplybox');
  if(!st||!er||!ro||!sb||!cb||!rb) return;
  var role=NET.role, code=(role==='host')?NET.code:((role==='join')?NET.reply:''), r=NET.roster||[], i, row, nm;
  st.textContent=NET.status||(role?'':'You are not in a party. Host one, or paste an invite code from a friend who is hosting.');
  er.textContent=NET.err||''; er.style.display=NET.err?'':'none';
  sb.style.display=role?'none':'flex';
  cb.style.display=code?'':'none';
  g('partylen').textContent=code?(((role==='host')?'INVITE CODE, ':'REPLY CODE, ')+code.length+' CHARACTERS'):'';
  if(g('partycode').value!==code) g('partycode').value=code;
  rb.style.display=(role==='host'&&NET.pend&&NET.pend.state==='offer'&&NET.code)?'':'none';
  g('partyinvite').style.display=(role==='host'&&!NET.busy&&netFreeSeat()>=0)?'':'none';
  g('partyquit').style.display=role?'':'none';
  g('partyquit').textContent=(role==='host')?'END THE PARTY':'QUIT THE PARTY';
  g('partyhost').disabled=!!NET.busy; g('partyjoin').disabled=!!NET.busy; g('partyaccept').disabled=!!NET.busy;
  ro.innerHTML='';
  ro.style.display=r.length?'':'none';
  for(i=0;i<r.length;i++){
    row=document.createElement('div'); nm=document.createElement('div');
    row.className='row'; row.setAttribute('data-seat',String(r[i].seat));
    nm.className='nm';
    nm.textContent=(r[i].seat+1)+'.  '+r[i].name+(r[i].host?'   HOST':'')+((r[i].seat===NET.seat)?'   YOU':'');
    row.appendChild(nm); ro.appendChild(row);
  }
}
function netUi(fn,busyText){
  var pr=null;
  NET.busy=true; NET.err=''; NET.status=busyText||''; renderParty();
  try{ pr=fn(); }catch(e){ pr=Promise.resolve({err:netErrText(e)}); }
  Promise.resolve(pr).then(function(r){ NET.busy=false; if(r&&r.err){ NET.err=r.err; NET.status=''; } renderParty(); },
                           function(e){ NET.busy=false; NET.err=netErrText(e); NET.status=''; renderParty(); });
}
function netCopy(){
  var t=document.getElementById('partycode');
  if(!t||!t.value) return;
  var done=function(ok){ NET.status=ok?'Copied. Paste it to your friend.':'Select the code and copy it by hand.'; renderParty(); };
  try{ if(navigator.clipboard&&navigator.clipboard.writeText){ navigator.clipboard.writeText(t.value).then(function(){ done(true); },function(){ netCopyOld(t,done); }); return; } }catch(e){}
  netCopyOld(t,done);
}
function netCopyOld(t,done){
  var ok=false;
  try{ t.select(); ok=document.execCommand('copy'); t.blur(); }catch(e){ ok=false; }
  done(ok);
}
(function(){
  var g=function(id){ return document.getElementById(id); };
  // A paste box keeps the keyboard until it is let go, and the floor ignores every key while one has it.
  var blurIn=function(){ var a=document.activeElement, m=g('partymodal'); if(a&&m&&m.contains(a)&&a.blur) a.blur(); };
  g('closeparty').onclick=function(){ blurIn(); g('partymodal').classList.remove('on'); };
  g('partyhost').onclick=function(){ netUi(netHost,'Making an invite code. This takes a few seconds.'); };
  g('partyinvite').onclick=function(){ netUi(netHost,'Making a new invite code. This takes a few seconds.'); };
  g('partyjoin').onclick=function(){
    var v=g('partyin').value; blurIn();
    if(!String(v||'').replace(/\s+/g,'')){ NET.err='Paste the invite code your host sent you into the box first.'; renderParty(); return; }
    netUi(function(){ return netJoin(v); },'Reading the invite code and making your reply code. This takes a few seconds.');
  };
  g('partyaccept').onclick=function(){
    var v=g('partyreplyin').value; blurIn();
    if(!String(v||'').replace(/\s+/g,'')){ NET.err='Paste the reply code your friend sent back into the box first.'; renderParty(); return; }
    g('partyreplyin').value='';
    netUi(function(){ return netAccept(v); },'Reading the reply code.');
  };
  g('partycopy').onclick=function(){ netCopy(); };
  g('partyquit').onclick=function(){ blurIn(); netReset(); renderParty(); };
})();
// THE TEST PAGE HANDLE. Only a copy opened with ?netslot has it, so tools/nettest.html can read two copies side by side; a
// copy opened any other way sets nothing on window.
if(NETSLOT){
  try{
    window.__net={slot:NETSLOT,key:SKEY,ver:VER,proto:NET.proto,
      state:function(){ return {on:NET.on,role:NET.role,seat:NET.seat,roster:JSON.parse(JSON.stringify(NET.roster)),status:NET.status,err:NET.err,made:NET.made,codeLen:NET.codeLen,links:NET.peers.length}; },
      rngs:function(){ return RNGS; },
      open:function(){ openParty(); },
      reset:function(){ netReset(); }};
  }catch(e){}
}
'@

SubRx @'
          try{ localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}
'@ @'
          try{ if(!NETSLOT) localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer
'@

SubRx @'
          try{ localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}
'@ @'
          try{ if(!NETSLOT) localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer
'@

$pat = "(?m)^  now:'v15\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.74: TWO COPIES OF THE GAME LINK UP BY INVITE CODE. Multiplayer build 1, text only. F at the lift opens the PARTY window: HOST A PARTY makes an invite code to copy, JOIN A PARTY takes one and makes a reply code to send back, the host pastes the reply in with LET THEM IN, and the roster shows who is in, up to four. A direct browser link with no server, STUN only. Nothing links until HOST or JOIN is pressed, nothing asks for the microphone, and every raid is still solo: the net code never draws from the seeded stream and never touches a raid. ?netslot=A or B gives a test copy a save of its own. Check 15.74 fails on v15.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
