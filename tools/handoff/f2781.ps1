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

if ($s.Contains("  {v:'27.81',what:")) { throw "check 27.81 is in the fixture already" }

SubRx @'
  {v:'27.80',what:
'@ @'
  {v:'27.81',what:'feel2c, his words: the reload bar needs a clear red line for the active reload. The bar over the head draws the sweet spot (42 to 60 percent) as a red zone with a red line at each end, it lights up while the playhead is inside it and dims once missed, and the ring on the cursor draws its sweet spot arc in red too',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     var bad=[], g, p, all, oWep, oAmmo, oRes, oMx, oMy, w, S, sc, i, proto, oFill, oArc, rects, arcs, st;
     function rgb(s){
       var m=String(s).match(/^#([0-9a-f]{6})$/i), n;
       if(m){ n=parseInt(m[1],16); return {r:(n>>16)&255,g:(n>>8)&255,b:n&255,a:1}; }
       m=String(s).match(/^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)$/);
       return m?{r:+m[1],g:+m[2],b:+m[3],a:(m[4]===undefined)?1:+m[4]}:null;
     }
     function red(s){ var c=rgb(s); return !!c&&c.a>=0.3&&c.r>=200&&c.r-c.g>=85&&c.r-c.b>=85; }
     function snap(f){
       p.wep.reload=2000; p.rlTot=2000; p.reloading=2000*(1-f); p.ammo=3; p.reserve=60; p.drawT=0; p.jam=0; p.hand=false; mouse.x=W/2; mouse.y=H/2; rects=[]; arcs=[]; render2D(0);
       proto=CanvasRenderingContext2D.prototype; oFill=proto.fillRect; oArc=proto.arc;
       proto.fillRect=function(x,y,ww,hh){ rects.push({x:x,y:y,w:ww,h:hh,s:String(this.fillStyle)}); return oFill.apply(this,arguments); };
       proto.arc=function(){ var a=[].slice.call(arguments); a.push(String(this.strokeStyle)); arcs.push(a); return oArc.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.fillRect=oFill; proto.arc=oArc; }
     }
     function zoneOf(){
       var k, plate=null, zone=null, r, d;
       sc=w2s(p.x,34,p.y);
       for(k=0;k<rects.length;k++){ r=rects[k];
         if(Math.abs(r.x+r.w/2-sc.x)<12&&Math.abs(r.y+r.h/2-sc.y)<80&&r.w>40&&r.w<400&&r.h>6&&r.h<40&&rgb(r.s)&&rgb(r.s).r<30&&(!plate||r.w>plate.w)) plate=r;
       }
       if(!plate) return null;
       for(k=0;k<rects.length;k++){ r=rects[k];
         if(r.x>plate.x&&r.x<plate.x+plate.w&&Math.abs(r.y+r.h/2-(plate.y+plate.h/2))<plate.h&&r.w>plate.w*0.1&&r.w<plate.w*0.3&&r.h>=plate.h*0.5&&rgb(r.s)&&rgb(r.s).r>=140&&rgb(r.s).r-rgb(r.s).g>=50&&rgb(r.s).r-rgb(r.s).b>=50) zone=r;
       }
       return zone?{plate:plate,zone:zone}:{plate:plate,zone:null};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve; oMx=mouse.x; oMy=mouse.y; p.iv=99;
       w=cloneObj(WEAPONS.rifle); p.wep=w;
       // ONE: before the zone: a red zone on the bar, at the 42 to 60 percent stretch of the track
       snap(0.2); st=zoneOf();
       if(!st) bad.push('ONE: no reload bar was drawn over the head');
       else if(!st.zone) bad.push('ONE: the reload bar has no red zone');
       else {
         var fx=(st.zone.x-st.plate.x)/st.plate.w, fw=st.zone.w/st.plate.w;
         if(!(fx>0.38&&fx<0.47)) bad.push('ONE: the red zone starts '+fx.toFixed(2)+' of the way along the bar, not at 0.42');
         if(!(fw>0.13&&fw<0.21)) bad.push('ONE: the red zone is '+fw.toFixed(2)+' of the bar wide, not about 0.18');
         if(!(st.zone.h>=st.plate.h*0.6)) bad.push('ONE: the red zone is too thin ('+st.zone.h.toFixed(1)+' px)');
         var lines=0, k, r2; for(k=0;k<rects.length;k++){ r2=rects[k]; if(red(r2.s)&&r2.w<=4&&r2.h>=st.zone.h&&r2.x>=st.zone.x-3&&r2.x<=st.zone.x+st.zone.w+3) lines++; }
         if(lines<2) bad.push('ONE: only '+lines+' red line(s) beside the zone, not 2');
         // TWO: inside the zone it lights up, after it it dims
         var cBefore=rgb(st.zone.s);
         snap(0.5); var s2=zoneOf(); var cIn=(s2&&s2.zone)?rgb(s2.zone.s):null;
         snap(0.85); var s3=zoneOf(); var cMiss=(s3&&s3.zone)?rgb(s3.zone.s):null;
         if(!cIn) bad.push('TWO: no zone drawn at 0.5 of the reload');
         else if(!(cIn.g>cBefore.g+30)) bad.push('TWO: the zone does not light up inside the window ('+cBefore.g+' to '+cIn.g+')');
         if(!cMiss) bad.push('TWO: no zone drawn after the window');
         else if(!(cMiss.a<0.8||cMiss.r<200)) bad.push('TWO: the zone does not dim once missed');
       }
       // THREE: the ring on the cursor draws its sweet spot in red
       snap(0.2);
       var a0=-1.5708+6.2832*AR_A, a1=-1.5708+6.2832*AR_B, hit=0, ticks=0, k2;
       for(k2=0;k2<arcs.length;k2++) if(arcs[k2].length>=5&&Math.abs(arcs[k2][3]-a0)<0.002&&Math.abs(arcs[k2][4]-a1)<0.002){ if(red(arcs[k2][arcs[k2].length-1])) hit++; }
       if(!hit) bad.push('THREE: the sweet spot arc on the ring is not red');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(proto){ if(oFill) proto.fillRect=oFill; if(oArc) proto.arc=oArc; } if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.reloading=0; p.rlTot=0; } if(g&&all) g.ents=all.slice(); if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
