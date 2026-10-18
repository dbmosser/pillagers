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

if ($s.Contains("  {v:'31.50',what:")) { throw "check 31.50 is in the fixture already" }

SubRx @'
  {v:'31.49',what:
'@ @'
  {v:'31.50',what:'cw-trcol2, the follow-up on his one column order (2026-10-18): the corner column is 300 px wide at 1080p (his menu survey pick, q16 and q20 A; 600 at 4k) and a world name label (a named cache, a nameplate, the strongbox) is not drawn while it would overlap the column (the rows, the gap between two rows, the minimap) or the score and clock plate at the top centre, in career, in the demo and in the two player demo, and still is drawn beside them',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof HUDBOX==='undefined'||typeof MMAP==='undefined'||typeof TX!=='function'||typeof ZOOM!=='function'||typeof FS!=='function') return 'SKIP: no HUD boxes here';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, oBp=proto.beginPath, oMv=proto.moveTo, oLn=proto.lineTo, oFl=proto.fill, oRr=proto.roundRect, oCs=canSee;
     var sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, p0=null, keepHud, hadHud, g=null, sub=null, cal=null, oSolo, rr1=null, rr2=null;
     function grab(){
       var r={t:[],p:[],rr:[]}, bb=null, D=(ctx.getTransform().a)||1;
       function pt(c,x,y){ var m=c.getTransform(), X=(m.a*x+m.c*y+m.e)/D, Y=(m.b*x+m.d*y+m.f)/D; if(!bb) bb={x0:X,y0:Y,x1:X,y1:Y}; else { if(X<bb.x0) bb.x0=X; if(X>bb.x1) bb.x1=X; if(Y<bb.y0) bb.y0=Y; if(Y>bb.y1) bb.y1=Y; } }
       proto.fillText=function(t,x,y){ if(this===ctx||this===wc){ var m=this.getTransform(), fm=/([\d.]+)px/.exec(this.font||''), Dd=(this===ctx)?D:(DPR||1); r.t.push({s:String(t),d:TX(String(t)),x:(m.a*x+m.c*y+m.e)/Dd,y:(m.b*x+m.d*y+m.f)/Dd,al:this.textAlign,px:fm?(+fm[1])*m.a/Dd:0}); } return oFt.apply(this,arguments); };
       proto.beginPath=function(){ if(this===ctx) bb=null; return oBp.apply(this,arguments); };
       proto.moveTo=function(x,y){ if(this===ctx) pt(this,x,y); return oMv.apply(this,arguments); };
       proto.lineTo=function(x,y){ if(this===ctx) pt(this,x,y); return oLn.apply(this,arguments); };
       proto.fill=function(){ if(this===ctx&&bb) r.p.push({x0:bb.x0,y0:bb.y0,x1:bb.x1,y1:bb.y1}); return oFl.apply(this,arguments); };
       if(oRr) proto.roundRect=function(x,y,w,h){ if(this===ctx){ var m=this.getTransform(); r.rr.push({x0:(m.a*x+m.e)/D,y0:(m.d*y+m.f)/D,x1:(m.a*(x+w)+m.e)/D,y1:(m.d*(y+h)+m.f)/D}); } return oRr.apply(this,arguments); };
       try{ __frame(0.016); } finally { proto.fillText=oFt; proto.beginPath=oBp; proto.moveTo=oMv; proto.lineTo=oLn; proto.fill=oFl; if(oRr) proto.roundRect=oRr; }
       return r;
     }
     // what is being placed: {o: the thing moved, txt: the string it draws, want: the string as drawn, left: 1 if drawn left aligned, font: the font it is drawn in, back: puts it where it was}
     function subW(){ var w; ctx.save(); ctx.font=sub.font(); w=ctx.measureText(sub.txt).width*ZOOM(); ctx.restore(); return w; }
     function shown(){ var r=grab(), a, n=0, l=null; for(a=0;a<r.t.length;a++) if(r.t[a].d===sub.want){ n++; l=r.t[a]; } if(l&&sub.left) l.x+=subW()/2; return {n:n,t:l,r:r}; }
     function subCache(gg){   // a named cache if the map has one, else the first closed box given a name, so the arms run on every map
       var k, c2, b=null, o0;
       for(k=0;k<gg.containers.length;k++){ c2=gg.containers[k]; if(c2.cache&&c2.tag&&!c2.strong&&!c2.opened){ b=c2; break; } }
       if(!b) for(k=0;k<gg.containers.length;k++){ c2=gg.containers[k]; if(!c2.strong&&!c2.opened){ b=c2; break; } }
       if(!b) return null;
       o0={x:b.x,y:b.y,cache:b.cache,tag:b.tag};
       if(!(b.cache&&b.tag)){ b.cache=true; b.tag='PROBE CACHE'; }
       return {o:b,txt:String(b.tag),want:TX(String(b.tag)),left:0,font:function(){ return FS(TYPE.head); },back:function(){ b.x=o0.x; b.y=o0.y; b.cache=o0.cache; b.tag=o0.tag; }};
     }
     function subStrong(gg){
       var k, c2, b=null, o0;
       for(k=0;k<gg.containers.length;k++){ c2=gg.containers[k]; if(c2.strong&&!c2.opened){ b=c2; break; } }
       if(!b) return null;
       o0={x:b.x,y:b.y};
       return {o:b,txt:'MERIDIAN STRONGBOX',want:TX('MERIDIAN STRONGBOX'),left:0,font:function(){ return FS(TYPE.label); },back:function(){ b.x=o0.x; b.y=o0.y; }};
     }
     function subEnt(gg){   // a named machine: its nameplate is the label (every machine is seen while canSee says so)
       var k, e=null, o0;
       for(k=0;k<gg.ents.length;k++){ if(gg.ents[k].name&&gg.ents[k].kind==='sentry'){ e=gg.ents[k]; break; } }
       if(!e) return null;
       o0={x:e.x,y:e.y,state:e.state};
       canSee=function(){ return true; };
       return {o:e,txt:String(e.name),want:TX(String(e.name)),left:1,font:function(){ return FS(TYPE.micro); },back:function(){ e.x=o0.x; e.y=o0.y; e.state=o0.state; canSee=oCs; }};
     }
     function use(s){ if(sub) sub.back(); sub=s; cal=null; }
     function put(cx,cy){ var Z=ZOOM(); sub.o.x=VX+(cx-cal.dx)/Z; sub.o.y=VY+(cy-cal.dy)/Z; if(sub.left) sub.o.state='idle'; }
     function calib(){   // where the label lands on the screen for a thing at a known place, read from what is really drawn
       var Z, s, k;
       for(k=0;k<3;k++) __frame(0.2);
       Z=ZOOM(); sub.o.x=VX+W*0.4/Z; sub.o.y=VY+H*0.62/Z; if(sub.left) sub.o.state='idle';
       s=shown(); if(!s.n) return null;
       cal={dx:s.t.x-(sub.o.x-VX)*Z, dy:s.t.y-(sub.o.y-VY)*Z, px:s.t.px};
       return s;
     }
     function arm(tag,where,cx,cy,expect){
       var s; put(cx,cy); s=shown();
       if(expect&&!s.n) bad.push(tag+': the '+sub.nm+' was not drawn '+where+' (x '+cx.toFixed(0)+', y '+cy.toFixed(0)+'), where it clears the HUD');
       else if(!expect&&s.n) bad.push(tag+': the '+sub.nm+' is drawn '+where+' (x '+cx.toFixed(0)+', y '+cy.toFixed(0)+'), over the HUD');
     }
     function runArms(tag,wantW,rows,quick){
       var s=calib(), r, pl=[], a, p, mm, L, w, tw, py, cy, gy, rr=null, ys;
       if(!s){ bad.push(tag+': the '+sub.nm+' is not drawn with nothing near it, so the label arms prove nothing'); return null; }
       r=s.r; mm=MMAP.box;
       if(!mm){ bad.push(tag+': no minimap was drawn'); return null; }
       L=mm.x; w=mm.w;
       if(!quick){
         if(Math.abs(w-wantW)>1.5) bad.push(tag+': the column is '+w.toFixed(1)+' px wide, not '+wantW+' (300 at 1080p, his menu survey pick)');
         if(rows&&HUDBOX.cond&&Math.abs(HUDBOX.cond.w-wantW)>1.5) bad.push(tag+': the run info panel is '+HUDBOX.cond.w.toFixed(1)+' px wide, not '+wantW);
       }
       for(a=0;a<r.p.length;a++){ p=r.p[a]; if(p.x0>=W*0.55&&p.x1<=W+1&&(p.x1-p.x0)>=W*0.06&&p.y0>=0&&p.y1<=mm.y+1) pl.push(p); }
       pl.sort(function(u,v){ return u.y0-v.y0; });
       if(!quick) for(a=0;a<pl.length;a++) if(Math.abs((pl[a].x1-pl[a].x0)-wantW)>1.5){ bad.push(tag+': row '+(a+1)+' is '+(pl[a].x1-pl[a].x0).toFixed(1)+' px wide, not '+wantW); break; }
       tw=subW(); py=cal.px;
       cy=mm.y+mm.h/2+py*0.35;
       arm(tag,'in the middle of the minimap',L+w/2,cy,false);
       arm(tag,'with its right end 24 px under the left edge of the column',L-tw/2+24,cy,false);
       arm(tag,'with its right end 14 px left of the column',L-tw/2-14,cy,true);
       if(rows){
         if(pl.length>=4&&pl[3].y0-pl[2].y1>2){ gy=(pl[2].y1+pl[3].y0)/2; arm(tag,'in the gap between the stash and backpack rows',L+w/2,gy+py*0.35,false); }
         else bad.push(tag+': found no gap between the stash and backpack rows to put a label in ('+pl.length+' row plates)');
       }
       for(a=0;a<r.rr.length;a++) if(r.rr[a].x0<W/2&&r.rr[a].x1>W/2&&r.rr[a].y0<=1&&r.rr[a].y1>4&&(r.rr[a].x1-r.rr[a].x0)>W*0.04){ rr=r.rr[a]; break; }
       if(!rr){ bad.push(tag+': no score and clock plate was drawn at the top centre'); return null; }
       ys=rr.y1/2+py*0.35;
       arm(tag,'in the middle of the score and clock plate',(rr.x0+rr.x1)/2,ys,false);
       arm(tag,'with its middle on the right end of the score and clock plate',rr.x1,ys,false);
       if(rr.x1+14+tw<L-8) arm(tag,'14 px right of the score and clock plate',rr.x1+14+tw/2,ys,true);
       arm(tag,'14 px under the score and clock plate',W/2,rr.y1+14+py,true);
       rr.tw=tw; rr.ys=ys;
       return rr;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       p0=__P(); hadHud=('hud' in p0); keepHud=p0.hud;
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof careerPostBuild!=='function') return 'SKIP: this build has no career raid';
       try{ careerPostBuild(g); }catch(_cp){}   // the fixture's raid is not a career raid until this runs (it draws the score and clock plate)
       p0=__P(); p0.hud={};
       use(subCache(g)); if(!sub) return 'SKIP: no closed box on this map';
       sub.nm='cache name';
       runArms('career 1080p',300,true,false);
       use(subEnt(g));
       if(sub){ sub.nm='nameplate'; runArms('career 1080p',300,true,true); }
       else bad.push('control: no named sentry to put a nameplate on');
       use(subStrong(g));
       if(sub){ sub.nm='strongbox name'; runArms('career 1080p',300,true,true); }
       use(null);
       __forceSize(3840,2160);
       use(subCache(g)); if(sub){ sub.nm='cache name'; runArms('career 4k',600,true,false); }
       use(null);
       __endRaid('abandon'); __topClear();
       __forceSize(1920,1080);
       if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('control: arcadeDeploy built no arcade raid');
         else {
           g=__state(); keys={}; ARCADE.holdT=0; oSolo=ARCADE.solo;
           if(!g||g.over||!g.player) bad.push('control: no live demo raid');
           else {
             use(subCache(g));
             if(!sub) bad.push('control: no closed box in the demo raid');
             else {
               sub.nm='cache name';
               ARCADE.solo=1; rr1=runArms('the demo 1080p',300,false,false);
               ARCADE.solo=0; rr2=runArms('the demo for 2 players 1080p',300,false,false);
               if(rr1&&rr2){
                 if(rr2.x1<rr1.x1+20) bad.push('control: the 2 player score plate ends at x '+rr2.x1.toFixed(0)+' and the 1 player one at '+rr1.x1.toFixed(0)+', so the 2 player arm proves nothing');
                 else arm('the demo for 2 players 1080p','where the 1 player plate ended plus 14 px, which the wider 2 player plate covers',rr1.x1+14+rr2.tw/2,rr2.ys,false);
               }
             }
             use(null);
           }
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       proto.fillText=oFt; proto.beginPath=oBp; proto.moveTo=oMv; proto.lineTo=oLn; proto.fill=oFl; if(oRr) proto.roundRect=oRr;
       try{ use(null); }catch(_u){}
       canSee=oCs;
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE){ if(oSolo!==undefined) ARCADE.solo=oSolo; ARCADE.team=null; ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_a){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       try{ var pf=__P(); if(hadHud) pf.hud=keepHud; else delete pf.hud; saveProfile(); }catch(_r){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
