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

if ($s.Contains("  {v:'24.38',what:")) { throw "check 24.38 is in the fixture already" }

SubRx @'
  {v:'24.37',what:
'@ @'
  {v:'24.38',what:'graphics program gfx25: a round going north that stops on the south face of a plain wall leaves a mark painted into that wall baked sprite in place (the pixel at the mark is 12 or more darker than before), the mark survives a flush and rebake of every wall sprite, and a round from the north leaves none',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep)||typeof wallSprite!=='function'||typeof WALLSPR==='undefined') return 'SKIP: this fixture cannot bake a wall sprite';
     var bad=[], g=null, w=null, i, q, LIFT, d3, e0, e1, snap, sc, mk, l0, l1, l2, wb0=CFG.wallBake, by0=GFX.bypass;
     function lum(cv2,x,y){ var d=cv2.getContext('2d').getImageData(Math.round(x),Math.round(y),1,1).data; return 0.299*d[0]+0.587*d[1]+0.114*d[2]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.map) return 'SKIP: staging: no raid';
       CFG.wallBake=1; GFX.bypass=0;
       for(i=0;i<g.map.walls.length;i++){ q=g.map.walls[i];
         if(q.tree||q.ruin||q.wreck||q.furn||q.win||q.door||q.ledge||q.lm||q.lockWall||q.noDes) continue;
         if(q.w>=80&&q.w<=1000&&q.h<=80&&(q.lift||26)>=14){ w=q; break; } }
       if(!w) return 'SKIP: staging: no plain wall 80 wide on this map';
       LIFT=w.lift||((w.w<=60&&w.h<=60)?14:26); d3=(w.d===undefined)?3:w.d;
       e0=wallSprite(w,d3,LIFT); if(!e0||!e0.c) return 'SKIP: staging: the wall did not bake';
       snap=document.createElement('canvas'); snap.width=e0.c.width; snap.height=e0.c.height; snap.getContext('2d').drawImage(e0.c,0,0);
       if(typeof WALLMKQ==='undefined') return 'there is no wall mark store (WALLMKQ): a round that stops on a wall leaves nothing';
       WALLMKQ.length=0;
       if(!wallMark(w,w.x+w.w/2,w.y,0,1)) bad.push('the wall hook did not take a live event');
       if(WALLMKQ.length) bad.push('a round from the north (the far face) left a mark');
       wallMark(w,w.x+w.w/2,w.y+w.h,0,-1); mk=(WALLMKQ.length===1)?WALLMKQ[0]:null;
       if(!mk||typeof mk!=='object'||!(mk.x>=w.x&&mk.x<=w.x+w.w)) return 'a round going north that stopped on the south face left no mark on the wall';
       sc=e0.ss; q={x:(mk.x-w.x)*sc+1,y:(mk.y-(w.y-LIFT))*sc+1};
       l0=lum(snap,q.x,q.y); l1=lum(e0.c,q.x,q.y);
       if(l0-l1<12) bad.push('the baked sprite was not marked in place: the pixel at the mark went from '+l0.toFixed(1)+' to '+l1.toFixed(1));
       if(!(mk.y>w.y+w.h-LIFT&&mk.y<w.y+w.h)) bad.push('the mark is at y '+mk.y.toFixed(1)+', not on the south face band ('+(w.y+w.h-LIFT)+' to '+(w.y+w.h)+')');
       WALLSPR.m={}; WALLSPR.n=0;
       e1=wallSprite(w,d3,LIFT);
       if(!e1||e1===e0) bad.push('the flush did not make a new sprite');
       else { l2=lum(e1.c,q.x,q.y); if(l0-l2<12) bad.push('after a flush and rebake the mark is gone: the pixel is '+l2.toFixed(1)+' against '+l0.toFixed(1)+' unmarked'); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       CFG.wallBake=wb0; GFX.bypass=by0;
       try{ WALLSPR.m={}; WALLSPR.n=0; }catch(_w){}
       try{ var g2=__state(); if(g2){ if(!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
