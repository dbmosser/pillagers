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

if ($s.Contains("  {v:'33.51',what:")) { throw "check 33.51 is in the fixture already" }

SubRx @'
  {v:'33.50',what:
'@ @'
  {v:'33.51',what:'cw-pixkit (86a): the pixel look row (local, on), pinned off in the fixture; pixBlit draws on whole device pixels and only edge pixels blend at a part scale; the caches evict past their cap; a 3rd build in a frame is refused and draws the nearest pose; the ramp tables keep their value bands; with the switch off a raid frame is the same',
   run:function(){
     if(typeof pixOn!=='function'||typeof pixBlit!=='function'||typeof PIXSTORE!=='object'||typeof pixBuild!=='function'||typeof pixCanvas!=='function') return 'no pixel kit (pixOn, pixBlit, PIXSTORE, pixBuild)';
     var bad=[], row=null, i, oldCapA=PIXSTORE.cap.actors, oldPO=pixOn, sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, h0, h1, d, s, spr, t;
     function fnv(c){ var q=c.getContext('2d').getImageData(0,0,c.width,c.height).data, h=2166136261, k; for(k=0;k<q.length;k+=4){ h^=q[k]; h=Math.imul(h,16777619); h^=q[k+1]; h=Math.imul(h,16777619); h^=q[k+2]; h=Math.imul(h,16777619); } return (h>>>0).toString(16); }
     function dest(){ return pixCanvas(24,24); }
     function px(dd,x,y){ var o=(y*24+x)*4; return [dd[o],dd[o+1],dd[o+2],dd[o+3]]; }
     function is(p,r,b){ return p[3]===255&&p[0]===r&&p[1]===0&&p[2]===b; }
     function ent(by){ var q=pixCanvas(4,4); var e=pixSprite(q.c,0,0,1); e.bytes=by; return e; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(i=0;i<XF_ROWS.length;i++) if(XF_ROWS[i][0]==='xfPix') row=XF_ROWS[i];
       if(!row) bad.push('no xfPix row in the experimental list'); else if(row[3]!=='l') bad.push('the pixel look row is scope '+row[3]+', not l');
       if(DEF.xfPix!==1) bad.push('the pixel look default is '+DEF.xfPix+', not on');
       if(CFG.xfPix!==0) bad.push('a fresh fixture does not pin the pixel look off (xfPix '+CFG.xfPix+')');
       CFG.xfPix=1; __pinDefaults(0); if(CFG.xfPix!==0) bad.push('__pinDefaults does not pin the pixel look off');
       if(pixOn()) bad.push('pixOn is true with the switch off');
       CFG.xfPix=1; if(!pixOn()) bad.push('pixOn is false with the switch on'); CFG.xfPix=0;
       // pixBlit: a 3x3 sprite, left column red, the rest blue
       s=pixCanvas(3,3); s.x.fillStyle='#ff0000'; s.x.fillRect(0,0,1,3); s.x.fillStyle='#0000ff'; s.x.fillRect(1,0,2,3); spr=pixSprite(s.c,0,0,1);
       d=dest(); pixBlit(spr,10.4,10.6,false,d.x,1); t=d.x.getImageData(0,0,24,24).data;
       (function(){ var n=0,x,y,p; for(y=0;y<24;y++) for(x=0;x<24;x++){ p=px(t,x,y); if(!p[3]) continue; n++; if(!(x>=10&&x<=12&&y>=11&&y<=13)) bad.push('S 1: a pixel at '+x+','+y+' is outside the snapped box'); else if(!is(p,x===10?255:0,x===10?0:255)) bad.push('S 1: pixel '+x+','+y+' is '+p.join('/')); } if(n!==9) bad.push('S 1 drew '+n+' pixels, not 9'); })();
       d=dest(); pixBlit(spr,10.2,10.2,false,d.x,2); t=d.x.getImageData(0,0,24,24).data;
       (function(){ var n=0,x,y,p; for(y=0;y<24;y++) for(x=0;x<24;x++){ p=px(t,x,y); if(!p[3]) continue; n++; if(!(x>=10&&x<=15&&y>=10&&y<=15)) bad.push('S 2: a pixel at '+x+','+y+' is outside the box'); else if(!is(p,x<12?255:0,x<12?0:255)) bad.push('S 2: pixel '+x+','+y+' is '+p.join('/')); } if(n!==36) bad.push('S 2 drew '+n+' pixels, not 36'); })();
       d=dest(); pixBlit(spr,10,10,true,d.x,2); t=d.x.getImageData(0,0,24,24).data;
       if(!is(px(t,8,11),255,0)||!is(px(t,9,11),255,0)||!is(px(t,4,11),0,255)||!is(px(t,7,11),0,255)||px(t,10,11)[3]) bad.push('S 2 flipped: the sprite is not mirrored on its anchor');
       d=dest(); pixBlit(spr,10,10,false,d.x,4/3); t=d.x.getImageData(0,0,24,24).data;
       (function(){ var x,y,p,mid=0; for(y=0;y<24;y++) for(x=0;x<24;x++){ p=px(t,x,y); if(p[3]&&!(x>=10&&x<=13&&y>=10&&y<=13)) bad.push('S 1.333: a pixel at '+x+','+y+' is outside the 4x4 box'); }
         for(y=11;y<=12;y++){ p=px(t,10,y); if(!(p[0]>=200&&p[2]<=60)) bad.push('S 1.333: the red edge is '+p.join('/')); for(x=12;x<=13;x++){ p=px(t,x,y); if(!(p[2]>=200&&p[0]<=60)) bad.push('S 1.333: the blue part is '+p.join('/')+' at '+x); } p=px(t,11,y); if(p[1]>3) bad.push('S 1.333: the join drew a third colour '+p.join('/')); if(!is(p,255,0)&&!is(p,0,255)) mid++; }
         if(mid>2) bad.push('S 1.333: '+mid+' blended pixels, only the edge column should blend'); })();
       // the LRU
       PIXSTORE.cap.actors=9000; pixDropAll(); i=PIX.evict;
       pixPut('actors','a',ent(4000)); pixPut('actors','b',ent(4000)); pixGet('actors','a'); pixPut('actors','c',ent(4000));
       if(PIXSTORE.m.actors.has('b')||!PIXSTORE.m.actors.has('a')||!PIXSTORE.m.actors.has('c')) bad.push('the LRU did not evict the least recently used entry');
       if(PIXSTORE.bytes.actors>9000) bad.push('the actors cache holds '+PIXSTORE.bytes.actors+' bytes past its 9000 cap');
       if(PIX.evict<=i) bad.push('an eviction was not counted');
       PIXSTORE.cap.actors=oldCapA; pixDropAll();
       if(PIXSTORE.cap.actors!==24*1048576||PIXSTORE.cap.scene!==16*1048576) bad.push('the caps are not 24 MB and 16 MB');
       // the build budget and the nearest pose
       function mkfn(){ var q=pixCanvas(4,4); return pixSprite(q.c,0,0,1); }
       pixFrame(); var r1=pixBuild('scene','k4',mkfn,'fam',4), r2=pixBuild('scene','k9',mkfn,'fam',9), rf=PIX.refused, r3=pixBuild('scene','k5',mkfn,'fam',5);
       if(!r1||!r2) bad.push('the first two builds in a frame were refused');
       if(r3||PIX.refused!==rf+1) bad.push('a 3rd build in one frame was not refused');
       if(pixFetch('scene','k5',mkfn,'fam',5)!==r1) bad.push('a refused build did not draw the nearest cached pose');
       pixFrame(); if(!pixBuild('scene','k5',mkfn,'fam',5)) bad.push('the budget did not start over with the next frame');
       pixFrame(); PIX.fMs=3; if(pixBuild('scene','k6',mkfn,'fam',6)) bad.push('a build went ahead after 2 ms of baking in the frame'); pixFrame();
       pixDropAll();
       if(typeof pixTelRow!=='function'||['builds','ms','hits','miss','bytes','S'].some(function(k){ return pixTelRow()[k]===undefined; })) bad.push('the pix telemetry row is missing a field');
       // the ramp tables keep their value bands
       (function(){ var nm,k,q,r,l,b,lo,hi,names=['floor','wall','top','act']; for(nm in PIXRAMPS.districts) for(k in PIX_BANDS){ for(q=0;q<4;q++){ r=PIXRAMPS.districts[nm][k][names[q]]; b=PIX_BANDS[k][names[q]]; if(!r||r.length!==4){ bad.push(nm+' '+k+' '+names[q]+' is not a 4 tone ramp'); continue; }
         l=pixHsl(r[0])[2]*100; lo=pixHsl(r[3])[2]*100; if(l>b[1]+1.5||lo<b[0]-1.5) bad.push(nm+' '+k+' '+names[q]+' ramp runs '+lo.toFixed(1)+' to '+l.toFixed(1)+', outside '+b[0]+'-'+b[1]); } } })();
       if(Object.keys(PIXRAMPS.districts).length!==4||!PIXRAMPS.skins.fair||!PIXRAMPS.skins.tan||!PIXRAMPS.skins.umber||!PIXRAMPS.mb.gm||!PIXRAMPS.plants.leaf) bad.push('the ramp tables miss a district, a skin, the plants or the machine palette');
       // ?pixbench
       (function(){ var el=pixBenchOpen(), n=Object.keys(PIX.reg).length; if(!el||!document.getElementById('pixbench')) bad.push('the pixel bench did not open'); else { if(el.getElementsByTagName('canvas').length!==2*n) bad.push('the pixel bench shows '+el.getElementsByTagName('canvas').length+' pictures for '+n+' assets'); if(!n&&String(el.textContent).indexOf('no pixel assets registered yet')<0) bad.push('an empty pixel bench does not say so'); el.remove(); } })();
       // with the switch off, a raid frame is the same as with every pixel path stubbed off
       CFG.xfPix=0; __forceSize(1920,1080); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       for(i=0;i<3;i++) __frame(0.016);
       h0=fnv(cv); __frame(0.016); if(fnv(cv)!==h0) bad.push('the raid frame is not steady between two frames, so it cannot be compared');
       pixOn=function(){ return false; }; __frame(0.016); h1=fnv(cv); pixOn=oldPO;
       if(h1!==h0) bad.push('with the pixel look off the raid frame differs from the frame with every pixel path stubbed off');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel kit check: '+String(err&&err.message||err);
     } finally {
       pixOn=oldPO; PIXSTORE.cap.actors=oldCapA; try{ pixDropAll(); pixFrame(); }catch(_p){}
       try{ var be=document.getElementById('pixbench'); if(be) be.remove(); }catch(_b){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
