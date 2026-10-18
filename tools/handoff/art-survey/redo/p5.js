var A=window.__art, gx=window.__gx; await A.scene('duo',{});
var s=A.state(), m=s.map, gcv=gx('G.ground'), gctx=gcv.getContext('2d'), out=[], i, w;
function px(x,y){ try{ var d=gctx.getImageData(Math.round(x),Math.round(y),1,1).data; return [d[0],d[1],d[2]]; }catch(e){ return null; } }
function green(c){ return c&&c[1]>c[0]+14&&c[1]>c[2]+22; }
var n=0;
for(i=0;i<m.walls.length;i++){ w=m.walls[i]; if(w.x<-1000||w.tree||w.furn||w.wreck||w.w<30||w.h<20) continue;
  var cx=w.x+w.w/2, cy=w.y+w.h/2;
  var L=px(w.x-90,cy), R=px(w.x+w.w+90,cy), T=px(cx,w.y-90), B=px(cx,w.y+w.h+90);
  var gl=green(L)?1:0, gr=green(R)?1:0, gt=green(T)?1:0, gb=green(B)?1:0;
  if(gl+gr+gt+gb>=1){ out.push({x:Math.round(w.x),y:Math.round(w.y),w:Math.round(w.w),h:Math.round(w.h),g:[gl,gr,gt,gb].join('')}); }
  n++;
}
out.sort(function(a,b){return (b.g.split('1').length)-(a.g.split('1').length);});
return {total:n, found:out.length, sample:out.slice(0,30), gsize:[gcv.width,gcv.height]};
