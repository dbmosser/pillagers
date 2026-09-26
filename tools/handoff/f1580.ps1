$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.80',what:")) { throw "check 15.80 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.80. Synchronous, as the fixture runner does not await a promise a check returns, and it never makes a connection:
# the party is a stand-in link whose channel records what is sent, the words are fed to the real netOnMsg, the host ascends
# through the real ascent path (__deploy, commitKit, startRaid) and the linked window through the real netUpTake and
# startRaid, the frames are the real loop (__loop) and the rounds the real updateBullets. Three raids are built (the host, the
# solo control, the linked window) and every one is ended in finally. The live half between two real windows is the enemy
# step of RUN RAID in tools/nettest.html.
SubRx @'
  {v:'15.79',what:
'@ @'
  {v:'15.80',what:'one set of enemies run by the host, seen and felt by everyone: at the build the host numbers its 85 bodies in list order; with one of the party filed up top beside a hostile pillager and the host player far away, a few frames of the real loop post snapshots at ten a second and put that pillager in chase on the party member spot (the field the AI steers by), a host tick posts one snapshot on the fast channel naming that pillager at its rounded place and in chase, with the reach lifted every body fits one packet under the message cap, an enemy round through the real updateBullets on the party member spot posts a hit word to his seat with its damage and its shooter and the host player health is untouched with damagePlayer never called, a host round on that spot posts nothing and hurts nobody (no team damage), a shot request from that seat lowers a crawler by what it says and clears its mark while it stands, a second request that kills it marks the seat, the next frame takes it off the list without counting it for the host, and the next tick posts a gone word and a kill word to that seat; a body pushed mid raid is numbered and told to the party with its name on the next tick and told gone when it leaves; the seeded stream never moves through the ticks and the requests; CONTROL with the party off: no body is numbered, a tick posts nothing, and the bodies move on their own over six frames; THE LINKED WINDOW up top on the host word numbers the same bodies the same way, its own updateEnts moves none of them over six frames, a first snapshot puts a crawler where the host says at once and in chase, a second slides it there over six frames while the others stand still, an older snapshot and one from another seed are dropped, a new word makes a named sentry with its health, a snapshot row for a body never seen makes it on the spot, a gone word takes a body off the list and the map and a late packet from before it does not bring the body back, an out word marks a pillager extracted on the board, a hit word lowers this player through its own damagePlayer and one for another seat does not, its own round on a crawler posts a shot request with the damage it worked out and leaves the crawler untouched here, and a kill word counts the crawler on its own run (multiplayer phase 2 build 2)',
   run:function(){
     // THE SHARED ENEMIES ARE THERE. Without them each window runs its own, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netEntsTick!=='function'||typeof netEntsApply!=='function'||typeof netTargetFor!=='function'||typeof netHitPlayer!=='function'||
        typeof netShotTake!=='function'||typeof netShotSend!=='function'||typeof netEntsEase!=='function'||typeof netEntWord!=='function'||typeof netKillTake!=='function'||
        typeof netHitTake!=='function'||typeof netEntsInit!=='function'||typeof netNearDist!=='function'||typeof netBulletPeer!=='function'||typeof netAreaHitPeers!=='function'||
        typeof netEntsPeer!=='function'||typeof NET_ENT_KINDS==='undefined'||typeof NET_ENT_STATES==='undefined'||typeof NET_ENT_RANGE==='undefined')
       return 'this build runs a separate set of pillagers and machines in every window: the host sends no snapshot of its bodies (no netEntsTick or netEntsApply), no body picks a player but the host player (no netTargetFor), and a blow on one of the party reaches nobody (no netHitPlayer)';
     if(typeof netOnMsg!=='function'||typeof netReset!=='function'||typeof netStartHost!=='function'||typeof netStartJoin!=='function'||typeof netRosterBuild!=='function'||
        typeof netUpFp!=='function'||typeof netUpFpText!=='function'||typeof updateEnts!=='function'||typeof updateBullets!=='function'||typeof damagePlayer!=='function'||
        typeof startRaid!=='function'||typeof endRaid!=='function'||typeof showScreen!=='function'||typeof losClear!=='function'||typeof spotFree!=='function'||typeof mkSentry!=='function'||
        typeof WEAPONS==='undefined'||typeof NET_MSG_MAX==='undefined'||!window.__loop) return 'this build has no raid under the party';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     if(!window.__deploy||!window.__hubEnter||!window.__endRaid||!window.__resetCfg||!window.__pinDefaults||!window.__cleanProfile) return 'SKIP: this fixture cannot ascend';
     var bad=[], rng0=null, keepEq=P.equipped, keepWp=(P.weapons||[]).slice(), keepIntel=P.intel, keepTerms=P.terms, keepWx=P.wxPick, keepRange=NET_ENT_RANGE;
     var _s2=say2, sentA=[], sentB=[], oDP=damagePlayer, dpCalls=[], spied=false, q, p, RW=null;
     var g=function(id){ return document.getElementById(id); };
     function js(o){ return JSON.stringify(o); }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     // A stand-in link: what the game sends on it is written down. Never a real connection.
     function link(seat,name,box){ return {id:++NET.sid,pc:null,dc:{readyState:'open',send:function(s){ var o=null; try{ o=JSON.parse(s); }catch(e){ o={t:'unreadable'}; } box.push(o); }},fc:null,state:'in',seat:seat,pid:'zqxseat'+seat,name:name,timers:[]}; }
     function words(box,t){ var o=[], i; for(i=0;i<box.length;i++) if(box[i]&&box[i].t===t) o.push(box[i]); return o; }
     function last(box,t){ var o=words(box,t); return o.length?o[o.length-1]:null; }
     // THE SPY: every blow the host player takes through damagePlayer.
     function spy(){ if(spied) return; spied=true; damagePlayer=function(a,s,nm,x,y){ dpCalls.push({a:a,s:String(s)}); return oDP.apply(null,arguments); }; }
     function unspy(){ if(!spied) return; spied=false; damagePlayer=oDP; }
     function frames(n){ var i; for(i=0;i<n;i++) __loop(lastTs+50); }
     function byNid(id){ var i; for(i=0;i<G.ents.length;i++) if(G.ents[i].nid===id) return G.ents[i]; return null; }
     function firstOf(kind,not){ var i, e; for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(e.kind===kind&&e!==not&&e.hp>0&&!e.downed&&!e.finished) return e; } return null; }
     function numbered(){ var i, ok=0; for(i=0;i<G.ents.length;i++) if(G.ents[i].nid===i+1) ok++; return ok; }
     function down(){ try{ if(G) __endRaid('abandon'); }catch(_e){} try{ if(G){ G=null; keys={}; showScreen('hub'); } }catch(_e2){} }
     function fresh(){ __resetCfg(); __pinDefaults(0); }
     try{
       __topClear(); closeAll();
       netReset(); say2=function(){};
       try{ __hubEnter(); }catch(_h){}
       if(G) down();
       __cleanProfile();

       // ONE: THE HOST. A stand-in party of one friend, and the real ascent through __deploy on sector 0 at seed 4242.
       P.intel=0; P.terms=[];
       netStartHost();
       var A=link(1,'ZQX MATE',sentA); NET.peers.push(A); NET.roster=netRosterBuild();
       fresh();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.seed!==4242||state!=='raid') bad.push('the host ascent did not build seed 4242 (seed '+(G?G.seed:'no raid')+', state '+state+')');
       var fpH=G?netUpFp(G):null;
       if(!fpH||fpH.e!==85||fpH.c!==165) bad.push('the host built '+netUpFpText(fpH)+' on sector 0 at seed 4242, not the 85 bodies and 165 containers of the fingerprint');
       RW=last(sentA,'raid');
       if(!RW) bad.push('the host ascent told the party no raid word');
       if(G&&numbered()!==G.ents.length) bad.push('the host did not number its bodies in list order at the build ('+(G?numbered():0)+' of '+(G?G.ents.length:0)+')');
       if(!netEntsPeer()&&G&&NET.entMap&&NET.entMap[1]!==G.ents[0]) bad.push('the host does not hold its first body under number 1');
       // THE HOSTILE PILLAGER AND THE SPOT BESIDE IT: open ground 60 units out with a clear line, and the host player far away at a ring.
       p=G.player;
       var R=null, spot=null, ai, ang, cx, cy, cand, far=null, fd=-1, zi;
       for(q=0;q<G.ents.length&&!spot;q++){
         cand=G.ents[q];
         if(cand.kind!=='raider'||cand.merc||cand.friendlyPC||cand.downed||cand.finished||cand.hp<=cand.maxhp*0.3||cand.state==='extract') continue;
         for(ai=0;ai<8;ai++){
           ang=ai*0.7854; cx=cand.x+Math.cos(ang)*60; cy=cand.y+Math.sin(ang)*60;
           if(cx<40||cy<40) continue;
           if(!spotFree(G.map,cx,cy,14)||!losClear(cand.x,cand.y,cx,cy,G.map.segs)) continue;
           R=cand; spot={x:cx,y:cy}; break;
         }
       }
       if(!R) bad.push('no pillager with open ground beside it at seed 4242, so the targeting cannot be driven');
       for(zi=0;zi<(G.zones||[]).length;zi++){ var zd=R?dist(G.zones[zi],R):0; if(zd>fd){ fd=zd; far=G.zones[zi]; } }
       if(!far||fd<700) bad.push('no ring far enough from the pillager to stand the host player at ('+Math.round(fd)+')');
       if(far){ p.x=far.x; p.y=far.y; }
       if(R&&Math.abs(R.tx-spot.x)<5&&Math.abs(R.ty-spot.y)<5) bad.push('control: the pillager already steers by the spot before anyone stands there');
       // One of the party filed up top on the spot, then a few frames of the real loop.
       var st1=netOnMsg(A,js({t:'st',k:'r',sd:4242,x:spot?spot.x:0,y:spot?spot.y:0,f:0,m:0,c:0,sp:0,dn:0,r:0,w:'smg'}));
       if(st1!=='state'||!NET.up[1]) bad.push('the party member was not filed up top ('+st1+')');
       spy(); sentA.length=0; NET.upAcc=0;
       frames(10);
       if(words(sentA,'en').length<3) bad.push('ten frames of the real loop posted '+words(sentA,'en').length+' snapshots, not the four or five of half a second at ten a second');
       if(R&&(R.state!=='chase'||Math.abs(R.tx-spot.x)>0.01||Math.abs(R.ty-spot.y)>0.01)) bad.push('after ten frames the pillager beside the party member does not steer by his spot (state '+(R?R.state:'?')+', target '+(R?(Math.round(R.tx)+','+Math.round(R.ty)):'?')+' against '+(spot?(Math.round(spot.x)+','+Math.round(spot.y)):'?')+'): every body still hunts the host player alone');
       // THE SNAPSHOT: one tick names that pillager at its rounded place, in chase; with the reach lifted every body fits one packet.
       sentA.length=0; rng0=RNGS;
       var sn=netEntsTick();
       var en=last(sentA,'en');
       if(!sn||!en||en.sd!==4242||!en.e||typeof en.e.length!=='number') bad.push('a host tick did not post a snapshot of its bodies ('+js(en?{t:en.t,sd:en.sd,rows:(en.e?en.e.length:null)}:null)+')');
       var row=null, rq;
       if(en&&en.e&&R) for(rq=0;rq<en.e.length;rq++) if(en.e[rq]&&en.e[rq][0]===R.nid) row=en.e[rq];
       if(R&&!row) bad.push('the snapshot does not name the pillager beside the party member (number '+R.nid+')');
       if(row&&(row[2]!==Math.round(R.x)||row[3]!==Math.round(R.y)||NET_ENT_KINDS[row[1]]!=='raider'||NET_ENT_STATES[row[5]]!=='chase')) bad.push('the snapshot row for that pillager is not its place and state ('+js(row)+' against '+Math.round(R.x)+','+Math.round(R.y)+' chase)');
       NET_ENT_RANGE=1e9;
       var sn2=netEntsTick();
       NET_ENT_RANGE=keepRange;
       if(!sn2||!sn2.e||sn2.e.length!==G.ents.length) bad.push('with the reach lifted the snapshot names '+(sn2&&sn2.e?sn2.e.length:0)+' bodies of '+G.ents.length);
       if(sn2&&js(sn2).length>NET_MSG_MAX) bad.push('a snapshot of every body at seed 4242 is '+js(sn2).length+' characters, over the message cap of '+NET_MSG_MAX);
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through two host ticks');
       // AN ENEMY ROUND ON THE PARTY MEMBER: a hit word to his seat, the host player untouched, damagePlayer never called.
       sentA.length=0; dpCalls.length=0;
       var hp0=p.hp;
       if(spot&&R){ G.bullets.push({x:spot.x-6,y:spot.y,vx:120,vy:0,dmg:9,life:1,player:false,owner:R,tint:'#fff'}); updateBullets(0.05); }
       var hw=last(sentA,'hit');
       if(!hw||hw.seat!==1||hw.dmg!==9||hw.kind!=='raider'||hw.name!==(R?R.name:'')) bad.push('an enemy round on the party member did not post a hit word to his seat with its damage and its shooter ('+js(hw)+')');
       if(p.hp!==hp0) bad.push('an enemy round on the party member took '+(hp0-p.hp)+' off the HOST player');
       if(dpCalls.length) bad.push('an enemy round on the party member went through the host damagePlayer ('+js(dpCalls)+')');
       // NO TEAM DAMAGE: a host round on the same spot posts nothing and hurts nobody.
       sentA.length=0; dpCalls.length=0;
       if(spot){ G.bullets.push({x:spot.x-6,y:spot.y,vx:120,vy:0,dmg:9,life:1,player:true,owner:G.player,tint:'#fff'}); updateBullets(0.05); }
       if(last(sentA,'hit')) bad.push('a round from the host player on the party member posted a hit word: team damage');
       if(dpCalls.length||p.hp!==hp0) bad.push('a round from the host player on the party member hurt someone');
       // A SHOT REQUEST FROM THAT SEAT: a crawler loses what it says; its mark clears while it stands, and a killing request marks the seat.
       var C=firstOf('crawler',null), hpC=C?C.hp:0, k0=G.tel.kills.crawler;
       if(!C) bad.push('no crawler alive at seed 4242 to shoot');
       rng0=RNGS;
       var sr=C?netOnMsg(A,js({t:'shot',id:C.nid,dmg:10,x:spot?spot.x:0,y:spot?spot.y:0,a:0})):'no crawler';
       if(sr!=='shot'||!C||Math.abs(C.hp-(hpC-10))>0.01) bad.push('a shot request from the party member did not lower the crawler by what it said ('+sr+', '+(C?C.hp:'?')+' against '+(hpC-10)+')');
       if(C&&(C.bySeat||C.byPlayer)) bad.push('a blow the crawler stood through left a kill mark on it (seat '+C.bySeat+', player '+C.byPlayer+')');
       if(C&&(C.state!=='chase'||Math.abs(C.tx-spot.x)>0.01)) bad.push('the crawler shot by the party member does not turn onto him (state '+C.state+')');
       var sr2=C?netOnMsg(A,js({t:'shot',id:C.nid,dmg:300,x:spot?spot.x:0,y:spot?spot.y:0,a:0})):'no crawler';
       if(sr2!=='shot'||!C||C.hp>0||C.bySeat!==1||C.byPlayer) bad.push('a killing request did not mark the seat that made it ('+sr2+', hp '+(C?C.hp:'?')+', seat '+(C?C.bySeat:'?')+')');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through two shot requests');
       sentA.length=0;
       frames(1);
       if(C&&G.ents.indexOf(C)>=0) bad.push('the crawler the party member killed is still on the list a frame later');
       if(G.tel.kills.crawler!==k0) bad.push('the crawler the party member killed was counted for the host ('+G.tel.kills.crawler+' against '+k0+')');
       netEntsTick();
       var gw=last(sentA,'ent'), kw=last(sentA,'kill');
       if(!gw||gw.op!=='gone'||gw.id!==(C?C.nid:-1)||gw.how!=='dead') bad.push('the next tick did not tell the party the crawler is gone ('+js(gw)+')');
       if(!kw||kw.seat!==1||kw.id!==(C?C.nid:-1)||kw.k!=='crawler') bad.push('the next tick did not credit the kill to the seat that made it ('+js(kw)+')');
       if(C&&netOnMsg(A,js({t:'shot',id:C.nid,dmg:5,x:0,y:0}))!=='gone') bad.push('a shot request on a body that left was taken');
       // A BODY PUSHED MID RAID is numbered and told to the party with its name on the next tick, and told gone when it leaves.
       var NS=mkSentry(p.x+200,p.y); G.ents.push(NS);
       sentA.length=0;
       netEntsTick();
       var nw=last(sentA,'ent');
       if(!NS.nid||!nw||nw.op!=='new'||nw.id!==NS.nid||nw.k!=='sentry'||nw.n!==NS.name) bad.push('a body that arrived mid raid was not numbered and told to the party with its name ('+js(nw)+', number '+NS.nid+')');
       G.ents.splice(G.ents.indexOf(NS),1); NS.hp=0;
       sentA.length=0;
       netEntsTick();
       var gw2=last(sentA,'ent');
       if(!gw2||gw2.op!=='gone'||gw2.id!==NS.nid) bad.push('a body that left was not told gone ('+js(gw2)+')');
       if(last(sentA,'kill')) bad.push('a body nobody in the party killed was credited to a seat');
       unspy();
       down();
       netReset();
       if(G||state!=='hub') bad.push('the host raid did not come down to the Undercroft (state '+state+')');

       // TWO: CONTROL, the party off. No body is numbered, a tick posts nothing, and the bodies move on their own.
       fresh();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.ents.length!==85) bad.push('control: the solo build is not 85 bodies');
       if(G&&G.ents[0].nid!==undefined) bad.push('control: with the party off the bodies are numbered ('+G.ents[0].nid+')');
       if(netEntsTick()!==null) bad.push('control: with the party off a tick posted a snapshot');
       var pos0=[], moved=0;
       for(q=0;q<G.ents.length;q++) pos0.push([G.ents[q].x,G.ents[q].y]);
       frames(6);
       for(q=0;q<G.ents.length&&q<pos0.length;q++) if(Math.abs(G.ents[q].x-pos0[q][0])+Math.abs(G.ents[q].y-pos0[q][1])>0.5) moved++;
       if(!moved) bad.push('control: with the party off no body moved over six frames, so the freeze test below proves nothing');
       down();

       // THREE: THE LINKED WINDOW up top on the host word: the same numbers, its own updateEnts moves nothing, the host words move everything.
       netStartJoin(); NET.seat=1;
       var H=link(0,'ZQX HOST',sentB); NET.peers.push(H);
       NET.roster=[{seat:0,pid:'zqxseat0',name:'ZQX HOST',host:true},{seat:1,pid:NET.pid,name:NET.name,host:false}];
       fresh(); P.intel=0; P.terms=[];
       var tk=RW?netOnMsg(H,js(RW)):'no word';
       if(tk!=='up') bad.push('the raid word did not take this window up ('+tk+')');
       if(!G||G.seed!==4242||state!=='raid') bad.push('this window is not up top on seed 4242 (seed '+(G?G.seed:'no raid')+', state '+state+')');
       if(!netEntsPeer()) bad.push('this window up top on the host seed does not know the host runs its bodies');
       if(G&&numbered()!==G.ents.length) bad.push('this window did not number its bodies in list order ('+(G?numbered():0)+' of '+(G?G.ents.length:0)+')');
       if(G&&NET.entMap[1]!==G.ents[0]) bad.push('this window does not hold its first body under number 1');
       var n85=G?G.ents.length:0;
       pos0=[]; for(q=0;q<G.ents.length;q++) pos0.push([G.ents[q].x,G.ents[q].y]);
       frames(6);
       moved=0;
       for(q=0;q<G.ents.length&&q<pos0.length;q++) if(Math.abs(G.ents[q].x-pos0[q][0])+Math.abs(G.ents[q].y-pos0[q][1])>0.5) moved++;
       if(moved) bad.push('on this window '+moved+' bodies moved on their own over six frames: its own updateEnts still runs them');
       if(G.ents.length!==n85) bad.push('six frames on this window changed the list ('+G.ents.length+' against '+n85+')');
       // A first snapshot puts a crawler where the host says at once, in chase; a second slides it there while the others stand still.
       var E=firstOf('crawler',null), kE=E?NET_ENT_KINDS.indexOf(E.kind):-1, x0=E?Math.round(E.x):0, y0=E?Math.round(E.y):0;
       if(!E) bad.push('no crawler on this window to move');
       rng0=RNGS;
       var ap=E?netOnMsg(H,js({t:'en',sd:4242,n:1,e:[[E.nid,kE,x0+100,y0,1.5,1,20,8]]})):'no crawler';
       if(ap!=='ents'||!E||Math.abs(E.x-(x0+100))>0.01||E.state!=='chase'||!E.moving) bad.push('a first snapshot did not put the crawler where the host says at once ('+ap+', '+(E?(Math.round(E.x)+','+Math.round(E.y)+' '+E.state):'?')+' against '+(x0+100)+','+y0+' chase)');
       var ap2=E?netOnMsg(H,js({t:'en',sd:4242,n:2,e:[[E.nid,kE,x0+200,y0,1.5,1,20,8]]})):'no crawler';
       if(ap2!=='ents'||!E||Math.abs(E.x-(x0+100))>0.01) bad.push('a second snapshot jumped the crawler instead of sliding it ('+(E?Math.round(E.x):'?')+')');
       if(E&&netOnMsg(H,js({t:'en',sd:4242,n:0,e:[[E.nid,kE,x0,y0,0,0,20,0]]}))!=='old') bad.push('an older snapshot was applied');
       if(E&&netOnMsg(H,js({t:'en',sd:777,n:3,e:[[E.nid,kE,x0,y0,0,0,20,0]]}))!=='seed') bad.push('a snapshot from another seed was applied');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the snapshots');
       pos0=[]; for(q=0;q<G.ents.length;q++) pos0.push([G.ents[q].x,G.ents[q].y]);
       frames(6);
       if(E&&(Math.abs(E.x-(x0+200))>8||E.x<x0+150)) bad.push('over six frames the crawler did not slide to where the second snapshot put it ('+Math.round(E.x)+' against '+(x0+200)+')');
       moved=0;
       for(q=0;q<G.ents.length&&q<pos0.length;q++) if(G.ents[q]!==E&&Math.abs(G.ents[q].x-pos0[q][0])+Math.abs(G.ents[q].y-pos0[q][1])>0.5) moved++;
       if(moved) bad.push('while the crawler slid, '+moved+' other bodies moved with no word about them');
       // A new word makes a named sentry with its health; a row for a body never seen makes it on the spot; a gone word takes a body off.
       rng0=RNGS;
       var nwr=netOnMsg(H,js({t:'ent',op:'new',id:900,k:'sentry',x:x0+300,y:y0,n:'ZQX NEWCOMER',r:22,mh:150,hp:20,el:0,ho:1}));
       var NE=byNid(900);
       if(nwr!=='ent:new'||!NE||NE.kind!=='sentry'||NE.name!=='ZQX NEWCOMER'||NE.maxhp!==150||NE.hp!==150||Math.abs(NE.x-(x0+300))>0.01) bad.push('a new word did not make a named sentry with its health ('+nwr+', '+js(NE?{k:NE.kind,n:NE.name,mh:NE.maxhp,hp:NE.hp}:null)+')');
       var ap3=netOnMsg(H,js({t:'en',sd:4242,n:4,e:[[901,NET_ENT_KINDS.indexOf('crawler'),x0+400,y0,0,0,20,0]]}));
       var UE=byNid(901);
       if(ap3!=='ents'||!UE||UE.kind!=='crawler'||UE.r!==15) bad.push('a snapshot row for a body never seen did not make it on the spot ('+ap3+', '+js(UE?{k:UE.kind,r:UE.r}:null)+')');
       var gr=E?netOnMsg(H,js({t:'ent',op:'gone',id:E.nid,how:'dead',n:7})):'no crawler';
       if(gr!=='ent:gone'||!E||G.ents.indexOf(E)>=0||NET.entMap[E.nid]) bad.push('a gone word did not take the crawler off the list and the map ('+gr+', on the list at '+(E?G.ents.indexOf(E):'?')+')');
       // A late packet from before that word names the crawler again: the row is dropped, the rest of the packet applied.
       var ap5=E?netOnMsg(H,js({t:'en',sd:4242,n:5,e:[[E.nid,kE,x0,y0,0,0,20,0],[901,NET_ENT_KINDS.indexOf('crawler'),x0+450,y0,0,0,20,0]]})):'no crawler';
       if(ap5!=='ents'||(E&&byNid(E.nid))||!UE||Math.abs(UE.ntx-(x0+450))>0.01) bad.push('a late packet from before the gone word put the crawler back, or its other rows were dropped ('+ap5+', back '+(E?!!byNid(E.nid):'?')+')');
       var RR=null; for(q=0;q<(G.roster||[]).length;q++) if(G.roster[q].ref&&!G.roster[q].out&&G.ents.indexOf(G.roster[q].ref)>=0){ RR=G.roster[q]; break; }
       if(RR){ var orr=netOnMsg(H,js({t:'ent',op:'gone',id:RR.ref.nid,how:'out'})); if(orr!=='ent:gone'||!RR.out||G.ents.indexOf(RR.ref)>=0) bad.push('an out word did not mark the pillager extracted on the board ('+orr+', out '+RR.out+')'); }
       else bad.push('no pillager on the board to extract');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the new, the row and the gone words');
       // A hit word lowers this player through its own damagePlayer; one for another seat does not.
       spy(); p=G.player; p.iv=0; hp0=p.hp; dpCalls.length=0;
       var hr=netOnMsg(H,js({t:'hit',seat:1,dmg:12,kind:'crawler',name:'ZQX BITER',x:p.x+10,y:p.y}));
       if(hr!=='hit'||dpCalls.length!==1||dpCalls[0].a!==12||dpCalls[0].s!=='crawler'||!(p.hp<hp0)) bad.push('a hit word did not lower this player through its own damagePlayer ('+hr+', '+js(dpCalls)+', hp '+p.hp+' from '+hp0+')');
       dpCalls.length=0; hp0=p.hp;
       var hr2=netOnMsg(H,js({t:'hit',seat:2,dmg:12,kind:'crawler',name:'ZQX BITER',x:p.x+10,y:p.y}));
       if(hr2!=='ignored'||dpCalls.length||p.hp!==hp0) bad.push('a hit word for another seat was taken ('+hr2+')');
       unspy();
       // Its own round on a crawler posts a shot request with the damage it worked out and leaves the crawler untouched here.
       var F=firstOf('crawler',UE), hpF=F?F.hp:0, bl=null;
       if(!F) bad.push('no crawler left on this window to shoot');
       if(F){ F.face=Math.PI; bl={x:F.x-6,y:F.y,vx:120,vy:0,dmg:7,life:1,player:true,owner:G.player,tint:'#fff'}; G.bullets.push(bl); }
       sentB.length=0; rng0=RNGS;
       if(F) updateBullets(0.05);
       var sw=last(sentB,'shot');
       if(!sw||!F||sw.id!==F.nid||sw.dmg!==7||typeof sw.a!=='number'||typeof sw.x!=='number') bad.push('this window round on a crawler did not post a shot request with the damage it worked out ('+js(sw)+')');
       if(F&&F.hp!==hpF) bad.push('this window round lowered the crawler here ('+F.hp+' from '+hpF+'): the host runs it');
       if(bl&&G.bullets.indexOf(bl)>=0) bad.push('the round that landed on the crawler flew on');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through a round on a body the host runs');
       // A kill word counts the crawler on this run; one for another seat does not.
       k0=G.tel.kills.crawler;
       var kr=F?netOnMsg(H,js({t:'kill',seat:1,id:F.nid,k:'crawler'})):'no crawler';
       if(kr!=='kill'||G.tel.kills.crawler!==k0+1) bad.push('a kill word did not count the crawler on this run ('+kr+', '+G.tel.kills.crawler+' against '+(k0+1)+')');
       if(F&&(netOnMsg(H,js({t:'kill',seat:2,id:F.nid,k:'crawler'}))!=='ignored'||G.tel.kills.crawler!==k0+1)) bad.push('a kill word for another seat was counted');
       down();
       if(G||state!=='hub') bad.push('this window raid did not come down to the Undercroft');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ unspy(); }catch(_us){}
       try{ NET_ENT_RANGE=keepRange; }catch(_kr){}
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
  {v:'15.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
