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

if ($s.Contains("  {v:'24.14',what:")) { throw "check 24.14 is in the fixture already" }

SubRx @'
  {v:'24.13',what:
'@ @'
  {v:'24.14',what:'his answer 38: screen shake goes from light to strong with the size of the hit and how often hits are coming in',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof damagePlayer!=='function') return 'SKIP: no raid here';
     var bad=[], g, p;
     function hit(n){ p.iv=0; p.hp=100; p.downed=false; G.shake=0; damagePlayer(n,'test','Test'); return G.shake; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       g.t=100; p.hurtHeat=undefined; p.hurtHeatAt=undefined;
       var one=hit(12);
       g.t=110; var big=hit(40);
       g.t=200; p.hurtHeat=undefined; p.hurtHeatAt=undefined;
       hit(12); g.t+=0.1; hit(12); g.t+=0.1; hit(12); g.t+=0.1; hit(12); g.t+=0.1;
       var burst=hit(12);
       g.t=300; var cool=hit(12);
       if(!(one>0)) bad.push('a hit does not shake the screen');
       if(!(big>one*1.5)) bad.push('a 40 damage hit shakes '+big.toFixed(2)+', not much more than a 12 damage hit at '+one.toFixed(2));
       if(!(burst>one*1.25)) bad.push('the fifth hit of a quick burst shakes '+burst.toFixed(2)+', no more than one stray hit at '+one.toFixed(2));
       if(!(Math.abs(cool-one)<one*0.05)) bad.push('a hit long after the burst shakes '+cool.toFixed(2)+', not back to a single hit at '+one.toFixed(2));
       if(!(big<=24&&burst<=24)) bad.push('the shake passes its cap of 24');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; G.shake=0; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
