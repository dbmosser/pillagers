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

if ($s.Contains("  {v:'28.97',what:")) { throw "check 28.97 is in the fixture already" }

SubRx @'
  {v:'28.96',what:
'@ @'
  {v:'28.97',what:'cloud-coop-ricochet-seen: a round that ricochets off steel in one window is sent again from the bounce flagged, so the teammate sees it fly on with the bounce spark and no second muzzle flash',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netFxShot!=='function'||typeof netFxTake!=='function'||typeof netFxStep!=='function'||typeof ricochetOff!=='function'||typeof updateBullets!=='function'||typeof GFXMUZ==='undefined') return 'SKIP: no ricochet or party tracers in this fixture';
     var bad=[], g, p, NK={}, k, oSF=netSendFast, oS=netSend, fast=[], staged=false, oIv, w=null, i, b, x, y, ux, uy, n, W2, ws, t, a0, a1, mz0=GFXMUZ.slice(), m0, alive=0, hp={seat:1,state:'in'}, h={seat:0,state:'in'};
     try{
       __topClear(); __runPrep(); __resetCfg();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       W2=g.map.walls.filter(function(q){ return !q.win&&matOf(q)==='metal'&&q.w>=60; });
       for(i=0;i<W2.length;i++){ x=W2[i].x+W2[i].w*0.3; y=W2[i].y-30; ux=Math.cos(0.5236); uy=Math.sin(0.5236); if(spotFree(g.map,x,y,4)&&rayHitG(x,y,ux,uy,200)<200){ w=W2[i]; break; } }
       if(!w) return 'SKIP: staging: no metal wall with a clear glancing line on map 0';
       g.ents=[];
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0; NET.role='host'; NET.seat=0; NET.peers=[hp];
       netSendFast=function(q,m){ fast.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       // ONE: the shooter window: a glancing round off steel sends a second tracer word from the bounce, flagged
       g.bullets.length=0;
       b={x:x,y:y,vx:ux*1180,vy:uy*1180,dmg:30,life:0.5,player:true,owner:p,tint:'#fff',el:'',thru:0,gid:'rifle'}; g.bullets.push(b);
       netFxShot(b);
       for(n=0;n<12&&g.bullets.indexOf(b)>=0;n++){ updateBullets(1/60); if(b._rico) break; }
       if(!b._rico) return 'SKIP: staging: the round did not ricochet';
       ws=fast.filter(function(q){ return q.t==='fx'&&q.k==='b'; });
       if(ws.length!==2) bad.push('ONE: the shooter sent '+ws.length+' tracer words for a round that bounced, not 2');
       a0=ws[0]&&ws[0].b; a1=ws[1]&&ws[1].b;
       if(a0&&a0[7]) bad.push('ONE: the fire word is flagged as a bounce');
       if(ws.length>=2&&!(a1&&a1[7]===1)) bad.push('ONE: the second word is not flagged as a bounce ('+JSON.stringify(a1)+')');
       if(a0&&a1&&!(a0[3]*a1[3]<0)) bad.push('ONE: the bounce word does not carry the flipped flight (vy '+a0[3]+' then '+a1[3]+')');
       // TWO: the teammate window takes the bounce word: a tracer flies on past the wall, and no muzzle flash at the steel
       NET.role='join'; NET.seat=1; NET.peers=[h];
       if(a1){
         g.fxBullets=[]; GFXMUZ.length=0;
         if(netFxTake(h,ws[1])!=='fx:b') bad.push('TWO: the bounce word was not taken');
         if(GFXMUZ.length!==0) bad.push('TWO: the bounce drew a muzzle flash at the steel');
         t=g.fxBullets[0];
         if(!t) bad.push('TWO: no tracer from the bounce');
         else {
           if(!(t.vy*a0[3]<0)) bad.push('TWO: the teammate tracer did not turn at the wall');
           for(n=0;n<30;n++){ netFxStep(1/60); if(g.fxBullets.indexOf(t)>=0) alive=n+1; }
           if(alive<5) bad.push('TWO: the teammate tracer died after '+alive+' frames, not flying on from the bounce');
         }
       }
       // THREE: the fire word still draws its muzzle flash for the teammate
       g.fxBullets=[]; GFXMUZ.length=0;
       if(a0){ netFxTake(h,ws[0]); if(GFXMUZ.length!==1) bad.push('THREE: the fire word drew '+GFXMUZ.length+' muzzle flashes, not 1'); }
     }catch(e){ bad.push('threw: '+String(e&&e.stack||e).slice(0,300)); }
     finally{
       netSend=oS; netSendFast=oSF;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       GFXMUZ.length=0; for(i=0;i<mz0.length;i++) GFXMUZ.push(mz0[i]);
       try{ if(p) p.iv=oIv; }catch(_p){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
