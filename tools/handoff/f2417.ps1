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

if ($s.Contains("  {v:'24.17',what:")) { throw "check 24.17 is in the fixture already" }

SubRx @'
  {v:'24.16',what:
'@ @'
  {v:'24.17',what:'graphics program gfx23: casings settle into the floor: 60 brass casings in flight beside him, 2 seconds of frames later none of them is left in the shell list, a drawn frame paints no casing, and the floor shows brass at 50 or more of the 60 landing points',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot run raid frames';
     var bad=[], g=null, p=null, sh=[], i, t0, left=0, draws=0, hits=0, own=false, of=null, by0=GFX.bypass, s, a;
     function rb(cx,cy){
       var d=g.ground.getContext('2d').getImageData(Math.floor(cx)-1,Math.floor(cy)-1,3,3).data, m=-999, k;
       for(k=0;k<d.length;k+=4) m=Math.max(m,d[k]-d[k+2]);
       return m;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.ground||!g.ground.getContext) return 'SKIP: staging: this raid has no baked floor';
       p=g.player; p.iv=99; keys={}; GFX.bypass=0;
       for(i=0;i<60;i++){
         a=i*0.1047;
         s={brass:1,x:p.x+Math.cos(a)*60,y:p.y+Math.sin(a)*60,vx:Math.cos(a)*90,vy:Math.sin(a)*90,t:0,life:0.5+0.004*i,rot:i*0.37};
         g.shells.push(s); sh.push(s);
       }
       t0=performance.now();
       for(i=0;i<120&&!g.over;i++) __loop(t0+(i+1)*16.7);
       if(g.over) return 'SKIP: staging: the raid ended during the frames';
       for(i=0;i<sh.length;i++) if(g.shells.indexOf(sh[i])>=0) left++;
       if(left) bad.push(left+' of 60 settled casings are still in the shell list after 2 seconds (each is redrawn every frame)');
       own=Object.prototype.hasOwnProperty.call(wc,'fillRect'); of=wc.fillRect;
       wc.fillRect=function(x,y,w,h){ if(x===-1.6&&w===3.2) draws++; return of.apply(this,arguments); };
       try{ __frame(0.016); } finally { if(own) wc.fillRect=of; else delete wc.fillRect; own=false; }
       if(draws) bad.push('a drawn frame painted '+draws+' casings one by one, not 0');
       for(i=0;i<sh.length;i++){
         s=sh[i];
         if(s.x<4||s.y<4||s.x>g.ground.width-14||s.y>g.ground.height-14) continue;
         if(rb(s.x,s.y)>=40&&rb(s.x,s.y)-rb(s.x+9,s.y+9)>=25) hits++;
       }
       if(hits<50) bad.push('the floor shows brass at only '+hits+' of the 60 landing points, not 50 or more');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       GFX.bypass=by0; keys={};
       try{ var g2=__state(); if(g2){ if(!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
