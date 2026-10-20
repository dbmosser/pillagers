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

if ($s.Contains("  {v:'32.39',what:")) { throw "check 32.39 is in the fixture already" }

SubRx @'
  {v:'32.38',what:
'@ @'
  {v:'32.39',what:'calling an extraction folds the compact controls list so it cannot cover the countdown (critic 37)',
   run:function(){
     if(typeof legendAuto!=='function') return 'no legendAuto';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], r0=P.runs, oSay=say, g=null;
     try{
       say=function(){};
       P.runs=0; __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: staging: no raid';
       g.legendOn=1; g.legendAutoDone=false; g.legendExtDone=false; g.beaconT=null; legendAuto(5);
       if(g.legendOn!==1) bad.push('folded with no extraction called');
       g.beaconT=12; legendAuto(5);
       if(g.legendOn!==0) bad.push('still open with an extraction called');
       g.legendOn=1; legendAuto(6);
       if(g.legendOn!==1) bad.push('folded a second time (F1 open must stay open)');
       g.beaconT=null;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=oSay; P.runs=r0; try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null;
   }},
  {v:'32.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
