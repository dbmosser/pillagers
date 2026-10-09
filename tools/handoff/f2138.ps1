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

if ($s.Contains("  {v:'21.38',what:")) { throw "check 21.38 is in the fixture already" }

SubRx @'
  {v:'21.37',what:
'@ @'
  {v:'21.38',what:'at 4K the SECTOR MAP header stands clear of the map frame as it does at 1080p: its baseline sits at least 8 map zooms above the map, past the frame that grows with the screen, and at 1080p it is where it was',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__forceSize)) return 'SKIP: this fixture cannot deploy at a forced size';
     if(typeof drawMapOverlay!=='function'||typeof mapProj!=='function'||typeof hudRes!=='function') return 'SKIP: no sector map here';
     var bad=[], g, oFT=ctx.fillText, y1, y4, m1, m4, z4;
     function grab(){ var got=null; ctx.fillText=function(s,x,y){ if(got===null&&String(s)==='SECTOR MAP') got=y; return oFT.apply(this,arguments); }; ctx.save(); try{ drawMapOverlay(); } finally { ctx.restore(); delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } return got; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       y1=grab(); m1=mapProj();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       z4=hudRes(); y4=grab(); m4=mapProj();
       if(y1===null||y4===null) return 'SKIP: the map header was not drawn';
       if(!(z4>1.5)) return 'SKIP: the screen factor did not grow at 4K';
       if(Math.abs(y1-(m1.oy-10))>0.5) bad.push('at 1080p the header moved: its baseline is '+(m1.oy-y1).toFixed(1)+' above the map, not 10');
       if(y4>m4.oy-8*z4) bad.push('at 4K the header baseline is '+(m4.oy-y4).toFixed(1)+' pixels above the map while the frame reaches '+(4.5*z4).toFixed(1)+' up, so the words stand on the frame');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){} try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
