// node redo/shootgame.mjs NAME[:screen] ...  shoots game/NAME.html (screen defaults to NAME) with the redo recipes at 1080 (or add :res via env RES=1080,4k) -> shots/NAME/
import { shoot } from './lib.mjs';
for (const a of process.argv.slice(2)) {
  const [name, screen] = a.split(':');
  const r = shoot(name, screen || name);
  console.log(name + ' ' + (r.ok ? 'shot' : 'FAILED ' + r.err) + ' | ' + r.note.slice(0, 300));
}
