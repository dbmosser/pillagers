# python3 mklean.py SRC DST : the game plus one game-scope eval hook placed where the fixture puts its hooks (no test wrappers), for profiling
import sys
s=open(sys.argv[1],newline='').read(); nd='// ================================================================ boot'
assert s.count(nd)==1, s.count(nd)
i=s.index(nd)
open(sys.argv[2],'w',newline='').write(s[:i]+"window.__gx=function(s){ return eval(s); };   // audit probe only, never shipped\n"+s[i:])
