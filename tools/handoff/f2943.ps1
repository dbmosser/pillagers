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

if ($s.Contains("  {v:'29.43',what:")) { throw "check 29.43 is in the fixture already" }

SubRx @'
  {v:'29.42',what:
'@ @'
  {v:'29.43',what:'the Heavy plates, the Big Pauldron and the Raider round pads are drawn with bare steel paint chips and colour panel stripes, inside the old outline; the spiked pad is not chipped',
   run:function(){
     if(typeof drawVest!=='function'||typeof drawPads!=='function') return 'SKIP: no drawVest';
     var bad=[], kw=wc, SC=240, sch={a:'#c8a24a'};
     function paint(fn){
       var cv2=document.createElement('canvas'), x2;
       cv2.width=SC; cv2.height=SC; x2=cv2.getContext('2d');
       wc=x2;
       try{ x2.translate(120,20); x2.scale(4,4); fn(); }
       finally { wc=kw; }
       return x2.getImageData(0,0,SC,SC).data;
     }
     function near(d,i,r,g,b,t){ return d[i+3]>200&&Math.abs(d[i]-r)<=t&&Math.abs(d[i+1]-g)<=t&&Math.abs(d[i+2]-b)<=t; }
     function chips(d){ var n=0, i; for(i=0;i<d.length;i+=4) if(near(d,i,223,230,236,12)) n++; return n; }
     function box(d){ var x1=999,x2=-1,y1=999,y2=-1,p,q,i; for(q=0;q<SC;q++) for(p=0;p<SC;p++){ i=(q*SC+p)*4; if(d[i+3]>10){ if(p<x1) x1=p; if(p>x2) x2=p; if(q<y1) y1=q; if(q>y2) y2=q; } } return {w:(x2-x1+1)/4,h:(y2-y1+1)/4}; }
     try{
       var v=paint(function(){ drawVest('vestheavy','lean',0,30,'#4a5a6a',sch,1); });
       var pb=paint(function(){ drawPads('padsbig','lean',0,30,1,sch); });
       var pr=paint(function(){ drawPads('padsround','lean',0,30,1,sch); });
       var ps=paint(function(){ drawPads('padsspike','lean',0,30,1,sch); });
       var cv=chips(v), cb=chips(pb), cr=chips(pr), cs=chips(ps), bv=box(v), bb=box(pb), br=box(pr), i1, i2;
       if(cv<20) bad.push('the Heavy plates show only '+cv+' bare steel chip pixels (want 20 or more)');
       if(cb<14) bad.push('the Big Pauldron shows only '+cb+' bare steel chip pixels (want 14 or more)');
       if(cr<8) bad.push('the Raider round pads show only '+cr+' bare steel chip pixels (want 8 or more)');
       if(cs>0) bad.push('the spiked pad is chipped too ('+cs+' pixels), it should stay clean');
       i1=(68*SC+97)*4; i2=(68*SC+142)*4;
       if(!near(v,i1,200,162,74,14)||!near(v,i2,200,162,74,14)) bad.push('the Heavy plates have no colour stripe on both sides');
       if(bv.w>17.8||bv.h>10.9) bad.push('the Heavy plates grew to '+bv.w.toFixed(1)+'x'+bv.h.toFixed(1)+' px (old outline 17.4x10.6)');
       if(bb.w>15.8||bb.h>12.6) bad.push('the Big Pauldron grew to '+bb.w.toFixed(1)+'x'+bb.h.toFixed(1)+' px (old outline 15.2x12.0)');
       if(br.w>31.2||br.h>9.9) bad.push('the round pads grew to '+br.w.toFixed(1)+'x'+br.h.toFixed(1)+' px (old outline 30.8x9.4)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=kw; }
     return bad.length?bad.join('; '):null; }},
  {v:'29.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
