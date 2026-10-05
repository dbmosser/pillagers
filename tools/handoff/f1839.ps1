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

if ($s.Contains("  {v:'18.39',what:")) { throw "check 18.39 is in the fixture already" }

SubRx @'
  {v:'18.38',what:
'@ @'
  {v:'18.39',what:'the weapon readout panel never covers the belt: in a raid HUD frame the bottom right panel starts to the right of the last belt key',
   run:function(){
     if(typeof hudPanel!=='function') return 'SKIP: no HUD panel';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, oHP=hudPanel, seen=[], C, br;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.bagOpen=false;
       __frame(0.016);
       hudPanel=function(x,y,w,h,a){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; seen.push([(m.a*x+m.c*y+m.e)/d,(m.b*x+m.d*y+m.f)/d,w*m.a/d,h*m.d/d]); return oHP.apply(this,arguments); };   // screen space: the corner is drawn scaled
       __frame(0.016);
       hudPanel=oHP;
       C=g.hotCells&&g.hotCells[g.hotCells.length-1];
       br=seen.filter(function(r){ return r[0]+r[2]>=W-30&&r[1]>H*0.6; })[0];
       if(!C||!br) return 'SKIP: no belt or no corner panel drawn';
       if(br[0]<C.x+C.w&&br[1]<C.y+C.h) bad.push('the corner panel starts at '+Math.round(br[0])+', over belt key 9 which ends at '+Math.round(C.x+C.w));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oHP; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
