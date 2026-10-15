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

if ($s.Contains("  {v:'27.49',what:")) { throw "check 27.49 is in the fixture already" }

SubRx @'
  {v:'27.48',what:
'@ @'
  {v:'27.49',what:'the HUD rule: the boss bar is on the HUD plate and THE OVERSEER bar names the phase it is in (PHASE 2 under 66 percent, PHASE 3 under 33), as it keeps its place and its bottom edge',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__textTrace||typeof drawBossBar!=='function'||typeof bossTick!=='function'||typeof overseerPhaseOf!=='function') return 'SKIP: no boss bar here';
     var bad=[], g, b, tr, cb0=CFG.boss, i, e, ph={}, want=[[0.8,''],[0.5,'PHASE 2'],[0.2,'PHASE 3']], k, bot, seen;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.t=Math.max(g.t||0,30); g.bossDone=0; if(CFG.boss===0) CFG.boss=1; b=bossTick(true); CFG.boss=cb0; if(!b) return 'SKIP: staging: no Overseer';
       b.x=g.player.x+200; b.y=g.player.y; b.barSeen=1;
       for(k=0;k<want.length;k++){
         b.hp=Math.max(1,Math.round(b.maxhp*want[k][0]));
         tr=__textTrace(function(){ drawBossBar(); });
         seen=tr.filter(function(t){ return /^PHASE /.test(t.t); }).map(function(t){ return t.t; });
         if(!tr.some(function(t){ return t.t===b.name; })) { bad.push('the boss name is not drawn at '+Math.round(want[k][0]*100)+' percent'); continue; }
         if(want[k][1]===''&&seen.length) bad.push('a phase is named at '+Math.round(want[k][0]*100)+' percent: '+seen.join(','));
         if(want[k][1]!==''&&seen.indexOf(want[k][1])<0) bad.push('the bar at '+Math.round(want[k][0]*100)+' percent does not say '+want[k][1]+' (it says '+(seen.join(',')||'nothing')+')');
         if(!(HUDBOSSB>0)) bad.push('the boss plate left no bottom edge at '+Math.round(want[k][0]*100)+' percent');
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{ CFG.boss=cb0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
