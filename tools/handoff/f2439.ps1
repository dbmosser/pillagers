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

if ($s.Contains("  {v:'24.39',what:")) { throw "check 24.39 is in the fixture already" }

SubRx @'
  {v:'24.38',what:
'@ @'
  {v:'24.39',what:'graphics program gfx26: a frag blast on open floor darkens the baked floor by 12 or more at its centre and at four points 12 units out, and after 500 more decals (the old 420 cap churning) the floor there is still dark',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep)||typeof explodeFrag!=='function'||typeof decal!=='function') return 'SKIP: this fixture cannot set off a frag';
     var bad=[], g=null, p=null, best=null, i, j, x, y, lm, pts, b0=[], b1, by0=GFX.bypass;
     function L(px,py){ var d=g.ground.getContext('2d').getImageData(Math.round(px),Math.round(py),1,1).data; return 0.299*d[0]+0.587*d[1]+0.114*d[2]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.ground||!g.ground.getContext) return 'SKIP: staging: this raid has no baked floor';
       p=g.player; p.iv=99; keys={}; GFX.bypass=0;
       for(i=0;i<24;i++) for(j=0;j<3;j++){
         x=p.x+Math.cos(i*0.2618)*(520+j*90); y=p.y+Math.sin(i*0.2618)*(520+j*90);
         if(!(x>60&&y>60&&x<g.ground.width-60&&y<g.ground.height-60)) continue;
         if(roofAt(x,y)||(typeof inWaterMap==='function'&&inWaterMap(g.map,x,y))) continue;
         lm=L(x,y); if(!best||lm>best.l) best={x:Math.round(x),y:Math.round(y),l:lm};
       }
       if(!best||best.l<40) return 'SKIP: staging: no open floor bright enough to read a scorch on';
       pts=[[0,0],[12,0],[-12,0],[0,12],[0,-12]];
       for(i=0;i<pts.length;i++) b0.push(L(best.x+pts[i][0],best.y+pts[i][1]));
       explodeFrag({x:best.x,y:best.y,t:0,fuse:0});
       for(i=0;i<pts.length;i++){ b1=L(best.x+pts[i][0],best.y+pts[i][1]); if(b0[i]-b1<12) bad.push('the floor at ('+pts[i][0]+','+pts[i][1]+') from the blast went from '+b0[i].toFixed(1)+' to '+b1.toFixed(1)+', not 12 or more darker'); }
       for(i=0;i<500;i++) decal(p.x+(i%25)*3,p.y+Math.floor(i/25)*3,'#141210',4);
       if(typeof __frame==='function') __frame(0.016);
       for(i=0;i<pts.length;i++){ b1=L(best.x+pts[i][0],best.y+pts[i][1]); if(b0[i]-b1<12){ bad.push('after 500 more decals the blast spot ('+pts[i][0]+','+pts[i][1]+') is back to '+b1.toFixed(1)+' against '+b0[i].toFixed(1)); break; } }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       GFX.bypass=by0; keys={};
       try{ var g2=__state(); if(g2){ if(!g2.over){ g2.player.iv=0; g2.player.downed=false; g2.player.hp=Math.max(1,g2.player.hp); __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
