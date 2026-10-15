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

if ($s.Contains("  {v:'28.39',what:")) { throw "check 28.39 is in the fixture already" }

SubRx @'
  {v:'28.38',what:
'@ @'
  {v:'28.39',what:'cloud-coop-pillager-gun-sync: a pillager who takes a better gun on the host holds the same gun and plays the same role in player 2 window, late join included, and nothing else about him resets',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netOnMsg!=='function'||typeof netEntsTick!=='function'||typeof netEntsInit!=='function'||typeof netLateReply!=='function'||typeof raiderRole!=='function'||typeof updateEnts!=='function') return 'SKIP: no arcade or party in this fixture';
     var g=null, NK={}, k, oSF=netSendFast, oS=netSend, oB=netBroadcast, oSay=say, sent=[], late=[], h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false;
     var host={}, swapped=[], i, e, n0, b, w, lw, before, msg=null;
     function cap(a){ return function(q,m){ if(m===undefined){ m=q; } a.push(JSON.parse(JSON.stringify(m))); return true; }; }
     function deploy(){ __topClear(); __runPrep(); if(ARCADE.on) return null; if(!arcadeDeploy({mapIx:1,seed:1077})) return null; var q=__state(); return (q&&!q.over&&q.player)?q:null; }
     function leave(){ try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} }
     try{
       g=deploy(); if(!g) return 'SKIP: arcadeDeploy built no arcade raid';
       g.player.iv=999; g.player.armor=0;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0; NET.role='host'; NET.seat=0; NET.peers=[hp];
       netSendFast=function(){ return true; }; netSend=cap(sent); netBroadcast=function(m){ sent.push(JSON.parse(JSON.stringify(m))); return 1; }; say=function(){};
       netEntsInit(g);
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(e.kind==='raider') host[e.nid]={w:e.wep&&e.wep.id}; }
       for(i=0;i<10;i++){ updateEnts(0.05); netEntsTick(); }
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(e.kind!=='raider'||!host[e.nid]) continue; if(host[e.nid].w!==(e.wep&&e.wep.id)) swapped.push(e.nid); host[e.nid].w=e.wep&&e.wep.id; host[e.nid].role=raiderRole(e); }
       if(!swapped.length) return 'SKIP: no pillager took a better gun in the first half second on this seed';
       NET.upWord={t:'raid',seed:g.seed>>>0}; NET.lateOut={}; netSend=cap(late);
       netLateReply(hp);
       netSend=cap(sent);
       leave();
       g=deploy(); if(!g) return 'SKIP: the same seed built no second raid';
       NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; NET.specG=null;
       netEntsInit(g);
       n0=g.ents.length; before={};
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(e.kind==='raider') before[e.nid]={x:e.x,y:e.y,hp:e.hp,st:e.state,hair:e.hair,skin:e.skin,nm:e.name,el:e.elite}; }
       for(i=0;i<sent.length;i++) if(sent[i]&&sent[i].t==='ent') netOnMsg(h,JSON.stringify(sent[i]));
       if(g.ents.length!==n0) return 'player 2 window has '+g.ents.length+' bodies after the gun words, '+n0+' before';
       for(i=0;i<swapped.length;i++){
         e=NET.entMap[swapped[i]]; b=before[swapped[i]];
         if(!e||!b) return 'player 2 window lost pillager '+swapped[i];
         if((e.wep&&e.wep.id)!==host[swapped[i]].w) return 'pillager '+e.name+' holds a '+host[swapped[i]].w+' on the host but a '+(e.wep&&e.wep.id)+' in player 2 window';
         if(raiderRole(e)!==host[swapped[i]].role) return 'pillager '+e.name+' plays '+host[swapped[i]].role+' on the host but '+raiderRole(e)+' in player 2 window';
         if(e.x!==b.x||e.y!==b.y||Math.abs(e.hp-b.hp)>(e.maxhp||100)/20+1||e.state!==b.st||e.hair!==b.hair||e.skin!==b.skin||e.name!==b.nm||!e.elite!==!b.el) return 'the gun word reset pillager '+b.nm+' in player 2 window: '+JSON.stringify([e.x,b.x,e.y,b.y,e.hp,b.hp,e.state,b.st,e.hair,b.hair,e.skin,b.skin,e.name,b.nm,e.elite,b.el]);
       }
       for(i=0;i<swapped.length;i++){
         lw=null; for(k=0;k<late.length;k++) if(late[k]&&late[k].t==='ent'&&late[k].op==='new'&&late[k].id===swapped[i]) lw=late[k];
         if(!lw||lw.w!==host[swapped[i]].w) return 'a late joining player 2 is never told pillager '+swapped[i]+' holds a '+host[swapped[i]].w;
         if(lw.idn!==undefined) return 'the late gun word would re-roll his look';
       }
       return null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       netSendFast=oSF; netSend=oS; netBroadcast=oB; say=oSay;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       leave();
       __topClear();
     }
   }},
  {v:'28.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
