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

if ($s.Contains("  {v:'24.95',what:")) { throw "check 24.95 is in the fixture already" }

SubRx @'
  {v:'24.94',what:
'@ @'
  {v:'24.95',what:'his order (add minimap): a minimap in the top right of the raid HUD, baked once a raid, a few draw calls a frame, CONDITIONS under it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof drawHUD!=='function'||typeof ctx==='undefined') return 'SKIP: no raid HUD here';
     if(typeof drawMinimap!=='function'||typeof MMAP!=='object'||!MMAP) return 'the raid HUD has no minimap';
     var bad=[], g, i, OWN=Object.prototype.hasOwnProperty, names=['fillRect','fill','stroke','drawImage','fillText','strokeText','strokeRect','putImageData'], own={}, real={}, n=0, srcs=[], b0, b1, bx, cb;
     function wrap(){ names.forEach(function(k){ own[k]=OWN.call(ctx,k); real[k]=ctx[k]; ctx[k]=function(){ n++; if(k==='drawImage') srcs.push(arguments[0]); return real[k].apply(this,arguments); }; }); }
     function unwrap(){ names.forEach(function(k){ if(!(k in real)) return; if(own[k]) ctx[k]=real[k]; else delete ctx[k]; }); real={}; }
     try{
       __topClear(); __runPrep();
       b0=MMAP.bakes;
       __deploy({kit:['gun_carbine'],seed:4242,mapIx:0});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       drawHUD();
       b1=MMAP.bakes;
       if(b1-b0!==1&&!(b1-b0===0&&MMAP.map===g.map)) bad.push('the first raid frame baked the minimap '+(b1-b0)+' times');
       if(MMAP.map!==g.map||!MMAP.cv) bad.push('the minimap bake is not of this raid map');
       bx=MMAP.box;
       if(!bx) bad.push('a raid frame drew no minimap');
       else {
         if(bx.x+bx.w>W+0.5||bx.x<W*0.6||bx.y>H*0.25) bad.push('the minimap is not in the top right corner ('+Math.round(bx.x)+','+Math.round(bx.y)+' '+Math.round(bx.w)+' wide on '+W+'x'+H+')');
         if(Math.abs(bx.w-bx.h)>1) bad.push('the minimap is not square');
         if(!(MMSPAN>=900&&MMSPAN<=1100)) bad.push('the minimap spans '+MMSPAN+' world units');
         cb=HUDBOX.cond;
         if(cb&&cb.x<bx.x+bx.w&&cb.x+cb.w>bx.x&&cb.y<bx.y+bx.h-0.5) bad.push('the CONDITIONS panel overlaps the minimap (panel top '+Math.round(cb.y)+', minimap bottom '+Math.round(bx.y+bx.h)+')');
       }
       for(i=0;i<5;i++) drawHUD();
       if(MMAP.bakes!==b1) bad.push('the minimap baked again on later frames ('+(MMAP.bakes-b1)+' more)');
       n=0; srcs=[];
       wrap(); try{ drawMinimap(); } finally { unwrap(); }
       if(!(n>0)) bad.push('the minimap made no draw calls');
       if(n>24) bad.push('the minimap made '+n+' draw calls in one frame');
       if(srcs.indexOf(MMAP.cv)<0) bad.push('the minimap frame did not draw the baked map');
       // the bake holds the walls: the middle of a solid wall is lighter than the floor
       var wl=null, ws=g.map.walls||[], cv2=MMAP.cv, c2=cv2&&cv2.getContext('2d'), px;
       for(i=0;i<ws.length;i++){ var q=ws[i]; if(!q.furn&&!q.tree&&!q.door&&!q.wreck&&!q.ruin&&!q.ledge&&q.w*MMAP.bs>=3&&q.h*MMAP.bs>=3&&q.x>0&&q.y>0){ wl=q; break; } }
       if(!wl||!c2) bad.push('no solid wall to read in the bake');
       else {
         px=c2.getImageData(Math.floor((wl.x+wl.w/2)*MMAP.bs),Math.floor((wl.y+wl.h/2)*MMAP.bs),1,1).data;
         if(!(px[0]>120&&px[1]>120)) bad.push('the bake has no wall where a wall stands (rgb '+px[0]+','+px[1]+','+px[2]+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ unwrap(); }catch(_u){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
