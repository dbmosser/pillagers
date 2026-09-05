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
  {v:'11.38',what:'a melee swing next to your own merc does not hurt him; a swing next to a hostile pillager still does',
'@ @'
  {v:'11.39',what:'with the controls list off, the "H controls" hint draws clear of the bottom-left corner (where the vitals panel is), above the panel, at 1080p and at 1440p',
   run:function(){
     if(!(window.__deploy&&window.__loop)) return 'SKIP: this fixture cannot draw a HUD frame';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     var bad=[];
     var NEEDLE=['H  ','controls'].join('');
     function traceHint(w,h){
       __pinDPR(1); __forceSize(w,h);
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.legendOn=0;
       var proto=CanvasRenderingContext2D.prototype, orig=proto.fillText, got=null;
       proto.fillText=function(t,x,y){ if(t===NEEDLE&&got===null) got=[x,y]; return orig.apply(this,arguments); };
       var threw=null; try{ __loop(performance.now()); }catch(e){ threw=String(e); }
       proto.fillText=orig;
       return {got:got, H:(window.innerHeight||h), threw:threw};
     }
     // The vitals panel occupies roughly the bottom quarter of the screen at the
     // bottom-left. The old hint drew at H-14, inside it; the fix draws it above
     // the panel. A hint whose baseline is within 120px of the bottom is on the
     // panel. This reads only the traced position and the height, not the panel
     // box, which does not compute reliably on every fixture page.
     [[1920,1080],[2560,1440]].forEach(function(sz){
       var r=traceHint(sz[0],sz[1]);
       if(r.threw){ bad.push('the HUD frame threw at '+sz[0]+'x'+sz[1]+': '+r.threw); return; }
       if(!r.got){ bad.push('the "H controls" hint was not drawn at '+sz[0]+'x'+sz[1]+' with the legend off'); return; }
       var floor=sz[1]-120;
       if(r.got[1]>floor) bad.push('at '+sz[0]+'x'+sz[1]+' the hint drew at y '+Math.round(r.got[1])+', within 120px of the bottom (drawing height '+sz[1]+'), so it is on the vitals panel');
     });
     __forceSize(1920,1080);
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.38',what:'a melee swing next to your own merc does not hurt him; a swing next to a hostile pillager still does',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
