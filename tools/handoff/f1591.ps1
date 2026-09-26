$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.91',what:")) { throw "check 15.91 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.91. Synchronous, as the fixture runner does not await a promise a check returns, and it never makes a connection:
# the party is stand-in links whose channel records what is sent, the words are fed to the real netOnMsg, the host ascends
# through the real ascent path (__deploy, commitKit, startRaid) and the linked window through the real netUpTake and
# startRaid, the search hold is the real play path (updatePlayer with E held) and the frames the real loop (__loop), with
# endRaid spied. Five raids are built (the host, the solo control, the linked window three times) and every one is ended in
# finally. The live half between two real windows is the loot step and the host leaving step of RUN RAID in tools/nettest.html.
SubRx @'
  {v:'15.90',what:
'@ @'
  {v:'15.91',what:'loot per player and the host leaving ends the run for everyone: at the build the host numbers its 165 containers in list order; a search request from one of the party on a box is granted with the count of the host list and told held to the others, a second request on the same box from another seat is refused as held while the first runs, a request from a seat filed far from the box is refused as far, the host own E on a box one of the party holds starts nothing and says who holds it while on a free box it starts (control), frames of the real loop run the search on the host and post the loot to the requesting seat in the order of the host list one stage at a time with the last word saying done, the box is told open to everyone with the seat that searched it and refuses every request after, the host own backpack, stash, credits and container tally gain nothing, a box holding a locked room key keeps the KEY mark test the sector map makes until one of the party pulls the key out and loses it before the box opens, a hold let go keeps its progress and frees the box and a second request resumes from that bar, a body the host made mid raid is numbered and told new on the next tick and told open and shut as it changes, a seat that comes up is told which boxes are open, the seeded stream never moves through the requests, the words and the ticks; CONTROL with the party off: nothing is numbered, a held E empties the box into the backpack from the local list and the net section holds no search; THE LINKED WINDOW up top on the host word numbers the same boxes, a held E on a box asks the host once and grants nothing from its own list, the bar stands until the host grants it and then fills from where the host has it and stops at the top with the box still shut and the backpack unchanged, a loot word puts the items in this window own backpack and the done word closes the box and counts it on this run, an open word marks a box searched so a held E starts nothing and asks nothing (control: before the word it asks), letting go tells the host, a held word keeps a held E off the box and a free word lets it ask, a shut word puts a searched box back, a new word makes a body the host made that a held E asks for, an all word marks open and held boxes, and the seeded stream never moves through the words; THE HOST LEAVING: an out word from another seat and a roster without it end nothing, an out word from seat 0 ends this raid as abandon through endRaid with the host left line on the run card and in the PARTY status, and up again on the same word a lost host link ends it the same way and the party is off (multiplayer phase 3 build 1)',
   run:function(){
     // THE SHARED CONTAINERS ARE THERE. Without them each window searches its own copy of every box, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netSrchTake!=='function'||typeof netSrchTick!=='function'||typeof netContTick!=='function'||typeof netLootTake!=='function'||
        typeof netContWord!=='function'||typeof netSrchHold!=='function'||typeof netHostGone!=='function'||typeof netContInit!=='function'||typeof netSrchShared!=='function'||
        typeof netContOf!=='function'||typeof netSrchSync!=='function'||typeof netContHello!=='function'||typeof netSrchAnswer!=='function')
       return 'this build searches every box on each window alone: a search on a linked window grants from its own list (no netSrchTake or netLootTake), two windows can empty one box at once, and the host leaving ends nothing (no netHostGone)';
     if(typeof netOnMsg!=='function'||typeof netReset!=='function'||typeof netStartHost!=='function'||typeof netStartJoin!=='function'||typeof netRosterBuild!=='function'||
        typeof netUpFp!=='function'||typeof netUpFpText!=='function'||typeof updatePlayer!=='function'||typeof endRaid!=='function'||typeof openContainer!=='function'||
        typeof startRaid!=='function'||typeof showScreen!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof netDrop!=='function'||typeof refreshVseg!=='function'||
        typeof ITEMS==='undefined'||typeof keys==='undefined'||!window.__loop) return 'this build has no raid under the party';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     if(!window.__deploy||!window.__hubEnter||!window.__endRaid||!window.__resetCfg||!window.__pinDefaults||!window.__cleanProfile) return 'SKIP: this fixture cannot ascend';
     var bad=[], rng0=null, keepEq=P.equipped, keepWp=(P.weapons||[]).slice(), keepIntel=P.intel, keepTerms=P.terms, keepWx=P.wxPick;
     var _s2=say2, sentA=[], sentB=[], oER=endRaid, erCalls=[], spied=false, q, p, RW=null;
     var g=function(id){ return document.getElementById(id); };
     function js(o){ return JSON.stringify(o); }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     // A stand-in link: what the game sends on it is written down. Never a real connection.
     function link(seat,name,box){ return {id:++NET.sid,pc:null,dc:{readyState:'open',send:function(s){ var o=null; try{ o=JSON.parse(s); }catch(e){ o={t:'unreadable'}; } box.push(o); }},fc:null,state:'in',seat:seat,pid:'zqxseat'+seat,name:name,timers:[]}; }
     function words(box,t){ var o=[], i; for(i=0;i<box.length;i++) if(box[i]&&box[i].t===t) o.push(box[i]); return o; }
     function last(box,t){ var o=words(box,t); return o.length?o[o.length-1]:null; }
     function contWords(box,cid,st){ var o=[], i, w; for(i=0;i<box.length;i++){ w=box[i]; if(w&&w.t==='cont'&&w.cid===cid&&(!st||w.st===st)) o.push(w); } return o; }
     function lootOf(box,cid){ var o=[], i, w, j; for(i=0;i<box.length;i++){ w=box[i]; if(w&&w.t==='loot'&&w.cid===cid&&w.items) for(j=0;j<w.items.length;j++) o.push(w.items[j]); } return o; }
     // THE SPY: every end of a raid through endRaid, with how.
     function spy(){ if(spied) return; spied=true; endRaid=function(how){ erCalls.push(String(how)); return oER.apply(null,arguments); }; }
     function unspy(){ if(!spied) return; spied=false; endRaid=oER; }
     function frames(n){ var i; for(i=0;i<n;i++) __loop(lastTs+50); }
     function onPad(ct){ var z; for(z=0;z<(G.zones||[]).length;z++) if(dist(ct,G.zones[z])<G.zones[z].r+60) return true; return false; }
     // A box standing alone: no other unopened box within 60 units, so a held E beside it finds this box and no other.
     function lonely(ct){ var i, o; for(i=0;i<G.containers.length;i++){ o=G.containers[i]; if(o!==ct&&!o.opened&&dist(o,ct)<60) return false; } return true; }
     function pickBox(not,minLoot,types){ var i, ct; for(i=0;i<G.containers.length;i++){ ct=G.containers[i]; if(ct.opened||ct.dropped||ct.cache||ct.strong||ct.mercSrc) continue; if((types||['crate','locker','safe']).indexOf(ct.type)<0) continue; if(!ct.loot||ct.loot.length<(minLoot||1)) continue; if(not.indexOf(ct)>=0||onPad(ct)||!lonely(ct)) continue; return ct; } return null; }
     function keyBox(){ var i, ct, j; for(i=0;i<G.containers.length;i++){ ct=G.containers[i]; if(ct.opened||!ct.loot||onPad(ct)) continue; for(j=0;j<ct.loot.length;j++) if(String(ct.loot[j]).indexOf('key_')===0) return ct; } return null; }
     function hasKey(ct){ return (ct.loot||[]).some(function(k){ return String(k).indexOf('key_')===0; }); }
     function markOn(ct){ return !(ct.opened||!hasKey(ct)); }   // the test the sector map makes before it draws the gold KEY mark on a box (v15.55)
     function standOn(ct){ G.player.x=ct.x+6; G.player.y=ct.y; try{ refreshVseg(); }catch(_rv){} }
     function fileAt(L,x,y){ return netOnMsg(L,js({t:'st',k:'r',sd:4242,x:x,y:y,f:0,m:0,c:0,sp:0,dn:0,r:0,w:'smg'})); }
     function down(){ try{ if(G) __endRaid('abandon'); }catch(_e){} try{ if(G){ G=null; keys={}; showScreen('hub'); } }catch(_e2){} try{ __topClear(); }catch(_e3){} }
     function fresh(){ __resetCfg(); __pinDefaults(0); }
     try{
       __topClear(); closeAll();
       netReset(); say2=function(){};
       try{ __hubEnter(); }catch(_h){}
       if(G) down();
       __cleanProfile();

       // ONE: THE HOST. Two stand-in friends on seats 1 and 2, and the real ascent through __deploy on sector 0 at seed 4242.
       P.intel=0; P.terms=[];
       netStartHost();
       var A=link(1,'ZQX MATE',sentA), B=link(2,'ZQX OTHER',sentB); NET.peers.push(A); NET.peers.push(B); NET.roster=netRosterBuild();
       fresh();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.seed!==4242||state!=='raid') bad.push('the host ascent did not build seed 4242 (seed '+(G?G.seed:'no raid')+', state '+state+')');
       var fpH=G?netUpFp(G):null;
       if(!fpH||fpH.e!==85||fpH.c!==165) bad.push('the host built '+netUpFpText(fpH)+' on sector 0 at seed 4242, not the 85 bodies and 165 containers of the fingerprint');
       RW=last(sentA,'raid');
       if(!RW) bad.push('the host ascent told the party no raid word');
       var nc=0; for(q=0;q<G.containers.length;q++) if(G.containers[q].cid===q) nc++;
       if(nc!==G.containers.length||NET.contN!==G.containers.length||netContOf(0)!==G.containers[0]) bad.push('the host did not number its containers in list order at the build ('+nc+' of '+G.containers.length+', told '+NET.contN+')');
       p=G.player;
       var C1=pickBox([],2), C3=pickBox(C1?[C1]:[],1), C2=pickBox(C1?[C1,C3]:[],1);
       if(!C1||!C2||!C3) bad.push('fewer than three unopened crates, lockers or safes off the rings at seed 4242 to search');
       // The host player far away at a ring, so its own reach never finds the boxes.
       var far=null, fd=-1, zi, zd;
       for(zi=0;zi<(G.zones||[]).length;zi++){ zd=C1?dist(G.zones[zi],C1):0; if(zd>fd){ fd=zd; far=G.zones[zi]; } }
       if(far){ p.x=far.x; p.y=far.y; }
       var L0=C1?C1.loot.slice():[], cid1=C1?C1.cid:-1, bag0=G.bag.length, stash0=js(P.stash), cred0=P.credits, tc0=G.tel.containers;
       // The two friends filed up top: seat 1 beside the box, seat 2 a little off.
       var st1=C1?fileAt(A,C1.x+8,C1.y):'no box', st2=C1?fileAt(B,C1.x+20,C1.y+8):'no box';
       if(st1!=='state'||st2!=='state'||!NET.up[1]||!NET.up[2]) bad.push('the two friends were not filed up top ('+st1+', '+st2+')');
       // A SEARCH REQUEST from seat 1 is granted with the count of the host list, and the other seat is told the box is held.
       sentA.length=0; sentB.length=0; rng0=RNGS;
       var r1=C1?netOnMsg(A,js({t:'srch',op:'start',cid:cid1,slow:1})):'no box', an1=last(sentA,'srch');
       if(r1!=='srch:ok'||!an1||an1.ok!==1||an1.cid!==cid1||an1.n!==L0.length) bad.push('a search request from seat 1 was not granted with the count of the host list ('+r1+', '+js(an1)+')');
       if(!C1||C1.netBy!==1||!NET.holds||!NET.holds[1]||NET.holds[1].cid!==cid1) bad.push('the granted search is not held by seat 1 on the host (by '+(C1?C1.netBy:'?')+', holds '+js(NET.holds)+')');
       var hb=contWords(sentB,cid1,'held');
       if(!hb.length||hb[0].by!==1) bad.push('the other seat was not told the box is held by seat 1 ('+js(contWords(sentB,cid1))+')');
       // A SECOND REQUEST ON THE SAME BOX from seat 2 is refused as held while the first runs.
       var r2=C1?netOnMsg(B,js({t:'srch',op:'start',cid:cid1,slow:1})):'no box', an2=last(sentB,'srch');
       if(r2!=='srch:held'||!an2||an2.ok!==0||an2.why!=='held'||an2.by!==1) bad.push('a second request on the same box from seat 2 was not refused as held ('+r2+', '+js(an2)+')');
       if(!C1||C1.netBy!==1||(NET.holds&&NET.holds[2])) bad.push('the refused request took the box from seat 1 (by '+(C1?C1.netBy:'?')+')');
       // A REQUEST FROM FAR AWAY is refused: seat 2 filed a long way from the third box asks for it.
       if(C3) fileAt(B,C3.x+1000,C3.y);
       var r4=C3?netOnMsg(B,js({t:'srch',op:'start',cid:C3.cid,slow:1})):'no box';
       if(r4!=='srch:far'||(C3&&C3.netBy!==-1)) bad.push('a request from a seat filed far from the box was not refused as far ('+r4+')');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the requests');
       // THE HOST OWN E on the held box starts nothing and says who holds it; on a free box it starts (control).
       if(C1){ standOn(C1); keys['KeyE']=true; updatePlayer(0.05); updatePlayer(0.05); keys['KeyE']=false; }
       if(G.searching) bad.push('the host started its own search on a box one of the party holds ('+(G.searching===C1?'that box':'another box')+')');
       if(C1&&(C1.prog||0)>0.0001) bad.push('the host own hold moved the bar on a box one of the party holds ('+C1.prog+')');
       if(!(/searching/i).test(String(window.__lastSay||''))) bad.push('the host was not told who is searching the box (last line: '+String(window.__lastSay||'')+')');
       if(C2){ standOn(C2); keys['KeyE']=true; updatePlayer(0.05); updatePlayer(0.05); keys['KeyE']=false; }
       if(!C2||G.searching!==C2||!(C2.prog>0)) bad.push('control: the host own hold on a free box did not start a search ('+(G.searching?'another box':'nothing')+')');
       if(C2){ G.searching=null; G.searchT=0; C2.prog=0; C2.pulled=0; }
       if(far){ p.x=far.x; p.y=far.y; }
       // THE SEARCH RUNS ON THE HOST for seat 1 through frames of the real loop: the loot goes to that seat in the order of the host list, one stage at a time, and the box is told open to everyone.
       sentA.length=0; sentB.length=0;
       var fr=0; while(C1&&!C1.opened&&fr<160){ frames(1); fr++; }
       if(!C1||!C1.opened) bad.push('after '+fr+' frames the box seat 1 searches is not open (bar '+(C1?C1.prog:'?')+' of '+(C1?C1.time:'?')+', holds '+js(NET.holds)+')');
       var got=lootOf(sentA,cid1), lw=words(sentA,'loot');
       if(js(got)!==js(L0)) bad.push('the loot posted to seat 1 is not the host list in its order ('+js(got)+' against '+js(L0)+')');
       if(!lw.length||!lw[lw.length-1].done) bad.push('the last loot word does not say the box is done ('+js(lw)+')');
       if(lw.length<2) bad.push('the loot came in '+lw.length+' word(s): the staged pulls did not come out one at a time as the bar filled');
       if(lootOf(sentB,cid1).length) bad.push('loot from the box seat 1 searched was posted to seat 2');
       if(C1&&C1.loot.length) bad.push('the host list still holds '+C1.loot.length+' items after the box was emptied for seat 1');
       if(C1&&(C1.netBy!==-1||(NET.holds&&NET.holds[1]))) bad.push('the box is still held after it was emptied (by '+(C1?C1.netBy:'?')+')');
       var ow=contWords(sentA,cid1,'open'), ow2=contWords(sentB,cid1,'open');
       if(ow.length!==1||ow2.length!==1||ow[0].by!==1||ow2[0].by!==1) bad.push('the box was not told open once to everyone with the seat that searched it (seat 1 '+js(ow)+', seat 2 '+js(ow2)+')');
       if(G.bag.length!==bag0) bad.push('the host own backpack gained '+(G.bag.length-bag0)+' from a search one of the party made');
       if(js(P.stash)!==stash0||P.credits!==cred0) bad.push('the host own stash or credits changed through a search one of the party made');
       if(G.tel.containers!==tc0) bad.push('a search one of the party made was counted as a container the host opened ('+G.tel.containers+' against '+tc0+')');
       var r3=C1?netOnMsg(B,js({t:'srch',op:'start',cid:cid1,slow:1})):'no box';
       if(r3!=='srch:open') bad.push('a request on the emptied box was not refused as open ('+r3+')');
       // A WINDOW THAT COMES UP is told which boxes are open: an in word from seat 2.
       sentB.length=0;
       var iw=netOnMsg(B,js({t:'up',st:'in'})), aw=last(sentB,'cont');
       if(iw!=='up:in'||!aw||aw.st!=='all'||!aw.open||aw.open.indexOf(cid1)<0) bad.push('a seat that came up was not told which boxes are open ('+iw+', '+js(aw?{st:aw.st,open:aw.open}:null)+')');
       // THE KEY MARK follows the host list: a box holding a locked room key keeps the mark the sector map draws until one of the party pulls the key out, before the box opens.
       var K=keyBox(), kid=null, kx;
       if(!K){ for(q in ITEMS) if(Object.prototype.hasOwnProperty.call(ITEMS,q)&&q.indexOf('key_')===0&&ITEMS[q]){ kid=q; break; } K=pickBox([C1,C2,C3],1); if(K&&kid) K.loot.unshift(kid); }
       else { for(kx=0;kx<K.loot.length;kx++) if(String(K.loot[kx]).indexOf('key_')===0){ kid=K.loot[kx]; K.loot.splice(kx,1); K.loot.unshift(kid); break; } }
       if(K&&K.loot.length<2) K.loot.push('scrap');
       if(!K||!kid) bad.push('no box holding a locked room key at seed 4242 and no key item to put in one');
       else {
         G.intel=1; G.intelKeys=[K];
         if(!markOn(K)) bad.push('control: the box holding a key shows no KEY mark before the search');
         fileAt(B,K.x+8,K.y); sentB.length=0;
         var rk=netOnMsg(B,js({t:'srch',op:'start',cid:K.cid,slow:1}));
         if(rk!=='srch:ok') bad.push('the request on the key box from seat 2 was not granted ('+rk+')');
         fr=0; while(hasKey(K)&&!K.opened&&fr<160){ frames(1); fr++; }
         if(hasKey(K)||K.opened) bad.push('after '+fr+' frames the key is still in the box or the box opened before the key came out (key '+hasKey(K)+', open '+K.opened+')');
         if(markOn(K)) bad.push('the KEY mark stays on the box after one of the party pulled the key out');
         if(lootOf(sentB,K.cid).indexOf(kid)<0) bad.push('the key was not posted to the seat that pulled it ('+js(lootOf(sentB,K.cid))+')');
         fr=0; while(!K.opened&&fr<160){ frames(1); fr++; }
         if(!K.opened||markOn(K)) bad.push('the key box did not open for seat 2 or keeps its mark open (open '+K.opened+')');
         G.intel=0; G.intelKeys=[];
       }
       // A HOLD LET GO keeps its progress and frees the box; a second request resumes from that bar.
       if(C3){ fileAt(A,C3.x+8,C3.y); sentA.length=0; sentB.length=0; }
       var r5=C3?netOnMsg(A,js({t:'srch',op:'start',cid:C3.cid,slow:1})):'no box';
       if(r5!=='srch:ok') bad.push('the request on the third box was not granted ('+r5+')');
       frames(4);
       var pr3=C3?(C3.prog||0):0;
       rng0=RNGS;
       var r6=C3?netOnMsg(A,js({t:'srch',op:'stop',cid:C3.cid})):'no box';
       if(r6!=='srch:stop'||!C3||C3.netBy!==-1||(NET.holds&&NET.holds[1])||C3.opened) bad.push('letting go did not free the box ('+r6+', by '+(C3?C3.netBy:'?')+', holds '+js(NET.holds)+')');
       if(!contWords(sentB,C3?C3.cid:-1,'free').length) bad.push('the other seat was not told the box is free again');
       if(!(pr3>0.1)||(C3&&Math.abs((C3.prog||0)-pr3)>0.0001)) bad.push('the box did not keep its progress when the hold was let go ('+pr3+' then '+(C3?C3.prog:'?')+')');
       sentA.length=0;
       var r7=C3?netOnMsg(A,js({t:'srch',op:'start',cid:C3.cid,slow:1})):'no box', an7=last(sentA,'srch');
       if(r7!=='srch:ok'||!an7||!(an7.prog>0.1)) bad.push('a second request did not resume from the kept bar ('+r7+', '+js(an7)+')');
       netOnMsg(A,js({t:'srch',op:'stop',cid:C3?C3.cid:-1}));
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the stop and the second request');
       // A BODY THE HOST MADE MID RAID is numbered and told new on the next tick, then told open and shut as it changes.
       var NB=setLoot(mkContainer(p.x+60,p.y,'body'),['scrap']); G.containers.push(NB);
       sentA.length=0; rng0=RNGS;
       netContTick();
       var nw=last(sentA,'cont');
       if(typeof NB.cid!=='number'||NB.cid!==165||!nw||nw.st!=='new'||nw.cid!==NB.cid||nw.ty!=='body'||nw.n!==1||netContOf(NB.cid)!==NB) bad.push('a body the host made mid raid was not numbered 165 and told new on the next tick ('+js(nw)+', number '+NB.cid+')');
       NB.opened=true; sentA.length=0; netContTick(); nw=last(sentA,'cont');
       if(!nw||nw.st!=='open'||nw.cid!==NB.cid) bad.push('a box the host opened was not told open on the next tick ('+js(nw)+')');
       NB.opened=false; sentA.length=0; netContTick(); nw=last(sentA,'cont');
       if(!nw||nw.st!=='shut'||nw.cid!==NB.cid) bad.push('a box shut again was not told shut on the next tick ('+js(nw)+')');
       sentA.length=0; netContTick();
       if(words(sentA,'cont').length) bad.push('a tick with nothing changed posted '+words(sentA,'cont').length+' container words');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through four container ticks');
       down();
       netReset();
       if(G||state!=='hub') bad.push('the host raid did not come down to the Undercroft (state '+state+')');

       // TWO: CONTROL, the party off. Nothing is numbered, a held E empties the box into the backpack from the local list, and the net section holds no search.
       fresh();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.containers.length!==165) bad.push('control: the solo build is not 165 containers');
       if(G&&G.containers[0].cid!==undefined) bad.push('control: with the party off the containers are numbered ('+G.containers[0].cid+')');
       var X=pickBox([],1,['crate','locker']), xb=G.bag.length, xl=X?X.loot.length:0;
       if(!X) bad.push('control: no box to search');
       if(X){ standOn(X); keys['KeyE']=true; for(q=0;q<60;q++) updatePlayer(0.05); keys['KeyE']=false; }
       if(!X||!X.opened||G.bag.length!==xb+xl) bad.push('control: with the party off a held E did not empty the box into the backpack from the local list (open '+(X?X.opened:'?')+', bag '+(G.bag.length-xb)+' of '+xl+')');
       if(NET.srch||NET.srchOwn!==-1||(NET.holds&&Object.keys(NET.holds).length)) bad.push('control: with the party off the net section holds a search');
       down();

       // THREE: THE LINKED WINDOW up top on the host word: the same numbers, a held E asks the host and grants nothing here, the host words move everything.
       netStartJoin(); NET.seat=1;
       var H=link(0,'ZQX HOST',sentB); NET.peers.push(H);
       NET.roster=[{seat:0,pid:'zqxseat0',name:'ZQX HOST',host:true},{seat:1,pid:NET.pid,name:NET.name,host:false},{seat:2,pid:'zqxseat2',name:'ZQX OTHER',host:false}];
       fresh(); P.intel=0; P.terms=[];
       var tk=RW?netOnMsg(H,js(RW)):'no word';
       if(tk!=='up') bad.push('the raid word did not take this window up ('+tk+')');
       if(!G||G.seed!==4242||state!=='raid') bad.push('this window is not up top on seed 4242 (seed '+(G?G.seed:'no raid')+', state '+state+')');
       if(!netContPeer()) bad.push('this window up top on the host seed does not know the host owns the boxes');
       nc=0; for(q=0;q<G.containers.length;q++) if(G.containers[q].cid===q) nc++;
       if(nc!==G.containers.length||netContOf(0)!==G.containers[0]) bad.push('this window did not number its boxes in list order ('+nc+' of '+G.containers.length+')');
       frames(1);
       p=G.player;
       var E1=pickBox([],1,['crate','locker']), E2=pickBox(E1?[E1]:[],1), E3=pickBox(E1?[E1,E2]:[],1), E4=pickBox(E1?[E1,E2,E3]:[],1);
       if(!E1||!E2||!E3||!E4) bad.push('fewer than four boxes to search on this window');
       // A HELD E ON A BOX asks the host once and grants nothing here; the bar stands until the host grants it.
       var eb=G.bag.length, el0=E1?E1.loot.length:0, stashP=js(P.stash);
       if(E1){ standOn(E1); sentB.length=0; keys['KeyE']=true; updatePlayer(0.05); }
       var sw=last(sentB,'srch');
       if(!E1||G.searching!==E1||!sw||sw.op!=='start'||sw.cid!==E1.cid||typeof sw.slow!=='number') bad.push('a held E on a box did not ask the host to search it ('+js(sw)+', searching '+(G.searching?'a box':'nothing')+')');
       if(!NET.srch||NET.srch.cid!==(E1?E1.cid:-2)||NET.srch.ok) bad.push('the request is not held as asked ('+js(NET.srch)+')');
       updatePlayer(0.05); updatePlayer(0.05);
       if(E1&&((E1.prog||0)>0||E1.loot.length!==el0||G.bag.length!==eb)) bad.push('before the host answered, a held E moved the bar or granted from this window own list (bar '+(E1?E1.prog:'?')+', list '+(E1?E1.loot.length:'?')+' of '+el0+', backpack '+(G.bag.length-eb)+')');
       rng0=RNGS;
       var ar=E1?netOnMsg(H,js({t:'srch',cid:E1.cid,ok:1,prog:0.3,n:2})):'no box';
       if(ar!=='srch:ok'||!NET.srch||!NET.srch.ok||!E1||Math.abs((E1.prog||0)-0.3)>0.001) bad.push('the host answer did not grant the search from where the host has the bar ('+ar+', '+js(NET.srch)+', bar '+(E1?E1.prog:'?')+')');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the answer');
       for(q=0;q<50;q++) updatePlayer(0.05);   // two and a half seconds of holding: the bar fills to the top and stops, the box stays shut, nothing is granted here
       if(E1&&!(E1.prog>0.3)) bad.push('the bar did not move once the host granted the search');
       if(E1&&E1.prog>E1.time+0.001) bad.push('the bar ran past the top ('+E1.prog+' of '+E1.time+')');
       if(E1&&(E1.opened||E1.loot.length!==el0||G.bag.length!==eb)) bad.push('holding E on a box the host runs granted from this window own list or opened it here ('+js({open:E1.opened,list:E1.loot.length,was:el0,backpack:G.bag.length-eb})+')');
       if(words(sentB,'srch').length!==1) bad.push('holding E asked the host '+words(sentB,'srch').length+' times for one box');
       // A LOOT WORD puts the items in this window own backpack; the done word closes the box and counts it on this run.
       var tc=G.tel.containers; rng0=RNGS;
       var lr=E1?netOnMsg(H,js({t:'loot',cid:E1.cid,items:['scrap']})):'no box';
       if(lr!=='loot'||G.bag.length!==eb+1||G.bag.indexOf('scrap')<0) bad.push('a loot word did not put the item in this window own backpack ('+lr+', '+js(G.bag)+')');
       if(E1&&(E1.opened||G.searching!==E1||!NET.srch)) bad.push('a loot word closed the box or let go of the search before the host said done');
       var lr2=E1?netOnMsg(H,js({t:'loot',cid:E1.cid,items:['wire'],done:1})):'no box';
       if(lr2!=='loot'||G.bag.length!==eb+2||G.bag.indexOf('wire')<0||!E1||!E1.opened||G.searching!==null||NET.srch||E1.loot.length!==0||G.tel.containers!==tc+1)
         bad.push('the done word did not put the item in the backpack, close the box, count it on this run and let go ('+js({r:lr2,backpack:G.bag.length-eb,open:E1?E1.opened:null,searching:!!G.searching,asked:!!NET.srch,left:E1?E1.loot.length:null,counted:G.tel.containers-tc})+')');
       if(js(P.stash)!==stashP) bad.push('a loot word wrote the stash: the backpack banks at extraction, not here');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through two loot words');
       keys['KeyE']=false; frames(2);
       // AN OPEN WORD marks a box searched so a held E starts nothing and asks nothing; control: before the word it asks, and letting go tells the host.
       if(E2){ standOn(E2); sentB.length=0; keys['KeyE']=true; updatePlayer(0.05); }
       if(!E2||G.searching!==E2||!last(sentB,'srch')||last(sentB,'srch').cid!==E2.cid) bad.push('control: before the open word a held E on the second box did not ask the host ('+js(last(sentB,'srch'))+')');
       keys['KeyE']=false; frames(2);
       var stw=last(sentB,'srch');
       if(!E2||!stw||stw.op!=='stop'||stw.cid!==E2.cid||NET.srch) bad.push('letting go of E did not tell the host the search stopped ('+js(stw)+', asked '+js(NET.srch)+')');
       rng0=RNGS;
       var cw=E2?netOnMsg(H,js({t:'cont',cid:E2.cid,st:'open',by:0})):'no box';
       if(RNGS!==rng0) bad.push('the seeded stream moved through an open word');
       sentB.length=0; keys['KeyE']=true; updatePlayer(0.05); updatePlayer(0.05); keys['KeyE']=false;
       var askedE2=false; for(q=0;q<sentB.length;q++) if(sentB[q]&&sentB[q].t==='srch'&&sentB[q].op==='start'&&E2&&sentB[q].cid===E2.cid) askedE2=true;
       if(cw!=='cont:open'||!E2||!E2.opened||G.searching===E2||askedE2) bad.push('after the open word a held E on the box still searched it ('+cw+', open '+(E2?E2.opened:'?')+', searching it '+(G.searching===E2)+', asked '+askedE2+')');
       frames(2);
       // A HELD WORD keeps a held E off a box another seat holds; a free word lets it ask.
       if(E3) standOn(E3);
       var hw=E3?netOnMsg(H,js({t:'cont',cid:E3.cid,st:'held',by:2})):'no box';
       sentB.length=0; keys['KeyE']=true; updatePlayer(0.05);
       var askedE3=false; for(q=0;q<sentB.length;q++) if(sentB[q]&&sentB[q].t==='srch'&&sentB[q].op==='start'&&E3&&sentB[q].cid===E3.cid) askedE3=true;
       if(hw!=='cont:held'||!E3||E3.netBy!==2||G.searching===E3||askedE3) bad.push('a box seat 2 holds was searched or asked for from this window ('+hw+', by '+(E3?E3.netBy:'?')+', searching it '+(G.searching===E3)+', asked '+askedE3+')');
       if(!(/searching/i).test(String(window.__lastSay||''))) bad.push('this window was not told who holds the box (last line: '+String(window.__lastSay||'')+')');
       var fw=E3?netOnMsg(H,js({t:'cont',cid:E3.cid,st:'free',by:2})):'no box';
       updatePlayer(0.05);
       if(fw!=='cont:free'||!E3||E3.netBy!==-1||G.searching!==E3||!last(sentB,'srch')||last(sentB,'srch').cid!==E3.cid) bad.push('after the free word a held E did not ask the host for the box ('+fw+', by '+(E3?E3.netBy:'?')+', asked '+js(last(sentB,'srch'))+')');
       keys['KeyE']=false; frames(2);
       // A SHUT WORD puts a searched box back; a NEW WORD makes a body the host made, and a held E asks for it; an ALL word marks open and held boxes.
       rng0=RNGS;
       var shw=E1?netOnMsg(H,js({t:'cont',cid:E1.cid,st:'shut',by:0})):'no box';
       if(shw!=='cont:shut'||!E1||E1.opened||E1.prog!==0||E1.netBy!==-1) bad.push('a shut word did not put the searched box back ('+shw+')');
       var n0=G.containers.length, nwr=netOnMsg(H,js({t:'cont',st:'new',cid:900,x:Math.round(p.x)+300,y:Math.round(p.y),ty:'body',tm:1,n:2,d:-1})), NE=netContOf(900);
       if(nwr!=='cont:new'||!NE||G.containers.length!==n0+1||NE.type!=='body'||NE.cid!==900||NE.loot.length!==0||NE.opened) bad.push('a new word did not make the body the host made ('+nwr+', '+js(NE?{k:NE.type,cid:NE.cid,n:NE.loot.length}:null)+')');
       if(netOnMsg(H,js({t:'cont',st:'new',cid:900,x:0,y:0,ty:'body',tm:1,n:2}))!=='cont:known') bad.push('a new word for a box already made was taken again');
       var alw=E4?netOnMsg(H,js({t:'cont',st:'all',open:[E4.cid],held:[[E3.cid,2]]})):'no box';
       if(alw!=='cont:all'||!E4||!E4.opened||!E3||E3.netBy!==2) bad.push('an all word did not mark the open and held boxes ('+alw+')');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the shut, new and all words');
       if(NE){ standOn(NE); sentB.length=0; keys['KeyE']=true; updatePlayer(0.05); keys['KeyE']=false; }
       if(!NE||G.searching!==NE||!last(sentB,'srch')||last(sentB,'srch').cid!==900) bad.push('a held E on the body the host made did not ask the host for it ('+js(last(sentB,'srch'))+')');
       frames(2);
       // THE HOST LEAVING. Another seat leaving ends nothing; the out word from seat 0 ends this raid as abandon through endRaid, with the host left line on the run card.
       spy(); erCalls.length=0; G.tel.shots=1;   // not an instant quit, which shows no card
       var o2=netOnMsg(H,js({t:'up',s:2,st:'out',how:'dead'}));
       var rw2=netOnMsg(H,js({t:'roster',roster:[{seat:0,pid:'zqxseat0',name:'ZQX HOST',host:true},{seat:1,pid:NET.pid,name:NET.name,host:false}]}));
       if(o2!=='up:out'||rw2!=='roster'||erCalls.length||!G||G.over) bad.push('control: another seat leaving ended this raid ('+o2+', '+rw2+', '+js(erCalls)+', over '+(G?G.over:'no raid')+')');
       var o0=netOnMsg(H,js({t:'up',s:0,st:'out',how:'extract'}));
       var sub=g('oc_sub')?String(g('oc_sub').textContent||''):'', ttl=g('oc_title')?String(g('oc_title').textContent||''):'', card=!!(g('outcome')&&g('outcome').classList.contains('on'));
       if(o0!=='up:out'||js(erCalls)!==js(['abandon'])||!G||G.over!=='abandon') bad.push('the host out word did not end this raid as abandon through endRaid ('+o0+', '+js(erCalls)+', over '+(G?G.over:'no raid')+')');
       if(!card||ttl!=='ABANDONED'||sub.indexOf('HOST')<0||sub.indexOf('ABANDON')<0) bad.push('the run card does not say the host left (card '+card+', title '+ttl+', line: '+sub+')');
       if(!(/host/i).test(NET.status||'')) bad.push('the PARTY window status does not say the host left: '+NET.status);
       unspy();
       down();
       // THE LOST LINK: up again on the same word, then the link to the host drops: abandon again, with the line, and the party off.
       fresh(); P.intel=0; P.terms=[];
       var tk2=RW?netOnMsg(H,js(RW)):'no word';
       if(tk2!=='up'||!G||G.seed!==4242) bad.push('this window did not go up a second time ('+tk2+', '+(G?G.seed:'no raid')+')');
       spy(); erCalls.length=0; if(G) G.tel.shots=1;
       netDrop(H,'closed');
       sub=g('oc_sub')?String(g('oc_sub').textContent||''):'';
       if(js(erCalls)!==js(['abandon'])||!G||G.over!=='abandon') bad.push('the lost link to the host did not end this raid as abandon through endRaid ('+js(erCalls)+', over '+(G?G.over:'no raid')+')');
       if(sub.indexOf('HOST')<0||sub.indexOf('ABANDON')<0) bad.push('after the lost link the run card does not say the host was lost: '+sub);
       if(NET.on) bad.push('the party is still on after the link to the host was lost');
       unspy();
       down();
       if(G||state!=='hub') bad.push('this window raid did not come down to the Undercroft');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ unspy(); }catch(_us){}
       try{ keys={}; }catch(_k){}
       try{ if(G) __endRaid('abandon'); }catch(_er){}
       try{ if(G){ G=null; keys={}; } }catch(_g0){}
       try{ NET.on=false; NET.upHold=false; NET.upIss=null; pendSeed=null; netReset(); }catch(_nr){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ P.equipped=keepEq; P.weapons=keepWp; P.intel=keepIntel; P.terms=keepTerms; P.wxPick=keepWx; }catch(_kp){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
