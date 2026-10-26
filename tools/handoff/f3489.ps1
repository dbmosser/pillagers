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

if ($s.Contains("  {v:'34.89',what:")) { throw "check 34.89 is in the fixture already" }

SubRx @'
  {v:'34.88',what:
'@ @'
  {v:'34.89',what:'cw-hudcorner, his note of 2026-10-25 ("in raid, right hand lower corner menu and minizmized controls f1 key are awkward take a look"): the gun card is one plain panel that hugs its rows (as wide as they can read with that gun in hand) with even padding and no lime stub, and keeps one size and place for every gun through a shot, an empty magazine, a reload, aiming in, a reserve that loses or gains a figure and loot in the backpack; the folded f1 controls chip stands on the belt caption row just left of key 1 in the caption style, and F1 opens the list upward from it (it may end on the top of the use bar plate when it stands over the plate columns), clear of the vitals, the feed, the medals, the caption, the belt, the use bar of a bandage (and it does not move when the bandage goes on), both use bars of a bandage and a plate at once (from their first frame, and back in its place after), four power up timer chips and, with the ship called, the raised use bar (one or both) and the countdown, landing on each new place in its first frame with no flash, ending before 47 percent of the width, in career, the demo and the second window at 1080 and 4K, and still clear of the vitals, the feed, the belt and the use bar (one or both) and ending before 47 percent (or, where the feed leaves no such room, right against the feed and short of the middle) on a short screen (1280x720, 1366x768 and 1600x900, career and the demo, where the party type puts the belt spot beside the bars); a pad shows no chip',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__forceSize||typeof arcadeDeploy!=='function'||typeof hudPanel!=='function'||typeof bar!=='function'||typeof hudKey!=='function') return 'SKIP: no raid staging in this fixture';
     var bad=[], PR=CanvasRenderingContext2D.prototype, oT=PR.fillText, oR=PR.fillRect, oPanel=hudPanel, oBar=bar, oKey=hudKey, oPad=padOn, oSay=say, r0=P.runs, nsv=null, nsp=(typeof netSamePost==='function')?netSamePost:null, hud0=(P.hud===undefined)?undefined:JSON.stringify(P.hud), rec=null, done=0;
     var SZ=[[1920,1080,'1080'],[3840,2160,'4k']], MD=['career','demo','second window'], si, mi;
     function hit(a,b){ return !!(a&&b&&a.w>0&&b.w>0&&a.h>0&&b.h>0&&a.x<b.x+b.w-0.5&&b.x<a.x+a.w-0.5&&a.y<b.y+b.h-0.5&&b.y<a.y+a.h-0.5); }
     function R(b){ return b?Math.round(b.x)+','+Math.round(b.y)+' '+Math.round(b.w)+'x'+Math.round(b.h):'none'; }
     function lbox(){ var b=HUDBOX.legend; return b?{x:b.x,y:b.y,w:b.w,h:b.h}:null; }
     function same(a,b){ return !!(a&&b&&Math.abs(a.x-b.x)<=0.5&&Math.abs(a.y-b.y)<=0.5&&Math.abs(a.w-b.w)<=0.5&&Math.abs(a.h-b.h)<=0.5); }
     function sr(c,x,y,w,h){ var t=c.getTransform(), d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1, x0=(t.a*x+t.c*y+t.e)/d, y0=(t.b*x+t.d*y+t.f)/d, x1=(t.a*(x+w)+t.c*(y+h)+t.e)/d, y1=(t.b*(x+w)+t.d*(y+h)+t.f)/d; return {x:Math.min(x0,x1),y:Math.min(y0,y1),w:Math.abs(x1-x0),h:Math.abs(y1-y0)}; }
     function fpx(c,f){ var m=/([\d.]+)px/.exec(String(f)), t=c.getTransform(), d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1; return m?(+m[1])*Math.abs(t.a)/d:0; }
     function hook(){
       rec={panels:[],bars:[],rects:[],texts:[],keys:[]};
       hudPanel=function(x,y,w,h,a,pl){ if(rec&&w>0&&h>0){ var b=sr(ctx,x,y,w,h); b.a=a; b.pl=!!pl; rec.panels.push(b); } return oPanel.apply(this,arguments); };
       bar=function(x,y,w,h){ if(rec) rec.bars.push(sr(ctx,x,y,w,h)); return oBar.apply(this,arguments); };
       hudKey=function(l,x,y,a,sw,o){ var r=oKey.apply(this,arguments); if(rec){ var b=sr(ctx,x,y-a,(sw>0?sw:r)||1,a||1); b.l=String(l).toLowerCase(); b.fill=o&&o.fill; rec.keys.push(b); } return r; };
       PR.fillRect=function(x,y,w,h){ if(rec&&this===ctx){ var b=sr(this,x,y,w,h); b.c=String(this.fillStyle); rec.rects.push(b); } return oR.apply(this,arguments); };
       PR.fillText=function(s,x,y){ if(rec&&this===ctx){ var m=this.measureText(s), l=m.actualBoundingBoxLeft||0, r=m.actualBoundingBoxRight||0, a=m.actualBoundingBoxAscent||0, dd=m.actualBoundingBoxDescent||0, b=sr(this,x-l,y-a,l+r,a+dd); b.s=String(s).toLowerCase(); b.px=fpx(this,this.font); b.c=String(this.fillStyle); rec.texts.push(b); } return oT.apply(this,arguments); };
     }
     function unhook(){ var r=rec; rec=null; hudPanel=oPanel; bar=oBar; hudKey=oKey; PR.fillRect=oR; PR.fillText=oT; padOn=oPad; return r; }
     function netBack(){ var k; if(!nsv) return; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; if(nsp) netSamePost=nsp; }
     function down(){ unhook(); try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) arcadeLeave(); }catch(_l){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.over=null; ARCADE.ini=null; } }catch(_a){} netBack(); try{ __topClear(); }catch(_t){} }
     function stage(md,sz){
       var g, p, i;
       down();
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1);
       if(typeof PAD==='object'&&PAD) PAD.on=false;
       P.hud={}; _legBase=null; _legAnchorY=null;   // no drag or zoom of his on any panel, and no list rect left over from the other screen size (its clamp would move the chip)
       __forceSize(sz[0],sz[1]);
       if(md==='career'){
         __deploy({kit:['gun_carbine'],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||g.over||!g.player) return null;
         g.career=1; g.arcade=0;
       } else {
         ARCADE.ini=null; ARCADE.over=null;
         if(md==='second window'){ NET.on=false; NET.role=''; NET.same='p2'; }
         if(!arcadeDeploy(md==='second window'?{role:'p2',mapIx:0,seed:4242}:{mapIx:0,seed:4242})) return null;
         try{ attStop(); }catch(_as){}
         g=__state(); if(!g||g.over||!g.arcade||!g.player) return null;
         ARCADE.over=null; ARCADE.ini=null; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
         if(md==='second window'){
           ARCADE.role='p2'; NET.on=true; NET.role='join'; NET.same='p2'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.up=[]; NET.peers=[]; NET.upOut={};
           NET.bc={postMessage:function(){},close:function(){}}; NET.pair='tp'; netSamePost=function(){ return true; };
         } else ARCADE.role='host';
       }
       g.legendAutoDone=true; g.legendOn=0; g.bagOpen=false; g.mapOpen=false; keys={};
       p=g.player;
       for(i=0;i<12;i++){ if(p.wep&&p.wep.mag>0){ p.ammo=p.wep.mag; p.reloading=0; p.jam=0; } __frame(0.016); if(!__state()||__state().over) return null; }
       return g;
     }
     function frame(g){ var p=g.player, q; if(p.wep&&p.wep.mag>0){ p.ammo=p.wep.mag; p.reloading=0; p.jam=0; } hook(); try{ __frame(0.016); } finally { q=unhook(); } return q; }
     function vitals(r){ var v=[], i, b; for(i=0;i<r.bars.length;i++){ b=r.bars[i]; if(b.x<W*0.3&&b.y>H*0.6) v.push(b); } for(i=0;i<r.panels.length;i++){ b=r.panels[i]; if(b.pl&&b.x<W*0.03&&b.y>H*0.75) v.push(b); } return v; }
     function capStrip(r){ var i, b; for(i=0;i<r.rects.length;i++){ b=r.rects[i]; if(b.c==='rgba(17, 19, 21, 0.72)'&&Math.abs(b.x+b.w/2-W/2)<=2&&b.y>H*0.7) return b; } return null; }
     function cardOf(r){ var i, b, c=null, z=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'); for(i=0;i<r.panels.length;i++){ b=r.panels[i]; if(b.a===0.88&&Math.abs(b.x+b.w-(W-8))<=3*z&&b.y+b.h>H*0.8&&b.x>W*0.6&&(!c||b.y+b.h>c.y+c.h)) c=b; } return c; }
     function mw(f,s){ var w; ctx.save(); try{ ctx.font=f; w=ctx.measureText(String(s)).width; } finally { ctx.restore(); } return w; }
     function wide(f,s){ var q, w, b=-1, d='0'; for(q=0;q<10;q++){ w=mw(f,String(q)); if(w>b){ b=w; d=String(q); } } return String(s).replace(/[0-9]/g,d); }
     // the widest each row of the card can read with this gun in hand (card units): the name with its aim word, the rounds as a full
     // magazine over a reserve of three figures in the widest digit, or RELOADING; in career the backpack row with two item and five money figures
     function room(g){
       var p=g.player, w=p.wep, ft=FS(TYPE.title), fm=FS(TYPE.num), ff=hudFineFS(), fl=FS(TYPE.label), o=+w.optic||0, n, r, f=0, cv=0, i;
       n=Math.max(mw(fl,w.name+'  [ADS]'),o>1?mw(fl,w.name+'  '+(+o.toFixed(2))+'x SCOPE'):0);
       r=Math.max(mw(ft,' / '+wide(ft,Math.max(100,rsvShow(p)|0)))+4+mw(fm,wide(fm,Math.max(w.mag|0,p.ammo|0))),mw(ft,'RELOADING'),mw(ft,'JAMMED'));
       if(!trDemo()){ for(i=0;i<G.bag.length;i++) cv+=ival(G.bag[i]); f=mw(ff,keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK')+LH(16)+mw(ff,wide(ff,Math.max(10,G.bag.length))+' ITEMS  $'+wide(ff,Math.max(10000,cv).toLocaleString())); }
       return Math.max(n,r,f);
     }
     // 5. the card keeps one size and place while he plays: every gun, a shot, one round left, empty, reloading, aiming (and aiming
     // while reloading), a reserve of 999, 99, 9 and 0, and in career loot going in the backpack; its words stay inside it in every state
     function steady(g,tag){
       var p=g.player, s0={wep:p.wep,ammo:p.ammo,reserve:p.reserve,reloading:p.reloading,ads:p.ads,jam:p.jam}, bag0=G.bag.slice(), ids=[], id, i, j, w, c0, c, r, st, T, top=null, tv=0, nb;
       function setBag(a){ G.bag.length=0; for(var q=0;q<a.length;q++) G.bag.push(a[q]); }
       function shot(o){ var q, t, k, hp; p.ammo=o.a; p.reserve=o.v; p.reloading=o.rl?1:0; p.ads=!!o.ads; p.jam=0; if(o.bag) setBag(o.bag); hook(); try{ __frame(0.016); } finally { q=unhook(); } c=cardOf(q); hp=LH(8)*(HUDZ.gear||1)*hudRes()*hudUserZ('gear')*0.5;
         if(c) for(k=0;k<q.texts.length;k++){ t=q.texts[k]; if(t.w>0&&t.x+t.w/2>c.x&&t.x+t.w/2<c.x+c.w&&t.y+t.h/2>c.y&&t.y+t.h/2<c.y+c.h&&(t.x<c.x+hp-0.5||t.x+t.w>c.x+c.w+0.5||t.y<c.y-0.5||t.y+t.h>c.y+c.h+0.5)) return '"'+t.s+'" is squeezed to or over the edge of the gun card '+R(c)+' at '+R(t); }
         return null; }
       for(id in WEAPONS) if(Object.prototype.hasOwnProperty.call(WEAPONS,id)&&WEAPONS[id].mag>0&&!ids.some(function(q){ return WEAPONS[q].name===WEAPONS[id].name; })) ids.push(id);
       try{
         for(i=0;i<ids.length;i++){
           w=(typeof arcadeGun==='function')?arcadeGun(ids[i]):WEAPONS[ids[i]]; p.wep=w;
           st=[{n:'full',a:w.mag,v:6*w.mag},{n:'one shot fired',a:w.mag-1,v:6*w.mag},{n:'one round left',a:1,v:6*w.mag},{n:'empty',a:0,v:6*w.mag},{n:'reloading',a:0,v:6*w.mag,rl:1},{n:'aiming',a:w.mag,v:6*w.mag,ads:1},{n:'aiming and reloading',a:0,v:6*w.mag,rl:1,ads:1},{n:'reserve 999',a:w.mag,v:999},{n:'reserve 99',a:w.mag,v:99},{n:'reserve 9',a:w.mag,v:9},{n:'reserve 0',a:w.mag,v:0}];
           c0=null;
           for(j=0;j<st.length;j++){
             T=shot(st[j]);
             if(!c){ bad.push(tag+'no gun card with the '+w.name+' '+st[j].n); break; }
             if(T){ bad.push(tag+'with the '+w.name+' '+st[j].n+': '+T); break; }
             if(!c0){ c0=c; continue; }
             if(Math.abs(c.x-c0.x)>0.5||Math.abs(c.y-c0.y)>0.5||Math.abs(c.w-c0.w)>0.5||Math.abs(c.h-c0.h)>0.5){ bad.push(tag+'the gun card moves with the '+w.name+' '+st[j].n+': '+R(c)+', full it is '+R(c0)); break; }
           }
         }
         if(!g.arcade){   // career: loot going in the backpack
           p.wep=s0.wep;
           for(id in ITEMS) if(Object.prototype.hasOwnProperty.call(ITEMS,id)&&ival(id)>0&&ival(id)<5000&&(!top||ival(id)>ival(top))) top=id;
           nb=top?Math.ceil(20000/ival(top)):0;
           st=[{n:'an empty backpack',a:p.wep.mag,v:6*p.wep.mag,bag:[]},{n:'one item in the backpack',a:p.wep.mag,v:6*p.wep.mag,bag:['bandage']},{n:'twelve items in the backpack',a:p.wep.mag,v:6*p.wep.mag,bag:['bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage']}];
           if(top&&nb<100){ st.push({n:nb+' items worth about $20,000 in the backpack',a:p.wep.mag,v:6*p.wep.mag,bag:Array.apply(null,Array(nb)).map(function(){ return top; })}); }
           c0=null;
           for(j=0;j<st.length;j++){
             T=shot(st[j]);
             if(!c){ bad.push(tag+'no gun card with '+st[j].n); break; }
             if(T){ bad.push(tag+'with '+st[j].n+': '+T); break; }
             if(!c0){ c0=c; continue; }
             if(Math.abs(c.x-c0.x)>0.5||Math.abs(c.y-c0.y)>0.5||Math.abs(c.w-c0.w)>0.5||Math.abs(c.h-c0.h)>0.5){ bad.push(tag+'the gun card moves with '+st[j].n+': '+R(c)+', with an empty backpack it is '+R(c0)); break; }
           }
         }
       } finally { p.wep=s0.wep; p.ammo=s0.ammo; p.reserve=s0.reserve; p.reloading=s0.reloading; p.ads=s0.ads; p.jam=s0.jam; setBag(bag0); }
     }
     // a bandage in use for one drawn frame: the use bar plate as drawn (a plain 0.88 panel centred on the screen, over the caption) and the list in that frame
     function useOn(g,cs){
       var p=g.player, q, u=null, i, b, L1=null;
       p.prep={kind:'heal',key:'bandage',t:0.5,max:3};
       try{ hook(); try{ __frame(0.016); } finally { q=unhook(); } }
       finally { p.prep=null; }
       for(i=0;i<q.panels.length;i++){ b=q.panels[i]; if(b.pl&&b.a===0.88&&Math.abs(b.x+b.w/2-W/2)<=3&&b.y>H*0.4&&(!cs||b.y+b.h<=cs.y+1)&&(!u||b.y+b.h>u.y+u.h)) u=b; }
       if(HUDBOX.legend) L1={x:HUDBOX.legend.x,y:HUDBOX.legend.y,w:HUDBOX.legend.w,h:HUDBOX.legend.h};
       return {u:u,L:L1,r:q};
     }
     // a bandage and a plate at once (v11.82), the first two drawn frames: drawUseBar stacks the plate bar one step up. Each use bar plate
     // is found by its words (applying ..., slotting ...) on a plain 0.88 panel centred on the screen; the list must clear both in both frames
     function useBoth(g){
       var p=g.player, F=[], k, q, i, j, b, t, u;
       p.prep={kind:'heal',key:'bandage',t:0.5,max:3}; p.prepA={kind:'armor',key:'plate',t:0.5,max:2};
       try{
         for(k=0;k<2;k++){
           hook(); try{ __frame(0.016); } finally { q=unhook(); }
           u=[];
           for(i=0;i<q.panels.length;i++){ b=q.panels[i]; if(!(b.pl&&b.a===0.88&&Math.abs(b.x+b.w/2-W/2)<=3)) continue;
             for(j=0;j<q.texts.length;j++){ t=q.texts[j]; if(/^(applying|slotting) /.test(t.s)&&t.x+t.w/2>b.x&&t.x+t.w/2<b.x+b.w&&t.y+t.h/2>b.y&&t.y+t.h/2<b.y+b.h){ u.push({x:b.x,y:b.y,w:b.w,h:b.h,s:t.s}); break; } } }
           F.push({u:u,L:lbox()});
         }
       } finally { p.prep=null; p.prepA=null; }
       return F;
     }
     function bothOk(g,tg,wh){
       var F=useBoth(g), k, i, f, n, e0=bad.length;
       for(k=0;k<F.length&&bad.length===e0;k++){
         f=F[k];
         n=f.u.filter(function(q){ return /^applying /.test(q.s); }).length+'/'+f.u.filter(function(q){ return /^slotting /.test(q.s); }).length;
         if(n!=='1/1'){ bad.push(tg+wh+'with a bandage and a plate in use frame '+(k+1)+' drew '+n+' bandage/plate use bars, not 1/1'); break; }
         if(!f.L||!(f.L.w>0)){ bad.push(tg+wh+'with a bandage and a plate in use the opened list did not draw'); break; }
         for(i=0;i<f.u.length;i++) if(hit(f.L,f.u[i])) bad.push(tg+wh+'with a bandage and a plate in use the opened list '+R(f.L)+' covers the '+(/^slotting /.test(f.u[i].s)?'plate':'bandage')+' use bar '+R(f.u[i])+' in frame '+(k+1));
         if(f.L.y<0) bad.push(tg+wh+'with a bandage and a plate in use the opened list '+R(f.L)+' runs off the top of the screen');
       }
       if(bad.length===e0&&!same(F[0].L,F[1].L)) bad.push(tg+wh+'when a plate goes on over a bandage the opened list flashes to '+R(F[0].L)+' for a frame before it stands at '+R(F[1].L));   // it lands on its new place in the first frame
       return F;
     }
     // the v27.26 rule: the list ends before 47 percent of the width (the player stands in the middle); where the feed and the medal spot leave
     // no such room (its rows are 16 px whatever the zoom), it stands right against them and still ends short of the middle
     function wideOk(L,tg){ var rs=Math.max(1,hudRes()), lx=Math.max((FEEDBOX&&FEEDBOX.on&&FEEDBOX.w>0)?FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*rs):0,(MEDALBOX&&MEDALBOX.on&&MEDALBOX.w>0)?MEDALBOX.x+MEDALBOX.w+Math.round(LH(10)*rs):0);
       if(L.x+L.w<=W*0.47+0.5) return;
       if(L.x+L.w>W*0.5) bad.push(tg+'the opened list '+R(L)+' reaches past the middle of the screen ('+Math.round(W*0.5)+')');
       else if(L.x>lx+1.5) bad.push(tg+'the opened list '+R(L)+' runs past 47 percent of the width ('+Math.round(W*0.47)+') although it could stand further left (the feed and medal spot end at '+Math.round(lx)+')'); }
     // where the list may end: on the chip row, or on the top of the use bar plate when it stands over the plate columns
     function lowEnd(L,ch,u,rs){ var lo=ch.y-LH(16)*rs; if(u&&L.x<u.x+u.w&&L.x+L.w>u.x-LH(6)*rs) lo=Math.min(lo,u.y-LH(16)*rs); return lo; }
     function clearOf(n,box,r,tag){
       var i, v=vitals(r), cs=capStrip(r), hc=G.hotCells||[];
       if(FEEDBOX&&FEEDBOX.on&&hit(box,FEEDBOX)) bad.push(tag+n+' '+R(box)+' is over the feed '+R(FEEDBOX));
       if(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on&&hit(box,MEDALBOX)) bad.push(tag+n+' '+R(box)+' is over the medal spot '+R(MEDALBOX));
       if(cs&&hit(box,cs)) bad.push(tag+n+' '+R(box)+' is over the belt caption '+R(cs));
       for(i=0;i<hc.length;i++) if(hit(box,hc[i])){ bad.push(tag+n+' '+R(box)+' is over belt key '+(i+1)); break; }
       for(i=0;i<v.length;i++) if(hit(box,v[i])){ bad.push(tag+n+' '+R(box)+' is over the vitals '+R(v[i])); break; }
       if(!v.length) bad.push(tag+'no vitals were drawn');
       if(box.x<0||box.y<0||box.x+box.w>W+0.5||box.y+box.h>H+0.5) bad.push(tag+n+' '+R(box)+' is off the screen');
     }
     try{
       say=function(){}; P.runs=0;
       nsv={}; for(var k0 in NET) if(Object.prototype.hasOwnProperty.call(NET,k0)) nsv[k0]=NET[k0];
       for(si=0;si<SZ.length;si++) for(mi=0;mi<MD.length;mi++){
         var tag=MD[mi]+' '+SZ[si][2]+': ', g=stage(MD[mi],SZ[si]), r, cz, card=null, i, b, T=[], U=null, ub3=null, pad, P0, z, nm, chip, cs, ct, cc, kf, kc, c0, rs, L, gap, need, L3;
         if(!g){ bad.push(tag+'could not stage the raid'); continue; }
         if(W!==SZ[si][0]||H!==SZ[si][1]){ bad.push(tag+'the screen is '+W+'x'+H); continue; }
         if(!g.player.wep||!(g.player.wep.mag>0)){ bad.push(tag+'no gun with a magazine in hand'); continue; }
         r=frame(g);
         // 1. the gun card
         z=(HUDZ.gear||1)*hudRes()*hudUserZ('gear');
         card=cardOf(r);
         if(!card) bad.push(tag+'no gun card in the lower right');
         else {
           if(!card.pl) bad.push(tag+'the gun card is drawn with the lime tab');
           for(i=0;i<r.rects.length;i++){ b=r.rects[i]; if(b.c==='#e6ff3d'&&hit(b,{x:card.x-2,y:card.y-2,w:card.w+4,h:card.h+4})){ bad.push(tag+'a lime stub is drawn on the gun card at '+R(b)); break; } }
           for(i=0;i<r.texts.length;i++){ b=r.texts[i]; if(b.w>0&&b.x+b.w/2>card.x&&b.x+b.w/2<card.x+card.w&&b.y+b.h/2>card.y&&b.y+b.h/2<card.y+card.h) T.push(b); }
           need=[['the gun name',function(q){ return q.y+q.h<card.y+card.h*0.5; }],['the rounds',function(q){ return q.s===String(g.player.ammo); }],['the reserve',function(q){ return /^ \/ /.test(q.s); }]];
           if(!g.arcade) need.push(['the item count',function(q){ return /item/.test(q.s); }],['the backpack key',function(q){ return /backpack/.test(q.s); }]);
           for(i=0;i<need.length;i++) if(!T.some(need[i][1])) bad.push(tag+need[i][0]+' is not on the gun card');
           for(i=0;i<T.length;i++){ b=T[i]; if(b.x<card.x-0.5||b.y<card.y-0.5||b.x+b.w>card.x+card.w+0.5||b.y+b.h>card.y+card.h+0.5) bad.push(tag+'"'+b.s+'" runs over the edge of the gun card'); U=U?{x:Math.min(U.x,b.x),y:Math.min(U.y,b.y),r:Math.max(U.r,b.x+b.w),b:Math.max(U.b,b.y+b.h)}:{x:b.x,y:b.y,r:b.x+b.w,b:b.y+b.h}; }
           if(U){
             U.x=Math.min(U.x,U.r-room(g)*z);   // the room each row keeps for its other states is content too
             pad=[U.x-card.x,U.y-card.y,card.x+card.w-U.r,card.y+card.h-U.b]; P0=LH(8)*z;
             if(Math.max.apply(null,pad)>P0*1.6||Math.min.apply(null,pad)<P0*0.5||Math.max.apply(null,pad)>Math.min.apply(null,pad)*2) bad.push(tag+'the gun card padding is not even: left '+Math.round(pad[0])+' top '+Math.round(pad[1])+' right '+Math.round(pad[2])+' bottom '+Math.round(pad[3])+' (card '+R(card)+', one padding is about '+Math.round(P0)+')');
           }
         }
         // 2. the folded chip
         chip=(typeof LEGHINT!=='undefined'&&LEGHINT)?{x:LEGHINT.x,y:LEGHINT.y,w:LEGHINT.w,h:LEGHINT.h}:null; cs=capStrip(r); c0=(G.hotCells&&G.hotCells[0])||null; rs=Math.max(1,hudRes());
         if(!chip) bad.push(tag+'the folded chip did not draw');
         else if(!cs||!c0) bad.push(tag+'no belt caption or belt this frame');
         else {
           if(!r.rects.some(function(q){ return q.c===cs.c&&Math.abs(q.x-chip.x)<=1&&Math.abs(q.y-chip.y)<=1&&Math.abs(q.w-chip.w)<=1&&Math.abs(q.h-chip.h)<=1; })) bad.push(tag+'the folded chip '+R(chip)+' is not drawn on a belt caption strip');
           if(Math.abs(chip.y-cs.y)>1||Math.abs(chip.h-cs.h)>1) bad.push(tag+'the folded chip '+R(chip)+' is not on the belt caption row '+R(cs));
           ct=r.texts.filter(function(q){ return /controls$/.test(q.s)&&q.x+q.w/2>chip.x&&q.x+q.w/2<chip.x+chip.w&&q.y+q.h/2>chip.y&&q.y+q.h/2<chip.y+chip.h; })[0];
           cc=r.texts.filter(function(q){ return /use$/.test(q.s)&&q.x+q.w/2>cs.x&&q.x+q.w/2<cs.x+cs.w&&q.y+q.h/2>cs.y&&q.y+q.h/2<cs.y+cs.h; })[0];
           if(!ct||!cc) bad.push(tag+'the chip words or the caption words were not drawn');
           else if(Math.abs(ct.px-cc.px)>0.05||ct.c!==cc.c) bad.push(tag+'the chip words are '+Math.round(ct.px*10)/10+'px '+ct.c+', the caption words '+Math.round(cc.px*10)/10+'px '+cc.c);
           kf=r.keys.filter(function(q){ return /^f1$/.test(q.l)&&q.x>=chip.x-1&&q.x+q.w<=chip.x+chip.w+1&&q.y>=chip.y-1&&q.y+q.h<=chip.y+chip.h+1; })[0]; kc=r.keys.filter(function(q){ return q.x>=cs.x&&q.x<=cs.x+cs.w&&q.y>=cs.y-1&&q.y+q.h<=cs.y+cs.h+1; })[0];
           if(!kf) bad.push(tag+'f1 is not a key cap on the chip');
           else if(kc&&kf.fill!==kc.fill) bad.push(tag+'the f1 cap is '+kf.fill+', the caption caps '+kc.fill);
           gap=c0.x-LH(4)-(chip.x+chip.w);
           if(gap<LH(4)*rs||gap>LH(16)*rs) bad.push(tag+'the folded chip '+R(chip)+' is not docked just left of belt key 1 at '+Math.round(c0.x)+' (gap past the belt plate '+Math.round(gap)+')');
           clearOf('the folded chip',chip,r,tag);
         }
         // 3. F1 opens the list upward from the chip
         g.legendOn=1; for(i=0;i<12;i++) __frame(0.016);
         r=frame(g); L=HUDBOX.legend; L=L?{x:L.x,y:L.y,w:L.w,h:L.h}:null;
         if(!L||!(L.w>0)) bad.push(tag+'the opened list did not draw');
         else if(chip){
           ub3=useOn(g,cs);
           if(!ub3.u) bad.push(tag+'no use bar plate drew with a bandage in use');
           else {
             if(hit(ub3.L,ub3.u)) bad.push(tag+'with a bandage in use the opened list '+R(ub3.L)+' covers the use bar '+R(ub3.u));
             if(!ub3.L||Math.abs(ub3.L.x-L.x)>0.5||Math.abs(ub3.L.y-L.y)>0.5||Math.abs(ub3.L.w-L.w)>0.5||Math.abs(ub3.L.h-L.h)>0.5) bad.push(tag+'the opened list moves when a bandage goes on: '+R(ub3.L)+', before '+R(L));
           }
           bothOk(g,tag,'');   // a bandage and a plate at once: the plate bar stacks a step up, the list clears both
           __frame(0.016); L3=lbox();
           if(!same(L3,L)) bad.push(tag+'the opened list is not back in its place in the first frame after the bandage and the plate are done: '+R(L3)+', before '+R(L));
           wideOk(L,tag);
           if(L.x<chip.x-2||L.x>chip.x+chip.w) bad.push(tag+'the opened list '+R(L)+' does not start on the chip '+R(chip));
           if(L.y+L.h>chip.y+chip.h+2||L.y+L.h<lowEnd(L,chip,ub3.u,rs)) bad.push(tag+'the opened list '+R(L)+' does not end on the chip row '+R(chip)+' or on the use bar '+R(ub3.u));
           if(c0&&L.y+L.h>c0.y-LH(4)+0.5) bad.push(tag+'the opened list '+R(L)+' runs down over the belt plate');
           clearOf('the opened list',L,r,tag);
           if(MD[mi]!=='second window'&&typeof pwrS==='function'){   // four power up timers: the chip row over the belt
             var S5=pwrS(), a5=S5.act, L5, C5, L51, L52;
             S5.act={clip:15,dmg:12,rapid:12,shield:8};
             try{ for(i=0;i<4;i++){ __frame(0.016); if(!i) L51=lbox(); } C5=EDGEBOX.chips?{x:EDGEBOX.chips.x,y:EDGEBOX.chips.y,w:EDGEBOX.chips.w,h:EDGEBOX.chips.h}:null; L5=lbox(); }
             finally { S5.act=a5||{}; }
             if(!C5) bad.push(tag+'no power up timer chips drew with four running');
             else if(hit(L5,C5)) bad.push(tag+'with four power ups running the opened list '+R(L5)+' covers the timer chips '+R(C5));
             if(C5&&hit(L51,C5)) bad.push(tag+'in the first frame of four power ups the opened list '+R(L51)+' covers the timer chips '+R(C5));
             for(i=0;i<4;i++){ __frame(0.016); if(!i) L52=lbox(); }
             if(!same(L52,L)) bad.push(tag+'the opened list is not back in its place in the first frame after the power ups end: '+R(L52)+', before '+R(L));
           }
           // the ship called (the list folds once, F1 opens it again): the use bar goes up over the countdown, and the list stays clear of both
           var bt5=g.beaconT, U5, X5, S6=[], E6=[];
           g.legendExtDone=true; g.beaconT=40;
           try{ for(i=0;i<6;i++){ g.legendOn=1; __frame(0.016); S6.push(lbox()); } U5=useOn(g,null); bothOk(g,tag,'with the ship called, '); }
           finally { g.beaconT=bt5; }
           X5=U5.r.texts.filter(function(q){ return /inbound/.test(q.s); })[0];
           if(!U5.u) bad.push(tag+'no use bar plate drew with the ship called');
           else if(hit(U5.L,U5.u)) bad.push(tag+'with the ship called the opened list '+R(U5.L)+' covers the use bar '+R(U5.u));
           if(!X5) bad.push(tag+'no extract countdown drew with the ship called');
           else if(hit(U5.L,X5)) bad.push(tag+'with the ship called the opened list '+R(U5.L)+' covers the countdown "'+X5.s+'" '+R(X5));
           for(i=0;i<6;i++){ g.legendOn=1; __frame(0.016); E6.push(lbox()); }
           if(!same(S6[0],S6[5])) bad.push(tag+'when the ship is called the opened list flashes to '+R(S6[0])+' for a frame before it stands at '+R(S6[5]));   // it lands on its new place in the first frame
           if(!same(E6[0],E6[5])) bad.push(tag+'when the ship call ends the opened list flashes to '+R(E6[0])+' for a frame before it stands at '+R(E6[5]));
         }
         g.legendOn=0; for(i=0;i<6;i++) __frame(0.016);
         // 4. a pad shows no chip
         hook(); padOn=function(){ return true; }; try{ __frame(0.016); } finally { r=unhook(); }
         if(typeof LEGHINT!=='undefined'&&LEGHINT) bad.push(tag+'the folded chip draws on a pad');
         if(r.texts.some(function(q){ return /f1\s+controls$/.test(q.s); })) bad.push(tag+'the f1 controls words draw on a pad');
         // 5. one size and place while he plays (career and the demo; the second window draws the same card)
         if(MD[mi]!=='second window') steady(g,tag);
         done++;
       }
       // 6. a short screen (the party type is bigger, so in the demo the belt spot is beside the armour and stamina bars): the chip and the
       // opened list still keep off the vitals, the feed, the medals, the caption, the belt keys, the belt plate and the use bar, the list
       // ends before 47 percent of the width (the player stands in the middle), and it grows up from the chip where the chip leaves it room
       var SH=[[1280,720,'720'],[1366,768,'768'],[1600,900,'900']], MS=['career','demo'], sj, mj;
       for(sj=0;sj<SH.length;sj++) for(mj=0;mj<MS.length;mj++){
         var tg=MS[mj]+' '+SH[sj][2]+': ', g2=stage(MS[mj],SH[sj]), r2, ch2, L2, k2, q2, ub6;
         if(!g2){ bad.push(tg+'could not stage the raid'); continue; }
         if(W!==SH[sj][0]||H!==SH[sj][1]){ bad.push(tg+'the screen is '+W+'x'+H); continue; }
         r2=frame(g2); ch2=(typeof LEGHINT!=='undefined'&&LEGHINT)?{x:LEGHINT.x,y:LEGHINT.y,w:LEGHINT.w,h:LEGHINT.h}:null; k2=(G.hotCells&&G.hotCells[0])||null; q2=k2?{x:k2.x-LH(4),y:k2.y-LH(4),w:W,h:H}:null;
         if(!ch2) bad.push(tg+'the folded chip did not draw');
         else { clearOf('the folded chip',ch2,r2,tg); if(hit(ch2,q2)) bad.push(tg+'the folded chip '+R(ch2)+' runs over the belt plate'); }
         g2.legendOn=1; for(i=0;i<12;i++) __frame(0.016);
         r2=frame(g2); L2=HUDBOX.legend; L2=L2?{x:L2.x,y:L2.y,w:L2.w,h:L2.h}:null;
         if(!L2||!(L2.w>0)) bad.push(tg+'the opened list did not draw');
         else {
           clearOf('the opened list',L2,r2,tg); if(hit(L2,q2)) bad.push(tg+'the opened list '+R(L2)+' runs down over the belt plate');
           wideOk(L2,tg);
           ub6=useOn(g2,capStrip(r2));
           if(!ub6.u) bad.push(tg+'no use bar plate drew with a bandage in use');
           else if(hit(ub6.L,ub6.u)) bad.push(tg+'with a bandage in use the opened list '+R(ub6.L)+' covers the use bar '+R(ub6.u));
           bothOk(g2,tg,'');   // a bandage and a plate at once
           if(ch2&&ch2.x+L2.w<=W*0.47&&(L2.x<ch2.x-2||L2.x>ch2.x+ch2.w||L2.y+L2.h>ch2.y+ch2.h+2||L2.y+L2.h<lowEnd(L2,ch2,ub6.u,Math.max(1,hudRes())))) bad.push(tg+'the opened list '+R(L2)+' does not grow up from the chip '+R(ch2));
         }
         g2.legendOn=0; done++;
       }
       if(!done) return 'SKIP: no raid could be staged';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ down(); say=oSay; P.runs=r0; try{ if(hud0===undefined) delete P.hud; else P.hud=JSON.parse(hud0); _legBase=null; _legAnchorY=null; __runPrep(); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null;
   }},
  {v:'34.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
