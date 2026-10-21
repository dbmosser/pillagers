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

if ($s.Contains("  {v:'33.73',what:")) { throw "check 33.73 is in the fixture already" }

SubRx @'
  {v:'33.72',what:
'@ @'
  {v:'33.73',what:'cw-cx-pixpreview: the FASHION turntable routes through the pixel body in both facings, at exactly 4x with smoothing off, changes no saved look, and keeps the vector preview with the switch off',
   run:function(){
     var bad=[], oldPix=CFG.xfPix, oldAngle=AVANG, oldPhase=AVPH, oldBlit=pxBlit, c, made=false, calls=[], before, i, b0, snap, g;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no raid';
       c=document.getElementById('avcv');
       if(!c){ c=document.createElement('canvas'); c.id='avcv'; c.width=380; c.height=470; c.style.display='none'; document.body.appendChild(c); made=true; }
       snap=JSON.stringify(P);
       pxBlit=function(s,x,y,m){
         var answer=oldBlit.apply(this,arguments);
         if(wc.canvas===c) calls.push({scale:m.a,smooth:wc.imageSmoothingEnabled});
         return answer;
       };
       for(var face=0;face<2;face++){
         AVANG=face*Math.PI; AVPH=0;
         for(i=0;i<24;i++){ pixFrame(); drawAvatarCanvas(); }
         b0=PIX.bodies; calls=[]; pixFrame(); drawAvatarCanvas();
         if(PIX.bodies!==b0+1) bad.push('facing '+face+' uses the vector turntable');
         if(calls.length!==2) bad.push('facing '+face+' drew '+calls.length+' pixel layers, wanted 2');
         calls.forEach(function(row){ if(row.scale!==4||row.smooth) bad.push('a preview layer has scale '+row.scale+' and smoothing '+row.smooth); });
       }
       if(JSON.stringify(P)!==snap) bad.push('drawing the preview changed the saved look');
       CFG.xfPix=0; b0=PIX.bodies; calls=[]; drawAvatarCanvas();
       if(PIX.bodies!==b0||calls.length) bad.push('switch off still uses pixel art');
       if(c.style.imageRendering==='pixelated') bad.push('switch off keeps pixel preview styling');
       return bad.length?bad.join('; '):null;
     } finally {
       pxBlit=oldBlit; AVANG=oldAngle; AVPH=oldPhase;
       if(made&&c&&c.parentNode) c.parentNode.removeChild(c);
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=oldPix;
     } }},
  {v:'33.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
