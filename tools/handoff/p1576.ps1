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

# THE MODE MENU AND SAME MACHINE PAIRING. Multiplayer, phase 1, build 3 (tools/multiplayer/plan.md section E with the
# corrections in critique.md), his order of 2026-09-25: two players on the SAME PC in two game windows on two screens, player 2
# on a controller, and a START MENU with exactly these rows in this order: 1 PLAYER, 2 PLAYER CO-OP (SAME MACHINE),
# 2 PLAYER CO-OP (SERVER) (greyed, coming later), 2 PLAYER PVP (SAME MACHINE), PVP (SERVER) (greyed, coming later).
# 1. CSS for the menu rows and the greyed note.
# 2. The title: the start button becomes the 1 PLAYER row under its old id, with the four rows under it, the blocked-window
#    sentence with RETRY, and the player 2 line.
# 3. The PARTY window names the mode.
# 4. VER 15.75 to 15.76.
# 5. The save key: ?p2=1 plays salvagerun:profile:p2 and never moves the save pointer (netSaveLocked on both title writes);
#    the boot crash list sits beside that save too.
# 6. The net section: the mode and window fields on NET, netP2Of and friends beside netSlotKey, netReset lets go of the
#    channel, the same machine section (the channel, the pick, the handshake carried on the channel, the player 2 boot, the
#    title wiring), the test handle reads the mode.
# 7. The title wiring: netTitleInit(go) after the start button, ENTER presses the highlighted row, the arrows move it.
# Solo play is untouched: 1 PLAYER is the old start under its old id and runs no net code.

SubRx @'
  #partymodal textarea{ font-family:ui-monospace,Consolas,monospace; font-size:12px; word-break:break-all; }
'@ @'
  #partymodal textarea{ font-family:ui-monospace,Consolas,monospace; font-size:12px; word-break:break-all; }
  /* v15.76, HIS ORDER OF 2026-09-25 (multiplayer, build 3): THE MODE MENU ON THE TITLE. Five rows, one under the other and all
     centred, so a controller stepping down the column lands on the next row and not on a control off to one side. A greyed
     row keeps its note beside it, out of the flow, so the row itself stays centred with the others. */
  #modemenu{ display:flex; flex-direction:column; align-items:center; gap:6px; }
  #modemenu button.moderow{ min-width:440px; padding:9px 28px; font-size:12px; letter-spacing:.22em; }
  #modemenu .modelater{ position:relative; display:inline-block; }
  #modemenu .modelater span{ position:absolute; left:100%; top:50%; transform:translateY(-50%); margin-left:12px; white-space:nowrap;
    font-size:10.5px; letter-spacing:.18em; color:var(--ash); text-transform:uppercase; }
  #modemsg{ font-size:12.5px; line-height:1.5; color:var(--hazard); max-width:640px; }
  #p2line{ font-size:12.5px; line-height:1.5; color:var(--amber); max-width:640px; }
'@

SubRx @'
    <button class="deploy" id="titlestart"
      style="margin-top:26px;padding:13px 46px;font-size:15px;letter-spacing:.2em">ENTER THE UNDERCROFT</button>
'@ @'
    <!-- v15.76, HIS ORDER OF 2026-09-25 (multiplayer, build 3): THE MODE MENU. The first thing a player picks is the mode, five
         rows in his order and wording. 1 PLAYER is the old start button under its old id, so the pad focus, ENTER and every
         check that found it still do, and it runs exactly what the start button ran. The two SERVER rows are greyed, coming
         later. A same machine row opens the player 2 window; if the browser blocks it the sentence and RETRY below say so. -->
    <div id="modemenu" style="margin-top:22px">
      <button class="deploy moderow" id="titlestart" data-mode="solo"
        style="padding:13px 46px;font-size:15px;letter-spacing:.2em">1 PLAYER</button>
      <button class="deploy ghost moderow" id="modecoop" data-mode="coop">2 PLAYER CO-OP (SAME MACHINE)</button>
      <div class="modelater"><button class="deploy ghost moderow" id="modecoopsrv" data-mode="coopsrv" disabled>2 PLAYER CO-OP (SERVER)</button><span>coming later</span></div>
      <button class="deploy ghost moderow" id="modepvp" data-mode="pvp">2 PLAYER PVP (SAME MACHINE)</button>
      <div class="modelater"><button class="deploy ghost moderow" id="modepvpsrv" data-mode="pvpsrv" disabled>PVP (SERVER)</button><span>coming later</span></div>
      <div id="modemsg" style="display:none"></div>
      <button class="deploy ghost" id="moderetry" style="display:none;padding:8px 24px">RETRY</button>
      <div id="p2line" style="display:none"></div>
    </div>
