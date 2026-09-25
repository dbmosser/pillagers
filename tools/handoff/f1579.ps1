$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.79',what:")) { throw "check 15.79 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.79. Synchronous, as the fixture runner (__regress and __regressBg) does not await a promise a check returns, and it
# never makes a connection: the party is two stand-in links whose channel records what is sent, the words are fed to the real
# netOnMsg, the host ascends through the real ascent path (__deploy, commitKit, startRaid) and the linked window through the
# real netUpTake and startRaid; the raid frame is the real render2D with drawOp and wc.fillText spied. Four raids are built
# (host, dial control, the linked window, the mismatch) and every one is ended in finally. The live half between two real
# windows is the raid step of RUN SAME MACHINE in tools/nettest.html.
SubRx @'
  {v:'15.78',what:
'@ @'
  {v:'15.79',what:'the party ascends together into one surface and sees each other up top: when the host raid is built the party is told one raid word with the seed, the sector, the hour, the weather, whether a loaner was drawn, the terms, the hire, the dials that differ from default and a fingerprint of the built world; a linked window in the Undercroft builds the same raid from it through the real startRaid on its own save (the seed 4242 counts and the same fingerprint with its own dial moved and the loaner draw the other way round from the host, its own P, its own dials back after the build and never in its save, its own kit up top, the intel core not spent, the same weather); a window up top already, or on the title, is told it was left behind and tells the host why, and the host names it; the same word without the loaner hint builds a different world and is refused before a frame with the stash and the packed kit put back and the PARTY window saying so; the save is never written while the host dials are in and once when they are out; up top a word from a party member puts him on the list, is passed on to the third seat as it came and never back, and the raid frame draws him once at his place with his gun, crouched when he said so, with his name over his head, one operator more than the same frame with the party off and none with the party off again; an out word, a word from another seed and a bye each take him off the frame; the host sends where it stands to every link, through the real loop too; the host is drawn by the window that joined the same way and hidden when its raid ends; each raid ending tells the party out; the seeded stream never moves through the net words (multiplayer phase 2 build 1)',
   run:function(){
     // THE SHARED ASCENT IS THERE. Without it the host goes up alone and the party stays below, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netUpTake!=='function'||typeof netUpAnnounce!=='function'||typeof netUpStart!=='function'||typeof netUpTick!=='function'||
        typeof netUpDraw!=='function'||typeof netUpDrawOne!=='function'||typeof netUpTags!=='function'||typeof netUpFp!=='function'||typeof netUpFpSame!=='function'||
        typeof netUpFpText!=='function'||typeof netUpWord!=='function'||typeof netUpEnd!=='function'||typeof netUpView!=='function'||!NET.up||typeof NET.up.length!=='number')
       return 'this build does not ascend a party together: the host tells nobody its seed (no netUpAnnounce, netUpTake or netUpFp), a linked window stays in the Undercroft while the host goes up alone, and nobody is drawn up top';
     if(typeof netOnMsg!=='function'||typeof netReset!=='function'||typeof netStartHost!=='function'||typeof netStartJoin!=='function'||typeof netRosterBuild!=='function'||
        typeof render2D!=='function'||typeof drawOp!=='function'||typeof startRaid!=='function'||typeof endRaid!=='function'||typeof showScreen!=='function'||
        typeof DEF==='undefined'||typeof CFG==='undefined'||typeof WEAPONS==='undefined'||typeof SKEY==='undefined'||typeof wc==='undefined'||!wc||typeof storeSet!=='function'||!window.__loop) return 'this build has no raid under the party';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     if(!window.__deploy||!window.__hubEnter||!window.__endRaid||!window.__resetCfg||!window.__pinDefaults||!window.__cleanProfile) return 'SKIP: this fixture cannot ascend';
     var bad=[], rng0=null, keepP=P, keepEq=P.equipped, keepWp=(P.weapons||[]).slice(), keepIntel=P.intel, keepTerms=P.terms, keepWx=P.wxPick;
     var oOp=drawOp, oFill=null, fillOwn=false, spied=false, ops=[], texts=[], _s2=say2, sentA=[], sentB=[], sentC=[], oStore=storeSet, heldSaves=0, saves=0;
     var g=function(id){ return document.getElementById(id); };
     function js(o){ return JSON.stringify(o); }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     // A stand-in link: what the game sends on it is written down. Never a real connection.
     function link(seat,name,box){ return {id:++NET.sid,pc:null,dc:{readyState:'open',send:function(s){ var o=null; try{ o=JSON.parse(s); }catch(e){ o={t:'unreadable'}; } box.push(o); }},fc:null,state:'in',seat:seat,pid:'zqxseat'+seat,name:name,timers:[]}; }
     function words(box,t){ var o=[], q; for(q=0;q<box.length;q++) if(box[q]&&box[q].t===t) o.push(box[q]); return o; }
     function last(box,t){ var o=words(box,t); return o.length?o[o.length-1]:null; }
     // THE SPIES: every operator drawn in a raid frame, and every string painted on the world canvas.
     function spy(){ if(spied) return; spied=true; fillOwn=Object.prototype.hasOwnProperty.call(wc,'fillText'); oFill=wc.fillText;
       drawOp=function(x,y,face,ph,coat,pk,mz,mode,iv,st){ ops.push({x:x,y:y,mode:String(mode),hero:!!(st&&st.hero),wep:(st&&st.own&&st.own.wep&&st.own.wep.id)||''}); return oOp.apply(null,arguments); };
       wc.fillText=function(t){ texts.push(String(t)); return oFill.apply(wc,arguments); }; }
     function unspy(){ if(!spied) return; spied=false; drawOp=oOp; if(fillOwn) wc.fillText=oFill; else { try{ delete wc.fillText; }catch(_d){ wc.fillText=oFill; } } }
     function frame(){ ops=[]; texts=[]; render2D(0); return ops.length; }
     function at(x,y){ var q, c=0; for(q=0;q<ops.length;q++) if(!ops[q].hero&&Math.abs(ops[q].x-x)<0.01&&Math.abs(ops[q].y-y)<0.01) c++; return c; }
     function opAt(x,y){ var q; for(q=0;q<ops.length;q++) if(!ops[q].hero&&Math.abs(ops[q].x-x)<0.01&&Math.abs(ops[q].y-y)<0.01) return ops[q]; return null; }
     // Every raid ends the way the fixture ends one: abandon, and the floor if the card path was taken.
     function down(){ try{ if(G) __endRaid('abandon'); }catch(_e){} try{ if(G){ G=null; keys={}; showScreen('hub'); } }catch(_e2){} }
     function fresh(){ __resetCfg(); __pinDefaults(0); }
     var RW=null, hostFp=null, hostDrew=false, p, n0, n1, u;
     // The linked window carries the loaner draw the other way round from the host: a gun of its own when the host drew a
     // loaner, no gun when the host had one (the fixture pin equips one), so the build only lands where the host put it when
     // the draw is held in step.
     function armPeerGun(){ if(hostDrew){ P.equipped='tacker'; P.weapons=['tacker']; } else { P.equipped='fists'; P.weapons=[]; } }
     try{
       __topClear(); closeAll();
       netReset(); say2=function(){};
       try{ __hubEnter(); }catch(_h){}
       if(G) down();
       __cleanProfile();

       // ONE: THE HOST. A stand-in party of two, and the real ascent through __deploy on sector 0 at seed 4242 under the
       // fixture pins (a gun equipped, so no loaner is drawn; the raid word must say which).
       P.intel=0; P.terms=[];
       netStartHost();
       var A=link(1,'ZQX MATE',sentA), A3=link(2,'ZQX THIRD',sentC); NET.peers.push(A); NET.peers.push(A3); NET.roster=netRosterBuild();
       fresh();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.seed!==4242||state!=='raid') bad.push('the host ascent did not build seed 4242 (seed '+(G?G.seed:'no raid')+', state '+state+')');
       hostFp=G?netUpFp(G):null;
       if(!hostFp||hostFp.e!==85||hostFp.c!==165) bad.push('the host built '+netUpFpText(hostFp)+' on sector 0 at seed 4242, not the 85 bodies and 165 containers of the fingerprint');
       var rw=words(sentA,'raid');
       if(rw.length!==1) bad.push('the host ascent told the party '+rw.length+' raid words, not one');
       if(words(sentC,'raid').length!==1) bad.push('the third seat was told '+words(sentC,'raid').length+' raid words, not one');
       RW=rw[0]||null;
       if(RW){
         if(RW.seed!==4242||RW.mapIx!==0) bad.push('the raid word does not carry seed 4242 on sector 0 ('+js({seed:RW.seed,mapIx:RW.mapIx})+')');
         if(RW.cond!=='day') bad.push('the raid word does not carry the hour (cond '+RW.cond+')');
         if(!G||RW.wx!==((G.wx&&G.wx.id)||'')) bad.push('the raid word does not carry the weather the host got ('+RW.wx+' against '+(G&&G.wx?G.wx.id:'?')+')');
         hostDrew=!!(G&&G.issDraw);
         if(RW.iss!==(hostDrew?1:0)) bad.push('the raid word does not say whether the host drew a loaner (iss '+RW.iss+', issDraw '+(G?G.issDraw:'?')+')');
         if(G&&G.player&&G.player.wepIssued!==hostDrew) bad.push('control: the raid says a loaner was '+(hostDrew?'':'not ')+'drawn but the host holds '+(G.player.wepIssued?'a loaner':'its own gun'));
         if(!netUpFpSame(RW.fp,hostFp)) bad.push('the raid word fingerprint is not the built world ('+netUpFpText(RW.fp)+' against '+netUpFpText(hostFp)+')');
         if(!RW.cfg||typeof RW.cfg!=='object') bad.push('the raid word carries no dials');
         if(!RW.terms||typeof RW.terms.length!=='number') bad.push('the raid word carries no terms');
       }
       if(NET.upSeed!==4242||!netUpFpSame(NET.upFp,hostFp)) bad.push('the host does not hold its own seed and fingerprint (seed '+NET.upSeed+')');
       // The net words move nothing on the seeded stream: the word again by hand, then a word from up top and the frames.
       rng0=RNGS; sentA.length=0;
       var m2=netUpAnnounce(G);
       if(!m2||words(sentA,'raid').length!==1) bad.push('netUpAnnounce by hand did not send one raid word');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the raid word');
       // With the party off the frame is the v15.78 frame; with one of the party up top it draws him once at his place, named.
       spy();
       p=G.player;
       NET.on=false; n0=frame(); NET.on=true;
       if(!n0) bad.push('the raid frame drew no operator at all, so there is nothing to compare');
       var st1=netOnMsg(A,js({t:'st',k:'r',sd:4242,x:p.x+30,y:p.y,f:0.5,m:1,c:0,sp:0,dn:0,r:0,w:'tacker'}));
       if(st1!=='state') bad.push('a word from up top was not filed ('+st1+')');
       u=NET.up[1];
       if(!u||Math.abs(u.x-(p.x+30))>0.01||Math.abs(u.y-p.y)>0.01||u.sd!==4242||u.w!=='tacker') bad.push('the word from up top did not put him where he said, in this raid, with his gun ('+js(u?{x:u.x,y:u.y,sd:u.sd,w:u.w}:null)+')');
       if(NET.floor[1]) bad.push('a word from up top was filed on the floor list');
       var rl=last(sentC,'st');
       if(!rl||rl.k!=='r'||rl.s!==1||rl.sd!==4242||rl.w!=='tacker'||typeof rl.c!=='number') bad.push('the host did not pass the word from up top on to the third seat as it came ('+js(rl)+')');
       if(last(sentA,'st')) bad.push('the host passed his own word back to him');
       netUpTick(0);
       n1=frame();
       if(n1!==n0+1) bad.push('with one of the party up top the raid frame drew '+n1+' operators where the same frame with the party off drew '+n0+': not exactly one more');
       if(at(p.x+30,p.y)!==1) bad.push('he is drawn '+at(p.x+30,p.y)+' times at his place, not once');
       var o1=opAt(p.x+30,p.y);
       if(o1&&o1.wep!=='tacker') bad.push('he is not drawn with the gun he said he holds ('+(o1.wep||'none')+')');
       if(texts.indexOf('ZQX MATE')<0) bad.push('his name is not painted over his head');
       NET.on=false;
       if(frame()!==n0||texts.indexOf('ZQX MATE')>=0) bad.push('with the party off the raid frame still draws him, or his name ('+ops.length+' against '+n0+')');
       NET.on=true;
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through a word from up top and three frames');
       // The host sends where it stands: one tick past a tenth of a second sends one word from up top to each link, under seat 0, with the seed.
       sentA.length=0; sentC.length=0;
       var sn=netUpTick(0.11);
       var sw=last(sentA,'st');
       if(sn!==2||!sw||sw.k!=='r'||sw.s!==0||sw.sd!==4242||typeof sw.x!=='number'||typeof sw.c!=='number'||!last(sentC,'st')) bad.push('the host did not send where it stands up top to both links ('+sn+' sent, '+js(sw)+')');
       // An out word hides him at once; a word again shows him crouched; a word from another seed is filed and not drawn; a bye takes him off.
       var ow=netOnMsg(A,js({t:'up',st:'out',how:'extract'}));
       if(ow!=='up:out'||NET.up[1]) bad.push('an out word did not take him off the list ('+ow+')');
       netUpTick(0);
       if(frame()!==n0) bad.push('after his raid ended the frame still draws him ('+ops.length+' against '+n0+')');
       if(texts.indexOf('ZQX MATE')>=0) bad.push('after his raid ended his name is still painted');
       netOnMsg(A,js({t:'st',k:'r',sd:4242,x:p.x+30,y:p.y,f:0.5,m:0,c:1,sp:0,dn:0,r:0,w:''}));
       netUpTick(0);
       if(frame()!==n0+1) bad.push('a word after his raid ended does not show him again');
       var o2=opAt(p.x+30,p.y);
       if(o2&&o2.mode!=='crouch') bad.push('crouched, he is not drawn crouched ('+(o2?o2.mode:'?')+')');
       netOnMsg(A,js({t:'st',k:'r',sd:777,x:p.x+30,y:p.y,f:0.5,m:0,c:0,sp:0,dn:0,r:0,w:''}));
       netUpTick(0);
       if(frame()!==n0) bad.push('a word from another seed is drawn');
       netOnMsg(A,js({t:'st',k:'r',sd:4242,x:p.x+30,y:p.y,f:0.5,m:0,c:0,sp:0,dn:0,r:0,w:''}));
       netUpTick(0);
       if(frame()!==n0+1) bad.push('control: back on this seed he is not drawn');
       var by=netOnMsg(A,js({t:'bye'}));
       if(by!=='bye') bad.push('the bye was not taken ('+by+')');
       netUpTick(0);
       if(frame()!==n0||NET.up[1]) bad.push('after his bye the frame still draws him');
       // The host takes no raid word.
       var B0=link(1,'ZQX MATE',sentA); NET.peers.push(B0); NET.roster=netRosterBuild();
       if(RW&&netOnMsg(B0,js(RW))!=='ignored') bad.push('the host took a raid word');
       unspy();
       // Two raid frames through the real loop send where the host stands (the tick sits in loop, ahead of the frame).
       sentA.length=0; NET.upAcc=0;
       try{ __loop(lastTs+50); __loop(lastTs+50); }catch(_lp){ bad.push('two raid frames through the loop threw: '+(_lp&&_lp.message||_lp)); }
       var lw=last(sentA,'st');
       if(!lw||lw.k!=='r'||lw.s!==0) bad.push('two raid frames through the loop did not send where the host stands ('+js(lw)+')');
       sentA.length=0;
       down();
       var outW=last(sentA,'up');
       if(!outW||outW.st!=='out'||outW.how!=='abandon') bad.push('ending the host raid did not tell the party out ('+js(outW)+')');
       if(NET.upSeed||NET.up.length) bad.push('ending the host raid left the seed or the list ('+NET.upSeed+', '+NET.up.length+')');
       netReset();
       if(G||state!=='hub') bad.push('the host raid did not come down to the Undercroft (state '+state+')');

       // TWO: CONTROL for the dials. This window with its own dial moved (no pillagers) builds fewer bodies at seed 4242.
       fresh(); CFG.nRaider=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var ownE=G?G.ents.length:-1;
       down();
       if(ownE<0||ownE>=85) bad.push('control: with no pillagers dialled this window still builds '+ownE+' bodies, so the dial control proves nothing');

       // THREE: A LINKED WINDOW IN THE UNDERCROFT takes the host word: the same raid on its own save, with its own dial moved
       // and the loaner draw the other way round from the host.
       netStartJoin(); NET.seat=1;
       var H=link(0,'ZQX HOST',sentB); NET.peers.push(H);
       NET.roster=[{seat:0,pid:'zqxseat0',name:'ZQX HOST',host:true},{seat:1,pid:NET.pid,name:NET.name,host:false}];
       fresh(); CFG.nRaider=0; armPeerGun();
       P.intel=1; P.terms=['zqxownterm']; P.stash=['medkit','plate','bandage']; P.kit=['medkit']; P.kitChosen=0; P.dropKit=[]; P.freeKit=0;
       try{ saveProfile(); }catch(_sv){}
       // Every write of the save while the host dials are in is counted: there must be none, and one after they are out.
       heldSaves=0; saves=0;
       storeSet=function(v){ saves++; if(NET.upHold) heldSaves++; return oStore.apply(null,arguments); };
       var tk=RW?netOnMsg(H,js(RW)):'no word';
       storeSet=oStore;
       if(tk!=='up') bad.push('the raid word did not take this window up ('+tk+')');
       if(heldSaves) bad.push('the save was written '+heldSaves+' times while the host dials were in');
       if(!saves) bad.push('the save was not written once the host dials were out');
       if(G&&G.intel) bad.push('the intel core was used up top on a party ascent');
       var fpB=(G&&!G.sim)?netUpFp(G):null;
       if(!G||G.seed!==4242||state!=='raid') bad.push('this window is not up top on seed 4242 (seed '+(G?G.seed:'no raid')+', state '+state+')');
       if(!fpB||fpB.e!==85||fpB.c!==165) bad.push('this window built '+netUpFpText(fpB)+' from the host word, not the 85 bodies and 165 containers of sector 0 at seed 4242 (own dial: no pillagers; the loaner draw the other way round)');
       if(RW&&!netUpFpSame(fpB,RW.fp)) bad.push('the fingerprints differ: host '+netUpFpText(RW.fp)+', this window '+netUpFpText(fpB));
       if(G&&RW&&((G.wx&&G.wx.id)||'')!==RW.wx) bad.push('the weather differs from the host ('+(G&&G.wx?G.wx.id:'?')+' against '+RW.wx+')');
       if(P!==keepP) bad.push('the build swapped P for another object');
       if(G&&G.player&&G.player.wep){
         if(hostDrew&&G.player.wep.id!=='tacker') bad.push('this window did not go up with its own gun ('+G.player.wep.id+')');
         if(!hostDrew&&!G.player.wepIssued) bad.push('this window with no gun did not go up with a loaner ('+G.player.wep.id+')');
       }
       if(G&&G.bag&&G.bag.indexOf('medkit')<0) bad.push('this window did not go up with its own packed kit');
       if(CFG.nRaider!==0) bad.push('this window own dial (no pillagers) did not come back after the build (nRaider '+CFG.nRaider+')');
       var saved=null; try{ saved=JSON.parse(localStorage.getItem(SKEY)); }catch(_ls){ saved=null; }
       if(!saved||!saved.cfg||saved.cfg.nRaider!==0) bad.push('the host dial leaked into this window save (saved nRaider '+(saved&&saved.cfg?saved.cfg.nRaider:'none')+')');
       if(P.intel!==1) bad.push('the intel core was spent on a party ascent (intel '+P.intel+')');
       if(js(P.terms)!==js(['zqxownterm'])) bad.push('this window own terms did not come back ('+js(P.terms)+')');
       if(P.mapIx!==0||P.cond!=='day') bad.push('the sector and the hour are not the host ones ('+P.mapIx+', '+P.cond+')');
       if(pendSeed!==null) bad.push('pendSeed was left set');
       if(NET.upHold||NET.upIss!==null) bad.push('the party build guard was left on');
       if(NET.upSeed!==4242||!netUpFpSame(NET.upFp,fpB)) bad.push('this window does not hold the seed and fingerprint it built');
       var inW=last(sentB,'up');
       if(!inW||inW.st!=='in') bad.push('the host was not told this window is up top ('+js(inW)+')');
       // A second raid word while up top is refused, and the host told why.
       sentB.length=0;
       var tk2=RW?netOnMsg(H,js(RW)):'no word';
       var noW=last(sentB,'up');
       if(tk2!=='busy'||!noW||noW.st!=='no'||noW.why!=='up top already') bad.push('a raid word while up top was not refused with the reason ('+tk2+', '+js(noW)+')');
       if(!G||G.seed!==4242||state!=='raid') bad.push('a second raid word disturbed the raid in hand');
       // The host drawn by this window: a word under seat 0, once at its place, named; a word with no seat is bad; an out word hides it.
       spy(); p=G.player;
       NET.on=false; n0=frame(); NET.on=true;
       rng0=RNGS;
       var st2=netOnMsg(H,js({t:'st',k:'r',sd:4242,s:0,x:p.x-40,y:p.y+10,f:2,m:0,c:0,sp:1,dn:0,r:0,w:'tacker'}));
       if(st2!=='state'||!NET.up[0]) bad.push('the host word from up top was not filed on this window ('+st2+')');
       netUpTick(0);
       n1=frame();
       if(n1!==n0+1) bad.push('with the host up top this window drew '+n1+' operators where the same frame with the party off drew '+n0+': not exactly one more');
       if(at(p.x-40,p.y+10)!==1) bad.push('the host is drawn '+at(p.x-40,p.y+10)+' times at its place, not once');
       if(texts.indexOf('ZQX HOST')<0) bad.push('the host name is not painted over its head');
       var st3=netOnMsg(H,js({t:'st',k:'r',sd:4242,x:p.x-40,y:p.y+10,f:2,m:0,c:0,sp:0,dn:0,r:0,w:''}));
       if(st3!=='bad') bad.push('a word with no seat from the host was taken ('+st3+')');
       var ow2=netOnMsg(H,js({t:'up',s:0,st:'out',how:'dead'}));
       if(ow2!=='up:out'||NET.up[0]) bad.push('the host out word did not take it off the list ('+ow2+')');
       netUpTick(0);
       if(frame()!==n0) bad.push('after the host raid ended this window still draws it');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the words from up top');
       unspy();
       sentB.length=0;
       down();
       var outB=last(sentB,'up');
       if(!outB||outB.st!=='out') bad.push('ending this window raid did not tell the host out ('+js(outB)+')');
       if(G||state!=='hub') bad.push('this window raid did not come down to the Undercroft');

       // FOUR: THE SAME WORD WITHOUT THE LOANER HINT builds a different world for this window, whose loaner draw goes the
       // other way: the fingerprints differ, the raid is torn down before a frame, the stash and the packed kit come back,
       // and the PARTY window says so.
       fresh(); CFG.nRaider=0; armPeerGun();
       P.stash=['medkit','plate','bandage']; P.kit=['medkit']; P.kitChosen=0; P.dropKit=[]; P.freeKit=0; P.intel=1;
       var RWn=RW?JSON.parse(js(RW)):null; if(RWn) delete RWn.iss;
       sentB.length=0;
       var tk3=RWn?netOnMsg(H,js(RWn)):'no word';
       if(tk3!=='mismatch') bad.push('the word without the loaner hint was not refused as a mismatch ('+tk3+'): the loaner draw is not held in step, or a different world is played');
       if(G||state!=='hub') bad.push('a mismatched word left a raid in hand (state '+state+')');
       if(js(P.stash)!==js(['medkit','plate','bandage'])||js(P.kit)!==js(['medkit'])) bad.push('the stash and the packed kit did not come back after the mismatch ('+js(P.stash)+', '+js(P.kit)+')');
       if(P.intel!==1||P.equipped!==(hostDrew?'tacker':'fists')) bad.push('the save did not come back whole after the mismatch (intel '+P.intel+', equipped '+P.equipped+')');
       if(!NET.err||NET.err.toLowerCase().indexOf('undercroft')<0||NET.err.toLowerCase().indexOf('surface')<0) bad.push('the PARTY window does not say this window stays in the Undercroft: '+NET.err);
       var noW2=last(sentB,'up');
       if(!noW2||noW2.st!=='no'||noW2.why!=='surface') bad.push('the host was not told the surface could not be built ('+js(noW2)+')');
       if(CFG.nRaider!==0) bad.push('the own dial did not come back after the mismatch');

       // FIVE: A WINDOW ON THE TITLE is told it was left behind and tells the host why; the host names who and why.
       NET.err='';
       g('title').classList.add('on');
       sentB.length=0;
       var tk4=RW?netOnMsg(H,js(RW)):'no word';
       g('title').classList.remove('on');
       var noW3=last(sentB,'up');
       if(tk4!=='busy'||G||!noW3||noW3.st!=='no'||noW3.why!=='on the title') bad.push('a window on the title was not told and ignored ('+tk4+', '+js(noW3)+')');
       if(!NET.err||NET.err.indexOf('on the title')<0) bad.push('the PARTY window does not say the window was on the title: '+NET.err);
       netReset(); netStartHost();
       var A2=link(1,'ZQX MATE',sentA), A4=link(2,'ZQX THIRD',sentC); NET.peers.push(A2); NET.peers.push(A4); NET.roster=netRosterBuild();
       sentA.length=0; sentC.length=0;
       var wn=netOnMsg(A2,js({t:'up',st:'no',why:'on the title'}));
       if(wn!=='up:no'||!NET.status||NET.status.indexOf('ZQX MATE')<0||NET.status.indexOf('title')<0) bad.push('the host does not say who was left behind and why ('+wn+', '+NET.status+')');
       var rw2=last(sentC,'up');
       if(!rw2||rw2.s!==1||rw2.st!=='no'||rw2.why!=='on the title') bad.push('the host did not pass the word on to the third seat under seat 1 ('+js(rw2)+')');
       if(last(sentA,'up')) bad.push('the host passed the word back to the seat it came from');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ unspy(); }catch(_us){}
       try{ storeSet=oStore; }catch(_st){}
       try{ if(G) __endRaid('abandon'); }catch(_er){}
       try{ if(G){ G=null; keys={}; } }catch(_g0){}
       try{ NET.on=false; NET.upHold=false; NET.upIss=null; pendSeed=null; netReset(); }catch(_nr){}
       try{ g('title').classList.remove('on'); }catch(_t){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ P.equipped=keepEq; P.weapons=keepWp; P.intel=keepIntel; P.terms=keepTerms; P.wxPick=keepWx; }catch(_kp){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
