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

if ($s.Contains("  {v:'25.42',what:")) { throw "check 25.42 is in the fixture already" }

SubRx @'
  {v:'25.41',what:
'@ @'
  {v:'25.42',what:'a crawler hanging on you is never shoved through a wall: walk it into a wall and it slides round to your side and keeps biting',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim) return 'SKIP: no raid here';
     var bad=[], g, p, all, e, mh, i, j, c, cands=[], tried=0, fails=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); e=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0; })[0];
       if(!e) return 'SKIP: no crawler on this map';
       g.ents=[e]; e.elite=false; mh=p.maxhp; p.maxhp=100000; p.hp=100000; p.armor=0;
       for(var k in keys) keys[k]=false;
       G.crouchTog=false; p.ads=false;
       var W=G.map.walls, pr=(p.r||11);
       var hitBox=function(x0,y0,x1,y1,skip){ for(var q=0;q<W.length;q++){ var w=W[q]; if(w===skip) continue; if(w.x<x1&&w.x+w.w>x0&&w.y<y1&&w.y+w.h>y0) return true; } return false; };
       for(i=0;i<W.length&&cands.length<8;i++){
         var w=W[i], hz=w.w>=w.h, th=hz?w.h:w.w, ln=hz?w.w:w.h;
         if(th<10||th>24||ln<200) continue;
         for(j=-1;j<=1;j+=2){
           var n=hz?[0,j]:[j,0], cx=w.x+w.w/2, cy=w.y+w.h/2;
           var fx=hz?cx:(j<0?w.x:w.x+w.w), fy=hz?(j<0?w.y:w.y+w.h):cy;
           var sx=fx+n[0]*60, sy=fy+n[1]*60;
           if(sx<60||sy<60||sx>WORLD_W-60||sy>WORLD_H-60||inWater(sx,sy)||inWater(fx+n[0]*14,fy+n[1]*14)) continue;
           var bx0=hz?cx-80:Math.min(fx-n[0]*(th+40),sx+n[0]*40), bx1=hz?cx+80:Math.max(fx-n[0]*(th+40),sx+n[0]*40);
           var by0=hz?Math.min(fy-n[1]*(th+40),sy+n[1]*40):cy-80, by1=hz?Math.max(fy-n[1]*(th+40),sy+n[1]*40):cy+80;
           if(hitBox(bx0,by0,bx1,by1,w)) continue;
           if(!losClear(sx,sy,fx+n[0]*12,fy+n[1]*12,G.map.segs)) continue;
           var key=n[0]>0?'KeyA':(n[0]<0?'KeyD':(n[1]>0?'KeyW':'KeyS'));
           cands.push({w:w,n:n,fx:fx,fy:fy,sx:sx,sy:sy,th:th,key:key});
           if(cands.length>=8) break;
         }
       }
       if(cands.length<2) return 'SKIP: no clear building wall to walk into ('+cands.length+')';
       for(c=0;c<cands.length;c++){
         var C=cands[c];
         for(var k1 in keys) keys[k1]=false;
         p.x=C.sx; p.y=C.sy; p.hp=100000; p.iv=0; p.downed=false; p.stam=100; p.vx=0; p.vy=0;
         e.hp=e.maxhp; e.x=C.sx-C.n[0]*(e.r+pr+2); e.y=C.sy-C.n[1]*(e.r+pr+2);
         e.latchS=-1; e.latchBlk=0; e.cd=0; e.state='chase'; e.alert=2.4; e.tx=p.x; e.ty=p.y;
         keys[C.key]=true;
         var fr=0, last=p.hp, bites=[], crossed=0, lost=-1;
         for(i=0;i<132;i++){
           __sim(1/60); fr++;
           if(p.hp<last-0.01) bites.push(fr/60); last=p.hp;
           var sd=(e.x-C.fx)*C.n[0]+(e.y-C.fy)*C.n[1];
           if(sd<-C.th*0.5) crossed++;
           if(lost<0&&e.latchS!==-1) lost=fr/60;
         }
         keys[C.key]=false;
         var pd=(p.x-C.fx)*C.n[0]+(p.y-C.fy)*C.n[1];
         if(pd>pr+6) continue;   // he never reached the wall: not a valid trial
         tried++;
         var gap=0, prev=0;
         for(j=0;j<bites.length;j++){ gap=Math.max(gap,bites[j]-prev); prev=bites[j]; }
         gap=Math.max(gap,132/60-prev);
         var why=[];
         if(crossed) why.push('through the wall for '+crossed+' frames');
         if(lost>=0) why.push('let go at '+lost.toFixed(2)+' s');
         if(gap>0.8) why.push('no bite for '+gap.toFixed(2)+' s ('+bites.length+' bites)');
         if(why.length) fails.push('wall '+Math.round(C.w.x)+','+Math.round(C.w.y)+' ('+Math.round(C.th)+' thick): '+why.join(', ')+', ends '+Math.round(Math.hypot(e.x-p.x,e.y-p.y))+' from him');
       }
       if(tried<2) return 'SKIP: he reached the wall in only '+tried+' trials';
       if(fails.length) bad.push(fails.length+' of '+tried+' walls: '+fails.slice(0,3).join('; '));
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ for(var k2 in keys) keys[k2]=false; try{ if(all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.maxhp=mh||100; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
