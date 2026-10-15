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

if ($s.Contains("  {v:'28.25',what:")) { throw "check 28.25 is in the fixture already" }

SubRx @'
  {v:'28.24',what:
'@ @'
  {v:'28.25',what:'cloud-coop-event-ends-said: player 2 window says the same convoy and rampage end line the host said: carrier killed CONVOY DOWN / SEARCH THE CRATE, carrier gone at its destination CONVOY AWAY, carrier staying in view CONVOY ARRIVED / THEY STAY (even when it is gone before the next word), timeout nothing, rampage ran out with the Overseer alive OVERSEER RETURNS (even when he dies before the next word), Overseer killed nothing',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof EVENTS!=='object'||!EVENTS.convoy||!EVENTS.rampage) return 'SKIP: no arcade, party or events in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oB=netBroadcast, oSay=say, sent=[], w=null, h={seat:0,state:'in'}, HF=null, PF={}, staged=false, ev, i, oIv=null, side='host', L={host:[],p2:[]}, b=null, oBoss=null, mine=null, oBc, bk={}, hit, nid=960, px=0, py=0, car=null;
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function asHost(){ side='host'; NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.upSeed=g.seed>>>0; g.flow=HF; }
     function asTwo(){ side='p2'; NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; }
     function sendTake(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); sent.length=0; asHost(); return w; }
     function has(a,re){ for(var q=0;q<a.length;q++) if((re).test(a[q])) return a[q]; return null; }
     function cnt(a,re){ var n=0, q; for(q=0;q<a.length;q++) if((re).test(a[q])) n++; return n; }
     function tag(e){ if(e&&!e.nid){ e.nid=nid++; } if(e) NET.entMap[e.nid]=e; }
     function goLive(id){ var e=evLaunch(id), j; if(!e) return null; e.t=e.warn; evTick(0.01); if(e.ph!=='live') return null; if(id==='convoy'){ for(j=0;e.d.crew&&j<e.d.crew.length;j++) tag(e.d.crew[j]); } else tag(e.d.b); sendTake(); return e; }
     function runOut(e){ var j; for(j=0;j<10&&e.ph==='live';j++){ g.t+=0.05; evTick(0.05); } }
     function clear(){ HF.ev.live=[]; sendTake(); L={host:[],p2:[]}; }
     function same(tagx,re,mid){
       var a, c;
       if(mid) mid(); sendTake(); a=has(L.host,re); c=has(L.p2,re);
       if(!a) return 'SKIP: staging: '+tagx+': the host did not say it ('+JSON.stringify(L.host)+')';
       if(!c) bad.push(tagx+': the host said '+a+' and player 2 window said nothing of it ('+JSON.stringify(L.p2)+')');
       else if(c!==a) bad.push(tagx+': player 2 window said '+c+', the host said '+a);
       sendTake(); sendTake();
       if(cnt(L.p2,re)>1) bad.push(tagx+': player 2 window said it more than once ('+JSON.stringify(L.p2)+')');
       return null;
     }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99; px=p.x; py=p.y;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netBroadcast=function(m){ sent.push(JSON.parse(JSON.stringify(m))); return 1; };
       say=function(a,b2,c){ L[side].push(String(a)+'|'+((c&&c.sub)||'')+'|'+String(b2)); };
       HF=g.flow||{}; HF.ev={plan:[],live:[],n:0,wrecks:[]}; HF.sh={sites:[]}; HF.fplan=[];
       asHost(); g.t=60;
       // ONE: the convoy carrier is killed
       ev=goLive('convoy'); if(!ev||!ev.d.car) return 'SKIP: staging: the convoy did not go live';
       L={host:[],p2:[]};
       ev.d.car.hp=0; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the convoy did not end when its carrier died';
       hit=same('ONE carrier killed',/^CONVOY DOWN\|/); if(hit) return hit;
       if(has(L.p2,/^CONVOY AWAY\|/)) bad.push('ONE: player 2 window said CONVOY AWAY for a carrier that was killed');
       clear();
       // TWO: the carrier reaches its destination
       ev=goLive('convoy'); if(!ev||!ev.d.car) return 'SKIP: staging: the second convoy did not go live';
       L={host:[],p2:[]};
       p.x=(ev.d.dx<WORLD_W/2)?WORLD_W-320:320; p.y=(ev.d.dy<WORLD_H/2)?WORLD_H-320:320;
       ev.d.car.x=ev.d.dx; ev.d.car.y=ev.d.dy; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the convoy did not end at its destination';
       if(G.ents.indexOf(ev.d.car)>=0) return 'SKIP: staging: the carrier stayed with the host player far away';
       hit=same('TWO carrier arrived',/^CONVOY AWAY\|/); if(hit) return hit;
       if(has(L.p2,/^CONVOY (DOWN|ARRIVED)\|/)) bad.push('TWO: player 2 window said '+has(L.p2,/^CONVOY (DOWN|ARRIVED)\|/)+' for a convoy that got away');
       p.x=px; p.y=py; clear();
       // TWO B: the carrier arrives next to the host player: it stays
       ev=goLive('convoy'); if(!ev||!ev.d.car) return 'SKIP: staging: the convoy for the stay did not go live';
       L={host:[],p2:[]};
       ev.d.car.x=ev.d.dx; ev.d.car.y=ev.d.dy; p.x=ev.d.dx+100; p.y=ev.d.dy; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the staying convoy did not end';
       hit=same('TWO B carrier arrived in view',/^CONVOY ARRIVED\|/); if(hit) return hit;
       if(has(L.p2,/^CONVOY (AWAY|DOWN)\|/)) bad.push('TWO B: the carrier stayed and player 2 window said '+has(L.p2,/^CONVOY (AWAY|DOWN)\|/));
       clear();
       // TWO C: the carrier arrives in view, then is gone before the next world word: player 2 still says what the host said
       ev=goLive('convoy'); if(!ev||!ev.d.car) return 'SKIP: staging: the convoy for the race did not go live';
       L={host:[],p2:[]};
       ev.d.car.x=ev.d.dx; ev.d.car.y=ev.d.dy; p.x=ev.d.dx+100; p.y=ev.d.dy; runOut(ev); car=ev.d.car;
       if(ev.ph==='live') return 'SKIP: staging: the convoy for the race did not end';
       hit=same('TWO C carrier arrived in view, gone before the word',/^CONVOY ARRIVED\|/,function(){ var q=G.ents.indexOf(car); if(q>=0) G.ents.splice(q,1); }); if(hit) return hit;
       if(has(L.p2,/^CONVOY (AWAY|DOWN)\|/)) bad.push('TWO C: the host said CONVOY ARRIVED and player 2 window said '+has(L.p2,/^CONVOY (AWAY|DOWN)\|/));
       p.x=px; p.y=py; clear();
       // THREE: the convoy runs out of time: nothing is said on either window
       ev=goLive('convoy'); if(!ev||!ev.d.car) return 'SKIP: staging: the third convoy did not go live';
       L={host:[],p2:[]};
       ev.lt=ev.dur; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the convoy did not time out';
       sendTake(); sendTake();
       if(has(L.host,/^CONVOY (DOWN|AWAY)\|/)) return 'SKIP: staging: the host said an end line on a timeout ('+JSON.stringify(L.host)+')';
       if(has(L.p2,/^CONVOY (DOWN|AWAY)\|/)) bad.push('THREE: the convoy timed out, the host said nothing and player 2 window said '+has(L.p2,/^CONVOY (DOWN|AWAY)\|/));
       clear();
       // the Overseer: the raid one, or a stand-in made here and taken out after
       oBc=CFG.boss; if(CFG.boss===0) CFG.boss=1;
       oBoss=G.bossRef; b=G.bossRef;
       if(!b||!(b.hp>0)||G.ents.indexOf(b)<0){ b=mkCrawler(p.x+400,p.y); b.hp=b.maxhp=500; b.lairX=b.x; b.lairY=b.y; g.ents.push(b); G.bossRef=b; mine=b; }
       bk={hp:b.hp,spd:b.spd,lairX:b.lairX,lairY:b.lairY,rmp:b.rmp,x:b.x,y:b.y,tx:b.tx,ty:b.ty,seenYou:b.seenYou}; b.rmp=0;
       // FOUR: the rampage runs out with the Overseer alive
       ev=goLive('rampage'); if(!ev||ev.d.b!==b) return 'SKIP: staging: the rampage did not go live';
       L={host:[],p2:[]};
       ev.lt=ev.dur; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the rampage did not run out';
       hit=same('FOUR rampage ran out',/^OVERSEER RETURNS\|/); if(hit) return hit;
       clear(); b.rmp=0; b.hp=bk.hp;
       // FOUR B: the rampage runs out with the Overseer alive, and he dies before the next world word: player 2 still says what the host said
       ev=goLive('rampage'); if(!ev||ev.d.b!==b) return 'SKIP: staging: the rampage for the race did not go live';
       L={host:[],p2:[]};
       ev.lt=ev.dur; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the rampage for the race did not run out';
       hit=same('FOUR B rampage ran out, Overseer dead before the word',/^OVERSEER RETURNS\|/,function(){ b.hp=0; }); if(hit) return hit;
       clear(); b.rmp=0; b.hp=bk.hp;
       // FIVE: the Overseer is killed during the rampage: no RETURNS on either window
       ev=goLive('rampage'); if(!ev||ev.d.b!==b) return 'SKIP: staging: the second rampage did not go live';
       L={host:[],p2:[]};
       b.hp=0; runOut(ev);
       if(ev.ph==='live') return 'SKIP: staging: the rampage did not end when the Overseer died';
       sendTake(); sendTake();
       if(has(L.host,/^OVERSEER RETURNS\|/)) return 'SKIP: staging: the host said RETURNS for a dead Overseer';
       if(has(L.p2,/^OVERSEER RETURNS\|/)) bad.push('FIVE: the Overseer was killed and player 2 window still said OVERSEER RETURNS');
       return bad.length?bad.join(' / '):null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       netSendFast=oSF; netSend=oS; netBroadcast=oB; say=oSay;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(g&&HF){ g.flow=HF; if(HF.ev) HF.ev.live=[]; } }catch(_g){}
       try{ if(b&&b!==mine) for(k in bk) b[k]=bk[k]; }catch(_b){}
       if(p&&staged){ p.x=px; p.y=py; }
       try{ if(mine){ k=G.ents.indexOf(mine); if(k>=0) G.ents.splice(k,1); G.bossRef=oBoss; } }catch(_m){}
       if(oBc!==undefined) CFG.boss=oBc;
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
