$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.75',what:")) { throw "check 15.75 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.75. Synchronous, as the fixture runner (__regress and __regressBg) does not await a promise a check returns, and it
# never makes a real connection: stand-in links speak the protocol through the real netOnMsg, and the floor is driven through
# the real updateHubWorld and drawHubWorld. The live walk between two copies is tools/nettest.html, run by hand.
# The frames are held still: dt 0, and tickHubCrowd (the crowd errands, which roll Math.random) stubbed for the length of the
# check, so a solo frame and a party frame can be compared operator by operator.
SubRx @'
  {v:'15.74',what:
'@ @'
  {v:'15.75',what:'the party sees each other on the Undercroft floor, and solo play is untouched: with the party off a floor frame draws exactly the operators it drew before and calls none of the net floor code, and a floor update sends nothing and eases nobody, even with a friend left in the list behind a stand-in link that was let in; with the party on the floor update ticks the net floor code, with the PARTY window open too, and sends where he stands (x, y, facing and walking, his look in the first packet) about ten times a second on the fast channel when it is open and the reliable one when not; the host files a friend under the seat of his link whatever seat he claims, keeps his look to rack ids, passes him on to the other friend and never back, refuses a position that is not a number and one from a link that never said hello, eases him toward a new spot rather than jumping, and draws him once with the operator body in his own fit and hair where he stands, sorted with the player, with his name over him, the rest of the frame exactly as solo; a joining copy files the host and the other friend and ignores its own seat, a seat outside the roster and a position with no seat; a bye, a lost link or a roster without him takes him off the floor, and the seeded stream never moves (multiplayer build 2)',
   run:function(){
     // THE FLOOR CODE IS THERE. Without it two linked copies never see each other, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netOnMsg!=='function'||typeof netStartHost!=='function'||typeof netStartJoin!=='function'||
        typeof netReset!=='function'||typeof netDrop!=='function')
       return 'this build has no net section, so nobody else can be drawn on the Undercroft floor';
     if(typeof netHubTick!=='function'||typeof netDrawPeers!=='function'||typeof netDrawPeer!=='function')
       return 'this build draws nobody else on the Undercroft floor: there is no netHubTick to send where he stands and no netDrawPeers or netDrawPeer to draw the others, so two linked copies cannot see each other';
     if(!NET.floor||typeof NET.floor.length!=='number') return 'the net section keeps no list of who stands where on the floor (NET.floor)';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the party meets on the Undercroft floor';
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     var bad=[], rng0=null, i, k, ops=[], texts=[], pm=document.getElementById('partymodal');
     var oOp=drawOp, oCrowd=(typeof tickHubCrowd==='function')?tickHubCrowd:null, oTick=netHubTick, oPeers=netDrawPeers, oPeer=netDrawPeer;
     var oTags=(typeof netDrawTags==='function')?netDrawTags:null, _s2=say2, calls={tick:0,peers:0,peer:0,tags:0};
     var keepP=null, keepH=null, fillOwn=false, oFill=null, spied=false, SAYT=(typeof HUBSAY_T==='number')?HUBSAY_T:null;
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function stop(){ return bad.join('; '); }
     // A stand-in link that speaks the protocol and records what it is sent. Never a real connection.
     function fake(){
       var f={id:-1,pc:null,state:'open',seat:-1,pid:'',name:'',timers:[],sent:[]};
       f.dc={readyState:'open',send:function(x){ f.sent.push(String(x)); },close:function(){}};
       return f;
     }
     // And its fast channel, open, recording apart from the reliable one.
     function withFast(f){ f.fs=[]; f.fc={readyState:'open',send:function(x){ f.fs.push(String(x)); },close:function(){}}; return f; }
     function js(o){ return JSON.stringify(o); }
     function sts(list){ var out=[], q, j; for(j=0;j<(list||[]).length;j++){ q=null; try{ q=JSON.parse(list[j]); }catch(_j){} if(q&&q.t==='st') out.push(q); } return out; }
     function lastOf(a){ return a.length?a[a.length-1]:null; }
     function sig(list){
       var out=[], j, o;
       for(j=0;j<list.length;j++){ o=list[j]; out.push([(+o.x).toFixed(2),(+o.y).toFixed(2),(+o.f||0).toFixed(3),o.mode,o.hero?1:0].join(',')); }
       return out.join('|');
     }
     function drawnAs(own){ var out=[], j; for(j=0;j<ops.length;j++) if(own&&ops[j].own===own) out.push(ops[j]); return out; }
     function drawnBut(own){ var out=[], j; for(j=0;j<ops.length;j++) if(ops[j].own!==own) out.push(ops[j]); return out; }
     function painted(t){ return texts.join('|').indexOf(t)>=0; }
     function near1(o,x,y){ return !!o&&Math.abs(o.x-x)<=1&&Math.abs(o.y-y)<=1; }
     function xy(o){ return o?((+o.x).toFixed(1)+','+(+o.y).toFixed(1)):'nowhere'; }
     function home(){ var q=HB.player; q.x=keepP.x; q.y=keepP.y; q.face=keepP.face; q.moving=keepP.moving; q.rollT=keepP.rollT; q.bob=keepP.bob; HB.t=keepH.t; }
     function frame(){
       ops=[]; texts=[];
       try{ drawHubWorld(0); }catch(e){ bad.push('a floor frame threw: '+(e&&e.message||e)); }
     }
     try{
       __topClear();
       try{ __hubEnter(); }catch(_h){}
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });   // a fresh profile opens the welcome window
       try{ var pbx=document.getElementById('pausebox'); if(pbx&&pbx.classList.contains('on')){ try{ togglePauseBox(false); }catch(_tp){} if(pbx.classList.contains('on')){ pbx.classList.remove('on'); pauseOpen=false; } } }catch(_pb){}
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player||!wc) return skip('the Undercroft floor is not up here');
       netReset();
       say2=function(){};   // who joined is said on the floor; kept off it here
       for(k in keys) keys[k]=false;
       keepP={x:HB.player.x,y:HB.player.y,face:HB.player.face,moving:HB.player.moving,rollT:HB.player.rollT,bob:HB.player.bob};
       keepH={t:HB.t,near:HB.near,eLock:HB.eLock};
       rng0=RNGS;
       // THE SPIES: every operator drawn, every string painted on the floor canvas, every call into the net floor code.
       fillOwn=Object.prototype.hasOwnProperty.call(wc,'fillText'); oFill=wc.fillText;
       spied=true;
       drawOp=function(x,y,face,ph,coat,pk,mz,mode,iv,st){
         ops.push({x:x,y:y,f:face,mode:String(mode),coat:coat,hero:!!(st&&st.hero),hair:st?st.hair:undefined,own:(st&&st.own)||null});
         return oOp.apply(null,arguments);
       };
       if(oCrowd) tickHubCrowd=function(){};
       netHubTick=function(){ calls.tick++; return oTick.apply(null,arguments); };
       netDrawPeers=function(){ calls.peers++; return oPeers.apply(null,arguments); };
       netDrawPeer=function(){ calls.peer++; return oPeer.apply(null,arguments); };
       if(oTags) netDrawTags=function(){ calls.tags++; return oTags.apply(null,arguments); };
       wc.fillText=function(t){ texts.push(String(t)); return oFill.apply(wc,arguments); };

       // ONE: SOLO PLAY. With no party a floor frame calls none of the net floor code. The first frame settles anyone the
       // floor would still push out of a wall; the second is the solo frame every later frame is held to.
       frame();
       frame();
       var soloSig=sig(ops), soloN=ops.length;
       if(!soloN) return skip('the floor drew no operator at all, so there is nothing to compare');
       if(calls.peers||calls.peer||calls.tags) bad.push('with no party a floor frame still called into the net floor code ('+calls.peers+' list, '+calls.peer+' body, '+calls.tags+' names)');
       // A friend left in the list with the party off: staged through the real handlers, then the party switched off under him.
       netStartHost();
       var fl=fake(); NET.peers.push(fl);
       var al=netOnMsg(fl,js({t:'hello',proto:NET.proto,ver:VER,pid:'1e11e11e',name:'ZQX LEFT BEHIND'}));
       var sl=netOnMsg(fl,js({t:'st',x:211.5,y:233.5,f:0.5,m:1,r:0}));
       var gl=NET.floor[fl.seat]||null;
       if(al!=='welcome'||sl!=='state'||!gl){ bad.push('could not stage a friend on the floor through the real handlers (his hello said '+al+', his position said '+sl+')'); return stop(); }
       NET.on=false;
       calls={tick:0,peers:0,peer:0,tags:0}; fl.sent=[];
       gl.tx=gl.x+40; gl.ty=gl.y+30;
       var glx=gl.x, gly=gl.y;
       updateHubWorld(1/60); updateHubWorld(0.25);
       home();
       frame();
       if(calls.tick) bad.push('with the party off a floor update still called netHubTick ('+calls.tick+' times)');
       if(calls.peers||calls.peer||calls.tags) bad.push('with the party off and a friend still in the list a floor frame called into the net floor code ('+calls.peers+' list, '+calls.peer+' body, '+calls.tags+' names)');
       if(sts(fl.sent).length) bad.push('with the party off a floor update still sent where he stands: '+fl.sent[0]);
       if(gl.x!==glx||gl.y!==gly) bad.push('with the party off a floor update still eased the friend left in the list');
       if(sig(ops)!==soloSig) bad.push('with the party off and a friend left in the list the floor frame drew '+ops.length+' operators, not the '+soloN+' of the solo frame'+(drawnAs(gl).length?' (the friend among them)':''));
       if(painted('ZQX LEFT BEHIND')) bad.push('with the party off the name of a friend left in the list is still painted');
       var dl=[];
       if((oPeers(dl)||0)!==0||dl.length) bad.push('netDrawPeers with the party off still puts '+dl.length+' on the floor');
       if((oTick(0.5)||0)!==0||sts(fl.sent).length) bad.push('netHubTick with the party off still sends');
       netReset();

       // TWO: THE HOST. Two friends let in through the real hello handler; the one on seat 1 has his fast channel open.
       netStartHost();
       var f1=withFast(fake()), f2=fake(), f3=fake();
       NET.peers.push(f1); NET.peers.push(f2);
       var h1=netOnMsg(f1,js({t:'hello',proto:NET.proto,ver:VER,pid:'f1f1f1f1',name:'ZQX NEAR FRIEND'}));
       var h2=netOnMsg(f2,js({t:'hello',proto:NET.proto,ver:VER,pid:'f2f2f2f2',name:'ZQX FAR FRIEND'}));
       if(h1!=='welcome'||h2!=='welcome'||f1.seat!==1||f2.seat!==2){ bad.push('two stand-in friends were not let in as seats 1 and 2 (they heard '+h1+' and '+h2+')'); return stop(); }
       f1.sent=[]; f1.fs=[]; f2.sent=[];
       // Junk is refused, and so is a link that never said hello.
       var j1=netOnMsg(f1,js({t:'st',x:0,y:5,f:0}).replace(':0,',':1e999,')), j2=netOnMsg(f1,js({t:'st',x:'300',y:200,f:0}));
       NET.peers.push(f3);
       var j3=netOnMsg(f3,js({t:'st',x:100,y:100,f:0}));
       if(j1==='state'||j2==='state') bad.push('a position that is not a number was filed (the handler said '+j1+' and '+j2+')');
       if(j3==='state') bad.push('a link that never said hello had his position filed');
       for(i=0;i<NET.floor.length;i++) if(NET.floor[i]){ bad.push('a refused position left seat '+i+' on the floor'); break; }
       // The friend on seat 1 says where he stands, and claims seat 3.
       var s1=netOnMsg(f1,js({t:'st',s:3,x:300,y:200,f:0.5,m:0,r:0,lk:{fit:'moss',hair:'red',hat:'zqxnohat'}}));
       var g1=NET.floor[1]||null;
       if(s1!=='state'||!g1){ bad.push('the position of the friend on seat 1 was not filed (the handler said '+s1+')'); return stop(); }
       if(NET.floor[3]) bad.push('the host filed a friend under the seat he claimed, 3, not the seat of his link');
       if(!near1(g1,300,200)) bad.push('the first position from a friend did not put him where he said: '+xy(g1)+' for 300,200');
       if(!g1.lk||g1.lk.fit!=='moss'||g1.lk.hair!=='red'||g1.lk.hat!==undefined) bad.push('his look was not kept to rack ids: '+js(g1.lk));
       var r2=lastOf(sts(f2.sent));
       if(!r2||r2.s!==1||!near1(r2,300,200)) bad.push('the host did not pass the friend on seat 1 on to the friend on seat 2 ('+(f2.sent.join(' ')||'nothing sent')+')');
       else if(!r2.lk||r2.lk.fit!=='moss'||r2.lk.hat!==undefined) bad.push('the look passed on is not the cleaned one: '+js(r2.lk));
       if(sts(f1.sent).length||sts(f1.fs).length) bad.push('the host sent a friend his own position back');
       // A new spot eases him there rather than jumping.
       netOnMsg(f1,js({t:'st',x:340,y:230,f:1,m:1,r:0}));
       if(!near1(g1,300,200)) bad.push('a new position jumped the friend there at once: he is at '+xy(g1));
       netHubTick(1/60);
       if(!(g1.x>300.5&&g1.x<339.5&&g1.y>200.3&&g1.y<229.7)) bad.push('one floor tick after a new position the friend is at '+xy(g1)+', not part way from 300,200 to 340,230');
       // Where the host stands goes out while it ticks, and the friend arrives.
       HB.player.x=123.4; HB.player.y=234.5; HB.player.face=0.77; HB.player.moving=true; HB.player.rollT=0;
       f1.sent=[]; f1.fs=[]; f2.sent=[];
       for(i=0;i<60;i++) netHubTick(1/60);
       if(!near1(g1,340,230)) bad.push('a second after his new position the friend is drawn at '+xy(g1)+', not at 340,230');
       var q1=sts(f1.fs), q1r=sts(f1.sent), q2=sts(f2.sent), o1=lastOf(q1);
       if(!o1) bad.push('the host sent no position on the fast channel of the friend who has it open'+(q1r.length?' (it went on the reliable one)':''));
       else {
         if(o1.s!==0||Math.abs(o1.x-123.4)>0.05||Math.abs(o1.y-234.5)>0.05||Math.abs(o1.f-0.77)>0.01||o1.m!==1) bad.push('the host position reads '+js(o1)+', not seat 0 at 123.4,234.5 facing 0.77 and walking');
         if(q1.length<8||q1.length>11) bad.push('the host sent '+q1.length+' positions in a second of floor ticks, not about ten');
         if(!q1[0].lk||q1[0].lk.fit!==cosWorn('fit')||q1[0].lk.hair!==cosWorn('hair')) bad.push('the first position the host sent does not carry what he is wearing: '+js(q1[0].lk));
       }
       if(q1r.length) bad.push('the host put '+q1r.length+' positions on the reliable channel of a friend whose fast channel is open');
       if(!q2.length) bad.push('the host sent no position to the friend without a fast channel, where the reliable channel is the way');
       // THE FRAME. The friend is drawn once, as another body in his own fit and hair, where he stands, sorted with the player,
       // named over his head, and the rest of the frame is the solo frame operator for operator.
       home();
       frame();
       var m1=drawnAs(g1);
       if(m1.length!==1) bad.push('with the party on the floor drew the friend '+m1.length+' times, not once');
       else {
         if(m1[0].hero) bad.push('the friend was drawn as the player himself, not as another body');
         if(!near1(m1[0],340,230)) bad.push('the friend was drawn at '+xy(m1[0])+', not at 340,230 where he said he stands');
         if(m1[0].coat!==FITCOL.moss[1]||m1[0].hair!=='red') bad.push('the friend was not dressed from his own racks: coat '+m1[0].coat+' and hair '+m1[0].hair+' for moss and red');
         var hi=-1, gi=-1;
         for(i=0;i<ops.length;i++){ if(ops[i].hero&&hi<0) hi=i; if(ops[i].own===g1) gi=i; }
         if(hi>=0&&gi>=0&&Math.abs(keepP.y-230)>1&&((230>keepP.y)!==(gi>hi))) bad.push('the friend is not sorted into the floor with the player: standing '+((230>keepP.y)?'in front of':'behind')+' him he is drawn '+((gi>hi)?'after':'before')+' him');
       }
       if(sig(drawnBut(g1))!==soloSig) bad.push('with the party on the rest of the floor frame changed: '+drawnBut(g1).length+' other operators against '+soloN+' in the solo frame');
       if(!painted('ZQX NEAR FRIEND')) bad.push('the friend is drawn with no name over him');
       if(painted('ZQX FAR FRIEND')) bad.push('the friend who never said where he stands has his name painted on the floor');
       // THE UPDATE ticks the net floor code with the party on, and with the PARTY window open too, so a man reading the window
       // at the lift is still seen.
       calls.tick=0;
       updateHubWorld(1/60);
       var tk1=calls.tick;
       if(tk1!==1) bad.push('with the party on a floor update called netHubTick '+tk1+' times, not once');
       if(pm){
         pm.classList.add('on'); updateHubWorld(1/60); pm.classList.remove('on');
         if(calls.tick!==tk1+1) bad.push('with the PARTY window open the floor update does not tick the net floor code, so a man reading the window stops being seen');
       }
       home();
       // A BYE takes him off the floor.
       var b1=netOnMsg(f1,js({t:'bye'}));
       frame();
       if(drawnAs(g1).length) bad.push('after his bye ('+b1+') the friend is still drawn');
       if(painted('ZQX NEAR FRIEND')) bad.push('after his bye his name is still painted');
       netHubTick(1/60);
       if(NET.floor[1]) bad.push('after his bye the friend is still in the floor list');
       // A LOST LINK does too. CONTROL: the friend on seat 2 is drawn once before his link goes.
       var s2=netOnMsg(f2,js({t:'st',x:150,y:160,f:0,m:0,r:0}));
       var g2=NET.floor[2]||null;
       frame();
       if(s2!=='state'||!g2||drawnAs(g2).length!==1) bad.push('control: the friend on seat 2 is not drawn once after he says where he stands ('+s2+')');
       netDrop(f2,'closed');
       frame();
       if(g2&&drawnAs(g2).length) bad.push('after his link was lost the friend on seat 2 is still drawn');
       netHubTick(1/60);
       if(NET.floor[2]) bad.push('after his link was lost the friend on seat 2 is still in the floor list');
       netReset();

       // THREE: A JOINING COPY, on seat 1. The host passes on itself (seat 0) and the other friend (seat 2); its own seat coming
       // back, a seat outside the roster and a position with no seat are not filed.
       netStartJoin();
       var fh=fake(); fh.seat=0; NET.peers.push(fh);
       var RO=[{seat:0,pid:'aaaaaaaa',name:'ZQX HOST',host:true},{seat:1,pid:'bbbbbbbb',name:'ZQX ME',host:false},{seat:2,pid:'cccccccc',name:'ZQX OTHER',host:false}];
       var wj=netOnMsg(fh,js({t:'welcome',you:1,ver:VER,roster:RO}));
       if(wj!=='welcome'||NET.seat!==1){ bad.push('a joining copy was not let in as seat 1 (it said '+wj+')'); return stop(); }
       var k0=netOnMsg(fh,js({t:'st',s:0,x:410,y:150,f:2,m:0,r:0,lk:{fit:'rust',hair:'white'}}));
       var k2=netOnMsg(fh,js({t:'st',s:2,x:420,y:260,f:0,m:1,r:0}));
       var k1=netOnMsg(fh,js({t:'st',s:1,x:430,y:170,f:0,m:0,r:0}));
       var k3=netOnMsg(fh,js({t:'st',s:3,x:440,y:180,f:0,m:0,r:0}));
       var kn=netOnMsg(fh,js({t:'st',x:450,y:190,f:0,m:0,r:0}));
       var e0=NET.floor[0]||null, e2=NET.floor[2]||null;
       if(k0!=='state'||!near1(e0,410,150)) bad.push('a joining copy did not file the host where he stands under seat 0 ('+k0+')');
       if(k2!=='state'||!near1(e2,420,260)) bad.push('a joining copy did not file the other friend under seat 2 ('+k2+')');
       if(k1==='state'||NET.floor[1]) bad.push('a joining copy filed its own seat as somebody else on the floor');
       if(k3==='state'||NET.floor[3]) bad.push('a joining copy filed seat 3, which is not in the roster');
       if(kn==='state') bad.push('a joining copy filed a position that names no seat');
       // Where he stands goes to the host.
       fh.sent=[];
       HB.player.x=111.1; HB.player.y=222.2; HB.player.face=-1.25; HB.player.moving=false; HB.player.rollT=0;
       for(i=0;i<7;i++) netHubTick(1/60);
       var oj=lastOf(sts(fh.sent));
       if(!oj||Math.abs(oj.x-111.1)>0.05||Math.abs(oj.y-222.2)>0.05||Math.abs(oj.f+1.25)>0.01||oj.m!==0) bad.push('a joining copy did not send the host where it stands: '+(oj?js(oj):'nothing sent'));
       home();
       frame();
       if(!e0||!e2||drawnAs(e0).length!==1||drawnAs(e2).length!==1) bad.push('a joining copy drew the host '+drawnAs(e0).length+' times and the other friend '+drawnAs(e2).length+' times, not once each');
       else if(drawnAs(e0)[0].coat!==FITCOL.rust[1]||drawnAs(e0)[0].hair!=='white') bad.push('a joining copy did not dress the host from his racks');
       if(!painted('ZQX HOST')||!painted('ZQX OTHER')) bad.push('a joining copy did not name the host and the other friend over their heads');
       if(painted('ZQX ME')) bad.push('a joining copy painted its own name on the floor');
       // A roster without seat 2 takes him off the floor. CONTROL: the host stays.
       netOnMsg(fh,js({t:'roster',roster:[RO[0],RO[1]]}));
       frame();
       if(e2&&drawnAs(e2).length) bad.push('after the roster lost the other friend he is still drawn');
       netHubTick(1/60);
       if(NET.floor[2]) bad.push('after the roster lost the other friend he is still in the floor list');
       if(!NET.floor[0]) bad.push('control: the host left the floor list with the other friend');
       // The host ends the party: nobody is left, and the frame is the solo frame again.
       netOnMsg(fh,js({t:'bye'}));
       var left=0; for(i=0;i<(NET.floor||[]).length;i++) if(NET.floor[i]) left++;
       if(NET.on||left) bad.push('after the host ended the party '+left+' are still on the floor list (the net section on: '+NET.on+')');
       frame();
       if(sig(ops)!==soloSig) bad.push('after the party ended the floor frame is not the solo frame again ('+ops.length+' operators against '+soloN+')');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the floor code');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ netReset(); }catch(_n){}
       try{ if(spied){ drawOp=oOp; if(oCrowd) tickHubCrowd=oCrowd; netHubTick=oTick; netDrawPeers=oPeers; netDrawPeer=oPeer; if(oTags) netDrawTags=oTags; } }catch(_r){}
       try{ if(spied&&oFill){ if(fillOwn) wc.fillText=oFill; else delete wc.fillText; } }catch(_f){}
       try{ if(pm) pm.classList.remove('on'); }catch(_m){}
       try{ for(var kz in keys) keys[kz]=false; }catch(_kz){}
       try{ if(keepP&&keepH&&HB&&HB.player){ home(); HB.near=keepH.near; HB.eLock=keepH.eLock; } }catch(_hp){}
       try{ if(SAYT!==null) HUBSAY_T=SAYT; }catch(_st){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
