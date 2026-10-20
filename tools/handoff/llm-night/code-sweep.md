# Code sweep (chunks of 200 lines, model qwen2.5-coder:14b, 10-20 00:51, since 42d60d03)

LINE 46003: calls or reads of names from removed systems (UNITPLURAL, UNITNAME)
LINE 46006: calls or reads of names from removed systems (ITEMS)
LINE 46015: try/catch that swallows a whole per-frame draw or update
LINE 46028: try/catch that swallows a whole per-frame draw or update
LINE 46073: try/catch that swallows a whole per-frame draw or update
LINE 46652: ctx.fillText(sm.helped?'SURVIVOR':'SURVIVOR (NEEDS)',smx,smy-11*_MZ); ctx.textAlign='left'; - Duplicate assignment of ctx.textAlign.
LINE 46703: for(var _tw=1;_tw<G.trail.length;_tw++) ctx.lineTo(ox+G.trail[_tw].x*sc,oy+G.trail[_tw].y*sc); - Possible NaN or undefined values reaching canvas calls (arc).
LINE 46725: var _hgf=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11; - Potential issue with ctx.font being null or undefined.
LINE 46739: if(_zHold) _fl=0.55+0.45*Math.sin(G.t*10); else if(_zAct) _fl=0.65+0.35*Math.sin(G.t*4); - Possible NaN or undefined values reaching canvas calls (arc).
LINE 46789: var _pv=function(a,r){ return [_pmx+Math.cos(_pf+a)*r*_pmz, _pmy+Math.sin(_pf+a)*r*_pmz]; }; - Potential issue with Math.cos and Math.sin receiving NaN or undefined values
