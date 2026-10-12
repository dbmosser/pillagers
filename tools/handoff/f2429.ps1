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

if ($s.Contains("  {v:'24.29',what:")) { throw "check 24.29 is in the fixture already" }

SubRx @'
  {v:'24.28',what:
'@ @'
  {v:'24.29',what:'his answer 39: darker moodier nights, the streets away from him darker while the ground at his feet reads as before',
   run:function(){
     if(!(window.__deploy&&window.__forceSize&&window.__vpAlive)) return 'SKIP: this fixture cannot draw a raid frame at a set size';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to compare';
     var bad=[], g, p, c0=P.cond, ns0=NIGHT_SHEET, nm0=(typeof NIGHT_MOOD==='number')?NIGHT_MOOD:null, cv=document.getElementById('cv');
     if(!cv) return 'SKIP: no world canvas';
     function meas(){
       __frame(0);
       var k=cv.width/Math.max(1,W), s=w2s(p.x,0,p.y), cx=s.x*k, cy=s.y*k, d=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;
       var nr=0, nn=0, fr=0, fn=0, x, y, dd, i, R1=360*k, R2=520*k, RN=26*k;
       for(y=0;y<cv.height;y+=6) for(x=0;x<cv.width;x+=6){
         dd=Math.sqrt((x-cx)*(x-cx)+(y-cy)*(y-cy)); if(dd>RN&&(dd<R1||dd>R2)) continue;
         i=(y*cv.width+x)*4; var l=0.2126*d[i]+0.7152*d[i+1]+0.0722*d[i+2];
         if(dd<=RN){ nr+=l; nn++; } else { fr+=l; fn++; }
       }
       return {near:nn?nr/nn:0, far:fn?fr/fn:0, nn:nn, fn:fn};
     }
     try{
       __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); if(window.__zoom&&__zoom.set) __zoom.set(1,true);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; P.cond='night';
       if(isDay()) return 'SKIP: the raid would not go dark';
       for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
       var A=meas(), A2=meas();
       if(!(A.fn>50&&A.nn>4)) return 'SKIP: the player is not on the frame here';
       if(Math.abs(A.far-A2.far)>Math.max(0.5,A.far*0.02)) return 'SKIP: two identical redraws differ ('+A.far.toFixed(2)+', '+A2.far.toFixed(2)+')';
       NIGHT_SHEET=0.30; if(nm0!==null) NIGHT_MOOD=0;
       var B=meas();
       NIGHT_SHEET=ns0; if(nm0!==null) NIGHT_MOOD=nm0;
       if(!(B.far>2)) return 'SKIP: the night frame is black away from him, nothing to compare ('+B.far.toFixed(2)+')';
       var rf=A.far/B.far, rn=B.near>0?A.near/B.near:1;
       if(!(rf<0.93)) bad.push('the night away from him is not darker than the old night ('+(rf*100).toFixed(1)+' percent of it)');
       if(!(rn>0.9&&rn<1.15)) bad.push('the ground at his feet moved to '+(rn*100).toFixed(1)+' percent of the old night');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NIGHT_SHEET=ns0; if(nm0!==null) NIGHT_MOOD=nm0; P.cond=c0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
