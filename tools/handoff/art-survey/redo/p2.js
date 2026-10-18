await window.__art.scene('duo',{});
var s=__state(), m=s.map, out={mk:Object.keys(m)};
var long=[]; for(var i=0;i<m.walls.length;i++){ var w=m.walls[i]; if(w.x<-1000) continue; if(w.tree||w.furn||w.wreck||w.ruin) continue;
  if(w.w>150||w.h>150) long.push([Math.round(w.x),Math.round(w.y),Math.round(w.w),Math.round(w.h),Object.keys(w).filter(function(k){return ['x','y','w','h','streaks','lift','_wi','_ws','wid'].indexOf(k)<0}).join(',')]); }
out.nlong=long.length; out.long=long.slice(0,80);
out.W=__gx('WORLD_W'); out.H=__gx('WORLD_H');
return out;
