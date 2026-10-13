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

if ($s.Contains("  {v:'24.56',what:")) { throw "check 24.56 is in the fixture already" }

SubRx @'
  {v:'24.55',what:
'@ @'
  {v:'24.56',what:'sprite program spr13 (the Pillbox redesign): a crown of brass organ pipes stands on its drum, and its live mouth charges red in the sensor language, with no lilac or violet in it (it was #e0a0ff)',
   run:function(){
     if(typeof drawChoirS!=='function') return 'SKIP: no pillbox painter';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var w0=wc, cv=document.createElement('canvas'), x2, bad=[], W=280, H=280, OX=140, OY=240, Z=4;
     cv.width=W; cv.height=H; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       x2.setTransform(Z,0,0,Z,OX,OY); wc=x2;
       try{ drawChoirS({kind:'choir',x:0,y:0,r:26,hp:400,maxhp:400,face:0,state:'chase',step:0,hitT:0,muzzle:0,seenYou:true,overheat:0}); }
       finally{ wc=w0; x2.setTransform(1,0,0,1,0,0); }
       var d=x2.getImageData(0,0,W,H).data, q, i, px, py, wx, wy, brass=0, vio=0, red=0, r, g, b, mx, mn, h, s;
       for(q=0;q<d.length;q+=4){ if(d[q+3]<200) continue; i=q/4; px=i%W; py=(i-px)/W; wx=(px-OX)/Z; wy=(py-OY)/Z;
         r=d[q]/255; g=d[q+1]/255; b=d[q+2]/255; mx=Math.max(r,g,b); mn=Math.min(r,g,b); if(mx-mn<0.02) continue; s=(mx-mn)/mx;
         if(mx===r) h=60*(((g-b)/(mx-mn))%6); else if(mx===g) h=60*((b-r)/(mx-mn)+2); else h=60*((r-g)/(mx-mn)+4); if(h<0) h+=360;
         if(wy<-40&&h>=34&&h<=56&&s>0.35&&mx>0.45) brass++;
         if(Math.hypot(wx-17,wy+24)<=9){ if(h>=255&&h<=325&&s>0.2) vio++; if((h<=12||h>=350)&&s>0.5&&mx>0.6) red++; } }
       if(brass<60) bad.push('no brass pipes above the drum ('+brass+' pixels)');
       if(vio>0) bad.push(vio+' lilac or violet pixels in the live mouth');
       if(red<20) bad.push('the live mouth does not charge red ('+red+' pixels)');
     }catch(er){ bad.push('threw: '+(er&&er.message||er)); }
     finally{ wc=w0; try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
