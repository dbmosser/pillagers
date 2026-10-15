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

if ($s.Contains("  {v:'27.19',what:")) { throw "check 27.19 is in the fixture already" }

SubRx @'
  {v:'27.18',what:
'@ @'
  {v:'27.19',what:'coop6, the two player first: player 2 has his own air strike meter, charged by the damage he sends the host and not by player 1, and a strike called in either window is seen and felt in the other (the rings, the blasts and the shake, with no damage there)',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netOnMsg!=='function'||typeof airCall!=='function'||typeof airScan!=='function'||typeof netShotSend!=='function'||typeof mkCrawler!=='function') return 'SKIP: no arcade, party or air strike in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, posted=[], i, oIv, oSh, oAr, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, HA=null, PA={m:0,aim:0,aimT:0,prev:0,sk:[],used:0,dealt:0,rdy:0}, lines=[], rs=say, own=false, e=null, e2=null, hp0, w;
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[hp]; g.flow.air=HA; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; g.flow.air=PA; }
     function airs(){ return posted.filter(function(m){ return m.t==='fl'&&m.k==='air'; }); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       g.ents=g.ents.filter(function(q){ return !(q&&q.kind!=='peddler'&&q.kind!=='stray'&&dist(q,p)<2200); });
       HA=airS();
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,m){ return true; };
       netSend=function(q,m){ posted.push(JSON.parse(JSON.stringify(m))); return true; };
       e=mkCrawler(p.x+320,p.y); e.hp=e.maxhp=5000; e.nid=4242; g.ents.push(e);
       // ONE: on the host, a round player 2 landed does not charge the host meter, one of the host own does
       asHost(); e.airH=5000; e.hp=4950; e.pHitT=0.3; e.pHitSeat=1; airScan();
       if(HA.m>0) bad.push('ONE: a round of player 2 charged the host air strike meter ('+HA.m+')');
       e.pHitT=0.3; e.pHitSeat=0; e.hp=4900; airScan();
       if(!(HA.m>=49&&HA.m<=51)) bad.push('ONE: a round of the host own did not charge the host meter by its 50 ('+HA.m+')');
       // TWO: player 2 sends the host damage and his own meter fills
       asTwo(); lines.length=0;
       netShotSend(e,40,0,null);
       if(!(PA.m>=39&&PA.m<=41)) bad.push('TWO: 40 damage sent to the host charged player 2 meter to '+PA.m+', not 40');
       e.hp=5000; netShotSend(e,AIR.need,0,null);
       if(!(PA.m>=AIR.need)) bad.push('TWO: player 2 meter is '+PA.m+' of '+AIR.need+' after sending the damage');
       if(!lines.some(function(m){ return /^AIR STRIKE READY/.test(m); })) bad.push('TWO: player 2 was not told AIR STRIKE READY');
       // THREE: player 2 calls a strike: the host sees it come and feels it, and nothing on the host is hurt by it
       e2=mkCrawler(p.x+2000,p.y+2000); e2.hp=e2.maxhp=900; g.ents.push(e2);
       posted.length=0; lines.length=0;
       airCall(e2.x,e2.y);
       w=airs();
       if(w.length!==1) bad.push('THREE: player 2 called a strike and '+w.length+' words went to the host');
       else {
         asHost(); lines.length=0; g.shake=0; hp0=e2.hp;
         netOnMsg(hp,JSON.stringify(w[0]));
         if(!HA.sk.length||!HA.sk[HA.sk.length-1].fx) bad.push('THREE: the host did not get the strike player 2 called');
         if(!lines.some(function(m){ return /^AIR STRIKE INBOUND/.test(m); })) bad.push('THREE: the host was not told AIR STRIKE INBOUND');
         p.x=e2.x; p.y=e2.y; g.shake=0;
         for(i=0;i<30;i++) airTick(0.1);
         if(!(g.shake>0.5)) bad.push('THREE: the host felt no shake from the strike ('+g.shake+')');
         if(e2.hp!==hp0) bad.push('THREE: the strike player 2 called hurt a body in the host window ('+hp0+' to '+e2.hp+')');
       }
       // FOUR: the host calls one: player 2 sees it come and feels it
       asHost(); HA.m=AIR.need; posted.length=0; p.x=e2.x; p.y=e2.y;
       airCall(e2.x,e2.y);
       w=airs();
       if(w.length!==1) bad.push('FOUR: the host called a strike and '+w.length+' words went to player 2');
       else {
         asTwo(); lines.length=0; g.shake=0; PA.sk=[];
         netOnMsg(h,JSON.stringify(w[0]));
         if(!PA.sk.length||!PA.sk[0].fx) bad.push('FOUR: player 2 did not get the strike the host called');
         if(!lines.some(function(m){ return /^AIR STRIKE INBOUND/.test(m); })) bad.push('FOUR: player 2 was not told AIR STRIKE INBOUND');
         for(i=0;i<30;i++) airTick(0.1);
         if(!(g.shake>0.5)) bad.push('FOUR: player 2 felt no shake from the strike ('+g.shake+')');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&HA) g.flow.air=HA; }catch(_sh){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
