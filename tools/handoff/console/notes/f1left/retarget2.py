# cw-f1left retarget of 34.89 (his order of 2026-10-27, "should be over on the left, not the middle of the screen"; he picked a: "just the f1
# key list moves to the left side"). Where legLeftDock exists (the new build) the opened list must stand on the left dock with no feed line
# under it, and may rest in the medal spot only where the dock dropped there; the old build keeps the chip claims.
# usage: python retarget2.py PATH_TO_mkfixture.ps1   (each replacement must match exactly once, or nothing is written)
import sys
p = sys.argv[1]
s = open(p, 'r', encoding='utf-8', newline='').read()
R = '/* retarget (cw-f1left, his order of 2026-10-27 "should be over on the left, not the middle of the screen"): '
pairs = [
 ("if(FEEDBOX&&FEEDBOX.on&&hit(box,FEEDBOX)) bad.push(tag+n+' '+R(box)+' is over the feed '+R(FEEDBOX));",
  "var lft=(n==='the opened list'&&typeof legLeftDock==='function'&&legLeftDock())?legLeftDock():null;   " + R + "the opened list stands at the left edge in the feed zone and the feed lines step right of it, so the test is the lines; it rests in the medal spot only where the dock dropped there */\n"
  "       if(lft){ if((FEEDBOX.rows||[]).some(function(q){ return hit(box,q); })) bad.push(tag+'a feed line is under '+n+' '+R(box)); }\n"
  "       else if(FEEDBOX&&FEEDBOX.on&&hit(box,FEEDBOX)) bad.push(tag+n+' '+R(box)+' is over the feed '+R(FEEDBOX));"),
 ("if(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on&&hit(box,MEDALBOX)) bad.push(tag+n+' '+R(box)+' is over the medal spot '+R(MEDALBOX));",
  "if(typeof MEDALBOX==='object'&&MEDALBOX&&MEDALBOX.on&&hit(box,MEDALBOX)&&!(lft&&FEEDBOX&&lft.b>FEEDBOX.y+FEEDBOX.h+0.5)) bad.push(tag+n+' '+R(box)+' is over the medal spot '+R(MEDALBOX));"),
 ("if(L.x<chip.x-2||L.x>chip.x+chip.w) bad.push(tag+'the opened list '+R(L)+' does not start on the chip '+R(chip));",
  "if(typeof legLeftDock==='function'&&legLeftDock()){ var D5=legLeftDock(); if(Math.abs(L.x-D5.x)>2||Math.abs(L.y+L.h-D5.b)>2) bad.push(tag+'the opened list '+R(L)+' does not stand on the left dock at '+Math.round(D5.x)+', bottom '+Math.round(D5.b)); }   " + R + "the list no longer grows from the chip; it stands on the left dock */\n"
  "           else { if(L.x<chip.x-2||L.x>chip.x+chip.w) bad.push(tag+'the opened list '+R(L)+' does not start on the chip '+R(chip));"),
 ("bad.push(tag+'the opened list '+R(L)+' does not end on the chip row '+R(chip)+' or on the use bar '+R(ub3.u));",
  "bad.push(tag+'the opened list '+R(L)+' does not end on the chip row '+R(chip)+' or on the use bar '+R(ub3.u)); }"),
 ("if(ch2&&ch2.x+L2.w<=W*0.47&&(L2.x<ch2.x-2",
  "if(typeof legLeftDock==='function'&&legLeftDock()){ var D6=legLeftDock(); if(Math.abs(L2.x-D6.x)>2||Math.abs(L2.y+L2.h-D6.b)>2) bad.push(tg+'the opened list '+R(L2)+' does not stand on the left dock at '+Math.round(D6.x)+', bottom '+Math.round(D6.b)); }   " + R + "it stands on the left dock, not on the chip */\n"
  "           else if(ch2&&ch2.x+L2.w<=W*0.47&&(L2.x<ch2.x-2"),
]
for a, b in pairs:
    n = s.count(a)
    if n != 1:
        sys.exit('anchor matched %d: %s' % (n, a[:90]))
    s = s.replace(a, b)
open(p, 'w', encoding='utf-8', newline='').write(s)
print('retargeted', len(pairs))
