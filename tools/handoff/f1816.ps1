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

if ($s.Contains("  {v:'18.16',what:")) { throw "check 18.16 is in the fixture already" }

SubRx @'
  {v:'18.15',what:
'@ @'
  {v:'18.16',what:'the trees and bushes bake their blobs: with the sprites warm a raid frame at the spawn issues under 120 arc calls (it issued about 250), the vegetation sprite store holds a handful of sizes, and a tree sprite is painted (its middle pixel is opaque)',
   run:function(){
     if(typeof vegSprite!=='function'||typeof VEGSPR==='undefined') return 'the trees are repainted every frame';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], P2=CanvasRenderingContext2D.prototype, real=P2.arc, n=0, g, i, e, d, ks;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.legendOn=1;
       for(i=0;i<4;i++) __frame(0.016);
       ks=Object.keys(VEGSPR.m);
       if(!ks.length) bad.push('no vegetation sprite was baked');
       if(ks.length>60) bad.push('the vegetation store holds '+ks.length+' sprites');
       e=vegSprite('tree',28); if(!e) bad.push('no tree sprite for a canopy of 28');
       else { d=e.c.getContext('2d').getImageData(Math.round(e.ox*e.ss),Math.round((e.oy-28*0.35)*e.ss),1,1).data; if(d[3]<200) bad.push('the tree sprite is blank at its middle (alpha '+d[3]+')'); }
       P2.arc=function(){ n++; return real.apply(this,arguments); };
       __frame(0.016);
       P2.arc=real;
       if(!(n<120)) bad.push('a warm frame still issues '+n+' arc calls');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P2.arc=real; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
