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

if ($s.Contains("  {v:'20.30',what:")) { throw "check 20.30 is in the fixture already" }

SubRx @'
  {v:'20.29',what:
'@ @'
  {v:'20.30',what:'when the host leaves, every box holds what the host last said: a box part searched gives nothing twice, a box the host searched holds what he left, and a pile or restocked box the host made keeps its items',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netHostGone!=='function'||typeof netContWord!=='function'||typeof netLootTake!=='function') return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oSwf=sayWhenFree, oSay=say, oBc=netBroadcast, words=[], i, q, A=null, B=null, C=null, D, a0, b0, c0, peer={seat:0,state:'in'}, cid, lw, r;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       sayWhenFree=function(){}; say=function(){};
       for(i=0;i<G.containers.length;i++){ q=G.containers[i]; if(q.opened||!q.loot||q.loot.length<3) continue; if(!A) A=q; else if(!B) B=q; else { C=q; break; } }
       if(!A||!B||!C) return 'SKIP: staging: no three full boxes';
       a0=A.loot.slice(); b0=B.loot.slice(); c0=C.loot.slice();
       netBroadcast=function(w){ words.push(JSON.parse(JSON.stringify(w))); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[]; NET.upSeed=G.seed>>>0;
       netContInit(G); netContTick(); words=[];
       A.loot.shift(); A.pulled=1; netContTick();
       lw=words.filter(function(w){ return w.cid===A.cid&&w.st==='left'; })[0];
       if(!lw) bad.push('the host told nobody that a box was part searched ('+words.length+' words)');
       else if(!(lw.lk&&lw.lk.length===a0.length-1&&lw.pl===1)) bad.push('the host word reads '+JSON.stringify(lw));
       A.loot=a0.slice(); A.pulled=0;
       netBroadcast=oBc;
       NET.role='join'; NET.seat=1; NET.peers=[peer];
       netContInit(G);
       r=netLootTake(peer,{t:'loot',cid:A.cid,items:a0.slice(0,2)});
       netContWord(peer,{t:'cont',st:'left',cid:B.cid,lk:b0.slice(1),pl:1});
       cid=NET.contN;
       netContWord(peer,{t:'cont',st:'new',cid:cid,x:Math.round(G.player.x+40),y:Math.round(G.player.y),ty:'pile',tm:1,d:-1,dr:1,op:0,n:1,lk:[c0[0]],pl:0});
       C.opened=true; netContWord(peer,{t:'cont',st:'shut',cid:C.cid,lk:c0.slice(0,2),pl:0});
       netHostGone('lost');
       if(!G||G.over) return 'the raid ended when the host left';
       if(A.loot.length!==a0.length-2||(A.pulled|0)!==2) bad.push('a box that handed this window 2 of its '+a0.length+' items now holds '+A.loot.length+' with '+(A.pulled|0)+' pulled ('+r+')');
       if(B.loot.length!==b0.length-1||B.loot[0]!==b0[1]) bad.push('a box the host took 1 of '+b0.length+' from now holds '+B.loot.length);
       D=netContOf(cid);
       if(!D) bad.push('the pile the host made is unknown here');
       else if(!(D.loot&&D.loot.length===1&&D.loot[0]===c0[0])) bad.push('the pile the host made holds '+JSON.stringify(D.loot));
       if(C.opened||!(C.loot&&C.loot.length===2)) bad.push('a box the host restocked holds '+JSON.stringify(C.loot));
       if(A.net) bad.push('the bar still reads the host count');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netBroadcast=oBc; sayWhenFree=oSwf; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
