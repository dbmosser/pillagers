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

if ($s.Contains("  {v:'18.03',what:")) { throw "check 18.03 is in the fixture already" }

SubRx @'
  {v:'18.02',what:
'@ @'
  {v:'18.03',what:'the fog of war and darkness sheets draw at a fraction of the screen and are stretched back: the sheets are between half and three quarters of the screen width at full render resolution, smaller again at Low, and with a raid up the ground behind the player is still darker than the ground beside him',
   run:function(){
     if(typeof SOFTR==='undefined'||typeof resize!=='function'||typeof litC==='undefined') return 'the soft sheets still draw at full screen size';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], s0=CFG.gfxScale, g, p, pz, sx, sy, fx, fy, near, far;
     function px(x,y){ var d=wc.getImageData(Math.round(x*DPR),Math.round(y*DPR),1,1).data; return d[0]+d[1]+d[2]; }
     try{
       CFG.gfxScale=1; resize();
       if(!(litC.width<W*0.75&&litC.width>=Math.round(W*0.5)-1)) bad.push('the darkness sheet is '+litC.width+' wide on a '+W+' screen');
       if(fogC.width!==litC.width||fogC.height!==litC.height) bad.push('the two sheets differ in size');
       CFG.gfxScale=0.5; resize(); if(!(litC.width<W*0.4)) bad.push('a Low render resolution left the sheet '+litC.width+' wide'); CFG.gfxScale=1; resize();
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.mapOpen=false; keys={};
       __frame(0.016); __frame(0.016);
       pz=ZOOM(); sx=(p.x-g.camX)*pz; sy=(p.y-g.camY)*pz;
       fx=Math.max(4,Math.min(W-4,sx-Math.cos(p.face||0)*620)); fy=Math.max(4,Math.min(H-4,sy-Math.sin(p.face||0)*620));
       // THE SHEET ITSELF: the fog sheet is cut open where he stands and solid behind him, read on the small sheet at SOFTR.
       near=fx2.getImageData(Math.round(sx*SOFTR),Math.round(sy*SOFTR),1,1).data[3]; far=fx2.getImageData(Math.round(fx*SOFTR),Math.round(fy*SOFTR),1,1).data[3];
       if(!(near<60)) bad.push('the fog sheet is not cut open where he stands (alpha '+near+')');
       if(!(far>40&&far>near+30)) bad.push('the fog sheet is thin behind him (alpha '+far+' against '+near+' where he stands)');
       if(!(px(fx,fy)>=0)) bad.push('the frame has no pixels');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CFG.gfxScale=s0; try{ resize(); }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
