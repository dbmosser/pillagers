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

if ($s.Contains("  {v:'34.49',what:")) { throw "check 34.49 is in the fixture already" }

SubRx @'
  {v:'34.48',what:
'@ @'
  {v:'34.49',what:'cw-bldkinds (86i ship 1): BUILDING KINDS. Every building of seed 4242 has a kind (3 or more appear) from grit() without moving the seeded stream or the walls, nav grid and sight segments; each kind has its floor; flat details land only inside the room, in the pixel look; the furniture wears the kind colours through pixWrap and with the look off keeps today',
   run:function(){
     if(typeof bldKind!=='function'||typeof pixKindDetail!=='function'||typeof bldKindFloor!=='function') return 'no building kind (bldKind)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot build a raid';
     var bad=[], old=CFG.xfPix, mA, mB, rA, rB, kinds={}, nk=0, i, k, m, fl={}, cv, c, im, d, n, x0, y0, x1, y1, px, py, b, f, pal, src, got, g;
     function H(a){ var h=2166136261, j; for(j=0;j<a.length;j++) h=Math.imul(h^(Math.round(a[j]*8)|0),16777619)>>>0; return h; }
     function sig(mp){ var a=[], j, w; for(j=0;j<mp.walls.length;j++){ w=mp.walls[j]; a.push(w.x,w.y,w.w,w.h,w.furn||0); } return mp.walls.length+':'+mp.segs.length+':'+H(a)+':'+H(Array.prototype.slice.call(mp.nav.blk)); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.bkind=0; RNGS=4242; mA=buildFixedMap(FIXED_MAPS[0]); rA=RNGS;
       delete CFG.bkind; RNGS=4242; mB=buildFixedMap(FIXED_MAPS[0]); rB=RNGS;
       if(rA!==rB) bad.push('kinds move the seeded stream: '+rA+' without, '+rB+' with');
       if(sig(mA)!==sig(mB)) bad.push('kinds change the walls, sight segments or nav grid: '+sig(mA)+' against '+sig(mB));
       for(i=0;i<mA.buildings.length;i++) if(mA.buildings[i].kind) bad.push('CFG.bkind 0 still gives building '+i+' a kind');
       for(i=0;i<mB.buildings.length;i++){ k=mB.buildings[i].kind; if(BKINDS.indexOf(k)<0) bad.push('building '+i+' has no kind: '+k); else if(!kinds[k]){ kinds[k]=1; nk++; } }
       if(nk<3) bad.push('only '+nk+' kinds on the map: '+Object.keys(kinds).join(','));
       for(i=0;i<BKINDS.length;i++){ f=bldKindFloor({kind:BKINDS[i],x:100,y:200}); if(!(f>=0&&f<=4)) bad.push('kind '+BKINDS[i]+' has floor '+f); fl[f]=1; }
       if(Object.keys(fl).length<4) bad.push('the 5 kinds share only '+Object.keys(fl).length+' floors');
       // the flat details, on a scratch canvas: something is drawn, only inside the room
       cv=document.createElement('canvas'); cv.width=700; cv.height=600; c=cv.getContext('2d');
       for(i=0;i<BKINDS.length;i++){
         c.clearRect(0,0,700,600); b={x:100,y:100,w:400,h:300,kind:BKINDS[i]};
         pixKindDetail(c,b,108,108,384,284,2);
         im=c.getImageData(0,0,700,600).data; n=0; x0=1e9; y0=1e9; x1=-1; y1=-1;
         for(py=0;py<600;py++) for(px=0;px<700;px++) if(im[(py*700+px)*4+3]){ n++; if(px<x0) x0=px; if(px>x1) x1=px; if(py<y0) y0=py; if(py>y1) y1=py; }
         if(n<150) bad.push(BKINDS[i]+' draws almost no detail ('+n+' px)');
         else if(x0<124||y0<124||x1>476||y1>376) bad.push(BKINDS[i]+' details leave the room: '+x0+','+y0+' to '+x1+','+y1);
       }
       // a real raid with the look on: details change the ground only, never the wall, sight or nav lists
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       m=__state().map; got=sig(m);
       g=bakeGround(m); g=pixGroundFinish(g);
       if(sig(m)!==got) bad.push('baking the ground changed the wall, sight or nav lists');
       for(i=0;i<m.buildings.length;i++) if(!m.buildings[i].kind) bad.push('a deployed building has no kind: '+i);
       // furniture: kind colours in the pixel look, today's colours with it off, and the raid frame draws it through pixWrap
       src=String(render2D);
       if(src.indexOf("pixWrap('fn:'")<0) bad.push('the raid frame does not draw furniture through pixWrap');
       for(i=0;i<m.walls.length;i++){ f=m.walls[i]; if(!f.furn||f.ib===undefined) continue; b=m.buildings[f.ib]; if(!b||!b.kind) continue;
         CFG.xfPix=1; pal=pixFurnPal(f); if(pal!==FNPAL[b.kind]) bad.push('furniture in a '+b.kind+' wears '+pal.k);
         CFG.xfPix=0; if(pixFurnPal(f)!==FNPAL.none) bad.push('furniture with the look off is not today\'s'); CFG.xfPix=1; }
       if(FNPAL.office.tt===FNPAL.none.tt||FNPAL.workshop.tt===FNPAL.none.tt) bad.push('the office or workshop table colour is today\'s');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'building kinds check: '+String(err&&err.message||err);
     } finally {
       delete CFG.bkind; CFG.xfPix=old;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'34.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
