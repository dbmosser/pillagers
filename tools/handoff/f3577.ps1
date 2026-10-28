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

if ($s.Contains("  {v:'35.77',what:")) { throw "check 35.77 is in the fixture already" }

SubRx @'
  {v:'35.76',what:
'@ @'
  {v:'35.77',what:'hot-ground kills pay 1.05x after the streak, with a hot popup, in career and demo on the host and partner',
   run:function(){
     var g, p, c0=CAREER_ON, d0=DMUL_ON, saved={}, nk=['on','role','seat','upSeed','entMap','entDead'], i, mode, q, before, n, x, y, hot, last;
     var fs=[flowKill,styleKill,pwrKill,teamKill,arcadeKillPerks,arcadeScSend];
     function reset(){ if(g.cs) g.cs.streak=null; ARCADE.streak=null; g.labels.length=0; }
     function score(){ return g.arcade?ARCADE.mine:g.cs.s; }
     function kill(){ return g.arcade?arcadeKill('sentry',0,0,x,y):careerKill('sentry',0,0,x,y); }
     function sample(want,tag,join){
       reset(); before=score();
       if(join){
         NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed;
         NET.entMap={991:{kind:'sentry',x:x,y:y,hp:0}}; NET.entDead={};
         if(netKillTake({state:'in'},{seat:1,k:'sentry',id:991})!=='kill') throw Error(tag+' partner credit rejected');
         n=score()-before;
       }else{ NET.on=false; NET.role='host'; n=kill(); }
       if(n!==want||score()-before!==want) throw Error(tag+' paid '+n+' / '+(score()-before)+', wanted '+want);
       last=g.labels[g.labels.length-1];
       if(!last||last.txt!=='+'+arcadeCr(want)+(want===105?' hot':'')) throw Error(tag+' popup '+(last&&last.txt));
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(i=0;i<nk.length;i++) saved[nk[i]]=NET[nk[i]];
       DMUL_ON=0;
       flowKill=styleKill=pwrKill=teamKill=arcadeKillPerks=arcadeScSend=function(){};
       for(mode=0;mode<2;mode++){
         CAREER_ON=1;
         if(mode){ if(!arcadeDeploy({mapIx:0,seed:4242})) throw Error('demo did not deploy'); }
         else __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state(); if(!g||!g.player||g.over||(!mode&&!g.cs)||!!g.arcade!==!!mode) throw Error('wrong raid mode');
         p=g.player; hot={x:p.x+60,y:p.y,r:100,at:0}; g.hotZone=hot;
         for(q=0;q<2;q++){
           x=hot.x; y=hot.y; sample(105,(mode?'demo':'career')+' inside',q);
           x=hot.x+hot.r; sample(105,'boundary',q);
           x+=1; sample(100,'outside',q);
         }
         NET.on=false; NET.role='host'; x=hot.x; y=hot.y; reset(); kill(); n=kill();
         if(n!==Math.round(100*arcadeStreakX(2)*1.05)) throw Error('bonus is not after streak: '+n);
         x=Infinity; reset(); if(kill()!==100) throw Error('infinite position got bonus');
         x=NaN; reset(); if(kill()!==100) throw Error('missing position got bonus');
         g.hotZone=null; x=hot.x; sample(100,'no hot ground',false);
         if(mode) arcadeLeave();
         if(__state()&&!__state().over) __endRaid('abandon');
         __topClear();
       }
       return null;
     }catch(e){ return String(e&&e.message||e); }
     finally{
       flowKill=fs[0]; styleKill=fs[1]; pwrKill=fs[2]; teamKill=fs[3]; arcadeKillPerks=fs[4]; arcadeScSend=fs[5];
       try{ if(ARCADE.on) arcadeLeave(); if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       CAREER_ON=c0; DMUL_ON=d0;
       for(i=0;i<nk.length;i++) if(Object.prototype.hasOwnProperty.call(saved,nk[i])) NET[nk[i]]=saved[nk[i]];
       __topClear();
     } }},
  {v:'35.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
