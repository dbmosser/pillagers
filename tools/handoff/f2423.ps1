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

if ($s.Contains("  {v:'24.23',what:")) { throw "check 24.23 is in the fixture already" }

SubRx @'
  {v:'24.22',what:
'@ @'
  {v:'24.23',what:'sprite program spr10 (THE OVERSEER): the boss is no longer a Warden drawn bigger: a crown of sensor masts rises above its head line, a second cannon sits above the first, and it wears brass',
   run:function(){
     if(typeof drawWardenAt!=='function') return 'SKIP: no warden painter';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var w0=wc, cv=document.createElement('canvas'), x2, bad=[], W=360, H=330, OX=180, OY=300, Z=3;
     cv.width=W; cv.height=H; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function shot(e){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,W,H); x2.setTransform(Z,0,0,Z,OX,OY); wc=x2;
       try{ drawWardenAt(e); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); }
       return x2.getImageData(0,0,W,H).data; }
     function stats(d){ var crown=0,gun2=0,brass=0,op=0,q,i,px,py,wx,wy,r,g,b,mx,mn,h;
       for(q=0;q<d.length;q+=4){ if(d[q+3]<200) continue; op++; i=q/4; px=i%W; py=(i-px)/W; wx=(px-OX)/Z; wy=(py-OY)/Z;
         if(wy<-78) crown++;
         if(wx>30&&wy>-64&&wy<-55) gun2++;
         r=d[q]/255; g=d[q+1]/255; b=d[q+2]/255; mx=Math.max(r,g,b); mn=Math.min(r,g,b);
         if(mx>0.45&&mx-mn>0.35*mx&&mx===r){ h=60*((g-b)/(mx-mn)); if(h>=36&&h<=54) brass++; } }
       return {crown:crown,gun2:gun2,brass:brass,op:op}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       var s=stats(shot({kind:'warden',boss:1,name:BOSS_NAME,x:0,y:0,r:44,hp:4000,maxhp:4000,face:0,state:'patrol',step:0,hitT:0,muzzle:0,seenYou:false,overheat:0,windup:null}));
       if(s.op<4000) bad.push('the Overseer drew only '+s.op+' opaque pixels');
       if(s.crown<40) bad.push('no crown above its head line ('+s.crown+' pixels above it)');
       if(s.gun2<40) bad.push('no second cannon above the first ('+s.gun2+' pixels there)');
       if(s.brass<s.op*0.02) bad.push('no brass on it ('+s.brass+' of '+s.op+' pixels)');
     }catch(er){ bad.push('threw: '+(er&&er.message||er)); }
     finally{ wc=w0; try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
