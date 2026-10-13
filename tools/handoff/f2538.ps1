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

if ($s.Contains("  {v:'25.38',what:")) { throw "check 25.38 is in the fixture already" }

SubRx @'
  {v:'25.37',what:
'@ @'
  {v:'25.38',what:'skeptic of his seal order (2026-10-12): the seal never lands within reach of a crate, so E at a crate always searches it: 70 raids, no container but the strongbox within 116 of the seal (the cut reach 70 plus the search reach 46), and the seal still stands in 40 or more places',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof FIXED_MAPS==='undefined') return 'SKIP: no raid here';
     var bad=[], hits=[], s, g, i, Q, d, md, mq, n=0, sp={}, ns=0, k;
     try{
       __topClear(); __runPrep();
       for(s=1;s<=70;s++){
         __deploy({kit:[],safe:null,mapIx:0,seed:s*7919});
         g=__state(); if(!g||!g.seal) return 'SKIP: no seal in the raid at seed '+(s*7919);
         k=g.seal.x+','+g.seal.y; if(!sp[k]){ sp[k]=1; ns++; }
         md=1e9; mq=null;
         for(i=0;i<(g.containers||[]).length;i++){
           Q=g.containers[i]; if(!Q||Q.strong) continue;
           d=Math.hypot(Q.x-g.seal.x,Q.y-g.seal.y); if(d<md){ md=d; mq=Q; }
         }
         n++;
         if(mq&&md<116) hits.push((s*7919)+': a '+(mq.kind||mq.type||'container')+' '+Math.round(md)+' from the seal');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     if(bad.length) return bad.join('; ');
     if(n<70) return 'only '+n+' raids ran';
     if(hits.length) return hits.length+' of 70 raids put the seal within reach of a crate, so E there cuts the seal and never searches it: '+hits.slice(0,5).join('; ');
     if(ns<40) return '70 seeds put the seal in only '+ns+' different places';
     return null; }},
  {v:'25.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
