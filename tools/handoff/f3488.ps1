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

if ($s.Contains("  {v:'34.88',what:")) { throw "check 34.88 is in the fixture already" }

SubRx @'
  {v:'34.87',what:
'@ @'
  {v:'34.88',what:'cw-mmfold, his note of 2026-10-25 ("make it where it is minimizable"): with the minimap on, a click on its chevron folds it to a slim strip named minimap with a closed chevron, the run info panel moves up under the strip, a second click on the same spot opens it at full size, a press on it never drags it, the fold leaves the Settings MINIMAP row alone, the click box is the fold tab that is drawn and a press on the map beside it still fires, run info dragged over the tab keeps its own click, with the minimap folded from the raid start the map is still baked so the first unfold never bakes mid raid, and with the minimap off or the map open nothing of it is drawn or takes a click; in the career raid at the window size and at 4K, the player 2 seat and the demo',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof drawMinimap!=='function'||typeof MMAP!=='object'||!MMAP||typeof hudHit!=='function'||typeof hudChev!=='function'||typeof inRect!=='function'||typeof cv==='undefined'||!cv||typeof hcv==='undefined'||!hcv||typeof resize!=='function'||!window.__forceSize||typeof mouse==='undefined') return 'SKIP: no raid HUD with a minimap here';
     var bad=[], g=null, P0=P, kHud=JSON.stringify((P&&P.hud)||null), kS=CFG.mmSz, kM=CFG.minimap, kNet={on:NET.on,role:NET.role,seat:NET.seat,same:NET.same}, PR=CanvasRenderingContext2D.prototype, oft=PR.fillText, ofr=PR.fillRect, ochev=hudChev, txt=[], chev=[], rects=[], rec=0, km={x:mouse.x,y:mouse.y}, dz=(typeof DPRH==='number'&&DPRH>0)?DPRH:1, ksz=null;
     function unforce(){ cv.style.width=ksz[0]; cv.style.height=ksz[1]; hcv.style.width=ksz[2]; hcv.style.height=ksz[3]; resize(); }   // the canvas back at the window size it had, not a fixed 1920 by 1080
     function frame(){ __frame(0); txt.length=0; chev.length=0; rects.length=0; rec=1; try{ __frame(0); }finally{ rec=0; } }
     function inside(q,b,m){ m=m||0; return !!b&&q.x>=b.x-m&&q.x<=b.x+b.w+m&&q.y>=b.y-m&&q.y<=b.y+b.h+m; }
     function named(b){ for(var i=0;i<txt.length;i++) if(txt[i].t==='minimap'&&inside(txt[i],b,2)) return true; return false; }
     function chevIn(b,open){ for(var i=0;i<chev.length;i++) if(chev[i].open===open&&inside(chev[i],b,2)) return true; return false; }
     function drawnAs(b){ for(var i=0;i<rects.length;i++){ var o=rects[i]; if(Math.abs(o.x-b.x)<=1&&Math.abs(o.y-b.y)<=1&&Math.abs(o.w-b.w)<=1&&Math.abs(o.h-b.h)<=1) return true; } return false; }
     function press(q,dn){
       var rc=cv.getBoundingClientRect(), d, f;
       mouse.x=q.x; mouse.y=q.y; mouse.down=false; HUDDRAG=null;
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,clientX:q.x+rc.left,clientY:q.y+rc.top,bubbles:true,cancelable:true}));
       d=HUDDRAG?HUDDRAG.id:null; f=!!mouse.down;
       window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})); mouse.down=false; HUDDRAG=null;
       return dn?f:d;
     }
     // what the HUD canvas really draws this frame: every string (as drawn, after TX), every chevron and every filled rectangle, at its spot on the screen
     PR.fillText=function(t,x,y){ if(rec&&typeof t==='string'){ var m=this.getTransform(); txt.push({t:(typeof TX==='function')?String(TX(t)):t,x:(m.a*x+m.c*y+m.e)/dz,y:(m.b*x+m.d*y+m.f)/dz}); } return oft.apply(this,arguments); };
     PR.fillRect=function(x,y,w,h){ if(rec){ var m=this.getTransform(); rects.push({x:(m.a*x+m.e)/dz,y:(m.d*y+m.f)/dz,w:m.a*w/dz,h:m.d*h/dz}); } return ofr.apply(this,arguments); };
     hudChev=function(xr,yb,open){ if(rec){ var m=ctx.getTransform(), cx=xr-Math.max(3,LH(4))-1, cy=yb-LH(4); chev.push({open:!!open,x:(m.a*cx+m.c*cy+m.e)/dz,y:(m.b*cx+m.d*cy+m.f)/dz}); } return ochev.apply(this,arguments); };
     function side(tag){
       var b0, b1, c0, c1, h0, tg, q, q2, hh, go0, kk, nb;
       g=__state(); if(!g||g.over||!g.player){ bad.push(tag+': staging: no raid'); return; }
       g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.mapFirst=0; g.paused=false; g.wheel=null; g.trade=null; g.drag=null;
       for(kk in keys) keys[kk]=false; mouse.down=false;
       P.hud={}; CFG.minimap=1; CFG.mmSz=1; go0=JSON.stringify(P.gameOpts||null);
       frame(); b0=MMAP.box; c0=HUDBOX.cond?HUDBOX.cond.y:null;
       if(!b0||!(b0.h>100)){ bad.push(tag+': staging: no minimap with the Settings row on standard'); return; }
       h0=b0.h;
       if(!HUDBOX.mmap||!HUDBOX.mmap.tg){ bad.push(tag+': the open minimap has no fold (no chevron to click, no HUDBOX.mmap)'); return; }
       tg={x:HUDBOX.mmap.tg.x,y:HUDBOX.mmap.tg.y,w:HUDBOX.mmap.tg.w,h:HUDBOX.mmap.tg.h}; q={x:Math.round(tg.x+tg.w/2),y:Math.round(tg.y+tg.h/2)};
       if(!inside(q,b0)) bad.push(tag+': the chevron is not on the minimap');
       if(!chevIn(tg,true)) bad.push(tag+': no open chevron is drawn on the minimap corner');
       hh=hudHit(q.x,q.y); if(!hh||hh.id!=='mmap'||hh.part!=='glyph') bad.push(tag+': over the chevron the pointer is not the hand ('+(hh?hh.id+' '+hh.part:'nothing')+')');
       // the click box is the fold tab that is drawn, no taller and no wider, and a press on the map just under it or just left of it is a shot
       if(Math.abs(HUDBOX.mmap.x-tg.x)>1||Math.abs(HUDBOX.mmap.y-tg.y)>1||Math.abs(HUDBOX.mmap.h-tg.h)>1||!drawnAs(HUDBOX.mmap)) bad.push(tag+': the click box of the open fold ('+[HUDBOX.mmap.x,HUDBOX.mmap.y,HUDBOX.mmap.w,HUDBOX.mmap.h].map(Math.round).join(',')+') is not the tab that is drawn');
       [{x:q.x,y:Math.round(HUDBOX.mmap.y+HUDBOX.mmap.h)+3,s:'under'},{x:Math.round(HUDBOX.mmap.x)-3,y:q.y,s:'left of'}].forEach(function(q3){
         var fired=press(q3,1);
         if(P.hud&&P.hud.mmap&&P.hud.mmap.c){ bad.push(tag+': a press on the map just '+q3.s+' the fold tab folded the minimap'); P.hud.mmap.c=false; }
         else if(!fired) bad.push(tag+': a press on the map just '+q3.s+' the fold tab did not fire');
       });
       // ONE: the click on the chevron folds it
       if(press(q)) bad.push(tag+': the click on the chevron started a drag');
       if(!(P.hud&&P.hud.mmap&&P.hud.mmap.c)) bad.push(tag+': the click on the chevron did not fold the minimap');
       frame(); b1=MMAP.box;
       if(!b1||!HUDBOX.mmap||!HUDBOX.mmap.tg) bad.push(tag+': folded, the minimap left no strip to open it from');
       else {
         if(!(b1.h<h0*0.25&&b1.h>=12)) bad.push(tag+': folded, the strip is '+Math.round(b1.h)+' px high against '+Math.round(h0)+' open');
         if(Math.abs(b1.w-b0.w)>2||Math.abs(b1.y-b0.y)>1||Math.abs(b1.x+b1.w-b0.x-b0.w)>2) bad.push(tag+': folded, the strip does not sit where the top of the minimap was');
         if(!named(b1)) bad.push(tag+': folded, the strip is not named minimap ('+txt.filter(function(o){ return inside(o,b1,2); }).map(function(o){ return o.t; }).join('|')+')');
         if(!chevIn(b1,false)) bad.push(tag+': folded, the strip draws no closed chevron');
         if(Math.abs(HUDBOX.mmap.tg.x-tg.x)>1||Math.abs(HUDBOX.mmap.tg.y-tg.y)>1) bad.push(tag+': folded, the chevron is not where the click was');
         if(c0!==null){ c1=HUDBOX.cond?HUDBOX.cond.y:null; if(c1===null||!(c1<c0-(h0-b1.h)*0.8)) bad.push(tag+': folded, the run info panel did not move up (open '+Math.round(c0)+', folded '+c1+')'); else if(c1<b1.y+b1.h) bad.push(tag+': folded, the run info panel climbs over the strip'); }
         if(CFG.mmSz!==1||JSON.stringify(P.gameOpts||null)!==go0) bad.push(tag+': the fold changed the Settings minimap row');
         // TWO: a press on the strip never drags it
         q2={x:Math.round(b1.x+12),y:Math.round(b1.y+b1.h/2)};
         hh=hudHit(q2.x,q2.y); if(hh&&hh.part==='bar') bad.push(tag+': over the strip the pointer is the move cross');
         if(press(q2)||P.hud.mmap.dx||P.hud.mmap.dy) bad.push(tag+': a press on the strip started a drag');
       }
       // THREE: the second click on the same spot opens it
       press(q);
       if(P.hud&&P.hud.mmap&&P.hud.mmap.c) bad.push(tag+': the second click on the chevron did not open the minimap');
       frame();
       if(!MMAP.box||Math.abs(MMAP.box.h-h0)>1) bad.push(tag+': opened again, the minimap is '+(MMAP.box?Math.round(MMAP.box.h):0)+' px high, not '+Math.round(h0));
       if(c0!==null&&(!HUDBOX.cond||Math.abs(HUDBOX.cond.y-c0)>1)) bad.push(tag+': opened again, the run info panel is not back under the minimap');
       // run info dragged up over the fold tab is drawn over it, so it keeps its own click and its own pointer
       if(c0!==null){
         P.hud={cond:{dy:Math.round(b0.y-c0)}}; frame();
         if(!HUDBOX.cond||!HUDBOX.cond.tg||!inRect(HUDBOX.cond.tg,q.x,q.y)||!HUDBOX.mmap) bad.push(tag+': staging: run info dragged up does not cover the fold tab (run info at '+(HUDBOX.cond?Math.round(HUDBOX.cond.y):'none')+', the minimap at '+Math.round(b0.y)+')');
         else {
           hh=hudHit(q.x,q.y); if(!hh||hh.id!=='cond') bad.push(tag+': with run info dragged over the fold tab the pointer answers for '+(hh?hh.id+' '+hh.part:'nothing'));
           press(q);
           if(P.hud.mmap&&P.hud.mmap.c) bad.push(tag+': with run info dragged over the fold tab a click there folded the minimap under it');
           if(!(P.hud.cond&&P.hud.cond.c)) bad.push(tag+': with run info dragged over the fold tab a click on its chevron did not fold run info');
         }
         P.hud={}; frame();
       }
       // the bake: folded from the raid start (no bake of this map yet), the map is still baked, so the first unfold draws from the bake and never bakes mid raid
       P.hud={mmap:{c:1}}; MMAP.map=null; nb=MMAP.bakes; frame();
       if(!(MMAP.bakes>nb)||MMAP.map!==G.map||!MMAP.cv) bad.push(tag+': folded at the raid start, the map is not baked, so the first unfold bakes it mid raid');
       nb=MMAP.bakes; P.hud.mmap.c=false; frame();
       if(MMAP.bakes!==nb) bad.push(tag+': the first unfold baked the map on that frame ('+(MMAP.bakes-nb)+' bakes)');
       P.hud={};
       // FOUR: off in Settings (folded or not) and under the open map, nothing of it is drawn or takes a click
       P.hud.mmap={c:1}; CFG.mmSz=0; frame();
       if(MMAP.box||HUDBOX.mmap||named({x:0,y:0,w:W,h:H})) bad.push(tag+': with the minimap off a folded strip is still drawn or takes a click');
       CFG.mmSz=1; frame(); if(!HUDBOX.mmap) bad.push(tag+': staging: the folded strip did not come back with the row on'); g.mapOpen=true; frame(); g.mapOpen=false;
       if(HUDBOX.mmap) bad.push(tag+': with the map open the folded minimap still takes a click');
       P.hud={};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine'],safe:null,mapIx:0,seed:4242});
       side('CAREER');
       // he plays at 4K on a TV: the same steps on a 3840 by 2160 canvas, then the window size again for the player 2 seat and the demo
       ksz=[cv.style.width,cv.style.height,hcv.style.width,hcv.style.height]; __forceSize(3840,2160);
       if(!(W>=3800&&H>=2100)) bad.push('CAREER 4K: staging: the canvas is '+W+' by '+H+', not 4K'); else side('CAREER 4K');
       unforce(); ksz=null;
       // the player 2 window draws its own HUD in seat 1
       NET.on=false; NET.role='join'; NET.seat=1; NET.same='p2';
       side('P2');
       NET.on=kNet.on; NET.role=kNet.role; NET.seat=kNet.seat; NET.same=kNet.same;
       __endRaid('abandon'); __topClear();
       if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('DEMO: staging: arcadeDeploy built no raid');
         else side('DEMO');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       PR.fillText=oft; PR.fillRect=ofr; hudChev=ochev; rec=0;
       try{ NET.on=kNet.on; NET.role=kNet.role; NET.seat=kNet.seat; NET.same=kNet.same; }catch(_n){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) arcadeLeave(); }catch(_l){}
       CFG.mmSz=kS; CFG.minimap=kM; mouse.x=km.x; mouse.y=km.y; mouse.down=false; HUDDRAG=null;
       try{ var hd=JSON.parse(kHud); if(hd) P0.hud=hd; else delete P0.hud; if(P===P0) saveProfile(); }catch(_h){}
       try{ if(ksz) unforce(); }catch(_z){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
