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

if ($s.Contains("  {v:'36.62',what:")) { throw "check 36.62 is in the fixture already" }

SubRx @'
  {v:'36.61',what:
'@ @'
  {v:'36.62',what:'material wall hits use wood splinters, masonry dust and short metal sparks; fog, sim, reduced effects and an eight-burst frame cap hold',
   run:function(){
     if(typeof wallImpactFx!=='function') return 'no material-aware visual hit function';
     var g, oldFog=fowLive, oldLevel=CFG.fxLevel, oldFlash=CFG.flashRed, oldPart=GFXQ.particles, bad=[], i, s, n;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no raid';
       CFG.fxLevel=2; CFG.flashRed=0; GFXQ.particles=1; fowLive=function(){return true;};
       g.sparks=[]; g.puffs=[]; g._impFxFrame=null;
       wallImpactFx({tree:true},g.player.x,g.player.y,0,-1);
       if(g.sparks.length!==4||g.puffs.length) bad.push('wood did not make four splinters');
       s=g.sparks[0]; if(!s||!s.nc||s.sl!==6||s.life>.28||s.c!=='#ba8a51') bad.push('wood shape or lifetime');
       g.sparks=[]; wallImpactFx({},g.player.x,g.player.y,0,-1);
       if(g.sparks.length||g.puffs.length!==2||g.puffs[0].life>.28) bad.push('masonry did not make brief dust');
       g.puffs=[]; wallImpactFx({wreck:true},g.player.x,g.player.y,0,-1);
       s=g.sparks[0]; if(g.sparks.length!==4||g.puffs.length||!s||s.sl!==4||s.life>.18||s.c!=='#ffd58b') bad.push('metal did not make short sparks');
       g.sparks=[]; g.puffs=[]; g._impFxFrame=null;
       for(i=0;i<20;i++) wallImpactFx({tree:true},g.player.x,g.player.y,0,-1);
       if(g.sparks.length!==32) bad.push('frame cap did not stop at 32 particles');
       g.frameN=(g.frameN||0)+1;
       if(wallImpactFx({},g.player.x,g.player.y,0,-1)!==2) bad.push('budget did not reset next frame');
       n=g.sparks.length+g.puffs.length; fowLive=function(){return false;};
       wallImpactFx({},0,0,0,-1);
       if(g.sparks.length+g.puffs.length!==n) bad.push('hidden hit spawned');
       fowLive=function(){return true;}; g.sim=true; wallImpactFx({},0,0,0,-1); g.sim=false;
       if(g.sparks.length+g.puffs.length!==n) bad.push('simulation spawned');
       CFG.fxLevel=0;
       if(wallImpactFx({tree:true},0,0,0,-1)!==1) bad.push('reduced effects ignored');
       if((String(updateBullets).match(/wallImpactFx\(/g)||[]).length!==2) bad.push('stop or penetration hook missing');
       if(String(netFxStep).indexOf('wallImpactFx(')<0) bad.push('other-window tracer hook missing');
       return bad.length?bad.join('; '):null;
     }finally{
       fowLive=oldFog; CFG.fxLevel=oldLevel; CFG.flashRed=oldFlash; GFXQ.particles=oldPart;
       if(g) g.sim=false;
       try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'36.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
