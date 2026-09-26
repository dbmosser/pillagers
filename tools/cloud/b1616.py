import json, os, gen
from gen import patch, fixture
SRC = open(os.path.join(gen.H, '..', '..', 'dark_raiders.html'), encoding='utf-8').read().split('\n')
o = {x['id']: x for x in json.load(open('/tmp/tx/keep.json'))}
M = json.load(open('/tmp/tx/map.json'))
bylines = {}
for k, v in M.items():
    x = o[int(k)]; ln = x['ln'] - 1
    cur = bylines.get(ln, SRC[ln])
    q = "'" + x['t'] + "'"
    assert q in cur, (k, x['t'][:40])
    bylines[ln] = cur.replace(q, "'" + v + "'", 1)
edits = []
for ln in sorted(bylines):
    old, new = SRC[ln], bylines[ln]
    if SRC.count(old) > 1:
        old, new = old + '\n' + SRC[ln + 1], new + '\n' + SRC[ln + 1]
        assert '\n'.join(SRC).count(old) == 1, ln
    edits.append((old, new))
patch(1616, edits, "PLAIN GAME LANGUAGE, THE LARGER PASS. His order. About eighty on-screen lines that explained mechanics like a rulebook now read the way a game says them: raid messages, the stash and loadout screens, the Mainframe, the terms, the reputation card, the PARTY window, Settings hints. His TXSHIP sentences, the pillager and hire barks, the lore and every line a check reads word for word are untouched. Text only. Check 16.16 fails on v16.15",
"# PLAIN GAME LANGUAGE, THE LARGER PASS. His order of 2026-09-26. Text only; TXSHIP keys untouched.\n")
NEW = [v for v in M.values() if len(v) > 20][:12]
fixture(1616, r"""  {v:'16.16',what:'plain game language, the larger pass: the rewritten lines are in the build, the rulebook versions are gone,',
   run:function(){
     var src='', bad=[], i, OLD, NEW;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     OLD=['No throwable you carry is on your','No legs left to roll with','Auto-jog arms from a standstill','Type what to call them first','Everyone with the','Point at an item in the stash, then press','Let go too soon','Hold it down for a second','Linked. Saying hello to the host'];
     NEW=['No throwable on your tactical belt.','Too tired to roll.','Stop first, then tap CAPS to auto-jog.','Enter a name first.','Released too early. Hold for one second.','Hold for one second to confirm.','Connected. Joining the host.'];
     for(i=0;i<OLD.length;i++) if(src.indexOf(OLD[i])>=0) bad.push('the old line with "'+OLD[i]+'" is still in the build');
     for(i=0;i<NEW.length;i++) if(src.indexOf(NEW[i])<0) bad.push('the line "'+NEW[i]+'" is missing');
     return bad.length?bad.join('; '):null; }},
""")
print(len(edits), 'line edits')

_p = os.path.join(gen.H, 'f1616.ps1'); _t = open(_p, encoding='ascii').read()
MK = open(os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
extra = ''
for a, b in [("if(!/extracted, minus everything you carried in/.test(html))", "if(!/extracted minus value carried in/.test(html))"),
             ("return /destroyed\\. It has stopped listening/.test(t);", "return /destroyed\\. It dropped a cache/.test(t);")]:
    ln = [x for x in MK if a in x]; assert len(ln) == 1, (a, len(ln))
    extra += gen.sub(ln[0], ln[0].replace(a, b))
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
