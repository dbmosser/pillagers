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

if ($s.Contains("  {v:'36.89',what:")) { throw "check 36.89 is in the fixture already" }

SubRx @'
  {v:'36.88',what:
'@ @'
  {v:'36.89',what:'the frame loop makes less garbage: drsTick no longer sorts its window with array sorts (same percentiles) and the vignette gradient is built once, not every frame',
   run:function(){
     if(typeof __frame!=='function'||typeof drsTick!=='function'||typeof gfxqVignette!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, og=PR.createRadialGradient, AS=Array.prototype.sort, i, vig=0, srt=0, d0, a0, t0, gaps=[], works=[], now, sg, sw;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||!__state().player) return 'SKIP: no raid';
       __frame(); __frame();
       d0=GFXQ.detail; a0=CFG.gfxAuto;
       PR.createRadialGradient=function(){ if((/gfxqVignette/).test(String(new Error().stack))) vig++; return og.apply(this,arguments); };
       GFXQ.detail=1; if(typeof VIGC!=='undefined') VIGC.g=null;
       for(i=0;i<8;i++) gfxqVignette();
       if(vig!==1) return 'the vignette gradient was built '+vig+' times in 8 frames (once is enough)';
       GFXQ.detail=0.5; gfxqVignette(); gfxqVignette();
       if(vig!==2) return 'a changed vignette strength should build one new gradient, got '+(vig-1);
       PR.createRadialGradient=og; GFXQ.detail=d0;
       Array.prototype.sort=function(){ if((/drsTick/).test(String(new Error().stack))) srt++; return AS.apply(this,arguments); };
       CFG.gfxAuto=1; DRS.win=[]; now=performance.now()+100000;
       for(i=0;i<30;i++){ gaps.push(10+(i*7)%9); works.push(2+(i*3)%5); drsTick(gaps[i],now+i*16,works[i]); }
       Array.prototype.sort=AS;
       if(srt>0) return 'drsTick still sorts its window with an array sort ('+srt+' sorts in 30 frames)';
       sg=gaps.slice().sort(function(a,b){return a-b;}); sw=works.slice().sort(function(a,b){return a-b;});
       if(DRS.gap95!==sg[Math.ceil(30*0.95)-1]||DRS.gap50!==sg[Math.ceil(30*0.5)-1]) return 'the frame gap percentiles changed: p95 '+DRS.gap95+' p50 '+DRS.gap50+' want '+sg[28]+' '+sg[14];
       if(DRS.work95!==sw[Math.ceil(30*0.95)-1]) return 'the own work percentile changed: '+DRS.work95+' want '+sw[28];
       return null;
     } finally {
       PR.createRadialGradient=og; Array.prototype.sort=AS;
       try{ GFXQ.detail=d0; CFG.gfxAuto=a0; DRS.win=[]; }catch(_r){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
