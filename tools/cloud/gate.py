#!/usr/bin/env python3
# gate.py KEY [--base REV] [--draft FILE] [--new X.YY] [--out DIR]
# Python port of tools/handoff/drafts/gen-draft.ps1 + dryrun.ps1 for the cloud (no PowerShell needed for this step).
# Applies draft-KEY.json to a COPY of the game at REV (default HEAD) and its check to a COPY of tools/mkfixture.ps1 at REV:
#   the edits (anchor/replacement; each anchor must match exactly once, whole lines, CRLF tolerant), 'v16.xx' in a replacement
#   becomes the new version, the VER bump, the DEVNOW now: line, and the check inserted above the previous version's check.
# Writes OUT/dry.html (patched game), OUT/prev.html (REV's game), OUT/mkfixture.ps1 (patched). Never touches the repo files.
# Exit 0 = applied, 1 = a gate failed (message starts with STOP).
import json, re, subprocess, sys, os, argparse
ap = argparse.ArgumentParser(); ap.add_argument('key'); ap.add_argument('--base', default='HEAD'); ap.add_argument('--draft'); ap.add_argument('--new'); ap.add_argument('--out', default='/tmp/pillagers-gate')
a = ap.parse_args()
R = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], text=True, cwd=os.path.dirname(os.path.abspath(__file__))).strip()
def stop(m): print('STOP: ' + m); sys.exit(1)
def show(path): return subprocess.check_output(['git', 'show', a.base + ':' + path], cwd=R).decode('utf-8')
dp = a.draft or os.path.join(R, 'tools/handoff/drafts/draft-%s.json' % a.key)
if not os.path.isfile(dp): stop('no draft file ' + dp)
d = json.load(open(dp, encoding='utf-8'))
for f in ('title', 'why', 'now', 'check', 'edits'):
    if not d.get(f): stop('draft field %s is missing' % f)
game = show('dark_raiders.html'); fx = show('tools/mkfixture.ps1')
m = re.search(r"var VER='([0-9]+\.[0-9]+)';", game)
if not m: stop('no var VER in the base game')
PV = m.group(1); pn = round(float(PV) * 100) if False else int(PV.split('.')[0]) * 100 + int(PV.split('.')[1])
V = a.new or '%d.%02d' % ((pn + 1) // 100, (pn + 1) % 100)
def ascii_ok(t):
    for ch in t:
        if ord(ch) > 126 or (ord(ch) < 32 and ch not in '\n\t\r'): return ord(ch)
    return 0
def pat(old): return r'\r?\n'.join(re.escape(l) for l in old.replace('\r', '').split('\n'))
s = game; n = 0
for i, e in enumerate(d['edits'], 1):
    an = e['anchor'].replace('\r', ''); rp = e['replacement'].replace('\r', '').replace('v16.xx', 'v' + V)
    for t in (an, rp):
        c = ascii_ok(t)
        if c: stop('edit %d has non-ASCII or control character code %d' % (i, c))
    if re.search(r"(?m)^'@", an) or re.search(r"(?m)^'@", rp): stop('edit %d: here-string terminator inside an edit' % i)
    p = pat(an); c = len(re.findall(p, s))
    if c != 1: stop('edit %d: anchor matched %d times: %s' % (i, c, an.split('\n')[0][:90]))
    s = re.sub(p, lambda _m: rp, s, count=1); n += 1
p = pat("var VER='%s';" % PV)
if len(re.findall(p, s)) != 1: stop('VER line did not match once')
s = re.sub(p, lambda _m: "var VER='%s';" % V, s, count=1)
p = r"(?m)^  now:'v" + re.escape(PV) + r":.*$"; c = len(re.findall(p, s))
if c != 1: stop('DEVNOW now line matched %d times, expected 1' % c)
now = "  now:'v%s: %s Check %s fails on v%s'," % (V, d['now'], V, PV)
if ascii_ok(now): stop('the now text is not ASCII')
s = re.sub(p, lambda _m: now, s, count=1)
if len(re.findall(r"(?m)^  now:'", s)) != 1: stop('more than one now key in DEVNOW')
chk = d['check'].replace('\r', '').replace("{v:'VER'", "{v:'%s'" % V, 1).rstrip()
if ascii_ok(chk): stop('the check is not ASCII (code %d)' % ascii_ok(chk))
if not chk.lstrip().startswith("{v:'%s',what:" % V): stop("the check must start with {v:'VER',what:")
if not chk.endswith('}},'): stop('the check must end with }},')
if re.search(r"(?m)^'@", chk): stop("a check line starts with '@")
if ("  {v:'%s',what:" % V) in fx: stop('check %s is in the fixture already' % V)
anchor = "  {v:'%s',what:" % PV
if fx.count(anchor) != 1: stop('fixture anchor %r matched %d times' % (anchor, fx.count(anchor)))
fx = fx.replace(anchor, chk + '\n' + anchor, 1)
os.makedirs(a.out, exist_ok=True)
for name, txt in (('dry.html', s), ('prev.html', game), ('mkfixture.ps1', fx)):
    open(os.path.join(a.out, name), 'w', encoding='utf-8', newline='').write(txt)
print('generated v%s from base %s (v%s): %d edits + VER + DEVNOW, check %d chars, title: %s' % (V, a.base, PV, n, len(chk), d['title']))
open(os.path.join(a.out, 'version.txt'), 'w').write('%s %s\n' % (V, PV))
