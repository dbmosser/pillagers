$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.25 CHECK, inserted before the v12.24 entry. The canvas is forced to 4K,
# 1440p and 1080p in turn (the pane itself stays where it is; titleRes reads
# W and H) and the corner readout must carry the window zoom and grow with the
# monitor; the floor answer line must carry it too; the real Text size button
# must move the readout; and two controls guard what the growth could break at
# 1080p: the stash top row (CLOSE) must stay clear of the wider readout, and a
# raid must still start its CONDITIONS box under the readout (v11.78).
SubRx @'
  {v:'12.24',what:'with the raid clock switched OFF the boarding window is the full 30 seconds and the call line does not say the clock runs out first; with the clock on at 12 seconds left the window is 11 (2026-09-06 in-raid audit)',
'@ @'
  {v:'12.25',what:'the corner credits and XP readout and the floor answer line carry the window zoom: at 4K and 1440p they follow the monitor and the Text size setting like every window, and at 1080p the readout still clears the stash top row and the raid CONDITIONS box (his note of 2026-09-07)',
   run:function(){
     if(!(window.__forceSize&&window.__hubEnter&&window.__showScreen&&window.__P&&window.__deploy&&window.__frame&&window.__state&&window.__endRaid&&window.__pinDPR)) return 'SKIP: this fixture cannot resize and deploy';
     if(typeof applyMenuZoom!=='function'||typeof titleRes!=='function') return 'SKIP: no menu zoom in this build';
     var el=document.getElementById('topright'), toast=document.getElementById('hubtoast');
     if(!el||!toast) return 'SKIP: no corner readout or floor answer line in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], P2=__P(), keepZ=P2.menuZoom, keepU=P2.uiScale, keepC=P2.credits, keepX=P2.xp;
     function rd(){ var r=el.getBoundingClientRect(); return {z:parseFloat(el.style.zoom)||1,h:r.height||0,w:r.width||0,l:r.left,r:r.right,b:r.bottom}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1);
       try{ var g0=__state(); if(g0&&!g0.over) __endRaid('abandon'); }catch(_0){}
       keys={}; __showScreen('hub'); __hubEnter();
       P2.credits=1234567; P2.xp=12345; P2.menuZoom=1.3; delete P2.uiScale; saveProfile();   // distinctive and seven figures wide; saveProfile runs syncTopRight
       __forceSize(1920,1080); applyMenuZoom();
       var a=rd();
       if(!(a.h>0&&a.w>0)) return 'SKIP: the readout has no box at 1080p ('+a.w.toFixed(0)+'x'+a.h.toFixed(0)+')';
       // THE FINDING, 4K: on v12.24 el.style.zoom is empty, so the readout is the same 44 pixels at every size.
       __forceSize(3840,2160); applyMenuZoom();
       if(!(W>=3000)) return 'SKIP: the canvas would not go to 4K ('+W+'x'+H+')';
       var want=Math.max(1,P2.menuZoom)*titleRes(), c=rd();
       if(Math.abs(c.z-want)>0.05) bad.push('at 4K the readout zoom is '+c.z+' where the windows are at '+want.toFixed(2));
       if(!(c.h>a.h*1.4)) bad.push('at 4K the readout is '+c.h.toFixed(0)+'px tall against '+a.h.toFixed(0)+' at 1080p: it did not follow the monitor');
       var tz=parseFloat(toast.style.zoom)||1;
       if(Math.abs(tz-want)>0.05) bad.push('the floor answer line is at zoom '+tz+', not '+want.toFixed(2));
       // 1440p sits between the two.
       __forceSize(2560,1440); applyMenuZoom();
       var b=rd();
       if(!(b.h>a.h*1.2&&b.h<c.h)) bad.push('at 1440p the readout is '+b.h.toFixed(0)+'px tall, not between 1080p ('+a.h.toFixed(0)+') and 4K ('+c.h.toFixed(0)+')');
       // THE TEXT SIZE SETTING REACHES IT: the real Settings button, not the field.
       __forceSize(1920,1080); P2.menuZoom=1.3; delete P2.uiScale; applyMenuZoom();
       var h0=rd().h;
       if(typeof renderSettings==='function'&&document.getElementById('setlist')){
         renderSettings();
         var bt=document.getElementById('set_text');
         if(bt){ bt.click(); var h1=rd().h; if(!(Math.abs(h1-h0)>1)) bad.push('the Text size button did not move the readout, '+h0.toFixed(0)+' then '+h1.toFixed(0)); }
         else bad.push('staging: no Text size button in Settings');
       }
       P2.menuZoom=1.3; delete P2.uiScale; applyMenuZoom();
       // CONTROL ONE, 1080p: the readout is 1.3 times wider now and must still clear the stash top row (CLOSE).
       var hub=document.getElementById('hub');
       if(hub){ try{ renderHub(); }catch(_rh){} hub.classList.add('on'); }
       var r2=el.getBoundingClientRect(), tr=hub?hub.querySelector('.toprow'):null;
       if(tr){
         var bs=tr.querySelectorAll('button'), i;
         for(i=0;i<bs.length;i++){ var r1=bs[i].getBoundingClientRect(); if(r1.width>0&&r1.right>r2.left&&r1.left<r2.right&&r1.bottom>r2.top&&r1.top<r2.bottom) bad.push('control: at 1080p the readout ('+Math.round(r2.left)+'..'+Math.round(r2.right)+') covers the stash top row button "'+(bs[i].textContent||'').trim()+'" ('+Math.round(r1.left)+'..'+Math.round(r1.right)+')'); }
       } else bad.push('staging: no stash top row to measure against');
       if(hub) hub.classList.remove('on');
       // CONTROL TWO: a raid still starts CONDITIONS under the zoomed readout, the v11.78 rule.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __frame(0.016); __frame(0.016);
       var rb=el.getBoundingClientRect().bottom, C=(typeof HUDBOX!=='undefined')?HUDBOX.cond:null;
       if(!C) bad.push('control: the raid drew no CONDITIONS box');
       else if(C.y<rb-0.5) bad.push('control: the CONDITIONS box starts at '+C.y.toFixed(0)+', above the readout bottom at '+rb.toFixed(0));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       P2.menuZoom=keepZ; if(keepU===undefined) delete P2.uiScale; else P2.uiScale=keepU; P2.credits=keepC; P2.xp=keepX;
       try{ saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ var hb2=document.getElementById('hub'); if(hb2) hb2.classList.remove('on'); }catch(_h){}
       try{ __forceSize(1920,1080); applyMenuZoom(); }catch(_f){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.24',what:'with the raid clock switched OFF the boarding window is the full 30 seconds and the call line does not say the clock runs out first; with the clock on at 12 seconds left the window is 11 (2026-09-06 in-raid audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
