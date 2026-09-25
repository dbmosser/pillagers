$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.77',what:")) { throw "check 15.77 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.77. Synchronous, as the fixture runner (__regress and __regressBg) does not await a promise a check returns, and it
# never opens a window, makes a channel or makes a connection: the channel between windows is a stand-in that records what
# is posted, navigator.getGamepads and document.hasFocus are stubbed for the length of the check, and the words are fed to
# the real netSameOnMsg, which hands them to the real netPadRecv; the real pollPad reads them. Everything is put back in
# finally. The live hand-over between two real windows is the controller step of RUN SAME MACHINE in tools/nettest.html.
SubRx @'
  {v:'15.76',what:
'@ @'
  {v:'15.77',what:'each window on one PC gets a controller of its own: in a same machine mode the window in front reads every connected controller each frame and hands the other window the state of that window pad over the channel between windows (the host with no pick plays no pad and hands player 2 the first connected pad; the host that picked controller 1 plays it and hands player 2 controller 2 with its buttons, its trigger and its sticks, never its own; three frames hand over three states), a pick both windows made goes to the host, a pick of a pad that is not plugged in is handed nothing, a pick from another pair code is ignored; the window not in front hands nothing over and does not play its own read, plays the state handed over (the reader fills the pad fields from it: the sticks, the buttons down and the keys they hold), drops a state from the other window own pad, one from a pad this window did not pick, one with a bad shape and one older than a quarter second; in front the own pad wins, the state handed over earlier is dropped and the other window is handed its pad; the CONTROLLER row in the PARTY window shows only in a same machine mode, cycles none, 1 to 4, none, tells the other window and keeps the pick under its own key; the real same machine pick (window, code maker and channel stood in) reads the kept pick and tells the player 2 window, tells it again on ready, and the real player 2 boot reads its own kept pick and tells the host with ready still the last word; outside a same machine mode nothing is handed over, focus is never asked, a state handed over is not played and the first connected pad is read as before; the seeded stream never moves (multiplayer build 4)',
   run:function(){
     // THE HAND-OVER IS THERE. Without it the second window has no controller while the first is in front, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netPadTick!=='function'||typeof netPadFor!=='function'||typeof netPadRecv!=='function'||typeof netPadSend!=='function'||
        typeof netPadWant!=='function'||typeof netPadInit!=='function'||typeof netPadCycle!=='function'||typeof netPadSet!=='function'||typeof netPadLabel!=='function'||
        typeof netSameOnMsg!=='function'||!document.getElementById('partypad')||!document.getElementById('partypadbtn')||typeof NET.padIx!=='number')
       return 'this build hands no controller to a window that is not in front (no netPadTick, netPadFor, netPadRecv or netPadSend, and no CONTROLLER row in the PARTY window), so player 2 at the second window on one PC has no controller while the player 1 window is in front';
     if(typeof pollPad!=='function'||typeof PAD==='undefined'||!PAD||typeof padAxis!=='function'||typeof padRelease!=='function'||typeof padOpenModal!=='function'||typeof renderParty!=='function'||typeof netReset!=='function'||
        typeof netSamePick!=='function'||typeof netSameBootP2!=='function'||typeof netHost!=='function'||typeof netSupported!=='function') return 'this build has no controller reader under the hand-over';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the hand-over is measured on the Undercroft floor';
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     var bad=[], rng0=null, keepP=null, keepPad=null, keepNet=null, i;
     var _s2=say2, NG=navigator.getGamepads, stubbed=false, hf={n:0,v:true}, hadHF=Object.prototype.hasOwnProperty.call(document,'hasFocus'), oHF=document.hasFocus, hfStub=false;
     var KH='salvagerun:samepad:host', KP='salvagerun:samepad:p2', lsWas=null, PAIR='zqxpadpair1';
     var oOpen=window.open, hadBC=('BroadcastChannel' in window), oBC=window.BroadcastChannel, oH=netHost, oStart=NET.start, spied=false, chans=[];
     // A stand-in channel class for the real pick and the real player 2 boot: records what is posted. Never a real channel.
     function BC(name){ this.name=String(name); this.posted=[]; this.onmessage=null; this.closed=false; chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){ this.closed=true; };
     function lastOf(list,t){ var q, o=null; for(q=0;q<list.length;q++) if(list[q]&&list[q].t===t) o=list[q]; return o; }
     function unspy(){ if(!spied) return; spied=false; window.open=oOpen; if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_db){ window.BroadcastChannel=undefined; } } netHost=oH; NET.start=oStart; }
     var g=function(id){ return document.getElementById(id); };
     function ls(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function txt(el){ return String((el&&el.textContent)||'').replace(/\s+/g,' ').replace(/^ | $/g,''); }
     function shown(el){ return !!el&&el.style.display!=='none'; }
     function js(o){ return JSON.stringify(o); }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     // A pad as the browser hands one back: the buttons down by number, a trigger part way, and the sticks.
     function pad(ix,down,axes,part){
       var bts=[], q, d;
       for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bts.push({pressed:d,value:d?1:((part&&part[q]!==undefined)?part[q]:0),touched:d}); }
       return {connected:true,id:'probe pad '+ix,index:ix,mapping:'standard',timestamp:1,axes:axes||[0,0,0,0],buttons:bts};
     }
     function pads(list){ navigator.getGamepads=function(){ return list; }; }
     // The stand-in channel between windows: records what is posted. Never a real channel.
     var ch={posted:[],closed:false,onmessage:null,postMessage:function(m){ this.posted.push(m); },close:function(){ this.closed=true; }};
     function posts(t){ var o=[], q; for(q=0;q<ch.posted.length;q++) if(ch.posted[q]&&ch.posted[q].t===t) o.push(ch.posted[q]); return o; }
     function last(t){ var o=posts(t); return o.length?o[o.length-1]:null; }
     // A state as the other window would hand it over.
     function fwd(ix,own,down,axes){ var p=[], v=[], q; for(q=0;q<17;q++){ p.push(down.indexOf(q)>=0?1:0); v.push(down.indexOf(q)>=0?1:0); } return {t:'pad',pair:PAIR,ix:ix,own:own,p:p,v:v,a:axes||[0,0,0,0]}; }
     function downs(){ var o=[], q; for(q=0;q<(PAD.prev||[]).length;q++) if(PAD.prev[q]) o.push(q); return o.join(','); }
     function same(a,b){ var q; if(!a||!b||a.length!==b.length) return false; for(q=0;q<a.length;q++) if(Math.abs(a[q]-b[q])>1e-6) return false; return true; }
     function frame(){ pollPad(); }
     try{
       __topClear();
       try{ __hubEnter(); }catch(_h){}
       closeAll();   // a fresh profile opens the welcome window
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player) return skip('the Undercroft floor is not up here');
       if(padOpenModal()) return skip('a panel is open over the floor, so the reader would work the panel and not the floor');
       try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
       if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return skip('this browser will not let the pad be faked'); }
       try{ document.hasFocus=function(){ hf.n++; return hf.v; }; hfStub=(document.hasFocus()===true&&hf.n===1); hf.n=0; }catch(_hf){ hfStub=false; }
       if(!hfStub) return skip('this browser will not let the focus be faked');
       netReset();
       say2=function(){};
       for(var k0 in keys) keys[k0]=false;
       keepP={x:HB.player.x,y:HB.player.y,face:HB.player.face};
       keepPad={on:PAD.on,aSpent:PAD.aSpent,announced:PAD.announced,ax:PAD.ax,mrep:PAD.mrep,mx:PAD.mx,my:PAD.my,prev:(PAD.prev||[]).slice()};
       keepNet={padIx:NET.padIx,padOther:NET.padOther};
       lsWas={h:ls(KH),p:ls(KP)};
       rng0=RNGS;

       // ONE: THE ROW. Hidden outside a same machine mode, shown in one, and it cycles the pick and keeps it.
       NET.same=''; renderParty();
       if(shown(g('partypad'))) bad.push('the CONTROLLER row shows outside a same machine mode');
       NET.same='host'; NET.pair=PAIR; NET.mode='coop'; NET.bc=ch; NET.padIx=-1; NET.padOther=-1; NET.padFwd=null;
       renderParty();
       if(!shown(g('partypad'))) bad.push('the CONTROLLER row is not shown in a same machine mode');
       if(txt(g('partypadbtn')).indexOf('CONTROLLER')<0) bad.push('the CONTROLLER row does not name a controller: '+txt(g('partypadbtn')));
       ch.posted=[];
       var c1=netPadCycle(); renderParty();
       if(c1!==0||NET.padIx!==0) bad.push('one press on the CONTROLLER row did not pick controller 1 (pick '+NET.padIx+')');
       if(txt(g('partypadbtn')).indexOf('CONTROLLER 1')<0) bad.push('the row does not read CONTROLLER 1 after one press: '+txt(g('partypadbtn')));
       var pk=last('padpick');
       if(!pk||pk.pair!==PAIR||pk.ix!==0) bad.push('the pick was not told to the other window ('+js(pk)+')');
       if(ls(KH)!=='0') bad.push('the host pick is not kept under '+KH+' (it holds '+ls(KH)+')');
       netPadCycle(); netPadCycle(); netPadCycle();
       if(NET.padIx!==3) bad.push('four presses did not reach controller 4 (pick '+NET.padIx+')');
       netPadCycle();
       if(NET.padIx!==-1||ls(KH)!==null) bad.push('a fifth press did not come round to none (pick '+NET.padIx+', kept '+ls(KH)+')');

       // THE PICK IS TOLD. The real same machine pick (the second window, the code maker and the channel stood in) reads the
       // pick kept from last time and tells the player 2 window; a ready from player 2 is answered with it again; the real
       // player 2 boot reads its own kept pick and tells the host, and ready stays the last word of the boot.
       NET.bc=null; NET.same=''; NET.pair=''; NET.mode='';
       netReset();
       spied=true;
       window.open=function(){ return {closed:false}; };
       window.BroadcastChannel=BC;
       netHost=function(){ return {then:function(){}}; };
       NET.start=function(){};
       try{ localStorage.setItem(KH,'2'); localStorage.setItem(KP,'1'); }catch(_lk){}
       var k1=netSamePick('coop',function(){});
       if(k1!=='opened'||NET.same!=='host'||!NET.bc||chans.length!==1) bad.push('the stand-in same machine pick did not open ('+k1+', same '+NET.same+', channels '+chans.length+')');
       else {
         if(NET.padIx!==2) bad.push('the host pick kept from last time was not read at the pick (pick '+NET.padIx+')');
         var t1=lastOf(chans[0].posted,'padpick');
         if(!t1||t1.ix!==2||t1.pair!==NET.pair) bad.push('the host pick was not told to the player 2 window at the pick ('+js(t1)+')');
         chans[0].posted=[];
         netSameOnMsg({t:'ready',pair:NET.pair});
         var t2=lastOf(chans[0].posted,'padpick');
         if(!t2||t2.ix!==2) bad.push('a ready from player 2 was not answered with the host pick ('+js(chans[0].posted)+')');
       }
       netReset();
       if(NET.same||NET.bc||NET.padOther!==-1) bad.push('ending the party did not let go of the channel and the other window pick (same '+NET.same+', other '+NET.padOther+')');
       chans=[];
       var b2=netSameBootP2(PAIR,'coop');
       if(b2!=='ready'||chans.length!==1) bad.push('the stand-in player 2 boot did not get ready ('+b2+', channels '+chans.length+')');
       else {
         if(NET.padIx!==1) bad.push('the player 2 pick kept from last time was not read at boot (pick '+NET.padIx+')');
         var t3=lastOf(chans[0].posted,'padpick'), rd=chans[0].posted.length?chans[0].posted[chans[0].posted.length-1]:null;
         if(!t3||t3.ix!==1||t3.pair!==PAIR) bad.push('the player 2 pick was not told to the host at boot ('+js(t3)+')');
         if(!rd||rd.t!=='ready') bad.push('ready is not the last word of the player 2 boot ('+js(rd)+')');
       }
       NET.bc=null; NET.same=''; NET.pair=''; NET.mode='';   // a player 2 boot keeps its channel across netReset; the stand-in is let go by hand
       netReset();
       unspy();
       try{ localStorage.removeItem(KH); localStorage.removeItem(KP); }catch(_lk2){}
       // Back to the stand-in state for the frames below.
       NET.same='host'; NET.pair=PAIR; NET.mode='coop'; NET.bc=ch; NET.padIx=-1; NET.padOther=-1; NET.padFwd=null;

       // TWO: THE HOST IN FRONT. With no pick it plays no pad and hands player 2 the first connected pad; with controller 1
       // picked it plays that and hands player 2 controller 2, with its buttons, its trigger and its sticks, never its own.
       var P0=pad(0,[3],[0,0,0,0]), P1=pad(1,[0,5],[0.6,-0.4,0,0],{6:0.4});
       pads([P0,P1]); hf.v=true; hf.n=0; ch.posted=[];
       NET.padIx=-1; NET.padOther=-1; NET.padFwd=null;
       frame();
       if(PAD.on) bad.push('the host with no controller picked plays a pad (buttons down '+downs()+')');
       if(keys.KeyF||keys.KeyE) bad.push('the host with no controller picked holds a key from a pad (F '+!!keys.KeyF+', E '+!!keys.KeyE+')');
       var h1=posts('pad');
       if(h1.length!==1) bad.push('one frame of the host in front handed over '+h1.length+' states, not one');
       else if(h1[0].pair!==PAIR||h1[0].ix!==0||h1[0].own!==-1||!h1[0].p||h1[0].p[3]!==1||h1[0].p[0]!==0) bad.push('the host with no pick did not hand player 2 the first connected pad, controller 1 with Y down ('+js(h1[0])+')');
       netPadSet(0); ch.posted=[];
       frame();
       if(!PAD.on) bad.push('the host that picked controller 1 plays no pad');
       if(!keys.KeyF||keys.KeyE||keys.KeyT) bad.push('the host that picked controller 1 does not hold its Y as F, or holds E or T from the other pad (F '+!!keys.KeyF+', E '+!!keys.KeyE+', T '+!!keys.KeyT+')');
       if(!PAD.prev[3]||PAD.prev[0]||PAD.prev[5]) bad.push('the host reads the wrong pad: buttons down '+downs()+', not 3');
       var h2=posts('pad');
       if(h2.length!==1) bad.push('the host that picked controller 1 handed over '+h2.length+' states in one frame, not one');
       else {
         var m2=h2[0];
         if(m2.ix!==1||m2.own!==0) bad.push('the host hands player 2 pad '+m2.ix+' (its own is '+m2.own+'), not controller 2');
         if(!m2.p||m2.p[0]!==1||m2.p[5]!==1||m2.p[3]!==0) bad.push('the state handed over does not carry controller 2 with A and RB down and Y up ('+js(m2.p)+')');
         if(!m2.v||Math.abs(m2.v[6]-0.4)>0.011) bad.push('the state handed over does not carry the trigger part way ('+js(m2.v)+')');
         if(!same(m2.a,[0.6,-0.4,0,0])) bad.push('the state handed over does not carry the sticks ('+js(m2.a)+')');
       }
       frame(); frame();
       if(posts('pad').length!==3) bad.push('three frames in front handed over '+posts('pad').length+' states, not three');
       // A pick both windows made goes to the host; a pick of a pad that is not there is handed nothing; another pair is ignored.
       if(netSameOnMsg({t:'padpick',pair:PAIR,ix:0})!=='padpick'||NET.padOther!==0) bad.push('the player 2 pick did not reach the host (other '+NET.padOther+')');
       ch.posted=[]; frame();
       var h3=last('pad');
       if(!h3||h3.ix!==1||!PAD.prev[3]) bad.push('with both windows picking controller 1 the host did not keep it and hand player 2 controller 2 ('+js(h3)+', host down '+downs()+')');
       netSameOnMsg({t:'padpick',pair:PAIR,ix:2}); ch.posted=[]; frame();
       if(posts('pad').length) bad.push('player 2 picked controller 3, which is not plugged in, and was handed '+js(last('pad'))+' instead of nothing');
       if(netSameOnMsg({t:'padpick',pair:'zqxotherpair',ix:1})!=='ignored'||NET.padOther!==2) bad.push('a pick from another pair code was taken (other '+NET.padOther+')');
       netSameOnMsg({t:'padpick',pair:PAIR,ix:1}); ch.posted=[]; frame();
       if(!last('pad')||last('pad').ix!==1) bad.push('player 2 picking controller 2 is not handed it ('+js(last('pad'))+')');
       // The host not in front: nothing goes out, its own read is not played, and a state handed over by player 2 is.
       hf.v=false; ch.posted=[]; NET.padOther=-1;
       frame();
       if(posts('pad').length) bad.push('the host not in front handed over a state');
       if(PAD.on||keys.KeyF) bad.push('the host not in front plays its own read (on '+PAD.on+', F '+!!keys.KeyF+')');
       var r1=netSameOnMsg(fwd(0,1,[2],[0,0.5,0,0]));
       if(r1!=='pad'||NET.padOther!==1) bad.push('a state handed over by player 2 was not kept ('+r1+', other '+NET.padOther+')');
       frame();
       if(!PAD.on||!keys.KeyR||keys.KeyF||!PAD.prev[2]||PAD.prev[3]) bad.push('the host not in front does not play the state handed over: on '+PAD.on+', R '+!!keys.KeyR+', F '+!!keys.KeyF+', down '+downs());
       if(!PAD.ax||Math.abs(PAD.ax[1]-0.5)>1e-6||Math.abs(PAD.my-padAxis(0.5))>1e-6) bad.push('the sticks handed over did not reach the pad fields (ax '+js(PAD.ax)+', my '+PAD.my+')');
       if(netSameOnMsg(fwd(1,1,[2]))!=='padown') bad.push('a state from the other window own pad was kept');
       if(netSameOnMsg(fwd(1,0,[2]))!=='padnot') bad.push('a state from a pad the host did not pick was kept');
       if(netSameOnMsg(fwd(0,1,[2]))!=='pad') bad.push('control: a state from the pad the host picked was refused');
       NET.padFwd.at-=1;
       frame();
       if(PAD.on||keys.KeyR) bad.push('a state handed over a second ago is still played (on '+PAD.on+', R '+!!keys.KeyR+')');
       NET.padIx=-1;
       if(netSameOnMsg(fwd(0,1,[2]))!=='padnone') bad.push('the host with no pick took a state handed over');

       // THREE: PLAYER 2. Not in front: its own read is ignored, the state handed over drives the reader and the keys it holds
       // are the ones the buttons handed over hold. In front: its own pad wins and the host is handed its pad.
       NET.same='p2'; NET.padIx=-1; NET.padOther=-1; NET.padFwd=null; ch.posted=[]; hf.v=false;
       var OWN=pad(0,[2],[-0.7,0,0,0]);
       pads([OWN]);
       frame();
       if(PAD.on||keys.KeyR||keys.KeyE) bad.push('player 2 not in front plays its own read (on '+PAD.on+', R '+!!keys.KeyR+')');
       var r2=netSameOnMsg(fwd(1,0,[0,3],[0.6,-0.4,0,0]));
       if(r2!=='pad'||NET.padOther!==0) bad.push('the state the host handed over was not kept ('+r2+', other '+NET.padOther+')');
       frame();
       if(!PAD.on) bad.push('player 2 not in front does not play the state handed over');
       if(!keys.KeyE||!keys.KeyF||keys.KeyR) bad.push('the buttons handed over do not hold their keys (E '+!!keys.KeyE+', F '+!!keys.KeyF+'), or the own pad X holds R ('+!!keys.KeyR+')');
       if(!PAD.prev[0]||!PAD.prev[3]||PAD.prev[2]) bad.push('the reader shows buttons '+downs()+' down, not 0 and 3 handed over');
       if(!same(PAD.ax,[0.6,-0.4,0,0])||Math.abs(PAD.mx-padAxis(0.6))>1e-6||Math.abs(PAD.my-padAxis(-0.4))>1e-6) bad.push('the sticks handed over did not reach the pad fields (ax '+js(PAD.ax)+', mx '+PAD.mx+', my '+PAD.my+')');
       if(posts('pad').length) bad.push('player 2 not in front handed a state to the host');
       if(netSameOnMsg(fwd(0,0,[0]))!=='padown') bad.push('player 2 kept a state from the host own pad');
       if(netSameOnMsg({t:'pad',pair:'zqxotherpair',ix:1,own:0,p:[1],v:[1],a:[0,0,0,0]})!=='ignored') bad.push('player 2 kept a state from another pair');
       if(netSameOnMsg({t:'pad',pair:PAIR,ix:1,own:0,p:[1,0],v:[1],a:[0,0,0,0]})!=='bad') bad.push('a state with buttons and values of different lengths was kept');
       // In front: the own pad wins (controller 2, since the host holds controller 1), the state handed over is dropped, and
       // the host is handed controller 1 with nothing of player 2 in it.
       hf.v=true; ch.posted=[];
       pads([pad(0,[4],[0,0,0,0]),pad(1,[2],[-0.7,0,0,0])]);
       frame();
       if(!PAD.on||!keys.KeyR||keys.KeyE||keys.KeyF||!PAD.prev[2]||PAD.prev[0]||PAD.prev[3]||PAD.prev[4]) bad.push('player 2 in front does not play its own pad, controller 2 (on '+PAD.on+', R '+!!keys.KeyR+', E '+!!keys.KeyE+', down '+downs()+')');
       if(!same(PAD.ax,[-0.7,0,0,0])) bad.push('player 2 in front does not read its own sticks (ax '+js(PAD.ax)+')');
       if(NET.padFwd) bad.push('player 2 in front kept the state handed over earlier');
       var h4=posts('pad');
       if(h4.length!==1||h4[0].ix!==0||h4[0].own!==-1||!h4[0].p||h4[0].p[4]!==1||h4[0].p[2]!==0) bad.push('player 2 in front did not hand the host its controller 1 with LB down and nothing of its own ('+js(h4)+')');
       netPadSet(1); renderParty();
       if(ls(KP)!=='1'||NET.padIx!==1||!last('padpick')||last('padpick').ix!==1) bad.push('the player 2 pick is not kept under '+KP+' and told to the host (kept '+ls(KP)+', pick '+NET.padIx+')');
       if(txt(g('partypadbtn')).indexOf('CONTROLLER 2')<0) bad.push('the player 2 row does not read CONTROLLER 2: '+txt(g('partypadbtn')));
       ch.posted=[]; frame();
       if(!keys.KeyR||keys.KeyE||!last('pad')||last('pad').ix!==0) bad.push('player 2 that picked controller 2 does not play it and hand the host controller 1 (R '+!!keys.KeyR+', handed '+js(last('pad'))+')');
       netPadSet(0); ch.posted=[]; frame();
       if(!keys.KeyR||PAD.prev[4]||!last('pad')||last('pad').ix!==0) bad.push('player 2 picking the host controller 1 was given it: down '+downs()+', handed '+js(last('pad')));
       netPadSet(1); hf.v=false; pads([OWN]); ch.posted=[];
       if(netSameOnMsg(fwd(0,-1,[0]))!=='padnot') bad.push('player 2 that picked controller 2 kept a state from controller 1');
       if(netSameOnMsg(fwd(1,0,[0]))!=='pad') bad.push('control: player 2 that picked controller 2 refused a state from it');
       frame();
       if(!keys.KeyE||keys.KeyR) bad.push('player 2 not in front with a pick does not play the state handed over (E '+!!keys.KeyE+', R '+!!keys.KeyR+')');
       if(posts('pad').length) bad.push('player 2 not in front with a pick handed a state to the host');
       netPadSet(-1);
       if(ls(KP)!==null) bad.push('a pick of none left '+KP+' behind ('+ls(KP)+')');

       // FOUR: CONTROL. Outside a same machine mode nothing is handed over, focus is never asked, a state handed over is not
       // played, and the first connected pad is read as before.
       NET.same=''; NET.pair=''; NET.padFwd=null; ch.posted=[]; hf.n=0; hf.v=false;
       pads([P0,P1]);
       frame();
       if(!PAD.on||!keys.KeyF||keys.KeyE||!PAD.prev[3]||PAD.prev[0]) bad.push('control: outside a same machine mode the first connected pad is not read as before (on '+PAD.on+', F '+!!keys.KeyF+', down '+downs()+')');
       if(ch.posted.length) bad.push('control: outside a same machine mode a state was handed over');
       if(hf.n) bad.push('control: outside a same machine mode the reader asked about focus '+hf.n+' times');
       NET.pair=PAIR;
       if(netSameOnMsg(fwd(0,1,[2]))==='pad'||NET.padFwd) bad.push('control: outside a same machine mode a state handed over was kept');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the hand-over');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.padFwd=null; NET.padOther=(keepNet?keepNet.padOther:-1); NET.padIx=(keepNet?keepNet.padIx:-1); }catch(_n){}
       try{ netReset(); }catch(_nr){}
       try{ unspy(); }catch(_us){}
       try{ NET.pick=''; NET.p2url=''; }catch(_np){}
       try{ netModeMsg(''); }catch(_mm){}
       try{ if(lsWas){ if(lsWas.h===null) localStorage.removeItem(KH); else localStorage.setItem(KH,lsWas.h); if(lsWas.p===null) localStorage.removeItem(KP); else localStorage.setItem(KP,lsWas.p); } }catch(_l){}
       try{ if(hfStub){ if(hadHF) document.hasFocus=oHF; else delete document.hasFocus; } }catch(_h2){}
       try{ if(stubbed){ navigator.getGamepads=function(){ return []; }; pollPad(); } }catch(_p0){}
       try{ padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.on=keepPad.on; PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; PAD.ax=keepPad.ax; PAD.mrep=keepPad.mrep; PAD.mx=keepPad.mx; PAD.my=keepPad.my; PAD.prev=keepPad.prev; } }catch(_kp){}
       try{ for(var k3 in keys) keys[k3]=false; }catch(_k3){}
       try{ if(keepP&&HB&&HB.player){ HB.player.x=keepP.x; HB.player.y=keepP.y; HB.player.face=keepP.face; HB.eLock=true; } }catch(_hp){}
       try{ renderParty(); }catch(_rp){}
       try{ closeAll(); }catch(_ca){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
