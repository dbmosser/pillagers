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

if ($s.Contains("  {v:'37.11',what:")) { throw "check 37.11 is in the fixture already" }

SubRx @'
  {v:'37.10',what:
'@ @'
  {v:'37.11',what:'the last minute reddens the world and drops ash: a drawn raid frame at 59 s left has BURN.ash and BURN.k above zero, at 120 s left and while the site is going up both are zero',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     if(typeof BURN==='undefined'||typeof burnFx!=='function') return 'there is no burn effect (BURN does not exist)';
     var g=null, a1, k1, k2, t0, i, ms;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.over=false; g.paused=false; g.nuking=false;
       g.timeLeft=59; __frame(); __frame(); a1=BURN.ash; k1=BURN.k;
       if(!(a1>0)) return 'no ash was drawn at 59 s left (BURN.ash '+a1+')';
       if(!(k1>0)) return 'no red glow at 59 s left (BURN.k '+k1+')';
       g.timeLeft=5; __frame(); k2=BURN.k;
       if(!(k2>k1&&k2<=0.1601)) return 'the glow does not grow toward 0.16 as the clock runs down ('+k1+' then '+k2+')';
       g.timeLeft=120; __frame();
       if(BURN.ash!==0||BURN.k!==0) return 'ash or glow at 120 s left (ash '+BURN.ash+', k '+BURN.k+')';
       g.timeLeft=20; g.nuking=true; __frame();
       if(BURN.ash!==0||BURN.k!==0) return 'ash or glow while the site is going up (ash '+BURN.ash+', k '+BURN.k+')';
       g.nuking=false; g.timeLeft=30;
       t0=performance.now(); for(i=0;i<200;i++) burnFx(ctx,0.016,W,H); ms=(performance.now()-t0)/200;
       if(ms>2) return 'one burn pass costs '+ms.toFixed(3)+' ms, over the 2 ms bound';
       return null;
     } finally {
       try{ if(g) g.nuking=false; }catch(_e0){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'37.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
