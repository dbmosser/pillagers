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

if ($s.Contains("  {v:'28.63',what:")) { throw "check 28.63 is in the fixture already" }

SubRx @'
  {v:'28.62',what:
'@ @'
  {v:'28.63',what:'cloud-raid-rampagedead: an Overseer killed during the rampage warning ends the rampage at once: no HUNTING YOU ring and map mark for two minutes, and the next event is not held up',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__loop)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof evLaunch!=='function'||typeof bossTick!=='function'||typeof flowTick!=='function') return 'SKIP: no arcade or raid events in this fixture';
     var g=null, p=null, rs=say, own=false, ev=null, b=null, i, T0, oIv;
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(){}; own=true; oIv=p.iv; p.iv=999;
       g.t=5; flowTick(0.1); g.flow.ev.plan.length=0;
       b=g.bossRef; if(!b){ g.bossDone=0; b=bossTick(true); }
       if(!b||!(b.hp>0)) return 'SKIP: staging: no Overseer in this raid';
       ev=evLaunch('rampage'); if(!ev) return 'SKIP: staging: the rampage could not be launched';
       ev.t=ev.warn-1; b.hp=0;
       T0=performance.now(); __loop(T0); for(i=1;i<=120;i++) __loop(T0+i*16);
       for(i=0;i<40;i++) flowTick(0.25);
       if(ev.ph==='live') return 'the rampage of a dead Overseer is still live '+Math.round(ev.lt)+' s after its warning ended';
       return null;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(own) say=rs; if(p) p.iv=oIv; try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'28.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
