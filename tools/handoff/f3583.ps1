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

if ($s.Contains("  {v:'35.83',what:")) { throw "check 35.83 is in the fixture already" }

SubRx @'
  {v:'35.82',what:
'@ @'
  {v:'35.83',what:'two player demo final 90 seconds: 1.05x kill SP in both seats, faster machine waves and one start callout; solo and career excluded',
   run:function(){
     if(typeof arcadeRushOn!=='function'||typeof arcadeRushTick!=='function') return 'final rush is missing';
     var g, i, n, before, calls=[], saved={}, nk=['on','role','seat','upSeed','entMap','entDead'], solo0=ARCADE.solo, role0=ARCADE.role, dm0=DMUL_ON;
     var funcs={say:say,flowKill:flowKill,styleKill:styleKill,pwrKill:pwrKill,teamKill:teamKill,arcadeKillPerks:arcadeKillPerks,arcadeScSend:arcadeScSend,
       flowDir:flowDir,flowAmbushOk:flowAmbushOk,arcadeWaveSpot:arcadeWaveSpot,arcadeWaveBody:arcadeWaveBody,arcadeWaveLive:arcadeWaveLive,siegeCalled:siegeCalled,waveTier:waveTier};
     function kill(want,join){
       ARCADE.streak=null; before=ARCADE.mine;
       if(join){
         NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed;
         NET.entMap={991:{kind:'sentry',x:g.player.x,y:g.player.y,hp:0}}; NET.entDead={};
         if(netKillTake({state:'in'},{seat:1,k:'sentry',id:991})!=='kill') throw Error('partner kill rejected');
       }else{ NET.on=false; NET.role='host'; arcadeKill('sentry',0,0,g.player.x,g.player.y); }
       if(ARCADE.mine-before!==want) throw Error((join?'partner':'host')+' kill paid '+(ARCADE.mine-before)+', wanted '+want);
     }
     function wave(time,clock,pace,ring,live){
       g.timeLeft=time; ARCADE.waveT=clock;
       flowDir=function(){ return {pace:pace}; }; siegeCalled=function(){ return ring; };
       arcadeWaveLive=function(){ return live||0; };
       return arcadeWaveTick(0);
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(i=0;i<nk.length;i++) saved[nk[i]]=NET[nk[i]];
       if(!arcadeDeploy({mapIx:0,seed:4242})) throw Error('demo did not deploy');
       g=__state(); if(!g||!g.player||g.over||!g.arcade) throw Error('no demo raid');
       g.hotZone=null; ARCADE.solo=0; ARCADE.role='host'; DMUL_ON=0;
       siegeCalled=function(){ return true; };
       say=function(m,k,o){ if(m==='final rush') calls.push([m,k,o&&o.sub]); return funcs.say.apply(this,arguments); };
       flowKill=styleKill=pwrKill=teamKill=arcadeKillPerks=arcadeScSend=function(){};
       g.timeLeft=90.001; if(arcadeRushOn()||arcadeRushTick()) throw Error('rush starts early'); kill(100,false);
       for(i=0;i<2;i++){
         g.arcRushSaid=0; calls=[]; g.timeLeft=90; g.alert=null; g.alertQ=[];
         ARCADE.role=i?'p2':'host'; NET.on=!!i; NET.role=i?'join':'host'; NET.upSeed=g.seed;
         arcadeWaveTick(0); arcadeWaveTick(0);
         if(calls.length!==1||calls[0][2]!=='kills x1.05 sp'||!g.alert||g.alert.m!=='final rush') throw Error('seat '+i+' start callout '+JSON.stringify(calls));
         kill(105,!!i); g.timeLeft=0.01; kill(105,!!i);
         g.timeLeft=0; if(arcadeRushOn()) throw Error('rush continues at expiry'); kill(100,!!i);
       }
       NET.on=false; NET.role='host'; ARCADE.role='host';
       g.timeLeft=90; ARCADE.solo=1; g.arcRushSaid=0; calls=[];
       if(arcadeRushOn()||arcadeRushTick()||calls.length) throw Error('solo rush'); kill(100,false);
       ARCADE.solo=0; g.arcade=0; if(arcadeRushOn()||arcadeRushTick()) throw Error('career rush'); g.arcade=1;
       g.sim=true; if(arcadeRushOn()) throw Error('simulation rush'); g.sim=false;
       g.over=true; if(arcadeRushOn()) throw Error('finished raid rush'); g.over=false;
       waveTier=function(){ return 4; }; flowAmbushOk=function(){ return false; };
       arcadeWaveSpot=function(){ return {x:g.player.x+900,y:g.player.y}; };
       arcadeWaveBody=function(m,q,c){ return c; };
       if(wave(90.001,13,1,false,0)!==0) throw Error('normal wave arrived early');
       n=wave(90.001,14,1,false,0); if(n!==4) throw Error('normal wave size '+n);
       n=wave(90,11.21,1,false,0); if(n!==5) throw Error('rush wave size or interval '+n);
       n=g.ents[g.ents.length-1]; if(!n||!n.arcWave||['crawler','sentry'].indexOf(n.kind)<0) throw Error('rush extra body is not a machine');
       if(wave(90,999,0,false,0)!==0) throw Error('rush bypasses breather');
       if(wave(90,999,1,true,0)!==0) throw Error('rush bypasses called ring');
       if(wave(90,999,1,false,16)!==0) throw Error('rush bypasses cap');
       ARCADE.solo=1; if(wave(90,11.21,1,false,0)!==0) throw Error('solo wave accelerated');
       return null;
     }catch(e){ return String(e&&e.message||e); }
     finally{
       say=funcs.say; flowKill=funcs.flowKill; styleKill=funcs.styleKill; pwrKill=funcs.pwrKill; teamKill=funcs.teamKill; arcadeKillPerks=funcs.arcadeKillPerks; arcadeScSend=funcs.arcadeScSend;
       flowDir=funcs.flowDir; flowAmbushOk=funcs.flowAmbushOk; arcadeWaveSpot=funcs.arcadeWaveSpot; arcadeWaveBody=funcs.arcadeWaveBody; arcadeWaveLive=funcs.arcadeWaveLive; siegeCalled=funcs.siegeCalled; waveTier=funcs.waveTier;
       try{ if(g){ g.sim=false; g.arcade=1; g.over=false; } if(ARCADE.on) arcadeLeave(); if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       ARCADE.solo=solo0; ARCADE.role=role0; DMUL_ON=dm0;
       for(i=0;i<nk.length;i++) if(Object.prototype.hasOwnProperty.call(saved,nk[i])) NET[nk[i]]=saved[nk[i]];
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'35.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
