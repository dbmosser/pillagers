// node redo/shootx.mjs OUTNAME SCREEN PAGE  : shoots PAGE (game/PAGE.html) with screen SCREEN into shots/OUTNAME
import { shoot } from './lib.mjs';
const [o, sc, pg] = process.argv.slice(2);
const r = shoot(o, sc, undefined, pg);
console.log(o + ' ' + (r.ok ? 'shot' : 'FAILED ' + r.err) + ' | ' + r.note.slice(0, 200));
