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

if ($s.Contains("  {v:'35.94',what:")) { throw "check 35.94 is in the fixture already" }

SubRx @'
  {v:'35.93',what:
'@ @'
  {v:'35.94',what:'cw-bossbarfight, his order of 2026-10-28 (picture of the Overseer bar over the crawlers): "the overseer\'s health bar should go away unless i\'m actively fighting him eg dealt damage in last few secs": seen, near and unhurt, no bar; a hit you land shows it; five seconds with no hit, it goes; the phase marks still show in a fight',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawBossBar!=='function'||typeof bossTick!=='function'||typeof BOSS_NAME==='undefined') return 'SKIP: no boss bar here';
     var bad=[], g, b, cb0=CFG.boss, t0;
     function bar(){ var tr=__textTrace(function(){ drawBossBar(); }); return tr.some(function(t){ return t.t===b.name; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       g.t=Math.max(g.t||0,30); g.bossDone=0; if(CFG.boss===0) CFG.boss=1; b=bossTick(true); CFG.boss=cb0; if(!b) return 'SKIP: staging: no Overseer';
       g.bossRef=b; b.x=g.player.x+200; b.y=g.player.y; b.barSeen=1; b.pHitT=0; delete b.barHitAt; t0=g.t;
       if(bar()) bad.push('the bar shows for a seen Overseer nobody has hit');
       b.pHitT=0.3;
       if(!bar()) bad.push('control: the bar does not show after a hit you landed');
       b.pHitT=0; g.t=t0+2;
       if(!bar()) bad.push('the bar went away 2 s after a hit, mid fight');
       b.hp=Math.max(1,Math.round(b.maxhp*0.5));
       if(!(HUDBOSSB>0)) bad.push('the plate in a fight left no bottom edge');
       g.t=t0+5.5;
       if(bar()) bad.push('the bar still shows 5.5 s after the last hit');
       if(HUDBOSSB!==0) bad.push('the hidden bar still holds space ('+HUDBOSSB+')');
       b.pHitT=0.3;
       if(!bar()) bad.push('a new hit does not bring the bar back');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{ CFG.boss=cb0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