'@

SubRx @'
  <div class="msub" id="partystat" style="color:var(--amber);font-weight:700"></div>
'@ @'
  <div class="msub" id="partystat" style="color:var(--amber);font-weight:700"></div>
  <div class="msub" id="partymode" style="display:none;color:var(--bone);letter-spacing:.14em"></div>
'@

SubRx @'
var VER='15.75';
'@ @'
var VER='15.76';
'@

SubRx @'
if(NETSLOT) SKEY=netSlotKey(NETSLOT);
'@ @'
// v15.76, HIS ORDER OF 2026-09-25 (multiplayer, build 3): THE PLAYER 2 WINDOW KEEPS A SAVE OF ITS OWN. A same machine row on
// the title opens a second window of the game with ?p2=1 on its address, and that window plays salvagerun:profile:p2 (netP2Key,
// in the net section): a permanent save for player 2, never the main save, never a numbered save and never the ?netslot test
// saves. ?netslot wins when both are on the address, since it is the explicit test override. Like a ?netslot copy, a player 2
// window never writes salvagerun:activeSlot (netSaveLocked, read by both title writes). Without either, SKEY is exactly what it was.
var NETP2=!NETSLOT&&netP2Of((typeof location!=='undefined'&&location.search)||'');
if(NETSLOT) SKEY=netSlotKey(NETSLOT);
else if(NETP2) SKEY=netP2Key();
'@

SubRx @'
var PLOADED=false, PRECRASH=NETSLOT?(SKEY+':precrash'):'salvagerun:precrash';   // v15.74: a ?netslot copy keeps its boot crash list beside its own save
'@ @'
var PLOADED=false, PRECRASH=(NETSLOT||NETP2)?(SKEY+':precrash'):'salvagerun:precrash';   // v15.74: a ?netslot copy keeps its boot crash list beside its own save; v15.76: the player 2 window too
'@

SubRx @'
  floor:[],hubAcc:0,hubN:0,lkSent:''};   // v15.75: who stands where on the floor, by seat, and the send clock
'@ @'
  floor:[],hubAcc:0,hubN:0,lkSent:'',   // v15.75: who stands where on the floor, by seat, and the send clock
  mode:'',pick:'',same:'',pair:'',bc:null,p2win:null,p2url:'',sameBusy:false,start:null};   // v15.76: the mode, and the two windows on one PC
'@

SubRx @'
function netSlotKey(s){ return 'salvagerun:profile:net'+s; }
'@ @'
function netSlotKey(s){ return 'salvagerun:profile:net'+s; }
// v15.76 (multiplayer, build 3): THE PLAYER 2 WINDOW. ?p2=1 on the address (read at the save key, like ?netslot) plays the
// permanent player 2 save, salvagerun:profile:p2: never a numbered save, never the test net saves, and never the save pointer.
// mode=coop or pvp and pair=<code> ride on the same address, put there by the player 1 window that opened it.
function netP2Of(q){ return (/[?&]p2=1(&|$)/).test(String(q||'')); }
function netP2Key(){ return 'salvagerun:profile:p2'; }
function netModeOf(q){ var m=(/[?&]mode=(coop|pvp)(&|$)/).exec(String(q||'')); return m?m[1]:''; }
function netPairOf(q){ var m=(/[?&]pair=([a-z0-9]{4,16})(&|$)/).exec(String(q||'')); return m?m[1]:''; }
// A ?netslot copy and the player 2 window never move the save pointer: the title save list reads this before it writes.
function netSaveLocked(){ return !!((typeof NETSLOT!=='undefined'&&NETSLOT)||(typeof NETP2!=='undefined'&&NETP2)); }
'@

SubRx @'
  NET.floor=[]; NET.hubAcc=0; NET.hubN=0; NET.lkSent='';   // v15.75: nobody is left standing on the floor
'@ @'
  NET.floor=[]; NET.hubAcc=0; NET.hubN=0; NET.lkSent='';   // v15.75: nobody is left standing on the floor
  // v15.76: the host lets go of the window channel and the mode; the player 2 window keeps both, so the host can offer again.
  if(!(typeof NETP2!=='undefined'&&NETP2)) netSameStop();
