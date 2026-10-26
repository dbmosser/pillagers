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

if ($s.Contains("  {v:'34.90',what:")) { throw "check 34.90 is in the fixture already" }

SubRx @'
  {v:'34.89',what:
'@ @'
  {v:'34.90',what:'cw-thirdsize, his note of 2026-10-25, played on build 33.17 where the figure was drawn at 1.25 ("player character is still wayyy too big, needs to be 1/3 of the size he is right now"): every human figure is drawn at 1.25/3 of its size 1 art times its build (measured on the drawn pixels, lean and broad), the pillager plate rides just over the smaller head, the world muzzle flash sits on the drawn gun tip, the side mark sits beside the body and never covers his gun (a hostile pillager or a hire, aiming any way), the reload bar and the frag and smoke cook plates over your head sit just over the drawn head at 1080, at 4K and aimed in (one HUD gap at every screen and zoom, the two cook plates by the same gap), the give prompt sits over the drawn head of the survivor at every screen and zoom, the glow round the survivor sits on his drawn body, the golden pillager (drawn through the golden body pass on its own canvas) is drawn the size of a plain one, the golden and the outlined body stand on a shadow of their drawn size, the forge flames, ice block and chill ring fit the drawn body, the get-up bar sits over the head of a body rising in a crouch and under his nameplate, the rifle flash reaches less far past the drawn muzzle than the drawn gun reaches past the body and is drawn the same in the partner window, the tracer is drawn at the height of the drawn muzzle in both windows, the survivor (no gun drawn) flashes as long as a lean pillager pistol shot at the height of his tracer, which is drawn at the pillager tracer height, the same in the partner window, a body on the ground (his order of 2026-10-20: scaled properly compared to bodies on ground) lies about as long as a standing pillager is tall, and the hit circle keeps its size',
   run:function(){
     if(typeof drawOp!=='function'||typeof drawOp0!=='function'||typeof gunMuzzleAt!=='function'||typeof worldSideCue!=='function'||typeof colourCueGlyph!=='function'||typeof spriteTop!=='function') return 'SKIP: no figure painter here';
     if(typeof __deploy!=='function'||typeof __runPrep!=='function'||typeof __forceSize!=='function'||typeof drawHUD!=='function'||typeof reloadBarDraw!=='function') return 'SKIP: no raid helpers';
     var T=1.25/3, bad=[], g, K, X0, Y0, keepPix=CFG.xfPix, keepGlyph=colourCueGlyph, cue=null, b1, b3, B, m, i, st;
     var hTop=null, hp=null, oRB=reloadBarDraw, oF=null, hadF=false, wp0, az0, ZC0=ZC, ZT0=ZT, CS, ci, rec, rs, gp, nm;
     var keepSh=shadowE, eg, sg, P1, Gd, Rm, gOpen, rOpen, L0, A0, t0, EL, mx, ee, q, j, bb, bn, bc, bu;
     var by0=GFX.bypass, NK=null, sent=[], pl, own, ob, msg, fm, fb, fl, fp, fr, gl, ys, PS, ct, cL, LT=CanvasRenderingContext2D.prototype.lineTo, ltOn=false;
     var o1, o2, o3, sv, fs, fr2, yr, yp;
     var SD, sm, hz, hb, PN, HG=CanvasRenderingContext2D.prototype.createRadialGradient, hgOn=false;
     function cp(o){ var r={}, k; for(k in o) r[k]=o[k]; return r; }
     // the pixels round one body at 100,100 (60 by 50 units)
     function pxd(fn){ wc.save(); try{ wc.setTransform(1,0,0,1,0,0); wc.clearRect(0,0,cv.width,cv.height); wc.setTransform(K,0,0,K,X0-100*K,Y0-100*K); fn(); } finally { wc.restore(); } return wc.getImageData(X0-30*K,Y0-40*K,60*K,50*K).data; }
     // a body with a rifle aiming fc: its gun pixels (drawn with the rifle, less the bare body, both with the side mark left out), how many of them the side mark paints over,
     // how many pixels the mark paints at all, where it was put, and how many pixels a second draw changed (0: the drawing is steady)
     function sideHide(team,fc,bld){
       var s1={hero:0,build:bld,team:team,merc:team==='ally'?1:0,moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,own:{hp:50,wep:{id:'rifle'}}}, s0=cp(s1), A, A2, N, F, i, n=0, c=0, z=0, mp=0, cu=null;
       s0.own={hp:50,wep:null};
       colourCueGlyph=function(){};
       try{ A=pxd(function(){ drawOp(100,100,fc,0,'#242832',0,0,'',0,s1); }); A2=pxd(function(){ drawOp(100,100,fc,0,'#242832',0,0,'',0,s1); }); N=pxd(function(){ drawOp(100,100,fc,0,'#242832',0,0,'none',0,s0); }); } finally { colourCueGlyph=keepGlyph; }
       colourCueGlyph=function(c2,kind,x,y){ cu={x:x-100,y:100-y}; return keepGlyph.apply(this,arguments); };
       try{ F=pxd(function(){ drawOp(100,100,fc,0,'#242832',0,0,'',0,s1); }); } finally { colourCueGlyph=keepGlyph; }
       for(i=0;i<A.length;i+=4){
         if(A[i]!==A2[i]||A[i+1]!==A2[i+1]||A[i+2]!==A2[i+2]||A[i+3]!==A2[i+3]) z++;
         if(F[i]!==A[i]||F[i+1]!==A[i+1]||F[i+2]!==A[i+2]||F[i+3]!==A[i+3]) mp++;
         if(A[i+3]>40&&(A[i]!==N[i]||A[i+1]!==N[i+1]||A[i+2]!==N[i+2]||A[i+3]!==N[i+3])){ n++; if(F[i]!==A[i]||F[i+1]!==A[i+1]||F[i+2]!==A[i+2]||F[i+3]!==A[i+3]) c++; }
       }
       return {n:n,c:c,z:z,mp:mp,cu:cu};
     }
     // one world frame with only the survivor (still in need of help) beside you: where the middle of the glow round him is and how wide it is
     function halo(s3){ var o=null, L0h=g.ents; CanvasRenderingContext2D.prototype.createRadialGradient=function(x0,y0,r0,x1,y1,r1){ if(!o&&Math.abs(x0-s3.x)<1e-6&&r0===2) o={up:s3.y-y0,r:r1}; return HG.apply(this,arguments); }; hgOn=true; try{ g.ents=[s3]; __frame(0); } finally { CanvasRenderingContext2D.prototype.createRadialGradient=HG; hgOn=false; g.ents=L0h; } return o; }
     function peer(s){ return {state:'in',seat:s,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function flashBox(ev,cx,cy){ var r, e2=cp(ev); e2.me=true; GFXMUZ.length=0; GFXMUZ.push(e2); GFX.bypass=0; /* me: drawn whoever fired it (the size is measured, not the sight line) */ try{ r=box(function(){ gfxMuzzleFx(0); },cx,cy); } finally { GFXMUZ.length=0; } return r; }
     // one shot fired in a shared raid as the host, then its word taken in the partner window: the flash and the round of each window
     function netShot(sh,wep,fromP){ var o={own:null,ob:null,msg:null,fm:null,fb:null}, q2;
       NK={}; for(q2 in NET) NK[q2]=NET[q2];
       try{
         keys={}; GFX.bypass=0;
         NET.on=true; NET.up=[]; NET.upSeed=g.seed>>>0; NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
         GFXMUZ.length=0; g.bullets.length=0; g.fxBullets=[]; sent.length=0; NET.role='host'; NET.seat=0; NET.peers=[peer(1)];
         fireWeapon(sh,cloneObj(wep),sh.x+300,sh.y,fromP);
         o.own=GFXMUZ[GFXMUZ.length-1]; o.ob=g.bullets[g.bullets.length-1]; o.own=o.own?cp(o.own):null; o.ob=o.ob?cp(o.ob):null;
         o.msg=sent.filter(function(x){ return x&&x.t==='fx'&&x.k==='b'; })[0]||null;
         if(o.own&&o.ob&&o.msg){ GFXMUZ.length=0; g.fxBullets=[]; NET.role='join'; NET.seat=1; NET.peers=[peer(0)]; netFxTake(NET.peers[0],o.msg); o.fm=GFXMUZ[GFXMUZ.length-1]; o.fb=g.fxBullets[g.fxBullets.length-1]; o.fm=o.fm?cp(o.fm):null; o.fb=o.fb?cp(o.fb):null; }
       } finally { for(q2 in NET) if(!(q2 in NK)) delete NET[q2]; for(q2 in NK) NET[q2]=NK[q2]; GFXMUZ.length=0; g.bullets.length=0; g.fxBullets=[]; GFX.bypass=by0; }
       return o;
     }
     // one world frame with only this round in the air, 30 units on (past any muzzle gate); how far over the round its tracer was drawn
     function trY(bl,inFx){ var Y=[], v=Math.hypot(bl.vx,bl.vy)||1; bl=cp(bl); bl.x+=bl.vx/v*30; bl.y+=bl.vy/v*30; g.bullets.length=0; g.fxBullets=[]; if(inFx) g.fxBullets.push(bl); else g.bullets.push(bl); CanvasRenderingContext2D.prototype.lineTo=function(x,y){ if(Math.abs(x-bl.x)<1e-6) Y.push(bl.y-y); return LT.apply(this,arguments); }; ltOn=true; try{ __frame(0); } finally { CanvasRenderingContext2D.prototype.lineTo=LT; ltOn=false; g.bullets.length=0; g.fxBullets=[]; } return Y; }
     // one HUD frame at a screen size and a scope zoom, cooking a throwable of kind ck; returns how far the bottom of the reload bar and of the cook plate sit over the drawn lean head top, in HUD px
     function plates(w,h,az,ckd){
       var r, feet, head, dpr=(typeof DPRH==='number'&&DPRH>0)?DPRH:1, o={}, oHP=hudPrompt, SV=null, nv=[g.nearStray,g.nearDoor,g.nearSeal,g.nearDown,g.ents];
       __forceSize(w,h); __pinDPR(1); g.adsZ=az; ZC=1; ZT=1; keys={};
       r=hudRes(); feet=w2s(hp.x,0,hp.y).y; head=hTop*ZOOM();
       rec={rb:null,ck:null,inRB:0,gv:null};
       if(hb){   // a found survivor 30 beside you who still needs a medkit, so E hands it over and the give prompt is the one prompt drawn
         SV={kind:'stray',x:hp.x+30,y:hp.y,r:11,hp:70,maxhp:70,face:Math.PI,coat:'#7a8a6a',name:'SURVIVOR',neutral:1,want:'medkit',helped:0,found:1,hostile:0};
         g.ents=g.ents.concat([SV]); g.nearStray=SV; g.nearDoor=null; g.nearSeal=null; g.nearDown=null;
         hudPrompt=function(s,x,y,q2){ var q=oHP.apply(this,arguments), M; if(/GIVE/i.test(String(s))&&q&&isFinite(q.by)){ M=ctx.getTransform(); rec.gv=(M.b*x+M.d*q.by+M.f)/dpr; } return q; };
       }
       reloadBarDraw=function(){ rec.inRB=1; try{ return oRB.apply(this,arguments); } finally { rec.inRB=0; } };
       hadF=Object.prototype.hasOwnProperty.call(ctx,'fillRect'); oF=ctx.fillRect;
       ctx.fillRect=function(x,y,ww,hh){
         var M=this.getTransform(), y1=(M.b*x+M.d*y+M.f)/dpr, y2=(M.b*x+M.d*(y+hh)+M.f)/dpr, k=null, fs=String(this.fillStyle).replace(/\s/g,'');
         if(rec.inRB) k='rb'; else if(ww===116&&(fs==='rgba(6,9,13,0.72)'||fs==='rgba(6,9,13,.72)')) k='ck';
         if(k){ if(!rec[k]) rec[k]={bot:Math.max(y1,y2)}; else rec[k].bot=Math.max(rec[k].bot,y1,y2); }
         return oF.apply(this,arguments);
       };
       try{ hp.reloading=1500; hp.rlTot=3000; hp.cooking=1; hp.cookKind=ckd; hp.cookT=0.3; drawHUD(); }
       finally{ if(hadF) ctx.fillRect=oF; else delete ctx.fillRect; reloadBarDraw=oRB; hudPrompt=oHP; g.nearStray=nv[0]; g.nearDoor=nv[1]; g.nearSeal=nv[2]; g.nearDown=nv[3]; g.ents=nv[4]; hp.reloading=0; hp.rlTot=0; hp.cooking=0; hp.cookKind=null; hp.cookT=0; }
       o.r=r; o.z=ZOOM();
       if(rec.rb) o.rb=(feet-rec.rb.bot-head)/r;
       if(rec.ck) o.ck=(feet-rec.ck.bot-head)/r;
       if(SV&&rec.gv!==null) o.gv=(w2s(SV.x,0,SV.y).y-rec.gv-hb.top*ZOOM())/r;   // the bottom of the give plate over the drawn head of the crouched survivor
       return o;
     }
     function box(fn,cx,cy){
       var d, W2, H2, x0=1e9, y0=1e9, x1=-1, y1=-1, x, y;
       wc.save();
       try{ wc.setTransform(1,0,0,1,0,0); wc.clearRect(0,0,cv.width,cv.height); wc.setTransform(K,0,0,K,X0-(cx===undefined?100:cx)*K,Y0-(cy===undefined?100:cy)*K); fn(); } finally { wc.restore(); }
       W2=cv.width; H2=cv.height; d=wc.getImageData(0,0,W2,H2).data;
       for(y=0;y<H2;y++) for(x=0;x<W2;x++) if(d[(y*W2+x)*4+3]>40){ if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; }
       return x1<0?null:{w:(x1-x0+1)/K, h:(y1-y0+1)/K, top:(Y0-y0)/K, right:(x1+1-X0)/K};
     }
     function shAt(fn){ var o=[], s0=shadowE, b; shadowE=function(x,y,rx,ry,a){ var M=wc.getTransform(); o.push(Math.hypot(M.a,M.b)); return s0.apply(this,arguments); }; try{ b=box(fn); } finally { shadowE=s0; } return {b:b,s:o}; }
     function mk(b){ return {hero:0,build:b,moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,own:{wep:{id:'rifle'}}}; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       if(!wc||wc.canvas!==cv) return 'SKIP: the world canvas is not up';
       CFG.xfPix=0; keys={};
       K=(cv.height>=500)?4:2; X0=Math.round(cv.width/2); Y0=Math.round(cv.height*0.8);
       B={lean:[0.92,1.08],broad:[1.1,0.96]};
       for(i in B){
         st=mk(i);
         b1=box(function(){ drawOp0(100,100,0,0,'#242832',0,0,'',0,st); });
         b3=box(function(){ drawOp(100,100,0,0,'#242832',0,0,'',0,st); });
         if(!b1||!b3){ bad.push('the '+i+' figure drew nothing'); continue; }
         if(Math.abs(b3.h/b1.h-B[i][1]*T)>0.02) bad.push('the '+i+' figure is drawn '+(b3.h/b1.h).toFixed(3)+' of its size 1 height, not 1.25/3 times its build ('+(B[i][1]*T).toFixed(3)+')');
         if(Math.abs(b3.w/b1.w-B[i][0]*T)>0.02) bad.push('the '+i+' figure is drawn '+(b3.w/b1.w).toFixed(3)+' of its size 1 width, not 1.25/3 times its build ('+(B[i][0]*T).toFixed(3)+')');
         if(i==='lean'){
           hTop=b3.top;
           m=spriteTop({kind:'raider',r:11})-b3.top;
           if(!(m>=2&&m<=12)) bad.push('the pillager plate sits '+m.toFixed(1)+' over the drawn head (wanted 2 to 12)');
           m=gunMuzzleAt({kind:'raider',x:100,y:100,build:'lean'},{id:'rifle'},0);
           if(!m||Math.abs((m.x-100)-b3.right)>3) bad.push('the muzzle flash point is '+(m?(m.x-100).toFixed(1):'none')+' out, the drawn gun ends '+b3.right.toFixed(1)+' out');
           colourCueGlyph=function(c,kind,x,y){ cue={x:x,y:y}; };
           try{ worldSideCue(100,100,{team:'foe',build:'lean',own:{hp:50}}); } finally { colourCueGlyph=keepGlyph; }
           if(!cue) bad.push('no side mark was drawn for a hostile pillager');
           else if(!(100-cue.y>=0&&100-cue.y<=b3.top+2&&100-cue.x>=4&&100-cue.x<=16)) bad.push('the side mark sits '+(100-cue.x).toFixed(1)+' left and '+(100-cue.y).toFixed(1)+' up of the feet, not beside a body '+b3.top.toFixed(1)+' tall');
           // the side mark never covers his gun: a hostile pillager and a hire (the plus mark) aiming each of eight ways, and a broad one aiming left; the mark is painted beside the
           // body (4 to 16 out to either side, no higher than the head) and paints over at most 2 in 100 of his gun pixels (the body drawn with a rifle, less the bare body)
           SD=[['foe',0,'lean'],['foe',0.25,'lean'],['foe',0.5,'lean'],['foe',0.75,'lean'],['foe',1,'lean'],['foe',-0.75,'lean'],['foe',-0.5,'lean'],['foe',-0.25,'lean'],['ally',1,'lean'],['ally',0,'lean'],['foe',1,'broad']];
           for(j=0;j<SD.length;j++){
             sm=sideHide(SD[j][0],SD[j][1]*Math.PI,SD[j][2]); nm=(SD[j][0]==='ally'?'a hire':'a hostile pillager')+' ('+SD[j][2]+') aiming '+SD[j][1]+' pi';
             if(sm.z||sm.n<200||!sm.cu||sm.mp<200) bad.push('staging: '+nm+': '+sm.n+' gun pixels, '+sm.mp+' mark pixels, '+sm.z+' unsteady, mark '+(sm.cu?'placed':'not placed'));
             else if(!(Math.abs(sm.cu.x)>=4&&Math.abs(sm.cu.x)<=16&&sm.cu.y>=0&&sm.cu.y<=b3.top+2)) bad.push('the side mark of '+nm+' sits '+sm.cu.x.toFixed(1)+' across and '+sm.cu.y.toFixed(1)+' up of the feet, not beside a body '+b3.top.toFixed(1)+' tall');
             else if(sm.c>0.02*sm.n) bad.push('the side mark covers '+sm.c+' of the '+sm.n+' gun pixels of '+nm);
           }
           // the golden pillager: goldBodyBegin swaps wc for its own canvas, and he must still be drawn the size of a plain pillager, on a shadow of that size; so must an outlined elite (rimOpen)
           eg={kind:'raider',golden:1,elite:true,affix:'fast',x:100,y:100,r:12,hp:50,face:0,build:'lean',state:'idle',hostile:true,wep:{id:'rifle'}};
           sg={own:eg,team:'foe',merc:0,build:'lean',moving:false,sprint:false,ads:false,hurt:0,bulk:0};
           P1=shAt(function(){ drawOp(100,100,0,0,'#242832',0,0,'',0,sg); });
           Gd=shAt(function(){ var h=goldBodyBegin(eg); gOpen=!!h; try{ drawOp(100,100,0,0,'#242832',0,0,'',0,sg); } finally { goldBodyEnd(h); } });
           Rm=shAt(function(){ var h=rimOpen(eg,'#ff4040'); rOpen=!!h; try{ drawOp(100,100,0,0,'#242832',0,0,'',0,sg); } finally { rimClose(h); } });
           if(!gOpen||!rOpen) return 'SKIP: staging: the golden body pass ('+gOpen+') or the outline pass ('+rOpen+') did not open';
           if(!P1.b||!Gd.b||Math.abs(Gd.b.h-P1.b.h)>1.5||Math.abs(Gd.b.top-P1.b.top)>1) bad.push('the golden pillager is drawn '+(Gd.b?Gd.b.h.toFixed(1)+' tall with his shadow, head '+Gd.b.top.toFixed(1)+' up':'as nothing')+', a plain one '+(P1.b?P1.b.h.toFixed(1)+', head '+P1.b.top.toFixed(1):'as nothing'));
           if(!P1.s.length||!Gd.s.length||!Rm.s.length) bad.push('staging: no ground shadow was drawn (plain '+P1.s.length+', golden '+Gd.s.length+', outlined '+Rm.s.length+')');
           else { m=Gd.s.concat(Rm.s).filter(function(v){ return Math.abs(v/P1.s[0]-1)>0.02; }); if(m.length) bad.push('the golden or outlined body stands on a shadow drawn at scale '+m[0].toFixed(3)+' ('+m.length+' of '+(Gd.s.length+Rm.s.length)+'), the plain one at '+P1.s[0].toFixed(3)); }
           // the forge element effects on a pillager bot fit the drawn body: the flames stay under the head, the ice block just covers it, the chill ring rings it
           L0=g.ents; A0=g.arcs; t0=g.t; mx={};
           try{
             g.arcs=[]; EL={burn:{burnT:2},frozen:{frozenT:2},chill:{chillT:2,chill:1}};
             for(nm in EL) for(j=0;j<(nm==='burn'?6:1);j++){
               ee={kind:'raider',x:100,y:100,r:11,hp:50,face:0,build:'lean',hostile:true,seen:true}; for(q in EL[nm]) ee[q]=EL[nm][q];   // seen: the element effects draw on a body in sight only (v34.87)
               g.ents=[ee]; g.t=t0+j*0.173;
               bb=box(function(){ drawElemFx(0); });
               if(bb){ if(!mx[nm]) mx[nm]={top:bb.top,w:bb.w}; else { mx[nm].top=Math.max(mx[nm].top,bb.top); mx[nm].w=Math.max(mx[nm].w,bb.w); } }
             }
           } finally { g.ents=L0; g.arcs=A0; g.t=t0; }
           bn=box(function(){ drawOp(100,100,0,0,'#242832',0,0,'none',0,{hero:0,build:'lean',moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,own:{wep:null}}); });
           if(!mx.burn||!mx.frozen||!mx.chill||!bn) bad.push('staging: an element effect or the bare body drew nothing ('+Object.keys(mx).join(',')+')');
           else {
             if(mx.burn.top>b3.top+2) bad.push('the flames reach '+mx.burn.top.toFixed(1)+' up, over the head of a body '+b3.top.toFixed(1)+' tall');
             if(!(mx.frozen.top>=b3.top+1&&mx.frozen.top<=b3.top+9)) bad.push('the ice block reaches '+mx.frozen.top.toFixed(1)+' up, not just over the head ('+b3.top.toFixed(1)+')');
             if(mx.frozen.w>2.2*bn.w) bad.push('the ice block is '+mx.frozen.w.toFixed(1)+' wide round a body '+bn.w.toFixed(1)+' wide');
             if(!(mx.chill.top>=b3.top&&mx.chill.top<=b3.top+8)) bad.push('the chill ring reaches '+mx.chill.top.toFixed(1)+' up, not just over the head ('+b3.top.toFixed(1)+')');
           }
           // the get-up bar of a downed pillager bot: over the head of his body rising in a crouch (the bar is drawn first), under his nameplate
           bc=box(function(){ drawOp(100,100,0,0,'#242832',0,0,'crouch',0,mk('lean')); });
           bu=box(function(){ raiderGetUpBar({kind:'raider',x:100,y:100,r:11,hp:20,downed:true,getUp:1.5,hostile:true}); });
           m=spriteTop({kind:'raider',r:11});
           if(!bc||!bu) bad.push('staging: the crouched body or the get-up bar drew nothing');
           else if(!(bu.top-bu.h>=bc.top-0.5&&bu.top<=m)) bad.push('the get-up bar runs '+(bu.top-bu.h).toFixed(1)+' to '+bu.top.toFixed(1)+' up, not between the head of the body rising in a crouch ('+bc.top.toFixed(1)+') and his nameplate ('+m.toFixed(1)+')');
           // the rifle flash of a lean pillager: it reaches less far past the drawn muzzle than the drawn gun reaches past the bare body
           GFXMUZ.length=0; GFX.bypass=0;
           try{ gfxShot({kind:'raider',x:100,y:100,r:11,build:'lean'},cloneObj(WEAPONS.rifle),0,true); fr=GFXMUZ[GFXMUZ.length-1]; } finally { GFX.bypass=by0; GFXMUZ.length=0; }
           m=gunMuzzleAt({kind:'raider',x:100,y:100,build:'lean'},{id:'rifle'},0);
           fl=fr?flashBox(fr):null; GFX.bypass=by0; gl=b3.right-bn.right;
           if(!fr||!fl||!m) bad.push('staging: the rifle shot drew no flash');
           else if(!(fl.right-(m.x-100)<gl)) bad.push('the rifle flash reaches '+(fl.right-(m.x-100)).toFixed(1)+' past the drawn muzzle, the drawn gun only '+gl.toFixed(1)+' past the body');
           // your rifle shot as the host: the partner window takes its word; his flash is drawn as long as yours, and both tracers are drawn at the height of the drawn muzzle
           pl=g.player; pl.iv=99; pl.face=0;
           o1=netShot(pl,WEAPONS.rifle,true); own=o1.own; ob=o1.ob; msg=o1.msg; fm=o1.fm; fb=o1.fb;
           if(!own||!ob||!msg||!fm||!fb) bad.push('staging: the shot left no flash ('+!!own+'), no round ('+!!ob+'), no word ('+!!msg+') or nothing in the partner window ('+!!fm+', '+!!fb+')');
           else {
             q=cp(fm); q.x=own.x; q.y=own.y; q.a=own.a;   // the partner flash drawn where and as yours is aimed (29.08 holds where it sits; a round has its own spread), so only its size can differ
             fl=flashBox(own,pl.x,pl.y); fp=flashBox(q,pl.x,pl.y); GFX.bypass=by0;
             if(!fl||!fp) bad.push('staging: your flash ('+!!fl+') or the partner flash ('+!!fp+') drew nothing');
             else if(Math.abs(fp.right-fl.right)>1||Math.abs(fp.w-fl.w)>1) bad.push('the partner window draws your flash '+fp.w.toFixed(1)+' long to '+fp.right.toFixed(1)+' out, your window '+fl.w.toFixed(1)+' long to '+fl.right.toFixed(1)+' out');
             ys=trY(ob,false);
             if(!ys.length) bad.push('staging: your tracer was not drawn');
             else if(ys.some(function(y){ return Math.abs(y-(pl.y-own.y))>1; })) bad.push('your tracer is drawn '+ys[0].toFixed(1)+' over the round, the drawn muzzle is '+(pl.y-own.y).toFixed(1)+' up');
             fr=ys; ys=trY(fb,true);
             if(!ys.length) bad.push('staging: the partner tracer was not drawn');
             else if(fr.length&&ys.some(function(y){ return Math.abs(y-fr[0])>1; })) bad.push('the partner window draws your tracer '+ys[0].toFixed(1)+' over the round, your window '+fr[0].toFixed(1));
           }
           // the survivor draws no gun and fires a pistol when turned: his flash is as long as a lean pillager pistol flash and at the height of his tracer, his tracer at the pillager tracer height, and the partner window draws both as his own window does
           sv={kind:'stray',x:pl.x,y:pl.y,r:11,hp:70,maxhp:70,face:0,hostile:true,helped:0,coat:'#7a8a6a'};
           o2=netShot(sv,WEAPONS.pistol,false);
           o3=netShot({kind:'raider',x:pl.x,y:pl.y,r:11,hp:50,face:0,build:'lean',hostile:true},WEAPONS.pistol,false);
           if(!o2.own||!o2.ob||!o2.msg||!o2.fm||!o2.fb||!o3.own||!o3.ob) bad.push('staging: the survivor shot left no flash ('+!!o2.own+'), no round ('+!!o2.ob+'), no word ('+!!o2.msg+') or nothing in the partner window ('+!!o2.fm+', '+!!o2.fb+'), or the pillager pistol shot no flash or round ('+!!o3.own+', '+!!o3.ob+')');
           else {
             q=cp(o2.fm); q.x=o2.own.x; q.y=o2.own.y; q.a=o2.own.a;   // as for yours: only the size of the partner flash can differ
             fs=flashBox(o2.own,pl.x,pl.y); fr2=flashBox(o3.own,pl.x,pl.y); fp=flashBox(q,pl.x,pl.y); GFX.bypass=by0;
             if(!fs||!fr2||!fp) bad.push('staging: the survivor flash ('+!!fs+'), the pillager pistol flash ('+!!fr2+') or the partner survivor flash ('+!!fp+') drew nothing');
             else {
               if(Math.abs(fs.w-fr2.w)>1) bad.push('the survivor flash is drawn '+fs.w.toFixed(1)+' long, a lean pillager pistol flash '+fr2.w.toFixed(1)+' long');
               if(Math.abs(fp.w-fs.w)>1) bad.push('the partner window draws the survivor flash '+fp.w.toFixed(1)+' long, his own window '+fs.w.toFixed(1));
             }
             ys=trY(o2.ob,false); yr=trY(o3.ob,false); yp=trY(o2.fb,true);
             if(!ys.length||!yr.length||!yp.length) bad.push('staging: the survivor tracer ('+ys.length+'), the pillager pistol tracer ('+yr.length+') or the partner survivor tracer ('+yp.length+') was not drawn');
             else {
               if(ys.some(function(y){ return Math.abs(y-(sv.y-o2.own.y))>1; })) bad.push('the survivor tracer is drawn '+ys[0].toFixed(1)+' over the round, his flash '+(sv.y-o2.own.y).toFixed(1)+' up');
               if(Math.abs(ys[0]-yr[0])>1) bad.push('the survivor tracer is drawn '+ys[0].toFixed(1)+' over the round, a lean pillager pistol tracer '+yr[0].toFixed(1));
               if(yp.some(function(y){ return Math.abs(y-ys[0])>1; })) bad.push('the partner window draws the survivor tracer '+yp[0].toFixed(1)+' over the round, his own window '+ys[0].toFixed(1));
             }
           }
           // the glow round the survivor while he still needs help: its middle in the middle of his drawn crouched body (0.3 to 0.6 of its height up), 0.8 to 1.6 times his height round
           hb=box(function(){ drawOp(100,100,0,0,'#7a8a6a',0,0,'crouchnone',0,{moving:false,sprint:false,ads:false,hurt:0,bulk:0,outfit:'outsurvivor',wave:1}); });
           hz=halo({kind:'stray',x:pl.x+40,y:pl.y,r:11,hp:70,maxhp:70,face:Math.PI,coat:'#7a8a6a',name:'SURVIVOR',neutral:1,bag:[],stock:[],want:'medkit',helped:0,found:0,askedT:0,state:'idle',tx:pl.x+40,ty:pl.y,cd:5,alert:0,spd:0,dmg:0,rng:0,cone:0,hitT:0,step:0,goal:null,skips:[],goalT:0,goalD:0,extracting:0});
           if(!hb||!hz) bad.push('staging: the crouched survivor ('+!!hb+') or the glow round him ('+!!hz+') was not drawn');
           else if(!(hz.up>=0.3*hb.top&&hz.up<=0.6*hb.top&&hz.r>=0.8*hb.top&&hz.r<=1.6*hb.top)) bad.push('the glow round the survivor is centred '+hz.up.toFixed(1)+' up and '+hz.r.toFixed(1)+' round, his crouched body is '+hb.top.toFixed(1)+' tall');
           // a body on the ground lies at the size of a standing pillager: as long as he is tall, give or take a fifth (eight bodies, each lying its own way)
           PS=[[0,0],[13,-7],[-21,5],[31,-11],[-9,9],[27,3],[-35,-15],[5,-19]]; cL=0;
           for(j=0;j<PS.length;j++){ ct={x:100+PS[j][0],y:100+PS[j][1],r:15,type:'body',loot:[],opened:false,time:1,best:'common',prog:0}; bb=box(function(){ drawContS(ct); }); if(bb) cL=Math.max(cL,bb.w,bb.h); }
           if(!(cL>0)) bad.push('staging: a body on the ground drew nothing');
           else if(!(cL<=1.2*b3.top&&cL>=0.6*b3.top)) bad.push('a body on the ground is drawn '+cL.toFixed(1)+' long next to a standing pillager '+b3.top.toFixed(1)+' tall');
         }
       }
       // the reload bar and the cook plates over your head (the frag plate, and the smoke plate with its second row, as the decoy and the trip mine have): at 1080, at 4K (hudRes 2),
       // aimed in at both (ZOOM 1.6 times) and a long scope at 1080 (2.3 times); each plate ends over the drawn head, by the same gap at every screen and zoom, and the two cook plates by the same gap;
       // the give prompt over a found survivor beside you ends over his drawn (crouched, waving) head at each of them
       if(hTop>0){
         hp=g.player; wp0=hp.wep; az0=g.adsZ; hp.wep=cloneObj(WEAPONS.rifle); hp.iv=99;
         CS={'1080':[1920,1080,1],'4k':[3840,2160,1],'1080 aimed':[1920,1080,1.6],'4k aimed':[3840,2160,1.6],'1080 long scope':[1920,1080,2.3]}; rs={};
         try{ for(ci in CS){ rs[ci]=plates(CS[ci][0],CS[ci][1],CS[ci][2],'frag'); rs[ci].sk=plates(CS[ci][0],CS[ci][1],CS[ci][2],'smoke').ck; } }
         finally{ hp.wep=wp0; g.adsZ=az0; ZC=ZC0; ZT=ZT0; __runPrep(); }
         if(!(rs['4k'].r>=1.99)) return 'SKIP: staging: a 3840 by 2160 screen gave a HUD scale of '+rs['4k'].r;
         PN={rb:'the reload bar',ck:'the frag cook plate',sk:'the smoke cook plate',gv:'the give prompt over the survivor'};
         for(nm in PN){
           gp=[]; for(ci in rs){ if(rs[ci][nm]===undefined){ bad.push(PN[nm]+' was not drawn at '+ci); continue; } gp.push(rs[ci][nm]); }
           for(ci in rs) if(rs[ci][nm]!==undefined&&!(rs[ci][nm]>=(nm==='rb'?-1:(nm==='gv'?1:0))&&rs[ci][nm]<=(nm==='rb'?6:(nm==='gv'?30:20)))) bad.push(PN[nm]+' ends '+rs[ci][nm].toFixed(1)+' HUD px over the drawn head at '+ci+' (ZOOM '+rs[ci].z.toFixed(2)+', HUD scale '+rs[ci].r+'), wanted '+(nm==='rb'?'-1 to 6':(nm==='gv'?'1 to 30':'0 to 20')));
           if(gp.length&&Math.max.apply(null,gp)-Math.min.apply(null,gp)>(nm==='gv'?4:2)) bad.push(PN[nm]+' gap over the head changes with the screen and the zoom ('+gp.map(function(v){ return v.toFixed(1); }).join(', ')+' HUD px)');   // the give prompt lifts over the standing head and the survivor crouches, so its gap may drift a little with the zoom
         }
         for(ci in rs) if(rs[ci].ck!==undefined&&rs[ci].sk!==undefined&&Math.abs(rs[ci].sk-rs[ci].ck)>1.5) bad.push('the smoke cook plate ends '+rs[ci].sk.toFixed(1)+' HUD px over the drawn head at '+ci+', the frag plate '+rs[ci].ck.toFixed(1));
       }
       if(g.player.r!==11) bad.push('control: the hit circle moved to '+g.player.r+' (drawing only)');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ colourCueGlyph=keepGlyph; shadowE=keepSh; GFX.bypass=by0; if(ltOn||CanvasRenderingContext2D.prototype.lineTo!==LT) CanvasRenderingContext2D.prototype.lineTo=LT; if(hgOn||CanvasRenderingContext2D.prototype.createRadialGradient!==HG) CanvasRenderingContext2D.prototype.createRadialGradient=HG; try{ GFXMUZ.length=0; if(NK){ for(q in NET) if(!(q in NK)) delete NET[q]; for(q in NK) NET[q]=NK[q]; } }catch(_n){} try{ if(GOLDB.h) goldBodyAbort(); if(RIM.h) rimAbort(); }catch(_ga){} CFG.xfPix=keepPix; reloadBarDraw=oRB; try{ if(oF&&!hadF&&Object.prototype.hasOwnProperty.call(ctx,'fillRect')) delete ctx.fillRect; }catch(_f){} ZC=ZC0; ZT=ZT0; try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __runPrep(); __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
