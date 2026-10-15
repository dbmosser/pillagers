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

if ($s.Contains("  {v:'27.07',what:")) { throw "check 27.07 is in the fixture already" }

SubRx @'
  {v:'27.06',what:
'@ @'
  {v:'27.07',what:'coop2, the two player first: a linked player 2 window takes the host raid events from the world word and plans none of its own: the ring and its phase come over, a piece of debris that lands on player 2 hurts him in his own window, and a coolant rupture shortens his sight inside the ring and not outside it',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function') return 'SKIP: no arcade, party or events in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, sent=[], w=null, ev=null, E, i, hp0, oIv, oSh, oAr, h={seat:0,state:'in'}, staged=false, pt=null, v1, v0, HE=null, PE={plan:null,live:[],n:0,wrecks:[]};
     function word(){ var q, r=null; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd'){ r=sent[q]; break; } return r; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; g.flow.ev=HE; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; g.flow.ev=PE; }
     function sendTake(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); return w; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0;
       HE=evS(); HE.plan=[]; HE.live=[];
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       asHost();
       // ONE: the host launches an orbital debris event; player 2 has its ring, in its warning phase
       ev=evLaunch('debris');
       if(!ev) return 'SKIP: staging: the debris event found no ground';
       sendTake();
       if(!w||!w.fl||!w.fl.e||w.fl.e.length!==1) bad.push('ONE: the host world word does not carry the event (fl '+JSON.stringify(w&&w.fl)+')');
       E=PE;
       if(E.live.length!==1) bad.push('ONE: player 2 has '+E.live.length+' events after the host word, not 1');
       else if(E.live[0].id!=='debris'||E.live[0].ph!=='warn'||Math.hypot(E.live[0].x-ev.x,E.live[0].y-ev.y)>1.5||Math.abs(E.live[0].r-ev.r)>0.6) bad.push('ONE: the event player 2 has is '+E.live[0].id+' '+E.live[0].ph+' at '+Math.round(E.live[0].x)+','+Math.round(E.live[0].y)+' size '+Math.round(E.live[0].r));
       for(i=0;i<5;i++) flowTick(0.1);
       if(PE.plan) bad.push('ONE: the linked window planned events of its own');
       // TWO: the host goes live: pieces come down; player 2 has them, with a landing time each
       asHost(); ev.t=ev.warn; evTick(0.01);
       if(ev.ph!=='live'||!ev.d.pts||!ev.d.pts.length) return 'SKIP: staging: the host event did not go live';
       sendTake();
       E=PE;
       if(E.live.length!==1||E.live[0].ph!=='live') bad.push('TWO: player 2 event did not go live ('+(E.live[0]&&E.live[0].ph)+')');
       else if(!E.live[0].d.pts||E.live[0].d.pts.length!==ev.d.pts.length) bad.push('TWO: player 2 has '+((E.live[0].d.pts||[]).length)+' pieces of debris, the host has '+ev.d.pts.length);
       // THREE: a piece lands on player 2: he is hurt, in his own window
       if(E.live.length&&E.live[0].d.pts&&E.live[0].d.pts.length){
         pt=E.live[0].d.pts[0];
         p.x=pt.x+66; p.y=pt.y; p.hp=100; p.downed=false; p.dying=0; hp0=p.hp;
         for(i=0;i<60&&p.hp>=hp0&&E.live[0].lt<pt.at+3;i++) flowTick(0.1);
         if(!(p.hp<hp0)) bad.push('THREE: a piece of debris landed 66 from player 2 and he took no damage (hp '+hp0+' to '+p.hp+')');
       }
       // FOUR: a coolant rupture shortens player 2 sight inside the ring and not outside it
       HE.live=[]; PE.live=[]; asHost();
       ev=evLaunch('cool');
       if(!ev) return 'SKIP: staging: the coolant event found no ground';
       ev.t=ev.warn; evTick(0.01);
       sendTake();
       E=PE;
       if(E.live.length!==1||E.live[0].id!=='cool'||E.live[0].ph!=='live') bad.push('FOUR: player 2 has no live coolant rupture');
       else {
         p.x=E.live[0].x; p.y=E.live[0].y; v1=flowVis();
         p.x=E.live[0].x+E.live[0].r+500; v0=flowVis();
         if(!(v1<0.99)) bad.push('FOUR: player 2 in the middle of the rupture sees at '+v1.toFixed(2)+' of the full range');
         if(!(v0>0.999)) bad.push('FOUR: player 2 well outside the rupture sees at '+v0.toFixed(2)+' of the full range');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&HE) g.flow.ev=HE; }catch(_ev){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
