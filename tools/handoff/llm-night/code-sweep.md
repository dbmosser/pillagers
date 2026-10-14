# Code sweep (chunks of 200 lines, model qwen2.5-coder:14b, 10-14 01:55, since )

LINE 4601: Assignment used where a comparison was meant (`if(!S) return B;` should be `if(S === null || S === undefined) return B;`).
LINE 4603: try/catch that swallows a whole per-frame draw or update.
LINE 4728: Property access on a value that can be null or undefined in per-frame code without a guard (`SND_DOWN.mine++;` should check if `SND_DOWN` is defined).
LINE 4730: Property access on a value that can be null or undefined in per-frame code without a guard (`SND_DOWN.mate++;` should check if `SND_DOWN` is defined).
LINE 4751: Possible NaN or undefined values reaching canvas calls (fillText positions) (`R.lp=Math.round(clamp(1500-600*d/900,900,1500));`).
LINE 5207: try/catch that swallows a whole per-frame draw or update.
LINE 5213: property access on a value that can be null or undefined in per-frame code without a guard (G.map).
LINE 5231: function crouchHeld() uses G.crouchTog without checking if G is defined.
LINE 5241: variable bsh used before it is set, assuming it's supposed to be p.bush based on context.
LINE 5308: canSee function call with undefined parameters if G.vseg is not defined.
LINE 6034: assignment used where a comparison was meant, duplicate object keys, code after an unconditional return, a variable used before it is set
LINE 6129: property access on a value that can be null or undefined in per-frame code without a guard
LINE 6157: calls or reads of names from removed systems (taunt, TAUNT, voxBark, voxCall, VOX_ANN, GO_SEC, goTick, drawGoCount, doEmote, EMOTES, emoteBubble, MACH_LOOP, stowLine)
LINE 14004: try{ renderSettings(); }catch(_ue){} - A try/catch that swallows a whole per-frame draw or update.
LINE 14034: window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false; if(keyRemap(e.code)==='AltLeft'&&state==='raid') e.preventDefault(); /* v25.xx (altstatus): and its release, or the browser takes the menu focus */ if((e.code==='ControlLeft'||e.code=== - Code after an unconditional return.
LINE 14093: var GB=G.bagCells||[]; - Property access on a value that can be null or undefined in per-frame code without a guard.
LINE 14128: for(var dc=0;dc<G.bagCells.length;dc++){ - Property access on a value that can be null or undefined in per-frame code without a guard.
LINE 14176: var _pinHand=!!(_hs2&&_HC2.i<GUNKEYS&&_hs2.kind==='gun'&&_hs2.equipped&&_hs2.icon&&_hs2.icon!=='fists'&&G.player); - Property access on a value that can be null or undefined in per-frame code without a guard.
LINE 17408: A try/catch that swallows a whole per-frame draw or update.
LINE 17432: Assignment used where a comparison was meant, `ik?4.0:1.9` should be `ik===true?4.0:1.9`.
LINE 17563: Property access on a value that can be null or undefined in per-frame code without a guard, `G.shake=Math.max(G.shake,Math.min(6,1.8+amt*0.16));` should check if G is defined.
LINE 17592: Duplicate object keys, `k:src,w:recapWeapon(src,srcName)` might have a typo or intended to be different keys.
LINE 17600: Code after an unconditional return, which is not a bug but could indicate potential dead code.
LINE 32205: try{ gfxScreen(dt); }catch(_gsc){} - This try/catch block swallows any errors that occur in the per-frame draw or update function `gfxScreen`.
LINE 32207: try{ drawHUD(); } finally { GFXWT=null; } - This try/finally block also swallows any errors that occur in the per-frame draw or update function `drawHUD`, and it sets `GFXWT` to null regardless of whether an error occurs.
LINE 32400: wc.drawImage(BUZZTR,0,0); - If `BUZZTR` is not properly initialized or has a width or height of 0, this could result in drawing nothing on the canvas.
LINE 34276: Possible NaN or undefined values reaching canvas calls (arc, createRadialGradient, drawImage, fillText positions).
LINE 34358: Property access on a value that can be null or undefined in per-frame code without a guard.
LINE 34361: Assignment used where a comparison was meant.
LINE 34370: Variable used before it is set (s2).
LINE 34395: A try/catch that swallows a whole per-frame draw or update.
LINE 37805: calls or reads of names from removed systems (taunt)
LINE 37806: calls or reads of names from removed systems (tb)
LINE 37821: property access on a value that can be null or undefined in per-frame code without a guard (G.map.zones)
LINE 37842: possible NaN or undefined values reaching canvas calls (fillText positions) (L.x, L.y)
LINE 37905: variable used before it is set (_hdY)
LINE 50427: `NET.up.length` is accessed without checking if `NET.up` is an array.
LINE 50438: `spotFree(m,x,y,22)` and `shutRoomAt(m,x,y)` are called with `m` which might be null or undefined.
LINE 50441: `m.spawns.length` is accessed without checking if `m.spawns` is an array.
LINE 50486: `ringD(s.x,s.y)` and `foeD(s.x,s.y)` are called with `s` which might be null or undefined.
LINE 50537: `G.deathBeat=null; p.dying=false; p.downed=false; p.downT=0; p.pendKiller=null; p.prep=null; p.prepA=null;` is duplicated code.
