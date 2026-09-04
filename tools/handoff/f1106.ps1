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
  {v:'11.04',what:'a restore code can be pasted back in
'@ @'
  {v:'11.06',what:'the 23 jersey reads as a jersey rather than as a black block, and the number is not painted over',
   run:function(){
     if(!(window.__opShot&&window.__canvases)) return 'SKIP: this fixture cannot draw one figure at a time';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     var CN=__canvases(), wx=CN.world.getContext('2d');
     var BASE={hero:0,faceMark:'faceplain',eyes:'eyeblue',skin:'skinfair',hat:'none',
               hair:'blonde',cut:'shaved',beard:'clean',tattoo:'tatnone'};
     function look(o){ var q={},k; for(k in BASE) q[k]=BASE[k]; if(o) for(k in o) q[k]=o[k]; return q; }
     // The chest, found from the drawing rather than from numbers typed here: the
     // jersey red is the one flat colour on this figure that nothing else uses.
     function tally(lk){
       var r=__opShot(lk,0,9); if(!r||r.thrown) return null;
       var W=CN.world.width, H=CN.world.height;
       var d=wx.getImageData(0,0,W,H).data;
       var red=0, white=0, black=0, minx=1e9,maxx=-1,miny=1e9,maxy=-1, x,y,q;
       for(y=0;y<H;y++) for(x=0;x<W;x++){ q=(y*W+x)*4;
         if(d[q+3]<40) continue;
         if(d[q]===196&&d[q+1]===30&&d[q+2]===30){ red++;
           if(x<minx)minx=x; if(x>maxx)maxx=x; if(y<miny)miny=y; if(y>maxy)maxy=y; } }
       if(red<50) return {red:red,white:0,black:0,box:null};
       // Everything else is counted only inside the chest the red just described,
       // so the boots, the shorts and the sky cannot join in.
       var x0=Math.max(0,minx-6), x1=Math.min(W-1,maxx+6),
           y0=Math.max(0,miny-6), y1=Math.min(H-1,maxy+6);
       for(y=y0;y<=y1;y++) for(x=x0;x<=x1;x++){ q=(y*W+x)*4;
         if(d[q+3]<40) continue;
         if(d[q]===244&&d[q+1]===242&&d[q+2]===236) white++;
         else if(d[q]===20&&d[q+1]===22&&d[q+2]===27) black++; }
       return {red:red,white:white,black:black,box:[x0,y0,x1,y1]};
     }
     var J=tally(look({outfit:'outballer'}));
     if(!J) return 'drawing the baller threw';
     if(J.red<500) return 'SKIP: the baller did not draw a red jersey here ('+J.red+' red pixels)';
     // 1. THE NUMBER IS NOT PAINTED OVER. Measured on v11.05 the chest rig was a
     //    near-black band the full width of the chest, drawn AFTER the jersey and
     //    straight across the lower half of the 23: 1,582 white pixels. Drawn
     //    after the rig instead, the same numeral reads 2,735.
     if(J.white<2000) bad.push('the 23 shows only '+J.white+' pale pixels, so something is painted across it');
     // 2. AND THE SHIRT IS A SHIRT, not a black block. Measured on v11.05 the two
     //    side panels were 2.4 wide each on a chest 13 wide and came to 2,384
     //    black against 3,222 red, a ratio of 0.74. As trim they read 0.54.
     var ratio=J.black/Math.max(1,J.red);
     if(ratio>0.62) bad.push('the black on the jersey is '+J.black+' against '+J.red+' of red, a ratio of '+ratio.toFixed(2)+', which is the black block he reported');
     // 3. CONTROLS. The pale pixels have to BE the number, so a figure with no
     //    jersey must not produce them, and the red has to be the jersey, so the
     //    same figure must not produce that either.
     var N=tally(look({outfit:'outnone',fit:'slate'}));
     if(!N) bad.push('control: the plain figure would not draw');
     else {
       if(N.red>200) bad.push('control: a figure with no jersey draws '+N.red+' pixels of jersey red, so the red is not the jersey');
       if(N.white>800) bad.push('control: a figure with no jersey draws '+N.white+' pale pixels, so the pale is not the number');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.04',what:'a restore code can be pasted back in
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
