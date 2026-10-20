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

if ($s.Contains("  {v:'32.05',what:")) { throw "check 32.05 is in the fixture already" }

SubRx @'
  {v:'32.04',what:
'@ @'
  {v:'32.05',what:'the slow-frame system toasts (resolution stepped down, running slowly) are headlines only, with no detail line',
   run:function(){
     if(typeof drsTick!=='function'||typeof perfNote!=='function'||typeof DRS==='undefined'||typeof PERF==='undefined') return 'SKIP: no frame notes here';
     var bad=[], oSwf=sayWhenFree, lines=[], c0=CFG.gfxAuto, s0=CFG.gfxScale, f0=CFG.fpsCap, d0=JSON.stringify(DRS), w0=PERF.win, ps0=PERF.said, i, t=0, t0;
     try{
       sayWhenFree=function(m,k,o){ lines.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); };
       CFG.gfxAuto=1; CFG.gfxScale=1; CFG.fpsCap=0; DRS.scale=1; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.last=0; DRS.bounce=0; DRS.upAt=0; DRS.said=0;
       lines.length=0; for(i=0;i<200;i++){ t+=40; drsTick(40,t); }
       if(!lines.length) return 'SKIP: staging: no resolution step line';
       if(lines[0].sub) bad.push('the resolution step still has the detail '+JSON.stringify(lines[0].sub));
       PERF.win=[]; PERF.said=0; t0=performance.now()-9000; for(i=0;i<120;i++) PERF.win.push([t0+i*75,40]);
       lines.length=0; perfNote(40);
       if(!lines.length) return 'SKIP: staging: no running slowly line';
       if(lines[0].sub) bad.push('running slowly still has the detail '+JSON.stringify(lines[0].sub));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ sayWhenFree=oSwf; CFG.gfxAuto=c0; CFG.gfxScale=s0; CFG.fpsCap=f0; try{ var o=JSON.parse(d0); for(var k in o) DRS[k]=o[k]; }catch(_e){} PERF.win=w0; PERF.said=ps0; }
     return bad.length?bad.join('; '):null; }},
  {v:'32.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
