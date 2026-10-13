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

if ($s.Contains("  {v:'24.43',what:")) { throw "check 24.43 is in the fixture already" }

SubRx @'
  {v:'24.42',what:
'@ @'
  {v:'24.43',what:'sprite program spr4 (his order: make every sprite look better, gritty like ARC Raiders): the Crier is redrawn as a loudspeaker drone that tilts instead of spinning (its inked outline keeps its size from one moment to the next), with four rotor blurs, an ochre-ringed horn, and the ALARM countdown arc coming out of the horn',
   run:function(){
     if(typeof drawSnitchS!=='function') return 'SKIP: no crier painter here';
     var bad=[], w0=wc, cvs=document.createElement('canvas'), x2, staged=0, t0=null, nEl=0;
     cvs.width=480; cvs.height=480; x2=cvs.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function mk(o){ var e={kind:'snitch',x:0,y:0,r:11,hp:38,maxhp:38,face:0,state:'patrol',step:0,legs:0,hitT:0,muzzle:0,seenYou:false,overheat:0,wind:null,windup:null}, k; for(k in o) e[k]=o[k]; return e; }
     function paint(e,tt){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,480,480); x2.setTransform(6,0,0,6,240,400); wc=x2; G.t=tt;
       try{ drawSnitchS(e); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); } }
     function px(lx,ly){ return x2.getImageData(Math.round(240+lx*6),Math.round(400+ly*6),1,1).data; }
     function box(){ var d=x2.getImageData(0,0,480,480).data, q, i, X0=1e9, X1=-1, Y0=1e9, Y1=-1, xx, yy;
       for(q=0;q<d.length;q+=4){ if(d[q+3]>200&&d[q]<34&&d[q+1]<34&&d[q+2]<34){ i=q/4; xx=i%480; yy=(i-xx)/480; if(xx<X0) X0=xx; if(xx>X1) X1=xx; if(yy<Y0) Y0=yy; if(yy>Y1) Y1=yy; } }
       return {w:X1-X0, h:Y1-Y0}; }
     function count(f){ var d=x2.getImageData(0,0,480,480).data, n=0, q; for(q=0;q<d.length;q+=4) if(d[q+3]>200&&f(d[q],d[q+1],d[q+2])) n++; return n; }
     try{
       if(typeof G==='undefined'||!G||G.over||!G.map){ __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); staged=1; }
       if(typeof G==='undefined'||!G) return 'SKIP: no raid to draw in';
       t0=G.t;
       paint(mk({}),10); var b1=box();
       paint(mk({}),10.5); var b2=box();
       if(!(b1.w>40&&b1.h>30)) bad.push('the crier has no ink contour ('+b1.w+' x '+b1.h+' px)');
       if(Math.abs(b1.w-b2.w)>3||Math.abs(b1.h-b2.h)>3) bad.push('the body still spins: its ink outline is '+b1.w+' x '+b1.h+' then '+b2.w+' x '+b2.h+' half a second later');
       x2.ellipse=function(cx,cy,rx){ if(rx>6&&rx<7) nEl++; return CanvasRenderingContext2D.prototype.ellipse.apply(this,arguments); };
       paint(mk({}),10);
       delete x2.ellipse;
       if(nEl!==4) bad.push('there are '+nEl+' rotor blurs, not 4');
       var nO=count(function(r,g,b){ return r>170&&g>120&&g<170&&b<80; });
       if(nO<20) bad.push('no ochre ring at a horn mouth ('+nO+' px)');
       var hov=17+Math.sin(10*6)*4, oy=-hov-7, a=0.1, hmx=9.6*Math.cos(a)-4.6*Math.sin(a), hmy=oy+9.6*Math.sin(a)+4.6*Math.cos(a);
       paint(mk({state:'alarm',seenYou:true,wind:2}),10);
       var p=px(hmx+22*Math.cos(1.0472),hmy+22*Math.sin(1.0472));
       if(!(p[0]>200&&p[1]<120)) bad.push('the ALARM countdown arc does not come out of the horn ('+p.join(',')+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ wc=w0; try{ delete x2.ellipse; }catch(_d){} try{ if(t0!==null&&G) G.t=t0; }catch(_g){} if(staged){ try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} } }
     return bad.length?bad.join('; '):null; }},
  {v:'24.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
