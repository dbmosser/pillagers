$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# v11.58 harness repair, second cut. Counting OPAQUE PIXELS in the belt cells
# cannot tell the belt from the floor HUD now that the floor HUD is visible
# behind it: with the dial off the count came back 91809 against 91809, the
# same number, because the region is covered either way. The control compares
# the actual PIXELS in the belt's own bounding box with the dial on and off and
# requires them to differ, which is what "these pixels are the belt" means.
$f = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($f)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
     function frames(t0){ for(var f=0;f<8;f++) __loop(t0+f*16.7); }
'@ @'
     function frames(t0){ for(var f=0;f<8;f++) __loop(t0+f*16.7); }
     // v11.58: a checksum of the real pixels, so the belt can be told from the
     // floor HUD that is drawn behind it.
     function unionOf(cs){ var x0=1e9,y0=1e9,x1=-1e9,y1=-1e9;
       for(var u=0;u<cs.length;u++){ var r=cs[u];
         if(r.x<x0)x0=r.x; if(r.y<y0)y0=r.y;
         if(r.x+r.w>x1)x1=r.x+r.w; if(r.y+r.h>y1)y1=r.y+r.h; }
       return {x:x0,y:y0,w:Math.max(1,x1-x0),h:Math.max(1,y1-y0)}; }
     function inkSum(r){ var d=hctx.getImageData(Math.max(0,Math.round(r.x)),Math.max(0,Math.round(r.y)),Math.max(1,Math.round(r.w)),Math.max(1,Math.round(r.h))).data, t=0;
       for(var i=0;i<d.length;i+=4) t=(t+d[i]*3+d[i+1]*5+d[i+2]*7+d[i+3]*11)|0; return t; }
'@

SubRx @'
     var hb=__hubBelt(), cellsOn=null, paintedOn=0;
'@ @'
     var hb=__hubBelt(), cellsOn=null, paintedOn=0, sumOn=0;
'@

SubRx @'
       cellsOn=hb.cells.slice(); paintedOn=painted;
'@ @'
       cellsOn=hb.cells.slice(); paintedOn=painted; sumOn=inkSum(unionOf(cellsOn));
'@

SubRx @'
     // v11.58: this used to require the whole bottom band to be blank, which was
     // only true while the floor HUD was erased every frame. It measures the
     // belt's OWN cells now and requires their paint to collapse.
     if(cellsOn&&cellsOn.length){
       var offInk=0; for(var c2=0;c2<cellsOn.length;c2++) offInk+=opaqueIn(cellsOn[c2]);
       if(offInk>paintedOn*0.2)
         bad.push('control: with hubBelt off the belt cells still hold '+offInk+' opaque pixels against '+paintedOn+' with it on, so what was measured is not the belt');
     }
'@ @'
     // v11.58: this used to require the whole bottom band to be blank, which was
     // only true while the floor HUD was erased every frame; and a plain opaque
     // count cannot separate the belt from the floor HUD drawn behind it, since
     // the region is covered either way. The pixels themselves must CHANGE when
     // the dial goes off, which is what makes them the belt.
     if(cellsOn&&cellsOn.length){
       var sumOff=inkSum(unionOf(cellsOn));
       if(sumOff===sumOn)
         bad.push('control: turning hubBelt off changed nothing in the belt band, so what was measured is not the belt');
     }
'@

if ($n -ne 4) { throw "expected 4 edits, made $n" }
[IO.File]::WriteAllText($f, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied to the live fixture source"
