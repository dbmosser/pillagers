import fs from 'node:fs';
import { mkrec, WORK, mkgame } from './lib.mjs';
const js = fs.readFileSync(WORK + '/cap-motion.js', 'utf8');
mkrec(WORK + '/rec-cap-motion.json', [{ name: 'capmotion', screen: 'P1 sprite sheets for the motion snippets', before: 'staged by cap-motion.js', query: '', expect: 'window.__capDone===true', js }]);
// the capture page: the fixture with the walk numbers of drawOp read from window.__MOT when it is set
mkgame('a11-cap', [
  { from: 'var amp=moving?(sprint?4.2:2.9):0;', to: 'var amp=window.__MOT?window.__MOT.amp:(moving?(sprint?4.2:2.9):0);' },
  { from: 'var liftA=moving?Math.max(0,Math.sin(ph))*(sprint?3.4:2.2):0;', to: 'var liftA=moving?Math.max(0,Math.sin(ph))*(window.__MOT?window.__MOT.lift:(sprint?3.4:2.2)):0;' },
  { from: 'var liftB=moving?Math.max(0,-Math.sin(ph))*(sprint?3.4:2.2):0;', to: 'var liftB=moving?Math.max(0,-Math.sin(ph))*(window.__MOT?window.__MOT.lift:(sprint?3.4:2.2)):0;' },
  { from: 'var bobY=moving?Math.abs(Math.sin(ph))*1.5:Math.sin(ph*.35)*.5;', to: 'var bobY=window.__MOT?window.__MOT.bob:(moving?Math.abs(Math.sin(ph))*1.5:Math.sin(ph*.35)*.5);' },
  { from: 'var leanX=sprint?fl*1.6:(moving?fl*.7:0);', to: 'var leanX=window.__MOT?fl*window.__MOT.lean:(sprint?fl*1.6:(moving?fl*.7:0));' },
  { from: '  var hx2=x+leanX;', to: '  var hx2=x+leanX+(window.__MOT&&window.__MOT.head?fl*window.__MOT.head:0); var _tiltOn=(window.__TILT&&st.hero)?1:0; if(_tiltOn){ wc.save(); wc.translate(hx2,ty-23); wc.rotate(window.__TILT); wc.translate(-hx2,-(ty-23)); }' },
  { from: "  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks", to: "  if(_tiltOn) wc.restore();" + String.fromCharCode(10) + "  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks" }
], { __OPT: 'cap' });
console.log('ok');
