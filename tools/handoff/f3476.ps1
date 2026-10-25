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

if ($s.Contains("  {v:'34.76',what:")) { throw "check 34.76 is in the fixture already" }

SubRx @'
  {v:'34.75',what:
'@ @'
  {v:'34.76',what:'glow pools (I5): queued glow sources draw a halo and a light map pool, none with POST FX off, intensity 0 or the effects rung, and the pass is cheap',
   run:function(){
     if(typeof gfxGlowHalo!=='function') return 'no glow halo pass';
     var oc=gfxCam, c0=JSON.stringify(CFG), d0=JSON.stringify(DRS), bad=[], g=null, p, k, t, avg;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player;
       CFG.gfxAuto=0; CFG.gfxPost=1; CFG.gfxLight=2; CFG.fxInt=1; DRS.q=0; gfxqApply();
       gfxCam=function(dt){ var r=oc(dt); GFX.emit.push({x:p.x+30,y:p.y-20,r:60,c:'#ff6a2a',a:0.5}); return r; };
       __frame(); __frame();
       if(GFX.glowN!==1) bad.push('POST FX on drew '+GFX.glowN+' halos, not 1');
       if(GFX.glowL!==1) bad.push('POST FX on lit '+GFX.glowL+' map pools, not 1');
       CFG.gfxPost=0; __frame();
       if(GFX.glowN!==0||GFX.glowL!==0) bad.push('POST FX off still drew '+GFX.glowN+' halos and '+GFX.glowL+' pools');
       CFG.gfxPost=1; CFG.fxInt=0; __frame();
       if(GFX.glowN!==0||GFX.glowL!==0) bad.push('effect intensity 0 still drew glow');
       CFG.fxInt=1; DRS.q=2; gfxqApply(); __frame();
       if(!gfxqCan('post')||GFXQ.post!==0) bad.push('the effects rung does not shed POST FX');
       if(GFX.glowN!==0||GFX.glowL!==0) bad.push('the effects rung still drew glow');
       DRS.q=0; gfxqApply(); if(GFXQ.post!==1) bad.push('full quality did not bring POST FX back');
       GFX.emit.length=0; for(k=0;k<8;k++) GFX.emit.push({x:p.x+k*10,y:p.y,r:60,c:'#ff6a2a',a:0.5});
       t=performance.now(); for(k=0;k<200;k++) gfxGlowHalo(p.x-400,p.y-300,1,800,600);
       avg=(performance.now()-t)/200;
       if(GFX.glowN!==8) bad.push('eight sources drew '+GFX.glowN);
       if(avg>1) bad.push('eight halos cost '+avg.toFixed(2)+' ms, over the 1 ms budget');
       return bad.length?bad.join('; '):null;
     } finally {
       gfxCam=oc; var ds=JSON.parse(d0), cs=JSON.parse(c0), kk;
       for(kk in DRS) if(!(kk in ds)) delete DRS[kk]; for(kk in ds) DRS[kk]=ds[kk]; for(kk in cs) CFG[kk]=cs[kk];
       gfxqApply(); try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
