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

if ($s.Contains("  {v:'33.81',what:")) { throw "check 33.81 is in the fixture already" }

SubRx @'
  {v:'33.80',what:
'@ @'
  {v:'33.81',what:'cw-pixgear (86g): with the pixel look on armour tiers 1 to 3 are pixel plates of growing width, the golden pillager bot is a baked gold palette drawn with no ctx.filter and no scratch canvas, the elite ring is a baked pixel ring that pulses and strokes no vector ellipse, the chase tell changes the eyes and brows, and each party seat wears its own SEATCOL trim',
   run:function(){
     if(typeof pixDrawOp!=='function'||typeof pxEliteRing!=='function'||typeof PXB_GOLD==='undefined'||typeof PXB_ARM==='undefined') return 'no pixel armour, gold and elite ring (pxEliteRing, PXB_GOLD, PXB_ARM)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__gfxCount)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], g, saved=false, i, M, r, w=[], up, a, al=[], gb, nf=0, sh0=null, e, cnt, gold, red, dd, k, hex, GC={}, RC={}, ck, lk0, t0, before, keys2=[], filt0, seat=[];
     function px(c){ return c.getContext('2d').getImageData(0,0,c.width,c.height).data; }
     function bboxW(c){ var d2=px(c), x, y, x0=1e9, x1=-1; for(y=0;y<c.height;y++) for(x=0;x<c.width;x++) if(d2[(y*c.width+x)*4+3]){ if(x<x0)x0=x; if(x>x1)x1=x; } return x1-x0+1; }
     function maps(){ var Mp=new Map(); PIXSTORE.m.actors.forEach(function(en,key){ Mp.set(en.c,{p:en,key:key}); }); return Mp; }
     function rec1(fn){
       var d0=wc.drawImage, out=[];
       wc.drawImage=function(src){ out.push({s:src,a:wc.globalAlpha}); return d0.apply(wc,arguments); };
       try{ fn(); } finally{ delete wc.drawImage; }
       return out;
     }
     function draw1(s,mode,face){ pixFrame(); drawOp(600,500,face||0,0,'#242832',0,0,mode||'',0,s); }
     function body(s,mode,face,tr){ var j, b4=PIX.bodies; for(j=0;j<(tr||14)&&PIX.bodies===b4;j++) draw1(s,mode,face); return PIX.bodies>b4; }
     function upO(o){ var q={head:'short',skin:'fair',clothes:'scav',bot:1,mir:0,pup:0,arms:1,lamp:'',band:'',low:0,bulk:0,tell:0}, z; for(z in o) q[z]=o[z]; return q; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; g=__state();
       if(!g||g.over) return 'SKIP: no raid';
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       t0=g.t;
       // armour: 3 tiers of growing width, drawn in pixels for a bot and for the player
       for(i=0;i<4;i++){ up=pxBuildUpper(upO({bulk:i})); w.push(bboxW(up.c)); }
       if(!(w[1]>0&&w[3]>w[1])) bad.push('armour 3 is not wider than armour 1 ('+w.join(',')+')');
       if(px(pxBuildUpper(upO({bulk:1})).c).join()===px(pxBuildUpper(upO({bulk:0})).c).join()) bad.push('armour 1 looks like no armour');
       if(px(pxBuildUpper(upO({bulk:2})).c).join()===px(pxBuildUpper(upO({bulk:3})).c).join()) bad.push('armour 2 looks like armour 3');
       [1,2,3].forEach(function(b){
         var sb={own:{kind:'raider',x:600,y:500,hp:50,wep:{id:'rifle'}},team:'foe',merc:0,moving:false,sprint:false,ads:false,hurt:0,bulk:b,rl:0};
         if(!body(sb,'',0,16)) bad.push('a bot in armour '+b+' was not drawn in pixels');
       });
       if(!body({hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:2,rl:0},'',0,16)) bad.push('the player in armour 2 was not drawn in pixels');
       // the golden bot: gold palette, no filter, no scratch canvas
       e={kind:'raider',golden:1,x:600,y:500,r:11,hp:50,wep:{id:'rifle'},state:'idle'};
       gb=goldBodyBegin(e); if(gb){ goldBodyAbort(); bad.push('the golden pillager bot still takes the scratch canvas'); }
       filt0=Object.getOwnPropertyDescriptor(wc,'filter');
       Object.defineProperty(wc,'filter',{configurable:true,set:function(){ nf++; },get:function(){ return 'none'; }});
       try{
         gold={own:e,team:'foe',merc:0,moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
         if(!body(gold,'',0,16)) bad.push('the golden bot was not drawn in pixels');
         for(i=0;i<8;i++){ g.t=i*0.25; draw1(gold,'',0); }
       } finally { delete wc.filter; if(filt0) Object.defineProperty(wc,'filter',filt0); }
       if(nf) bad.push('ctx.filter was set '+nf+' times while drawing the golden bot');
       dd=px(pxBuildUpper(upO({bot:2})).c); for(k=0;k<dd.length;k+=4){ if(!dd[k+3]) continue; hex='#'+((1<<24)+(dd[k]<<16)+(dd[k+1]<<8)+dd[k+2]).toString(16).slice(1); GC[hex]=(GC[hex]||0)+1; }
       if((GC[PXB_GOLD.coat[1]]||0)<80) bad.push('the golden bot has only '+(GC[PXB_GOLD.coat[1]]||0)+' body gold pixels');
       dd=px(pxBuildUpper(upO({bot:2})).c); ck=0; for(k=0;k<dd.length;k+=4){ if(!dd[k+3]) continue; hex='#'+((1<<24)+(dd[k]<<16)+(dd[k+1]<<8)+dd[k+2]).toString(16).slice(1); if(hex===PXB_REDS.coat[1]||hex===PXB_REDS.coat[2]) ck++; }
       if(ck) bad.push('the golden bot wears '+ck+' red coat pixels');
       // the elite ring is a baked pixel ring that pulses, with no vector stroke
       nf=0;
       for(i=0;i<11;i++){
         g.t=i*0.2; pixFrame(); if(i===0){ cnt=__gfxCount([wc],['stroke','arc','ellipse'],function(){ pxEliteRing({x:600,y:500,r:11}); }); if((cnt.calls.stroke||0)||(cnt.calls.ellipse||0)) bad.push('the elite ring still strokes a vector ellipse'); }
         r=rec1(function(){ if(!pxEliteRing({x:600,y:500,r:11})) bad.push('the elite ring was not drawn'); }); M=maps();
         r.forEach(function(q){ var z=M.get(q.s); if(z&&z.p.elite){ al.push(q.a); dd=px(q.s); for(k=3;k<dd.length;k+=4) if(dd[k]!==0&&dd[k]!==255){ nf++; break; } } });
       }
       if(al.length<11) bad.push('the elite ring drew in '+al.length+' of 11 frames'); else if(Math.max.apply(null,al)-Math.min.apply(null,al)<0.1) bad.push('the elite ring alpha does not pulse');
       if(nf) bad.push('the elite ring holds a blended pixel');
       // the tell changes the eyes and the brows
       a=px(pxBuildUpper(upO({tell:0})).c); up=px(pxBuildUpper(upO({tell:1})).c); k=0; for(i=0;i<a.length;i++) if(a[i]!==up[i]) k++;
       if(k<12) bad.push('the chase tell changes only '+k+' bytes of the body');
       before=PIX.bodies; if(!body({own:{kind:'raider',x:600,y:500,hp:50,wep:{id:'rifle'}},team:'foe',merc:0,moving:false,sprint:false,ads:false,hurt:0,bulk:0,tell:0.3,rl:0},'',0,16)) bad.push('a bot in its tell was not drawn in pixels');
       // each party seat wears its own trim
       sh0=seatHere;
       try{
         [0,1].forEach(function(s){
           seatHere=function(){ return 0; };
           var ss={own:{seat:s,kind:undefined,hp:80,wep:{id:'rifle'}},team:'ally',merc:0,moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
           if(!body(ss,'',0,16)){ bad.push('seat '+s+' was not drawn in pixels'); return; }
           M=maps(); var hit=0; PIXSTORE.m.actors.forEach(function(en,key){ if(key.indexOf('|'+SEATCOL[s]+'|')>0) hit=1; });
           if(!hit) bad.push('seat '+s+' wears no '+SEATCOL[s]+' trim');
           seat.push(s);
         });
       } finally { seatHere=sh0; }
       if(SEATCOL[0]===SEATCOL[1]) bad.push('the first two seats share a colour');
       g.t=t0;
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel gear check: '+String(err&&err.message||err);
     } finally {
       try{ delete wc.drawImage; }catch(_d){}
       try{ delete wc.filter; if(filt0) Object.defineProperty(wc,'filter',filt0); }catch(_f){}
       try{ if(sh0) seatHere=sh0; }catch(_s){}
       try{ if(g&&t0!==undefined) g.t=t0; }catch(_p){}
       if(saved){ try{ wc.restore(); }catch(_r){} }
       CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
