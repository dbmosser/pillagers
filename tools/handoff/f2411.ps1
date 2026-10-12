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

if ($s.Contains("  {v:'24.11',what:")) { throw "check 24.11 is in the fixture already" }

SubRx @'
  {v:'24.10',what:
'@ @'
  {v:'24.11',what:'sprite program spr3 (his order: make every sprite look better, gritty like ARC Raiders): the Crawler is redrawn with an ink contour, a rust-brown shell instead of the foe team red, three separate eyes in the sensor language (a dim cool white when idle, never amber at rest), and jointed legs whose feet step on a tripod gait',
   run:function(){
     if(typeof drawCrawlerS!=='function') return 'SKIP: no crawler painter here';
     var bad=[], w0=wc, cvs=document.createElement('canvas'), x2, staged=0, t0=null;
     cvs.width=420; cvs.height=320; x2=cvs.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function mk(o){ var e={kind:'crawler',x:0,y:0,r:15,hp:52,maxhp:52,face:0,state:'patrol',step:0,legs:0,hitT:0,muzzle:0,seenYou:false,overheat:0,windup:null}, k; for(k in o) e[k]=o[k]; return e; }
     function paint(e){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,420,320); x2.setTransform(6,0,0,6,200,250); wc=x2;
       try{ drawCrawlerS(e); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); } }
     function px(lx,ly){ return x2.getImageData(Math.round(200+lx*6),Math.round(250+ly*6),1,1).data; }
     function count(f){ var d=x2.getImageData(0,0,420,320).data, n=0, q; for(q=0;q<d.length;q+=4) if(d[q+3]>200&&f(d[q],d[q+1],d[q+2])) n++; return n; }
     try{
       if(typeof G==='undefined'||!G||G.over||!G.map){ __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); staged=1; }
       if(typeof G==='undefined'||!G) return 'SKIP: no raid to draw in';
       t0=G.t; G.t=10;
       paint(mk({}));
       var nInk=count(function(r,g,b){ return r<34&&g<34&&b<34; });
       if(nInk<500) bad.push('the crawler has no ink contour ('+nInk+' near-ink pixels, want 500 or more)');
       var nRed=count(function(r,g,b){ return r>150&&g<75&&b<60; });
       if(nRed>40) bad.push('the body is still painted in a saturated red that reads as the foe team colour ('+nRed+' px)');
       var p=px(17,-14.8);
       if(!(p[3]>200&&p[0]>90&&p[2]>=p[0]-10)) bad.push('the idle main eye is not a dim cool white ('+p.join(',')+')');
       paint(mk({state:'chase',seenYou:true}));
       p=px(17,-12.8);
       if(!(p[0]>200&&p[1]<130)) bad.push('the hunting main eye is not red ('+p.join(',')+')');
       paint(mk({legs:0.6})); var a=x2.getImageData(0,Math.round(250-4*6),420,5*6).data;
       paint(mk({legs:2.2})); var b=x2.getImageData(0,Math.round(250-4*6),420,5*6).data, nd=0, q;
       for(q=0;q<a.length;q+=4) if(Math.abs(a[q+3]-b[q+3])>120) nd++;
       if(nd<60) bad.push('the feet do not step between two leg phases ('+nd+' pixels differ)');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ wc=w0; try{ if(t0!==null&&G) G.t=t0; }catch(_g){} if(staged){ try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} } }
     return bad.length?bad.join('; '):null; }},
  {v:'24.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
