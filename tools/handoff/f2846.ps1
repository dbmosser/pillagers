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

if ($s.Contains("  {v:'28.46',what:")) { throw "check 28.46 is in the fixture already" }

SubRx @'
  {v:'28.45',what:
'@ @'
  {v:'28.46',what:'cloud-coop-takeover-no-replay: when the host leaves and player 2 picks up the raid, the fuel fires, raid events and RUN GOALS the host already ran do not come back, a fire the host has yet to light lights where and when the host planned it, and an event the host held behind a live one still comes once',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof netHostGone!=='function'||typeof flowTick!=='function'||typeof evS!=='function') return 'SKIP: no arcade, party or raid flow in this fixture';
     var bad=[], NK={}, k, oSF=netSendFast, oS=netSend, rs=say, own=false, staged=false, sent=[], lines=[], h={seat:0,state:'in'}, hp={seat:1,state:'in'}, g=null, p=null, oIv=0, HF, PF, i, r;
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.upSeed=g.seed>>>0; g.flow=HF; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; }
     function sendTake(){ var w; sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); (PF.fires||[]).forEach(function(f){ f.told=1; }); }   // player 2 window said each fire the frame it came
     function netBack(){ var q; if(!staged) return; for(q in NET) if(!(q in NK)) delete NET[q]; for(q in NK) NET[q]=NK[q]; }
     function endIt(){
       netBack();
       if(p) p.iv=oIv;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); g=null; p=null;
     }
     // a staged pair: the host runs the raid flow to hostT and player 2 takes its world words, then (before) runs, the host is gone,
     // and player 2 runs the flow himself to endT; returns what was said and launched after the takeover, or a string
     function pair(seed,hostT,before,endT){
       var o={}, i, n0, E;
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:seed})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       HF=g.flow||{}; PF={}; asHost();
       for(i=0;g.t<hostT&&i<4000;i++){ g.t+=0.5; flowTick(0.5); if(p.hp<50) p.hp=p.maxhp||100; if(i%4===0) sendTake(); asHost(); }
       sendTake();
       o.H=HF; o.HE=HF.ev||{plan:[],n:0,live:[]};
       if(before) before(o);
       lines.length=0; asTwo();
       if(!netHostGone('out')) return 'the takeover did not happen (netHostGone false)';
       E=evS(); n0=E.n|0; o.fires0=(PF.fires||[]).length; o.launched=[];
       for(i=0;g.t<endT&&i<4000;i++){ g.t+=0.25; flowTick(0.25); if(p.hp<50) p.hp=p.maxhp||100; while((E.n|0)>n0){ o.launched.push(E.live.length?E.live[E.live.length-1].id:'?'); n0++; } }
       o.lines=lines.slice(); o.P=PF; o.E=E;
       return o;
     }
     try{
       __topClear();
       for(k in NET) NK[k]=NET[k];
       staged=true;
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       // ONE: the host ran both fuel fires and its raid events and said RUN GOALS; 10 s on the new host bring none of it back
       r=pair(9071,440,null,450);
       if(typeof r==='string') return (/^SKIP/).test(r)?r:'ONE: '+r;
       if(!r.HE.n) bad.push('ONE staging: the host launched no raid event by 440 s');
       else if(!r.H.fplan||!r.H.fplan.some(function(f){ return f.on; })) bad.push('ONE staging: the host lit no fuel fire by 440 s');
       else if(!r.H.gtold) bad.push('ONE staging: the host never said RUN GOALS');
       else {
         r.lines.forEach(function(m){
           if((/^FUEL FIRE/).test(m)) bad.push('ONE: a fuel fire the host already lit came back: '+m);
           if((/^RUN GOALS/).test(m)) bad.push('ONE: RUN GOALS was said again: '+m);
         });
         r.launched.forEach(function(id){ for(var q=0;q<(r.HE.n|0)&&q<r.HE.plan.length;q++) if(r.HE.plan[q].id===id) bad.push('ONE: the new host launched '+id+' again, the host ran it at '+Math.round(r.HE.plan[q].at)+' s'); });
         for(i=0;r.E.plan&&i<r.E.plan.length&&i<(r.HE.n|0);i++) if(!r.E.plan[i].on) bad.push('ONE: the raid event '+r.E.plan[i].id+' the host ran waits to launch again on the new host');
       }
       endIt();
       // TWO: the host lit its first fuel fire; player 2, far from the drop, picks up the raid before the second: it lights where and when the host planned it, and once
       r=pair(9071,195,function(o){ var sp=g.spawnDbg&&g.spawnDbg.pt; o.hp2=o.H.fplan&&o.H.fplan[1]; o.lit=(o.H.fires||[]).length; if(sp){ p.x=Math.min(WORLD_W-200,sp.x+1200); p.y=sp.y; } },215);
       if(typeof r==='string') return (/^SKIP/).test(r)?r:'TWO: '+r;
       if(!r.H.fplan||r.H.fplan.length<2||!r.H.fplan[1].on||!(r.H.fplan[1].at<195)) bad.push('TWO staging: the host had not lit its second fuel fire by 195 s ('+JSON.stringify(r.H.fplan)+')');
       else {
         r.lines.forEach(function(m){ if((/^FUEL FIRE/).test(m)) bad.push('TWO: a fuel fire lit on the new host that the host did not plan then: '+m); });
         if((r.P.fires||[]).length>r.fires0) bad.push('TWO: the new host lit '+((r.P.fires||[]).length-r.fires0)+' new fuel fire(s) between 195 and 215 s');
       }
       endIt();
       // THREE: the host has the convoy live and the bounty held behind it: the new host launches the bounty exactly once
       r=pair(5008,365,null,460);
       if(typeof r==='string') return (/^SKIP/).test(r)?r:'THREE: '+r;
       if(!r.HE.plan||r.HE.plan.length<2||!r.HE.plan[0].on||r.HE.plan[1].on||!(r.HE.plan[1].at<=365)||!r.HE.live.some(function(v){ return v.ph!=='end'; })) bad.push('THREE staging: no event held behind a live one at 365 s ('+JSON.stringify(r.HE.plan)+')');
       else if(r.launched.length!==1||r.launched[0]!==r.HE.plan[1].id) bad.push('THREE: the new host launched ['+r.launched.join(', ')+'], not the held '+r.HE.plan[1].id+' once');
       endIt();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSendFast=oSF; netSend=oS; if(own) say=rs;
       try{ endIt(); }catch(_x){}
       netBack();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'28.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
