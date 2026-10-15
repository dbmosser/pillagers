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

if ($s.Contains("  {v:'28.34',what:")) { throw "check 28.34 is in the fixture already" }

SubRx @'
  {v:'28.33',what:
'@ @'
  {v:'28.34',what:'cloud-coop-mender-beams-seen: player 2 window draws the mender elite beam to a hurt machine in its reach, and none to a machine at full health',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof drawAffixTop!=='function'||typeof netEntsPeer!=='function'||typeof netEntMake!=='function'||typeof netEntFill!=='function'||typeof AFFIX!=='object'||!AFFIX.mend) return 'SKIP: no mender or linked window in this fixture';
     var g=null, NK={}, k, staged=false, all=null, men=null, hurt=null, oT=null, w=null, oMv=null, hadMv=false, segs=[], i, mach, sv=[], r, n1, n2, n0, nb, b;
     function beams(){ segs.length=0; drawAffixTop(men); var c=0, j; for(j=0;j<segs.length;j++) if(Math.abs(segs[j][0]-men.x)<0.01&&Math.abs(segs[j][1]-(men.y-men.r*0.8))<0.01) c++; return c; }
     try{
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       all=g.ents.slice();
       mach=all.filter(function(x){ return (x.kind==='sentry'||x.kind==='crawler')&&!x.boss&&x.hp>0&&!x.downed&&!x.finished; });
       if(mach.length<2) return 'SKIP: fewer than two machines in this raid';
       men=mach[0]; hurt=mach[1];
       for(i=0;i<2;i++){ var q=mach[i]; sv.push({e:q,x:q.x,y:q.y,hp:q.hp,elite:q.elite,affix:q.affix,mendFx:q.mendFx,mendTo:q.mendTo}); }
       men.elite=1; men.affix='mend'; men.mendFx=0; men.mendTo=undefined; men.hp=men.maxhp;
       hurt.x=men.x+60; hurt.y=men.y; hurt.hp=hurt.maxhp*0.5;
       g.ents=[men,hurt];
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       if(!netEntsPeer()) return 'SKIP: the staged join window is not a linked window';
       oT=g.t; g.t=Math.floor((g.t||0)/0.5)*0.5+0.1;
       w=wc; hadMv=Object.prototype.hasOwnProperty.call(w,'moveTo'); oMv=w.moveTo;
       w.moveTo=function(x,y){ segs.push([x,y]); return oMv.apply(this,arguments); };
       n0=beams();
       if(n0!==1) return 'player 2 window drew '+n0+' mender beams to one machine at half health 60 away (the host draws 1; mendFx '+men.mendFx+')';
       hurt.hp=hurt.maxhp;
       n1=beams();
       if(n1!==0) return 'player 2 window drew '+n1+' mender beams to a machine at full health';
       b=netEntMake(880009,'warden',men.x+60,men.y); netEntFill(b,{n:BOSS_NAME,r:44,mh:1000,hp:10,ho:1,af:''}); g.ents=[men,b];
       nb=beams(); g.ents=[men,hurt];
       if(nb!==0) return 'player 2 window drew '+nb+' mender beams to a hurt Overseer mirror, which the host never mends';
       hurt.hp=hurt.maxhp*0.5; hurt.x=men.x+AFFIX_MEND_R+40;
       n2=beams();
       if(n2!==0) return 'player 2 window drew '+n2+' mender beams to a machine out of its reach';
       if(men.mendFx>0||hurt.hp!==hurt.maxhp*0.5) return 'drawing the beams on player 2 window changed the bodies (mendFx '+men.mendFx+', hp '+hurt.hp+')';
       return null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       if(w){ if(hadMv) w.moveTo=oMv; else delete w.moveTo; }
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(g&&oT!==null) g.t=oT;
       for(i=0;i<sv.length;i++){ r=sv[i]; r.e.x=r.x; r.e.y=r.y; r.e.hp=r.hp; r.e.elite=r.elite; r.e.affix=r.affix; r.e.mendFx=r.mendFx; r.e.mendTo=r.mendTo; }
       if(g&&all) g.ents=all;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
