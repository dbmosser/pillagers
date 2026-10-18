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

// ---------------------------------------------------------------- a02 figure size: every human body (hero, mate, pillagers) drawn K times bigger about its feet
const scaleHook = (K) => `function(orig,args,x,y){ wc.save(); wc.translate(x,y); wc.scale(${K},${K}); wc.translate(-x,-y); try{ return orig.apply(null,args); } finally{ wc.restore(); } }`;
P['a02-B'] = { scene: 'duo', edits: [wrapDrawOp(scaleHook(1.25))] };
P['a02-C'] = { scene: 'duo', edits: [wrapDrawOp(scaleHook(1.5))] };

// ---------------------------------------------------------------- a03 face from above (scene duoaim: P1 aims up-right, P2 aims right)
const isPlayer = "(st&&(st.hero||(st.own&&typeof st.own.seat==='number')))";
// B: every face part slides toward the aim; aiming up the face is gone and the head is hair
const faceShift = "wc.save(); wc.translate(Math.cos(face)*2.2,Math.sin(face)*0.8);";
P['a03-B'] = { scene: 'duoaim', edits: [
  // the face marks and the eyes (one stretch, from the face marks to the glare lids)
  ['  // v10.94, his note: THE FACE MARKS GO ON FIRST.', '  var _BACK=(Math.sin(face)<-0.35); if(_BACK){ wc.fillStyle=HAIRDARK; rrF(hx2-7.5,ty-37,15,13,5); } else { ' + faceShift + ' }\n  // v10.94, his note: THE FACE MARKS GO ON FIRST.'],
  ['  // v10.94: the face marks used to be painted here, over the eyes. They are', '  if(!_BACK) wc.restore();\n  // v10.94: the face marks used to be painted here, over the eyes. They are'],
  // the tattoo and the beard
  ['    // v10.36: TATTOO, ink on the face and neck, before the beard and headgear.', '    if(_BACK){} else { ' + faceShift + ' }\n    // v10.36: TATTOO, ink on the face and neck, before the beard and headgear.'],
  ['    // HEADGEAR. Sits on top of the fringe and the face because that is where a', '    if(!_BACK) wc.restore();\n    // HEADGEAR. Sits on top of the fringe and the face because that is where a'],
  // the mouth
  ['  if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);', '  if(!_BACK){ ' + faceShift + ' }\n  if(_BACK){} else if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);'],
  ['  else wc.fillRect(hx2-1.5,ty-25.2,3,1);', '  else wc.fillRect(hx2-1.5,ty-25.2,3,1); if(!_BACK) wc.restore();'],
] };
// C: players wear a visor band instead of eyes
P['a03-C'] = { scene: 'duoaim', edits: [
  ['  // eyes: whites, pupils toward the aim, one specular dot each', "  var _VIS=" + isPlayer + ";\n  if(_VIS){ var _va=_SCH?_SCH.a:'#7fd0ff'; wc.fillStyle=INK; rrF(hx2-6.6,ty-33.4,13.2,6.4,2.2); wc.fillStyle=_va; rrF(hx2-5.5,ty-32.4,11,4,1.6); wc.fillStyle='#ffffff'; wc.fillRect(hx2-5.0,ty-32.0,2,1); }\n  else {\n  // eyes: whites, pupils toward the aim, one specular dot each"],
  ["  if(_BLD==='curved'){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95);", "  }\n  if(_BLD==='curved'&&!_VIS){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95);"],
] };
// D: players have bigger eyes and brows (P1 shown in his aiming scowl, brows tilted inward; the mate calm)
P['a03-D'] = { scene: 'duoaim', edits: [
  ['  wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.5,3,0,0,6.2832); wc.fill();\n', 'X', 0],
] };
