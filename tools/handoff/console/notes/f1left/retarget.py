# cw-f1left retargets (his order of 2026-10-27, "should be over on the left, not the middle of the screen"; he picked a: "just the f1 key list
# moves to the left side"). Each older check keeps the claims that still hold (clear of the vitals, no feed line under the list, text inside
# its panel, the anchor holds) and drops "the list stands by the belt". Every new form holds on the old build and on the new one.
# usage: python retarget.py PATH_TO_mkfixture.ps1   (each replacement must match exactly once, or nothing is written)
import sys
p = sys.argv[1]
s = open(p, 'r', encoding='utf-8', newline='').read()
R = '/* retarget (cw-f1left, his order of 2026-10-27 "should be over on the left, not the middle of the screen"): '
pairs = [
 # 34.54
 ("if(inLL(lb,'the opened list')) bad.push(inLL(lb,'the opened list'));",
  "if(!lb||!(lb.w>0)||lb.x+lb.w>W/2||lb.y+lb.h<H/2) bad.push('the opened list is not low on the left: '+(lb?Math.round(lb.x)+','+Math.round(lb.y)+' '+Math.round(lb.w)+'x'+Math.round(lb.h):'no box'));   " + R + "the list stands at the left edge in the feed place, so its top may sit just over the middle; it is in the left half with its bottom in the lower half */"),
 ("if(hit(lb,fb)) bad.push('the opened list overlaps the feed');",
  "if((fb.rows||[]).some(function(q){ return hit(lb,q); })) bad.push('a feed line is under the opened list');   " + R + "the list stands in the feed zone and the feed lines step right of it, so the test is the lines, not the zone */"),
 ("if(hh&&(lb.x<hh.x-2||lb.x>hh.x+hh.w)) bad.push('the opened list does not start on the folded chip: '+Math.round(lb.x)+' vs '+Math.round(hh.x)+' to '+Math.round(hh.x+hh.w));",
  R + "the opened list no longer grows from the folded chip on the belt; it stands at the left edge, which check cw-f1left tests */"),
 # 34.78
 ("if(L.y<H/2) bad.push('the list box starts above the lower half: y '",
  "if(L.y+L.h<H/2) bad.push('the list box ends above the lower half: y '"),
 ("if(fb&&fb.on&&hitR(L,fb)) bad.push('the opened list overlaps the left log');",
  "if(fb&&(fb.rows||[]).some(function(q){ return hitR(L,q); })) bad.push('a left log line is under the opened list');   " + R + "the list stands in the feed zone and its lines step right of it; its bottom, not its top, is in the lower half */"),
 # 33.15
 ("_ab=(_lc&&lb&&typeof legDock==='function')?legDock(_lc).b:null;",
  "_ab=(lb&&typeof legLeftDock==='function'&&legLeftDock())?legLeftDock().b:(_lc&&lb&&typeof legDock==='function')?legDock(_lc).b:null;   " + R + "the list rests on legLeftDock, at the left edge, where it exists */"),
 # 27.26
 ("if(hit(L,F)) bad.push('the controls list ('+r(L)+') is on the feed ('+r(F)+')');",
  "if((F.rows||[]).some(function(q){ return hit(L,q); })) bad.push('a feed line is under the controls list ('+r(L)+')');   " + R + "the list stands at the left edge in the feed zone, and the feed lines step right of it */"),
 ("if(L.x<F.x+F.w-0.5) bad.push('the controls list does not stand right of the feed');",
  R + "it no longer stands right of the feed */"),
 # 9.93
 ("if(d.y<box.y||d.y>box.y+box.h||d.x<box.x-1) continue;",
  "if(d.y<box.y||d.y>box.y+box.h||d.x<box.x-1||d.x>=box.x+box.w) continue;   " + R + "the feed lines now stand beside the list at its height; text that starts right of the panel is not its row */"),
 # 9.83
 ("var _ld=(typeof legDock==='function'&&typeof legChipSpot==='function')?legDock(legChipSpot()):null; if(_ld) body={y:_ld.b};",
  "var _ld=(typeof legLeftDock==='function'&&legLeftDock())?legLeftDock():(typeof legDock==='function'&&typeof legChipSpot==='function')?legDock(legChipSpot()):null; if(_ld) body={y:_ld.b};   " + R + "the list anchors on legLeftDock, at the left edge, where it exists */"),
]
for a, b in pairs:
    n = s.count(a)
    if n != 1:
        sys.exit('anchor matched %d: %s' % (n, a[:90]))
    s = s.replace(a, b)
open(p, 'w', encoding='utf-8', newline='').write(s)
print('retargeted', len(pairs))
