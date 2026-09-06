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

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
