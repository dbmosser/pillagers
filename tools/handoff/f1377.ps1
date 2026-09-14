$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.76',what:
'@ @'
  {v:'13.77',what:'an abandoned run does not say you fell: abandoning a minute in with stall money carried prints that the money was left behind and not that it was lost where you fell, while a death still says where you fell (downed and extraction audit 2026-09-14, finding 7)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(!document.getElementById('oc_manifest')) return 'SKIP: no run report manifest in this page';
     var bad=[];
     var FELL=['where','you','fell'].join(' '), LEFT=['money','left','behind'].join(' ');
     function run(how){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       g.ents.length=0; g.player.downed=false;
       g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen)-60; g.t=60;
       g.pedSold=517; g.pedCarry=517;
       if(how==='dead'){ g.tel.deathKiller='sentry'; g.player.pendKiller='sentry'; }
       __endRaid(how);
       return String(document.getElementById('oc_manifest').textContent||'');
     }
     try{
       // THE FINDING: an abandon with stall money on him.
       var A=run('abandon');
       if(A===null) return 'SKIP: no live raid';
       if(A.indexOf('517')<0) return 'SKIP: the abandoned card printed no stall money line to read';
       if(A.indexOf(FELL)>=0) bad.push('an abandoned run told him his stall money was lost '+FELL);
       if(A.indexOf(LEFT)<0) bad.push('an abandoned run did not say the stall money was left behind');
       // CONTROL: a death still says where he fell.
       var B=run('dead');
       if(B!==null&&B.indexOf(FELL)<0) bad.push('control: a death did not say the stall money was lost '+FELL+', so this check cannot read the line');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
