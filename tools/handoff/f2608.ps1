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

if ($s.Contains("  {v:'26.08',what:")) { throw "check 26.08 is in the fixture already" }

SubRx @'
  {v:'26.07',what:
'@ @'
  {v:'26.08',what:'his order (smoke 1.3 times bigger): a thrown smoke cloud is 1.3 times the old radius, blocks a sight line 1.25 times as far from its middle as the old one reached, is drawn 1.3 times as wide as a cloud of the old radius, the copy the host takes of a party smoke is the same size, and no place sizes a cloud from the raw dial',
   run:function(){
     if(!(window.__gfxStage&&window.__frame&&window.__state&&window.__endRaid&&window.__resetCfg)||typeof activateThrow!=='function'||typeof smokeSegs!=='function'||typeof refreshVseg!=='function'||typeof canSee!=='function'||typeof netOnMsg!=='function'||typeof wc==='undefined') return 'SKIP: this fixture cannot stage a smoke here';
     var OLD=165, REACH=OLD*0.92, bad=[], g=null, sm, base, cx, cy, d, e1, e0, keep={}, k, oSend=netSend, pa={state:'in',seat:1}, pb={state:'in',seat:2}, r, i, ss, t, at, n=0, needle='r:(CFG.sm'+'okeR===undef';
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function eyes(dd){ return canSee(cx-300,cy+dd,0,cx+300,cy+dd,smokeSegs(),2000,6.4,2000); }
     function extent(s){
       var out=0, got=0, orig=wc.arc;
       g.smokes.length=0; g.smokes.push(s);
       wc.arc=function(ax,ay,rr){
         var dx, dy, e;
         if(Math.abs(rr-s.r*0.5)<0.01&&Math.abs(ax-s.x)<=s.r*0.43&&Math.abs(ay-(s.y-12))<=8){ dx=ax-s.x; dy=ay-s.y; e=Math.sqrt(dx*dx+dy*dy)+rr; if(e>out) out=e; got++; }
         return orig.apply(wc,arguments);
       };
       try{ __frame(0.016); } finally { delete wc.arc; }
       return got>=6?out:0;
     }
     try{
       g=__gfxStage({frames:2});
       if(!g) return 'SKIP: __gfxStage built no raid';
       if(g.sim) return 'SKIP: the staged raid is a sim raid';
       __resetCfg();
       cx=g.player.x; cy=g.player.y; g.smokes.length=0;
       activateThrow({kind:'smoke',tx:cx,ty:cy,sx:cx,sy:cy,cook:0});
       sm=g.smokes[g.smokes.length-1];
       if(!sm) bad.push('a thrown smoke made no cloud');
       else {
         refreshVseg();
         if(Math.abs(sm.r-OLD*1.3)>0.5) bad.push('the cloud is '+sm.r+' wide, not 1.3 times '+OLD);
         if(sm.life!==12) bad.push('the cloud lasts '+sm.life+' seconds, not 12');
         if(g.vseg.length-g.map.segs.length!==8) bad.push('the cloud adds '+(g.vseg.length-g.map.segs.length)+' sight lines, not 8');
         if(eyes(2)) bad.push('a sight line through the middle of the cloud is clear');
         d=Math.round(REACH*1.25);
         if(eyes(d)) bad.push('a sight line '+d+' units from its middle, 1.25 times the old reach of '+Math.round(REACH)+', is clear');
         d=Math.round(REACH*1.45);
         if(!eyes(d)) bad.push('a sight line '+d+' units from its middle, 1.45 times the old reach, is blocked: the cloud is bigger than 1.3 times');
         base={x:cx,y:cy,r:OLD,t:0,life:12};
         e1=extent(sm); e0=extent(base);
         if(!(e0>0&&e1>0)) bad.push('the air pass drew '+(e0>0?'':'no old-size ')+(e1>0?'':'no thrown ')+'puffs');
         else if(e1/e0<1.25||e1/e0>1.35) bad.push('the drawn cloud is '+(e1/e0).toFixed(3)+' times as wide as an old-size cloud, not about 1.3');
         netSend=function(q,m){ return true; };
         NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[pa,pb]; NET.up=[]; NET.fxQ=[];
         g.smokes.length=0;
         r=netOnMsg(pa,JSON.stringify({t:'thr',k:'smoke',x:Math.round(cx),y:Math.round(cy)}));
         if(g.smokes.length!==1) bad.push('the host did not put the smoke a party member threw in its world ('+r+')');
         else if(Math.abs(g.smokes[0].r-sm.r)>0.01) bad.push('a party smoke is '+g.smokes[0].r+' wide, the one thrown here '+sm.r);
       }
       ss=[].slice.call(document.scripts);
       for(i=0;i<ss.length;i++){ t=ss[i].textContent||''; at=t.indexOf(needle); while(at>=0){ n++; at=t.indexOf(needle,at+1); } }
       if(n>0) bad.push(n+' places still size a cloud from the raw dial and not from smokeRad');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ delete wc.arc; }catch(_a){}
       keys={};
       try{ var g2=__state(); if(g2&&!g2.over&&!g2.sim){ g2.smokes.length=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
