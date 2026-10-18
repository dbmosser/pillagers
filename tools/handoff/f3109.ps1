$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'31.09',what:")) { throw "check 31.09 is in the fixture already" }

SubRx @'
  {v:'31.08',what:
'@ @'
  {v:'31.09',what:'cw-mapfirst, his note (2026-10-18, in a raid): "raid should show map at the beginning of the game and player has to click to proceed into the actual raid, clock/game ... until map is dismissed". A raid taken from the lift stands on the sector map with the world frozen over 12 loop frames, a click, E, Space, Tab or pad A or B starts it (never a shot, never in the same breath as the lift), two windows start only when both pressed and the first says waiting for the other, the party arcade lets go after 20 s, the prompt follows the last device',
   run:function(){
     if(typeof MAPFIRST!=='object'||typeof mapFirstGo!=='function'||typeof mapFirstStep!=='function'||typeof mapFirstPeers!=='function') return 'no map first screen in this build (MAPFIRST is missing)';
     if(!(window.__loop&&window.__state&&window.__endRaid&&window.__hubEnter&&window.__station&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot walk from the Undercroft into a raid';
     var bad=[], g=null, p=null, i, k, r, s0, s1, tl0, sh0, mv, txt, peer, peerB, box=[], boxB=[], w, nm, gp=null, NK={}, padK={}, pk, hasGp=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), oGp=navigator.getGamepads,
         oSay=say, oParty=PARTY, oSkip=MAPFIRST.skip, oDev=INDEV.dev, oLeg=INDEV.legacy, oMd=mouse.down, alive=(typeof __vpAlive!=='function')||__vpAlive(), got;
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     var rumK={}, rk; for(rk in RUMBLE) if(Object.prototype.hasOwnProperty.call(RUMBLE,rk)) rumK[rk]=RUMBLE[rk];   // a pad press stamps RUMBLE.usedAt, which the arcade idle clock reads: put it back
     for(k in NET) NK[k]=NET[k];
     var T0=performance.now(), where='start';
     function late(){ if(performance.now()-T0>70000) throw new Error('too slow at '+where+' after '+Math.round(performance.now()-T0)+' ms'); }
     function frames(n){ var b=performance.now(), q; for(q=0;q<n;q++){ __loop(b+q*50); late(); } }   // 50 ms apart is the longest step the loop allows, so a few frames are a real half second
     function shots(){ return (g&&g.tel&&g.tel.shots)|0; }
     function snap(){ var o={t:g.t,tl:g.timeLeft,x:p.x,y:p.y,sh:shots(),pos:[]}, q; for(q=0;q<g.ents.length&&q<80;q++) o.pos.push(Math.round(g.ents[q].x*100)+','+Math.round(g.ents[q].y*100)); return o; }
     function movedEnts(a,b){ var n=0, q; for(q=0;q<a.pos.length;q++) if(a.pos[q]!==b.pos[q]) n++; return n; }
     function up(){   // a player goes up: the Undercroft floor, the lift, the quick ascent act (the same function its key press calls)
       var q;
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(_e0){}
       __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       keys={}; mouse.down=false; P.mapIx=0; pendSeed=4242;
       __hubEnter();
       q=__station('lift','KeyR');
       if(!q||q.err) return 'the quick ascent act did not fire ('+JSON.stringify(q)+')';
       g=__state();
       if(!g||g.over||g.sim||!g.player||state!=='raid') return 'no raid came up from the quick ascent';
       p=g.player;
       return null;
     }
     function rearm(){ g.mapFirst=0; g.mapOpen=false; MAPFIRST.skip=0; if(!mapFirstBegin()) bad.push('could not put the opening map back up for a staged test'); g.mapFirstT=0.5; }
     function padStub(){ var b=[], q; for(q=0;q<17;q++) b.push({pressed:false,value:0}); gp={connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:b,mapping:'standard'}; navigator.getGamepads=function(){ return [gp]; }; }
     function padBtn(n,on){ gp.buttons[n]={pressed:!!on,value:on?1:0}; }
     function padOff(){ gp=null; if(hasGp) navigator.getGamepads=oGp; else delete navigator.getGamepads; for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; for(rk in rumK) RUMBLE[rk]=rumK[rk]; try{ padBodyCls(); }catch(_pb){} }
     function key(code,type,rep){ window.dispatchEvent(new KeyboardEvent(type||'keydown',{code:code,key:code.replace('Key','').toLowerCase(),repeat:!!rep,bubbles:true})); }
     function click(){ cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,clientX:300,clientY:300})); }
     function clickUp(){ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})); }
     function seen(fn){ var h=txRecord(fn), out=[], q; for(q=0;q<h.length;q++) out.push(String(h[q].t)); return out; }
     function has(list,rx){ for(var q=0;q<list.length;q++) if(rx.test(list[q])) return true; return false; }
     function word(mf,pz){ return {t:'st',k:'r',sd:g.seed>>>0,x:p.x+120,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',pz:pz?1:0,hp:100,mh:100,ar:0,ac:0,dt:0,sa:1,mf:mf}; }
     function dcOf(b){ return {readyState:'open',send:function(s){ try{ b.push(JSON.parse(s)); }catch(_j){} }}; }
     function stage(){   // this window hosts a two seat raid; seat 1 is up top in the raid it hosts, seat 2 only listens
       peer={id:991,pc:null,dc:dcOf(box),fc:null,state:'in',seat:1,pid:'zqxseat1',name:'ZQX MATE',timers:[]};
       peerB={id:992,pc:null,dc:dcOf(boxB),fc:null,state:'in',seat:2,pid:'zqxseat2',name:'ZQX THIRD',timers:[]};
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.upSeed=g.seed>>>0; NET.peers=[peer,peerB]; NET.up=[]; NET.upOut=undefined; NET.upAcc=0;
       NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ZQX MATE'},{seat:2,name:'ZQX THIRD'}];
       try{ netEntsInit(g); }catch(_ei){}
       say=function(){ return 0; };
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // CONTROL: the same ascent with the screen skipped is a live raid, so the readings below can tell a frozen raid from a running one
       where='control'; MAPFIRST.skip=1;
       r=up(); if(r) return r;
       if(g.mapFirst||g.paused||g.mapOpen) return 'CONTROL: the fixture skip (MAPFIRST.skip=1) still opened the map first screen';
       s0=snap(); keys['KeyD']=true; frames(12); keys={}; s1=snap();
       if(!(s1.t>s0.t+0.3)) return 'CONTROL: with the screen skipped the raid clock did not run over 12 frames ('+s0.t+' to '+s1.t+'), so what follows would prove nothing';
       // ONE: the way a player goes up, the map is up and the world stands still over 12 frames, with the walking keys held
       where='one'; MAPFIRST.skip=0;
       r=up(); if(r) return r;
       if(!(g.mapFirst===1&&g.mapOpen===true&&g.paused===true)) return 'ONE: a raid from the quick ascent did not open on the map ('+JSON.stringify({mapFirst:g.mapFirst,mapOpen:g.mapOpen,paused:g.paused})+')';
       click(); clickUp();
       if(!g.mapFirst) bad.push('ONE: a click in the same breath as the ascent started the raid');
       s0=snap(); keys['KeyD']=true; keys['KeyW']=true; frames(12); keys={}; s1=snap();
       if(s1.t!==s0.t||s1.tl!==s0.tl) bad.push('ONE: the raid clock ran on the map ('+s0.t+' to '+s1.t+', time left '+s0.tl+' to '+s1.tl+')');
       if(s1.x!==s0.x||s1.y!==s0.y) bad.push('ONE: the player moved on the map');
       mv=movedEnts(s0,s1); if(mv) bad.push('ONE: '+mv+' bodies moved on the map');
       if(!(g.mapFirst===1&&g.mapOpen&&g.paused)) bad.push('ONE: the map did not stay up over 12 frames');
       if(!(g.mapFirstT>0.4)) bad.push('ONE: the screen counted '+g.mapFirstT+' s over 12 frames');
       // TWO: a click starts it, is not a shot, and the clock runs on after it
       where='two'; click();
       if(g.mapFirst||g.mapOpen||g.paused) bad.push('TWO: a click did not start the raid ('+JSON.stringify({mapFirst:g.mapFirst,mapOpen:g.mapOpen,paused:g.paused})+')');
       if(mouse.down) bad.push('TWO: the click that started the raid is held down as the trigger');
       clickUp(); tl0=g.t; sh0=shots(); frames(8);
       if(!(g.t>tl0+0.3)) bad.push('TWO: the raid clock did not run after the click ('+tl0+' to '+g.t+')');
       if(shots()!==sh0) bad.push('TWO: the click that started the raid fired a shot');
       // the rest runs on this one raid with the screen put back up between the cases (a raid is slow to build)
       // THREE: keys. A walking key and a key repeat start nothing; E starts it
       where='three'; rearm();
       key('KeyW'); key('KeyW','keyup');
       if(!g.mapFirst) bad.push('THREE: W started the raid');
       key('KeyE','keydown',true);
       if(!g.mapFirst) bad.push('THREE: a held E (a key repeat) started the raid');
       key('KeyE'); key('KeyE','keyup');
       if(g.mapFirst||g.paused) bad.push('THREE: E did not start the raid');
       tl0=g.t; frames(6); if(!(g.t>tl0+0.2)) bad.push('THREE: the raid clock did not run after E');
       rearm();
       key('Space'); key('Space','keyup');
       if(g.mapFirst||g.paused) bad.push('THREE: Space did not start the raid');
       rearm();
       key('Tab'); frames(1); key('Tab','keyup');
       if(g.mapFirst||g.paused) bad.push('THREE: Tab, the way out of a map, did not start the raid');
       // FOUR: a pad. One plugged in starts nothing; A starts it and is not a roll; B, the way out of a map, starts it
       where='four'; rearm();
       padStub(); frames(2);
       if(!g.mapFirst) bad.push('FOUR: a pad plugged in started the raid');
       padBtn(0,true); frames(2); padBtn(0,false); frames(1);
       if(g.mapFirst||g.paused) bad.push('FOUR: pad A did not start the raid');
       if(p.roll>0) bad.push('FOUR: pad A that started the raid also rolled');
       padOff(); rearm();
       padStub(); frames(2); padBtn(1,true); frames(2); padBtn(1,false);
       if(g.mapFirst||g.paused) bad.push('FOUR: pad B, the way out of a map, did not start the raid');
       padOff(); rearm(); frames(1);
       where='seven'; // SEVEN: what is drawn follows the last device used
       if(alive){
         INDEV.legacy=false; INDEV.dev='kb'; rearm();
         txt=seen(function(){ frames(2); });
         if(!has(txt,/^or click to start$/)) bad.push('SEVEN: the keyboard prompt on the map does not read or click to start ('+txt.filter(function(s){ return /start|click|waypoint/.test(s); }).join(' | ')+')');
         if(!has(txt,/^e$/)) bad.push('SEVEN: the keyboard prompt shows no E key');
         if(has(txt,/click to set a waypoint/)) bad.push('SEVEN: the waypoint hint still shows on the opening map, where a click starts the raid');
         if(has(txt,/drop in/)) bad.push('SEVEN: the opening map says drop in');
         padStub(); INDEV.dev='pad'; rearm();
         txt=seen(function(){ frames(2); });
         if(!has(txt,/^to start$/)||has(txt,/or click/)) bad.push('SEVEN: the pad prompt on the map does not read to start ('+txt.filter(function(s){ return /start|click/.test(s); }).join(' | ')+')');
         if(!has(txt,/^a$/)) bad.push('SEVEN: the pad prompt shows no A button');
         padOff(); INDEV.dev='kb';
         mapFirstEnd('test'); g.mapOpen=true; frames(1);
         txt=seen(function(){ frames(2); });
         if(!has(txt,/click to set a waypoint/)) bad.push('SEVEN: the waypoint hint is gone from the map the player opens himself');
         g.mapOpen=false;
       }
       where='six'; // SIX: the party arcade lets go by itself after 20 s; a plain raid and a career party never do
       rearm(); g.arcade=1; PARTY=true;
       for(i=0;i<19;i++) mapFirstStep(1);
       if(!g.mapFirst) bad.push('SIX: the party arcade let go of the map before 20 s');
       mapFirstStep(0.4); if(!g.mapFirst) bad.push('SIX: the party arcade let go of the map before 20 s (19.9)');
       mapFirstStep(0.4);
       if(g.mapFirst||g.paused) bad.push('SIX: the party arcade did not let go of the map by itself after 20 s');
       rearm(); g.arcade=1; PARTY=false;
       for(i=0;i<40;i++) mapFirstStep(1);
       if(!g.mapFirst) bad.push('SIX: without the party flag the map let go by itself');
       rearm(); g.arcade=0; PARTY=true;
       for(i=0;i<40;i++) mapFirstStep(1);
       if(!g.mapFirst) bad.push('SIX: a career raid let go of the map by itself');
       g.arcade=0; PARTY=oParty;
       where='five'; // FIVE: two windows. The clock starts when both have pressed
       rearm(); stage();
       netOnState(peer,word(1,0));
       if(!NET.up[1]||NET.up[1].mf!==1||!netUpShown(NET.up[1])) return 'SKIP: staging: the other seat map word was not filed up top (mf '+(NET.up[1]&&NET.up[1].mf)+')';
       if(netPauseLive()) bad.push('FIVE: a shared raid on its map lets the world run behind it (netPauseLive is true)');
       mapFirstGo('key');
       if(!(g.mapFirst===1&&g.mapFirstMe===1)||mapFirstWord()!==2) bad.push('FIVE: pressing while the other seat is still on its map did not wait ('+JSON.stringify({mapFirst:g.mapFirst,me:g.mapFirstMe,word:mapFirstWord()})+')');
       for(i=0;i<40;i++) mapFirstStep(0.05);
       if(!g.mapFirst||!g.paused) bad.push('FIVE: the raid started while the other seat was still on its map');
       if(alive){
         txt=seen(function(){ drawMapOverlay(); });
         if(!has(txt,/^waiting for zqx mate$/)) bad.push('FIVE: no waiting for line on the map after the press ('+txt.filter(function(s){ return /wait|start/.test(s); }).join(' | ')+')');
       }
       box.length=0; boxB.length=0; NET.upAcc=1;
       try{ netUpTick(0.2); }catch(_tk){ bad.push('FIVE: netUpTick threw '+(_tk&&_tk.message||_tk)); }
       w=box.filter(function(x){ return x&&x.t==='st'&&x.k==='r'; })[0];
       if(!w||w.mf!==2) bad.push('FIVE: the state word of a window that pressed does not say mf 2 ('+(w&&w.mf)+')');
       netOnState(peer,word(2,0)); mapFirstStep(0.05);
       if(g.mapFirst||g.paused) bad.push('FIVE: both seats pressed and the raid did not start');
       rearm(); stage();
       netOnState(peer,word(2,1));
       for(i=0;i<40;i++) mapFirstStep(0.05);
       if(!g.mapFirst) bad.push('FIVE: a seat that had pressed started the raid for a window that had not');
       mapFirstGo('key');
       if(g.mapFirst) bad.push('FIVE: the other seat had pressed and my press did not start the raid');
       rearm(); stage();
       netOnState(peer,word(0,0)); mapFirstStep(0.05);
       if(g.mapFirst) bad.push('FIVE: a window did not follow a seat whose clock is already running');
       rearm(); stage(); NET.upOut={1:0};
       mapFirstGo('key');
       for(i=0;i<70;i++) mapFirstStep(0.05);
       if(!g.mapFirst) bad.push('FIVE: the window did not wait for a seat that said it came up and sent no word yet');
       for(i=0;i<20;i++) mapFirstStep(0.05);
       if(g.mapFirst) bad.push('FIVE: the window waited more than 4 s for a seat that sent no word');
       rearm(); stage(); NET.upOut=undefined;
       mapFirstGo('key');
       if(g.mapFirst) bad.push('FIVE: a seat that is not in this raid held the press (the second window sitting on the attract)');
       // the words on the wire: kept, handed on, and carried by a late joiner
       rearm(); stage(); box.length=0; boxB.length=0;
       netOnState(peer,word(1,0));
       w=boxB.filter(function(x){ return x&&x.t==='st'&&x.k==='r'&&x.s===1; })[0];
       if(!w||w.mf!==1) bad.push('FIVE: the host did not hand on the mf of a seat ('+(w&&w.mf)+')');
       netOnState(peer,{t:'st',k:'r',sd:g.seed>>>0,x:p.x+120,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',hp:100,mh:100});
       if(!NET.up[1]||NET.up[1].mf!==0) bad.push('FIVE: a word with no mf (an older window) did not read as running');
       netOnState(peer,word(1,0));
       NET.upWord={t:'raid',seed:g.seed>>>0}; NET.lateOut={}; box.length=0; mapFirstGo('key');
       if(!g.mapFirst) bad.push('FIVE: the staging let the map go before the late join word was read');
       try{ netLateReply(peer); }catch(_lr){ bad.push('FIVE: netLateReply threw '+(_lr&&_lr.message||_lr)); }
       w=box.filter(function(x){ return x&&x.late; })[0];
       if(!w||!w.late||w.late.mf!==2) bad.push('FIVE: the late join word does not carry the host state (mf '+(w&&w.late&&w.late.mf)+')');
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       say=oSay;
       rearm(); netLateApply({late:{t:3,left:g.timeLeft,x:p.x,y:p.y,mf:0},gone:[],wg:[]});
       if(g.mapFirst) bad.push('FIVE: a late joiner stayed on the map of a raid that is already running');
       rearm(); netLateApply({late:{t:3,left:g.timeLeft,x:p.x,y:p.y,mf:1},gone:[],wg:[]});
       if(!g.mapFirst) bad.push('FIVE: a late joiner was let into a raid whose host is still on the map');
       return bad.length?bad.join('; '):null;
     } finally {
       padOff(); say=oSay; PARTY=oParty; MAPFIRST.skip=oSkip; INDEV.dev=oDev; INDEV.legacy=oLeg; mouse.down=oMd; keys={};
       try{ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){}
       try{ if(G&&G.arcade) G.arcade=0; }catch(_ga){}
       try{ if(G&&!G.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     } }},
  {v:'31.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
