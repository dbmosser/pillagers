(function(){ var C=[
  {v:'13.32',what:'the quick ascent, which skips the sector page, tells a player who lands with a loaner that his own gun waits in his stash and how to take it, after the weather line rather than over it, and only when his stash holds a gun and nothing of his own is equipped',
   run:function(){
     if(!(window.__hubEnter&&window.__hb&&window.__keys&&window.__showScreen&&window.__state&&window.__endRaid&&window.__P&&window.__loop)) return 'SKIP: this fixture cannot walk the floor or step the loop';
     if(typeof updateHubWorld!=='function'||typeof startRaid!=='function') return 'SKIP: this build has no floor update or no raid to start';
     if(!ITEMS.gun_smg||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: this build has no stash gun item to stage';
     // r1334: the frame loop draws, and a pane with no layout throws in drawImage.
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     var bad=[], P2=__P();
     var keep={equipped:P2.equipped,equippedSec:P2.equippedSec,weapons:(P2.weapons||[]).slice(),stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),freeKit:P2.freeKit,hot:JSON.parse(JSON.stringify(P2.hotAssign||{}))};
     var needle=['Equip','your','own','gun'].join(' ');
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     function ascend(equipped,weapons,stash){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       endAny();
       __showScreen('hub'); __hubEnter();
       var HBx=__hb(); if(!HBx||!HBx.stations) return {none:'no floor to stand on'};
       var lift=null, i;
       for(i=0;i<HBx.stations.length;i++) if(HBx.stations[i].id==='lift') lift=HBx.stations[i];
       if(!lift) return {none:'this build has no lift'};
       P2.freeKit=0; P2.kit=[]; P2.hotAssign={}; P2.equipped=equipped; P2.equippedSec='none'; P2.weapons=weapons.slice(); P2.stash=stash.slice();
       var K=__keys(), k;
       for(k in K) delete K[k];
       HBx.player.x=lift.x; HBx.player.y=lift.y; HBx.eLock=false;
       K.KeyR=1;
       for(i=0;i<6;i++) updateHubWorld(0.05);
       for(k in K) delete K[k];
       var G2=__state();
       if(!G2||G2.over||G2.sim) return {none:'the quick ascent key did not start a raid'};
       var seen=[], t0=performance.now();
       // v21.86 (raid text R04): two message rows, and a raid line may carry its detail (o.sub, v21.94). A line on either row,
       // headline or detail, counts as shown, so the planned YOU CARRY A LOANER with Equip your own gun as its detail reads too.
       function note(){ var g=__state(); if(!g) return; var up=[], f1=g.feed&&g.feed[1];
         // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired and a raid line is a line of the left feed, so every feed line counts as shown.
         var FL=(g.fd&&g.fd.lines)||[]; for(var q=0;q<FL.length;q++) up.push(String(FL[q].txt));
         if(g.msg) up.push(String(g.msg)+(g.msgSub?' '+g.msgSub:''));
         if(g.msgT>0&&g.msg&&f1&&f1.T>0&&f1.m&&f1.m!==g.msg) up.push(String(f1.m)+(f1.sub?' '+f1.sub:''));
         for(var u=0;u<up.length;u++) if(seen.indexOf(up[u])<0) seen.push(up[u]); }
       note();
       for(i=0;i<300;i++){ __loop(t0+(i+1)*16.7); note(); }
       return {issued:!!(G2.player.wepIssued||G2.spawnGun), seen:seen};   // noloaner: a loaner on the old build, the free Scav Pistol (spawnGun) on the new
     }
     function hasN(m){ return String(m).toLowerCase().indexOf(needle.toLowerCase())>=0; }
     try{
       // ONE: nothing equipped, a pack gun in the stash. He lands with a loaner.
       var A=ascend('fists',['pistol'],['gun_smg','bandage']);
       if(A.none) return 'SKIP: '+A.none;
       if(!A.issued) return 'SKIP: staging: the quick ascent did not issue a loaner, so there is nothing to measure';
       var hitA=A.seen.filter(hasN);
       if(!hitA.length)
         bad.push('a player who takes the quick ascent with nothing equipped lands with a loaner and is never told his own gun waits in the stash [shown: '+A.seen.join(' | ').slice(0,200)+']');

       // TWO: nothing equipped, and no gun in the stash either.
       var B=ascend('fists',['pistol'],['bandage']);
       if(!B.none&&B.seen.some(hasN))
         bad.push('a player with no gun in his stash is told on landing to equip one from it');

       // THREE: a gun of his own equipped, another in the stash. No loaner, no line.
       var C=ascend('pistol',['pistol'],['gun_smg']);
       if(!C.none&&C.issued) bad.push('staging: a player with his own pistol equipped was issued a loaner');
       else if(!C.none&&C.seen.some(hasN))
         bad.push('a player who went up with his own gun is told he is carrying a loaner');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       endAny();
       try{ P2.equipped=keep.equipped; P2.equippedSec=keep.equippedSec; P2.weapons=keep.weapons; P2.stash=keep.stash; P2.kit=keep.kit; P2.freeKit=keep.freeKit; P2.hotAssign=keep.hot; saveProfile(); }catch(_r){}
       try{ var K2=__keys(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},

  {v:'13.33',what:'a line that must not be lost waits its turn: with a message showing, two more queued behind it are each shown when the one before runs out, in order and none written over, which is how the rival warning and the loaner line reach the player',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__loop&&window.__showScreen)) return 'SKIP: this fixture cannot start a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof startRaid!=='function'||typeof say!=='function') return 'SKIP: this build has no raid to start or no message line';
     var bad=[];
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       startRaid();
       var G2=__state(); if(!G2||G2.over||G2.sim) return 'SKIP: staging: no live raid started';
       var t0=performance.now(), f=0, i;
       // Let landing say what it says, so the queue starts empty.
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }
       // r1334b: nothing else may speak while the queue is measured. A live crier on
       // one seed kept the line busy past the stepping window.
       G2.ents.length=0;
       // r1334c: and no wave either. With nobody alive the spawner sends a man every
       // eight seconds with a line of its own; its clock is held back for the check.
       G2.waveT=-1e9;
       G2.msgQ=[]; G2.msgT=0; G2.fd={t:0,seq:0,lines:[]};
       var L1=['first','line','of','three'].join(' '), L2=['second','line','of','three'].join(' '), L3=['third','line','of','three'].join(' ');
       say(L1);
       if(typeof sayWhenFree==='function'){ sayWhenFree(L2); sayWhenFree(L3); }
       else { say(L2); say(L3); }   // v13.32 and earlier: the direct say the rival warning used
       var seen=[];
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): nothing waits behind the grey rows any more: each line is a line of the left feed, in the order said, none written over.
       var fdId={};
       function note(){ var g=__state(); if(g&&g.msg&&(seen.length===0||seen[seen.length-1]!==g.msg)) seen.push(String(g.msg));
         var FL=(g&&g.fd&&g.fd.lines)||[]; for(var q=0;q<FL.length;q++) if(!fdId[FL[q].id]){ fdId[FL[q].id]=1; seen.push(String(FL[q].txt)); } }
       function newest(){ var g=__state(), FL=(g&&g.fd&&g.fd.lines)||[]; return FL.length?String(FL[FL.length-1].txt):''; }
       note();
       for(i=0;i<720;i++){ __loop(t0+(++f)*16.7); note(); }
       var order=[L1,L2,L3].map(function(l){ return seen.indexOf(l); });
       if(order[0]<0) bad.push('the line shown first was never on screen');
       if(order[1]<0) bad.push('a second line said while the first was showing was written over and never shown [shown: '+seen.join(' | ').slice(0,200)+']');
       if(order[2]<0) bad.push('a third line queued behind the second was lost [shown: '+seen.join(' | ').slice(0,200)+']');
       if(order[0]>=0&&order[1]>=0&&order[2]>=0&&!(order[0]<order[1]&&order[1]<order[2]))
         bad.push('the queued lines were shown out of order ['+seen.join(' | ').slice(0,200)+']');
       // CONTROL: with nothing showing, sayWhenFree says at once rather than waiting.
       if(typeof sayWhenFree==='function'){
         G2.msgQ=[]; G2.msgT=0;
         var L4=['said','at','once'].join(' ');
         sayWhenFree(L4);
         if(__state().msg!==L4&&newest()!==L4) bad.push('control: with nothing showing, a line through the queue was held back instead of said at once');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       endAny();
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},

  {v:'13.38',what:'a real player round that kills the last pillager a kill contract needs shows the contract line and then the grudge line, in that order, so the grudge line no longer writes over the only in-raid word that the contract is done',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys)) return 'SKIP: this fixture cannot start a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof contractKill!=='function'||typeof idRec!=='function'||typeof rayHitG!=='function') return 'SKIP: this build has no kill contracts, no grudge ledger or no wall ray';
     var bad=[], keepC=P.contracts, keepNoto=P.notoriety, recId=null, keepRec=null, hadRec=false;
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var G2=__state(); if(!G2||G2.over||G2.sim||!G2.bullets||!G2.tel) return 'SKIP: staging: no live raid started';
       var p=G2.player, rd=null, i, k;
       for(i=0;i<G2.ents.length;i++){ var e0=G2.ents[i]; if(e0.kind==='raider'&&!e0.merc&&!e0.finished&&e0.ident&&e0.name){ rd=e0; break; } }
       if(!rd) return 'SKIP: staging: no named pillager on this map';
       // Nothing else may speak while the lines are read: no machines, no crier, and no wave (the v13.33 lessons).
       G2.ents.length=0; G2.waveT=-1e9; p.iv=99;
       var K=__keys(); for(k in K) delete K[k];
       try{ if(mouse) mouse.down=false; }catch(_m){}
       var t0=performance.now(), f=0;
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }   // landing says what it says first
       if(G2.over||__state()!==G2) return 'SKIP: staging: the raid ended while landing settled';
       // A clear line of fire from where he stands.
       var ux=null, uy=null;
       for(i=0;i<8;i++){ var a=i*Math.PI/4, cx=Math.cos(a), cy=Math.sin(a);
         if(rayHitG(p.x,p.y,cx,cy,60)>=59){ ux=cx; uy=cy; break; } }
       if(ux===null) return 'SKIP: staging: no clear 60 unit line of fire from the landing spot';
       // A kill contract one pillager short, with a description the game never rolls.
       recId=rd.ident; hadRec=!!(P.rivals&&P.rivals[recId]);
       keepRec=hadRec?JSON.parse(JSON.stringify(P.rivals[recId])):null;
       var kills0=idRec(recId).kills||0;
       var desc=['Destroy','2','pillagers','for','check','13','38'].join(' ');
       var C={type:'kill',tgt:'raider',n:2,prog:1,reward:520,desc:desc};
       P.contracts=[C];
       G2.tel.contractsMid=G2.tel.contractsMid||[];
       var mid0=G2.tel.contractsMid.length;
       // He lies downed at the player's feet, already hostile, so the round charges no notoriety and says nothing of its own.
       rd.x=p.x+ux*24; rd.y=p.y+uy*24;
       rd.downed=1; rd.downT=30; rd.hp=5; rd.state='down'; rd.finished=false;
       rd.hostile=true; rd.friendlyPC=0; rd.notoCharged=1; rd.roll=0; rd.rollCd=0; rd.byPlayer=false;
       G2.ents.push(rd);
       var nm=String(rd.name);
       G2.msgQ=[]; G2.msgT=0; G2.msg='';
       // YOUR round, in the shape the fire path pushes, so the kill flag is set where the game sets it.
       G2.bullets.push({x:p.x+ux*17,y:p.y+uy*17,vx:ux*1180,vy:uy*1180,dmg:500,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0});
       var seen=[];
       // v21.86 (raid text R04) gave the message line two rows: a line said while another shows moves the older one down to the
       // second row instead of writing over it. Every line on either row counts as shown, the older row first, with its detail.
       function rowTxt(m,s){ return String(m)+(s?' '+s:''); }
       function note(){ var g=__state(); if(!g) return; var up=[], f1=g.feed&&g.feed[1];
         // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired and a raid line is a line of the left feed, in the order said, so every feed line counts as shown.
         var FL=(g.fd&&g.fd.lines)||[]; for(var q=0;q<FL.length;q++) up.push(String(FL[q].txt));
         if(g.msgT>0&&g.msg&&f1&&f1.T>0&&f1.m&&f1.m!==g.msg) up.push(rowTxt(f1.m,f1.sub));
         if(g.msg) up.push(rowTxt(g.msg,g.msgSub));
         for(var u=0;u<up.length;u++) if(seen.indexOf(up[u])<0) seen.push(up[u]); }
       for(i=0;i<540;i++){ __loop(t0+(++f)*16.7); note(); if(__state()!==G2) break; }
       var head=['CONTRACT','DONE'].join(' ');
       var tail=['will','remember','that'].join(' ');
       var grudge=(nm+' '+tail).toUpperCase(), grudge2=(nm+' '+['wants','revenge'].join(' ')).toUpperCase();   // either voice: Name will remember that., NAME WILL REMEMBER THAT or (tr9fixl) NAME WANTS REVENGE
       var cIx=-1, rIx=-1;
       for(i=0;i<seen.length;i++){
         if(cIx<0&&seen[i].toUpperCase().indexOf(head)===0&&seen[i].indexOf(desc)>=0) cIx=i;
         if(rIx<0&&(seen[i].toUpperCase().indexOf(grudge)===0||seen[i].toUpperCase().indexOf(grudge2)===0)) rIx=i;
       }
       var shown=' [shown: '+seen.join(' | ').slice(0,240)+']';
       // CONTROLS: the round killed him, the kill was yours, the contract finished and the grudge was written, or the lines prove nothing.
       if(G2.ents.indexOf(rd)>=0) bad.push('control: the round did not kill the downed pillager (hp '+rd.hp+', downed '+rd.downed+')');
       if(C.prog!==C.n) bad.push('control: the kill did not finish the contract (progress '+C.prog+' of '+C.n+')');
       if(G2.tel.contractsMid.length!==mid0+1) bad.push('control: the finished contract was not recorded for the report');
       if((idRec(recId).kills||0)!==kills0+1) bad.push('control: the kill wrote no grudge, so the grudge line was never reached');
       // THE FIX.
       if(cIx<0) bad.push('the line that says the contract is done was written over in the same step and never shown'+shown);
       if(rIx<0) bad.push('the grudge line for '+nm+' was never shown'+shown);
       if(cIx>=0&&rIx>=0&&!(cIx<rIx)) bad.push('the grudge line was shown before the contract line'+shown);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       endAny();
       try{ var K2=__keys(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{
         P.contracts=keepC; P.notoriety=keepNoto;
         if(recId!==null&&P.rivals){ if(hadRec) P.rivals[recId]=keepRec; else delete P.rivals[recId]; }
       }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},

  {v:'13.39',what:'helping the survivor while carrying notoriety shows the line about the cache, the pay and the salvage he hands over, and the notoriety line follows it when that one runs out instead of writing over it in the same frame (2026-09-13 hunt)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__P&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__vpAlive)) return 'SKIP: this fixture cannot deploy, step the loop or read the profile';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof strayGive!=='function'||typeof mkStray!=='function'||typeof updatePlayer!=='function') return 'SKIP: this build has no survivor or no player update';
     if(!ITEMS.bandage) return 'SKIP: this build has no bandage to hand him';
     var bad=[], P2=__P(), noto0=P2.notoriety||0, cred0=P2.credits||0;
     // Assembled, never written whole: the pay clause and the notoriety line.
     var PAID=['He','pays','you'].join(' '), WORD=['Word','of','that'].join(' ');
     var endAny=function(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} };
     var show=function(s){ return s.join(' | ').slice(0,220); };
     try{
       keys={};
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||g.over||g.sim) return 'SKIP: staging: no live raid started';
       var t0=performance.now(), f=0, i;
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }   // landing says what it says first
       g=__state(); if(!g||g.over||g.sim) return 'SKIP: staging: the raid ended while landing settled';
       var p=g.player;
       // Nothing else may use the E press or the message line: no machines, no wave
       // (the r1334c lesson), no unopened crate in reach, and not inside a ring, where E calls the ship.
       g.ents.length=0; g.waveT=-1e9;
       for(i=0;i<g.zones.length;i++) if(dist(p,g.zones[i])<g.zones[i].r) return 'SKIP: staging: the player landed inside an extraction ring, where E calls the ship';
       for(i=0;i<g.containers.length;i++) if(!g.containers[i].opened&&dist(p,g.containers[i])<90) g.containers[i].opened=1;
       p.downed=false; p.roll=0;
       var e=mkStray(p.x+30,p.y); g.ents.push(e);
       e.want='bandage'; e.helped=0; e.hostile=false; e.downed=false;
       g.bag=['bandage'];
       P2.notoriety=2;
       g.msgQ=[]; g.msgT=0; g.msg=''; g.fd={t:0,seq:0,lines:[]};
       var seen=[], fdId={};
       // tr18fix: since the raid text rewrite (R18) what he pays is a +$ row in the pickup stack tagged FROM THE SURVIVOR, where no
       // line can write over it, instead of the He pays you sentence; either one shown counts, on the build before and after.
       var pickPaid=false;
       var note=function(){ var g1=__state(); if(g1&&g1.msg&&(seen.length===0||seen[seen.length-1]!==g1.msg)) seen.push(String(g1.msg));
         // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired and a raid line is a line of the left feed, in the order said, so every new feed line counts as shown.
         var FL=(g1&&g1.fd&&g1.fd.lines)||[]; for(var q0=0;q0<FL.length;q0++) if(!fdId[FL[q0].id]){ fdId[FL[q0].id]=1; seen.push(String(FL[q0].txt)); }
         if(g1&&g1.pick) for(var q=0;q<g1.pick.length;q++) if(String(g1.pick[q].m).charAt(0)==='+'&&/SURVIVOR/.test(String(g1.pick[q].tag||''))) pickPaid=true; };
       // THE PLAYER PATH: E held through one player update beside him, the same
       // test the key handler feeds (updatePlayer, the stray scan and strayLock).
       g.strayLock=0; keys['KeyE']=true;
       updatePlayer(0.016);
       keys={};
       note();
       if(!e.helped) bad.push('control: the E press beside the survivor did not help him (bag '+g.bag.join(',')+')');
       if((P2.notoriety||0)!==1) bad.push('control: helping the survivor at notoriety 2 left it at '+(P2.notoriety||0));
       g.ents.length=0;   // he walks out, and nothing of his may speak during the measurement
       for(i=0;i<600;i++){
         var gs=__state(); if(!gs||gs.over) break;
         __loop(t0+(++f)*16.7); note();
       }
       var at=function(nn){ for(var k=0;k<seen.length;k++) if(seen[k].indexOf(nn)>=0) return k; return -1; };
       var a=at(PAID), b=(at(WORD)>=0)?at(WORD):at('NOTORIETY '+'DOWN');
       if(e.helped&&a<0&&!pickPaid) bad.push('the line saying the survivor paid him and what he handed over was written over in the same frame and never shown [shown: '+show(seen)+']');
       if(e.helped&&b<0) bad.push('the notoriety line was never shown [shown: '+show(seen)+']');
       if(a>=0&&b>=0&&!(a<b)) bad.push('the notoriety line was shown before the line about the pay [shown: '+show(seen)+']');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       endAny();
       try{ var P3=__P(); P3.notoriety=noto0; P3.credits=cred0; }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},

  {v:'13.40',what:'a box searched on the hot ground says so: after a held X search through the frame loop, the hot ground bonus line is shown after the Found line instead of being written over by it in the same call, and a box off the hot ground never says it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__vpAlive)) return 'SKIP: this fixture cannot deploy a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof updatePlayer!=='function'||typeof openContainer!=='function'||typeof spotFree!=='function'||typeof losClear!=='function') return 'SKIP: this build has no search path to drive';
     var bad=[], g=null, keepZone=null, keepProg=[], t0=performance.now(), f=0, i;
     // Assembled, never written whole: the fixture is part of the page.
     var HOT=['Hot','ground.'].join(' '), FOUND=['Found',' '].join(':');
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; g0.searching=null; __endRaid('abandon'); } }catch(_0){} }
     // What the HUD draws: G.msg while G.msgT is above zero, read after each whole frame.
     function note(seen){ var gg=__state(); if(seen&&gg&&gg.msg&&gg.msgT>0&&(seen.length===0||seen[seen.length-1]!==String(gg.msg))) seen.push(String(gg.msg));
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired and a raid line is a line of the left feed, so each new feed line counts as shown (seen.fd: ids read).
       if(seen&&gg){ seen.fd=seen.fd||{}; var FL=(gg.fd&&gg.fd.lines)||[]; for(var q2=0;q2<FL.length;q2++) if(!seen.fd[FL[q2].id]){ seen.fd[FL[q2].id]=1; seen.push(String(FL[q2].txt)); } }
       // tr16fix: since the raid text rewrite (R16) the items taken are rows in the pickup stack (G.pick), not a Found line; they are
       // kept apart in seen.pk so the hot ground line is still read from the message line, on the build before and after.
       if(seen&&gg&&gg.pick&&gg.pick.length){ seen.pk=seen.pk||[]; for(var q=0;q<gg.pick.length;q++) if(seen.pk.indexOf(String(gg.pick[q].m))<0) seen.pk.push(String(gg.pick[q].m)); } }
     function step(nn,seen){ for(var s=0;s<nn;s++){ __loop(t0+(++f)*16.7); note(seen); if(__state()!==g||g.over) return false; } return true; }
     // An ordinary box, shortest search first, with a spot beside it that is clear of every
     // wall, in clear sight of the box, and nearer to it than to any other unopened box.
     // He is placed there, never walked, so the frame collides him with nothing.
     function pick(skip){
       var best=null, segs=g.vseg||g.map.segs;
       for(var c=0;c<g.containers.length;c++){
         var ct=g.containers[c];
         if(!ct||ct===skip||ct.opened||ct.cache||ct.strong||ct.mercSrc||ct.auto||ct.dropped||(ct.prog||0)>0) continue;
         if(!(ct.time>0)||!ct.loot||ct.loot.length<1) continue;
         if(ct.type!=='crate'&&ct.type!=='locker'&&ct.type!=='safe') continue;
         if(best&&ct.time>=best.ct.time) continue;
         var spot=null;
         for(var rad=20;rad<=36&&!spot;rad+=8){
           for(var a=0;a<16&&!spot;a++){
             var sx=ct.x+Math.cos(a*Math.PI/8)*rad, sy=ct.y+Math.sin(a*Math.PI/8)*rad;
             if(!spotFree(g.map,sx,sy,16)||!losClear(sx,sy,ct.x,ct.y,segs)) continue;
             var rival=false;
             for(var o=0;o<g.containers.length&&!rival;o++){ var c2=g.containers[o]; if(c2&&c2!==ct&&!c2.opened&&Math.hypot(c2.x-sx,c2.y-sy)<=rad+1) rival=true; }
             if(!rival) spot={x:sx,y:sy};
           }
         }
         if(spot) best={ct:ct,spot:spot};
       }
       return best;
     }
     // The real search: X held through the frame loop, staged pulls and all, until the box opens.
     function drive(ct,spot,seen){
       var p=g.player;
       p.x=spot.x; p.y=spot.y; p.downed=false;
       g.msgQ=[]; g.msgT=0;
       seen.fd={}; var FL0=(g.fd&&g.fd.lines)||[]; for(var q3=0;q3<FL0.length;q3++) seen.fd[FL0[q3].id]=1;   // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): a feed line from before this search is not this search's
       keys={}; keys[__srchKey()]=true;
       for(var s=0;s<1500&&!ct.opened;s++){
         __loop(t0+(++f)*16.7); note(seen);
         if(__state()!==g||g.over) break;
       }
       keys={};
       return !!ct.opened;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||g.over||g.sim) return 'SKIP: staging: no live raid started';
       if(!g.hotZone) return 'SKIP: this raid has no hot ground to search on';
       keepZone={x:g.hotZone.x,y:g.hotZone.y,at:g.hotZone.at};
       for(i=0;i<(P.contracts||[]).length;i++) keepProg.push({c:P.contracts[i],prog:P.contracts[i].prog});
       // Let landing say what it says, so the lines read below come from the search itself.
       if(!step(420,null)) return 'SKIP: staging: the raid ended while landing settled';
       // Nothing else may speak while they are read (13.33, r1334b and r1334c): no machines,
       // no wave, no clock warning, and the hot ground holds still.
       g.ents.length=0; g.waveT=-1e9; g.hotZone.at=0;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       g.bag.length=0;
       // ARM ONE: a box on the hot ground.
       var A=pick(null);
       if(!A) return 'SKIP: no ordinary box on this seed has a clear spot beside it to search from';
       g.hotZone.x=A.ct.x; g.hotZone.y=A.ct.y;
       var seenA=[];
       if(!drive(A.ct,A.spot,seenA)) bad.push('control: holding X beside the '+A.ct.type+' for 25 seconds never finished the search (prog '+(+(A.ct.prog||0)).toFixed(2)+' of '+A.ct.time+')');
       else {
         if(!A.ct.hotPaid) bad.push('control: the box on the hot ground was not paid the bonus, so this arm measured nothing');
         step(900,seenA);
         var hotN=0, foundN=0;
         for(i=0;i<seenA.length;i++){ if(seenA[i].indexOf(HOT)===0||seenA[i].indexOf('HOT '+'GROUND')===0) hotN++; if(seenA[i].indexOf(FOUND)>=0) foundN++; }
         var shownA=seenA.join(' | ').slice(-240);
         if(!foundN&&!(seenA.pk&&seenA.pk.length)) bad.push('control: the Found line (or since R16 a pickup row) never showed after the search [shown: '+shownA+']');
         if(!hotN) bad.push('the hot ground bonus line was never on screen; the Found line wrote over it in the same call [shown: '+shownA+']');
         if(hotN>1) bad.push('the hot ground bonus line was shown '+hotN+' times for one box [shown: '+shownA+']');
       }
       // ARM TWO, the control: a box off the hot ground never says it.
       keys={}; g.bag.length=0; g.msgQ=[]; g.msgT=0;
       var B=pick(A.ct);
       if(!B) bad.push('control: no second box with a clear spot, so the off-ground arm could not run');
       else {
         g.hotZone.x=(B.ct.x<WORLD_W/2)?WORLD_W-1:1; g.hotZone.y=(B.ct.y<WORLD_H/2)?WORLD_H-1:1; g.hotZone.at=0;
         if(Math.hypot(B.ct.x-g.hotZone.x,B.ct.y-g.hotZone.y)<=g.hotZone.r) bad.push('control: the hot ground could not be moved off the second box');
         else {
           var seenB=[];
           if(!drive(B.ct,B.spot,seenB)) bad.push('control: the off-ground search never finished');
           else {
             step(300,seenB);
             var shownB=seenB.join(' | ').slice(-240);
             if(B.ct.hotPaid) bad.push('a box off the hot ground was paid the hot ground bonus');
             if(seenB.some(function(t){ return t.indexOf(HOT)===0; })) bad.push('a box off the hot ground said the hot ground line [shown: '+shownB+']');
             if(!seenB.length&&!(seenB.pk&&seenB.pk.length)) bad.push('control: nothing showed on the message line or (since R16) in the pickup stack during the off-ground search, so it was not being read');
           }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       keys={};
       try{ if(g&&g.hotZone&&keepZone){ g.hotZone.x=keepZone.x; g.hotZone.y=keepZone.y; g.hotZone.at=keepZone.at; } }catch(_z){}
       endAny();
       for(i=0;i<keepProg.length;i++){ try{ keepProg[i].c.prog=keepProg[i].prog; }catch(_p){} }
       try{ saveProfile(); }catch(_s){}
       try{ __topClear(); }catch(_c){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},

  {v:'20.55',what:'the top centre stacks: with a message up, THE OVERSEER near and seen, a trade offer open and the controller paused word showing, the message plate, the boss bar, the offer line and the controller word each keep a band of their own, at 1080p and at 4K',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawBossBar!=='function'||typeof drawGiftLine!=='function'||typeof netPadHud!=='function'||typeof netPadDead!=='function'||typeof BOSS_NAME==='undefined'||typeof ctx.getTransform!=='function') return 'SKIP: no boss bar, offer line or controller word here';
     var bad=[], g, p, i, e=null, oFR=ctx.fillRect, oFT=ctx.fillText, oRR=ctx.roundRect, oPD=netPadDead, oSay=say, rec=[], MSG='ZQX PROBE LINE THIRTY EIGHT', CP=['CONTROLLER','PAUSED'].join(' '), SZ=[[1920,1080],[3840,2160]], si, forced=false, at, nm, M, B, O, C;
     function wrap(){
       ctx.fillRect=function(x,y,w,h){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, a=(m.b*x+m.d*y+m.f)/d, b=(m.b*x+m.d*(y+h)+m.f)/d; rec.push({r:1,fs:String(ctx.fillStyle),y0:Math.min(a,b),y1:Math.max(a,b)}); return oFR.apply(this,arguments); };
       ctx.fillText=function(s){ rec.push({t:String(s)}); return oFT.apply(this,arguments); };
       // v21.82 retarget (the raid text R03): the message plate is a rounded plate now (hudPlate), so a roundRect is a plate too,
       // recorded as r:2. Only the message band reads it; the boss, offer and controller bands read the fillRect plates as before.
       if(oRR) ctx.roundRect=function(x,y,w,h){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, a=(m.b*x+m.d*y+m.f)/d, b=(m.b*x+m.d*(y+h)+m.f)/d; rec.push({r:2,fs:String(ctx.fillStyle),y0:Math.min(a,b),y1:Math.max(a,b)}); return oRR.apply(this,arguments); };
     }
     function unwrap(){ delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; delete ctx.roundRect; if(oRR&&ctx.roundRect!==oRR) ctx.roundRect=oRR; }
     // the plate of a line: the n rectangles painted just before its text, as one band
     function band(test,n,rnd){
       var j, q, got=0, o=null;
       for(j=rec.length-1;j>=0;j--) if(rec[j].t!==undefined&&test(rec[j].t)) break;
       if(j<0) return null;
       for(q=j-1;q>=0&&got<n;q--) if(rec[q].r===1||(rnd&&rec[q].r===2)){ got++; if(!o) o={y0:rec[q].y0,y1:rec[q].y1}; else { o.y0=Math.min(o.y0,rec[q].y0); o.y1=Math.max(o.y1,rec[q].y1); } }
       return got===n?o:null;
     }
     // the boss plate: the rectangle painted just before the dark red of the bar, with the bar
     function bossBand(){ var j, qq, R1=rec.filter(function(q){ return q.r!==2; }); for(j=1;j<R1.length;j++) if(R1[j].r&&R1[j].fs==='#3a0d0d'&&R1[j-1].r) return {y0:Math.min(R1[j-1].y0,R1[j].y0),y1:Math.max(R1[j-1].y1,R1[j].y1)};
       // v27.xx (boss1) retarget: the boss plate is a HUD roundRect plate now (and its rail), then the track (a 12 percent white rect) and the fill in the danger colour
       for(j=1;j<rec.length-1;j++) if(rec[j].r===1&&rec[j].fs==='rgba(255, 255, 255, 0.12)'&&rec[j+1].r===1&&rec[j+1].fs==='#e5482f'){ qq=j-1; while(qq>0&&rec[qq].r!==2&&j-qq<4) qq--; if(rec[qq].r===2) return {y0:Math.min(rec[qq].y0,rec[j].y0),y1:Math.max(rec[qq].y1,rec[j].y1)}; }
       return null; }
     function hit(a,b){ return a.y0<b.y1-0.5&&b.y0<a.y1-0.5; }
     function rd(a){ return Math.round(a.y0)+' to '+Math.round(a.y1); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false;
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].name===BOSS_NAME&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e&&typeof bossTick==='function'){ g.t=Math.max(g.t||0,2.5); try{ e=bossTick(true); }catch(_bt){ e=null; } }
       if(!e) return 'SKIP: no Overseer in this raid';
       e.x=p.x+150; e.y=p.y; g.bossRef=e; e.barSeen=1;   // seen: this check is about the layout, not when the bar first shows
       nm=String(e.name);
       netPadDead=function(){ return true; };
       say=function(){};   // nothing replaces the probe message mid-frame
       for(si=0;si<SZ.length;si++){
         if(window.__forceSize){ __forceSize(SZ[si][0],SZ[si][1]); forced=true; } else if(si) break;
         at=W+'x'+H;
         g.msg=MSG; g.msgT=3; g.msgSub=''; g.msgK='info'; g.giftOut=null; g.giftIn={id:'zq38',k:'bandage',from:1,t:g.t};
         rec=[]; wrap();
         try{ __frame(0.016); netPadHud(); } finally { unwrap(); }
         M=band(function(s){ return s===MSG; },1,true);
         B=bossBand();
         O=band(function(s){ return s.indexOf(' offers you ')>=0||s.indexOf(' OFFERS ')>=0; },1);
         C=band(function(s){ return s.indexOf(CP)===0; },1);
         var noMsg=(typeof MSGROWS!=='undefined'&&!MSGROWS)||(typeof feedRows==='function'&&!feedRows().length);   // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired, so no message plate draws in the top centre
           // v27.xx (feed3) retarget: the top rows are lines of the feed, so there is no message plate to keep a band
         if((!M&&!noMsg)||!B||!O||!C){ bad.push('control at '+at+': not all four were drawn (message '+!!M+', boss bar '+!!B+', offer '+!!O+', controller word '+!!C+')'); continue; }
         if(M&&hit(M,B)) bad.push('at '+at+' the message plate ('+rd(M)+') covers the boss bar ('+rd(B)+')');
         if(hit(O,C)) bad.push('at '+at+' the offer line ('+rd(O)+') and the controller word ('+rd(C)+') print on top of each other');
         if(hit(B,O)) bad.push('at '+at+' the boss bar ('+rd(B)+') and the offer line ('+rd(O)+') overlap');
         if(hit(B,C)) bad.push('at '+at+' the boss bar ('+rd(B)+') and the controller word ('+rd(C)+') overlap');
         if(M&&hit(M,O)) bad.push('at '+at+' the message plate ('+rd(M)+') and the offer line ('+rd(O)+') overlap');
         if(M&&hit(M,C)) bad.push('at '+at+' the message plate ('+rd(M)+') and the controller word ('+rd(C)+') overlap');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unwrap(); netPadDead=oPD; say=oSay; keys={};
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.msgT=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},

  {v:'21.80',what:'the raid text module: the fixture runs the real say(), and say() carries a kind into the run log and the feed, and a line sent to wait is said at once (v35.30 retarget: the grey rows and their waiting queue are retired)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__loop) return 'SKIP: no raid here';
     var bad=[], g, i, lg, hit;
     var hit2=function(){ var L2=__msgLog(); for(var j=0;j<L2.length;j++) if(L2[j].m==='zq q') return L2[j]; return null; };
     var newest=function(){ var L=(g&&g.fd&&g.fd.lines)||[]; return L.length?String(L[L.length-1].txt):''; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       // R00, the harness: the fixture wraps the game say() instead of copying its body.
       if(typeof window.__sayReal!=='function') bad.push('the fixture keeps no handle on the real say()');
       else if(say===window.__sayReal) bad.push('say() is not wrapped, so __lastSay never moves');
       if(String(say).indexOf('G.msg'+'T=3.2')>=0) bad.push('the fixture say() is still a copy of the old body');
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired, so a line said is read from the run log
       // (G.msgLog, the kind as say() read it) and the left feed (G.fd), not from G.msg and its clock.
       g.msgQ=[]; g.msgT=0; g.fd={t:0,seq:0,lines:[]};
       __say('zq'+'wrap');
       lg=__msgLog(); hit=lg[lg.length-1];
       if(!hit||hit.m!=='zqwrap'||window.__lastSay!=='zqwrap') bad.push('__say did not reach the game (log '+(hit&&hit.m)+', last '+window.__lastSay+')');
       // R01, the kinds.
       say('zq kind','obj',{sub:'zq detail.'});
       lg=__msgLog(); hit=lg[lg.length-1];
       if(!hit||hit.m!=='zq kind'||hit.k!=='obj') bad.push('the log does not end with the obj line');
       else if(hit.sub!=='zq detail.') bad.push('the detail is not kept in the log');
       if(newest().indexOf('zq kind')!==0||newest().indexOf('zq detail.')<0) bad.push('say(m,obj) with a detail is not the newest feed line with its detail (it reads '+JSON.stringify(newest())+')');
       say('zq plain');
       lg=__msgLog(); if(lg[lg.length-1].k!=='info') bad.push('a one-string say is kind '+lg[lg.length-1].k+', not info');
       say('zq odd','nonsense');
       lg=__msgLog(); if(lg[lg.length-1].k!=='info') bad.push('an unknown kind is not read as info');
       for(i=0;i<20;i++) say('zq ring '+i,'chat');
       if(__msgLog().length!==16) bad.push('the log is not a ring of 16 (it holds '+__msgLog().length+')');
       g.sim=true; say('zq sim','crit'); g.sim=false;
       if(__msgLog()[15].m==='zq sim'||newest()==='zq sim'||(g.alert&&g.alert.m==='zq sim')) bad.push('say() acts while G.sim is set');
       // Nothing waits: a line sent to wait while others show is said at once, with its kind, and the queue stays empty.
       g.msgQ=[]; g.msgQM=[]; g.msgT=0; g.msg=''; g.feed=[]; say('zq showing a','obj'); say('zq showing b','obj'); sayWhenFree('zq q','obj');
       if(!hit2()) bad.push('a line sent to wait was not said at once');
       else if(hit2().k!=='obj') bad.push('the line sent to wait was said as kind '+hit2().k+', not obj');
       if(newest()!=='zq q') bad.push('the line sent to wait is not the newest feed line (it reads '+JSON.stringify(newest())+')');
       if((g.msgQ||[]).length) bad.push('a line still waits in the queue ('+JSON.stringify(g.msgQ)+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2){ g2.sim=false; g2.msgQ=[]; g2.msgQM=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},

  {v:'21.87',what:'no message line runs off the screen: a 260 character line wraps at a word into at most two lines that lie inside the screen at 1080p and at 4K, and its full text goes into the run report',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof ctx.getTransform!=='function') return 'SKIP: no getTransform here';
     var bad=[], ev=[], g, realSay=say, oFT=ctx.fillText, SZ=[[1920,1080],[3840,2160]], si, forced=false, at, i, ws=[], LONG, pc, j, t;
     for(i=0;i<60;i++) ws.push('zqx'+i);
     LONG=ws.join(' ').slice(0,260).replace(/\s+\S*$/,'');
     if(LONG.length<240) return 'SKIP: the probe line came out short';
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function spy(){ ev=[]; ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, w=ctx.measureText(String(s)).width, cx=(m.a*x+m.c*y+m.e)/d, al=String(ctx.textAlign), hw=w*Math.abs(m.a)/d, x0=al==='center'?cx-hw/2:(al==='right'||al==='end')?cx-hw:cx; ev.push({t:String(s),x0:x0,x1:x0+hw}); return oFT.apply(this,arguments); }; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false;
       for(si=0;si<SZ.length;si++){
         if(window.__forceSize){ __forceSize(SZ[si][0],SZ[si][1]); forced=true; } else if(si) break;
         at=W+'x'+H;
         g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[];
         say=realSay; say(LONG);
         say=function(){};   // nothing else is said mid-frame
         spy();
         try{ __frame(0.016); } finally { unspy(); }
         pc=[];
         // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired: the long line is a line of the left feed, cut with an end mark inside the screen, and its whole text is in the run log.
         for(j=0;j<ev.length;j++){ t=ev[j].t.replace(/(\u2026|\.\.\.)$/,''); if(t.length>=8&&LONG.indexOf(t)>=0) pc.push(ev[j]); }
         if(!pc.length){ bad.push('at '+at+' the long line was not drawn'); continue; }
         if(pc.length>2) bad.push('at '+at+' the long line was drawn in '+pc.length+' pieces, more than two');
         for(j=0;j<pc.length;j++) if(pc[j].x0<-0.5||pc[j].x1>W+0.5) bad.push('at '+at+' a piece of the long line runs from x '+Math.round(pc[j].x0)+' to '+Math.round(pc[j].x1)+', off a screen '+W+' wide');
         if(!(g.tel&&g.tel.longLines&&g.tel.longLines.indexOf(LONG)>=0)&&!(g.msgLog||[]).some(function(r){ return r.m===LONG; })) bad.push('at '+at+' the full long line is not in the run report (G.tel.longLines) or the run log (G.msgLog)');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; keys={};
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},

  {v:'21.91',what:'nothing waits behind the feed (v35.30 retarget, his order 2026-10-27, the quiet hud: the grey rows and their waiting queue are retired): a line sent to wait is a line of the left feed at once, the same line twice is one feed line, an objective is not held behind ordinary lines, a keyed line said again with new words refreshes its one feed line, and a full backpack said every frame of a search fills one row',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof feedSay!=='function'||typeof bagWeight!=='function') return 'SKIP: no feed or no backpack weight here';
     var bad=[], g, p, realSay=say, keepBW=bagWeight, keepAuto=P.autoloot, BF=['Backpack','full'].join(' '), t0, f=0, i, n, L, box=null, firstQ=-1, maxBF=0;
     function clr(){ g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey=''; g.fd={t:0,seq:0,lines:[]}; }
     function inF(s){ var F=(g.fd&&g.fd.lines)||[], c=0; for(var j=0;j<F.length;j++) if(String(F[j].txt)===s) c++; return c; }
     function step(){ __loop(t0+(++f)*16.7); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9;
       // only the probe lines and the backpack line may speak
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('ZQ')===0||s.toUpperCase().indexOf(BF.toUpperCase())===0) return realSay.apply(this,arguments); };
       t0=performance.now();
       // ONE: no copies, and nothing waits
       clr(); say('ZQ W1','obj'); say('ZQ W2','obj');
       sayWhenFree('zq dup'); sayWhenFree('zq dup');
       if(inF('zq dup')!==1) bad.push('the same line sent to wait twice is '+inF('zq dup')+' lines of the left feed, not one');
       if((g.msgQ||[]).length) bad.push('a line still waits in the queue ('+g.msgQ.length+')');
       // TWO: an objective sent to wait behind ordinary lines is a feed line at once
       clr(); say('zq p1'); say('zq p2'); sayWhenFree('ZQ BIG','obj');
       if(inF('ZQ BIG')!==1) bad.push('an objective sent to wait behind two ordinary lines is not a line of the left feed at once');
       // THREE: a keyed line said again with new words (past the one second a repeat only refreshes) is one feed line with the new words
       clr(); say('zq k 1','info',{key:'zqk'}); g.fd.t+=1.5; say('zq k 2','info',{key:'zqk'});
       L=g.fd.lines; n=0; for(i=0;i<L.length;i++) if(String(L[i].txt).indexOf('zq k ')===0) n++;
       if(n!==1||inF('zq k 2')!==1) bad.push('a keyed line said twice fills '+n+' feed lines ('+JSON.stringify(L.map(function(l){ return l.txt; }))+')');
       // FOUR, THE PLAY PATH: X held on a box with the backpack full while a line is sent to wait
       for(i=0;i<g.containers.length;i++){ var c=g.containers[i]; if(c&&!c.opened&&c.loot&&c.loot.length&&!c.cache&&!c.strong&&!c.auto){ box=c; break; } }
       if(!box) bad.push('SKIP: no box to stage the full backpack on');
       else {
         box.x=p.x+20; box.y=p.y; box.opened=false; box.prog=0; p.downed=false;
         P.autoloot=0; bagWeight=function(){ return 1e9; };
         clr(); say('zq s1'); say('zq s2'); sayWhenFree('zq q');
         if(inF('zq q')===1) firstQ=0;
         keys[__srchKey()]=true;
         for(i=0;i<360;i++){
           step(); if(g.over) break;
           L=(g.fd&&g.fd.lines)||[]; n=0;
           for(var r=0;r<L.length;r++) if(String(L[r].txt).toUpperCase().indexOf(BF.toUpperCase())===0) n++;
           for(var r2=0;r2<(g.pick||[]).length;r2++) if(String(g.pick[r2].m).toUpperCase().indexOf(BF.toUpperCase())===0) n++;
           if(n>maxBF) maxBF=n;
         }
         keys={};
         if(maxBF<1) bad.push('SKIP: the full backpack line was never said, so the play path was not staged');
         if(maxBF>1) bad.push('the backpack full line said every frame filled '+maxBF+' rows');
         if(firstQ<0) bad.push('a line sent to wait while two lines show is not a line of the left feed at once');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; keys={}; bagWeight=keepBW; P.autoloot=keepAuto;
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgKey=''; } if(g2&&!g2.over){ g2.player.downed=false; g2.searching=null; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},

  {v:'21.94',what:'a raid line with a detail shows it on its line of the left feed as HEADLINE, a middle dot, then the detail, and a line with no detail is drawn as before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], ev=[], g, realSay=say, H1=['ZQ','HEAD'].join(' '), D1=['zq','detail'].join(' '), PL=['zq','plain'].join(' '), want=H1+'  \u00b7  '+D1, oFT=ctx.fillText, j, got=false, gotPl=false, gotBare=false;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function spy(){ ev=[]; ctx.fillText=function(t){ ev.push(String(t)); return oFT.apply(this,arguments); }; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false; g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[];
       realSay(PL); realSay(H1,'info',{sub:D1});
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired: the line is a line of the left feed, its words the headline, a middle dot and the detail, drawn as two pieces.
       var FL=(g.fd&&g.fd.lines)||[], ln=FL.length?FL[FL.length-1]:null;
       if(g.msg!==H1&&!(ln&&ln.txt===want)) bad.push('the newest feed line reads '+JSON.stringify(ln&&ln.txt)+', not '+JSON.stringify(want));
       say=function(){};
       spy();
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++){ if(ev[j]===want||(ev[j]===H1&&ev.indexOf('  \u00b7  '+D1)>=0)) got=true; if(ev[j]===H1) gotBare=true; if(ev[j]===PL) gotPl=true; }
       if(!got) bad.push('the line with a detail was not drawn as '+JSON.stringify(want)+(gotBare?' (only the headline was drawn)':''));
       if(!gotPl) bad.push('the line with no detail was not drawn exactly as said');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ unspy(); say=realSay; keys={}; try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},

  {v:'22.13',what:'the alert lane: the Crier line is an alert headline on the danger plate at a steady alpha, the flashing marked row is gone, and an ordinary line said under it goes to the feed and does not displace it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof mkSnitch!=='function'||typeof hudPlate!=='function') return 'SKIP: no Crier or no plate here';
     var bad=[], g, p, cr, i, j, t0, f=0, realSay=say, oFT=ctx.fillText, oPl=hudPlate, ev=[], pl=[], KW='KNOW WHERE YOU '+'ARE', RV='CRIER '+'REVEALED', LOOT=['zq','loot'].join(' '),
         head='', alphas=[], dangerN=0, kw=false, after=null, lootSeen=false, DP=String(HUDC.dangerPlate||'');
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; hudPlate=oPl; }
     function draw(){
       ev=[]; pl=[];
       ctx.fillText=function(t){ ev.push({t:String(t),a:ctx.globalAlpha}); return oFT.apply(this,arguments); };
       hudPlate=function(x,y,w,h,ac,fill){ pl.push(String(fill||'')); return oPl.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(var k=0;k<ev.length;k++) if(ev[k].t.indexOf(KW)>=0) kw=true;
     }
     function rv(){ for(var k=0;k<ev.length;k++) if(ev[k].t.indexOf(RV)===0) return ev[k]; return null; }
     function step(){ __loop(t0+(++f)*50); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9; p.iv=99;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.marked=0;
       // only the Crier lines and the probe line may speak
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('CRIER')===0||s.indexOf('A CRIER')===0) return realSay.apply(this,arguments); };
       cr=mkSnitch(p.x+240,p.y); cr.state='alarm'; cr.wind=0.01; cr.lost=0; cr.markX=p.x; cr.markY=p.y; g.ents.push(cr);
       __ents(0.05);
       g.ents.length=0;   // the Crier and the machines it called are gone, so nothing else speaks
       if(!(g.marked>0)) return 'SKIP: staging: the Crier did not fire its mark';
       t0=Math.max(performance.now(),(typeof lastTs==="number"&&isFinite(lastTs))?lastTs:0);   // never behind the frame clock a check before left
       for(i=0;i<4;i++){ step(); if(g.over) break; }   // past the fade in
       for(i=0;i<4&&!g.over;i++){
         step(); draw();
         var e=rv();
         if(!e){ bad.push('frame '+i+': no Crier headline was drawn'); continue; }
         head=e.t; alphas.push(Math.round(e.a*1000)/1000);
         for(j=0;j<pl.length;j++) if(pl[j]&&pl[j]===DP){ dangerN++; break; }
       }
       if(head&&!/^CRIER REVEALED YOUR (LAST )?LOCATION$/.test(head)) bad.push('the Crier headline reads '+JSON.stringify(head));
       for(i=1;i<alphas.length;i++) if(Math.abs(alphas[i]-alphas[0])>0.001){ bad.push('the Crier line flickers: its alpha over four frames 0.05 s apart is '+alphas.join(', ')); break; }
       if(alphas.length&&alphas[0]<0.99) bad.push('the Crier line is drawn at alpha '+alphas[0]+', not full');
       if(dangerN<4) bad.push('the Crier line sat on the danger plate in '+dangerN+' of 4 frames');
       if(kw) bad.push('a drawn line still says '+KW);
       if(!(g.alert&&g.alert.k==='warn'&&String(g.alert.m).indexOf(RV)===0)) bad.push('the alert lane does not hold the Crier line as a warning ('+JSON.stringify(g.alert&&{m:g.alert.m,k:g.alert.k})+')');
       // an ordinary line said under it goes to the feed and the alert stays
       say(LOOT);
       step(); step(); draw();
       after=rv();
       for(j=0;j<ev.length;j++) if(ev[j].t===LOOT) lootSeen=true;
       if(!after) bad.push('an ordinary line said 0.4 s after the Crier line took it off the screen');
       else if(after.a<0.99) bad.push('an ordinary line said under the Crier line dimmed it to alpha '+after.a);
       if(!lootSeen) bad.push('the ordinary line said under the alert was not drawn');
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the ordinary line is a line of the left feed and the alert is the top banner only, not a feed line as well.
       var FL=(g.fd&&g.fd.lines)||[], inF=false, rvF=false; for(j=0;j<FL.length;j++){ if(FL[j].txt===LOOT) inF=true; if(String(FL[j].txt).indexOf(RV)===0) rvF=true; }
       if(g.msg!==LOOT&&!inF) bad.push('the ordinary line is not a line of the left feed');
       if(rvF) bad.push('the Crier alert is drawn twice: the top banner and again a line of the left feed');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; keys={};
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.marked=0; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},

  {v:'22.32',what:'threats are alert headlines in the shooter voice: a Pillbox that sees him says THE PILLBOX HAS SEEN YOU as the alert, in the callout size on the danger plate with no end stop, while a line said in the same frame goes to the feed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof mkChoir!=='function'||typeof hudPlate!=='function') return 'SKIP: no Pillbox or no plate here';
     var bad=[], g, p, c, i, j, t0, f=0, realSay=say, oFT=ctx.fillText, oPl=hudPlate, ev=[], pl=[], PB=['THE','PILLBOX','HAS','SEEN','YOU'].join(' '), LOOT=['zq','loot'].join(' '),
         hit=null, loot=false, said=[], DP=String(HUDC.dangerPlate||''), HF=FS(TYPE.title), dang=false;   /* retarget v22.32: the alert lane headline is the title size (alert3, v27.50) */
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; hudPlate=oPl; }
     function fpx(s){ var m=(/([\d.]+)px/).exec(String(s)); return m?parseFloat(m[1]):0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9; p.iv=99;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[];
       say=function(m){ var s=String(m); said.push(s); if(s.indexOf('zq')===0||s.indexOf('THE PILLBOX')===0) return realSay.apply(this,arguments); };
       c=mkChoir(p.x+60,p.y); c.sang=0; g.ents.push(c);
       __ents(0.05);
       g.ents.length=0;   // nothing else speaks or shoots
       say(LOOT);         // in the same frame
       if(!said.some(function(s){ return s.indexOf('THE PILLBOX')===0; })) return 'SKIP: staging: the Pillbox said nothing (said: '+said.join(' | ').slice(0,120)+')';
       t0=Math.max(performance.now(),(typeof lastTs==="number"&&isFinite(lastTs))?lastTs:0);   // never behind the frame clock a check before left
       for(i=0;i<4;i++){ __loop(t0+(++f)*50); if(g.over) break; }   // past the fade in
       ev=[]; pl=[];
       ctx.fillText=function(t){ ev.push({t:String(t),font:String(ctx.font)}); return oFT.apply(this,arguments); };
       hudPlate=function(x,y,w,h,ac,fill){ pl.push(String(fill||'')); return oPl.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++){ if(ev[j].t.indexOf('THE PILLBOX')===0&&!hit) hit=ev[j]; if(ev[j].t===LOOT) loot=true; }
       for(j=0;j<pl.length;j++) if(pl[j]===DP) dang=true;
       if(!hit) bad.push('the Pillbox line was not drawn');
       else {
         if(hit.t!==PB) bad.push('the Pillbox line reads '+JSON.stringify(hit.t)+', not the headline '+PB);
         if(Math.abs(fpx(hit.font)-fpx(HF))>0.2) bad.push('the Pillbox line is drawn in '+hit.font+', not the callout size '+HF);
       }
       if(!dang) bad.push('the Pillbox line is not on the danger plate');
       if(!(g.alert&&g.alert.m===PB&&g.alert.k==='warn')) bad.push('the alert lane does not hold the Pillbox line as a warning ('+JSON.stringify(g.alert&&{m:g.alert.m,k:g.alert.k})+')');
       if(!loot) bad.push('the line said in the same frame was not drawn');
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the line said in the same frame is a line of the left feed and the alert is the top banner only, not a feed line as well.
       var FL=(g.fd&&g.fd.lines)||[], inF=false, pbF=false; for(j=0;j<FL.length;j++){ if(FL[j].txt===LOOT) inF=true; if(String(FL[j].txt).indexOf('THE PILLBOX')===0) pbF=true; }
       if(g.msg!==LOOT&&!inF) bad.push('the line said in the same frame is not a line of the left feed');
       if(pbF) bad.push('the Pillbox alert is drawn twice: the top banner and again a line of the left feed');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; keys={};
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},

  {v:'22.86',what:'a line said under the solo pause box shows on it: BACKSPACE with the pause box open in a solo raid puts the cursor line on the answer line over the box and adds no row to the raid feed; with the box shut a system line still goes to the feed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof syncPause!=='function'||typeof restoreCursor!=='function') return 'SKIP: no pause box in this build';
     var bad=[], g, el=document.getElementById('hubtoast'), f0, NC='Cursor '+'reset', i, inFeed=false, NZ='ZQ '+'PING';
     if(!el) return 'SKIP: no answer line in this page';
     function feedHas(s){ var F=g.feed||[], j, U=String(s).toUpperCase(), FL=(g.fd&&g.fd.lines)||[]; if(g.msgT>0&&String(g.msg).toUpperCase().indexOf(U)>=0) return true;
       for(j=0;j<FL.length;j++) if(String(FL[j].txt).toUpperCase().indexOf(U)>=0) return true;   // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired, so the feed is the lines of the left feed
       for(j=0;j<F.length;j++) if(F[j]&&F[j].T>0&&String(F[j].m).toUpperCase().indexOf(U)>=0) return true; return false; }   // tr55fix: in any case (CURSOR RESET)
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.msgT=0; g.msg=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[];
       el.textContent=''; el.classList.remove('on');
       togglePauseBox(true); syncPause();
       if(!g.paused) return 'SKIP: staging: the pause box did not pause the raid';
       if(netPauseLive()) return 'SKIP: staging: this raid is shared, so its pause is the overlay';
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Backspace',key:'Backspace',bubbles:true}));
       if(String(el.textContent).toUpperCase().indexOf(NC.toUpperCase())<0||!el.classList.contains('on')) bad.push('BACKSPACE under the solo pause box did not show the cursor line on the answer line (it reads '+JSON.stringify(el.textContent)+', on '+el.classList.contains('on')+')');
       if(feedHas(NC)) bad.push('BACKSPACE under the solo pause box put the cursor line in the raid feed behind the box');
       // CONTROL: the box shut, a system line goes to the feed as before.
       togglePauseBox(false); syncPause(); g.paused=false;
       el.textContent=''; el.classList.remove('on');
       say(NZ,'sys');
       if(!feedHas(NZ)) bad.push('control: with the box shut a system line did not reach the feed');
       if(String(el.textContent).indexOf(NZ)>=0) bad.push('control: with the box shut a system line went to the answer line');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ togglePauseBox(false); syncPause(); }catch(_c){} try{ pauseOpen=false; }catch(_c2){}
       try{ el.textContent=''; el.classList.remove('on'); if(typeof HUBTOAST_T!=='undefined'&&HUBTOAST_T){ clearTimeout(HUBTOAST_T); HUBTOAST_T=null; } }catch(_t){}
       try{ var g2=__state(); if(g2){ g2.paused=false; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},

  {v:'23.10',what:'two contracts that finish on one container both show: one crate that finishes an open contract and a district contract in the same frame leaves two CONTRACT DONE lines in the left feed, each with its own words as the detail, rather than the second writing over the first',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)||typeof contractOpen!=='function'||typeof contractDesc!=='function'||typeof feedSay!=='function') return 'SKIP: no contracts or feed here';
     var bad=[], P2=__P(), con0=P2.contracts, g=null, i, ct=null, c1, c2, H1, H2, got=[], all;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.containers) return 'SKIP: staging: no raid';
       for(i=0;i<g.containers.length;i++){ var k0=g.containers[i]; if(k0&&!k0.dropped&&k0.type&&k0.d!==undefined){ ct=k0; break; } }
       if(!ct) return 'SKIP: staging: no container with a district here';
       c1={type:'open',ct:ct.type,n:2,prog:1,desc:'Open 2 zqx9k boxes',reward:100};
       c2={type:'district',d:ct.d,n:2,prog:1,desc:'zqx9k district',reward:100};
       P2.contracts=[c1,c2];
       H1=contractDesc(c1); H2=contractDesc(c2);   /* v34.46 (cw-cdoneshort): the detail is the contract words only */
       if(H1===H2) return 'SKIP: staging: the two contracts read the same';
       g.paused=false; g.msg=''; g.msgT=0; g.msgSub=''; g.msgKey=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.fd={t:0,seq:0,lines:[]};
       contractOpen(ct);
       if(c1.prog<c1.n||c2.prog<c2.n) return 'SKIP: staging: the crate did not finish both contracts';
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired and nothing waits: each line is a line of the left feed, its detail after a middle dot.
       function fdRows(){ return ((g.fd&&g.fd.lines)||[]).map(function(l){ var s=String(l.txt), ix=s.indexOf('  \u00b7  '); return ix<0?{m:s,sub:''}:{m:s.slice(0,ix),sub:s.slice(ix+5)}; }); }
       all=fdRows();
       for(i=0;i<all.length;i++) got.push(String(all[i].m)+' | '+String(all[i].sub||''));
       for(i=0;i<(g.msgQ||[]).length;i++) got.push(String(g.msgQ[i])+' | '+String((g.msgQM[i]&&g.msgQM[i].o&&g.msgQM[i].o.sub)||''));
       if(got.indexOf('CONTRACT DONE | '+H1)<0) bad.push('the open contract line is not showing or waiting (rows and queue: '+JSON.stringify(got)+')');
       if(got.indexOf('CONTRACT DONE | '+H2)<0) bad.push('the district contract line is not showing or waiting (rows and queue: '+JSON.stringify(got)+')');
       g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.fd={t:0,seq:0,lines:[]};
       say('ZQX9K SAME','info',{sub:'one'}); say('ZQX9K SAME','info',{sub:'one'});
       all=fdRows();
       if(all.length!==1||all[0].sub!=='one') bad.push('a line with no key said twice is not one line of the left feed: '+JSON.stringify(all.map(function(r){ return r.m+' | '+r.sub; })));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       P2.contracts=con0; keys={};
       try{ var g2=__state(); if(g2){ g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgT=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},

  {v:'27.51',what:'his order: the banners that came in at their own heights of the centre are alerts in the top centre lane: a notoriety rise and the drop-in count, and the notoriety is not also a line of the left feed (v35.30 retarget: every raid line shows in one place)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||typeof notoStamp!=='function'||typeof arcadeDropHud!=='function'||typeof ARCADE==='undefined') return 'SKIP: no raid or arcade here';
     var bad=[], g, a, i, holdWas=ARCADE.holdT, hit=false, F, ln, ni=ARCADE.on;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.arcade=0; g.alert=null; g.alertQ=[];
       notoStamp('YOU STARTED THAT FIGHT');
       a=g.alert; if(!a||String(a.m).indexOf('NOTORIETY')!==0) bad.push('a notoriety rise is not an alert in the top lane');
       else if(a.sub!=='YOU STARTED THAT FIGHT') bad.push('the alert detail reads "'+a.sub+'", not why');
       F=g.fd; ln=null; if(F) for(i=0;i<F.lines.length;i++) if(F.lines[i].txt.indexOf('NOTORIETY')===0) ln=F.lines[i];
       if(ln) bad.push('the notoriety rise is drawn twice: the top alert and again a line of the left feed');   // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): an alert is the top banner only
       for(i=0;i<document.scripts.length&&!hit;i++) if(String(document.scripts[i].text).indexOf('v8.27: THE NOTO'+'RIETY STAMP')>=0) hit=true;
       if(hit) bad.push('the notoriety banner draw is still in the source');
       g.alert=null; g.alertQ=[];
       ARCADE.holdT=2.4; arcadeDropHud();
       a=g.alert; if(!a||!/^(dropping|ascending) in 3$/i.test(String(a.m))) bad.push('the drop-in count is not an alert (reads '+(a?a.m:'nothing')+')');
       ARCADE.holdT=1.2; arcadeDropHud();
       a=g.alert; if(!a||!/^(dropping|ascending) in 2$/i.test(String(a.m))) bad.push('the drop-in alert is not refreshed in place (reads '+(a?a.m:'nothing')+')');
       F=g.fd; if(F) for(i=0;i<F.lines.length;i++) if(/^(dropping|ascending) in/i.test(String(F.lines[i].txt))) bad.push('the drop-in count is written into the feed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ARCADE.holdT=holdWas; ARCADE.on=ni; }catch(_h){} try{ var g2=__state(); if(g2){ g2.alert=null; g2.alertQ=[]; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},

  {v:'31.04',what:'cw-shkey, his note (2026-10-18) "superhot mode needs a toggle key": the key left of 1 turns Superhot on and off in a raid once per press and moves the same dial as the one Settings row, the line on screen always says the state just set (also on three quick presses), the F1 list and the pane beside the Settings row name the key, and a linked window refuses its own press and says it when the host flips Superhot',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step the loop or draw a frame';
     if(typeof cycleGameOpt!=='function'||typeof applyGameOpts!=='function'||typeof GAMEOPTS==='undefined'||typeof keys==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no Superhot row or keys in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(typeof __vpAlive==='function'&&!__vpAlive()) return 'SKIP: the page has no laid out viewport, so the Settings pane and the controls list cannot be read';
     var bad=[], g=null, i, r, txt, proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, w, row, sl, hadGo=!!P.gameOpts, go0=P.gameOpts?JSON.parse(JSON.stringify(P.gameOpts)):null, ls0=null, seen;
     var hasNet=(typeof NET==='object'&&NET&&typeof netShTake==='function'&&typeof netShDrop==='function'), NK={}, k, netTouched=false;
     function el(id){ return document.getElementById(id); }
     function on(e){ return !!(e&&e.classList.contains('on')); }
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     // The key as it arrives: a keydown on the window, and a keyup, with the repeat flag a held key sends.
     function bq(rep){ clearKeys(); window.dispatchEvent(new KeyboardEvent('keydown',{code:'Backquote',key:'`',repeat:!!rep,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'Backquote',key:'`',bubbles:true,cancelable:true})); clearKeys(); }
     function setSuper(v){ P.gameOpts=P.gameOpts||{}; P.gameOpts.superhot=v; applyGameOpts(); }
     function topMsg(){ if(g&&g.msg) return g.msg; var L=(g&&g.fd&&g.fd.lines)||[]; return L.length?String(L[L.length-1].txt):''; }   // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired, so the line on top is the newest line of the left feed
     // Every Superhot line the player can see: the two message rows over the screen and the lines of the left feed.
     function shLines(){ return (g.feed||[]).map(function(f){ return f&&f.m; }).concat(((g.fd&&g.fd.lines)||[]).map(function(l){ return l&&l.txt; })).filter(function(m){ return /^SUPERHOT/.test(m||''); }); }
     function wipe(){ g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.fd={t:0,seq:0,lines:[]}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state==='undefined'||state!=='raid') return 'SKIP: the page is not in a raid here';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       if(typeof togglePauseBox==='function'&&on(el('pausebox'))) togglePauseBox(false);
       setSuper(0);
       // ONE CONTROL: Superhot has one Settings row; the key moves the same dial and the same saved word, it is not a second setting.
       if(GAMEOPTS.filter(function(o){ return o.k==='superhot'; }).length!==1) bad.push('Superhot has '+GAMEOPTS.filter(function(o){ return o.k==='superhot'; }).length+' Settings rows, not one');
       // THE KEY: the key left of 1 turns Superhot on and off in a raid, once per press, and a held key (repeat) does nothing more.
       bq(false);
       if(CFG.superhot!==1||P.gameOpts.superhot!==1) bad.push('the key left of 1 did not turn Superhot on in a raid (dial '+CFG.superhot+', saved '+P.gameOpts.superhot+')');
       if(topMsg()!=='SUPERHOT ON') bad.push('the first press said "'+topMsg()+'", not SUPERHOT ON');
       bq(true);
       if(CFG.superhot!==1) bad.push('a held key (repeat) flipped Superhot again');
       // THE TOAST TELLS THE TRUTH on three quick presses: the line on top is the state the last press set, not the one before it.
       bq(false);
       if(CFG.superhot!==0||topMsg()!=='SUPERHOT OFF') bad.push('the second press said "'+topMsg()+'" with the dial at '+CFG.superhot+', not SUPERHOT OFF');
       bq(false);
       if(CFG.superhot!==1) bad.push('the third press did not turn Superhot on again');
       if(topMsg()!=='SUPERHOT ON') bad.push('on three quick presses the line on top said "'+topMsg()+'" with Superhot ON, so the toast shows the state before the last press');
       seen=shLines();
       if(seen.some(function(m){ return m!=='SUPERHOT ON'; })) bad.push('three quick presses (on, off, on) left the lines "'+seen.join('", "')+'" on screen, so one of them says OFF with Superhot ON');
       // THE SETTINGS ROW follows the key: with Settings open the Superhot row shows the state the key set.
       if(typeof openSettings==='function'&&el('settingsmodal')){
         openSettings();
         row=el('go_superhot');
         if(!row) bad.push('the Settings list has no Superhot row to follow the key');
         else{
           w=row.textContent;
           bq(false);
           if(CFG.superhot!==0) bad.push('the key did not turn Superhot off with Settings open');
           row=el('go_superhot');
           if(!row||row.textContent===w) bad.push('the Superhot row did not change when the key moved the dial with Settings open');
           bq(false);
         }
         // THE ROW NAMES ITS KEY: the pane beside the list says which key does what the row does.
         sl=el('setlist'); row=el('go_superhot');
         if(row&&sl&&typeof window.__setDetailSync==='function'){
           try{ row.scrollIntoView({block:'center'}); }catch(_si){}
           row.dispatchEvent(new MouseEvent('mouseover',{bubbles:true}));
           window.__setDetailSync();
           w=(el('setdetail')||{}).textContent||'';
           if(w.indexOf('`')<0&&!/left of 1/i.test(w)) bad.push('the pane beside the Settings list does not name the key for Superhot ('+w.slice(0,80)+')');   // retargeted (cw-shkey2): the key is named as the tick or in words
         }
         el('settingsmodal').classList.remove('on');
       }
       // THE F1 LIST names the key and the word.
       setSuper(0); wipe(); g.legendOn=2; g.bagOpen=false; txt=[];   // the feed is cleared: the lines the key just said would answer for the list
       proto.fillText=function(){ txt.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ __frame(0.016); } finally { proto.fillText=oFt; }
       if(!txt.some(function(s){ return /superhot/i.test(s); })) bad.push('the F1 controls list does not mention Superhot');
       if(txt.indexOf('`')<0&&!txt.some(function(s){ return /^left of 1$/i.test(s); })) bad.push('the F1 controls list does not show the key left of 1');   // retargeted (cw-shkey2): the key is shown as the tick or in words
       g.legendOn=1;
       // THE PLAYER 2 WINDOW: it follows the host. Its own press says so and changes nothing; the host flipping it mid raid is said there too.
       if(hasNet){
         for(k in NET) NK[k]=NET[k]; netTouched=true;
         NET.on=true; NET.role='join'; NET.shHost=null; NET.shOwn=null; setSuper(0); CFG.superhot=0;
         netShTake(0);
         bq(false);
         if(CFG.superhot!==0) bad.push('a linked window changed Superhot on its own key press (dial '+CFG.superhot+')');
         wipe();
         netShTake(1);
         if(CFG.superhot!==1) bad.push('the linked window did not follow the host to Superhot ON');
         if(topMsg()!=='SUPERHOT ON') bad.push('the host turned Superhot on mid raid and the linked window said "'+topMsg()+'"');
         wipe();
         netShTake(1);
         if(topMsg()) bad.push('the linked window said "'+topMsg()+'" when the host word did not change');
         netShTake(0);
         if(CFG.superhot!==0||topMsg()!=='SUPERHOT OFF') bad.push('the host turning Superhot off mid raid left the linked window at '+CFG.superhot+' saying "'+topMsg()+'"');
         netShDrop();
       }
       return bad.length?bad.join('; '):null;
     } finally {
       proto.fillText=oFt;
       if(netTouched){ try{ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){} }
       clearKeys();
       try{ var _sm=el('settingsmodal'); if(_sm) _sm.classList.remove('on'); }catch(_e0){}
       if(hadGo) P.gameOpts=go0; else delete P.gameOpts;
       try{ applyGameOpts(); saveProfile(); }catch(_e4){}
       try{ __endRaid('abandon'); }catch(_e5){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},

  {v:'32.27',what:'cw-cx-sectorhold-o03: codex, weather and page notices wait off the map without losing lifetime, replay in order, loot tags do not overlap, and seats use amber/cyan',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__drawHUD&&typeof txRecord==='function')) return 'SKIP: this fixture cannot draw a raid';
     var g, bad=[], os=MAPFIRST.skip, ow=W, oh=H, op=mapPlaceLabels, oi=mapIcon, oseat=seatHere, proto=CanvasRenderingContext2D.prototype, ofill=proto.fill, fills=[], labels=[], markerRects=[], icons=[], i,j, n, msg, ft, saved;
     function tick(n){ for(var k=0;k<n;k++){ g.t+=0.1; msgTick(0.1); } }
     function overlaps(a,b){ return a.l<b.r&&b.l<a.r&&a.t<b.b&&b.t<a.b; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       MAPFIRST.skip=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; document.getElementById('hubtoast').classList.remove('on');
       keys={}; mouse.down=false; g.paused=false; g.mapFirst=0; g.bagOpen=false; g.mapOpen=true;
       g.fd={t:0,seq:0,lines:[]}; g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[]; g.mapPop=null;
       feedSay('CODEX ENTRY','info',{sub:'scav pistol'});
       var painted=txRecord(function(){ __drawHUD(); });
       if(painted.some(function(h){ return /codex entry/i.test(String(h.t)); })) return 'codex entry draws over the open map';
       if(typeof mapPopupTick!=='function') return 'map popup hold is missing';
       say('WEATHER TURN','info',{key:'mapwait-weather'}); hubToast('corner notice');
       if(g.mapPop.q.length!==3) bad.push('three notices were not all held');
       tick(200); if(g.fd.t!==0||g.mapPop.q.length!==3) bad.push('held notices used time or vanished');
       g.mapOpen=false; msgTick(0.1);
       if(g.fd.lines.length!==1||String(g.fd.lines[0].txt).toLowerCase().replace(/\s+/g,' ')!=='codex entry \u00b7 scav pistol') bad.push('codex was not first after close: '+JSON.stringify(g.fd.lines.map(function(r){ return r.txt; })));
       if(g.msgT>0) bad.push('weather overwrote the first notice');
       // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): the grey rows are retired: the weather notice is a line of the left feed, fresh on the feed clock when it comes out.
       function wl(){ var L=g.fd.lines; for(var q=0;q<L.length;q++) if(String(L[q].txt).indexOf('WEATHER TURN')===0) return L[q]; return null; }
       for(i=0;i<70&&!wl()&&g.msg!=='WEATHER TURN';i++) tick(1);
       if(!(g.msg==='WEATHER TURN'&&g.msgT>=3)&&!(wl()&&g.fd.t-wl().at<=1.2)) bad.push('weather did not follow with its full lifetime');
       for(i=0;i<40&&g.mapPop.q.length;i++) tick(1);
       if(document.getElementById('hubtoast').textContent.toLowerCase()!=='corner notice') bad.push('corner notice was not last');
       if(g.mapPop.q.length) bad.push('the notice queue did not drain');
       // v28.xx (cw-cx-sectorhold-o03): an already visible popup also waits when M leaves world time running.
       g.mapPop.wait=0; say('existing notice','info'); msg=g.msgT; ft=g.fd.t; g.mapOpen=true; tick(120);
       if(g.msgT!==msg||g.fd.t!==ft) bad.push('an existing notice aged behind the map');
       g.mapOpen=false; msgTick(0.1); if(msg>0?Math.abs(g.msgT-(msg-0.1))>0.001:Math.abs(g.fd.t-(ft+0.1))>0.001) bad.push('existing notice lost its remaining time');   // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): with no grey row the remaining time is the feed clock
       // v28.xx (cw-cx-sectorhold-o03): closing/opening/closing clears feed layout metadata as well as pixels (32.25).
       g.mapOpen=false; __drawHUD();
       if(!FEEDBOX.on||!FEEDBOX.rows.length) bad.push('feed layout control missing with the map shut');
       g.mapOpen=true; __drawHUD();
       if(FEEDBOX.on||FEEDBOX.rows.length) bad.push('previous feed layout survives over the open map');
       g.mapOpen=false; __drawHUD();
       if(!FEEDBOX.on||!FEEDBOX.rows.length) bad.push('feed layout did not return after map close');
       MAPFIRST.skip=0; g.mapOpen=false; saved=g.timeLeft;
       if(!mapFirstBegin()) bad.push('could not stage the opening map');
       else{ feedSay('opening codex','info'); for(i=0;i<30;i++){ mapFirstStep(0.1); msgTick(0.1); } if(g.timeLeft!==saved) bad.push('opening map consumed raid clock'); }
       mapFirstEnd('test'); g.mapFirst=0; g.mapOpen=true;
       if(mapSeatColor(-1)!==SEATCOL[0]||mapSeatColor(0)!==SEATCOL[0]||mapSeatColor(1)!==SEATCOL[1]) bad.push('seat colours differ from seat rings');
       for(n=0;n<2;n++){
         fills=[]; seatHere=(function(seat){ return function(){ return seat; }; })(n);
         proto.fill=function(){ fills.push(String(this.fillStyle).toLowerCase()); return ofill.apply(this,arguments); };
         try{ drawMapOverlay(); }finally{ proto.fill=ofill; seatHere=oseat; }
         if(fills.indexOf(SEATCOL[n])<0) bad.push('player '+(n+1)+' marker did not paint in its seat colour');
       }
       // v28.xx (cw-cx-sectorhold-o03): exercise the same narrow nine-contract layout as 31.55, rather than only the wider empty-contract map.
       P.contracts=[{type:'kill',tgt:'crawler',n:5,prog:3,reward:450,desc:'x',tier:'std'},{type:'open',ct:'crate',n:4,prog:1,reward:280,desc:'x',tier:'std'},
         {type:'district',d:0,n:3,prog:0,reward:480,desc:'x',tier:'std'},{type:'exItem',item:'core',n:1,prog:0,reward:1450,desc:'x',tier:'std'},
         {type:'haul',v:1200,n:1,prog:0,reward:720,desc:'x',tier:'std'},{type:'conduct',ck:'clean',n:1,prog:0,reward:900,desc:'x',tier:'std'},
         {type:'kill',tgt:'sentry',n:3,prog:3,reward:450,desc:'x',tier:'std'},{type:'conduct',ck:'swift',n:1,prog:0,reward:1000,desc:'x',tier:'std'},
         {type:'kill',tgt:'crawler',n:2,prog:0,reward:300,desc:'x',tier:'std'}];
       delete P.uiScale;
       if(!g.hotZone) g.hotZone={x:WORLD_W*0.3,y:WORLD_H*0.5,r:260};
       mapIcon=function(x,y,r){ var m=ctx.getTransform(); icons.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f}); return oi.apply(this,arguments); };
       mapPlaceLabels=function(Q,hdr,fn){
         return op(Q,hdr,function(s,x,y){
           if(/^(cache|looted|encampment|peddler|strongbox|the forge)$/i.test(String(s))){
             var fm=/([\d.]+)px/.exec(ctx.font), fp=fm?+fm[1]:16, L={x:x,y:y,w:ctx.measureText(typeof TX==='function'?TX(String(s)):String(s)).width,fp:fp,m:ctx.getTransform(),ta:ctx.textAlign,tb:ctx.textBaseline};
             var B=mapLabelRect(L,0,0); markerRects.push({t:String(s),box:B});
             if(/^(cache|looted|strongbox)$/i.test(String(s))) labels.push(B);
           }
           return (fn||proto.fillText).call(ctx,s,x,y);
         });
       };
       for(n=0;n<2;n++){
         W=n?3840:1920; H=n?2160:1080; labels=[]; markerRects=[]; icons=[];
         __drawHUD();
         j=g.containers.filter(function(c){ return !!c.cache; }).length+g.containers.filter(function(c){ return c.strong&&!c.opened; }).length;
         if(labels.length!==j) bad.push('not every cache/strongbox has its own label at '+H+'p ('+labels.length+'/'+j+')');
         for(i=0;i<labels.length;i++) for(j=i+1;j<labels.length;j++) if(overlaps(labels[i],labels[j])) bad.push('loot labels overlap at '+H+'p');
         var cd=mapCard(), distant=[];
         markerRects.forEach(function(rec){ var B=rec.box, best=Infinity, nearest=null; icons.forEach(function(I){ var dx=Math.max(0,I.l-B.r,B.l-I.r), dy=Math.max(0,I.t-B.b,B.t-I.b), d=Math.sqrt(dx*dx+dy*dy); if(d<best){ best=d; nearest=I; } }); if(best>(/^(cache|looted|strongbox)$/i.test(String(rec.t))?100:12)*cd.z) distant.push({t:rec.t,gap:Math.round(best*10)/10,box:B,nearest:nearest}); });
         if(distant.length>3) bad.push('marker tags too far at '+H+'p: '+JSON.stringify(distant));
       }
       return bad.length?bad.join('; '):null;
     }finally{
       W=ow; H=oh; mapPlaceLabels=op; mapIcon=oi; seatHere=oseat; proto.fill=ofill; MAPFIRST.skip=os; keys={}; mouse.down=false;
       if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; document.getElementById('hubtoast').classList.remove('on');
       try{ if(g){ g.mapFirst=0; g.mapOpen=false; g.mapPop=null; } __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},

  {v:'33.08',what:'golden sentry and pillager bot death callouts draw once in both windows and keep search the hoard (critic duplicate finding)',
   run:function(){
     var g=null, oPeer=flowPeer, own=Object.prototype.hasOwnProperty.call(XF,'xfGold'), gold0=XF.xfGold,
         kinds=['sentry','raider'], names=['golden sentry down','golden pillager bot down'], i, side, trace, hits, want;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'staging: no raid';
       flowPeer=function(){ return false; }; XF.xfGold=1;
       g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.legendOn=0;
       for(i=0;i<kinds.length;i++) for(side=0;side<2;side++){
         g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.alert=null; g.msgLog=[]; g.fd=null;
         g.mapPop={q:[],wait:0,replay:0,open:false,at:0}; g.flow=g.flow||{};
         if(side===0){
           g.flow.gold={ref:{kind:kinds[i],hp:0,x:g.player.x+100,y:g.player.y},dead:0}; goldTick(0.01);
         }else{
           g.flow.gold={ref:null,dead:0}; goldNetTake([0,1,g.player.x+100,g.player.y,kinds[i]]);
         }
         feedTick(0.3); trace=__textTrace(function(){ __frame(0.016); }); want=names[i];
         hits=trace.filter(function(r){ return r.t.toLowerCase().indexOf(want)>=0; });
         if(hits.length!==1) return (side?'linked ':'host ')+want+' drawn '+hits.length+' times';
         // v35.30 (cw-quiettext) retarget, his order 2026-10-27 (build the quiet hud): a feed line draws its name and its detail as two pieces on one line, so the detail may be its own piece.
         if(hits[0].t.toLowerCase().indexOf('search the hoard')<0&&!trace.some(function(r){ return r.t.toLowerCase().indexOf('search the hoard')>=0&&(r.y===undefined||Math.abs(r.y-hits[0].y)<4); })) return 'missing search the hoard';
       }
       return null;
     } finally {
       flowPeer=oPeer; if(own) XF.xfGold=gold0; else delete XF.xfGold;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},

  {v:'9.89',what:'the tactical belt has one name on every surface that names it (his word since v10.26; it was hotbar from v9.89)',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so no gesture can be aimed';
     // THE NEEDLES ARE ASSEMBLED, never written out. This page embeds the source
     // it tests, and a check that greps for a phrase finds its own comment; it
     // has happened three times in this corpus. The old names are built from
     // halves so this file never contains them whole.
     var TACT=['Tact','ical belt'].join(''), BAR=['in the ','bar below'].join('');
     var BELTINV=['hotbar ','belt and inventory'].join(''), OFFBELT=['off the ','belt and into'].join('');
     var PLUSBELT=['plus your ','belt'].join('');
     function has(text,needle){ return String(text||'').toLowerCase().indexOf(needle.toLowerCase())>=0; }
     // ONE: the three surfaces that name it in markup, read as rendered text.
     var cm=document.getElementById('carrymodal');
     if(!cm) return 'SKIP: no raid backpack panel in the page';
     var heads=[].map.call(cm.querySelectorAll('h2'),function(h){ return h.textContent.trim(); });
     var msub=(cm.querySelector('.msub')||{}).textContent||'';
     var labs=[].map.call(document.querySelectorAll('.loslab'),function(l){ return l.textContent.trim(); });
     var all=heads.concat([msub]).concat(labs).join(' | ');
     var OLDW=['hot','bar'].join('');
     if(has(all,OLDW)) bad.push('a panel heading still says '+OLDW);
     if(has(msub,PLUSBELT)) bad.push('the backpack subtitle still says '+PLUSBELT);
     if(!heads.some(function(h){ return /^tactical belt$/i.test(h); }))
       bad.push('the raid backpack panel has no heading that reads Tactical belt, it has ['+heads.join(', ')+']');
     if(!labs.some(function(l){ return /^tactical belt/i.test(l); }))
       bad.push('the Undercroft loadout column has no label that starts with Tactical belt, it has ['+labs.join(', ')+']');
     // TWO: the prompt behind clicking an EMPTY hotbar cell in the Undercroft.
     __pinDPR(1); __forceSize(1920,1080); __cleanProfile();
     var P2=__P(); P2.stash=['frag']; P2.kit=[]; P2.hotAssign={};
     var shut=['stagemodal','sectormodal','outcome','title','pausebox'], was={};
     for(var si=0;si<shut.length;si++){ var se=document.getElementById(shut[si]);
       was[shut[si]]=!!(se&&se.classList.contains('on')); if(se) se.classList.remove('on'); }
     var hub=document.getElementById('hub'), hubWas=!!(hub&&hub.classList.contains('on'));
     function done(v){
       for(var q=0;q<shut.length;q++){ var e2=document.getElementById(shut[q]);
         if(!e2) continue; if(was[shut[q]]) e2.classList.add('on'); else e2.classList.remove('on'); }
       if(hub){ if(hubWas) hub.classList.add('on'); else hub.classList.remove('on'); }
       return v;
     }
     __showScreen('hub'); if(hub) hub.classList.add('on');
     // The ascent check has the same cells earlier in the document: ask the
     // stash screen for ITS cell.
     var cell=(hub||document).querySelector('[data-plan="5"]');
     if(!cell) return done('SKIP: the Undercroft column drew no hotbar cell');
     window.__lastSay=null;
     (function(){ var _t0=document.getElementById('hubtoast')||document.getElementById('toast')||document.getElementById('say2'); if(_t0) _t0.textContent=''; })();
     var hubToastText='';
     try{ cell.click(); }catch(e1){}
     // say2 writes to the hub toast; read whatever it wrote, and the fixture's
     // last-say mirror in case this build routes it there.
     var toast=document.getElementById('hubtoast')||document.getElementById('toast')||document.getElementById('say2');
     hubToastText=(toast&&toast.textContent)||'';
     var said=String(window.__lastSay||'')+' '+hubToastText;
     if(!/tactical belt/i.test(said)&&!has(said,OLDW)&&!has(said,BAR))
       return done('SKIP: clicking an empty belt cell said nothing this check can read: ['+said.trim().slice(0,80)+']');
     if(has(said,BAR)) bad.push('clicking an empty belt cell still says '+BAR);
     if(has(said,OLDW)) bad.push('clicking an empty belt cell still says '+OLDW);
     // THREE: the ascent summary sentence, which named both in one breath.
     var st=null; try{ st=__renderStage&&__renderStage(); }catch(e2){}
     var stage=document.getElementById('stagemodal');
     var stText=(stage&&stage.textContent)||'';
     if(has(stText,BELTINV)) bad.push('the ascent summary still says '+BELTINV);
     if(stage) stage.classList.remove('on');
     // FOUR: the message when an item is dragged OFF the hotbar. Same gesture the
     // v9.82 check drives, read off the toast it produces.
     P2.stash=['frag','frag']; P2.kit=['frag']; P2.hotAssign={5:'frag'};
     __showScreen('hub'); if(hub) hub.classList.add('on');
     var c2=(hub||document).querySelector('[data-plan="5"]'), sg=document.getElementById('stashgrid');
     if(c2&&sg){
       var cr=c2.getBoundingClientRect(), sr=sg.getBoundingClientRect();
       function ev(t,x,y,el){ var e=new MouseEvent(t,{bubbles:true,cancelable:true,clientX:x,clientY:y,button:0}); (el||document).dispatchEvent(e); }
       window.__lastSay=null;
       ev('mousedown',cr.left+cr.width/2,cr.top+cr.height/2,c2);
       ev('mousemove',sr.left+sr.width/2,sr.top+30);
       ev('mouseup',sr.left+sr.width/2,sr.top+30);
       var t2=document.getElementById('hubtoast')||document.getElementById('toast')||document.getElementById('say2');
       var said2=String(window.__lastSay||'')+' '+((t2&&t2.textContent)||'');
       if(has(said2,OFFBELT)) bad.push('dragging an item off the hotbar still says '+OFFBELT);
     }
     return done(bad.length?bad.join('; '):null); }},

], out=[]; C.forEach(function(t){ var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw '+e; } out.push(t.v+': '+(r?String(r).slice(0,500):'PASS')); }); return out.join(' ### '); })()