'@

SubRx @'
  er.textContent=NET.err||''; er.style.display=NET.err?'':'none';
'@ @'
  er.textContent=NET.err||''; er.style.display=NET.err?'':'none';
  var mo=g('partymode'); if(mo){ mo.textContent=NET.mode?('MODE: '+netModeName(NET.mode)):''; mo.style.display=NET.mode?'':'none'; }   // v15.76: the mode picked on the title
'@

SubRx @'
// THE PARTY WINDOW.
'@ @'
// v15.76, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 3 OF PHASE 1. THE MODE MENU AND TWO WINDOWS ON ONE PC.
//   THE MENU. The title opens on five rows in his order and wording: 1 PLAYER, 2 PLAYER CO-OP (SAME MACHINE), 2 PLAYER CO-OP
//   (SERVER), 2 PLAYER PVP (SAME MACHINE), PVP (SERVER); the two SERVER rows are greyed, coming later. 1 PLAYER is the old
//   start button and runs no net code. The arrows (and W and S) move the highlight down the rows and ENTER presses it; with
//   nothing highlighted ENTER starts 1 PLAYER, as it always did. A controller works the rows through padMenu as it works any
//   panel: the focus lands on 1 PLAYER, the D-pad steps down the column, A presses, B does nothing on the title.
//   TWO WINDOWS. A same machine row makes this window player 1 and the host. It opens a second window of the same page with
//   ?p2=1, the mode and a pair code on its address, which plays the permanent player 2 save (netP2Key). The two windows find
//   each other over a BroadcastChannel named for this page on this origin, and the pair code keeps any other copy out. Over
//   that channel runs the v15.74 handshake, unchanged: the host makes its invite code (netHost) and posts it, the player 2
//   window answers with its reply code (netJoin) and posts that, the host takes it (netAccept), the data channel opens, hello
//   and welcome as before, and both stand in the Undercroft as a party of two, seeing each other as v15.75 draws them. The
//   ICE list is the v15.74 one: on one PC the host candidates link the two windows; the STUN servers stay for later builds.
//   The mode is NET.mode, coop or pvp, named in the PARTY window. PvP rules are a later build. A blocked second window is
//   said on the title with a RETRY button.
// SOLO PLAY IS UNTOUCHED. 1 PLAYER runs the old start, nothing below runs until a same machine row is pressed or the page was
// opened with ?p2=1, and nothing here draws from the seeded stream (rr, rnd, ri, pick, rollTable) or reads G.
function netModeName(m){ return (m==='pvp')?'2 PLAYER PVP (SAME MACHINE)':((m==='coop')?'2 PLAYER CO-OP (SAME MACHINE)':''); }
function netSameName(){ return 'pillagers:same:'+((typeof location!=='undefined'&&location.pathname)||''); }
function netSameChan(){
  if(NET.bc) return NET.bc;
  try{ NET.bc=new BroadcastChannel(netSameName()); NET.bc.onmessage=function(ev){ netSameOnMsg(ev?ev.data:null); }; }
  catch(e){ NET.bc=null; }
  return NET.bc;
}
function netSamePost(m){ if(!NET.bc) return false; try{ NET.bc.postMessage(m); return true; }catch(e){ return false; } }
function netSameStop(){
  if(NET.bc){ try{ NET.bc.onmessage=null; NET.bc.close(); }catch(e){} }
  NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.p2win=null; NET.sameBusy=false;
}
// The address of the player 2 window: this page, with p2=1, the mode and the pair code and nothing else.
function netP2Url(mode,pair){
  var base=(typeof location!=='undefined'&&location.href)?String(location.href):'';
  base=base.split('#')[0].split('?')[0];
  return base+'?p2=1&mode='+((mode==='pvp')?'pvp':'coop')+'&pair='+String(pair||'');
}
// A window, not a tab, most of the screen, so he can drag it to his second screen and go fullscreen there.
function netP2Features(){
  var sw=(typeof screen!=='undefined'&&screen&&screen.availWidth)||1920, sh=(typeof screen!=='undefined'&&screen&&screen.availHeight)||1080;
  return 'popup=yes,width='+Math.max(800,Math.round(sw*0.9))+',height='+Math.max(600,Math.round(sh*0.9))+',left=0,top=0';
}
function netModeMsg(t,retry){
  var m=document.getElementById('modemsg'), r=document.getElementById('moderetry');
  if(m){ m.textContent=t||''; m.style.display=t?'':'none'; }
  if(r) r.style.display=(t&&retry)?'':'none';
}
// A SAME MACHINE ROW, or RETRY. Opens the player 2 window first, inside the click, since a browser only allows a window a
// click asked for; then this copy is the host and the title start runs. Returns what happened, so a check can read it.
function netSamePick(mode,startFn){
  var go=(typeof startFn==='function')?startFn:NET.start, w=null, url;
  mode=(mode==='pvp')?'pvp':'coop';
  NET.pick=mode;
  if(NET.same==='p2'||NET.role==='join'){ netModeMsg('This window is player 2 already.'); return 'p2'; }
  if(typeof BroadcastChannel!=='function'||!netSupported()){ netModeMsg('This browser cannot link two windows of the game. 1 PLAYER still plays.'); return 'unsupported'; }
  if(!NET.pair) NET.pair=netSess();
  url=netP2Url(mode,NET.pair); NET.p2url=url;
  try{ w=window.open(url,'pillagers_p2',netP2Features()); }catch(e){ w=null; }
  if(!w){ NET.p2win=null; netModeMsg('The browser blocked the second window. Allow popups for this page, then press RETRY.',true); return 'blocked'; }
  NET.p2win=w; NET.same='host'; NET.mode=mode; netModeMsg('');
  if(!NET.role) netStartHost();
  NET.status='Waiting for the player 2 window to link up.';
  netSameChan();
  netSameHostLink();
  if(typeof go==='function') go();
  return 'opened';
}
// The host side of the handshake: the invite code goes out on the channel when it is made (netSameHostDone), again when the
// player 2 window says it is ready, and the reply code that comes back is taken with netAccept.
function netSameHostLink(){
  if(NET.same!=='host') return 'off';
  if(NET.sameBusy) return 'busy';
  NET.sameBusy=true;
  var pr=null;
  try{ pr=netHost(); }catch(e){ pr=Promise.resolve({err:netErrText(e)}); }
  Promise.resolve(pr).then(netSameHostDone,function(e){ netSameHostDone({err:netErrText(e)}); });
  return 'linking';
}
function netSameHostDone(r){
  NET.sameBusy=false;
  if(NET.same!=='host') return 'off';
  if(!r||r.err){ NET.err=(r&&r.err)||'Could not make the link to the player 2 window.'; netRefresh(); return 'err'; }
  netSamePost({t:'offer',pair:NET.pair,mode:NET.mode,code:r.code});
  NET.status='Waiting for the player 2 window to link up.';
  netRefresh();
  return 'offer';
}
// The player 2 side: the reply code goes back on the channel, or the failure does.
function netSameJoinDone(r){
  if(NET.same!=='p2') return 'off';
  if(!r||r.err){ NET.err=(r&&r.err)||'Could not read the link from the player 1 window.'; netSamePost({t:'fail',pair:NET.pair,why:NET.err}); netRefresh(); return 'err'; }
  netSamePost({t:'answer',pair:NET.pair,code:r.code});
  return 'answer';
}
function netSameAcceptDone(r){ if(r&&r.err){ NET.err=r.err; netRefresh(); return 'err'; } return 'ok'; }
// EVERY WORD ON THE CHANNEL, from the real channel or a stand-in. Only a word carrying this pair code is read. Returns what
// it did, so a check can read the answer.
function netSameOnMsg(m){
  if(!m||typeof m!=='object'||typeof m.t!=='string') return 'bad';
  if(!NET.same||!NET.pair||m.pair!==NET.pair) return 'ignored';
  if(NET.same==='host'){
    if(m.t==='ready'){
      if(NET.pend&&NET.pend.state==='offer'){ if(NET.code){ netSamePost({t:'offer',pair:NET.pair,mode:NET.mode,code:NET.code}); return 'offer'; } return 'wait'; }
      netSameHostLink();
      return 'wait';
    }
    if(m.t==='answer'){
      if(typeof m.code!=='string') return 'bad';
      Promise.resolve(netAccept(m.code)).then(netSameAcceptDone,function(e){ netSameAcceptDone({err:netErrText(e)}); });
      return 'accept';
    }
    if(m.t==='fail'){ NET.err='Player 2 could not link up: '+netClean(m.why,120); netRefresh(); return 'fail'; }
    return 'ignored';
  }
  if(NET.same==='p2'){
    if(m.t==='offer'){
      if(typeof m.code!=='string') return 'bad';
      if(NET.role) return 'ignored';
      if(m.mode==='coop'||m.mode==='pvp') NET.mode=m.mode;
      Promise.resolve(netJoin(m.code)).then(netSameJoinDone,function(e){ netSameJoinDone({err:netErrText(e)}); });
      return 'join';
    }
    return 'ignored';
  }
  return 'off';
}
// THE PLAYER 2 WINDOW, at boot: the mode and the pair code come off the address (or from the caller, for a check), the
// channel opens, and the player 1 window is told this one is ready. Nothing goes to the network until its invite code arrives.
function netSameBootP2(pair,mode){
  var q=(typeof location!=='undefined'&&location.search)||'';
  NET.mode=(mode==='coop'||mode==='pvp')?mode:(netModeOf(q)||'coop');
  NET.pair=(typeof pair==='string'&&pair)?netPairOf('?pair='+pair):netPairOf(q);
  NET.same='p2';
  if(typeof BroadcastChannel!=='function'||!netSupported()){ NET.err='This browser cannot link two windows of the game.'; netRefresh(); return 'unsupported'; }
  if(!NET.pair){ NET.err='This window was opened without a pair code. Close it and pick the mode again in the player 1 window.'; netRefresh(); return 'nopair'; }
  if(!netSameChan()){ NET.err='Could not open the link to the player 1 window.'; netRefresh(); return 'nochan'; }
  netSamePost({t:'ready',pair:NET.pair});
  return 'ready';
}
// THE TITLE. Called once at boot with the start the old button runs. Wires the same machine rows and RETRY; in the player 2
// window it hides the rows, names the window and starts the pairing.
function netTitleInit(startFn){
  var g=function(id){ return document.getElementById(id); };
  var co=g('modecoop'), pv=g('modepvp'), rt=g('moderetry'), st=g('titlestart'), pl=g('p2line'), hide=['modecoop','modecoopsrv','modepvp','modepvpsrv'], i, el, r;
  NET.start=(typeof startFn==='function')?startFn:null;
  if(co) co.onclick=function(){ netSamePick('coop'); };
  if(pv) pv.onclick=function(){ netSamePick('pvp'); };
  if(rt) rt.onclick=function(){ netSamePick(NET.pick||'coop'); };
  if(!(typeof NETP2!=='undefined'&&NETP2)) return 'host';
  for(i=0;i<hide.length;i++){ el=g(hide[i]); if(!el) continue; if(el.parentNode&&el.parentNode.className==='modelater') el=el.parentNode; el.style.display='none'; }
  if(st) st.textContent='ENTER THE UNDERCROFT';
  r=netSameBootP2();
  if(pl){ pl.textContent='PLAYER 2. This window links up with the player 1 window on its own. Drag it to your second screen. MODE: '+netModeName(NET.mode)+'.'; pl.style.display=''; }
  try{ document.title='PILLAGERS, PLAYER 2'; }catch(e){}
  return r;
}
// The mode rows a keyboard or a pad can land on: shown and not greyed.
function netTitleRows(){
  var m=document.getElementById('modemenu'), out=[], q, i, el, w;
  if(!m) return out;
  q=m.querySelectorAll('button[data-mode]');
  for(i=0;i<q.length;i++){
    el=q[i]; w=(el.parentNode&&el.parentNode.className==='modelater')?el.parentNode:el;
    if(el.disabled||el.style.display==='none'||w.style.display==='none') continue;
    out.push(el);
  }
  return out;
}
// ARROWS (and W and S) on the title: the highlight steps down or up the rows and wraps. With nothing highlighted the
// highlight is 1 PLAYER, which is what ENTER would press. Returns whether a row took the key.
function netTitleMove(dir){
  var rows=netTitleRows(), cur=(typeof PAD!=='undefined'&&PAD)?PAD.focus:null, ix=0, i;
  if(!rows.length) return false;
  for(i=0;i<rows.length;i++) if(rows[i]===cur) ix=i;
  ix=(ix+((dir<0)?-1:1)+rows.length)%rows.length;
  padSetFocus(rows[ix]);
  return true;
}
// ENTER or SPACE on the title: the highlighted mode row, or with none highlighted the start the old button runs.
function netTitleEnter(startFn){
  var cur=(typeof PAD!=='undefined'&&PAD)?PAD.focus:null, m=document.getElementById('modemenu');
  if(cur&&m&&m.contains(cur)&&cur.getAttribute&&cur.getAttribute('data-mode')&&!cur.disabled&&cur.id!=='titlestart'){ cur.click(); return 'row'; }
  if(typeof startFn==='function') startFn();
  return 'start';
}
// THE PARTY WINDOW.
'@

