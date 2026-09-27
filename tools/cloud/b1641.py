import os, gen
from gen import patch, fixture
AR = "    if(g.ac>0){ ctx.fillStyle='rgba(255,255,255,.10)'; ctx.fillRect(x,y+14,w,4); ctx.fillStyle='#6fb8ff'; ctx.fillRect(x,y+14,w*clamp((g.ar||0)/g.ac,0,1),4); }"
patch(1641, [
(AR, AR + """
    try{ netMateArrow(g); }catch(_ma){}   // v16.41: an arrow at the screen edge to a teammate off screen"""),
("""function netTeamHud(by){""",
"""// v16.41, THE CO-OP LIST (item 2): AN ARROW AT THE SCREEN EDGE TO A TEAMMATE WHO IS OFF SCREEN. The point on screen where he
// stands is pulled to the edge, inset by a margin; an arrow there points at him with his name and how far he is. Red when he is
// down. Nothing when he is on screen. Returns the arrow drawn, for a check.
function netMateArrow(g){
  var s=w2s(g.x,0,g.y), M=LH(34), cx=W/2, cy=H/2, dx, dy, k, ax, ay, a, nm, d, c;
  if(!s||(s.x>=M&&s.x<=W-M&&s.y>=M&&s.y<=H-M)) return null;
  dx=s.x-cx; dy=s.y-cy; if(!dx&&!dy) return null;
  k=Math.min((W/2-M)/Math.max(1e-6,Math.abs(dx)),(H/2-M)/Math.max(1e-6,Math.abs(dy)));
  ax=cx+dx*k; ay=cy+dy*k; a=Math.atan2(dy,dx);
  c=g.dn?'#ff5a4a':'#ffc04a';
  ctx.save(); ctx.translate(ax,ay); ctx.rotate(a);
  ctx.fillStyle=c; ctx.strokeStyle='rgba(6,9,13,.9)'; ctx.lineWidth=2;
  ctx.beginPath(); ctx.moveTo(LH(14),0); ctx.lineTo(-LH(8),-LH(9)); ctx.lineTo(-LH(4),0); ctx.lineTo(-LH(8),LH(9)); ctx.closePath(); ctx.stroke(); ctx.fill();
  ctx.restore();
  nm=netSeatName(g.seat)||'PILLAGER'; d=(G&&G.player)?metres(dist(G.player,{x:g.x,y:g.y})):0;
  ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c;
  ctx.fillText(nm+'  '+d+'M'+(g.dn?'  DOWN':''),clamp(ax-Math.cos(a)*LH(30),LH(40),W-LH(40)),clamp(ay-Math.sin(a)*LH(22),LH(14),H-LH(8)));
  ctx.textAlign='left';
  return {x:ax,y:ay,a:a};
}
function netTeamHud(by){"""),
], "AN ARROW TO A TEAMMATE OFF SCREEN. Co-op list item 2. A teammate up top who is off screen gets an arrow at the screen edge pointing at him, with his name and how far he is; red with DOWN when he is down. Nothing when he is on screen. Check 16.41 fails on v16.40",
"# AN ARROW TO A TEAMMATE OFF SCREEN (co-op list item 2).\n")
fixture(1641, r"""  {v:'16.41',what:'a teammate off screen gets an arrow at the screen edge pointing at him; one on screen gets none',
   run:function(){
     if(typeof netMateArrow!=='function') return 'this build draws no arrow to a teammate off screen';
     if(typeof w2s!=='function'||!(W>0&&H>0)) return 'SKIP: no screen to draw on';
     var oW=w2s, a, b, bad=[];
     try{
       w2s=function(x,h,z){ return {x:x,y:z}; };
       a=netMateArrow({seat:1,x:W*3,y:H/2,dn:0});
       b=netMateArrow({seat:1,x:W/2,y:H/2,dn:0});
     } finally { w2s=oW; }
     if(!a) bad.push('a teammate far off the right edge got no arrow');
     else { if(!(a.x>W*0.8&&a.x<=W)) bad.push('the arrow is not at the right edge (x '+Math.round(a.x)+' of '+W+')'); if(Math.abs(a.a)>0.05) bad.push('the arrow does not point right ('+a.a.toFixed(2)+')'); }
     if(b) bad.push('a teammate on screen got an arrow');
     return bad.length?bad.join('; '):null; }},
""")
