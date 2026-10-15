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

if ($s.Contains("  {v:'28.28',what:")) { throw "check 28.28 is in the fixture already" }

SubRx @'
  {v:'28.27',what:
'@ @'
  {v:'28.28',what:'cloud-coop-getup-vs-burn: a downed pillager set on fire does not show player 2 the get-up bar or the pick sound before he really gets up, and a man getting up who stopped burning is not drawn on fire in the player 2 window',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim||!window.__state) return 'SKIP: no raid here';
     if(typeof elemHit!=='function'||typeof netEntRow!=='function'||typeof netEntsApply!=='function'||typeof netEntFlagsApply!=='function') return 'SKIP: no elements or snapshot rows here';
     var bad=[], g=null, p=null, all=null, A=null, M=null, NK={}, k, staged=false, oB=blip, picks=0, keepIv=null, i, n=1, pr={seat:0,state:'in'}, hostUp=-1, early=0, falseBurn=0, sawUp=0, upBlip=0, last;
     var step=function(c){ for(var s=0;s<c;s++) __sim(1/60); };
     var apply=function(){
       var row=netEntRow(A), gs=G.sim, r;
       row[0]=990771;
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[pr]; NET.upSeed=g.seed>>>0; G.sim=false;
       try{ r=netEntsApply(pr,{t:'en',sd:NET.upSeed,n:n++,e:[row]}); }
       finally{ G.sim=gs; NET.on=NK.on; NET.role=NK.role; NET.seat=NK.seat; NET.peers=NK.peers; NET.upSeed=NK.upSeed; }
       M=NET.entMap&&NET.entMap[990771];
       if(M){ var ix=g.ents.indexOf(M); if(ix>=0) g.ents.splice(ix,1); }
       return r;
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(CFG.raiderDown===0) return 'SKIP: pillagers die outright here';
       p=g.player; all=g.ents.slice(); keepIv=p.iv; p.iv=1e6;
       for(k in keys) keys[k]=false;
       A=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hostile===true&&x.hp>0&&!x.downed&&!x.finished; })[0];
       if(!A) return 'SKIP: no hostile pillager on this map';
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.entMap={}; NET.entLast=-1; NET.entGone={};
       g.bullets.length=0; A.x=p.x+220; A.y=p.y; A.hp=0; A.byPlayer=true; A.downed=0; A.finished=0; g.ents=[A]; step(1);
       if(A.downed!==1) return 'SKIP: a pillager at no health did not go down here';
       elemHit(A,'fire',20,0,p.x,p.y);
       if(!(A.burnT>0)) return 'SKIP: the fire round did not set him burning';
       blip=function(nm){ if(nm==='pick') picks++; return oB.apply(this,arguments); };
       var r0=apply(); if(r0!=='ents'||!M) return 'SKIP: the linked window took no snapshot ('+r0+')';
       for(i=0;i<12*60;i++){
         step(1);
         if(g.ents.indexOf(A)<0) break;
         last=picks; apply();
         if(!M) break;
         if(A.downed&&!(A.getUp>0)&&(M.getUp>0)&&!early) early=1;
         if(A.downed&&!(A.getUp>0)&&picks>last) early=2;
         if(A.downed&&A.getUp>0){ if(!sawUp){ sawUp=1; if(picks>last) upBlip=1; } if(!(A.burnT>0)&&M.burnT>0) falseBurn=1; }
         if(!A.downed){ hostUp=i; break; }
       }
       if(early) bad.push('player 2 saw the get-up bar'+(early===2?' and heard the pick':'')+' while the host man was still down and only burning');
       if(falseBurn) bad.push('player 2 drew a man getting up on fire after he stopped burning');
       if(!sawUp) bad.push('the burning man never began to get up on the host in 12 s (state '+(g.ents.indexOf(A)<0?'gone':A.state)+')');
       else if(!upBlip) bad.push('player 2 heard no pick at the real get-up');
       // old two argument callers and old rows still read the bit
       var o={kind:'raider',x:0,y:0,state:'down',hp:10,maxhp:50,downed:1};
       netEntFlagsApply(o,1|8388608);
       if(!(o.burnT>0)||!(o.getUp>0)) bad.push('a two argument flags read lost the old bit');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       blip=oB;
       if(staged){ for(k in NK) NET[k]=NK[k]; for(k in NET) if(!(k in NK)) delete NET[k]; }
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.bullets.length=0; if(g2.player&&keepIv!==null) g2.player.iv=keepIv; if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
