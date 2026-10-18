// redo/a30.mjs : game/a30-C.html = the night light pass with a much lower ambient (the sheet), the lamps, flashes and a small
// personal glow keeping their old strength (they were scaled by the sheet's darkness, so a darker sheet used to light the ground MORE).
// node redo/a30.mjs [a] [plr]   (a = the sheet's darkness, default .80 ; plr = the radius of the raider's own glow in world units, default 48)
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';
const a = process.argv[2] || '0.80', plr = process.argv[3] || '48';
buildCopy('a30-C', [
  ['function gfxLightPass(dt,BR,o){', 'var ART30={a:' + a + ',plr:' + plr + ',pl:1};\nfunction gfxLightPass(dt,BR,o){'],
  ['a=day?clamp(DAY_SHEET/BR,.02,.2):clamp(NIGHT_SHEET/BR,.05,.82);', 'a=day?clamp(DAY_SHEET/BR,.02,.2):clamp(NIGHT_SHEET/BR,.05,.82); var aL=a; if(!day&&ART30.a>0) a=ART30.a;'],
  ["put(gfxLightSpr(L.c,'map'),L.x,L.y,L.r*fk,2*a*.85*L.i);", "put(gfxLightSpr(L.c,'map'),L.x,L.y,L.r*fk,2*aL*.85*L.i);"],
  ['    plr=100*Math.min(1.5,BR);', '    plr=ART30.plr*Math.min(1.5,BR);'],
  ['put(wspr,p.x,p.y,plr,2*a*clamp(.5*BR,.3,.9));', 'put(wspr,p.x,p.y,plr,2*aL*clamp(.5*BR,.3,.9)*ART30.pl);'],
  ['put(wspr,M[k].x,M[k].y,plr,2*a*.40);', 'put(wspr,M[k].x,M[k].y,plr,2*aL*.40*ART30.pl);'],
  ['put(wspr,F.x,F.y,frr,2*a*.9*fr);', 'put(wspr,F.x,F.y,frr,2*aL*.9*fr);'],
  ["wc.fillStyle='rgb('+Math.round(S[0]*a+sp[0])+','+Math.round(S[1]*a+sp[1])+','+Math.round(S[2]*a+sp[2])+')';", "wc.fillStyle='rgb('+Math.round(S[0]*aL+sp[0])+','+Math.round(S[1]*aL+sp[1])+','+Math.round(S[2]*aL+sp[2])+')';"],
]);
const S = { 'a30-C': { from: 'a30-C' } };
fs.writeFileSync(new URL('screens-a30.json', import.meta.url), JSON.stringify(S, null, 1));
console.log('built a30-C a=' + a + ' plr=' + plr);
