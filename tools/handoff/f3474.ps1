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

if ($s.Contains("  {v:'34.74',what:")) { throw "check 34.74 is in the fixture already" }

SubRx @'
  {v:'34.73',what:
'@ @'
  {v:'34.74',what:'machines under half health trail smoke, under a fifth also spark and stutter their eye; none when healthy, effects off or the quality ladder has shed particles; cheap (cw-machdmg)',
   run:function(){
     if(typeof gfxDmgLevel!=='function') return 'machines show no damage (no gfxDmgLevel)';
     var g=null, m=null, i, e, r1, r2, r3, r4, r5, r6, t0, ms, rf=CFG.fxInt, rq=GFXQ.particles;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(GFXDMG_KINDS[e.kind]&&e.maxhp>0&&e.hp>0){ m=e; break; } }
       if(!m) return 'SKIP: no machine in the raid';
       m.hp=m.maxhp; r1=gfxDmgLevel(m);
       m.hp=m.maxhp*0.45; r2=gfxDmgLevel(m);
       m.hp=m.maxhp*0.15; r3=gfxDmgLevel(m);
       CFG.fxInt=0; r4=gfxDmgLevel(m); CFG.fxInt=rf;
       GFXQ.particles=0; r5=gfxDmgLevel(m); GFXQ.particles=rq;
       m.hp=0; r6=gfxDmgLevel(m); m.hp=m.maxhp*0.15;
       if(r1!==0) return 'a healthy machine shows damage';
       if(r2!==1) return 'a machine at 45% does not smoke (level '+r2+')';
       if(r3!==2) return 'a machine at 15% does not spark (level '+r3+')';
       if(r4!==0) return 'effect intensity off still draws machine damage';
       if(r5!==0) return 'a shed quality step still draws machine damage';
       if(r6!==0) return 'a dead machine still draws damage';
       GFX.dmgN=-1; gfxBodyFx(0.016);
       if(!(GFX.dmgN>=1)) return 'the body pass does not draw the damaged machine (dmgN '+GFX.dmgN+')';
       t0=performance.now(); for(i=0;i<200;i++) gfxBodyFx(0.016); ms=(performance.now()-t0)/200;
       if(ms>0.5) return 'machine damage costs '+ms.toFixed(3)+' ms a frame (budget 0.5)';
       return null;
     } finally {
       CFG.fxInt=rf; GFXQ.particles=rq;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
