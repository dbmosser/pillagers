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

if ($s.Contains("  {v:'26.46',what:")) { throw "check 26.46 is in the fixture already" }

SubRx @'
  {v:'26.45',what:
'@ @'
  {v:'26.46',what:'settings5, his order 2026-10-14: DISPLAY has SCREEN SHAKE (off, light, standard, strong), BRIGHTNESS (a gamma on the world canvas) and SHOW FPS, defaulting to today (standard, standard, off): shake off gives no camera offset after a blast and strong gives more than standard, the canvas has no filter at standard and a gamma filter with the row exponent otherwise, and the frame rate plate reads 60 FPS for 60 frames a second and is hidden when off',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof gfxTrauma!=='function'||typeof GFX==='undefined'||typeof cv==='undefined') return 'SKIP: no camera shake here';
     if(typeof shakeK!=='function'||typeof brightApply!=='function'||typeof fpsTick!=='function') return 'Settings has no screen shake, brightness or frame rate rows';
     var bad=[], g=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kS=CFG.shake, kG=CFG.gam, kF=CFG.showFps, kFx=CFG.fxInt, rows, i, w, a0, a1, a2, box, fl,
         kGFX={tr:GFX.tr,shL:GFX.shL,shG:GFX.shG,shT:GFX.shT,sx:GFX.sx,sy:GFX.sy,shA:GFX.shA}, kF0=cv.style.filter;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function blast(){ GFX.shG=null; gfxTrauma(0.016); g.shake=0; gfxTrauma(0.016); g.shake=14; return gfxTrauma(0.016); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.ents.length=0;
       P.gameOpts={}; P.tuned={}; __opts.apply(); CFG.fxInt=1;
       // ONE: the rows, in DISPLAY, defaulting to today, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       [['shake',1,[1,1.5,0,0.5,1]],['gam',1,[1,0.8,0.65,1.25,1]],['showFps',0,[0,1,0]]].forEach(function(q){
         var kk=q[0], rr=rowOf(kk), sn, jj;
         if(!rr){ bad.push('ONE: Settings has no '+kk+' row'); return; }
         if(CFG[kk]!==q[1]) bad.push('ONE: a fresh profile has '+kk+' '+CFG[kk]+', not '+q[1]);
         if(gameOptLive(kk)!==rr.def) bad.push('ONE: the '+kk+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+kk)!=='DISPLAY') bad.push('ONE: the '+kk+' row sits under '+secOf('go_'+kk)+', not DISPLAY');
         if(rr.label!==String(rr.label).toUpperCase()) bad.push('ONE: the '+kk+' label is not caps');
         sn=[CFG[kk]]; for(jj=1;jj<q[2].length;jj++){ __opts.cycle(kk); sn.push(CFG[kk]); }
         if(sn.join(',')!==q[2].join(',')) bad.push('ONE: clicking '+kk+' steps it '+sn.join(' > ')+', not '+q[2].join(' > '));
         if(typeof P.gameOpts[kk]!=='number') bad.push('ONE: the '+kk+' pick was not saved');
       });
       P.gameOpts={}; __opts.apply(); CFG.fxInt=1;
       // TWO: the shake. A blast gives a camera offset at STANDARD, none at OFF, more at STRONG, less at LIGHT
       CFG.shake=1; a0=blast(); if(!(a0>1)) bad.push('TWO: control: a blast at STANDARD shook the camera by '+a0);
       CFG.shake=0; a1=blast(); if(a1!==0||GFX.sx!==0||GFX.sy!==0) bad.push('TWO: SCREEN SHAKE off still moved the camera ('+a1+', '+GFX.sx+', '+GFX.sy+')');
       CFG.shake=1.5; a2=blast(); if(!(a2>a0*1.4&&a2<a0*1.6)) bad.push('TWO: STRONG shook '+a2+' against STANDARD '+a0);
       CFG.shake=0.5; a2=blast(); if(!(a2>a0*0.4&&a2<a0*0.6)) bad.push('TWO: LIGHT shook '+a2+' against STANDARD '+a0);
       // THREE: the brightness
       CFG.gam=1; brightApply(); if(cv.style.filter) bad.push('THREE: control: the canvas has a filter at STANDARD ('+cv.style.filter+')');
       CFG.gam=0.8; brightApply(); fl=document.querySelector('#gamf feFuncG');
       if(String(cv.style.filter).indexOf('url(')<0) bad.push('THREE: BRIGHTER put no filter on the world canvas ('+cv.style.filter+')');
       if(!fl||fl.getAttribute('exponent')!=='0.8') bad.push('THREE: BRIGHTER set the gamma to '+(fl?fl.getAttribute('exponent'):'nothing'));
       CFG.gam=1.25; brightApply(); fl=document.querySelector('#gamf feFuncR'); if(!fl||fl.getAttribute('exponent')!=='1.25') bad.push('THREE: DARKER set the gamma to '+(fl?fl.getAttribute('exponent'):'nothing'));
       CFG.gam=1; brightApply(); if(cv.style.filter) bad.push('THREE: STANDARD did not take the filter off ('+cv.style.filter+')');
       // FOUR: the frame rate plate
       CFG.showFps=0; FPSV.t0=0; for(i=0;i<40;i++) fpsTick(1000+i*16.667);
       box=document.getElementById('fpsbox'); if(box&&box.className==='on') bad.push('FOUR: control: the plate shows with SHOW FPS off');
       CFG.showFps=1; FPSV.t0=0; FPSV.n=0; for(i=0;i<40;i++) fpsTick(5000+i*16.667);
       box=document.getElementById('fpsbox'); if(!box||box.className!=='on') bad.push('FOUR: SHOW FPS on did not show the plate');
       else if(box.textContent!=='60 FPS') bad.push('FOUR: sixty frames a second read '+box.textContent);
       FPSV.t0=0; FPSV.n=0; for(i=0;i<20;i++) fpsTick(9000+i*33.333);
       if(box&&box.textContent!=='30 FPS') bad.push('FOUR: thirty frames a second read '+box.textContent);
       CFG.showFps=0; fpsTick(20000); if(box&&box.className==='on') bad.push('FOUR: switching SHOW FPS off left the plate up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.shake=kS; CFG.gam=kG; CFG.showFps=kF; CFG.fxInt=kFx; var b2=document.getElementById('fpsbox'); if(b2) b2.className=''; FPSV.t0=0; FPSV.n=0; cv.style.filter=kF0||''; BRT.v=1; }catch(_c){}
       try{ GFX.tr=kGFX.tr; GFX.shL=kGFX.shL; GFX.shG=kGFX.shG; GFX.shT=kGFX.shT; GFX.sx=kGFX.sx; GFX.sy=kGFX.sy; GFX.shA=kGFX.shA; var g1=__state(); if(g1) g1.shake=0; }catch(_g){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
