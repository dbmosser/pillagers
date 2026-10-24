/* 112 mockup B, bare: no panel behind the low-priority widgets (run info, cash block, board, left log, hint strip, legend, tags):
   text on a soft feathered shadow only. Panel P stays for the hero (ammo card, vitals, hotbar) and for danger and extraction plates.
   One type scale (micro joins label). Draw-only, fixture copy only. */
(function(){
  var LINE='rgba(74,82,87,.95)', FILL='rgba(22,25,27,.90)';
  function RR(x,y,w,h,r){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x,y,w,h,r); else ctx.rect(x,y,w,h); }
  function P(x,y,w,h,fill){
    ctx.save(); RR(x,y,w,h,4); ctx.fillStyle=fill||FILL; ctx.fill();
    RR(x+.5,y+.5,w-1,h-1,3.5); ctx.strokeStyle=LINE; ctx.lineWidth=1; ctx.stroke(); ctx.restore();
  }
  function bare(x,y,w,h){
    ctx.save(); ctx.shadowColor='rgba(0,0,0,.75)'; ctx.shadowBlur=20; ctx.fillStyle='rgba(0,0,0,.34)';
    ctx.fillRect(x+6,y+4,w-12,h-8); ctx.fillRect(x+6,y+4,w-12,h-8); ctx.restore();
  }
  function hero(x,y,w,h){ return y>H*0.78&&h>=LH(30); }
  window.hudPanel=function(x,y,w,h,a,plain){
    if(!(w>0&&h>0)) return;
    if(hero(x,y,w,h)||!plain){ P(x,y,w,h,FILL); if(!plain&&w>40){ ctx.save(); ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+16,y,36,2); ctx.restore(); } }
    else bare(x,y,w,h);
  };
  window.hudPlate=function(x,y,w,h,accent,fill){
    if(!(w>0&&h>0)) return;
    if(fill===UIC.acc){ ctx.save(); RR(x,y,w,h,4); ctx.fillStyle=fill; ctx.fill(); ctx.restore(); return; }
    var urgent=(fill===HUDC.dangerPlate)||accent===UIC.danger||accent===HUDC.extract||(fill&&fill!==HUDC.plate&&fill!==UIC.ui_panel);
    if(hero(x,y,w,h)||urgent) P(x,y,w,h,(fill&&fill!==HUDC.plate&&fill!==UIC.ui_panel)?fill:FILL);
    else bare(x,y,w,h);
    if(accent){ ctx.save(); ctx.fillStyle=accent; ctx.fillRect(x+1,y+4,3,Math.max(2,h-8)); ctx.restore(); }
  };
  trPlate=function(x,y,w,h){ bare(x,y,w,h); };   // the cash block's own plate
  TYPE.micro=TYPE.label; TYPE.body=TYPE.label;
})();
