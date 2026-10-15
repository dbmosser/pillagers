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

if ($s.Contains("  {v:'27.34',what:")) { throw "check 27.34 is in the fixture already" }

SubRx @'
  {v:'27.33',what:
'@ @'
  {v:'27.34',what:'career10, cloud review finding 24: a kill word that player 2 takes counts for the gun his last round came from (his tally is banked at the end of his raid) and the Overseer kill earns OVERSEER DOWN on his save',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof gunKillNote!=='function'||typeof trophyKill!=='function') return 'there is no gun tally or trophy case in this build';
     if(typeof netKillTake!=='function'||typeof netEntMake!=='function'||typeof netEntsPeer!=='function'||typeof BOSS_NAME!=='string') return 'SKIP: no kill word in this build';
     var keep={}, k, oSend=netSend, oRef=netRefresh, oSay=say, oSWF=sayWhenFree, oSave=saveProfile, oCK=contractKill, bad=[], g=null, r, eB, eC, peer={state:'in',seat:0}, snap=null, q, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, deployed=false;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.gunKills={}; delete q.trophies;
       NET.bc={postMessage:function(){},close:function(){}}; NET.pair='tp';
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       deployed=true; g=G;
       if(!g||g.over||!g.player||!g.tel||!g.tel.kills) return 'SKIP: staging: no live raid';
       if(!g.career) return 'SKIP: staging: no CAREER raid in this build';
       netSend=function(){ return true; }; netRefresh=function(){}; say=function(){}; sayWhenFree=function(){}; saveProfile=function(){}; contractKill=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[peer]; NET.up=[]; NET.entMap={}; NET.entDead={};
       eB=netEntMake(778811,'warden',g.player.x+400,g.player.y); eB.name=BOSS_NAME; eB.hp=0; eB.blow='g'; eB.blowG='rifle'; NET.entMap[778811]=eB;
       eC=netEntMake(778812,'crawler',g.player.x+450,g.player.y); eC.hp=0; eC.blow='g'; eC.blowG='smg'; NET.entMap[778812]=eC;
       r=netKillTake(peer,{t:'kill',seat:1,id:778811,k:'warden',el:0});
       if(r!=='kill') return 'SKIP: staging: the kill word answered '+r;
       if(!(g.gunK&&g.gunK.rifle===1)) bad.push('ONE: player 2 killing with the rifle left the raid tally at '+JSON.stringify(g.gunK));
       if(!(q.trophies&&q.trophies.overseer)) bad.push('TWO: player 2 killing the Overseer earned no OVERSEER DOWN');
       r=netKillTake(peer,{t:'kill',seat:1,id:778812,k:'crawler',el:0});
       if(!(g.gunK&&g.gunK.smg===1)) bad.push('ONE: a second kill with the SMG left the tally at '+JSON.stringify(g.gunK));
       if(gunKillsOf('smg')!==1) bad.push('ONE: the live tally for the SMG reads '+gunKillsOf('smg'));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netRefresh=oRef; say=oSay; sayWhenFree=oSWF; saveProfile=oSave; contractKill=oCK;
       try{ NET.on=keep.on; NET.role=keep.role; NET.seat=keep.seat; NET.peers=keep.peers; NET.entMap=keep.entMap; NET.entDead=keep.entDead; }catch(_n0){}
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ CAREER_ON=c0; }catch(_c0){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       __topClear(); try{ __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
