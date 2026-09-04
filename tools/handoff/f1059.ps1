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

SubRx @'
  {v:'10.58',what:'nothing a gunshot schedules starts later than 0.30 s after it, no buffer runs past 6,000 samples, and the tail under a big gun is a tenth of its crack',
'@ @'
  {v:'10.59',what:'seen through a wall in a raid, the operator is painted in his own colours, faded, and not as a light-blue cutout',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__frame)) return 'SKIP: this build cannot render a raid';
     if(!(W>0&&H>0)) return 'SKIP: the pane is 0x0';
     __startRaid({seed:4242,mapIx:0});
     if(!G||!G.player||!G.map||!G.wgrid) return 'no raid';
     var p=G.player, keep={x:p.x,y:p.y,see:CFG.seeThrough,cond:P.cond,iv:p.iv};
     // A big wall whose drawn top he can stand under: at least 60 wide and 60
     // deep so the lift is 26, no window, and open ground where his feet go.
     function clearOf(x,y,r){ var W2=G.map.walls; for(var i=0;i<W2.length;i++){ var w=W2[i]; if(x+r>w.x&&x-r<w.x+w.w&&y+r>w.y&&y-r<w.y+w.h) return false; } return true; }
     var wall=null, W2=G.map.walls;
     for(var i=0;i<W2.length;i++){ var w=W2[i]; if(w.win||w.door) continue; if(w.w<60||w.h<60) continue; var _L=(w.w<=60&&w.h<=60)?14:26, fx=w.x+w.w/2, fy=w.y-_L/2; if(!clearOf(fx,fy,12)||inWater(fx,fy)) continue; wall=w; break; }
     if(!wall) return 'SKIP: no wall on this map with open ground under its drawn top';
     try{
       p.x=wall.x+wall.w/2; p.y=wall.y-((wall.w<=60&&wall.h<=60)?14:26)/2; p.moving=false; p.iv=0;
       function snap(){ __frame(0.016); return wc.getImageData(0,0,wc.canvas.width,wc.canvas.height).data; }
       CFG.seeThrough=0; var a=snap(); CFG.seeThrough=1; var b=snap();
       var diff=0;
       for(var j=0;j<a.length;j+=4){ if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]) diff++; }
       if(diff<80) bad.push('the see-through pass changes only '+diff+' pixels under a wall top, so nothing was painted through it');
       else {
         // The chest, 16 units up the figure. The old pass painted it light blue;
         // measured against the wall top behind it, so a bluish wall cannot fake it.
         var sc=w2s(p.x,16,p.y);
         if(!sc) bad.push('the operator is off screen');
         else {
           var cw=wc.canvas.width, sx=Math.round(sc.x), sy=Math.round(sc.y), ron=0,bon=0,roff=0,boff=0,nn=0;
           for(var dy=-2;dy<=2;dy++) for(var dx=-2;dx<=2;dx++){ var k=((sy+dy)*cw+(sx+dx))*4; if(k<0||k>=a.length) continue; ron+=b[k]; bon+=b[k+2]; roff+=a[k]; boff+=a[k+2]; nn++; }
           var dOn=(bon-ron)/nn, dOff=(boff-roff)/nn;
           if(dOn-dOff>15) bad.push('the chest seen through the wall is bluer than the wall behind it by '+(dOn-dOff).toFixed(0)+' (blue over red): a light-blue cutout, not his coat');
         }
       }
     } finally {
       p.x=keep.x; p.y=keep.y; p.iv=keep.iv;
       if(keep.see===undefined) delete CFG.seeThrough; else CFG.seeThrough=keep.see;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.58',what:'nothing a gunshot schedules starts later than 0.30 s after it, no buffer runs past 6,000 samples, and the tail under a big gun is a tenth of its crack',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
