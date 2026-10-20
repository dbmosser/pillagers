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

if ($s.Contains("  {v:'32.65',what:")) { throw "check 32.65 is in the fixture already" }

SubRx @'
  {v:'32.64',what:
'@ @'
  {v:'32.65',what:'players in action (his art picks a11 to a16): bouncy walk, white flash then red with a recoil, red outline and stains at low health, kneeling downed body with a red ring, the fall that turns to light, the dotted aim line and the rare gun laser',
   run:function(){
     var g, keepWc, keepT, keepDB, cv, cx, p, base, i, d, d0, d1, t0, t1, n, ang, best, red, white, ok, spy, cnt, ofn, rate, WP;
     if(typeof drawOpB!=='function'||typeof drawAimMark!=='function') return 'the player state drawing (drawOpB, drawAimMark) is not in this build';
     function shot(mode,ph,st,sc){ var keep=wc; cx.setTransform(1,0,0,1,0,0); cx.clearRect(0,0,240,240); wc=cx; cx.setTransform(sc,0,0,sc,120,200); try{ drawOp(0,0,0,ph,'#242832',0,0,mode,0,st); } finally{ wc=keep; } return cx.getImageData(0,0,240,240).data; }
     function stat(dd,f,a){ var k=0, j; for(j=0;j<dd.length;j+=4) if(dd[j+3]>(a||128)&&f(dd[j],dd[j+1],dd[j+2])) k++; return k; }
     function opq(dd){ return stat(dd,function(){ return true; }); }
     function topRow(dd){ var r, c; for(r=0;r<240;r++) for(c=0;c<240;c++) if(dd[(r*240+c)*4+3]>128) return r; return 240; }
     function leftCol(dd){ var r, c; for(c=0;c<240;c++) for(r=0;r<240;r++) if(dd[(r*240+c)*4+3]>128) return c; return 240; }
     function mk(o){ var s={hero:1,own:{wep:null,hp:100},moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0}, q; for(q in o){ if(q==='own'){ var oo=o.own, z; for(z in oo) s.own[z]=oo[z]; } else s[q]=o[q]; } return s; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; keepWc=wc; keepT=g.t; keepDB=g.deathBeat; WP=WEAPONS;
       cv=document.createElement('canvas'); cv.width=240; cv.height=240; cx=cv.getContext('2d',{willReadFrequently:true});
       // a11: the bob at the top of a step is bigger (4x: 2.6 bob plus the squash, was 1.5 and none)
       t0=topRow(shot('none',0,mk({moving:true}),4)); t1=topRow(shot('none',1.5708,mk({moving:true}),4));
       if(t0-t1<14) return 'a11: the walking body rises only '+(t0-t1)+' device px from the footfall to the top of the step (a bouncy walk needs 14 or more)';
       // a12: the whole body goes white for the first 66 ms, then red
       d=shot('none',0,mk({hurt:0.40,hurtAge:0.02}),4); white=stat(d,function(r,gg,b){ return r>=225&&gg>=225&&b>=225; })/Math.max(1,opq(d));
       if(white<0.5) return 'a12: at 20 ms after a hit only '+Math.round(white*100)+' percent of the body is white (the whole body flashes white for 66 ms)';
       d=shot('none',0,mk({hurt:0.30,hurtAge:0.12}),4); red=stat(d,function(r,gg,b){ return r>gg+25&&r>b+25; })/Math.max(1,opq(d));
       if(red<0.6) return 'a12: at 120 ms after a hit only '+Math.round(red*100)+' percent of the body is red (the whole body is tinted red after the white)';
       d0=leftCol(shot('none',0,mk({}),4)); d1=leftCol(shot('none',0,mk({hurt:0.3,hurtAge:0.06,own:{hitDX:1}}),4));
       if(d1-d0<6) return 'a12: the body does not recoil away from the shot (moved '+(d1-d0)+' device px, 2.5 px of recoil is about 9)';
       // a13: stains on the body and a red outline at low health, and neither at full health
       rate=hpFlashRate();
       g.t=(4.71239)/rate;   // sin = -1: the outline at its darkest, only the stains show
       n=stat(shot('none',0,mk({own:{hp:18}}),4),function(r,gg,b){ return r>=100&&r-gg>=60&&gg<=60&&b<=60; })-stat(shot('none',0,mk({own:{hp:100}}),4),function(r,gg,b){ return r>=100&&r-gg>=60&&gg<=60&&b<=60; });
       if(n<4) return 'a13: no dark red stains on a body at 18 health ('+n+' px more than at full health)';
       g.t=(1.5708)/rate;    // sin = +1: the outline at its reddest
       n=stat(shot('none',0,mk({own:{hp:18}}),4),function(r,gg,b){ return r>=170&&gg<=70&&b<=60; })-stat(shot('none',0,mk({own:{hp:100}}),4),function(r,gg,b){ return r>=170&&gg<=70&&b<=60; });
       if(n<30) return 'a13: the body outline does not turn red at 18 health ('+n+' red px more than at full health)';
       // a14: downed means kneeling, a red ring, and the gun on the floor
       d=shot('down',0,mk({own:{downed:true,hp:40,wep:WP.rifle}}),4);
       if(stat(d,function(r,gg,b){ return r>=200&&gg<=110&&b<=100; },40)<60) return 'a14: no red ring round a downed body';
       if(200-topRow(d)<80) return 'a14: a downed body is a flat shape, not a kneeling one (it stands '+(200-topRow(d))+' device px tall, a kneel needs 80 or more)';
       if(opq(d)-opq(shot('down',0,mk({own:{downed:true,hp:40,wep:null}}),4))<40) return 'a14: the gun does not lie on the ground beside a downed body';
       // a15: the fall, then the points of light, then nothing
       g.deathBeat=0.9;
       d=shot('down',0,mk({own:{hp:0}}),4);
       n=0; for(i=0;i<160*240;i++){ var o4=i*4; if(d[o4+3]>20&&d[o4]>=200&&d[o4+1]>=120&&d[o4+1]<=215&&d[o4+2]<=110) n++; }
       if(n<12) return 'a15: no rising points of light above the fallen body ('+n+' px)';
       g.deathBeat=0.4;
       if(opq(shot('down',0,mk({own:{hp:0}}),4))>0) return 'a15: a body is still drawn 1.1 s after the death (nothing stays)';
       // a16: dots always, the red laser only for the two top tiers and the golden gun while the sights are held
       g.deathBeat=keepDB;
       cv.width=400; cv.height=400; cx=cv.getContext('2d',{willReadFrequently:true});
       function aimShot(wep,ads,an){ var keep=wc; cx.setTransform(1,0,0,1,0,0); cx.clearRect(0,0,400,400); wc=cx; cx.setTransform(1,0,0,1,200-p.x,200-p.y); try{ drawAimMark(p,wep,an,360,ads,null); } finally{ wc=keep; } return cx.getImageData(0,0,400,400).data; }
       function best8(wep,ads,f){ var a, b=0, k, dd; for(a=0;a<8;a++){ dd=aimShot(wep,ads,a*0.7854); k=stat(dd,f,20); if(k>b) b=k; } return b; }
       var isRed=function(r,gg,b){ return r>=200&&gg<=110&&b<=100; }, isWhite=function(r,gg,b){ return r>=200&&gg>=200&&b>=200; };
       var gold=Object.assign({},WP.rifle,{q:'gold'});
       if(best8(WP.pistol,false,isWhite)<10) return 'a16: no dotted line from a held pistol toward the crosshair';
       if(best8(WP.pistol,true,isRed)>0) return 'a16: a common gun shows the red laser';
       if(best8(WP.sniper,true,isRed)<12) return 'a16: a top tier gun does not show the red laser with the sights held';
       if(best8(WP.sniper,true,isWhite)>0) return 'a16: the dotted line still shows while the laser does';
       if(best8(WP.sniper,false,isWhite)<10) return 'a16: no dotted line from a top tier gun without the sights';
       if(best8(gold,true,isRed)<12) return 'a16: the golden gun does not show the red laser';
       // and the frame draws it: the real raid frame calls the aim mark for the held gun
       p.wep=WP.rifle; p.hand=false; g.handsT=0; p.downed=false;
       ofn=drawAimMark; cnt=0; drawAimMark=function(){ cnt++; return ofn.apply(this,arguments); };
       try{ __frame(); __frame(); } finally{ drawAimMark=ofn; }
       if(cnt<1) return 'a16: the raid frame never draws the aim mark for a held gun';
       return null;
     } finally {
       try{ wc=keepWc; g.t=keepT; g.deathBeat=keepDB; }catch(_k){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
