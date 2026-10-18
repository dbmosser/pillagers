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

if ($s.Contains("  {v:'29.29',what:")) { throw "check 29.29 is in the fixture already" }

SubRx @'
  {v:'29.28',what:
'@ @'
  {v:'29.29',what:'the compact controls list opens on arrival and folds to its one-line hint 30 seconds into the raid, once (style guide: hidden except F1 and the first 30 s)',
   run:function(){
     if(typeof legendAuto!=='function') return 'the controls list never folds at 30 s (no legendAuto)';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], r0=P.runs, oSay=say, g=null, rl;
     function at(s){ g.t=s; rl=(g.raidLen===undefined?CFG.raidSec:g.raidLen); g.timeLeft=rl-s; try{ drawHUD(); }catch(_h){} }
     try{
       say=function(){};
       P.runs=0; __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: staging: no raid';
       g.legendOn=1; g.legendAutoDone=false;
       at(5);
       if(g.legendOn!==1) bad.push('the list folded at 5 s ('+g.legendOn+')');
       at(31);
       if(g.legendOn!==0) bad.push('the list is still open at 31 s ('+g.legendOn+')');
       g.legendOn=1; at(40);
       if(g.legendOn!==1) bad.push('a list he opened again after 30 s was folded again');
       g.legendOn=2; g.legendAutoDone=false; at(35);
       if(g.legendOn!==2) bad.push('the full list was folded at 35 s');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=oSay; P.runs=r0; try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
