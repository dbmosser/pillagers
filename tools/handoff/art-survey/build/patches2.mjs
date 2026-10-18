// SECOND PASS (2026-10-18 evening): the options the art director sent back. These entries replace the ones of the same name in patches.mjs.
// run.mjs reads this file (it imports patches.mjs first and then overrides).
import { P, wrapDrawOp } from './patches.mjs';
export { P };

const RINGCALL = 'if(_SEAT>=0) drawSeatRing(x,y,_SEAT);';

// the soft strip a held gun throws on the body goes into the scratch canvas in rim mode and gets outlined with the rim colour (the "orange gun shadow").
// In rim mode it is now drawn on the world canvas instead, under the body, exactly where today's version puts it.
const STRIP_OLD = "  wc.fillStyle='rgba(0,0,0,.26)'; wc.fillRect(D.rv[0]+ext+1,D.by+1.2,D.tip-D.rv[0]-3,D.rv[1]+D.rv[3]-D.by+0.4);";
const STRIP_NEW = "  if(RIM.on&&RIM.h){ var __h=RIM.h, __M=wc.getTransform(), __w=__h.w0; __w.save(); __w.setTransform(new DOMMatrix([1,0,0,1,__h.sx,__h.sy]).multiply(__M)); __w.fillStyle='rgba(0,0,0,.26)'; __w.fillRect(D.rv[0]+ext+1,D.by+1.2,D.tip-D.rv[0]-3,D.rv[1]+D.rv[3]-D.by+0.4); __w.restore(); }\n"
  + "  else { wc.fillStyle='rgba(0,0,0,.26)'; wc.fillRect(D.rv[0]+ext+1,D.by+1.2,D.tip-D.rv[0]-3,D.rv[1]+D.rv[3]-D.by+0.4); }";
const STRIPFIX = [STRIP_OLD, STRIP_NEW];

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

// ---- a04: the three builds, scene trio2 (all three aim up and to the right, so the gun leaves the body clear). A and C are shot again in the same scene so the three stay identical.
P['a04-A'] = { scene: 'trio2', edits: [] };
P['a04-B'] = { scene: 'trio2', edits: P['a04-B'].edits };
P['a04-C'] = { scene: 'trio2', edits: P['a04-C'].edits };

// ---- a05-C: richer colour on the hat, vest, pads, pack, boots and coat only (skin, hair and face untouched), and trim lines about 2.5 times as thick
const RICH = 'saturate(1.9) contrast(1.06)';
P['a05-C'] = { scene: 'duo', edits: [
  wrapDrawOp("function(orig,args){ wc.save(); wc.filter='" + RICH + "'; try{ return orig.apply(null,args); } finally{ wc.restore(); } }"),
  // the head: skin, hair and face with no filter; the hat with it
  ['  var hx2=x+leanX;', "  var hx2=x+leanX; wc.filter='none';"],
  ['    // HEADGEAR. Sits on top of the fringe and the face because that is where a', "    wc.filter='" + RICH + "';\n    // HEADGEAR. Sits on top of the fringe and the face because that is where a"],
  // trims, thicker: boot collars, pack flap, hat bands, helmet lamp, vest buckles and straps
  ['wc.fillStyle=_SCH.a; wc.fillRect(x-6.4+swing2*.5,ty-6.5-liftB,4.8,1.0); wc.fillRect(x+1.6+swing*.5,ty-6.5-liftA,4.8,1.0);', 'wc.fillStyle=_SCH.a; wc.fillRect(x-6.4+swing2*.5,ty-7.3-liftB,4.8,2.6); wc.fillRect(x+1.6+swing*.5,ty-7.3-liftA,4.8,2.6);'],
  ['wc.fillRect(x-6.0+swing2*.5,ty-6.6-liftB*.5,3.6,0.9); wc.fillRect(x+2.2+swing*.5,ty-6.6-liftA*.5,3.6,0.9);', 'wc.fillRect(x-6.0+swing2*.5,ty-7.2-liftB*.5,3.6,2.2); wc.fillRect(x+2.2+swing*.5,ty-7.2-liftA*.5,3.6,2.2);'],
  ['wc.fillRect(x-6.4+swing2*.5,ty-10.3-liftB*.5,4.6,1.0); wc.fillRect(x+1.8+swing*.5,ty-10.3-liftA*.5,4.6,1.0);', 'wc.fillRect(x-6.4+swing2*.5,ty-11.0-liftB*.5,4.6,2.4); wc.fillRect(x+1.8+swing*.5,ty-11.0-liftA*.5,4.6,2.4);'],
  ['wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-20.4,pw-1.2,1.2);', 'wc.fillRect(x-fl*9-pw/2+leanX+0.6,ty-21.2,pw-1.2,3.0);'],
  ["wc.fillStyle=_hA;       wc.fillRect(hx2-7.8,ty-40.6,15.6,1.4);", "wc.fillStyle=_hA;       wc.fillRect(hx2-7.8,ty-41.6,15.6,3.4);"],
  ["wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2-7.2,ty-40.4,14.4,1.1);", "wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2-7.2,ty-41.0,14.4,2.8);"],
  ["wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2+fl*3.8-1.5,ty-46.1,3.0,2.4);", "wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2+fl*3.8-2.1,ty-47.1,4.2,3.6);"],
  ['wc.fillRect(cx-R.w/2+0.9,ty+R.y+1.4,R.w-2.4,0.9);', 'wc.fillRect(cx-R.w/2+0.9,ty+R.y+1.4,R.w-2.4,2.3);'],
  ['wc.fillStyle=A; wc.fillRect(x1-0.4,y1-0.6,2.0,2.0);', 'wc.fillStyle=A; wc.fillRect(x1-0.8,y1-1.0,3.0,4.4);'],
  ['wc.fillStyle=A; wc.fillRect(cx-1.1,ty-17.9,2.2,2.2);', 'wc.fillStyle=A; wc.fillRect(cx-1.6,ty-18.4,3.2,4.6);'],
] };

