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

if ($s.Contains("  {v:'21.04',what:")) { throw "check 21.04 is in the fixture already" }

SubRx @'
  {v:'21.03',what:
'@ @'
  {v:'21.04',what:'the open map hides the whole HUD: a white mark painted under the map backing comes out exactly the map colour, with nothing showing through',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map here';
     var bad=[], g, oMO=drawMapOverlay, px=null, err='', d=(typeof DPR==='number'&&DPR>0)?DPR:1, off;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=true;
       drawMapOverlay=function(){
         ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.globalAlpha=1; ctx.globalCompositeOperation='source-over'; ctx.fillStyle='#ffffff'; ctx.fillRect(0,0,Math.ceil(8*d),Math.ceil(8*d)); ctx.restore();
         var r=oMO.apply(this,arguments);
         try{ px=ctx.getImageData(Math.round(3*d),Math.round(3*d),1,1).data; }catch(_g){ px=null; err=String(_g&&_g.message||_g); }
         return r; };
       try{ __frame(0.016); } finally { drawMapOverlay=oMO; }
       if(!px) return 'SKIP: the map pixel could not be read '+err;
       off=Math.abs(px[0]-9)+Math.abs(px[1]-12)+Math.abs(px[2]-34);
       if(off>1||px[3]<255) bad.push('a white mark under the open map reads '+px[0]+','+px[1]+','+px[2]+' (alpha '+px[3]+') through the backing, not the map colour 9,12,34');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ drawMapOverlay=oMO; try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
