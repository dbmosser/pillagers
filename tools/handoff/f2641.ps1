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

if ($s.Contains("  {v:'26.41',what:")) { throw "check 26.41 is in the fixture already" }

SubRx @'
  {v:'26.40',what:
'@ @'
  {v:'26.41',what:'settings3, his order 2026-10-14: CONTROLS has MOUSE SENSITIVITY and AIM DOWN SIGHTS SENSITIVITY rows (50 to 200 percent, 100 default): in a live raid a move of the mouse turns the crosshair round the player by that factor, hip or aiming, and the cursor is exactly the real one at 100 percent, over the belt and with the backpack open',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof cv==='undefined') return 'SKIP: no canvas here';
     if(typeof msMove!=='function'||typeof MS==='undefined') return 'there is no mouse sensitivity: the crosshair is the cursor and nothing scales it';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kH=CFG.msHip, kA=CFG.msAds, rows, ps, a0, a1, ra0, ra1, RT=0, kHC, kMx=mouse.x, kMy=mouse.y;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     var RL={x:0,y:0};
     function mv(x,y){ var r=cv.getBoundingClientRect(); RL.x=Math.round(r.left+x)-r.left; RL.y=Math.round(r.top+y)-r.top; cv.dispatchEvent(new MouseEvent('mousemove',{clientX:r.left+RL.x,clientY:r.top+RL.y,bubbles:true})); }
     function angOf(){ return Math.atan2(mouse.y-ps.y,mouse.x-ps.x); }
     // a gesture: start at angle 0 round the player at radius 120, move to angle 0.2; give back how far the crosshair turned
     function turn(sh,sa,ads,rad){
       CFG.msHip=sh; CFG.msAds=sa; p.ads=ads; MS.th=null; MS.rx=null; ps=msPlayerScreen();
       mouse.x=ps.x+rad; mouse.y=ps.y; mv(ps.x+rad,ps.y);
       a0=angOf(); ra0=Math.atan2(RL.y-ps.y,RL.x-ps.x); mv(ps.x+rad*Math.cos(0.2),ps.y+rad*Math.sin(0.2)); a1=angOf(); ra1=Math.atan2(RL.y-ps.y,RL.x-ps.x);
       RT=ra1-ra0;
       return a1-a0;
     }
     function near(v,w,tol){ return Math.abs(v-w)<=tol; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; keys={}; mouse.down=false;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the rows, in CONTROLS, at 100 percent, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       ['msHip','msAds'].forEach(function(k){
         var rr=rowOf(k);
         if(!rr){ bad.push('ONE: Settings has no '+k+' row'); return; }
         if(CFG[k]!==1) bad.push('ONE: a fresh profile has '+k+' '+CFG[k]+', not 1');
         if(gameOptLive(k)!==rr.def) bad.push('ONE: the '+k+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+k)!=='CONTROLS') bad.push('ONE: the '+k+' row sits under '+secOf('go_'+k)+', not CONTROLS');
         __opts.cycle(k); if(CFG[k]!==1.25) bad.push('ONE: one click on '+k+' left it at '+CFG[k]);
         if(typeof P.gameOpts[k]!=='number') bad.push('ONE: the '+k+' pick was not saved');
       });
       P.gameOpts={}; __opts.apply();
       // TWO: the turn. 100 percent is the cursor, 200 turns twice as far, 50 half as far, and aiming down sights uses its own row
       a0=turn(1,1,false,120); if(!near(a0,RT,0.004)||!near(RT,0.2,0.02)) bad.push('TWO: control: at 100 percent the crosshair turned '+a0.toFixed(3)+' for a '+RT.toFixed(3)+' move');
       if(!near(mouse.x,RL.x,0.01)||!near(mouse.y,RL.y,0.01)) bad.push('TWO: control: at 100 percent the crosshair is not the cursor');
       a0=turn(2,1,false,120); if(!near(a0,2*RT,0.008)) bad.push('TWO: 200 percent turned '+a0.toFixed(3)+', not '+(2*RT).toFixed(3));
       a0=turn(0.5,1,false,120); if(!near(a0,0.5*RT,0.008)) bad.push('TWO: 50 percent turned '+a0.toFixed(3)+', not '+(0.5*RT).toFixed(3));
       a0=turn(2,0.5,true,120); if(!near(a0,0.5*RT,0.008)) bad.push('TWO: aiming down sights at 50 percent (hip 200) turned '+a0.toFixed(3)+', not '+(0.5*RT).toFixed(3));
       a0=turn(0.5,2,true,120); if(!near(a0,2*RT,0.008)) bad.push('TWO: aiming down sights at 200 percent (hip 50) turned '+a0.toFixed(3)+', not '+(2*RT).toFixed(3));
       // the distance is the cursor's, not scaled
       turn(2,1,false,150); if(!near(Math.hypot(mouse.x-ps.x,mouse.y-ps.y),Math.hypot(RL.x-ps.x,RL.y-ps.y),1.5)) bad.push('TWO: scaling the turn changed the aim distance to '+Math.hypot(mouse.x-ps.x,mouse.y-ps.y).toFixed(1));
       // THREE: where it does not apply, the crosshair is the real cursor
       CFG.msHip=2; p.ads=false; ps=msPlayerScreen();
       g.bagOpen=true; MS.th=null; MS.rx=null; mouse.x=ps.x+120; mouse.y=ps.y; mv(ps.x+120,ps.y); mv(ps.x+120*Math.cos(0.2),ps.y+120*Math.sin(0.2));
       if(!near(mouse.x,RL.x,0.01)||!near(mouse.y,RL.y,0.01)) bad.push('THREE: with the backpack open the crosshair is not the cursor');
       g.bagOpen=false;
       kHC=g.hotCells; MS.th=null; MS.rx=null; mouse.x=ps.x+120; mouse.y=ps.y; mv(ps.x+120,ps.y);
       g.hotCells=[{x:ps.x+120*Math.cos(0.2)-12,y:ps.y+120*Math.sin(0.2)-12,w:24,h:24}]; mv(ps.x+120*Math.cos(0.2),ps.y+120*Math.sin(0.2));
       if(!near(mouse.x,RL.x,0.01)||!near(mouse.y,RL.y,0.01)) bad.push('THREE: over a belt cell the crosshair is not the cursor');
       g.hotCells=kHC;
       // and it takes up again from where the crosshair is: no jump when scaling starts after a stretch of real moves
       CFG.msHip=1; MS.th=null; MS.rx=null; mouse.x=ps.x+100; mouse.y=ps.y; mv(ps.x+100*Math.cos(0.5),ps.y+100*Math.sin(0.5)); a0=angOf();
       CFG.msHip=2; mv(ps.x+100*Math.cos(0.5),ps.y+100*Math.sin(0.5)); if(!near(angOf(),a0,0.02)) bad.push('THREE: scaling jumped the crosshair by '+(angOf()-a0).toFixed(3)+' when it started');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.msHip=kH; CFG.msAds=kA; MS.th=null; MS.rx=null; mouse.x=kMx; mouse.y=kMy; var g1=__state(); if(g1){ g1.bagOpen=false; if(g1.player) g1.player.ads=false; } }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
