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

if ($s.Contains("  {v:'23.36',what:")) { throw "check 23.36 is in the fixture already" }

SubRx @'
  {v:'23.35',what:
'@ @'
  {v:'23.36',what:'arcmidfixa, review of arcade builds 7 to 13: in the arcade an Overseer that player 2 kills scores 2,000 on the player 2 window (its mirror body carries only the name), as it does on the host, and a plain warden still scores 400',
   run:function(){
     if(typeof netKillTake!=='function'||typeof netEntMake!=='function'||typeof netEntsPeer!=='function'||typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof BOSS_NAME!=='string') return 'no arcade kill word in this build';
     var keep={}, k, oSend=netSend, oRef=netRefresh, oSay=say, oSWF=sayWhenFree, oSave=saveProfile, oCK=contractKill,
         bad=[], g=null, r, m0, eB, eW, peer={state:'in',seat:0}, deployed=false;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       NET.bc={postMessage:function(){},close:function(){}}; NET.pair='tp';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       deployed=true; g=G;
       if(!g||!g.arcade||!g.player||!g.tel||!g.tel.kills) return 'SKIP: staging: no live arcade raid';
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; sayWhenFree=function(){}; saveProfile=function(){}; contractKill=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[peer]; NET.up=[]; NET.entMap={}; NET.entDead={};
       eB=netEntMake(778801,'warden',g.player.x+400,g.player.y); eB.name=BOSS_NAME; eB.hp=0; NET.entMap[778801]=eB;
       eW=netEntMake(778802,'warden',g.player.x+500,g.player.y); eW.name=''; eW.hp=0; NET.entMap[778802]=eW;
       if(eB.boss) return 'SKIP: staging: this build mirror already carries boss';
       m0=ARCADE.mine|0;
       r=netKillTake(peer,{t:'kill',seat:1,id:778801,k:'warden',el:0});
       if(r!=='kill') return 'SKIP: staging: the kill word answered '+r;
       if((ARCADE.mine|0)-m0!==2000) bad.push('player 2 killing THE OVERSEER scored '+((ARCADE.mine|0)-m0)+', not 2000');
       m0=ARCADE.mine|0;
       r=netKillTake(peer,{t:'kill',seat:1,id:778802,k:'warden',el:0});
       if((ARCADE.mine|0)-m0!==400) bad.push('player 2 killing a plain warden scored '+((ARCADE.mine|0)-m0)+', not 400');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netRefresh=oRef; say=oSay; sayWhenFree=oSWF; saveProfile=oSave; contractKill=oCK;
       try{ NET.on=keep.on; NET.role=keep.role; NET.seat=keep.seat; NET.peers=keep.peers; NET.entMap=keep.entMap; NET.entDead=keep.entDead; }catch(_n0){}
       try{ if(deployed&&ARCADE.on) arcadeLeave(); }catch(_l){}
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
