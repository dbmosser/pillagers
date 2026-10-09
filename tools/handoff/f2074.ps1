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

if ($s.Contains("  {v:'20.74',what:")) { throw "check 20.74 is in the fixture already" }

SubRx @'
  {v:'20.73',what:
'@ @'
  {v:'20.74',what:'at 1080p the full controls list (H twice) ends above the line over the belt: its plate never covers that line or the dark strip behind it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__textTrace&&window.__forceSize&&window.__pinDPR)) return 'SKIP: this fixture cannot draw the HUD';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, nothing is drawn';
     if(typeof drawLegend!=='function'||typeof hudPanel!=='function'||typeof cv==='undefined'||typeof hcv==='undefined') return 'SKIP: no legend here';
     var bad=[], g, oDL=drawLegend, oHP=hudPanel, inLeg=0, plates=[], tr, cap=null, hide=null, i, t, capTop, pb, ndl='[FIRE]'+' use';
     var sw=[cv.style.width,cv.style.height,hcv.style.width,hcv.style.height];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.player.hp=100000; g.player.maxhp=100000; g.ents.length=0;
       g.bagOpen=false; g.mapOpen=false; g.legendOn=2;
       if(P.hud&&P.hud.legend) P.hud.legend.c=0;
       __pinDPR(1); __forceSize(1920,1080);
       if(W!==1920||H!==1080) return 'SKIP: the canvas would not take 1920x1080 ('+W+'x'+H+')';
       for(i=0;i<6;i++) __frame(0.016);
       drawLegend=function(){ inLeg=1; try{ return oDL.apply(this,arguments); } finally{ inLeg=0; } };
       hudPanel=function(x,y,w,h){ if(inLeg){ var T=ctx.getTransform(); plates.push({y0:T.d*y+T.f,y1:T.d*(y+h)+T.f}); } return oHP.apply(this,arguments); };
       tr=__textTrace(function(){ __frame(0.016); });
       for(i=0;i<tr.length;i++){ t=tr[i].t; if(t.indexOf(ndl)>=0&&tr[i].align==='center') cap=tr[i]; else if(/^H  hide$/.test(t)) hide=tr[i]; }
       if(!plates.length) return 'SKIP: the full list was not drawn';
       if(!cap||!(cap.px>0)) return 'SKIP: no line over the belt was drawn';
       capTop=cap.y-cap.px*0.95;
       pb=plates[0].y1;
       if(pb>capTop+0.5) bad.push('the full list ends at y '+Math.round(pb)+', '+Math.round(pb-capTop)+' px into the dark strip behind the line over the belt (strip top '+Math.round(capTop)+')');
       if(hide&&hide.y>capTop) bad.push('H  hide sits at y '+Math.round(hide.y)+', on the strip over the belt');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       drawLegend=oDL; hudPanel=oHP;
       try{ cv.style.width=sw[0]; cv.style.height=sw[1]; hcv.style.width=sw[2]; hcv.style.height=sw[3]; resize(); }catch(_rs){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.legendOn=1; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
