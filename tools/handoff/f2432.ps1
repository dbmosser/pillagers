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

if ($s.Contains("  {v:'24.32',what:")) { throw "check 24.32 is in the fixture already" }

SubRx @'
  {v:'24.31',what:
'@ @'
  {v:'24.32',what:'spr20: the Peddler has a wide hat and a pack frame, wears his own outfit and his lantern glow is baked',
   run:function(){
     if(typeof drawPeddlerS!=='function'||typeof wc==='undefined') return 'SKIP: no Peddler here';
     var c=document.createElement('canvas'); c.width=480; c.height=480; var x=c.getContext('2d'), w0=wc, bad=[], nGr=0, d;
     var e={kind:'peddler',x:0,y:0,r:12,hp:150,maxhp:150,face:1.57,coat:'#d8a13a',neutral:1,step:0,hitT:0,
            stock:[{k:'bandage',sold:false},{k:'medkit',sold:false},{k:'ammobox',sold:false}]};
     x.createRadialGradient=function(){ nGr++; return CanvasRenderingContext2D.prototype.createRadialGradient.apply(this,arguments); };
     try{ x.setTransform(6,0,0,6,240,400); wc=x; drawPeddlerS(e); wc=w0; x.setTransform(1,0,0,1,0,0); d=x.getImageData(0,0,480,480).data; }
     catch(er){ bad.push('threw: '+(er&&er.message||er)); }
     finally{ wc=w0; delete x.createRadialGradient; }
     if(!d) return bad.join('; ');
     if(nGr>0) bad.push('the Peddler draw made '+nGr+' radial gradients (want 0: the glow is baked)');
     function wid(u){ var py=Math.round(400+6*u), a=-1, b2=-1, px; for(px=0;px<480;px++){ if(d[(py*480+px)*4+3]>200){ if(a<0) a=px; b2=px; } } return a<0?0:(b2-a+1)/6; }
     var top=-1, py; for(py=0;py<480&&top<0;py++){ for(var px=180;px<300;px++){ if(d[(py*480+px)*4+3]>200){ top=py; break; } } }
     // his hat, on the body alone (drawOp in his outfit, no pack frame or goods beside it)
     x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,480,480); x.setTransform(6,0,0,6,240,400); wc=x;
     try{ drawOp(0,0,1.57,0,'#d8a13a',0,0,'none',0,{moving:false,sprint:false,ads:false,hurt:0,outfit:'outpeddler'}); }catch(er2){ bad.push('threw: '+(er2&&er2.message||er2)); } finally{ wc=w0; x.setTransform(1,0,0,1,0,0); }
     d=x.getImageData(0,0,480,480).data;
     var brim=wid(-36.6), head=wid(-30);
     if(brim<22) bad.push('no wide hat brim: the widest row at the brow is '+brim.toFixed(1)+' (want 22 or more; the head is '+head.toFixed(1)+')');
     if(top<0||(400-top)/6<15+48) bad.push('no pack frame rising over his head (top of the figure '+(top<0?'none':((400-top)/6-15).toFixed(1))+' above his feet)');
     if(typeof OUTFITS!=='undefined'&&!OUTFITS.outpeddler) bad.push('no outpeddler outfit');
     if(typeof COSMETICS!=='undefined'&&COSMETICS.some(function(cc){ return cc&&cc.id==='outpeddler'; })) bad.push('the Peddler outfit is on sale');
     return bad.length?bad.join('; '):null; }},
  {v:'24.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
