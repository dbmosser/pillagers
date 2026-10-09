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

if ($s.Contains("  {v:'21.06',what:")) { throw "check 21.06 is in the fixture already" }

SubRx @'
  {v:'21.05',what:
'@ @'
  {v:'21.06',what:'at 4K an extraction ring label at the screen edge keeps a margin: with the ring at the right edge, the dark plate behind its words ends at least 8 pixels inside the screen',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, Z=null, oW=w2s, oFT=ctx.fillText, oFR=ctx.fillRect, last=null, rec=[], lab='', i, r, d=(typeof DPR==='number'&&DPR>0)?DPR:1;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       for(i=0;i<g.zones.length;i++) if(g.zones[i]&&g.zones[i].open){ Z=g.zones[i]; break; }
       if(!Z) return 'SKIP: no open ring';
       lab=String(zoneBadge(Z));
       w2s=function(x,h,y){ if(x===Z.x&&y===Z.y) return {x:W-14,y:H*0.45}; return oW.apply(this,arguments); };
       ctx.fillRect=function(x,y,w,h){ var m=ctx.getTransform(); last={l:(m.a*x+m.e)/d,r:(m.a*(x+w)+m.e)/d}; return oFR.apply(this,arguments); };
       ctx.fillText=function(s,x,y){ if(String(s)===lab&&last) rec.push(last); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { w2s=oW; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }
       if(!rec.length) return 'SKIP: the ring label was not drawn';
       r=rec[0];
       if(r.r>W-8) bad.push('at 4K the ring label plate ends '+Math.round(W-r.r)+' px from the right edge of the screen');
       if(r.l<0) bad.push('at 4K the ring label plate starts off the left edge of the screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ w2s=oW; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
