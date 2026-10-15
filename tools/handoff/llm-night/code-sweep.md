# Code sweep (chunks of 200 lines, model qwen2.5-coder:14b, 10-14 23:42, since )

LINE 18625: wc.save();
LINE 18631: wc.restore();
LINE 18709: blip('boom'); G.shake=Math.max(G.shake,10);
LINE 18726: blip('hit',undefined,undefined,'armor');
LINE 18730: foley('plateClack',null,null,{rate:0.72,g:1.15});
LINE 18731: foley('strapRip',null,null,{off:0.1,dur:0.12,g:0.5,rate:1.5,at:0.04,local:1});
LINE 19804: calls `blipMine` with undefined as the third argument.
LINE 19805: calls `sfx` with undefined as the second and third arguments if `fromPlayer` is false.
LINE 19823: accesses `G.player.wep.id` without checking if `G.player.wep` is null or undefined.
LINE 19879: uses `ival(G.bag[i])` which might return undefined, leading to NaN in calculations.
LINE 19907: uses bitwise OR (`|`) on a potentially non-numeric value from ARCADE.pot.
LINE 29206: A try/catch that swallows a whole per-frame draw or update.
LINE 29215: Assignment used where a comparison was meant, duplicate object keys, code after an unconditional return, a variable used before it is set. The condition `if(!_kw||_kw.id==='fists'||_ks[i][1]) continue;` seems to have a logical error as `_ks[i][1]` is being treated like a boolean without any comparison operator.
LINE 29307: Property access on a value that can be null or undefined in per-frame code without a guard. `closestRingDist(G.player)` might return null or undefined if G.player is not properly initialized.
LINE 29314: Property access on a value that can be null or undefined in per-frame code without a guard. `CFG.safeSlots` might not exist, causing an error when trying to use it.
LINE 29350: Property access on a value that can be null or undefined in per-frame code without a guard. `G.freeKit`, `G.spawnGun`, and `FREEKIT_GUN` might not exist, causing errors when trying to use them.
LINE 33201: Possible NaN or undefined values reaching canvas calls (arc, createRadialGradient, drawImage, fillText positions).
LINE 33258: A try/catch that swallows a whole per-frame draw or update.
LINE 33400: Variable used before it is set (LF).
LINE 36240: Assignment used where a comparison was meant, duplicate object keys, code after an unconditional return, a variable used before it is set.
LINE 36278: Property access on a value that can be null or undefined in per-frame code without a guard.
LINE 36291: Possible NaN or undefined values reaching canvas calls (arc).
LINE 36305: Assignment used where a comparison was meant, duplicate object keys, code after an unconditional return, a variable used before it is set.
LINE 36342: A try/catch that swallows a whole per-frame draw or update.
LINE 42208: try{ renderStage(); }catch(_e){} - A try/catch that swallows a whole per-frame draw or update.
LINE 42361: left=+left||0; if(!(left>0)) return false; - Possible NaN or undefined values reaching canvas calls (clockPopIn).
LINE 42378: for(i=0;i<MARKS.length;i++) if(prev>MARKS[i]&&MARKS[i]>=now) tlNow=MARKS[i]; - Assignment used where a comparison was meant.
LINE 42396: var _K='['+keyLabel('KeyX','X')+']'; - Variable used before it is set (keyLabel).
LINE 42613: Duplicate object key 'hero'.
LINE 42621: try/catch that swallows a whole per-frame draw or update.
LINE 42759: Variable `m` used before it is set (assuming `document.querySelectorAll('.modal.on')` returns an empty array).
LINE 42800: Code after an unconditional return.
