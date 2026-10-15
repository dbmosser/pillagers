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

if ($s.Contains("  {v:'27.12',what:")) { throw "check 27.12 is in the fixture already" }

SubRx @'
  {v:'27.11',what:
'@ @'
  {v:'27.12',what:'coop4, the two player first: a linked player 2 window takes the host strongholds from the world word and builds none of its own: the compound is where the host has it, a fence to player 2 from the side he stands on, the gate opens when player 2 stands at it (his word to the host fills the breach), and the open gate and the clear come over',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof shTick!=='function'||typeof shKeep!=='function') return 'SKIP: no arcade, party or strongholds in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, sent=[], posted=[], w=null, s=null, s2=null, i, j, a, ok, d, n0, oIv, oSh, oAr, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, HS=null, PS={sites:null}, p0=null, lines=[], rs=say, own=false, gp;
     function word(){ var q, r=null; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd'){ r=sent[q]; break; } return r; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[hp]; g.flow.sh=HS; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; g.flow.sh=PS; }
     function sendTake(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); return w; }
     function at(q,ang,off){ p.x=q.x+Math.cos(ang)*(q.r+off); p.y=q.y+Math.sin(ang)*(q.r+off); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0; p0={x:p.x,y:p.y};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ posted.push(JSON.parse(JSON.stringify(m))); return true; };
       HS=shS(); asHost();
       g.t=4; flowTick(0.1);
       if(!HS.sites||!HS.sites.length) return 'SKIP: staging: the raid laid out no stronghold';
       s=HS.sites[0];
       // ONE: the host word carries the compounds, player 2 has them where the host does, and builds none
       sendTake();
       if(!w||!w.fl||!w.fl.s||w.fl.s.length!==HS.sites.length) bad.push('ONE: the host world word does not carry the strongholds (fl.s '+JSON.stringify(w&&w.fl&&w.fl.s)+')');
       n0=g.ents.length;
       for(i=0;i<3;i++) flowTick(0.1);
       if(g.ents.length!==n0) bad.push('ONE: the linked window made '+(g.ents.length-n0)+' bodies of its own');
       if(!PS.sites||PS.sites.length!==HS.sites.length) bad.push('ONE: player 2 has '+(PS.sites?PS.sites.length:'no')+' strongholds, the host has '+HS.sites.length);
       else if(Math.hypot(PS.sites[0].x-s.x,PS.sites[0].y-s.y)>1.5||Math.abs(PS.sites[0].ga-s.ga)>0.01) bad.push('ONE: the compound player 2 has is not where the host has it');
       // TWO: the fence: player 2 outside is kept outside
       s2=PS.sites&&PS.sites[0];
       if(s2){
         a=null;
         for(j=0;j<24&&a===null;j++){
           d=s2.ga+Math.PI+(j%2?1:-1)*Math.floor((j+1)/2)*0.2618;
           if(Math.abs(angDiff(d,s2.ga))>s2.gw+0.4&&spotFree(g.map,s2.x+Math.cos(d)*(s2.r+17),s2.y+Math.sin(d)*(s2.r+17),8)&&spotFree(g.map,s2.x+Math.cos(d)*(s2.r-17),s2.y+Math.sin(d)*(s2.r-17),8)&&spotFree(g.map,s2.x+Math.cos(d)*(s2.r+80),s2.y+Math.sin(d)*(s2.r+80),8)) a=d;
         }
         if(a===null) return 'SKIP: staging: no open ground on the fence of the compound';
         p.shS=[0,0,0]; at(s2,a,80);
         for(i=0;i<2;i++) flowTick(0.1);
         p.x=s2.x+Math.cos(a)*(s2.r-80); p.y=s2.y+Math.sin(a)*(s2.r-80);
         for(i=0;i<3;i++) flowTick(0.1);
         d=Math.hypot(p.x-s2.x,p.y-s2.y);
         if(d<s2.r-0.5) bad.push('TWO: the fence did not hold player 2 out: he stands '+Math.round(s2.r-d)+' inside a compound of '+s2.r);
         // THREE: the gate: player 2 stands at it from outside, tells the host, and the host opens it with its own player far away
         p.shS=[0,0,0]; gp=shGatePt(s2);
         p.x=gp.x+Math.cos(s2.ga)*40; p.y=gp.y+Math.sin(s2.ga)*40;
         posted.length=0; flowTick(0.25);
         if(!posted.some(function(m){ return m.t==='fl'&&m.k==='gate'&&m.i===s2.i; })) bad.push('THREE: player 2 stood at the gate and told the host nothing ('+JSON.stringify(posted.slice(0,2))+')');
         else {
           for(j=0;j<18&&!s.open;j++){
             asTwo(); g.t+=0.3; p.x=gp.x+Math.cos(s2.ga)*40; p.y=gp.y+Math.sin(s2.ga)*40; posted.length=0; flowTick(0.25);
             asHost(); p.x=p0.x; p.y=p0.y; p.shS=[0,0,0];
             for(i=0;i<posted.length;i++) netOnMsg(hp,JSON.stringify(posted[i]));
             flowTick(0.25);
           }
           if(!s.open) bad.push('THREE: the host gate stayed shut after 4.5 s of player 2 at it (breach '+s.prog.toFixed(2)+')');
           else {
             lines.length=0; sendTake();
             if(!s2.open) bad.push('THREE: the gate is open on the host and shut for player 2');
             if(!lines.some(function(m){ return /^GATE BREACHED/.test(m); })) bad.push('THREE: player 2 was not told GATE BREACHED ('+lines.join(' / ')+')');
           }
         }
         // FOUR: cleared on the host, cleared for player 2 and said
         s.clear=1; lines.length=0; sendTake();
         if(!s2.clear) bad.push('FOUR: the stronghold is cleared on the host and not for player 2');
         if(!lines.some(function(m){ return /^STRONGHOLD CLEARED/.test(m); })) bad.push('FOUR: player 2 was not told STRONGHOLD CLEARED ('+lines.join(' / ')+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) say=rs;
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&HS) g.flow.sh=HS; }catch(_sh){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
