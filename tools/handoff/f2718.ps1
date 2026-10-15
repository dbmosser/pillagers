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

if ($s.Contains("  {v:'27.18',what:")) { throw "check 27.18 is in the fixture already" }

SubRx @'
  {v:'27.17',what:
'@ @'
  {v:'27.18',what:'coop5, the two player first: a linked player 2 window takes the golden enemy and its clue hunt from the world word and gilds and lays out nothing of its own: it has the host golden body, the three props and the search circle, taking a clue in his window tells the host and shrinks the circle for both, and the fall of the golden enemy is said to him',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof goldTick!=='function'||typeof clueTick!=='function'||typeof netEntsInit!=='function') return 'SKIP: no arcade, party or golden enemy in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, sent=[], posted=[], w=null, i, j, n, oIv, oSh, oAr, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, HG=null, HC=null, PGld, PClu, p0=null, lines=[], rs=say, own=false, C2, c0, c1, ref=null;
     function word(){ var q, r=null; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd'){ r=sent[q]; break; } return r; }
     function asHost(){ if(NET.role==='join'){ PGld=g.flow.gold; PClu=g.flow.clue; } NET.role='host'; NET.seat=0; NET.peers=[hp]; g.flow.gold=HG; g.flow.clue=HC; }
     function asTwo(){ if(NET.role==='host'){ HG=g.flow.gold; HC=g.flow.clue; } NET.role='join'; NET.seat=1; NET.peers=[h]; if(PGld) g.flow.gold=PGld; else delete g.flow.gold; if(PClu) g.flow.clue=PClu; else delete g.flow.clue; }
     function sendTake(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); return w; }
     function golds(){ var q, c=0; for(q=0;q<g.ents.length;q++) if(g.ents[q]&&g.ents[q].golden) c++; return c; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0; p0={x:p.x,y:p.y};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0; NET.role='host'; NET.seat=0; NET.peers=[hp];
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ posted.push(JSON.parse(JSON.stringify(m))); return true; };
       g.t=4.5; flowTick(0.1); flowTick(0.1);
       HG=g.flow.gold; HC=g.flow.clue;
       if(!HG||!HG.ref) return 'SKIP: staging: the raid gilded no machine';
       if(!HC||!HC.props||HC.props.length<3) return 'SKIP: staging: the raid laid out no clue hunt';
       ref=HG.ref; netEntsInit(g);
       // ONE: the host word names the golden body and the hunt, and player 2 has them
       sendTake();
       if(!w||!w.fl||!w.fl.g||!w.fl.c) bad.push('ONE: the host world word does not carry the golden enemy and the hunt (fl '+JSON.stringify(w&&w.fl&&Object.keys(w.fl))+')');
       p.x=p0.x+2400; p.y=p0.y+1900;
       for(i=0;i<3;i++) flowTick(0.1);
       if(!g.flow.gold||g.flow.gold.ref!==ref) bad.push('ONE: player 2 does not have the host golden enemy');
       if(golds()!==1) bad.push('ONE: '+golds()+' machines are gilded, not 1');
       C2=g.flow.clue;
       if(!C2||!C2.props||C2.props.length!==3) bad.push('ONE: player 2 has '+(C2&&C2.props?C2.props.length:'no')+' clue props, not 3');
       else {
         for(i=0;i<3;i++) if(Math.hypot(C2.props[i].x-HC.props[i].x,C2.props[i].y-HC.props[i].y)>1.5) bad.push('ONE: clue prop '+i+' is not where the host has it');
         c0=clueCircle(C2);
         if(Math.abs(c0.x-clueCircle(HC).x)>1.5||Math.abs(c0.r-1400)>1) bad.push('ONE: the search circle player 2 has is not the host one ('+Math.round(c0.r)+')');
       }
       // TWO: player 2 takes a clue in his window: said at once, told to the host, and the circle shrinks for both
       if(C2&&C2.props&&C2.props.length===3){
         lines.length=0; posted.length=0;
         p.x=C2.props[0].x; p.y=C2.props[0].y;
         flowTick(0.1);
         if(!C2.props[0].got) bad.push('TWO: player 2 walked onto a clue and did not take it');
         if(!lines.some(function(m){ return /^CLUE 1\/3/.test(m); })) bad.push('TWO: player 2 was not told CLUE 1/3 ('+lines.join(' / ')+')');
         if(!posted.some(function(m){ return m.t==='fl'&&m.k==='clue'&&m.i===0; })) bad.push('TWO: player 2 took a clue and told the host nothing');
         else {
           asHost(); p.x=p0.x; p.y=p0.y;
           for(i=0;i<posted.length;i++) netOnMsg(hp,JSON.stringify(posted[i]));
           if(!HC.props[0].got||HC.n!==1) bad.push('TWO: the host did not mark the clue player 2 took (got '+HC.props[0].got+', n '+HC.n+')');
           sendTake();
           c1=clueCircle(C2);
           if(!(c1.r<c0.r-1)) bad.push('TWO: the search circle did not shrink for player 2 ('+Math.round(c0.r)+' to '+Math.round(c1.r)+')');
         }
       }
       // THREE: the golden enemy falls on the host: player 2 has it down, is told, and the hunt is over
       asHost(); HG.ref.hp=0; p.x=p0.x; p.y=p0.y; flowTick(0.1);
       if(!HG.dead) return 'SKIP: staging: the host did not see the golden enemy fall';
       lines.length=0; sendTake();
       if(!g.flow.gold||!g.flow.gold.dead) bad.push('THREE: the golden enemy fell on the host and not for player 2');
       if(!lines.some(function(m){ return /^GOLDEN ENEMY DOWN/.test(m); })) bad.push('THREE: player 2 was not told GOLDEN ENEMY DOWN ('+lines.join(' / ')+')');
       if(g.flow.clue&&!g.flow.clue.done) bad.push('THREE: the hunt is not over for player 2');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) say=rs;
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&HG){ g.flow.gold=HG; g.flow.clue=HC; } }catch(_sh){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
