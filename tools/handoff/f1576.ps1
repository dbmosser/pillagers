$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.76',what:")) { throw "check 15.76 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.76. Synchronous, as the fixture runner (__regress and __regressBg) does not await a promise a check returns, and it
# never opens a window or makes a connection: window.open, BroadcastChannel and the three code makers (netHost, netJoin,
# netAccept) are stand-ins for the length of the check, the channel words are fed to the real netSameOnMsg, and the roster of
# two comes through the real hello and welcome handlers. The live pairing of two real windows is tools/nettest.html, by hand.
SubRx @'
  {v:'15.75',what:
'@ @'
  {v:'15.76',what:'the title opens on a mode menu and two windows on one PC pair up: the menu shows five rows in his order and wording (1 PLAYER, 2 PLAYER CO-OP (SAME MACHINE), 2 PLAYER CO-OP (SERVER), 2 PLAYER PVP (SAME MACHINE), PVP (SERVER)) with the two server rows greyed and marked coming later, the first row being the old start button; 1 PLAYER runs the old start with the net section off, no window opened, no channel made and no peer connection made; a same machine row with the second window blocked keeps the title up, sets no mode and shows the sentence with RETRY, and RETRY with the window allowed records the address of this page with p2=1, the mode and the pair code, makes the channel, makes this copy the host and runs the start; the arrows step the highlight down the rows past the greyed ones and wrap, ENTER presses the highlighted row and with none highlighted starts 1 PLAYER, a faked controller lands on 1 PLAYER, steps down to the co-op row and presses it with A, and B and ESC leave the title as it is; ?p2=1 picks the player 2 save key, a save under it leaves the main save, the save pointer and the save in play untouched, and the pointer lock holds for it; the handshake carried on a stand-in channel reaches a roster of two on the host and on the player 2 side, a word with another pair code is ignored, and the seeded stream never moves (multiplayer build 3)',
   run:function(){
     // THE MENU IS THERE. Without it there is no way to pick a mode, so the old build fails here rather than skips.
     var mm=document.getElementById('modemenu'), t=document.getElementById('title');
     if(!mm||!t||typeof NET==='undefined'||!NET||typeof netSamePick!=='function'||typeof netSameOnMsg!=='function'||typeof netSameBootP2!=='function'||
        typeof netSameHostDone!=='function'||typeof netSameJoinDone!=='function'||typeof netP2Of!=='function'||typeof netP2Key!=='function'||
        typeof netModeOf!=='function'||typeof netPairOf!=='function'||typeof netSaveLocked!=='function'||typeof netTitleMove!=='function'||typeof netTitleEnter!=='function')
       return 'this build has no mode menu on the title screen (no #modemenu, no netSamePick, no netSameOnMsg, no netSameBootP2 and no player 2 save key), so the first thing a player picks is not the mode and two windows on one PC cannot pair up';
     if(typeof netOnMsg!=='function'||typeof netStartJoin!=='function'||typeof netReset!=='function'||typeof renderParty!=='function') return 'this build has no net section under the mode menu';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the mode is picked on the title';
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     var bad=[], PCB=window.__pcBoot||null, pcb0=PCB?PCB.made:0, made0=NET.made, rng0=null, keepP=null, keepPad=null, i;
     var wasOn=t.classList.contains('on'), _s2=say2, NG=navigator.getGamepads, stubbed=false, S0=SKEY, kP=null, lsWas=null;
     var oOpen=window.open, hadBC=('BroadcastChannel' in window), oBC=window.BroadcastChannel, oH=netHost, oJ=netJoin, oA=netAccept, oStart=NET.start, oNP2=(typeof NETP2!=='undefined')?NETP2:undefined;
     var opens=[], chans=[], calls={host:0,join:0,accept:0,start:0,msg:0}, openRet=null, codes={join:'',accept:''}, spied=false;
     var MAIN='salvagerun:profile', AS='salvagerun:activeSlot', mo=document.getElementById('partymode');
     var g=function(id){ return document.getElementById(id); };
     function ls(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function stop(){ return bad.join('; '); }
     function txt(el){ return String((el&&el.textContent)||'').replace(/\s+/g,' ').replace(/^ | $/g,''); }
     function shown(el){ return !!el&&el.style.display!=='none'; }
     function lastPost(){ var c=NET.bc; return (c&&c.posted&&c.posted.length)?c.posted[c.posted.length-1]:null; }
     function js(o){ return JSON.stringify(o); }
     // A stand-in link that speaks the protocol and records what it is sent. Never a real connection.
     function fake(){
       var f={id:-1,pc:null,state:'open',seat:-1,pid:'',name:'',timers:[],sent:[]};
       f.dc={readyState:'open',send:function(x){ f.sent.push(String(x)); },close:function(){}};
       return f;
     }
     // A stand-in channel: records what is posted, and a check hands it words through its onmessage.
     function BC(name){ this.name=String(name); this.posted=[]; this.onmessage=null; this.closed=false; chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){ this.closed=true; };
     // A code maker that never resolves, so nothing runs after the check has put everything back.
     function pending(){ return {then:function(){}}; }
     function padWith(down){
       var bts=[],q;
       for(q=0;q<17;q++) bts.push({pressed:(q===down),value:(q===down)?1:0,touched:(q===down)});
       var fk={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fk]; };
     }
     function keyOn(code){
       window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true}));
     }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     function noFocus(){ try{ padSetFocus(null); PAD.focus=null; }catch(_f){} }
     try{
       __topClear();
       try{ __hubEnter(); }catch(_h){}
       closeAll();   // a fresh profile opens the welcome window
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       if(typeof state==='undefined'||!HB||!HB.player) return skip('the Undercroft floor is not up here');
       netReset();
       say2=function(){};
       for(var k0 in keys) keys[k0]=false;
       keepP={x:HB.player.x,y:HB.player.y,face:HB.player.face};
       rng0=RNGS;
       // THE STAND-INS: no window opens, no channel is real, no code is made.
       spied=true;
       window.open=function(u,nm,ft){ opens.push({url:String(u),name:nm,feat:ft}); return openRet; };
       window.BroadcastChannel=BC;
       netHost=function(){ calls.host++; return pending(); };
       netJoin=function(c){ calls.join++; codes.join=String(c); return pending(); };
       netAccept=function(c){ calls.accept++; codes.accept=String(c); return pending(); };
       NET.start=function(){ calls.start++; };

       // ONE: THE ROWS, in his order and wording, the server rows greyed and marked coming later, the first row the old start.
       var rows=mm.querySelectorAll('button[data-mode]'), want=['1 PLAYER','2 PLAYER CO-OP (SAME MACHINE)','2 PLAYER CO-OP (SERVER)','2 PLAYER PVP (SAME MACHINE)','PVP (SERVER)'];
       if(rows.length!==5) bad.push('the mode menu has '+rows.length+' rows, not five');
       for(i=0;i<Math.min(rows.length,5);i++) if(txt(rows[i])!==want[i]) bad.push('row '+(i+1)+' reads '+txt(rows[i])+', not '+want[i]);
       if(rows.length===5){
         if(!rows[2].disabled||!rows[4].disabled) bad.push('the two server rows are not greyed out');
         if(rows[0].disabled||rows[1].disabled||rows[3].disabled) bad.push('a row that plays today is greyed out');
         if(txt(rows[2].parentNode).toLowerCase().indexOf('coming later')<0||txt(rows[4].parentNode).toLowerCase().indexOf('coming later')<0) bad.push('a greyed server row is not marked coming later beside it');
         if(rows[0].id!=='titlestart') bad.push('the first row is not the old start button (its id is '+rows[0].id+'), so the pad focus and ENTER no longer land on it');
         if(!g('modecoop')||!g('modepvp')||g('modecoop').getAttribute('data-mode')!=='coop'||g('modepvp').getAttribute('data-mode')!=='pvp') bad.push('the two same machine rows are not #modecoop and #modepvp with their modes');
       }
       if(!g('modemsg')||!g('moderetry')) bad.push('the title has no sentence or RETRY for a blocked second window');
       if(!mo) bad.push('the PARTY window has no line naming the mode');

       // TWO: 1 PLAYER IS THE OLD START. The title goes, the floor is up, and the net section did nothing at all.
       t.classList.add('on'); noFocus();
       g('titlestart').click();
       if(t.classList.contains('on')) bad.push('1 PLAYER did not take the title down');
       if(state!=='hub') bad.push('1 PLAYER did not put him on the Undercroft floor (state '+state+')');
       if(NET.on||NET.role!==null||NET.mode||NET.same||NET.pair) bad.push('1 PLAYER switched the net section on: on '+NET.on+', role '+NET.role+', mode '+NET.mode+', same '+NET.same);
       if(opens.length) bad.push('1 PLAYER opened a second window');
       if(chans.length) bad.push('1 PLAYER made a channel between windows');
       if(calls.host||calls.join||calls.accept) bad.push('1 PLAYER made an invite or reply code');
       if(NET.made!==made0||(PCB&&PCB.wrapped&&PCB.made!==pcb0)) bad.push('1 PLAYER made a peer connection');
       closeAll();
       // And ENTER with nothing highlighted is the same start.
       t.classList.add('on'); noFocus();
       keyOn('Enter');
       if(t.classList.contains('on')) bad.push('ENTER on the title with nothing highlighted did not start 1 PLAYER');
       if(NET.on||NET.mode||opens.length||chans.length) bad.push('ENTER on the title with nothing highlighted ran net code');
       closeAll();

       // THREE: A SAME MACHINE ROW. Blocked first: the title stays, no mode is set, the sentence and RETRY show.
       t.classList.add('on'); noFocus();
       openRet=null;
       var r1=netSamePick('coop');
       if(r1!=='blocked') bad.push('with the second window blocked the pick said '+r1+', not blocked');
       if(NET.mode||NET.same||NET.on) bad.push('with the second window blocked the mode was set anyway: mode '+NET.mode+', same '+NET.same+', on '+NET.on);
       if(!t.classList.contains('on')) bad.push('with the second window blocked the title went away');
       if(calls.start) bad.push('with the second window blocked the start ran anyway');
       if(!shown(g('modemsg'))||!txt(g('modemsg'))) bad.push('with the second window blocked no sentence is shown on the title');
       else if(txt(g('modemsg')).toLowerCase().indexOf('popup')<0) bad.push('the blocked sentence does not tell him to allow the popup: '+txt(g('modemsg')));
       if(!shown(g('moderetry'))) bad.push('with the second window blocked RETRY is not offered');
       if(chans.length) bad.push('with the second window blocked a channel was made anyway');
       // RETRY with the window allowed: the address, the mode, the host, the channel, the start.
       var win={closed:false}, opened=opens.length;
       openRet=win;
       g('moderetry').click();
       var o=opens.length>opened?opens[opens.length-1]:null, base=String(location.href).split('#')[0].split('?')[0];
       if(!o) bad.push('RETRY did not open the second window');
       else {
         if(o.url.indexOf(base+'?')!==0) bad.push('the second window is not this page: '+o.url);
         if(!(/[?&]p2=1(&|$)/).test(o.url)) bad.push('the second window address has no p2=1: '+o.url);
         if(!(/[?&]mode=coop(&|$)/).test(o.url)) bad.push('the second window address does not carry the mode picked: '+o.url);
         if(!NET.pair||NET.pair.length<4||!(/[?&]pair=[a-z0-9]{4,16}(&|$)/).test(o.url)||o.url.indexOf('pair='+NET.pair)<0) bad.push('the second window address does not carry the pair code '+NET.pair+': '+o.url);
         if(o.url!==NET.p2url) bad.push('the address recorded on the net section is not the one opened');
       }
       if(NET.mode!=='coop'||NET.same!=='host'||!NET.on||NET.role!=='host'||NET.p2win!==win) bad.push('after RETRY this copy is not the host in co-op: mode '+NET.mode+', same '+NET.same+', on '+NET.on+', role '+NET.role);
       if(chans.length!==1||NET.bc!==chans[0]) bad.push('after RETRY there is not one channel between the windows ('+chans.length+' made)');
       else if(typeof chans[0].onmessage!=='function') bad.push('the channel has nothing listening on it');
       if(calls.host!==1) bad.push('after RETRY the invite code was made '+calls.host+' times, not once');
       if(calls.start!==1) bad.push('after RETRY the title start ran '+calls.start+' times, not once');
       if(shown(g('modemsg'))||shown(g('moderetry'))) bad.push('after RETRY the blocked sentence or RETRY is still shown');
       if(NET.made!==made0||(PCB&&PCB.wrapped&&PCB.made!==pcb0)) bad.push('the check itself made a peer connection, which it must never do');
       renderParty();
       if(mo&&(!shown(mo)||txt(mo).indexOf('CO-OP')<0||txt(mo).indexOf('SAME MACHINE')<0)) bad.push('the PARTY window does not name the mode: '+txt(mo));
       // PVP is the other same machine row, and only the mode value differs.
       netReset();
       if(NET.mode||NET.same||NET.pair||NET.bc||!chans[0].closed) bad.push('ending the party did not let go of the mode, the pair code and the channel');
       var r2=netSamePick('pvp');
       if(r2!=='opened'||NET.mode!=='pvp'||!(/[?&]mode=pvp(&|$)/).test(String(NET.p2url))) bad.push('the PVP row did not set the pvp mode ('+r2+', mode '+NET.mode+', '+NET.p2url+')');
       renderParty();
       if(mo&&txt(mo).indexOf('PVP')<0) bad.push('the PARTY window does not name the pvp mode: '+txt(mo));

       // FOUR: THE HANDSHAKE ON THE CHANNEL, host side. The invite code goes out when made and again when player 2 is ready,
       // a reply code is taken with netAccept, a word with another pair code is ignored, and the hello makes a roster of two.
       var ch=NET.bc, pair=NET.pair, CO='PTY1o'+'pzqxinvite', CA='PTY1a'+'pzqxreply';
       if(!ch||typeof ch.onmessage!=='function'){ bad.push('the pvp pick made no channel to carry the handshake'); return stop(); }
       var oMsg=netSameOnMsg; netSameOnMsg=function(){ calls.msg++; return oMsg.apply(null,arguments); };
       ch.posted=[];
       var d1=netSameHostDone({code:CO}), p1=lastPost();
       if(d1!=='offer'||!p1||p1.t!=='offer'||p1.pair!==pair||p1.mode!=='pvp'||p1.code!==CO) bad.push('the invite code made did not go out on the channel with the pair code and the mode ('+d1+', '+js(p1)+')');
       ch.posted=[];
       ch.onmessage({data:{t:'ready',pair:'zqxwrongpair'}});
       if(calls.msg!==1) bad.push('a word on the channel did not reach netSameOnMsg through the channel');
       if(ch.posted.length) bad.push('a ready from another pair code was answered');
       NET.pend={state:'offer'}; NET.code=CO;
       var d2=netSameOnMsg({t:'ready',pair:pair}), p2=lastPost();
       if(d2!=='offer'||!p2||p2.t!=='offer'||p2.code!==CO) bad.push('a ready from player 2 did not send the invite code out again ('+d2+', '+js(p2)+')');
       NET.pend=null; NET.code='';
       var d3=netSameOnMsg({t:'answer',pair:'zqxwrongpair',code:CA});
       if(d3!=='ignored'||calls.accept) bad.push('a reply code with another pair code was taken ('+d3+')');
       var d4=netSameOnMsg({t:'answer',pair:pair,code:CA});
       if(d4!=='accept'||calls.accept!==1||codes.accept!==CA) bad.push('the reply code on the channel was not taken with netAccept ('+d4+', taken '+calls.accept+' times, code '+codes.accept+')');
       if(netSameOnMsg({t:'answer',pair:pair,code:7})!=='bad') bad.push('a reply that is not a code was taken');
       var f1=fake(); NET.peers.push(f1);
       var h1=netOnMsg(f1,js({t:'hello',proto:NET.proto,ver:VER,pid:'f1f1f1f1',name:'ZQX PLAYER TWO'}));
       if(h1!=='welcome'||NET.roster.length!==2||f1.seat!==1) bad.push('after the handshake the hello did not make a roster of two on the host ('+h1+', '+NET.roster.length+')');
       var d5=netSameOnMsg({t:'fail',pair:pair,why:'zqx no link'});
       if(d5!=='fail'||String(NET.err).indexOf('zqx no link')<0) bad.push('a failure said by player 2 is not shown on the host ('+d5+', '+NET.err+')');
       netReset();
       if(NET.same||NET.bc||!ch.closed||NET.on) bad.push('ending the party did not close the channel');

       // FIVE: THE PLAYER 2 SIDE. Booted with a pair code and a mode, it says ready, takes the invite code with netJoin, adopts
       // the mode the host says, posts its reply code, and reads the welcome back as seat 1 of two.
       chans=[];
       var b1=netSameBootP2('zqxpair22','coop');
       if(b1!=='ready'||NET.same!=='p2'||NET.pair!=='zqxpair22'||NET.mode!=='coop') bad.push('the player 2 boot did not get ready ('+b1+', same '+NET.same+', pair '+NET.pair+', mode '+NET.mode+')');
       var c2=NET.bc, r0=lastPost();
       if(chans.length!==1||!c2||!r0||r0.t!=='ready'||r0.pair!=='zqxpair22') bad.push('the player 2 window did not tell the host it is ready on the channel ('+js(r0)+')');
       if(netSameOnMsg({t:'offer',pair:'zqxother',mode:'coop',code:CO})!=='ignored'||calls.join) bad.push('player 2 took an invite code from another pair');
       var j1=netSameOnMsg({t:'offer',pair:'zqxpair22',mode:'pvp',code:CO});
       if(j1!=='join'||calls.join!==1||codes.join!==CO) bad.push('the invite code on the channel was not taken with netJoin ('+j1+', taken '+calls.join+' times)');
       if(NET.mode!=='pvp') bad.push('player 2 did not take the mode the host says ('+NET.mode+')');
       if(c2) c2.posted=[];
       var j2=netSameJoinDone({code:CA}), a2=lastPost();
       if(j2!=='answer'||!a2||a2.t!=='answer'||a2.pair!=='zqxpair22'||a2.code!==CA) bad.push('the reply code did not go back on the channel ('+j2+', '+js(a2)+')');
       var j3=netSameJoinDone({err:'zqx bad code'}), a3=lastPost();
       if(j3!=='err'||!a3||a3.t!=='fail'||String(a3.why).indexOf('zqx bad code')<0) bad.push('a failed join is not said to the host on the channel ('+j3+', '+js(a3)+')');
       netStartJoin();
       var fh=fake(); fh.seat=0; NET.peers.push(fh);
       var w1=netOnMsg(fh,js({t:'welcome',you:1,ver:VER,roster:[{seat:0,pid:'aaaaaaaa',name:'ZQX HOST',host:true},{seat:1,pid:'bbbbbbbb',name:'ZQX ME',host:false}]}));
       if(w1!=='welcome'||NET.seat!==1||NET.roster.length!==2) bad.push('player 2 handed the welcome does not read seat 1 of two ('+w1+', seat '+NET.seat+', '+NET.roster.length+')');
       netReset();
       netSameOnMsg=oMsg;
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the handshake');

       // SIX: THE PLAYER 2 SAVE KEY. ?p2=1 is read off the address, the key is its own, and a save under it touches nothing else.
       if(!netP2Of('?p2=1')||!netP2Of('?mode=coop&p2=1&pair=abcd')) bad.push('?p2=1 is not read off the address');
       if(netP2Of('')||netP2Of('?p2=0')||netP2Of('?p2=12')||netP2Of('?xp2=1')||netP2Of('?netslot=A')) bad.push('control: an address without p2=1 picks the player 2 save');
       if(netModeOf('?p2=1&mode=pvp&pair=abcd')!=='pvp'||netModeOf('?mode=coop')!=='coop'||netModeOf('?mode=zzz')!==''||netModeOf('')!=='') bad.push('the mode is not read off the address');
       if(netPairOf('?pair=abcd1234')!=='abcd1234'||netPairOf('?p2=1&pair=zq12&mode=coop')!=='zq12'||netPairOf('?pair=AB')!==''||netPairOf('')!=='') bad.push('the pair code is not read off the address');
       kP=netP2Key();
       if(kP===MAIN||kP===S0||kP===netSlotKey('A')||kP===netSlotKey('B')||kP.indexOf(MAIN+':')!==0||kP.indexOf(':net')>=0) bad.push('the player 2 save key '+kP+' is not a key of its own beside '+MAIN);
       if(typeof NETP2!=='boolean') bad.push('the page does not read NETP2 off its address (it is '+typeof NETP2+')');
       else {
         NETP2=true; var l1=netSaveLocked(); NETP2=oNP2;
         if(!l1) bad.push('the save pointer lock does not hold for the player 2 window');
         if(!NETSLOT&&!oNP2&&netSaveLocked()) bad.push('control: the save pointer lock holds for an ordinary copy');
       }
       if((typeof NETSLOT!=='undefined'&&NETSLOT)||oNP2) return skip('this page was itself opened with ?netslot or ?p2=1, so the main save cannot be told apart here');
       lsWas={main:ls(MAIN),as:ls(AS),own:ls(S0),p2:ls(kP)};
       SKEY=kP; saveProfile(); var lsP=ls(kP); SKEY=S0;
       var dP=null; try{ dP=JSON.parse(lsP); }catch(_p){}
       if(!dP||typeof dP.credits!=='number') bad.push('a save made under ?p2=1 wrote no readable save under '+kP);
       if(ls(MAIN)!==lsWas.main) bad.push('a save made under ?p2=1 changed the main save '+MAIN);
       if(ls(AS)!==lsWas.as) bad.push('a save made under ?p2=1 moved the save pointer '+AS);
       if(ls(S0)!==lsWas.own) bad.push('a save made under ?p2=1 changed the save this page plays, '+S0);

       // SEVEN: KEYBOARD AND CONTROLLER. The arrows step the highlight down the rows past the greyed ones and wrap, ENTER
       // presses the highlighted row; a faked controller lands on 1 PLAYER, steps down to the co-op row and presses it with A;
       // B and ESC leave the title as it is.
       t.classList.add('on'); noFocus(); calls.start=0; opens=[]; chans=[];
       keyOn('ArrowDown');
       if(PAD.focus!==g('modecoop')) bad.push('ArrowDown on the title did not move the highlight to the co-op row (it is on '+(PAD.focus?txt(PAD.focus):'nothing')+')');
       else if(!g('modecoop').classList.contains('padfocus')) bad.push('the highlighted row is not drawn highlighted');
       keyOn('ArrowDown');
       if(PAD.focus!==g('modepvp')) bad.push('a second ArrowDown did not step past the greyed server row to the pvp row (it is on '+(PAD.focus?txt(PAD.focus):'nothing')+')');
       keyOn('ArrowDown');
       if(PAD.focus!==g('titlestart')) bad.push('a third ArrowDown did not wrap to 1 PLAYER (it is on '+(PAD.focus?txt(PAD.focus):'nothing')+')');
       keyOn('ArrowUp');
       if(PAD.focus!==g('modepvp')) bad.push('ArrowUp from 1 PLAYER did not wrap to the pvp row');
       keyOn('KeyW');
       if(PAD.focus!==g('modecoop')) bad.push('W did not move the highlight up to the co-op row');
       keyOn('Enter');
       if(NET.mode!=='coop'||opens.length!==1||calls.start!==1) bad.push('ENTER on the highlighted co-op row did not pick co-op (mode '+NET.mode+', windows '+opens.length+', starts '+calls.start+')');
       if(!(/[?&]mode=coop(&|$)/).test(opens.length?opens[0].url:'')) bad.push('ENTER on the co-op row opened the wrong address: '+(opens.length?opens[0].url:'none'));
       netReset(); closeAll();
       // The controller, when the title is laid out for the pad to work it.
       t.classList.add('on'); noFocus(); calls.start=0; opens=[];
       try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
       var pf=(typeof padFocusables==='function')?padFocusables(t):[];
       if(stubbed&&typeof pollPad==='function'&&typeof PAD!=='undefined'&&pf.indexOf(g('titlestart'))>=0&&pf.indexOf(g('modecoop'))>=0){
         keepPad={aSpent:PAD.aSpent,announced:PAD.announced,ax:PAD.ax,mrep:PAD.mrep};
         padWith(-1); pollPad(); pollPad();
         if(PAD.focus!==g('titlestart')) bad.push('the pad focus on the title lands on '+(PAD.focus?txt(PAD.focus):'nothing')+', not 1 PLAYER');
         padWith(13); pollPad(); padWith(-1); pollPad();
         if(PAD.focus!==g('modecoop')) bad.push('D-pad down from 1 PLAYER lands on '+(PAD.focus?txt(PAD.focus):'nothing')+', not the co-op row');
         padWith(1); pollPad(); padWith(-1); pollPad();
         if(!t.classList.contains('on')||NET.mode||opens.length) bad.push('B on the title changed something: title '+t.classList.contains('on')+', mode '+NET.mode+', windows '+opens.length);
         if(PAD.focus===g('modecoop')){
           padWith(0); pollPad(); padWith(-1); pollPad();
           if(NET.mode!=='coop'||opens.length!==1||calls.start!==1) bad.push('A on the highlighted co-op row did not pick co-op (mode '+NET.mode+', windows '+opens.length+', starts '+calls.start+')');
         }
       }
       netReset(); closeAll();
       // ESC on the document, with the title up: nothing happens.
       t.classList.add('on'); noFocus();
       document.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       document.dispatchEvent(new KeyboardEvent('keyup',{code:'Escape',key:'Escape',bubbles:true}));
       if(!t.classList.contains('on')) bad.push('ESC took the title away');
       if(NET.on||NET.mode||document.querySelector('.modal.on')) bad.push('ESC on the title changed something');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' while the mode menu was worked');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ netReset(); }catch(_n){}
       try{ NET.pick=''; NET.p2url=''; }catch(_np){}
       try{ if(spied){ window.open=oOpen; if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_db){ window.BroadcastChannel=undefined; } } netHost=oH; netJoin=oJ; netAccept=oA; NET.start=oStart; } }catch(_r){}
       try{ if(typeof NETP2!=='undefined'&&oNP2!==undefined) NETP2=oNP2; }catch(_n2){}
       try{ SKEY=S0; }catch(_k){}
       try{ if(kP&&lsWas){ if(lsWas.p2===null) localStorage.removeItem(kP); else localStorage.setItem(kP,lsWas.p2); } }catch(_l){}
       try{ netModeMsg(''); }catch(_mm){}
       try{ closeAll(); }catch(_ca){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; PAD.aSpent=0; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; PAD.ax=keepPad.ax; PAD.mrep=keepPad.mrep; } }catch(_kp){}
       try{ for(var k3 in keys) keys[k3]=false; }catch(_k3){}
       try{ if(keepP&&HB&&HB.player){ HB.player.x=keepP.x; HB.player.y=keepP.y; HB.player.face=keepP.face; HB.eLock=true; } }catch(_hp){}
       try{ if(wasOn) t.classList.add('on'); else t.classList.remove('on'); }catch(_t){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.75',what:
'@

SubRx @'
       var SKIP={titlestart:1,titlefs:1,delgo:1,newgame:1};
'@ @'
       // v15.76: the mode rows open the player 2 window (window.open) and RETRY re-runs the pick, so a corpus must not press them;
       // in the Browser pane the popup opens in the same tab and ends the run. Check 15.76 covers them with window.open stubbed.
       var SKIP={titlestart:1,titlefs:1,delgo:1,newgame:1,modecoop:1,modepvp:1,modecoopsrv:1,modepvpsrv:1,moderetry:1};
'@
SubRx @'
      return /UNDERCROFT|ENTER/i.test(b.textContent); })[0]:null;
'@ @'
      return b.id==='titlestart'||(/UNDERCROFT|ENTER|1 PLAYER/i).test(b.textContent); })[0]:null;   // v15.76: the button is the 1 PLAYER row
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
