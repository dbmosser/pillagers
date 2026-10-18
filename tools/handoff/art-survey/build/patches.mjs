// art-survey patches: one entry per option. {scene, recipes?, edits:[[find,replace]]}. Written 2026-10-18.
// find is a string (must be present exactly once) or a RegExp (must match exactly once); the copy is tools/fixture.html in memory, never written back.
const DRAWOP = 'function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){';
// hook: JS source of a function(orig,args,x,y,face,ph,coat,pk,muzzle,mode,iv,st) that replaces every drawOp call (orig is the real drawOp)
export const wrapDrawOp = (hook, extra) => [DRAWOP,
  (extra || '') + 'var __DOH=' + hook + ';\nfunction drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){ if(__DOH) return __DOH(drawOp0,arguments,x,y,face,ph,coat,pk,muzzle,mode,iv,st); return drawOp0.apply(this,arguments); }\nfunction drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st){'];

export const P = {};
const HEADEND = "// v10.54, his notes: THE SUIT'S OWN PAINT.";          // the line after the head block (hat last) of drawOp
const sv = (cx, cy, S) => `wc.save(); wc.translate(${cx},${cy}); wc.scale(${S},${S}); wc.translate(-(${cx}),-(${cy}));`;

// ---------------------------------------------------------------- the base looks (no change)
P['base-duo'] = { scene: 'duo', edits: [] };
P['base-loot'] = { scene: 'loot', edits: [] };

// ---------------------------------------------------------------- a01 head size: the head block of drawOp scaled about the neck point (hx2,ty-22)
const headScale = (S) => [
  ['  var hx2=x+leanX;', '  var hx2=x+leanX; ' + sv('hx2', 'ty-22', S)],
  [HEADEND, 'wc.restore(); ' + HEADEND],
  ['  if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);', '  ' + sv('hx2', 'ty-22', S) + ' if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);'],
  ['  else wc.fillRect(hx2-1.5,ty-25.2,3,1);', '  else wc.fillRect(hx2-1.5,ty-25.2,3,1); wc.restore();'],
];
P['a01-B'] = { scene: 'duo', edits: headScale(0.82) };
P['a01-C'] = { scene: 'duo', edits: headScale(0.65) };
P['a01-D'] = { scene: 'duo', edits: headScale(1.2) };

// ---------------------------------------------------------------- a02 figure size: every human body (hero, mate, pillagers) drawn K times bigger about its feet
const scaleHook = (K) => `function(orig,args,x,y){ wc.save(); wc.translate(x,y); wc.scale(${K},${K}); wc.translate(-x,-y); try{ return orig.apply(null,args); } finally{ wc.restore(); } }`;
P['a02-B'] = { scene: 'duo', edits: [wrapDrawOp(scaleHook(1.25))] };
P['a02-C'] = { scene: 'duo', edits: [wrapDrawOp(scaleHook(1.5))] };

