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

if ($s.Contains("  {v:'18.70',what:")) { throw "check 18.70 is in the fixture already" }

SubRx @'
  {v:'18.69',what:
'@ @'
  {v:'18.70',what:'an extraction ring label stays whole on screen: with a ring at the right edge, its label ends inside the screen',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, Z=null, oW=w2s, oFT=ctx.fillText, rec=[], i, r;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       for(i=0;i<g.zones.length;i++) if(g.zones[i]&&g.zones[i].open){ Z=g.zones[i]; break; }
       if(!Z) return 'SKIP: no open ring';
       w2s=function(x,h,y){ if(x===Z.x&&y===Z.y) return {x:W-14,y:H*0.45}; return oW.apply(this,arguments); };
       ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, w=ctx.measureText(String(s)).width; if(String(s).indexOf('EXTRACTION POINT')===0) rec.push({l:(m.a*(x-w/2)+m.e)/d,r:(m.a*(x+w/2)+m.e)/d}); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { w2s=oW; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       if(!rec.length) return 'SKIP: the ring label was not drawn';
       r=rec[0];
       if(r.r>W+1) bad.push('the ring label runs off the right edge (ends at '+Math.round(r.r)+' of '+W+')');
       if(r.l<-1) bad.push('the ring label starts off the left edge');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ w2s=oW; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
