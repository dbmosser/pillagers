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

if ($s.Contains("  {v:'24.00',what:")) { throw "check 24.00 is in the fixture already" }

SubRx @'
  {v:'23.99',what:
'@ @'
  {v:'24.00',what:'graphics program gfx22: a ground stamp (a scorch of radius 20) darkens the baked floor where it lands by 20 or more, is written to the raid stamp log, is painted back after the floor is rebaked (gfxScarReplay), and stamps nothing with the graphics hooks bypassed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof scarStamp!=='function') return 'scarStamp is missing';
     if(typeof gfxScarReplay!=='function') return 'gfxScarReplay is missing: nothing paints the stamps back after a rebake';
     var bad=[], g=null, keep=null, fresh, fc, best=null, i, j, x, y, lum, l0, l1, n0, by0=GFX.bypass;
     function L(cv2,px,py){ var d=cv2.getContext('2d').getImageData(Math.round(px),Math.round(py),1,1).data; return 0.299*d[0]+0.587*d[1]+0.114*d[2]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.ground||!g.ground.getContext) return 'SKIP: staging: this raid has no baked floor';
       keep=g.ground; GFX.bypass=0;
       for(i=0;i<16;i++) for(j=1;j<=3;j++){
         x=g.player.x+Math.cos(i*0.3927)*90*j; y=g.player.y+Math.sin(i*0.3927)*90*j;
         if(!(x>30&&y>30&&x<keep.width-30&&y<keep.height-30)) continue;
         lum=L(keep,x,y); if(!best||lum>best.l) best={x:Math.round(x),y:Math.round(y),l:lum};
       }
       if(!best||best.l<45) return 'SKIP: staging: no floor bright enough near him to read a scorch on';
       n0=(g.scarLog||[]).length;
       if(!scarStamp('scorch',best.x,best.y,{r:20})) bad.push('scarStamp refused a scorch on open floor in a live raid');
       l1=L(keep,best.x,best.y);
       if(best.l-l1<20) bad.push('the scorch darkened the floor by '+(best.l-l1).toFixed(1)+', not 20 or more ('+best.l.toFixed(1)+' to '+l1.toFixed(1)+')');
       if(!g.scarLog||g.scarLog.length!==n0+1) bad.push('the stamp log holds '+(g.scarLog?g.scarLog.length:'nothing')+' after one stamp, not '+(n0+1));
       fresh=document.createElement('canvas'); fresh.width=keep.width; fresh.height=keep.height;
       fc=fresh.getContext('2d'); fc.fillStyle='#8a8478'; fc.fillRect(0,0,fresh.width,fresh.height);
       g.ground=fresh; l0=L(fresh,best.x,best.y);
       gfxScarReplay();
       l1=L(fresh,best.x,best.y);
       if(l0-l1<20) bad.push('after a rebake the replay darkened the scorch spot by '+(l0-l1).toFixed(1)+', not 20 or more: the mark is lost');
       n0=g.scarLog.length; GFX.bypass=1;
       if(scarStamp('scorch',best.x+60,best.y,{r:20})) bad.push('scarStamp stamped with the graphics hooks bypassed');
       if(g.scarLog.length!==n0) bad.push('a bypassed stamp was still logged');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       GFX.bypass=by0;
       try{ var g2=__state(); if(g2){ if(keep) g2.ground=keep; if(!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
