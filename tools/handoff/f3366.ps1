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

if ($s.Contains("  {v:'33.66',what:")) { throw "check 33.66 is in the fixture already" }

SubRx @'
  {v:'33.65',what:
'@ @'
  {v:'33.66',what:'cw-pixwalls (86d): THE PIXEL WALL. With the pixel look on a plain wall sprite is ceil(w/2) by round(h/2)+round(lift/2) art pixels whatever the render resolution, every pixel is solid and from the district wall, roof or ink tones with the value bands held (wall 54-60, roof 72-78, day and night), a bullet mark is an ink pixel, and with the look off the sprite sizes are the old ones',
   run:function(){
     if(typeof pixWallBake!=='function') return 'no pixel wall (pixWallBake)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot build a raid';
     var bad=[], map, ws=[], wl, pick=[], cond0=P.cond, dpr0=DPR, i, e, e2, n0, LIFT, d, R, ok, px, p, W, k, hx, l, B, rows, nm, mk, ax, ay;
     function isPlain(w){ return !(w.tree||w.ruin||w.wreck||w.furn||w.win||w.door||w.ledge)&&w.sh===undefined&&w.w>=24&&w.h>=8; }
     function lift(w){ return w.lift||((w.w<=60&&w.h<=60)?14:26); }
     function hex(r,g,b){ return '#'+((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       map=__state().map; ws=(map.walls||[]).filter(isPlain);
       if(!ws.length) return 'no plain wall on the map to sample';
       pick=[ws[0]];
       for(i=0;i<ws.length;i++) if(ws[i].w<=60&&ws[i].h<=60){ pick.push(ws[i]); break; }
       for(i=0;i<ws.length;i++) if(ws[i].w>90&&ws[i].h>20){ pick.push(ws[i]); break; }
       // the look off: the old sprite, scale and margin included
       CFG.xfPix=0; P.cond='day';
       for(i=0;i<pick.length;i++){
         wl=pick[i]; d=wl.d===undefined?3:wl.d; LIFT=lift(wl); e=wallSprite(wl,d,LIFT);
         if(!e||e.px) bad.push('xfPix 0 gives a pixel wall sprite'); else if(e.c.width!==Math.ceil(wl.w*e.ss)+2||e.c.height!==Math.ceil((wl.h+LIFT)*e.ss)+2) bad.push('xfPix 0 sprite size changed: '+e.c.width+'x'+e.c.height);
       }
       CFG.xfPix=1;
       for(nm=0;nm<2;nm++){
         P.cond=nm?'night':'day'; B=PIX_BANDS[nm?'night':'day'];
         for(i=0;i<pick.length;i++){
           wl=pick[i]; d=wl.d===undefined?3:wl.d; LIFT=lift(wl); e=wallSprite(wl,d,LIFT);
           if(!e||!e.px){ bad.push((nm?'night ':'day ')+'wall '+i+': not a pixel sprite'); continue; }
           W=Math.ceil(wl.w/PIX_ENV); rows=Math.round(wl.h/PIX_ENV);
           if(e.c.width!==W||e.c.height!==rows+Math.round(LIFT/PIX_ENV)) bad.push((nm?'night ':'day ')+'wall '+i+' is '+e.c.width+'x'+e.c.height+', wanted '+W+'x'+(rows+Math.round(LIFT/PIX_ENV)));
           R=pixWallRamps(d); ok={}; R.wall.concat(R.top).forEach(function(h2){ ok[h2.toLowerCase()]=1; }); ok[PIX_INK]=1;
           px=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data;
           for(k=0;k<e.c.height*e.c.width;k++){
             p=k*4; hx=hex(px[p],px[p+1],px[p+2]);
             if(px[p+3]!==255){ bad.push((nm?'night ':'day ')+'wall '+i+': alpha '+px[p+3]+' at '+k); break; }
             if(!ok[hx]){ bad.push((nm?'night ':'day ')+'wall '+i+': colour '+hx+' is not a district tone'); break; }
             if(hx===PIX_INK) continue;
             l=pixHsl(hx)[2]*100; rows=Math.max(1,Math.round(wl.h/PIX_ENV));
             var band=(Math.floor(k/e.c.width)<rows)?B.top:B.wall;
             if(l<band[0]-1.5||l>band[1]+1.5){ bad.push((nm?'night ':'day ')+'wall '+i+': lightness '+l.toFixed(1)+' of '+hx+' outside '+band); break; }
           }
         }
       }
       // the sprite count and the sprite itself do not move with the render resolution
       P.cond='day'; wl=pick[0]; d=wl.d===undefined?3:wl.d; LIFT=lift(wl);
       e=wallSprite(wl,d,LIFT); n0=WALLSPR.n; DPR=Math.max(1,dpr0)*2;
       e2=wallSprite(wl,d,LIFT);
       if(e2!==e||WALLSPR.n!==n0) bad.push('the pixel wall sprite was rebuilt when the render scale changed ('+n0+' to '+WALLSPR.n+')');
       DPR=dpr0;
       // a bullet mark is an ink pixel in the sprite
       mk=wallMarkAdd(wl,wl.x+wl.w/2,wl.y+wl.h-1,0,-1);
       if(!mk) bad.push('wallMarkAdd gave no mark on a plain south face');
       else {
         e=wallSprite(wl,d,LIFT); ax=((mk.x-wl.x)/PIX_ENV)|0; ay=((mk.y-(wl.y-LIFT))/PIX_ENV)|0;
         px=e.c.getContext('2d').getImageData(ax,ay,1,1).data;
         if(hex(px[0],px[1],px[2])!==PIX_INK) bad.push('the bullet mark pixel is '+hex(px[0],px[1],px[2])+', not ink');
       }
       if(pixFaults()) bad.push('pixel faults logged: '+pixFaults());
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel wall check: '+String(err&&err.message||err);
     } finally {
       DPR=dpr0; P.cond=cond0; CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
