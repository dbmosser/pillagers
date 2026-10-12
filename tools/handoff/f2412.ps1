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

if ($s.Contains("  {v:'24.12',what:")) { throw "check 24.12 is in the fixture already" }

SubRx @'
  {v:'24.11',what:
'@ @'
  {v:'24.12',what:'sprite program spr9 (the Warden redesign): a Warden is drawn in gunmetal and oxide with no purple body (under 2 percent of its opaque pixels purple), and the whole hull mirrors with its facing (the launcher pod on its back sits left of the body facing right and right of it facing left)',
   run:function(){
     if(typeof drawWardenS!=='function') return 'SKIP: no warden painter';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var w0=wc, cv=document.createElement('canvas'), x2, bad=[], W=260;
     cv.width=W; cv.height=W; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function shot(face){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,W,W); x2.setTransform(4,0,0,4,130,236); wc=x2;
       var e={kind:'warden',x:0,y:0,r:30,hp:900,maxhp:900,face:face,state:'patrol',step:0,hitT:0,muzzle:0,seenYou:false,overheat:0,windup:null};
       try{ drawWardenS(e); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); }
       return x2.getImageData(0,0,W,W).data; }
     function stats(d){ var op=0,pu=0,L=0,R=0,q,i,px,py,r,g,b,mx,mn,h,s;
       for(q=0;q<d.length;q+=4){ if(d[q+3]<200) continue; op++; r=d[q]/255; g=d[q+1]/255; b=d[q+2]/255; mx=Math.max(r,g,b); mn=Math.min(r,g,b); s=mx>0?(mx-mn)/mx:0;
         if(mx-mn>0.02){ if(mx===r) h=60*(((g-b)/(mx-mn))%6); else if(mx===g) h=60*((b-r)/(mx-mn)+2); else h=60*((r-g)/(mx-mn)+4); if(h<0) h+=360; if(h>=260&&h<=300&&s>0.25) pu++; }
         i=q/4; px=i%W; py=(i-px)/W;
         if(py>=236-44*4&&py<=236-33*4&&mx<0.2){ if(px<130-19*4) L++; else if(px>130+19*4) R++; } }
       return {op:op,pu:pu,L:L,R:R}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       var a=stats(shot(0)), b=stats(shot(Math.PI));
       if(a.op<2000) bad.push('the Warden drew only '+a.op+' opaque pixels');
       if(a.pu>a.op*0.02) bad.push(a.pu+' of its '+a.op+' opaque pixels are purple (the elite colour)');
       if(!(a.L>=60&&a.R*4<a.L)) bad.push('facing right the dark mass beside its back is '+a.L+' left and '+a.R+' right (no launcher pod behind it)');
       if(!(b.R>=60&&b.L*4<b.R)) bad.push('facing left the dark mass beside its back is '+b.L+' left and '+b.R+' right (the hull does not mirror)');
     }catch(er){ bad.push('threw: '+(er&&er.message||er)); }
     finally{ wc=w0; try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
