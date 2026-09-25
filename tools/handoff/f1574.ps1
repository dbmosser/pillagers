$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.74. The fixture runner (__regress and __regressBg) does not await a promise a check returns: a promise is a truthy
# non-SKIP answer and would be recorded as a failure. So this check is synchronous and never makes a real connection; the live
# link between two copies is tools/nettest.html, run by hand. The pcBoot property runs once when the fixture loads, before the
# game boots, and counts every peer connection made in the page and every ask for the microphone from then on.
SubRx @'
  {v:'15.73',what:
'@ @'
  {v:'15.74',what:'two copies of the game link up by invite code, and solo play is untouched: the game boots with the net section present and off and no peer connection made in the page, an invite code and a reply code round-trip a sample offer and answer exactly (a chat line break inside the code changes nothing, and a restore code, a cut code and plain words are not read as one), the window reports how long the code is, the host turns away a hello from another version or protocol and lets in the same version with a roster of two, which the joining copy reads back, the seeded stream does not move through any of it, a save under the ?netslot=A key leaves the main save, the save pointer and the save in play untouched, and F at the lift opens the PARTY window, which TAB, ESC and controller B close (multiplayer build 1)',
   pcBoot:(function(){
     var o=window.__pcBoot||{made:0,gum:0,wrapped:false,err:''};
     if(!window.__pcBoot){
       window.__pcBoot=o;
       try{
         var R=window.RTCPeerConnection;
         if(typeof R==='function'&&typeof Proxy==='function'&&typeof Reflect==='object'){
           window.RTCPeerConnection=new Proxy(R,{construct:function(t,a){ o.made++; return Reflect.construct(t,a); }});
           o.wrapped=true;
         }
       }catch(e){ o.err=String(e&&e.message||e); }
       try{
         var md=navigator.mediaDevices;
         if(md&&typeof md.getUserMedia==='function'){ var gum=md.getUserMedia; md.getUserMedia=function(){ o.gum++; return gum.apply(md,arguments); }; }
       }catch(e2){}
     }
     return o;
   })(),
   run:function(){
     // THE NET SECTION IS THERE. Without it two copies cannot link up at all, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netOnMsg!=='function'||typeof netStartHost!=='function'||typeof netStartJoin!=='function'||
        typeof sdpPackPlain!=='function'||typeof sdpUnpackPlain!=='function'||typeof netSlotOf!=='function'||typeof netSlotKey!=='function'||
        typeof openParty!=='function'||typeof renderParty!=='function'||typeof netReset!=='function')
       return 'this build has no net section (NET, the hello handler, the invite code packer, the ?netslot save and the PARTY window), so two copies of the game cannot link up';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and a party is made in the Undercroft';
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     var bad=[], PCB=window.__pcBoot||null, S0=SKEY, kA=null, lsWas=null, rng0=null, keepP=null, keepPad=null, lift=null, i;
     var _s2=say2, pm=document.getElementById('partymodal'), NG=navigator.getGamepads, stubbed=false;
     var MAIN='salvagerun:profile', AS='salvagerun:activeSlot';
     function ls(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
     // A later part that cannot run keeps a failure already found.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     // A stand-in link that speaks the protocol and records what it is sent. Never a real connection.
     function fake(){
       var f={id:-1,pc:null,state:'open',seat:-1,pid:'',name:'',timers:[],sent:[]};
       f.dc={readyState:'open',send:function(x){ f.sent.push(String(x)); },close:function(){}};
       return f;
     }
     function said(f,t){ for(var k=0;k<f.sent.length;k++){ var q=null; try{ q=JSON.parse(f.sent[k]); }catch(_j){} if(q&&q.t===t) return q; } return null; }
     function padWith(down){
       var bts=[],q;
       for(q=0;q<17;q++) bts.push({pressed:(q===down),value:(q===down)?1:0,touched:(q===down)});
       var fk={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fk]; };
     }
     try{
       __topClear();
       // ONE: OFF AT BOOT, with no peer connection made and no microphone asked for.
       if(NET.on!==false||NET.role!==null||NET.peers.length!==0) bad.push('the net section is not off at boot: on '+NET.on+', role '+NET.role+', '+NET.peers.length+' links');
       if(NET.made!==0) bad.push('the net section has made '+NET.made+' peer connections with nobody pressing HOST or JOIN');
       if(PCB&&PCB.wrapped&&PCB.made!==0) bad.push(PCB.made+' peer connections were made in this page since the fixture loaded, with nobody pressing HOST or JOIN');
       if(PCB&&PCB.gum!==0) bad.push('the microphone was asked for '+PCB.gum+' times since the fixture loaded');
       // The Undercroft floor with nothing open over it, and from here the seeded stream is held still.
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       // A pause box left up freezes the floor, so F could never reach the lift.
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       say2=function(){};   // who joined is said on the floor; kept off the floor for the checks after this one
       rng0=RNGS;
       // TWO: THE CODE. A sample offer and answer, CRLF and all, round-trip exactly through the plain code.
       var SDP=['v=0','o=- 4611731400430051336 2 IN IP4 127.0.0.1','s=-','t=0 0','a=group:BUNDLE 0','a=extmap-allow-mixed','a=msid-semantic: WMS',
         'm=application 54321 UDP/DTLS/SCTP webrtc-datachannel','c=IN IP4 203.0.113.7',
         'a=candidate:1467250027 1 udp 2122260223 7c1d3f0e-5a2b-4c6d-8e9f-0a1b2c3d4e5f.local 54321 typ host generation 0 network-id 1',
         'a=candidate:2999745851 1 tcp 1518280447 7c1d3f0e-5a2b-4c6d-8e9f-0a1b2c3d4e5f.local 9 typ host tcptype active generation 0 network-id 1',
         'a=candidate:842163049 1 udp 1686052607 203.0.113.7 54321 typ srflx raddr 0.0.0.0 rport 0 generation 0 network-id 1',
         'a=ice-ufrag:Zq3x','a=ice-pwd:k9Qe1vX2mB7nR4tY8uW0sZ5a','a=ice-options:trickle',
         'a=fingerprint:sha-256 3B:9C:1F:07:A2:5E:66:D4:0B:8F:13:C7:2A:94:E1:5D:70:BB:08:36:CF:41:9A:E2:57:1C:D8:63:0F:A5:B9:24',
         'a=setup:actpass','a=mid:0','a=sctp-port:5000','a=max-message-size:262144',''].join('\r\n');
       var SDPA=SDP.split('a=setup:actpass').join('a=setup:active');
       var co=String(sdpPackPlain({type:'offer',sdp:SDP})||''), ca=String(sdpPackPlain({type:'answer',sdp:SDPA})||'');
       var uo=sdpUnpackPlain(co), ua=sdpUnpackPlain(ca);
       if(co.indexOf('PTY1o')!==0||ca.indexOf('PTY1a')!==0) bad.push('the plain codes do not start PTY1o for an invite and PTY1a for a reply: they start '+co.slice(0,6)+' and '+ca.slice(0,6));
       if(!uo||uo.type!=='offer'||uo.sdp!==SDP) bad.push('a sample invite code did not unpack to the same offer'+(uo?(' (type '+uo.type+', '+String(uo.sdp).length+' characters against '+SDP.length+')'):''));
       if(!ua||ua.type!=='answer'||ua.sdp!==SDPA) bad.push('a sample reply code did not unpack to the same answer');
       // A chat window that breaks the code over lines, with words round it, changes nothing.
       var uw=sdpUnpackPlain('Here it is: '+co.replace(/(.{60})/g,'$1\r\n ')+' .');
       if(!uw||uw.sdp!==SDP) bad.push('an invite code broken over lines by a chat window, with words round it, no longer unpacks to the same offer');
       // CONTROLS: a restore code, a cut code and plain words are not invite codes.
       if(sdpUnpackPlain('PIL1'+co.slice(4))!==null) bad.push('control: a restore code is read as an invite code');
       if(sdpUnpackPlain(co.slice(0,60))!==null) bad.push('control: an invite code cut to 60 characters still unpacks');
       if(sdpUnpackPlain('hello there')!==null) bad.push('control: plain words unpack as an invite code');
       // THREE: THE HOST TURNS AWAY ANOTHER VERSION OR PROTOCOL AND LETS IN THIS ONE, through the real hello handler.
       netStartHost();
       var fw=fake(), fp=fake(), fr=fake();
       NET.peers.push(fw); NET.peers.push(fp); NET.peers.push(fr);
       var aw=netOnMsg(fw,JSON.stringify({t:'hello',proto:NET.proto,ver:'0.01',pid:'0badc0de',name:'ZQX OLD COPY'}));
       var ap=netOnMsg(fp,JSON.stringify({t:'hello',proto:NET.proto+1,ver:VER,pid:'0badf00d',name:'ZQX OLD WIRE'}));
       var mw=said(fw,'reject'), mp=said(fp,'reject');
       if(!mw||mw.why!=='version') bad.push('a hello from a copy on v0.01 was not turned away for its version (the handler said '+aw+' and sent '+(fw.sent.join(' ')||'nothing')+')');
       if(!mp||mp.why!=='version') bad.push('a hello on protocol '+(NET.proto+1)+' was not turned away (the handler said '+ap+' and sent '+(fp.sent.join(' ')||'nothing')+')');
       if(said(fw,'welcome')||said(fp,'welcome')) bad.push('a copy on another version or protocol was let in');
       if(NET.roster.length!==1) bad.push('with two wrong copies turned away the host roster holds '+NET.roster.length+', not the host alone');
       // CONTROL: the same version and protocol is let in, in the second seat, with a roster of two sent to it and kept by the host.
       var ar=netOnMsg(fr,JSON.stringify({t:'hello',proto:NET.proto,ver:VER,pid:'cafef00d',name:'ZQX SAME COPY'}));
       var mr=said(fr,'welcome');
       if(!mr) bad.push('control: a hello from a copy on the same version v'+VER+' was not let in (the handler said '+ar+' and sent '+(fr.sent.join(' ')||'nothing')+')');
       else if(mr.you!==1||!mr.roster||mr.roster.length!==2) bad.push('the copy let in was given seat '+mr.you+' and a roster of '+(mr.roster?mr.roster.length:0)+', not seat 1 of 2');
       if(NET.roster.length!==2) bad.push('with one copy let in the host roster holds '+NET.roster.length+', not 2');
       else if(NET.roster[1].name!=='ZQX SAME COPY'||NET.roster[1].pid!=='cafef00d'||!NET.roster[0].host) bad.push('the host roster reads '+JSON.stringify(NET.roster)+', not the host and the copy let in');
       // FOUR: THE WINDOW REPORTS HOW LONG A CODE IS.
       NET.code=co; renderParty();
       var lenT=String((document.getElementById('partylen')||{}).textContent||'');
       if(lenT.indexOf(String(co.length))<0) bad.push('the PARTY window does not report the invite code length: its length line reads "'+lenT+'" for a code of '+co.length+' characters');
       netReset();
       if(NET.on||NET.role!==null||NET.peers.length) bad.push('the net section is not off again after the party ends: on '+NET.on+', role '+NET.role+', '+NET.peers.length+' links');
       // FIVE: THE JOINING COPY READS THE WELCOME BACK AS A ROSTER OF TWO, and a turn-away as the end of the party.
       netStartJoin();
       var fh=fake(); fh.seat=0; NET.peers.push(fh);
       netOnMsg(fh,JSON.stringify(mr||{t:'welcome',you:1,roster:[{seat:0,pid:'aaaaaaaa',name:'ZQX HOST',host:true},{seat:1,pid:'cafef00d',name:'ZQX SAME COPY',host:false}]}));
       if(NET.seat!==1||NET.roster.length!==2) bad.push('a joining copy handed the welcome reads seat '+NET.seat+' and a roster of '+NET.roster.length+', not seat 1 of 2');
       netReset();
       netStartJoin();
       var fx=fake(); fx.seat=0; NET.peers.push(fx);
       netOnMsg(fx,JSON.stringify({t:'reject',why:'version',ver:'0.01',proto:NET.proto}));
       if(NET.role!==null||String(NET.err).indexOf('0.01')<0) bad.push('a joining copy turned away for its version did not leave the party and say which version the host is on (role '+NET.role+', "'+NET.err+'")');
       netReset();
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the net code');
       // SIX: A SAVE UNDER ?netslot=A HAS A KEY OF ITS OWN.
       if(netSlotOf('?netslot=A')!=='A'||netSlotOf('?zq=1&netslot=B')!=='B') bad.push('the ?netslot override does not read A and B off the address');
       if(netSlotOf('')!==''||netSlotOf('?netslot=C')!==''||netSlotOf('?netslot=')!==''||netSlotOf('?xnetslot=A')!=='') bad.push('control: an address without netslot A or B picks a net save');
       if(typeof NETSLOT!=='undefined'&&NETSLOT) return skip('this page was itself opened with ?netslot, so the main save cannot be told apart here');
       kA=netSlotKey('A');
       if(kA===netSlotKey('B')||kA===MAIN||kA===S0||kA.indexOf(MAIN+':net')!==0) bad.push('the netslot save key '+kA+' is not a key of its own beside '+MAIN);
       lsWas={main:ls(MAIN),as:ls(AS),own:ls(S0),a:ls(kA)};
       SKEY=kA; saveProfile(); var lsA=ls(kA); SKEY=S0;
       var dA=null; try{ dA=JSON.parse(lsA); }catch(_p){}
       if(!dA||typeof dA.credits!=='number') bad.push('a save made under ?netslot=A wrote no readable save under '+kA);
       if(ls(MAIN)!==lsWas.main) bad.push('a save made under ?netslot=A changed the main save '+MAIN);
       if(ls(AS)!==lsWas.as) bad.push('a save made under ?netslot=A moved the save pointer '+AS);
       if(ls(S0)!==lsWas.own) bad.push('a save made under ?netslot=A changed the save this page plays, '+S0);
       // SEVEN: F AT THE LIFT OPENS THE PARTY WINDOW, through the real floor, and TAB, ESC and controller B close it.
       if(!pm) return skip('there is no PARTY window in the page');
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.stations||!HB.player) return skip('the Undercroft floor is not up here');
       for(i=0;i<HB.stations.length;i++) if(HB.stations[i]&&HB.stations[i].id==='lift') lift=HB.stations[i];
       if(!lift) return skip('the floor has no lift');
       var A=lift.acts||{};
       // CONTROL: the lift keeps its three acts, named as before.
       if(!A.KeyE||A.KeyE[0]!=='go up'||!A.KeyR||A.KeyR[0]!=='quick ascent'||!A.KeyT||A.KeyT[0]!=='the terms') bad.push('control: the lift lost or renamed one of go up, quick ascent and the terms ('+Object.keys(A).join(',')+')');
       if(!A.KeyF||A.KeyF[0]!=='party') bad.push('the lift has no F act named party ('+Object.keys(A).join(',')+')');
       else {
         keepP={x:HB.player.x,y:HB.player.y,face:HB.player.face};
         for(var k0 in keys) keys[k0]=false;
         HB.player.x=lift.x; HB.player.y=lift.y; HB.player.rollT=0; HB.eLock=false;
         keys['KeyF']=true; updateHubWorld(1/60); keys['KeyF']=false;
         if(!pm.classList.contains('on')) bad.push('F on the lift did not open the PARTY window (the floor had '+(HB.near?HB.near.id:'no station')+' in front of him)');
         else {
           if(NET.on||NET.made!==0||(PCB&&PCB.wrapped&&PCB.made!==0)) bad.push('opening the PARTY window switched the net section on or made a peer connection');
           // TAB, on window only: a key sent to the document reaches the window too and would act twice.
           window.dispatchEvent(new KeyboardEvent('keydown',{code:'Tab',key:'Tab',bubbles:true,cancelable:true}));
           window.dispatchEvent(new KeyboardEvent('keyup',{code:'Tab',key:'Tab',bubbles:true}));
           if(pm.classList.contains('on')){ bad.push('TAB did not close the PARTY window'); pm.classList.remove('on'); }
           // ESC, on the document where the window rule listens, as check 10.10 presses it.
           openParty();
           if(pm.classList.contains('on')){
             document.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
             if(pm.classList.contains('on')){ bad.push('ESC did not close the PARTY window'); pm.classList.remove('on'); }
           }
           // B on a faked controller, when the window is laid out for the pad to work it.
           openParty();
           try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
           if(stubbed&&typeof pollPad==='function'&&typeof padFocusables==='function'&&typeof PAD!=='undefined'&&padFocusables(pm).length){
             keepPad={aSpent:PAD.aSpent,announced:PAD.announced,ax:PAD.ax,mrep:PAD.mrep};
             padWith(-1); pollPad(); padWith(1); pollPad(); padWith(-1); pollPad();
             if(pm.classList.contains('on')) bad.push('B on a controller did not close the PARTY window');
           }
           pm.classList.remove('on');
         }
       }
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' while the PARTY window opened and closed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ netReset(); }catch(_n){}
       try{ SKEY=S0; }catch(_k){}
       try{ if(kA&&lsWas){ if(lsWas.a===null) localStorage.removeItem(kA); else localStorage.setItem(kA,lsWas.a); } }catch(_l){}
       try{ if(pm){ pm.classList.remove('on'); var ae=document.activeElement; if(ae&&pm.contains(ae)&&ae.blur) ae.blur(); } }catch(_m){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; PAD.ax=keepPad.ax; PAD.mrep=keepPad.mrep; } }catch(_kp){}
       try{ for(var k3 in keys) keys[k3]=false; }catch(_k3){}
       try{ if(keepP&&HB&&HB.player){ HB.player.x=keepP.x; HB.player.y=keepP.y; HB.player.face=keepP.face; HB.eLock=true; } }catch(_hp){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
