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
  {v:'10.91',what:'every panel resize grip has somewhere to drag to
'@ @'
  {v:'10.92',what:'your own marker on the map is far bigger than the eight pixels it was, and grows with the map like every other marker on it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__mapShot)) return 'SKIP: this fixture cannot draw the map screen';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var hc=document.getElementById('hcv');
     if(!hc) return 'SKIP: no HUD canvas to read the map from';
     var hx=hc.getContext('2d'), bad=[];
     // THE INSTRUMENT. The marker is the one thing on the map painted in flat
     // #ffc04a at full alpha, so an EXACT colour match isolates the gold disc and
     // nothing else: the halo is 18 percent alpha, the ink ring is near black,
     // and the heading line at 85 percent alpha lands on darker ground and blends
     // away from the exact value. What comes back is the disc, in pixels.
     function read(px,py){
       var Pj=__mapShot(); if(!Pj) return null;
       var cx=Math.round(Pj.ox+px*Pj.sc), cy=Math.round(Pj.oy+py*Pj.sc);
       var R=80;
       var x0=Math.max(0,cx-R), y0=Math.max(0,cy-R);
       var x1=Math.min(hc.width,cx+R), y1=Math.min(hc.height,cy+R);
       if(x1-x0<16||y1-y0<16) return null;
       var w=x1-x0, d=hx.getImageData(x0,y0,w,y1-y0).data, k=0, far=0, x, y;
       for(y=0;y<y1-y0;y++) for(x=0;x<w;x++){
         var i=(y*w+x)*4;
         if(d[i]===255&&d[i+1]===192&&d[i+2]===74&&d[i+3]>250){
           k++;
           var dd=Math.hypot(x0+x-cx,y0+y-cy); if(dd>far) far=dd;
         }
       }
       return {n:k,r:far};
     }
     function shotAt(w,h){
       __forceSize(w,h);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0;
       var pl=g.player;
       return {m:read(pl.x,pl.y),g:g,p:pl};
     }
     __runPrep(); __resetCfg(); __pinDefaults(0);
     try{
       // 1. AT HIS OWN SCREEN SIZE IT IS NO LONGER A SPECK. Measured on v10.91
       //    the disc was 4 pixels of radius, about 50 exact-gold pixels; the
       //    floor sits well above anything that small, and above the 98 a 5.6
       //    radius would give, so a quiet shrink back is caught.
       var base=shotAt(1920,1080);
       if(!base.m) return 'SKIP: the marker fell outside the canvas at 1920x1080';
       if(base.m.n<150) bad.push('your marker is only '+base.m.n+' pixels of gold at 1920x1080, which is the size he called hard to see');
       if(base.m.r<7) bad.push('your marker is '+base.m.r.toFixed(1)+' pixels of radius, no bigger than the old speck');
       // 2. AND IT DOES NOT SWAMP THE MAP EITHER. Much larger was the note, not
       //    a blot over the district he is standing in.
       if(base.m.r>22) bad.push('your marker is '+base.m.r.toFixed(1)+' pixels of radius, which covers the map rather than marking a spot on it');
       // 3. IT GROWS WITH THE MAP. This is the half of the defect that is not
       //    about the radius: every neighbouring marker is multiplied by the map
       //    zoom and yours alone was not, so on a bigger screen it got relatively
       //    smaller. At 2880x1620 that zoom is 1.5, so the disc should carry
       //    about 2.25 times the pixels. On the old build the ratio is exactly 1.
       var big=shotAt(2880,1620);
       if(!big.m) bad.push('SKIPPED the zoom half: the marker fell outside the canvas at 2880x1620');
       else {
         var zoom=(typeof hudRes==='function')?hudRes():0;
         if(zoom<1.4) bad.push('control: the map zoom only reached '+zoom.toFixed(2)+' at 2880x1620, so the growth test proves nothing');
         else {
           if(big.m.n/Math.max(1,base.m.n)<1.8) bad.push('your marker went from '+base.m.n+' to '+big.m.n+' pixels when the map zoom went to '+zoom.toFixed(2)+', so it is not following the map like the other markers');
           if(big.m.r/Math.max(0.1,base.m.r)<1.35) bad.push('your marker radius went from '+base.m.r.toFixed(1)+' to '+big.m.r.toFixed(1)+' at zoom '+zoom.toFixed(2)+', so it is not following the map');
         }
       }
       // 4. CONTROL, AND IT IS THE ONE THAT MATTERS: prove the gold being counted
       //    IS your marker. Move the operator across the map and the count has to
       //    move with him, or this check is measuring some other gold thing and
       //    every number above is furniture.
       var here=shotAt(1920,1080);
       if(here.m){
         var pl=here.p, ox2=pl.x, oy2=pl.y;
         var dx=(ox2+600<WORLD_W-300)?600:-600;
         pl.x=ox2+dx;
         var moved=read(pl.x,pl.y), left=read(ox2,oy2);
         pl.x=ox2;
         if(!moved||moved.n<150) bad.push('control: the marker did not follow the operator, it reads '+(moved?moved.n:'nothing')+' pixels at his new position');
         if(left&&left.n>40) bad.push('control: '+left.n+' gold pixels are still sitting where the operator used to be, so this check is counting something that is not him');
       }
     } finally { __forceSize(1920,1080); }
     return bad.length?bad.join('; '):null; }},
  {v:'10.91',what:'every panel resize grip has somewhere to drag to
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
