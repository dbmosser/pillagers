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

if ($s.Contains("  {v:'18.13',what:")) { throw "check 18.13 is in the fixture already" }

SubRx @'
  {v:'18.12',what:
'@ @'
  {v:'18.13',what:'stage C of the styling pass: the raid HUD panels share one rounded panel: in a drawn raid frame the conditions panel corner pixel is empty and a pixel just inside it is painted, and the same holds for the pillager board',
   run:function(){
     if(typeof hudPanel!=='function') return 'the HUD panels are flat rectangles';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof HUDBOX==='undefined') return 'SKIP: this fixture cannot deploy';
     var bad=[], g, keep=P.hud, R, a;
     function al(x,y){ return ctx.getImageData(Math.round(x*DPR),Math.round(y*DPR),1,1).data[3]; }
     function box(name,R){
       if(!R||!(R.w>20&&R.h>20)) return bad.push('control: no '+name+' panel to measure');
       // The HUD canvas carries a vignette at the screen edges, so every pixel is read against the one just outside the panel.
       var out=al(R.x-3,R.y-3), cor=al(R.x+0.6,R.y+0.6), ins=al(R.x+8,R.y+8), mid=al(R.x+0.6,R.y+R.h/2);
       if(cor>out+30) bad.push('the '+name+' panel corner is square (alpha '+cor+' against '+out+' outside)');
       if(ins<out+50) bad.push('the '+name+' panel is not painted inside its corner (alpha '+ins+' against '+out+' outside)');
       if(mid<out+50) bad.push('the '+name+' panel has no left edge (alpha '+mid+')');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.hud={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.legendOn=1;
       __frame(0.016); __frame(0.016);
       box('conditions',HUDBOX.cond); box('pillager board',HUDBOX.raiders);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.hud=keep; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
