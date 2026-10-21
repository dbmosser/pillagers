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

if ($s.Contains("  {v:'33.69',what:")) { throw "check 33.69 is in the fixture already" }

SubRx @'
  {v:'33.68',what:
'@ @'
  {v:'33.69',what:'cw-pixveg (86d): THE PIXEL TREE, BUSH AND SHADOW. With the pixel look on a canopy, a bush and a ground shadow are art-pixel sprites (ceil(w/2) wide whatever the render resolution, not rebuilt on a zoom step) with only alpha 0 and 255, canopy and bush colours only from the map palette or its dark edge tone, the map trees and walls are untouched, and with the look off the sprite sizes are the old ones',
   run:function(){
     if(typeof pixVegBake!=='function') return 'no pixel veg (pixVegBake)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot build a raid';
     var bad=[], cond0=P.cond, dpr0=DPR, nm, kinds=['tree','bush'], ki, e, e2, pal, ok, px, k, a, hx, n255, W, H, before, after, key, sh, rr=30;
     function hex(r,g,b){ return '#'+((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1); }
     function walls(){ return JSON.stringify(((__state().map.walls)||[]).map(function(w){ return [w.x,w.y,w.w,w.h,w.tree?w.canopy:0]; })); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       before=walls();
       CFG.xfPix=0; P.cond='day';
       for(ki=0;ki<2;ki++){ e=vegSprite(kinds[ki],rr); if(!e||e.px) bad.push('xfPix 0 gives a pixel '+kinds[ki]); }
       CFG.xfPix=1;
       for(nm=0;nm<2;nm++){
         P.cond=nm?'night':'day';
         for(ki=0;ki<2;ki++){
           e=vegSprite(kinds[ki],rr); if(!e||!e.px){ bad.push((nm?'night ':'day ')+kinds[ki]+': not a pixel sprite'); continue; }
           W=Math.ceil((kinds[ki]==='tree'?rr*2+4:rr*1.8+4)/PIX_ENV); H=Math.ceil((kinds[ki]==='tree'?rr*2+4:rr*1.3+4)/PIX_ENV);
           if(e.c.width!==W||e.c.height!==H) bad.push((nm?'night ':'day ')+kinds[ki]+' is '+e.c.width+'x'+e.c.height+', wanted '+W+'x'+H);
           pal=(kinds[ki]==='tree')?(nm?G.vegPal.treeN:G.vegPal.treeD):(nm?G.vegPal.bushN:G.vegPal.bushD);
           ok={}; pal.forEach(function(h2){ var r=pixVegRGB(h2,0), d=pixVegRGB(h2,1); ok[hex(r[0],r[1],r[2])]=1; ok[hex(d[0],d[1],d[2])]=1; });
           px=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data; n255=0;
           for(k=0;k<e.c.width*e.c.height;k++){
             a=px[k*4+3]; if(a!==0&&a!==255){ bad.push((nm?'night ':'day ')+kinds[ki]+': alpha '+a); break; }
             if(a===255){ n255++; hx=hex(px[k*4],px[k*4+1],px[k*4+2]); if(!ok[hx]){ bad.push((nm?'night ':'day ')+kinds[ki]+': colour '+hx+' is not a palette tone'); break; } }
           }
           if(n255<40) bad.push((nm?'night ':'day ')+kinds[ki]+' sprite is nearly empty ('+n255+' pixels)');
         }
       }
       // the sprite does not move with the render resolution
       P.cond='day'; e=vegSprite('tree',rr); DPR=Math.max(1,dpr0)*2; e2=vegSprite('tree',rr);
       if(e2!==e) bad.push('the pixel tree sprite was rebuilt when the render scale changed');
       DPR=dpr0;
       // the shadow stamp
       wc.save(); shadowE(120,120,20,8,0.3); wc.restore();
       key='px:'+Math.round(20*1.12/PIX_ENV)+','+Math.round(8*1.12/PIX_ENV); sh=SHADSPR.m[key];
       if(!sh||!sh.px) bad.push('shadowE laid no pixel stamp '+key);
       else { px=sh.c.getContext('2d').getImageData(0,0,sh.c.width,sh.c.height).data; n255=0;
         for(k=0;k<sh.c.width*sh.c.height;k++){ a=px[k*4+3]; if(a!==0&&a!==255){ bad.push('shadow alpha '+a); break; } if(a===255) n255++; }
         if(n255<20) bad.push('the shadow stamp is nearly empty'); }
       after=walls(); if(after!==before) bad.push('the map walls and trees changed');
       if(pixFaults()) bad.push('pixel faults logged: '+pixFaults());
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel veg check: '+String(err&&err.message||err);
     } finally {
       DPR=dpr0; P.cond=cond0; CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
