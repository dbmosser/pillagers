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

if ($s.Contains("  {v:'34.14',what:")) { throw "check 34.14 is in the fixture already" }

SubRx @'
  {v:'34.13',what:
'@ @'
  {v:'34.14',what:'real quality rungs reduce spawn counts and new decal life, fade decorative HUD/weather, and reserve canvas resizing for the sheets',
   run:function(){
     var d0=JSON.stringify(DRS), q0=JSON.stringify(GFXQ), c0=JSON.stringify(CFG), b0=BOOMS.slice(), g, n, full, b, oldSpark, oldDecal, bad=[], oR=resize, calls=0, k;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||!g.player) return 'no raid';
       CFG.fxLevel=1; CFG.flashRed=0; CFG.gfxAuto=1; CFG.gfxScale=1; DRS.scale=1; DRS.q=0; gfxqApply(); GFXQ.detail=1; resize();
       n=g.sparks.length; spark(10,10,'#fff',30,100); full=g.sparks.length-n; oldSpark=g.sparks[g.sparks.length-1];
       decal(10,10,'#fff',3); oldDecal=g.decals[g.decals.length-1];
       resize=function(){ calls++; return oR.apply(this,arguments); };
       DRS.q=1; gfxqSync();
       n=g.sparks.length; spark(10,10,'#fff',30,100);
       if(g.sparks.length-n!==Math.ceil(full/3)) bad.push('rung 1 did not spawn a third of sparks');
       if(g.sparks.indexOf(oldSpark)<0||oldSpark.t!==0) bad.push('rung 1 changed a living spark');
       CFG.fxLevel=0; n=g.sparks.length; spark(10,10,'#fff',30,100);
       if(g.sparks.length-n!==Math.ceil(full/3)) bad.push('Reduced effects was reduced twice');
       decal(10,10,'#fff',3);
       if(oldDecal.life!==45||g.decals[g.decals.length-1].life!==15) bad.push('decal life was not spawn only, 45 to 15');
       CFG.fxLevel=1; boomFx(10,10,1,'frag'); b=BOOMS[BOOMS.length-1];
       if(!b||b.deb.length!==5||b.smoke.length!==5) bad.push('rung 1 did not take the Reduced blast path');
       DRS.q=2; gfxqSync(); gfxqEase(0.5);
       if(Math.abs(GFXQ.detail-0.5)>1e-6||gfxqRainCount(200)!==150||gfxqFogWeight(3)!==0.5) bad.push('half-second HUD/weather fade is wrong');
       gfxqEase(0.5);
       if(GFXQ.detail!==0||gfxqRainCount(200)!==100||gfxqFogWeight(2)!==1||gfxqFogWeight(3)!==0||gfxqVignette()!==false) bad.push('rung 2 did not remove corner shade, four banks and half the rain');
       if(calls) bad.push('rungs 1 and 2 rebuilt canvases');
       if(GFXQ.lmap!==1) bad.push('sheets changed before rung 3');
       DRS.q=3; gfxqSync(); if(calls!==1||GFXQ.lmap!==0.66) bad.push('rung 3 did not resize soft sheets');
       if(GFXQ.post!==1||GFXQ.shadow!==1||gfxqCan('post')||gfxqCan('shadow')) bad.push('empty passes rejoined the ladder');
       DRS.q=0; gfxqApply(); gfxqEase(0.5); if(GFXQ.detail!==0.5) bad.push('recovery did not fade back'); gfxqEase(0.5);
       if(GFXQ.detail!==1||gfxqRainCount(200)!==200||gfxqFogWeight(6)!==1) bad.push('full weather did not return');
       return bad.length?bad.join('; '):null;
     }finally{
       resize=oR; try{ __endRaid('abandon'); }catch(_e){}
       var ds=JSON.parse(d0), qs=JSON.parse(q0), cs=JSON.parse(c0);
       for(k in DRS) if(!(k in ds)) delete DRS[k]; for(k in ds) DRS[k]=ds[k]; for(k in qs) GFXQ[k]=qs[k]; for(k in cs) CFG[k]=cs[k];
       BOOMS.length=0; for(k=0;k<b0.length;k++) BOOMS.push(b0[k]); gfxqApply(); try{ resize(); }catch(_r){} __topClear();
     } }},
  {v:'34.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
