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

if ($s.Contains("  {v:'26.48',what:")) { throw "check 26.48 is in the fixture already" }

SubRx @'
  {v:'26.47',what:
'@ @'
  {v:'26.48',what:'settings7, his order 2026-10-14: DISPLAY has MINIMAP SIZE (small, standard, large) and MINIMAP ZOOM (close, standard, wide), defaulting to today (216 pixels, 1000 units across): the drawn plate takes the row size and the street it shows takes the row span, and the panel under it moves down with a larger plate',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy, draw or reach the Settings rows';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof renderSettings!=='function'||typeof drawMinimap!=='function'||typeof MMAP==='undefined') return 'SKIP: no minimap here';
     if(typeof mmSizeK!=='function'||typeof mmSpan!=='function') return 'Settings has no minimap size or zoom rows';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kS=CFG.mmSz, kZ=CFG.mmSpan, kM=CFG.minimap, rows, R, w0, bs0, bw, bb, i;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function draw(){ __frame(0); __frame(0); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; keys={}; mouse.down=false;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the rows, in DISPLAY, defaulting to today, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       [['mmSize','mmSz',1,[1,1.35,0.75,1]],['mmZoom','mmSpan',1000,[1000,1400,700,1000]]].forEach(function(q){
         var kk=q[0], rr=rowOf(kk), sn, jj;
         if(!rr){ bad.push('ONE: Settings has no '+kk+' row'); return; }
         if(CFG[q[1]]!==q[2]) bad.push('ONE: a fresh profile has '+q[1]+' '+CFG[q[1]]+', not '+q[2]);
         if(gameOptLive(kk)!==rr.def) bad.push('ONE: the '+kk+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+kk)!=='DISPLAY') bad.push('ONE: the '+kk+' row sits under '+secOf('go_'+kk)+', not DISPLAY');
         sn=[CFG[q[1]]]; for(jj=1;jj<q[3].length;jj++){ __opts.cycle(kk); sn.push(CFG[q[1]]); }
         if(sn.join(',')!==q[3].join(',')) bad.push('ONE: clicking '+kk+' steps it '+sn.join(' > ')+', not '+q[3].join(' > '));
         if(typeof P.gameOpts[kk]!=='number') bad.push('ONE: the '+kk+' pick was not saved');
       });
       P.gameOpts={}; __opts.apply();
       md.classList.remove('on');
       // TWO: the plate. Standard is 216 at the screen factor; large and small scale it, and what is drawn is the rect
       CFG.minimap=1; CFG.mmSz=1; CFG.mmSpan=1000; R=hudRes(); draw();
       if(!MMAP.box) return 'SKIP: the minimap was not drawn here';
       w0=MMAP.box.w; if(w0!==Math.round(216*R)) bad.push('TWO: control: the standard plate is '+w0+' wide, not '+Math.round(216*R));
       bs0=MMAP.bs; bb=MMAP.box.y+MMAP.box.h;
       CFG.mmSz=1.35; draw(); if(MMAP.box.w!==Math.round(216*R*1.35)) bad.push('TWO: LARGE drew a plate '+MMAP.box.w+' wide, not '+Math.round(216*R*1.35));
       if(!(MMAP.box.y+MMAP.box.h>bb)) bad.push('TWO: LARGE did not grow the plate down');
       if(MMAP.box.x+MMAP.box.w>Math.round(W-16*R)+1) bad.push('TWO: LARGE left the screen corner');
       CFG.mmSz=0.75; draw(); if(MMAP.box.w!==Math.round(216*R*0.75)) bad.push('TWO: SMALL drew a plate '+MMAP.box.w+' wide, not '+Math.round(216*R*0.75));
       CFG.mmSz=1;
       // THREE: the span: closer shows less street over the same plate, so the bake is made at a bigger scale; wider the other way
       CFG.mmSpan=700; draw(); bw=MMAP.bs; if(!(bw>bs0*1.3&&bw<bs0*1.55)) bad.push('THREE: CLOSE baked at '+bw+' against '+bs0+' standard, not about 1.43 times');
       CFG.mmSpan=1400; draw(); bw=MMAP.bs; if(!(bw<bs0*0.8&&bw>bs0*0.65)) bad.push('THREE: WIDE baked at '+bw+' against '+bs0+' standard, not about 0.71 times');
       if(mmSpan()!==1400) bad.push('THREE: mmSpan reads '+mmSpan());
       CFG.mmSpan=1000; draw(); if(Math.abs(MMAP.bs-bs0)>1e-6) bad.push('THREE: back at STANDARD the bake is '+MMAP.bs+', not '+bs0);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CFG.mmSz=kS; CFG.mmSpan=kZ; CFG.minimap=kM; }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