// ---------------------------------------------------------------- a03 face from above (scene duoaim: P1 aims up and right, P2 aims right)
P['a03-A'] = { scene: 'duoaim', edits: [] };
const isPlayer = "(st&&(st.hero||(st.own&&typeof st.own.seat==='number')))";
const faceShift = 'wc.save(); wc.translate(Math.cos(face)*2.2,Math.sin(face)*0.8);';
// B: the face slides toward the aim; aiming up the face is gone and the head reads as hair
P['a03-B'] = { scene: 'duoaim', edits: [
  ['  // v10.94, his note: THE FACE MARKS GO ON FIRST.', '  var _BACK=(Math.sin(face)<-0.35); if(_BACK){ wc.fillStyle=HAIRDARK; rrF(hx2-7.5,ty-37,15,13,5); }\n  if(!_BACK){ ' + faceShift + '\n  // v10.94, his note: THE FACE MARKS GO ON FIRST.'],
  ['  // v10.94: the face marks used to be painted here, over the eyes. They are', '  wc.restore(); }\n  // v10.94: the face marks used to be painted here, over the eyes. They are'],
  ['    // v10.36: TATTOO, ink on the face and neck, before the beard and headgear.', '    if(!_BACK){ ' + faceShift + '\n    // v10.36: TATTOO, ink on the face and neck, before the beard and headgear.'],
  ['    // HEADGEAR. Sits on top of the fringe and the face because that is where a', '    wc.restore(); }\n    // HEADGEAR. Sits on top of the fringe and the face because that is where a'],
  ['  if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);', '  if(!_BACK){ ' + faceShift + ' if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);'],
  ['  else wc.fillRect(hx2-1.5,ty-25.2,3,1);', '  else wc.fillRect(hx2-1.5,ty-25.2,3,1); wc.restore(); }'],
] };
const LASHES = "  if(_BLD==='curved'){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95);";
const EYES = '  // eyes: whites, pupils toward the aim, one specular dot each';
// C: players wear a coloured visor band instead of eyes
P['a03-C'] = { scene: 'duoaim', edits: [
  [EYES, '  var _VIS=' + isPlayer + ";\n  if(_VIS){ var _va=_SCH?_SCH.a:'#7fd0ff'; wc.fillStyle=INK; rrF(hx2-6.6,ty-33.4,13.2,6.4,2.2); wc.fillStyle=_va; rrF(hx2-5.5,ty-32.4,11,4,1.6); wc.fillStyle='#ffffff'; wc.fillRect(hx2-5.0,ty-32.0,2,1); }\n  else {\n" + EYES],
  [LASHES, "  }\n  if(_BLD==='curved'&&!_VIS){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95);"],
] };
// D: players have eyes 1.35 times bigger and a brow over each (P1 is shown aiming, so his brows slope inward; the mate is calm)
const bigEyes = `  var _BIG=${isPlayer};
  if(_BIG){
    var pupX=Math.cos(face)*1.4,pupY=Math.sin(face)*0.9, _es, _ecx, _ecy, _EYE0=EYECOL[HERO?cosWorn('eyes'):(st.eyes||'eyebrown')]||EYECOL.eyebrown;
    for(_es=-1;_es<=1;_es+=2){
      _ecx=hx2+_es*3.4; _ecy=ty-29.5;
      wc.save(); wc.translate(_ecx,_ecy); wc.scale(1.35,1.35); wc.translate(-_ecx,-_ecy);
      wc.fillStyle='#FFF6DC'; wc.beginPath(); wc.ellipse(_ecx,_ecy,2.5,3,0,0,6.2832); wc.fill();
      wc.fillStyle=_EYE0; wc.beginPath(); wc.arc(_ecx+pupX,ty-29.3+pupY,1.9,0,6.2832); wc.fill();
      wc.fillStyle=INK; wc.beginPath(); wc.arc(_ecx+pupX,ty-29.3+pupY,1.0,0,6.2832); wc.fill();
      wc.fillStyle='#FFF6DC'; wc.fillRect(_ecx-0.7+pupX,ty-30.2+pupY,0.8,0.8);
      if(_BLD==='curved'){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(_ecx,_ecy,2.6,3.1,0,_es<0?3.45:3.47,_es<0?5.95:5.97); wc.stroke(); wc.fillStyle=INK; wc.fillRect(_es<0?_ecx-2.9:_ecx+1.4,ty-31.5,1.5,0.9); }
      wc.restore();
    }
  } else {
` + EYES;
P['a03-D'] = { scene: 'duoaim', edits: [
  [EYES, bigEyes],
  [LASHES, "  }\n  if(_BLD==='curved'&&!_BIG){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95);"],
  [HEADEND, "if(_BIG){ var _tl=((st.hero||st.sprint||st.ads)?8:(st.hurt>0?-8:0))*0.01745, _bs; for(_bs=-1;_bs<=1;_bs+=2){ wc.save(); wc.translate(hx2+_bs*3.4,ty-34.8); wc.rotate(-_bs*_tl); wc.fillStyle=INK; wc.fillRect(-1.6,-0.6,3.2,1.2); wc.restore(); } }\n  " + HEADEND],
] };

