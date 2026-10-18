// cap-motion.js : sprite sheets of P1 (the game's own drawOp, drawn at 4x on an offscreen canvas) for the motion snippets a11, a12, a15.
const A=window.__art;
await A.stage({});
const s0=__state(), p0=s0.player;
A.cam(A.base().x,A.base().y,5.0);
A.draw(3);
const S=4, CX=36, CY=60, CW=100, CH=74;     // a cell is CW x CH game units, the feet at (CX,CY)
function mkcv(w,h){ const c=document.createElement('canvas'); c.width=w; c.height=h; return c; }
function fig(x2,o){
  window.__x2=x2; window.__fo=o; window.__MOT=o.mot||undefined;
  __gx("(function(){ var k=wc, sk=shadowE, o=window.__fo, p=G.player; wc=window.__x2; shadowE=function(){}; try{ drawOp(0,0,0,o.ph||0,'#242832',0,0,'',0,{hero:1,own:p,team:'ally',moving:!!o.moving,sprint:!!o.sprint,ads:false,hurt:o.hurt||0,bulk:armorById(p.rig).bulk,rl:0}); } finally{ wc=k; shadowE=sk; } })()");
  window.__MOT=undefined;
}
function cell(o,drawFn){
  const c=mkcv(CW*S,CH*S), x2=c.getContext('2d',{willReadFrequently:true});
  x2.setTransform(S,0,0,S,CX*S,CY*S);
  if(drawFn) drawFn(x2); else fig(x2,o);
  return c;
}
const N=24;
const MOTS={
  'A-walk':  {amp:2.9,lift:2.2,lean:0.7,head:0,moving:1,sprint:0},
  'A-sprint':{amp:4.2,lift:3.4,lean:1.6,head:0,moving:1,sprint:1},
  'B-walk':  {amp:3.4,lift:2.6,lean:1.2,head:0,moving:1,sprint:0},
  'B-sprint':{amp:5.0,lift:4.0,lean:2.8,head:0,moving:1,sprint:1},
  'C-walk':  {amp:2.4,lift:1.8,lean:0.7,head:0,moving:1,sprint:0},
  'C-sprint':{amp:3.6,lift:2.9,lean:2.5,head:1.5,moving:1,sprint:1}
};
const sets={};   // name -> array of cells (canvases)
for(const k in MOTS){
  const m=MOTS[k]; sets[k]=[];
  for(let i=0;i<N;i++){ sets[k].push(cell({ph:Math.PI*2*i/N,moving:m.moving,sprint:m.sprint,mot:{amp:m.amp,lift:m.lift,lean:m.lean,head:m.head,bob:0}})); }
}
sets['stand']=[cell({ph:0,moving:0,sprint:0})];
sets['hurtA']=[0.4,0.35,0.3,0.25,0.2,0.15,0.1,0.05].map(h=>cell({ph:0,hurt:h}));
sets['hurtC']=[0.175,0.14,0.105,0.07,0.035].map(h=>cell({ph:0,hurt:h}));
sets['shadow']=[cell(null,function(x2){ window.__x2=x2; __gx("(function(){ var k=wc; wc=window.__x2; try{ shadowE(1.5,1.5,10,4,.34); shadowE(6,2.5,6.5,2.5,.18); } finally{ wc=k; } })()"); })];
// the held gun alone, and the pack alone (same colours as drawOp uses)
sets['gun']=[cell(null,function(x2){
  window.__x2=x2;
  __gx("(function(){ var k=wc, p=G.player, w=p.wep, id=(w&&GUNDEF[w.id])?w.id:'rifle', D=GUNDEF[id]; var fk=0, el='';"+
   "var wt=(w&&WTIER[w.id]!==undefined)?WTIER[w.id]+(RV_BASE[w.id]?1:0):1; var rc=(wt>=5?RCOL.gold:(wt>=4?RCOL.elite:(wt===3?RCOL.rare:(wt===2?RCOL.uncommon:RCOL.common))));"+
   "var S=2; try{ S=Math.min(6,Math.ceil((wallSpriteScale()+1)*GUNK)); }catch(e){} var B=gunBake(id,fk,el,rc,S);"+
   "wc=window.__x2; try{ wc.save(); wc.scale(GUNK,GUNK); wc.drawImage(B.c,B.x0,B.y0,B.w,B.h); wc.restore(); } finally{ wc=k; } })()");
})];
sets['pack']=[cell(null,function(x2){
  window.__x2=x2;
  __gx("(function(){ var k=wc, pw=6; wc=window.__x2; try{ var _PKC=PACKCOL[cosWorn('pack')]||PACKCOL.packbrown, ty=0, x=0, fl=1, leanX=0;"+
   "wc.fillStyle=INK; rrF(x-fl*9-pw/2+leanX-1,ty-22,pw+2,11,3); wc.fillStyle=_PKC; rrF(x-fl*9-pw/2+leanX,ty-21,pw,9,2);"+
   "if(/^#[0-9a-fA-F]{6}$/.test(_PKC)){ var _pkx=x-fl*9+leanX; wc.fillStyle=darkHex(_PKC,.35); wc.fillRect(_pkx-pw/2+0.6,ty-14.2,pw-1.2,0.9); wc.fillRect(_pkx-0.5,ty-19.2,1.0,5.0); wc.fillStyle='#cfd5db'; wc.fillRect(_pkx-0.9,ty-16.6,1.8,1.5); } } finally{ wc=k; } })()");
})];
// union box of everything that was drawn (only the figure sets share it; the gun and the pack get their own tight box)
function bbox(c){
  const x2=c.getContext('2d'), d=x2.getImageData(0,0,c.width,c.height).data; let x0=1e9,y0=1e9,x1=-1,y1=-1;
  for(let y=0;y<c.height;y++) for(let x=0;x<c.width;x++){ if(d[(y*c.width+x)*4+3]>6){ if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; } }
  return x1<0?null:[x0,y0,x1+1,y1+1];
}
function unionOf(names){ let u=null; for(const n of names) for(const c of sets[n]){ const b=bbox(c); if(!b) continue; u=u?[Math.min(u[0],b[0]),Math.min(u[1],b[1]),Math.max(u[2],b[2]),Math.max(u[3],b[3])]:b; } return u; }
const figNames=Object.keys(sets).filter(n=>n!=='gun'&&n!=='pack'&&n!=='shadow');
const U1=unionOf(figNames);
// round the box to whole game units so the feet stay on the pixel grid of the figure
const bx0=Math.floor(U1[0]/S)*S-S, by0=Math.floor(U1[1]/S)*S-S, bx1=Math.ceil(U1[2]/S)*S+S, by1=Math.ceil(U1[3]/S)*S+S;
function sheet(cells,box){
  const w=box[2]-box[0], h=box[3]-box[1], c=mkcv(w*cells.length,h), x2=c.getContext('2d');
  cells.forEach((cc,i)=>x2.drawImage(cc,box[0],box[1],w,h,i*w,0,w,h));
  return {w:w,h:h,n:cells.length,png:c.toDataURL('image/png'),webp:c.toDataURL('image/webp',1)};
}
const out={S:S,box:[bx0,by0,bx1,by1],fx:CX*S-bx0,fy:CY*S-by0,sets:{}};
for(const n of figNames){ out.sets[n]=sheet(sets[n],[bx0,by0,bx1,by1]); }
for(const n of ['gun','pack','shadow']){ const b=bbox(sets[n][0]); const bb=[b[0]-2,b[1]-2,b[2]+2,b[3]+2]; out.sets[n]=sheet(sets[n],bb); out.sets[n].ox=CX*S-bb[0]; out.sets[n].oy=CY*S-bb[1]; }
// what the figure is wearing, for the colour of the death ellipse and the stain
out.coat=__gx("(function(){ var st={hero:1,own:G.player}; var sc=schemeOf(st); return sc?sc.arm:'#a02020'; })()");
out.coatP=__gx("(function(){ var sc=schemeOf({hero:1,own:G.player}); return sc?sc.p:'#a02020'; })()");
async function loadImg(u){ return await new Promise((res,rej)=>{ const i=new Image(); i.onload=()=>res(i); i.onerror=rej; i.src=u; }); }
out.webpDiff={};
for(const n of ['A-sprint','hurtA','gun']){ const sh=out.sets[n]; const im=await loadImg(sh.webp), im2=await loadImg(sh.png); const c=mkcv(im.width,im.height), c2=mkcv(im.width,im.height); c.getContext('2d').drawImage(im,0,0); c2.getContext('2d').drawImage(im2,0,0); const d1=c.getContext('2d').getImageData(0,0,c.width,c.height).data, d2=c2.getContext('2d').getImageData(0,0,c.width,c.height).data; let bad=0,mx=0; for(let i=0;i<d1.length;i++){ const dd=Math.abs(d1[i]-d2[i]); if(dd>0){ bad++; if(dd>mx)mx=dd; } } out.webpDiff[n]={bad:bad,max:mx}; }
window.__capDone=true;
return JSON.stringify(out);
