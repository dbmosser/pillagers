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

if ($s.Contains("  {v:'34.13',what:")) { throw "check 34.13 is in the fixture already" }

SubRx @'
  {v:'34.12',what:
'@ @'
  {v:'34.13',what:'quality reads two seconds of gaps and own work, ignores empty passes and only resizes canvas size changes',
   run:function(){
     var d0=JSON.stringify(DRS), c0=JSON.stringify(CFG), oR=resize, calls=0, bad=[], t=100000, i;
     function reset(){ DRS.scale=1; DRS.q=0; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.last=0; DRS.upAt=0; DRS.bounce=0; DRS.said=1; DRS.win=[]; gfxqApply(); }
     function feed(gap,ms,work){ var end=t+ms; while(t<end){ t+=gap; drsTick(gap,t,work); } }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.gfxAuto=1; CFG.gfxScale=1; CFG.fpsCap=0; reset(); feed(22,5000,6);
       if(!DRS.q) bad.push('45 fps for five seconds shed no rung');
       if(DRS.gap95!==22||DRS.work95!==6) bad.push('gap and work window lost their samples');
       reset(); CFG.fpsCap=144; feed(11,30000,6);
       if(DRS.q||DRS.scale!==1) bad.push('144 cap sheds above 60 fps');
       CFG.fpsCap=0; reset(); DRS.q=2; gfxqApply(); feed(16,15000,12);
       if(DRS.q!==2) bad.push('high own work was incorrectly clear');
       reset(); resize(); resize=function(){ calls++; return oR.apply(this,arguments); };
       DRS.q=1; gfxqSync(); if(calls) bad.push('an unchanged sheet rebuilt canvases');
       if(GFXQ.particles!==undefined){ DRS.q=2; gfxqSync(); if(calls) bad.push('HUD and weather rung rebuilt canvases'); }
       DRS.q=GFXQ.particles!==undefined?3:2; gfxqSync(); if(calls!==1) bad.push('sheet size change did not resize once');
       gfxqSync(); if(calls!==1) bad.push('stable sheet rebuilt canvases');
       if(GFXQ.post!==1||GFXQ.shadow!==1) bad.push('empty passes still change with a rung');
       return bad.length?bad.join('; '):null;
     }finally{
       resize=oR; var k, ds=JSON.parse(d0), cs=JSON.parse(c0);
       for(k in DRS) if(!(k in ds)) delete DRS[k]; for(k in ds) DRS[k]=ds[k]; for(k in cs) CFG[k]=cs[k];
       gfxqApply(); try{ resize(); }catch(_r){} __topClear();
     } }},
  {v:'34.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