SubRx @'
if(NETSLOT){
'@ @'
if(NETSLOT||NETP2){   // v15.76: and the player 2 window, so the test page can read it beside the host copy
'@

SubRx @'
    window.__net={slot:NETSLOT,key:SKEY,ver:VER,proto:NET.proto,
'@ @'
    window.__net={slot:NETSLOT,p2:NETP2,key:SKEY,ver:VER,proto:NET.proto,
'@

SubRx @'
      fast:function(){ var c=0, j; for(j=0;j<NET.peers.length;j++) if(NET.peers[j].fc&&NET.peers[j].fc.readyState==='open') c++; return c; }};
'@ @'
      fast:function(){ var c=0, j; for(j=0;j<NET.peers.length;j++) if(NET.peers[j].fc&&NET.peers[j].fc.readyState==='open') c++; return c; },
      // v15.76: the mode and the two windows on one PC, and the same machine pick driven from a test page (no title start).
      same:function(){ return {mode:NET.mode,pick:NET.pick,same:NET.same,pair:NET.pair,p2url:NET.p2url,chan:!!NET.bc,busy:NET.sameBusy,p2win:!!NET.p2win}; },
      pick:function(mode){ return netSamePick(mode,function(){}); }};
'@

SubRx @'
          try{ if(!NETSLOT) localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer
'@ @'
          try{ if(!netSaveLocked()) localStorage.setItem('salvagerun:activeSlot',sn); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer; v15.76: nor the player 2 window
'@

SubRx @'
          try{ if(!NETSLOT) localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer
'@ @'
          try{ if(!netSaveLocked()) localStorage.setItem('salvagerun:activeSlot',key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer; v15.76: nor the player 2 window
'@

SubRx @'
    document.getElementById('titlestart').onclick=go;
'@ @'
    document.getElementById('titlestart').onclick=go;
    // v15.76 (multiplayer, build 3): the same machine rows, RETRY, and the player 2 window pairing. 1 PLAYER is the line above.
    try{ netTitleInit(go); }catch(_nt){}
'@

SubRx @'
      if(t.classList.contains('on')&&(e.code==='Enter'||e.code==='Space')){ e.preventDefault(); go(); }
'@ @'
      if(t.classList.contains('on')&&(e.code==='Enter'||e.code==='Space')){ e.preventDefault(); netTitleEnter(go); }   // v15.76: the highlighted mode row, or the start
      // v15.76: the arrows (and W and S) move the highlight down the mode rows.
      if(t.classList.contains('on')&&(e.code==='ArrowDown'||e.code==='ArrowUp'||e.code==='KeyS'||e.code==='KeyW')){ if(netTitleMove((e.code==='ArrowDown'||e.code==='KeyS')?1:-1)) e.preventDefault(); }
'@

$pat = "(?m)^  now:'v15\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.76: THE MODE MENU AND SAME MACHINE PAIRING. Multiplayer build 3. The title opens on five rows in his order: 1 PLAYER, 2 PLAYER CO-OP (SAME MACHINE), 2 PLAYER CO-OP (SERVER), 2 PLAYER PVP (SAME MACHINE) and PVP (SERVER), the two server rows greyed and coming later, picked by mouse, by the arrows and ENTER, or by a controller. 1 PLAYER is the old start button under its old id and runs no net code. A same machine row makes this window player 1 and the host, opens a second window of the game as player 2 on a permanent save of its own, and the two pair by themselves over a channel between windows carrying the v15.74 handshake, so both stand in the Undercroft as a party of two. A blocked second window is said on the title with RETRY. The mode is kept and named in the PARTY window; the PvP rules are a later build. Solo play is untouched and the seed 4242 fingerprint has no way to move. Check 15.76 fails on v15.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