// ---------------------------------------------------------------- a04 the three builds (scene trio: P1 lean, a hired pillager broad, P2 curved, all Standard Issue)
P['a04-A'] = { scene: 'trio', edits: [] };
const buildOf = "(st&&st.hero?cosWorn('build'):((st&&st.build)||'lean'))";
P['a04-B'] = { scene: 'trio', edits: [
  // Broad: wider torso (18 percent about the spine), wider legs, a thicker gun arm, shoulder caps and rig moved out with the torso
  ['var BUILD_BROAD=[[3.6,-23.8],[8.9,-23.0],[9.1,-19.4],[7.4,-14.6],[6.9,-10.6],[2.2,-10.2]];', 'var BUILD_BROAD=[[3.6,-23.8],[8.9,-23.0],[9.1,-19.4],[7.4,-14.6],[6.9,-10.6],[2.2,-10.2]].map(function(p){ return [p[0]*1.18,p[1]]; });'],
  // Curved: hips 20 percent wider (points 4 and 5), chest 15 percent wider (point 2)
  ['var BUILD_CURVED=[[3.0,-23.4],[6.0,-22.8],[7.8,-18.6],[4.1,-14.9],[8.7,-11.8],[7.3,-9.8],[0.8,-10.8]];', 'var BUILD_CURVED=[[3.0,-23.4],[6.0,-22.8],[7.8,-18.6],[4.1,-14.9],[8.7,-11.8],[7.3,-9.8],[0.8,-10.8]].map(function(p,i){ return [p[0]*(i===2?1.15:((i===4||i===5)?1.2:1)),p[1]]; });'],
  ["var _LSX=(_BLD==='broad')?1.2:1;", "var _LSX=(_BLD==='broad')?1.4:(_BLD?1:0.9);"],
  // Lean: a torso 9.5 wide, was 11
  ['  if(_PC){ wc.fillStyle=INK; rrF(x-6.6+leanX,ty-23,13.2,13,4); wc.fillStyle=cc; rrF(x-5.6+leanX,ty-22,11.2,11,3); }', '  if(_PC){ wc.fillStyle=INK; rrF(x-5.75+leanX,ty-23,11.5,13,4); wc.fillStyle=cc; rrF(x-4.75+leanX,ty-22,9.5,11,3); }'],
  ['else { wc.beginPath(); if(HAS_RR) wc.roundRect(cx-5.6,ty-22,11.2,11,3); else wc.rect(cx-5.6,ty-22,11.2,11);', 'else { wc.beginPath(); if(HAS_RR) wc.roundRect(cx-4.75,ty-22,9.5,11,3); else wc.rect(cx-4.75,ty-22,9.5,11);'],
  ['R=(b===\'broad\')?{w:12.4,y:-20.6,h:7.4,sx:-5.6,sx2:3.6,sw:2,pw:3.2,py:-16.8,ph:3.2,by:-12.6,bh:1.6}', 'R=(b===\'broad\')?{w:14.4,y:-20.6,h:7.4,sx:-6.6,sx2:4.4,sw:2,pw:3.8,py:-16.8,ph:3.2,by:-12.6,bh:1.6}'],
  [':{w:8.2,y:-20.2,h:6.8,sx:-3.9,sx2:2.5,sw:1.4,pw:2.3,py:-16.6,ph:3,by:-13.0,bh:1.4};', ':{w:7.0,y:-20.2,h:6.8,sx:-3.3,sx2:2.1,sw:1.2,pw:2.0,py:-16.6,ph:3,by:-13.0,bh:1.4};'],
  // the shoulder caps and the gun arm
  ["_sx=(_BLD==='broad')?9.6:(_BLD==='curved'?6.7:8.4), _sw=(_BLD==='broad')?5.2:(_BLD==='curved'?3.6:4.6),", "_sx=(_BLD==='broad')?11.3:(_BLD==='curved'?6.7:7.6), _sw=(_BLD==='broad')?5.6:(_BLD==='curved'?3.6:4.4),"],
  ["aw=(bld==='broad')?3.3:(bld==='curved'?2.0:(pc?2.1:2.4));", "aw=(bld==='broad')?4.2:(bld==='curved'?2.0:1.8);"],
] };
P['a04-C'] = { scene: 'trio', edits: [wrapDrawOp(`function(orig,args,x,y,face,ph,coat,pk,muzzle,mode,iv,st){ var b=${buildOf}, sx=(b==='broad')?1.1:(b==='curved'?1:0.92), sy=(b==='broad')?0.96:(b==='curved'?1:1.08); wc.save(); wc.translate(x,y); wc.scale(sx,sy); wc.translate(-x,-y); try{ return orig.apply(null,args); } finally{ wc.restore(); } }`)] };

