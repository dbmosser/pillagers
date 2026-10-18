// art-survey patches: one entry per option. {scene, recipes?, edits:[[find,replace]]}. Written 2026-10-18.
const DRAWOP = 'function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){';
// hook: JS source of a function(orig,args,x,y,face,ph,coat,pk,muzzle,mode,iv,st) that replaces every drawOp call
export const wrapDrawOp = (hook) => [DRAWOP,
  'var __DOH=' + hook + ';\nfunction drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){ if(__DOH) return __DOH(drawOp0,arguments,x,y,face,ph,coat,pk,muzzle,mode,iv,st); return drawOp0.apply(this,arguments); }\nfunction drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st){'];

// the head block of drawOp, scaled about the neck point (hx2,ty-22)
const headScale = (S) => [
  ['  var hx2=x+leanX;', '  var hx2=x+leanX; wc.save(); wc.translate(hx2,ty-22); wc.scale(' + S + ',' + S + '); wc.translate(-hx2,-(ty-22));'],
  ["// v10.54, his notes: THE SUIT'S OWN PAINT.", "wc.restore(); // v10.54, his notes: THE SUIT'S OWN PAINT."],
  ['  if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);', '  wc.save(); wc.translate(hx2,ty-22); wc.scale(' + S + ',' + S + '); wc.translate(-hx2,-(ty-22)); if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);'],
  ['  else wc.fillRect(hx2-1.5,ty-25.2,3,1);', '  else wc.fillRect(hx2-1.5,ty-25.2,3,1); wc.restore();'],
];

export const P = {};
P['a01-B'] = { scene: 'duo', edits: headScale(0.82) };
P['a01-C'] = { scene: 'duo', edits: headScale(0.65) };
P['a01-D'] = { scene: 'duo', edits: headScale(1.2) };
