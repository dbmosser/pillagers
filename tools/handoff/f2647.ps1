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

if ($s.Contains("  {v:'26.47',what:")) { throw "check 26.47 is in the fixture already" }

SubRx @'
  {v:'26.46',what:
'@ @'
  {v:'26.47',what:'settings6, his order 2026-10-14: DISPLAY has CROSSHAIR (cross, dot, circle, T), CROSSHAIR COLOUR (white, green, cyan, magenta) and CROSSHAIR SIZE (small to huge), defaulting to today (cross, white, standard): in a drawn raid frame the crosshair arms are the row colour, the row size and the row shape, and the default draws the white cross as before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy, draw or reach the Settings rows';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof renderSettings!=='function'||typeof hcv==='undefined') return 'SKIP: no HUD canvas here';
     if(typeof xhArms!=='function'||typeof xhDot!=='function'||typeof xhCol!=='function') return 'Settings has no crosshair rows: the crosshair is the one white cross';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kS=CFG.xhStyle, kC=CFG.xhCol, kZ=CFG.xhSz, rows, sx, sy, rz, hx=null, ex, RGB={0:[230,240,246],1:[61,255,122],2:[53,230,255],3:[255,79,216]}, i, j, a;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function draw(){ mouse.x=sx; mouse.y=sy; mouse.init=true; p.ads=false; p.recoil=0; __frame(0); __frame(0); hx=hcv.getContext('2d'); }
     // the strongest pixel in a 3 by 3 round (x,y): [r,g,b,alpha]
     function px(x,y){ var d=hx.getImageData(Math.round(x)-1,Math.round(y)-1,3,3).data, best=[0,0,0,0], q; for(q=0;q<9;q++) if(d[q*4+3]>best[3]) best=[d[q*4],d[q*4+1],d[q*4+2],d[q*4+3]]; return best; }
     function on(x,y){ return px(x,y)[3]>70; }
     function reach(){ var e=0, x; for(x=4;x<60;x++) if(on(sx+x,sy)) e=x; return e; }
     function near(c,w,t){ return Math.abs(c[0]-w[0])<=t&&Math.abs(c[1]-w[1])<=t&&Math.abs(c[2]-w[2])<=t; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; keys={}; mouse.down=false;
       p.wep=Object.assign({},WEAPONS.fists); p.drawRef=p.wep; p.drawT=0; p.hand=null; p.reloading=0; p.jam=0; p.ammo=0; g.hot=0;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the rows, in DISPLAY, defaulting to today, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       [['xhStyle',0,[0,1,2,3,0]],['xhCol',0,[0,1,2,3,0]],['xhSz',1,[1,1.3,1.6,0.8,1]]].forEach(function(q){
         var kk=q[0], rr=rowOf(kk), sn, jj;
         if(!rr){ bad.push('ONE: Settings has no '+kk+' row'); return; }
         if(CFG[kk]!==q[1]) bad.push('ONE: a fresh profile has '+kk+' '+CFG[kk]+', not '+q[1]);
         if(gameOptLive(kk)!==rr.def) bad.push('ONE: the '+kk+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+kk)!=='DISPLAY') bad.push('ONE: the '+kk+' row sits under '+secOf('go_'+kk)+', not DISPLAY');
         sn=[CFG[kk]]; for(jj=1;jj<q[2].length;jj++){ __opts.cycle(kk); sn.push(CFG[kk]); }
         if(sn.join(',')!==q[2].join(',')) bad.push('ONE: clicking '+kk+' steps it '+sn.join(' > ')+', not '+q[2].join(' > '));
         if(typeof P.gameOpts[kk]!=='number') bad.push('ONE: the '+kk+' pick was not saved');
       });
       P.gameOpts={}; __opts.apply();
       md.classList.remove('on');
       sx=Math.round(W/2+260); sy=Math.round(H*0.42); rz=hudRes();
       // TWO: the default is the white cross: a right arm and a top arm, white, the size it was
       CFG.xhStyle=0; CFG.xhCol=0; CFG.xhSz=1; draw();
       if(!on(sx+(8+3.5)*rz,sy)||!on(sx,sy-(8+3.5)*rz)||!on(sx,sy+(8+3.5)*rz)||!on(sx-(8+3.5)*rz,sy)) bad.push('TWO: control: the default crosshair is not a four arm cross');
       if(on(sx+3*rz,sy)||on(sx+4*rz,sy+4*rz)) bad.push('TWO: control: the default crosshair has something in its middle gap');
       a=px(sx+(8+3.5)*rz,sy); if(!near(a,RGB[0],10)) bad.push('TWO: control: the default crosshair is not white ('+a.join(',')+')');
       ex=reach(); if(!(Math.abs(ex-15*rz)<=2)) bad.push('TWO: control: the default crosshair reaches '+ex+', not about '+(15*rz));
       // THREE: the colours
       for(i=1;i<=3;i++){ CFG.xhCol=i; draw(); a=px(sx+(8+3.5)*rz,sy); if(!near(a,RGB[i],12)) bad.push('THREE: colour '+i+' drew '+a.join(',')+', not '+RGB[i].join(',')); }
       CFG.xhCol=0;
       // FOUR: the sizes: the arms reach farther the bigger the row
       for(i=0;i<3;i++){ j=[0.8,1.3,1.6][i]; CFG.xhSz=j; draw(); ex=reach(); if(!(Math.abs(ex-15*rz*j)<=2.2)) bad.push('FOUR: size '+j+' reaches '+ex+', not about '+(15*rz*j).toFixed(1)); }
       CFG.xhSz=1;
       // FIVE: the shapes
       CFG.xhStyle=1; draw(); if(on(sx+(8+3.5)*rz,sy)||on(sx,sy-(8+3.5)*rz)) bad.push('FIVE: the DOT has arms'); if(!on(sx+2*rz,sy)) bad.push('FIVE: the DOT has no dot');
       CFG.xhStyle=2; draw(); if(!on(sx+(8+3.5)*rz*0.7071,sy+(8+3.5)*rz*0.7071)) bad.push('FIVE: the CIRCLE has no ring at its diagonal'); if(on(sx+(8+7)*rz*1.0,sy-1000)) bad.push('FIVE: staging');
       CFG.xhStyle=3; draw(); if(on(sx,sy-(8+3.5)*rz)) bad.push('FIVE: the T has a top arm'); if(!on(sx,sy+(8+3.5)*rz)||!on(sx+(8+3.5)*rz,sy)||!on(sx-(8+3.5)*rz,sy)) bad.push('FIVE: the T lost an arm');
       CFG.xhStyle=0;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.xhStyle=kS; CFG.xhCol=kC; CFG.xhSz=kZ; var g1=__state(); if(g1&&g1.player) g1.player.ads=false; }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
