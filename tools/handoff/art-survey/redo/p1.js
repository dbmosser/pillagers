await window.__art.scene('duo',{});
var s=__state(), m=s.map, out={n:m.walls.length, keys:Object.keys(m.walls[0]), site:window.__art.base()};
var b=window.__art.base();
var near=[]; for(var i=0;i<m.walls.length;i++){ var w=m.walls[i]; if(w.x<-1000) continue; if(w.tree||w.furn||w.wreck) continue;
  var dx=Math.max(w.x-b.x,0,b.x-(w.x+w.w)), dy=Math.max(w.y-b.y,0,b.y-(w.y+w.h)); var d=Math.hypot(dx,dy);
  if(d<500) near.push({x:w.x,y:w.y,w:w.w,h:w.h,d:Math.round(d),k:Object.keys(w).filter(function(k){return ['x','y','w','h'].indexOf(k)<0}).join(',')}); }
near.sort(function(a,c){return a.d-c.d;});
out.near=near.slice(0,25);
return out;
