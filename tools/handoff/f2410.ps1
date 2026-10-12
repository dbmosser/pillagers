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

if ($s.Contains("  {v:'24.10',what:")) { throw "check 24.10 is in the fixture already" }

SubRx @'
  {v:'24.09',what:
'@ @'
  {v:'24.10',what:'sprite program spr2 (his order: make every sprite look better, gritty like ARC Raiders): the Sentry is redrawn with an ink contour round its hull, a camera lens in the sensor language (a dim cool white when idle, red when hunting, never amber at rest), the whole body turned with its facing, tread teeth that run as it rolls, and a brass edge when elite',
   run:function(){
     if(typeof drawSentryS!=='function') return 'SKIP: no sentry painter here';
     var bad=[], w0=wc, cvs=document.createElement('canvas'), x2, staged=0, t0=null;
     cvs.width=420; cvs.height=420; x2=cvs.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function mk(o){ var e={kind:'sentry',x:0,y:0,r:22,hp:150,maxhp:150,face:0,state:'patrol',step:0,legs:0,hitT:0,muzzle:0,seenYou:false,overheat:0,windup:null}, k; for(k in o) e[k]=o[k]; return e; }
     function paint(e){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,420,420); x2.setTransform(6,0,0,6,210,370); wc=x2;
       try{ drawSentryS(e); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); } }
     function px(lx,ly){ return x2.getImageData(Math.round(210+lx*6),Math.round(370+ly*6),1,1).data; }
     function count(lx,ly,w,h,f){ var d=x2.getImageData(Math.round(210+lx*6),Math.round(370+ly*6),Math.round(w*6),Math.round(h*6)).data, n=0, q;
       for(q=0;q<d.length;q+=4) if(d[q+3]>200&&f(d[q],d[q+1],d[q+2])) n++; return n; }
     function ink(r,g,b){ return r<34&&g<34&&b<34; }
     try{
       if(typeof G==='undefined'||!G||G.over||!G.map){ __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); staged=1; }
       if(typeof G==='undefined'||!G) return 'SKIP: no raid to draw in';
       t0=G.t; G.t=10;
       paint(mk({}));
       var nInk=count(-16.5,-34.5,33,22.5,ink);
       if(nInk<600) bad.push('the hull has no ink contour ('+nInk+' near-ink pixels round it, want 600 or more)');
       var p=px(8.6,-42);
       if(!(p[3]>200&&p[0]>100&&p[2]>=p[0]-10)) bad.push('the idle lens is not a dim cool white ('+p.join(',')+')');
       paint(mk({state:'chase',seenYou:true}));
       p=px(8.6,-42);
       if(!(p[0]>200&&p[1]<130)) bad.push('the hunting lens is not red ('+p.join(',')+')');
       paint(mk({face:Math.PI}));
       p=px(-8.6,-42);
       if(!(p[3]>200&&p[0]>100&&p[2]>=p[0]-10)) bad.push('facing left, the lens is not on the left side ('+p.join(',')+')');
       if(count(-16.5,-34.5,33,22.5,ink)<600) bad.push('facing left, the hull lost its contour');
       paint(mk({step:0.3})); var a=x2.getImageData(210-17*6,Math.round(370-1.2*6),34*6,1).data;
       paint(mk({step:0.8})); var b=x2.getImageData(210-17*6,Math.round(370-1.2*6),34*6,1).data, nd=0, q;
       for(q=0;q<a.length;q+=4) if(Math.abs(a[q]-b[q])+Math.abs(a[q+1]-b[q+1])+Math.abs(a[q+2]-b[q+2])>30) nd++;
       if(nd<20) bad.push('the tread teeth do not run with the step ('+nd+' pixels differ)');
       paint(mk({elite:1}));
       var nB=count(-14,-33,20,1.2,function(r,g,b2){ return r>170&&g>130&&b2<110; });
       if(nB<30) bad.push('an elite has no brass edge on its top plate ('+nB+' px)');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ wc=w0; try{ if(t0!==null&&G) G.t=t0; }catch(_g){} if(staged){ try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} } }
     return bad.length?bad.join('; '):null; }},
  {v:'24.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
