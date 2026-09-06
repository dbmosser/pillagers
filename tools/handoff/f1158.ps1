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

# v11.58 CHECK, inserted before the v11.57 entry. Driven through the REAL frame
# loop, because the hub HUD is painted by __loop and not by __hubFrame, and
# read off the real HUD canvas in pixels, because that is the only instrument
# that can tell a painted floor from an erased one.
SubRx @'
  {v:'11.57',what:'the storm warning ring says LIGHTNING INCOMING with the seconds left, and the world draw puts it at the circle (his note of 2026-09-05)',
'@ @'
  {v:'11.58',what:'the Undercroft floor HUD survives the frame it is painted in: the heading and the station prompt are on the HUD canvas after real frames, and the belt is still drawn under them',
   run:function(){
     if(!(window.__hubEnter&&window.__loop&&window.__P)) return 'SKIP: this fixture cannot drive the Undercroft loop';
     var cv2=document.getElementById('hcv');
     if(!cv2||!cv2.width||!cv2.height) return 'SKIP: no HUD canvas with a size here';
     var bad=[];
     function ink(x0,y0,x1,y1){
       // CSS pixels in, device pixels out: the canvas is DPR-scaled.
       var scx=cv2.width/Math.max(1,W), scy=cv2.height/Math.max(1,H);
       var rx=Math.max(0,Math.round(x0*scx)), ry=Math.max(0,Math.round(y0*scy));
       var rw=Math.min(cv2.width-rx,Math.round((x1-x0)*scx)), rh=Math.min(cv2.height-ry,Math.round((y1-y0)*scy));
       if(rw<=0||rh<=0) return -1;
       var d=cv2.getContext('2d').getImageData(rx,ry,rw,rh).data, n=0;
       for(var i=3;i<d.length;i+=4) if(d[i]>16) n++;
       return n;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __hubEnter();
       var t0=performance.now();
       for(var f=0;f<6;f++) __loop(t0+f*16.7);
       var head=ink(0,0,420,64);
       if(head<0) return 'SKIP: the HUD canvas is too small to measure at this size';
       // THE FIX: the floor heading and the line under it are actually on the canvas.
       if(head<150) bad.push('the Undercroft HUD is blank where the heading and the stash line are drawn ('+head+' opaque pixels in the top strip), so the floor is painting its screen and erasing it in the same frame');
       // CONTROL: the belt is still drawn, so the clear did not simply move the problem.
       var belt=ink(0,H-150,W,H);
       if(belt===0) bad.push('control: nothing is drawn along the bottom of the HUD canvas, so the belt was lost');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.57',what:'the storm warning ring says LIGHTNING INCOMING with the seconds left, and the world draw puts it at the circle (his note of 2026-09-05)',
'@

# HARNESS REPAIR, same build. Check 9.88's first control required the whole
# bottom band of the HUD canvas to be blank with the belt dial off, and used
# that as its proof that the pixels it counted were the belt. That was only
# true while the floor HUD was being erased every frame, so with this build it
# fires on correct behaviour: the floor's own teaching line lives in that band.
# It measures the belt's OWN cells now and requires their paint to collapse.
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
     var hb=__hubBelt();
'@ @'
     var hb=__hubBelt(), cellsOn=null, paintedOn=0, sumOn=0;
'@
SubRx @'
       for(var c=0;c<hb.cells.length;c++) painted+=opaqueIn(hb.cells[c]);
'@ @'
       for(var c=0;c<hb.cells.length;c++) painted+=opaqueIn(hb.cells[c]);
       cellsOn=hb.cells.slice(); paintedOn=painted; sumOn=inkSum(unionOf(cellsOn));
'@
SubRx @'
     if(opaqueIn({x:0,y:H-170,w:W,h:160})>0)
       bad.push('control: with hubBelt off the bottom of the HUD canvas still holds paint');
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

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
