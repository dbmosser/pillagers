/* 112 mockup A, quiet: every HUD widget is Panel P (style-guide Components): one fill, one 1px line-hi border, one 4px radius.
   Tags and the left log rows are the same panel at chip height. One type scale (micro joins label). Draw-only, fixture copy only. */
(function(){
  var LINE='rgba(74,82,87,.95)', FILL='rgba(22,25,27,.90)';
  function RR(x,y,w,h,r){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x,y,w,h,r); else ctx.rect(x,y,w,h); }
  function P(x,y,w,h,fill){
    ctx.save(); RR(x,y,w,h,4); ctx.fillStyle=fill||FILL; ctx.fill();
    RR(x+.5,y+.5,w-1,h-1,3.5); ctx.strokeStyle=LINE; ctx.lineWidth=1; ctx.stroke(); ctx.restore();
  }
  window.hudPanel=function(x,y,w,h,a,plain){
    if(!(w>0&&h>0)) return;
    P(x,y,w,h,(a!==undefined&&a>0.95)?'rgba(22,25,27,1)':FILL);
    if(!plain&&w>40){ ctx.save(); ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+16,y,36,2); ctx.restore(); }
  };
  window.hudPlate=function(x,y,w,h,accent,fill){
    if(!(w>0&&h>0)) return;
    var std=(!fill||fill===HUDC.plate||fill===UIC.ui_panel);
    if(fill===UIC.acc){ ctx.save(); RR(x,y,w,h,4); ctx.fillStyle=fill; ctx.fill(); ctx.restore(); return; }
    P(x,y,w,h,std?FILL:fill);
    if(accent){ ctx.save(); ctx.fillStyle=accent; ctx.fillRect(x+1,y+4,3,Math.max(2,h-8)); ctx.restore(); }
  };
  trPlate=function(x,y,w,h){ P(x,y,w,h,FILL); };   // the cash block's own plate
  TYPE.micro=TYPE.label; TYPE.body=TYPE.label;
})();
