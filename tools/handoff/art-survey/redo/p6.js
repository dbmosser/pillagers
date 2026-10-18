
var A=window.__art, gx=window.__gx, s=A.state(), AGE=0.15;
function age(sec){ var n=Math.round(sec*60), dt=1/60, k, i, sp, d; for(k=0;k<n;k++){
  for(i=s.sparks.length-1;i>=0;i--){ sp=s.sparks[i]; sp.t+=dt; sp.x+=sp.vx*dt; sp.y+=sp.vy*dt; d=Math.pow(.92,dt*60); sp.vx*=d; sp.vy*=d; if(sp.t>sp.life) s.sparks.splice(i,1); }
  for(i=s.puffs.length-1;i>=0;i--){ s.puffs[i].t+=dt; if(s.puffs[i].t>s.puffs[i].life) s.puffs.splice(i,1); } } }
var r=await A.scene('fight',{}); s=A.state();
s.bullets.length=0; s.shells.length=0; s.flashes.length=0; s.noiseRings.length=0; s.pings.length=0; gx('GFXMUZ.length=0'); s.sparks.length=0; s.puffs.length=0;
var b=A.base(), X=b.x+120, Y=b.y+92, i;
window.__bq={x:X,y:Y};
function mk(id,x,y){ return {id:id,x:x,y:y,hp:30,fuse:-1,by:-1,gone:0,k:'red'}; }
s.brl.length=0; var B0=mk(0,X,Y), B1=mk(1,X-42,Y+14), B2=mk(2,X+40,Y+22); s.brl.push(B0,B1,B2);
var ents=s.ents.splice(0,s.ents.length);
gx('FXS=0x2545F491');
gx('brlBlast(G.brl[0])');
for(i=0;i<ents.length;i++) s.ents.push(ents[i]);
B1.fuse=0.06; B2.fuse=-1; B2.chain=0;
s.noiseRings.length=0; s.pings.length=0; s.shake=0;
var bo=gx('BOOMS'); for(i=0;i<bo.length;i++){ bo[i].t0=s.t-AGE; }
age(AGE); A.draw(2); var pf=s.puffs.map(function(q){return [Math.round(q.x),Math.round(q.y),q.t,q.life,q.c,q.r];}); var fl=s.flashes.map(function(q){return Object.keys(q).map(function(k){return k+":"+(typeof q[k]==="number"?Math.round(q[k]*100)/100:q[k]);}).join(",");}); return {pf:pf,fl:fl.slice(0,6),bq:window.__bq,bfire:(gx("G.bfire")||[]).map(function(f){return [Math.round(f.x),Math.round(f.y),f.t,f.r,f.life];}),t:s.t,decals:s.decals.slice(-4).map(function(d){return [Math.round(d.x),Math.round(d.y),d.c,Math.round(d.s),d.a];})};