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

if ($s.Contains("  {v:'26.20',what:")) { throw "check 26.20 is in the fixture already" }

SubRx @'
  {v:'26.19',what:
'@ @'
  {v:'26.20',what:'his question (2026-10-14, where is the Forge): every raid has the Forge station at a clear reachable spot near its aisle, drawn in the world and marked on the minimap and the sector map',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof ctx==='undefined') return 'SKIP: no raid here';
     var bad=[], seeds=[4242,7,99], si, sd, g, p, f, i, R, hit, OWN=Object.prototype.hasOwnProperty, seen={map:0,world:0}, hadC, hadW, rC, rW, n;
     function clean(){ __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); }
     try{
       for(si=0;si<seeds.length;si++){
         sd=seeds[si]; clean(); __deploy({kit:[],safe:null,mapIx:0,seed:sd});
         g=__state(); if(!g||g.over){ bad.push('seed '+sd+': no live raid'); continue; }
         f=g.forge;
         if(!f||!isFinite(f.x)||!isFinite(f.y)){ bad.push('seed '+sd+': the raid has no Forge'); try{ __endRaid('abandon'); }catch(_e1){} continue; }
         if(Math.hypot(f.x-2420,f.y-1540)>420) bad.push('seed '+sd+': the Forge is '+Math.round(Math.hypot(f.x-2420,f.y-1540))+' from its aisle');
         hit=0; R=g.map.walls||[];
         for(i=0;i<R.length;i++){ if(R[i]&&!R[i].win&&!R[i].ledge&&f.x>R[i].x-30&&f.x<R[i].x+R[i].w+30&&f.y>R[i].y-30&&f.y<R[i].y+R[i].h+30) hit++; }
         if(hit) bad.push('seed '+sd+': the Forge stands within 30 of '+hit+' walls');
         if(g.map.reachGrid&&!navReachable(g.map,f.x,f.y)) bad.push('seed '+sd+': no route reaches the Forge');
         for(i=0;i<g.containers.length;i++) if(Math.hypot(g.containers[i].x-f.x,g.containers[i].y-f.y)<46){ bad.push('seed '+sd+': a crate stands on the Forge'); break; }
         try{ __endRaid('abandon'); }catch(_e2){}
       }
       clean(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return bad.length?bad.join('; '):'SKIP: no live raid';
       p=g.player; f=g.forge;
       if(!f) return bad.length?bad.join('; '):'the raid has no Forge';
       p.x=f.x-80; p.y=f.y; p.face=0;
       render2D(0.05);
       if(!(typeof MMAP==='object'&&MMAP&&MMAP.got&&MMAP.got.forge==='in')) bad.push('the minimap does not mark the Forge ('+(typeof MMAP==='object'&&MMAP&&MMAP.got&&MMAP.got.forge)+')');
       hadC=OWN.call(ctx,'fillText'); rC=ctx.fillText;
       ctx.fillText=function(t){ if(String(t)==='THE FORGE') seen.map++; return rC.apply(this,arguments); };
       try{ g.mapOpen=true; drawMapOverlay(); } finally { g.mapOpen=false; if(hadC) ctx.fillText=rC; else delete ctx.fillText; }
       if(!seen.map) bad.push('the sector map does not name the Forge');
       hadW=OWN.call(wc,'fillText'); rW=wc.fillText;
       wc.fillText=function(t){ if(String(t)==='THE FORGE') seen.world++; return rW.apply(this,arguments); };
       try{ for(n=0;n<40&&!seen.world;n++){ p.x=f.x-80; p.y=f.y; render2D(0.05); } } finally { if(hadW) wc.fillText=rW; else delete wc.fillText; }
       if(!seen.world) bad.push('the world does not draw the Forge');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.mapOpen=false; __endRaid('abandon'); } }catch(_e3){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'26.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
