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

if ($s.Contains("  {v:'31.03',what:")) { throw "check 31.03 is in the fixture already" }

SubRx @'
  {v:'31.02',what:
'@ @'
  {v:'31.03',what:'cw-trcol, his order (2026-10-18) everything in the right hand upper corner in a vertical 1 by 1 list, all the same size: in a raid the credits, xp, stash, bag (career) and notes logged rows, the minimap and the run info panel are ONE column from the top right corner, each its own plate on one right edge and one width, the rows one height and one type size, no two on a row, none overlapping, at 1080p, at 4K and in the demo',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof HUDBOX==='undefined'||typeof MMAP==='undefined'||typeof TX!=='function'||typeof syncTopRight!=='function') return 'SKIP: no HUD boxes here';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, oBp=proto.beginPath, oMv=proto.moveTo, oLn=proto.lineTo, oFl=proto.fill;
     var sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, p0=null, keepC, keepX, keepHud, hadHud, g=null, o, oSolo, el, now, cs0, i;
     function grab(){
       var r={t:[],p:[]}, bb=null, D=(ctx.getTransform().a)||1;
       function pt(c,x,y){ var m=c.getTransform(), X=(m.a*x+m.c*y+m.e)/D, Y=(m.b*x+m.d*y+m.f)/D; if(!bb) bb={x0:X,y0:Y,x1:X,y1:Y}; else { if(X<bb.x0) bb.x0=X; if(X>bb.x1) bb.x1=X; if(Y<bb.y0) bb.y0=Y; if(Y>bb.y1) bb.y1=Y; } }
       proto.fillText=function(t,x,y){ if(this===ctx){ var m=this.getTransform(), fm=/([\d.]+)px/.exec(this.font||''); r.t.push({s:String(t),d:TX(String(t)),x:(m.a*x+m.c*y+m.e)/D,y:(m.b*x+m.d*y+m.f)/D,al:this.textAlign,px:fm?(+fm[1])*m.a/D:0}); } return oFt.apply(this,arguments); };
       proto.beginPath=function(){ if(this===ctx) bb=null; return oBp.apply(this,arguments); };
       proto.moveTo=function(x,y){ if(this===ctx) pt(this,x,y); return oMv.apply(this,arguments); };
       proto.lineTo=function(x,y){ if(this===ctx) pt(this,x,y); return oLn.apply(this,arguments); };
       proto.fill=function(){ if(this===ctx&&bb) r.p.push({x0:bb.x0,y0:bb.y0,x1:bb.x1,y1:bb.y1}); return oFl.apply(this,arguments); };
       try{ __frame(0.016); } finally { proto.fillText=oFt; proto.beginPath=oBp; proto.moveTo=oMv; proto.lineTo=oLn; proto.fill=oFl; }
       return r;
     }
     function judge(tag,r,wallet,notes){
       var C=HUDBOX.cond, n=(wallet?4:0)+(notes?1:0), labs=[], pl=[], px=[], vx=[], gaps=[], k, p, q, lab, val, ref=null, L, Rr, a, low=[];
       if(wallet){ labs.push('credits'); labs.push('xp'); labs.push('stash'); labs.push('bag'); }
       if(notes) labs.push('notes logged');
       if(!C){ bad.push(tag+': no run info panel was drawn to line the corner up with'); return; }
       L=C.x; Rr=C.x+C.w;
       for(a=0;a<r.p.length;a++){ p=r.p[a]; if(p.x0>=W*0.55&&p.x1<=W+1&&(p.x1-p.x0)>=W*0.06&&p.y1<=C.y+C.h+2&&p.y0>=0) pl.push(p); }
       pl.sort(function(u,v){ return u.y0-v.y0; });
       if(pl.length!==n+2) bad.push(tag+': the corner holds '+pl.length+' plates, one under another, and not '+(n+2)+' ('+n+' rows, the minimap and the run info panel)');
       for(a=0;a<pl.length;a++){
         p=pl[a];
         if(Math.abs(p.x0-L)>1.5||Math.abs(p.x1-Rr)>1.5) bad.push(tag+': plate '+(a+1)+' of '+pl.length+' spans x '+p.x0.toFixed(0)+' to '+p.x1.toFixed(0)+' ('+(p.x1-p.x0).toFixed(0)+' wide), not the column '+L.toFixed(0)+' to '+Rr.toFixed(0)+' ('+(Rr-L).toFixed(0)+' wide)');
         if(a){ gaps.push(p.y0-pl[a-1].y1); if(p.y0<pl[a-1].y1-0.5) bad.push(tag+': plate '+(a+1)+' starts at y '+p.y0.toFixed(0)+', on top of the one above it, which ends at '+pl[a-1].y1.toFixed(0)); }
       }
       for(a=1;a<gaps.length;a++) if(Math.abs(gaps[a]-gaps[0])>2.5) bad.push(tag+': the gap under plate '+(a+1)+' is '+gaps[a].toFixed(1)+' and under plate 1 it is '+gaps[0].toFixed(1)+', not one gap all the way down');
       for(a=1;a<n&&a<pl.length;a++) if(Math.abs((pl[a].y1-pl[a].y0)-(pl[0].y1-pl[0].y0))>1) bad.push(tag+': row '+(a+1)+' is '+(pl[a].y1-pl[a].y0).toFixed(1)+' high and row 1 is '+(pl[0].y1-pl[0].y0).toFixed(1));
       if(pl.length&&(pl[0].y0>H*0.05||W-pl[0].x1>W*0.03)) bad.push(tag+': the column does not start in the top right corner (first plate at x '+pl[0].x1.toFixed(0)+' right edge, y '+pl[0].y0.toFixed(0)+')');
       if(!MMAP.box) bad.push(tag+': no minimap was drawn');
       else {
         q=MMAP.box;
         if(Math.abs(q.w-q.h)>1.5) bad.push(tag+': the minimap is '+q.w+' by '+q.h+', not a square');
         if(Math.abs(q.x-L)>1.5||Math.abs(q.x+q.w-Rr)>1.5) bad.push(tag+': the minimap spans x '+q.x+' to '+(q.x+q.w)+', not the column '+L.toFixed(0)+' to '+Rr.toFixed(0));
         if(pl.length>n&&Math.abs(pl[n].y0-q.y)>1.5) bad.push(tag+': the plate after the rows starts at y '+pl[n].y0.toFixed(0)+' and the minimap at '+q.y);
       }
       for(a=0;a<r.t.length;a++) if(/run info/.test(r.t[a].d)){ ref=r.t[a]; break; }
       if(!ref) bad.push(tag+': the run info title was not drawn');
       for(k=0;k<n&&k<pl.length;k++){
         p=pl[k]; lab=null; val=null;
         for(a=0;a<r.t.length;a++){ q=r.t[a]; if(q.x>=p.x0-1&&q.x<=p.x1+1&&q.y>=p.y0&&q.y<=p.y1+1){ if(q.al==='left'&&!lab) lab=q; else if(q.al==='right'&&!val) val=q; } }
         if(!lab||lab.d!==labs[k]) bad.push(tag+': row '+(k+1)+' says "'+(lab?lab.d:'')+'" and not "'+labs[k]+'"');
         else px.push(lab.px);
         if(!val) bad.push(tag+': row '+(k+1)+' ('+labs[k]+') has no figure at its right edge');
         else { px.push(val.px); vx.push(val.x); if(wallet&&k===0&&val.d!==(4471337).toLocaleString()) bad.push(tag+': the credits row says "'+val.d+'", not '+(4471337).toLocaleString()); if(wallet&&k===1&&val.d!==(98761).toLocaleString()) bad.push(tag+': the xp row says "'+val.d+'", not '+(98761).toLocaleString()); }
       }
       for(a=1;a<vx.length;a++) if(Math.abs(vx[a]-vx[0])>1) bad.push(tag+': the figures do not share one right edge ('+vx[0].toFixed(0)+' and '+vx[a].toFixed(0)+')');
       for(a=0;a<px.length;a++) if(Math.abs(px[a]-px[0])>0.3||(ref&&Math.abs(px[a]-ref.px)>0.3)) { bad.push(tag+': the rows use more than one type size ('+px[0].toFixed(1)+' and '+px[a].toFixed(1)+(ref?', the run info title '+ref.px.toFixed(1):'')+')'); break; }
       for(a=0;a<r.t.length;a++){ q=r.t[a]; if(pl.length&&q.x>=L-1&&q.x<=Rr+1&&q.y>=pl[0].y0&&q.y<=pl[pl.length-1].y1&&q.d!==q.d.toLowerCase()) low.push(q.d); }
       if(low.length) bad.push(tag+': words in the corner are not lower case ('+low.slice(0,3).join(', ')+')');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       p0=__P(); keepC=p0.credits; keepX=p0.xp; hadHud=('hud' in p0); keepHud=p0.hud;
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p0=__P(); p0.credits=4471337; p0.xp=98761; p0.hud={};
       g.tel.notes=[{t:1,txt:'probe note 4242'}];
       syncTopRight();
       o=grab(); judge('career 1080p',o,true,true);
       el=document.getElementById('topright');
       if(el){
         if(typeof trHide!=='function') bad.push('the credits and xp are still loose page text in the corner and not rows of the column');
         else {
           now=(typeof performance!=='undefined')?performance.now():Date.now();
           trHide(now); cs0=getComputedStyle(el).clipPath;
           if(!cs0||cs0==='none') bad.push('the page text of the credits is still showing while the rows are drawn (clip-path '+cs0+')');
           trHide(now+1e6);
           if(getComputedStyle(el).clipPath!=='none') bad.push('the page text of the credits stayed hidden after the rows stopped being drawn');
         }
       }
       __forceSize(3840,2160); g.tel.notes=[];
       o=grab(); judge('career 4k',o,true,false);
       __endRaid('abandon'); __topClear();
       p0=__P(); p0.credits=keepC; p0.xp=keepX;
       __forceSize(1920,1080);
       if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('control: arcadeDeploy built no arcade raid');
         else {
           g=__state(); if(!g||g.over||!g.player) bad.push('control: no live demo raid');
           else {
             keys={}; ARCADE.holdT=0; oSolo=ARCADE.solo; ARCADE.solo=0;
             try{ if(typeof goalsTick==='function') goalsTick(0.1); }catch(_gt){}
             __frame(0.016); __frame(0.016);
             if(g.flow&&g.flow.goals&&g.flow.goals.length){ o=grab(); judge('the demo 1080p',o,false,false); }   // no goals, no run info panel to line up with: the career runs above still decide
           }
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       proto.fillText=oFt; proto.beginPath=oBp; proto.moveTo=oMv; proto.lineTo=oLn; proto.fill=oFl;
       try{ if(typeof trHide==='function') trHide(1e15); }catch(_h){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE){ if(oSolo!==undefined) ARCADE.solo=oSolo; ARCADE.team=null; ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_a){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       try{ var pf=__P(); pf.credits=keepC; pf.xp=keepX; if(hadHud) pf.hud=keepHud; else delete pf.hud; saveProfile(); }catch(_r){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
