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

if ($s.Contains("  {v:'26.50',what:")) { throw "check 26.50 is in the fixture already" }

SubRx @'
  {v:'26.49',what:
'@ @'
  {v:'26.50',what:'settings9, his order 2026-10-14: ACCESSIBILITY has REDUCED FLASHING (off by default): on, a flash light is smaller and shorter, a burst has half the sparks, the lightning sheet is dimmer, and the muzzle flash drawn on the gun is dimmer; off is the game as it was',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy, draw or reach the Settings rows';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof renderSettings!=='function'||typeof flash!=='function'||typeof spark!=='function'||typeof msPlayerScreen!=='function') return 'SKIP: no flashes here';
     if(typeof flashK!=='function'||typeof lightningA!=='function') return 'Settings has no reduced flashing row';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kR=CFG.flashRed, kFx=CFG.fxLevel, rows, rr, sn, j, n0, F, ps, c, x0, y0, d, a, s1, s2, s3, src, NEEDLE=['lightning'+'A(lf)','flash'+'K()'];
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function sumAround(){ var q=cv.getContext('2d'), w=220, h=220, dd, t=0, z; ps=msPlayerScreen(); x0=Math.max(0,Math.round(ps.x-110)); y0=Math.max(0,Math.round(ps.y-130)); w=Math.min(w,cv.width-x0); h=Math.min(h,cv.height-y0); dd=q.getImageData(x0,y0,w,h).data; for(z=0;z<dd.length;z+=4) t+=dd[z]+dd[z+1]+dd[z+2]; return t; }
     function shot(){ g.flashes.length=0; p.muzzle=0.05; __frame(0); __frame(0); var t=sumAround(); g.flashes.length=0; return t; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; keys={}; mouse.down=false;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the row, in ACCESSIBILITY, off by default, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       rr=null; for(j=0;j<rows.length;j++) if(rows[j].k==='flashRed') rr=rows[j];
       if(!rr) bad.push('ONE: Settings has no flashRed row');
       else {
         if(CFG.flashRed!==0) bad.push('ONE: a fresh profile has flashRed '+CFG.flashRed+', not 0');
         if(gameOptLive('flashRed')!==rr.def) bad.push('ONE: the row reads CUSTOM on a fresh profile');
         if(secOf('go_flashRed')!=='ACCESSIBILITY') bad.push('ONE: the row sits under '+secOf('go_flashRed')+', not ACCESSIBILITY');
         sn=[CFG.flashRed]; for(j=1;j<3;j++){ __opts.cycle('flashRed'); sn.push(CFG.flashRed); }
         if(sn.join(',')!=='0,1,0') bad.push('ONE: clicking steps it '+sn.join(' > ')+', not 0 > 1 > 0');
         if(typeof P.gameOpts.flashRed!=='number') bad.push('ONE: the pick was not saved');
       }
       P.gameOpts={}; __opts.apply(); md.classList.remove('on');
       // TWO: a flash light and a burst of sparks
       CFG.fxLevel=1; CFG.flashRed=0; g.flashes.length=0; flash(100,100,200,'#fff',0.4); F=g.flashes[g.flashes.length-1];
       if(!F||F.r!==200||Math.abs(F.life-0.4)>1e-9) bad.push('TWO: control: a flash with the row off is '+(F?F.r+' wide for '+F.life:'missing'));
       g.sparks.length=0; spark(100,100,'#fff',40,300); n0=g.sparks.length; if(n0!==40) bad.push('TWO: control: a burst of 40 made '+n0);
       CFG.flashRed=1; g.flashes.length=0; flash(100,100,200,'#fff',0.4); F=g.flashes[g.flashes.length-1];
       if(!F||!(F.r<130)||!(F.life<0.35)) bad.push('TWO: REDUCED FLASHING left a flash '+(F?F.r+' wide for '+F.life:'missing'));
       g.sparks.length=0; spark(100,100,'#fff',40,300); if(g.sparks.length!==20) bad.push('TWO: REDUCED FLASHING made '+g.sparks.length+' sparks of 40, not 20');
       // THREE: the lightning and the factor
       CFG.flashRed=0; a=lightningA(1); if(Math.abs(a-0.4)>1e-9||flashK()!==1) bad.push('THREE: control: the lightning sheet is '+a+' and flashK '+flashK());
       CFG.flashRed=1; if(!(lightningA(1)<0.2)||!(flashK()<0.5)) bad.push('THREE: REDUCED FLASHING left the lightning sheet at '+lightningA(1));
       src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(src.indexOf(NEEDLE[0])<0) bad.push('THREE: the lightning does not draw through lightningA');
       if(src.split(NEEDLE[1]).length<8) bad.push('THREE: too few muzzle flashes and fog lifts read flashK ('+(src.split(NEEDLE[1]).length-1)+')');
       // FOUR: the muzzle flash on the gun, drawn
       CFG.fxLevel=1; __frame(0); __frame(0);
       CFG.flashRed=0; s1=shot(); CFG.flashRed=1; s2=shot();
       p.muzzle=0; g.flashes.length=0; CFG.flashRed=0; __frame(0); __frame(0); s3=sumAround(); CFG.flashRed=1; __frame(0); __frame(0); c=sumAround();
       if(!(s1>s2+4000)) bad.push('FOUR: the muzzle flash is no dimmer with the row on ('+s1+' against '+s2+')');
       if(Math.abs(s3-c)>3000) bad.push('FOUR: control: with no muzzle flash the picture moved by '+Math.abs(s3-c)+' with the row');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.flashRed=kR; CFG.fxLevel=kFx; var g1=__state(); if(g1){ g1.flashes.length=0; g1.sparks.length=0; if(g1.player) g1.player.muzzle=0; } }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
