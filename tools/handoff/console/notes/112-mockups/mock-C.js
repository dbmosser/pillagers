/* 112 mockup C, one rail: widgets in the same corner join into ONE Panel P (top right: cash block + run info + minimap;
   top left: pillager board; left log: every feed row) with one shared fill, border and padding. Members draw only a hairline divider
   (widgets) or their colour bar (log rows). The rail is the union of last frame's member rects. Everything else is Panel P.
   One type scale (micro joins label). Draw-only, fixture copy only. */
(function(){
  var LINE='rgba(74,82,87,.95)', FILL='rgba(22,25,27,.90)', PADR=8, rf=0, R={};
  (function tick(){ rf++; requestAnimationFrame(tick); })();
  function RR(x,y,w,h,r){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x,y,w,h,r); else ctx.rect(x,y,w,h); }
  function P(x,y,w,h,fill){
    ctx.save(); RR(x,y,w,h,4); ctx.fillStyle=fill||FILL; ctx.fill();
    RR(x+.5,y+.5,w-1,h-1,3.5); ctx.strokeStyle=LINE; ctx.lineWidth=1; ctx.stroke(); ctx.restore();
  }
  function grp(x,y,w,h){
    if(x>W*0.78&&y<H*0.30) return 'tr';
    if(x<W*0.22&&y<H*0.30&&y>H*0.08) return 'tl';
    if(x<W*0.24&&y>H*0.55&&y+h<H*0.85&&h<LH(46)) return 'log';
    return null;
  }
  // returns true when the rect was absorbed by a rail (the caller then draws only its own bar)
  function join(g,x,y,w,h){
    var r=R[g]; if(!r) r=R[g]={f:-1,cur:[],prev:[],drawn:-1};
    if(r.f!==rf){ r.prev=r.cur; r.cur=[]; r.f=rf; }
    r.cur.push([x,y,w,h]);
    if(!r.prev.length) return false;
    if(r.drawn!==rf){
      r.drawn=rf; var x0=1e9,y0=1e9,x1=-1e9,y1=-1e9;
      r.prev.forEach(function(q){ x0=Math.min(x0,q[0]); y0=Math.min(y0,q[1]); x1=Math.max(x1,q[0]+q[2]); y1=Math.max(y1,q[1]+q[3]); });
      P(x0-PADR,y0-PADR,x1-x0+PADR*2,y1-y0+PADR*2,FILL);
      if(g!=='log'){ ctx.save(); ctx.strokeStyle=LINE; ctx.lineWidth=1; ctx.beginPath();
        r.prev.forEach(function(q){ if(q[1]>y0+4){ ctx.moveTo(q[0]+4,Math.round(q[1]-PADR/2)+.5); ctx.lineTo(q[0]+q[2]-4,Math.round(q[1]-PADR/2)+.5); } });
        ctx.stroke(); ctx.restore(); }
    }
    return true;
  }
  window.hudPanel=function(x,y,w,h,a,plain){
    if(!(w>0&&h>0)) return;
    var g=grp(x,y,w,h);
    if(g&&join(g,x,y,w,h)) return;
    P(x,y,w,h,FILL);
    if(!plain&&w>40){ ctx.save(); ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+16,y,36,2); ctx.restore(); }
  };
  window.hudPlate=function(x,y,w,h,accent,fill){
    if(!(w>0&&h>0)) return;
    if(fill===UIC.acc){ ctx.save(); RR(x,y,w,h,4); ctx.fillStyle=fill; ctx.fill(); ctx.restore(); return; }
    var std=(!fill||fill===HUDC.plate||fill===UIC.ui_panel), g=std?grp(x,y,w,h):null;
    if(!(g&&join(g,x,y,w,h))) P(x,y,w,h,std?FILL:fill);
    if(accent){ ctx.save(); ctx.fillStyle=accent; ctx.fillRect(x+1,y+4,3,Math.max(2,h-8)); ctx.restore(); }
  };
  trPlate=function(x,y,w,h){ if(!join('tr',x,y,w,h)) P(x,y,w,h,FILL); };   // the cash block's own plate joins the top right rail
  TYPE.micro=TYPE.label; TYPE.body=TYPE.label;
})();
