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

if ($s.Contains("  {v:'33.77',what:")) { throw "check 33.77 is in the fixture already" }

SubRx @'
  {v:'33.76',what:
'@ @'
  {v:'33.77',what:'cw-pixcover (86e) ship 3: cover wrecks (car, skip, barrier, pipes, pallets) are one cached scene sprite each through pixWrap: every one in view is a sprite, none falls back, hard alpha, the size is kept, no clipping and no bake errors',
   run:function(){
     if(typeof pixWrap!=='function'||typeof PIXW!=='object') return 'no adapter: pixWrap is not defined';
     if(!(window.__deploy&&window.__frame&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], calls=[], pw0=pixWrap, cfg0=CFG.xfPix, seen={}, kinds=[], ws, i, j, w, kk, cv, m, e, px, aa, a1, W, H, clip0, e0, nk=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; __frame(0.016);
       ws=G.map.walls.filter(function(q){ return q.wreck; });
       if(!ws.length) return 'SKIP: no cover wreck on this map';
       ws.forEach(function(q){ var k2=q.kind||'car'; if(!seen[k2]){ seen[k2]=q; kinds.push(k2); } });
       pixWrap=function(key,w2,h2,d,paint,x,y,o){ var r=pw0.apply(this,arguments); calls.push({key:key,d:d,e:r}); return r; };
       clip0=PIXW.clip; e0=PIX.errs;
       kinds.slice(0,3).forEach(function(k2){
         w=seen[k2]; G.player.x=w.x+w.w/2; G.player.y=w.y+w.h+70;
         for(i=0;i<40;i++){   // the builder allows 2 bakes a frame, so warm up until every piece in view has its sprite (or 40 frames)
           calls.length=0; __frame(0.016);
           cv=calls.filter(function(c){ return c.key.indexOf('cv:'+k2)===0; });
           if(cv.length&&cv.every(function(c){ return c.e; })) break;
         }
         if(!cv.length){ bad.push(k2+' cover was never drawn through the adapter'); return; }
         nk++;
         cv.forEach(function(c){
           if(!c.e){ bad.push(k2+' fell back to vector ('+c.key+')'); return; }
           if(c.d!==PIX_ENV) bad.push(k2+' is not at the scene density');
           m=/:(\d+)x(\d+):/.exec(c.key); W=+m[1]; H=+m[2]; e=c.e;
           if(e.c.width*e.d<W-4||e.c.height*e.d<H-4) bad.push(k2+' sprite '+e.c.width*e.d+'x'+e.c.height*e.d+' is smaller than its '+W+'x'+H+' footprint');
           px=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data; aa=0; a1=0;
           for(j=3;j<px.length;j+=4){ if(px[j]===255) a1++; else if(px[j]!==0) aa++; }
           if(aa) bad.push(k2+' sprite has '+aa+' soft alpha pixels');
           if(!a1) bad.push(k2+' sprite is empty');
         });
       });
       if(nk<Math.min(2,kinds.length)) bad.push('only '+nk+' cover kind(s) drawn');
       if(PIXW.clip!==clip0) bad.push(PIXW.clip-clip0+' cover sprites touched the edge of the scratch');
       if(PIX.errs!==e0) bad.push((PIX.errs-e0)+' bake errors');
       return bad.length?bad.slice(0,8).join('; '):null;
     } catch(err){
       return 'pixcover check: '+String(err&&err.message||err);
     } finally {
       pixWrap=pw0;
       CFG.xfPix=cfg0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
