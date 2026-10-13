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

if ($s.Contains("  {v:'24.53',what:")) { throw "check 24.53 is in the fixture already" }

SubRx @'
  {v:'24.52',what:
'@ @'
  {v:'24.53',what:'sprite program spr12 (the Howler redesign): the mortar tube turns toward its facing: its ochre muzzle ring sits right of the body facing right and left of it facing left (it used to point up-left whatever it shot at)',
   run:function(){
     if(typeof drawHowlerS!=='function') return 'SKIP: no howler painter';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var w0=wc, cv=document.createElement('canvas'), x2, bad=[], W=240, H=240, OX=120, OY=200, Z=4;
     cv.width=W; cv.height=H; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function mz(face){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,W,H); x2.setTransform(Z,0,0,Z,OX,OY); wc=x2;
       try{ drawHowlerS({kind:'howler',x:0,y:0,r:20,hp:120,maxhp:120,face:face,state:'patrol',step:0,hitT:0,muzzle:0,seenYou:false,overheat:0}); }
       finally{ wc=w0; x2.setTransform(1,0,0,1,0,0); }
       var d=x2.getImageData(0,0,W,H).data, q, i, px, sx=0, n=0, r, g, b, mx, mn, h;
       for(q=0;q<d.length;q+=4){ if(d[q+3]<200) continue; r=d[q]; g=d[q+1]; b=d[q+2]; mx=Math.max(r,g,b); mn=Math.min(r,g,b);
         if(mx<140||mx!==r||(mx-mn)<0.5*mx) continue; h=60*((g-b)/(mx-mn)); if(h<30||h>55) continue;
         i=q/4; px=i%W; sx+=(px-OX)/Z; n++; }
       return n?{x:sx/n,n:n}:{x:0,n:0}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       var a=mz(0), b=mz(Math.PI);
       if(a.n<20||b.n<20) bad.push('no muzzle ring drawn ('+a.n+', '+b.n+' pixels)');
       else { if(!(a.x>3)) bad.push('facing right the muzzle sits at '+a.x.toFixed(1)+' (not right of the body)');
              if(!(b.x<-3)) bad.push('facing left the muzzle sits at '+b.x.toFixed(1)+' (not left of the body)'); }
     }catch(er){ bad.push('threw: '+(er&&er.message||er)); }
     finally{ wc=w0; try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