// ---- a06-B: the coloured outline only. No ring, no badge; the gun strip no longer rides into the outline
P['a06-B'] = { scene: 'duoparty', edits: [
  [RINGCALL, '/* no ring, no badge */'],
  STRIPFIX,
  wrapDrawOp("function(orig,args,x,y,face,ph,coat,pk,muzzle,mode,iv,st){ var sm=seatMarkOf(st), h=(sm>=0)?rimOpen({x:x,y:y,r:11},SEATCOL[sm&3]):null; try{ return orig.apply(null,args); } finally{ if(h) rimClose(h); } }"),
] };
// a06-C is not shot again; only its zoom boxes change (insets.mjs)

// ---- a06-D: the whole coat in the player's colour. Player 1 amber, player 2 cyan, strong; the palette of those two schemes is rewritten in this copy
P['a06-D'] = { scene: 'duoparty', edits: [
  [RINGCALL, '/* no ring */'],
  ['  S=id?SCHEMES[id]:null; if(!S) return null;', "  var _sm=st.hero?seatHere():((st.own&&typeof st.own.seat==='number')?(st.own.seat|0):-1); if(_sm===0) id='schember'; else if(_sm===1) id='schfrost';\n  S=id?SCHEMES[id]:null; if(!S) return null;"],
  ["schember:   {p:'#a8501f',s:'#2a2224',a:'#ffb52e'},", "schember:   {p:'#f5a812',s:'#8c5208',a:'#fff2bd'},"],
  ["schfrost:   {p:'#4a7f9f',s:'#1a2733',a:'#c4f0ff'},", "schfrost:   {p:'#1fc6f2',s:'#0a5e7c',a:'#e9fcff'},"],
] };

// ---- a07: four outline treatments on the cluttered floor (scene busy)
P['a07-A'] = { scene: 'busy', edits: [] };
P['a07-B'] = { scene: 'busy', edits: [STRIPFIX, wrapDrawOp(rimClosePlus('xb.drawImage(RIM.ca,0,0,h.w,h.h,-Math.round(1.7*u),-Math.round(1.7*u),h.w,h.h);'), "var __RIMCOL='rgba(246,243,232,.95)';\n")] };
P['a07-C'] = { scene: 'busy', edits: [STRIPFIX, wrapDrawOp(rimClosePlus('for(var k=0;k<8;k++){ xb.drawImage(RIM.ca,0,0,h.w,h.h,Math.round(Math.cos(k*0.7854)*1.4*u),Math.round(Math.sin(k*0.7854)*1.4*u),h.w,h.h); }'), "var __RIMCOL='rgba(242,239,230,.6)';\n")] };
P['a07-D'] = { scene: 'busy', edits: [wrapDrawOp("function(orig,args){ var k=INK; INK='#3a2f28'; try{ return orig.apply(null,args); } finally{ INK=k; } }")] };

// ---- a09-D: a clear raider-shaped cut-out lying on the ground. The body is drawn once into the scratch canvas, then stamped flat: turned over about the feet (it lies on the floor, the
// head away from the feet), squashed to 42 percent and leaned to the lower right (the light is top left), black at .46. The two soft lobes are gone.
P['a09-D'] = { scene: 'duo', edits: [STRIPFIX, wrapDrawOp(`function(orig,args,x,y){
    var T=wc.getTransform(), h=rimOpen({x:x,y:y,r:11},'#000000'); if(!h) return orig.apply(null,args);
    shadowE=function(){};
    try{ orig.apply(null,args); }catch(e){ rimAbort(); throw e; }
    var xb=RIM.xb, fx=T.a*x+T.e, fy=T.d*y+T.f;
    wc=h.w0; shadowE=h.sh0; RIM.on=0; RIM.h=null;
    xb.setTransform(1,0,0,1,0,0); xb.globalCompositeOperation='source-over'; xb.clearRect(0,0,h.w,h.h);
    xb.drawImage(RIM.ca,0,0,h.w,h.h,0,0,h.w,h.h);
    xb.globalCompositeOperation='source-in'; xb.fillStyle='#000'; xb.fillRect(0,0,h.w,h.h); xb.globalCompositeOperation='source-over';
    wc.save(); wc.setTransform(1,0,0,1,0,0); wc.globalAlpha=0.46;
    wc.translate(fx,fy); wc.transform(1,0,-0.62,-0.42,0,0); wc.translate(-fx,-fy);
    wc.drawImage(RIM.cb,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.restore();
    wc.save(); wc.setTransform(1,0,0,1,0,0); wc.drawImage(RIM.ca,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h); wc.restore();
  }`)] };
