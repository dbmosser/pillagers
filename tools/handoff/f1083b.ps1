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
  {v:'10.82',what:'a destroyed building looks destroyed: its floor is burnt and covered in rubble, and the building next door is untouched',
'@ @'
  {v:'10.83',what:'the map screen marks the buildings that have fallen, and marks nothing else',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__mapShot)) return 'SKIP: this fixture cannot open the map screen';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[];
     // THE INSTRUMENT, and it took two wrong ones to find it. Brightness cannot
     // do this: on THE COLD MILE the standing buildings vary among themselves by
     // 58 points, so a ruin sitting 8 below its neighbour says nothing. Counting
     // edges cannot either: a busy rect full of walls and labels reaches 49
     // where a hatched ruin reads 31. What DOES isolate the mark is redrawing
     // the same map with the ruined flags cleared, because then the only thing
     // that can differ is what v10.83 draws.
     // MEASURED: every ruined building moves 80.21 to 95.05 percent of its own
     // rectangle, every standing one moves exactly 0.00. Floor at half the
     // weakest signal, ceiling just above nothing.
     var HIT=40, QUIET=1, seen=0;
     var hc=document.getElementById('hcv');
     if(!hc) return 'SKIP: no HUD canvas to read the map from';
     var hx=hc.getContext('2d');
     function shot(){
       var P=__mapShot();
       if(!P) return null;
       var c=document.createElement('canvas'); c.width=hc.width; c.height=hc.height;
       c.getContext('2d').drawImage(hc,0,0);
       return {P:P,cx:c.getContext('2d')};
     }
     function pct(a,b,bd,P){
       var x=Math.round(P.ox+bd.x*P.sc), y=Math.round(P.oy+bd.y*P.sc);
       var w=Math.max(2,Math.round(bd.w*P.sc)), h=Math.max(2,Math.round(bd.h*P.sc));
       if(x<0||y<0||x+w>hc.width||y+h>hc.height) return -1;
       var d1=a.getImageData(x,y,w,h).data, d2=b.getImageData(x,y,w,h).data, k=0;
       for(var i=0;i<d1.length;i+=4)
         if(Math.abs(d1[i]-d2[i])+Math.abs(d1[i+1]-d2[i+1])+Math.abs(d1[i+2]-d2[i+2])>8) k++;
       return k/(d1.length/4)*100;
     }
     for(var mi=0;mi<2;mi++){
       __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(), B=g.map.buildings, nm=(mi===0?'COLD STORAGE':'THE COLD MILE'), q;
       var withMark=shot();
       if(!withMark) return 'SKIP: the map screen would not draw';
       var flags=[];
       for(q=0;q<B.length;q++){ flags.push(B[q].ruined?1:0); B[q].ruined=0; }
       var without=shot();
       for(q=0;q<B.length;q++) B[q].ruined=flags[q];
       if(!without) return 'SKIP: the second map draw failed';
       for(q=0;q<B.length;q++){
         var b=B[q];
         if(b.w<140||b.h<140) continue;
         var mv=pct(withMark.cx,without.cx,b,withMark.P);
         if(mv<0) continue;
         if(flags[q]){
           seen++;
           if(mv<HIT) bad.push(nm+' building '+q+' has fallen and only '+mv.toFixed(1)+' percent of its square on the map is drawn any differently, under the '+HIT+' a mark has to clear');
         } else if(mv>QUIET){
           bad.push(nm+' building '+q+' is standing and '+mv.toFixed(1)+' percent of its square on the map changed with the ruin flags off, so the mark is leaking onto buildings that never fell');
         }
       }
       // AND THE MAP ITSELF IS STILL THERE. Two identical draws would satisfy
       // the standing-building line above by drawing nothing at all.
       var anyDiff=false;
       for(q=0;q<B.length&&!anyDiff;q++) if(flags[q]&&pct(withMark.cx,without.cx,B[q],withMark.P)>0) anyDiff=true;
       if(!anyDiff) bad.push('control: nothing at all differed on '+nm+', so the map may not have drawn');
     }
     if(seen<2) bad.push('control: only '+seen+' fallen buildings were on the map to look at, so this check proved nothing');
     return bad.length?bad.join('; '):null; }},
  {v:'10.82',what:'a destroyed building looks destroyed: its floor is burnt and covered in rubble, and the building next door is untouched',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
