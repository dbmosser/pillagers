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

if ($s.Contains("  {v:'21.07',what:")) { throw "check 21.07 is in the fixture already" }

SubRx @'
  {v:'21.06',what:
'@ @'
  {v:'21.07',what:'a ring label never prints under the open backpack: with the ring behind the panel its label is drawn while the backpack is shut and left out while it is open',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, Z=null, oW=w2s, oFT=ctx.fillText, n=0, shut=0, bp, i, pt=null, lab='';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.mapOpen=false; g.bagOpen=true;
       __frame(0.016); __frame(0.016);
       bp=g.bagPanel; if(!bp||!(bp.w>0)||!(bp.h>0)) return 'SKIP: the backpack panel was not drawn';
       for(i=0;i<g.zones.length;i++) if(g.zones[i]&&g.zones[i].open){ Z=g.zones[i]; break; }
       if(!Z) return 'SKIP: no open ring';
       lab=String(zoneBadge(Z));
       pt={x:bp.x+bp.w*0.5,y:bp.y+bp.h*0.55};
       w2s=function(x,h,y){ if(x===Z.x&&y===Z.y) return {x:pt.x,y:pt.y}; return oW.apply(this,arguments); };
       ctx.fillText=function(s,x,y){ if(String(s)===lab) n++; return oFT.apply(this,arguments); };
       g.bagOpen=false; n=0; __frame(0.016); shut=n;
       if(!shut) return 'SKIP: the ring label is not drawn at that spot even with the backpack shut';
       g.bagOpen=true; __frame(0.016); n=0; __frame(0.016);
       if(n) bad.push('with the backpack open the ring label was drawn '+n+' times behind the panel');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ w2s=oW; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2){ g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
