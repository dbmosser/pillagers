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

if ($s.Contains("  {v:'20.36',what:")) { throw "check 20.36 is in the fixture already" }

SubRx @'
  {v:'20.35',what:
'@ @'
  {v:'20.36',what:'in co-op a new machine lands far from every player: with every free spot near player 2 none arrives, and with player 2 far away one does',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netNearDist!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oND=netNearDist, near=0, far=0, calls=0, g, nM, i;
     function mach(){ var n=0, j; for(j=0;j<G.ents.length;j++){ var q=G.ents[j].kind; if(q==='sentry'||q==='crawler') n++; } return n; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       NET.on=true; NET.upSeed=g.seed>>>0;
       netNearDist=function(q){ calls++; return 100; };
       nM=mach(); g.nMach=nM+1; g.t=200; g.reinfT=0;
       updateEnts(0.016); near=mach()-nM;
       if(near>0) bad.push('a machine arrived with every free spot within 100 of a player');
       if(!calls) bad.push('the spot was never measured against the party');
       netNearDist=function(q){ return 5000; };
       nM=mach(); g.nMach=nM+1; g.reinfT=0;
       updateEnts(0.016); far=mach()-nM;
       if(far!==1) bad.push('with every player far away '+far+' machines arrived, not 1');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netNearDist=oND;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