// ---------------------------------------------------------------- a05 cosmetics at game size (the standard duo: different hat, hair, vest, pack, boots and patch on each)
P['a05-A'] = { scene: 'duo', edits: [] };
const PACKSTART = '  if(!(OUTF&&OUTF.nopack)){   // v23.xx (spr21): the Survivor has no pack';
const PACKEND = 'drawPackExtra(_PKID,x-fl*9+leanX,ty,fl,pw,_SCH);';
const VESTCALL = "if(_VID!=='vestplate'&&!(OUTF&&OUTF.norig)) drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl);";
const PADSCALL = "if(_PDS!=='padsnone'&&(st.bulk||0)<2) drawPads(_PDS,_BLD,x+leanX,ty,fl,_SCH);";
const PATCHCALL = "if(_pid&&_pid!=='patchnone') drawPatch(wc,_pid,x-fl*3.6-1.8+leanX,ty-21.8,3.6);";
P['a05-B'] = { scene: 'duo', edits: [
  [PACKSTART, "  if(!(OUTF&&OUTF.nopack)){ " + sv('x-fl*9+leanX', 'ty-16.5', 1.3) + '   // v23.xx (spr21): the Survivor has no pack'],
  [PACKEND, PACKEND + ' wc.restore();'],
  // hair behind the head, then the hair on the head (the skin and the face between them stay), the fringe, and the hat
  ["  if(HERO&&(_HCUT==='long'||_HCUT==='pigtails')){", '  ' + sv('hx2', 'ty-22', 1.18) + "\n  if(HERO&&(_HCUT==='long'||_HCUT==='pigtails')){"],
  ['  wc.fillStyle=INK; rrF(hx2-8.5,ty-38,17,15,6);', '  wc.restore();\n  wc.fillStyle=INK; rrF(hx2-8.5,ty-38,17,15,6);'],
  ["  if(_NCT==='none'){ /* v10.54: no hair under a suit that has none */ }", '  ' + sv('hx2', 'ty-22', 1.18) + "\n  if(_NCT==='none'){ /* v10.54: no hair under a suit that has none */ }"],
  ['  // v23.xx (spr18): armour 3 wears a dark steel helmet shell over the crown', '  wc.restore();\n  // v23.xx (spr18): armour 3 wears a dark steel helmet shell over the crown'],
  ['      wc.fillStyle=HAIRLIT; rrF(hx2-7.5,ty-37,15,4,4);', '      ' + sv('hx2', 'ty-22', 1.18) + ' wc.fillStyle=HAIRLIT; rrF(hx2-7.5,ty-37,15,4,4);'],
  ['      wc.fillStyle=HAIRHI;  wc.fillRect(hx2-6.6,ty-36.6,10.4,1.4);', '      wc.fillStyle=HAIRHI;  wc.fillRect(hx2-6.6,ty-36.6,10.4,1.4); wc.restore();'],
  ['    // HEADGEAR. Sits on top of the fringe and the face because that is where a', '    ' + sv('hx2', 'ty-22', 1.18) + '\n    // HEADGEAR. Sits on top of the fringe and the face because that is where a'],
  [HEADEND, 'wc.restore(); ' + HEADEND],
  // vest and shoulder plates
  [VESTCALL, '{ if(_VID!==\'vestplate\'&&!(OUTF&&OUTF.norig)){ ' + sv('x', 'ty-17', 1.12) + ' drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl); wc.restore(); } }'],
  [PADSCALL, '{ if(_PDS!==\'padsnone\'&&(st.bulk||0)<2){ ' + sv('x', 'ty-17', 1.12) + ' drawPads(_PDS,_BLD,x+leanX,ty,fl,_SCH); wc.restore(); } }'],
  // the chest patch 1.6 times as big about its own centre
  [PATCHCALL, "if(_pid&&_pid!=='patchnone') drawPatch(wc,_pid,x-fl*3.6-1.8+leanX-1.08,ty-21.8-1.08,5.76);"],
] };
P['a05-C'] = { scene: 'duo', edits: [
  wrapDrawOp("function(orig,args){ wc.save(); wc.filter='saturate(1.25) brightness(1.06)'; try{ return orig.apply(null,args); } finally{ wc.restore(); } }"),
  // the accent trims, twice as tall: the boot collar, the pack flap, the accent stripe across the plate and the vest buckles
  ['wc.fillStyle=_SCH.a; wc.fillRect(x-6.4+swing2*.5,ty-6.5-liftB,4.8,1.0); wc.fillRect(x+1.6+swing*.5,ty-6.5-liftA,4.8,1.0);', 'wc.fillStyle=_SCH.a; wc.fillRect(x-6.4+swing2*.5,ty-6.5-liftB,4.8,2.0); wc.fillRect(x+1.6+swing*.5,ty-6.5-liftA,4.8,2.0);'],
  ['wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2);', 'wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,2.0);'],
  ['wc.fillRect(cx-R.w/2+0.9,ty+R.y+1.4,R.w-2.4,0.9);', 'wc.fillRect(cx-R.w/2+0.9,ty+R.y+1.4,R.w-2.4,1.8);'],
  ['wc.fillStyle=A; wc.fillRect(x1-0.4,y1-0.6,2.0,2.0);', 'wc.fillStyle=A; wc.fillRect(x1-0.4,y1-0.6,2.0,4.0);'],
  ['wc.fillStyle=A; wc.fillRect(cx-1.1,ty-17.9,2.2,2.2);', 'wc.fillStyle=A; wc.fillRect(cx-1.1,ty-17.9,2.2,4.4);'],
] };
P['a05-D'] = { scene: 'duo', edits: [
  // every ink plate of the boots, pack, hat and vest 0.6 bigger on each side (rrF grows an INK fill while window.__GROW is on)
  ['function rrF(x,y,w,h,r){', "function rrF(x,y,w,h,r){ if(window.__GROW&&wc.fillStyle==='#120e0c'){ x-=0.6; y-=0.6; w+=1.2; h+=1.2; }"],
  ['  rrF(x-6.9+swing2*.5,ty-11.6,5.8,7.9-liftB*.5,1.5);', '  window.__GROW=1; rrF(x-6.9+swing2*.5,ty-11.6,5.8,7.9-liftB*.5,1.5);'],
  ['  rrF(x+.5+swing,ty-5.1-liftA,6.6,5.1,1.5);', '  rrF(x+.5+swing,ty-5.1-liftA,6.6,5.1,1.5); window.__GROW=0;'],
  ['wc.fillStyle=INK; rrF(x-7.0+swing2*.5,ty-10.8-liftB*.5,5.8,7.4,1.5);', 'window.__GROW=1; wc.fillStyle=INK; rrF(x-7.0+swing2*.5,ty-10.8-liftB*.5,5.8,7.4,1.5);'],
  ['rrF(x+1.2+swing*.5,ty-10.8-liftA*.5,5.8,7.4,1.5);', 'rrF(x+1.2+swing*.5,ty-10.8-liftA*.5,5.8,7.4,1.5); window.__GROW=0;'],
  [PACKSTART, '  if(!(OUTF&&OUTF.nopack)){ window.__GROW=1;   // v23.xx (spr21): the Survivor has no pack'],
  [PACKEND, PACKEND + ' window.__GROW=0;'],
  ['    // HEADGEAR. Sits on top of the fringe and the face because that is where a', '    window.__GROW=1;\n    // HEADGEAR. Sits on top of the fringe and the face because that is where a'],
  [HEADEND, 'window.__GROW=0; ' + HEADEND],
  [VESTCALL, "{ if(_VID!=='vestplate'&&!(OUTF&&OUTF.norig)){ window.__GROW=1; drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl); window.__GROW=0; } }"],
  ['wc.lineCap=\'butt\'; wc.strokeStyle=INK; wc.lineWidth=4.2;', "wc.lineCap='butt'; wc.strokeStyle=INK; wc.lineWidth=5.4;"],
  ['wc.lineCap=\'butt\'; wc.strokeStyle=INK; wc.lineWidth=3.0;', "wc.lineCap='butt'; wc.strokeStyle=INK; wc.lineWidth=4.2;"],
  // the 1 px details dropped: lace dots, pack seam strap and buckle, helmet chips, bandolier flecks
  [/wc\.fillStyle='#d8d4c4'; wc\.fillRect\(x-6\.5\+swing2\+_lc[^\n]*\n/, '\n'],
  [/wc\.fillStyle='#d8cfb4'; wc\.fillRect\(x-4\.4\+swing2\*\.5[^\n]*\n/, '\n'],
  ['wc.fillStyle=darkHex(_PKC,.35); wc.fillRect(_pkx-pw/2+0.6,ty-14.2,pw-1.2,0.9); wc.fillRect(_pkx-0.5,ty-19.2,1.0,5.0);', ''],
  ["wc.fillStyle='#cfd5db'; wc.fillRect(_pkx-0.9,ty-16.6,1.8,1.5);", ''],
  ["wc.fillStyle='#dfe6ec'; wc.fillRect(hx2-7.4,ty-41.6,1.4,1.0); wc.fillRect(hx2+5.4,ty-42.6,1.4,1.0); wc.fillRect(hx2+6.4,ty-38.2,1.4,1.0); wc.fillRect(hx2-4.6,ty-38.0,1.4,1.0);", ''],
  ["wc.fillStyle='#dfe6ec'; for(i=0;i<4;i++){ t=0.23+i*0.18; px=x1+(x2-x1)*t; py=y1+(y2-y1)*t; wc.fillRect(px-0.7,py-1.0,1.4,1.0); }", ''],
] };

// ---------------------------------------------------------------- a06 player 1 or player 2 (scene duoparty: the party is on, so the game draws the seat marks)
P['a06-A'] = { scene: 'duoparty', edits: [] };
const SEATDOT = `function drawSeatDot(x,y,s){ var c=SEATCOL[s&3]; wc.fillStyle=INK; wc.beginPath(); wc.arc(x,y+8.4,3.7,0,6.2832); wc.fill(); wc.fillStyle=c; wc.beginPath(); wc.arc(x,y+8.4,3,0,6.2832); wc.fill();
  wc.fillStyle='#10151b'; wc.font='700 5px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; wc.textAlign='center'; wc.fillText(String((s&3)+1),x,y+10.1); wc.textAlign='left'; }\n`;
const RINGCALL = 'if(_SEAT>=0) drawSeatRing(x,y,_SEAT);';
P['a06-B'] = { scene: 'duoparty', edits: [
  ['function drawSeatRing(x,y,s){', SEATDOT + 'function drawSeatRing(x,y,s){'],
  [RINGCALL, 'if(_SEAT>=0) drawSeatDot(x,y,_SEAT);'],
  wrapDrawOp("function(orig,args,x,y,face,ph,coat,pk,muzzle,mode,iv,st){ var sm=seatMarkOf(st), h=(sm>=0)?rimOpen({x:x,y:y,r:11},SEATCOL[sm&3]):null; try{ return orig.apply(null,args); } finally{ if(h) rimClose(h); } }"),
] };
P['a06-C'] = { scene: 'duoparty', edits: [
  [RINGCALL, '/* no ring */'],
  wrapDrawOp(`function(orig,args,x,y,face,ph,coat,pk,muzzle,mode,iv,st){
    orig.apply(null,args);
    var sm=seatMarkOf(st); if(sm<0) return;
    var c=SEATCOL[sm&3], lab='p'+((sm&3)+1), ty0=y-55;
    wc.save(); wc.font='700 10px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; wc.textAlign='left';
    var tw=wc.measureText(lab).width, gx0=x-(9+2+tw)/2;
    wc.lineJoin='round'; wc.beginPath(); wc.moveTo(gx0,ty0-6); wc.lineTo(gx0+9,ty0-6); wc.lineTo(gx0+4.5,ty0); wc.closePath();
    wc.strokeStyle=INK; wc.lineWidth=2.4; wc.stroke(); wc.fillStyle=c; wc.fill();
    wc.strokeStyle=INK; wc.lineWidth=2.6; wc.strokeText(lab,gx0+11,ty0+0.6); wc.fillStyle=c; wc.fillText(lab,gx0+11,ty0+0.6);
    wc.restore();
  }`)] };
P['a06-D'] = { scene: 'duoparty', edits: [
  [RINGCALL, '/* no ring */'],
  ['  S=id?SCHEMES[id]:null; if(!S) return null;', "  var _sm=st.hero?seatHere():((st.own&&typeof st.own.seat==='number')?(st.own.seat|0):-1); if(_sm===0) id='schember'; else if(_sm===1) id='schfrost';\n  S=id?SCHEMES[id]:null; if(!S) return null;"],
] };

// ---------------------------------------------------------------- a07 outline on busy ground (scene loot)
P['a07-A'] = { scene: 'loot', edits: [] };
// the body goes to a scratch canvas (rimOpen), then back: the silhouette stamped first in a light colour, the sprite over it
const rimClosePlus = (stamp) => `function(orig,args,x,y){
    var h=rimOpen({x:x,y:y,r:11},'#f2efe6'); if(!h) return orig.apply(null,args);
    try{ orig.apply(null,args); }catch(e){ rimAbort(); throw e; }
    var xa=RIM.xa, xb=RIM.xb, u=h.u;
    wc=h.w0; shadowE=h.sh0; RIM.on=0; RIM.h=null;
    xb.setTransform(1,0,0,1,0,0); xb.globalCompositeOperation='source-over'; xb.clearRect(0,0,h.w,h.h);
    ${stamp}
    xb.globalCompositeOperation='source-in'; xb.fillStyle=__RIMCOL; xb.fillRect(0,0,h.w,h.h); xb.globalCompositeOperation='source-over';
    wc.save(); wc.setTransform(1,0,0,1,0,0);
    wc.drawImage(RIM.cb,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.drawImage(RIM.ca,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.restore();
  }`;
P['a07-B'] = { scene: 'loot', edits: [wrapDrawOp(rimClosePlus('xb.drawImage(RIM.ca,0,0,h.w,h.h,-Math.round(u),-Math.round(u),h.w,h.h);'), "var __RIMCOL='rgba(242,239,230,.35)';\n")] };
P['a07-C'] = { scene: 'loot', edits: [wrapDrawOp(rimClosePlus('for(var k=0;k<8;k++){ xb.drawImage(RIM.ca,0,0,h.w,h.h,Math.round(Math.cos(k*0.7854)*1.4*u),Math.round(Math.sin(k*0.7854)*1.4*u),h.w,h.h); }'), "var __RIMCOL='rgba(242,239,230,.55)';\n")] };
P['a07-D'] = { scene: 'loot', edits: [wrapDrawOp("function(orig,args){ var k=INK; INK='#3a2f28'; try{ return orig.apply(null,args); } finally{ INK=k; } }")] };

// ---------------------------------------------------------------- a08 gun and backpack
P['a08-A'] = { scene: 'duo', edits: [] };
const BIGPACK = [
  ['var pw=6+pk*5;', 'var pw=(6+pk*5)*1.25;'],
  ['rrF(x-fl*9-pw/2+leanX-1,ty-22,pw+2,11,3);', 'rrF(x-fl*9-pw/2+leanX-1,ty-22,pw+2,13.5,3);'],
  ['rrF(x-fl*9-pw/2+leanX,ty-21,pw,9,2);', 'rrF(x-fl*9-pw/2+leanX,ty-21,pw,11,2);'],
];
P['a08-B'] = { scene: 'duo', edits: [['var GUNK=1.3;', 'var GUNK=1.65;'], ...BIGPACK] };
P['a08-C'] = { scene: 'duo', edits: [
  ['  wc.drawImage(B.c,B.x0+ext,B.y0,B.w,B.h);', "  wc.drawImage(B.c,B.x0+ext,B.y0,B.w,B.h);\n  wc.globalAlpha=0.9; wc.fillStyle=(el&&ELEM[el])?ELEM[el].c:(rc||'#9da3a8'); wc.fillRect(D.grip+ext,D.rv[1]-0.5,D.tip-D.grip,2); wc.globalAlpha=1;"],
] };
P['a08-D'] = { scene: 'duo', edits: [['var GUNK=1.3;', 'var GUNK=2.0;'], ...BIGPACK] };

// ---------------------------------------------------------------- a09 shadow under the figure
P['a09-A'] = { scene: 'duo', edits: [] };
const SH1 = '  shadowE(x+1.5,y+1.5,10,4,.34);', SH2 = '  shadowE(x+6,y+2.5,6.5,2.5,.18);';
P['a09-B'] = { scene: 'duo', edits: [[SH1, '  shadowE(x+1.5,y+2,12.5,5,.5);'], [SH2, '  shadowE(x+7,y+3,8,3,.28);']] };
P['a09-C'] = { scene: 'duo', edits: [
  [SH1, "  wc.save(); wc.fillStyle='rgba(0,0,0,.30)'; wc.beginPath(); wc.ellipse(x+8.5,y+3.2,13,3.8,0.26,0,6.2832); wc.fill(); wc.fillStyle='rgba(0,0,0,.40)'; wc.beginPath(); wc.ellipse(x+0.5,y+1.6,7,2.5,0,0,6.2832); wc.fill(); wc.restore();"],
  [SH2, ''],
] };
P['a09-D'] = { scene: 'duo', edits: [wrapDrawOp(`function(orig,args,x,y){
    var T=wc.getTransform(), h=rimOpen({x:x,y:y,r:11},'#000000'); if(!h) return orig.apply(null,args);
    shadowE=function(){};
    try{ orig.apply(null,args); }catch(e){ rimAbort(); throw e; }
    var xb=RIM.xb, fx=T.a*x+T.e, fy=T.d*y+T.f;
    wc=h.w0; shadowE=h.sh0; RIM.on=0; RIM.h=null;
    xb.setTransform(1,0,0,1,0,0); xb.globalCompositeOperation='source-over'; xb.clearRect(0,0,h.w,h.h);
    xb.drawImage(RIM.ca,0,0,h.w,h.h,0,0,h.w,h.h);
    xb.globalCompositeOperation='source-in'; xb.fillStyle='rgba(0,0,0,.3)'; xb.fillRect(0,0,h.w,h.h); xb.globalCompositeOperation='source-over';
    wc.save(); wc.setTransform(1,0,0,1,0,0);
    wc.translate(fx+3*T.a,fy+4*T.d); wc.scale(1,0.55); wc.translate(-fx,-fy);
    wc.drawImage(RIM.cb,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.restore();
    wc.save(); wc.setTransform(1,0,0,1,0,0); wc.drawImage(RIM.ca,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h); wc.restore();
  }`)] };
