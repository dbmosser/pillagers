#!/usr/bin/env python3
# draftgate.py KEY [--keep]: the cloud copy of his PC gate for tools/handoff/drafts/draft-KEY.json, against the game as it
# stands in this checkout. Writes nothing tracked: the drafted game and both fixtures go to tools/gd-*-KEY.html and are
# removed at the end (unless --keep). Gates, in order, stopping at the first that does not hold:
#   every anchor matches exactly once, all text ASCII -> fixture builds -> parse PASS -> new check PASS x2 on the drafted
#   build -> new check FAILS (not SKIP) on the current build -> no new failures in the newest 80 checks -> seed 4242
#   fingerprint unchanged -> node --check on the drafted game. Prints GATE PASS or STOP <reason>.
import json, re, subprocess, sys, os
R = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
key = sys.argv[1]; keep = '--keep' in sys.argv
D = os.path.join(R, 'tools', 'handoff', 'drafts', 'draft-' + key + '.json')
T = os.path.join(R, 'tools'); RUN = os.path.join(T, 'cloud', 'run.mjs')
dry = 'gd-dry-' + key + '.html'; ctl = 'gd-ctl-' + key + '.html'; game = 'gd-game-' + key + '.html'; mk = os.path.join('/tmp', 'gd-mk-' + key + '.ps1')
def stop(msg):
    print('STOP ' + key + ': ' + msg); cleanup(); sys.exit(1)
def cleanup():
    if keep: return
    for f in (dry, ctl, game):
        try: os.remove(os.path.join(T, f))
        except OSError: pass
    try: os.remove(mk)
    except OSError: pass
def pat(a):
    return r'\r?\n'.join(re.escape(l) for l in a.replace('\r', '').split('\n'))
def ascii_ok(t):
    return all(ord(c) <= 126 and (ord(c) >= 32 or c in '\n\t') for c in t)
def node(*a, timeout=1500):
    try: p = subprocess.run(['node', RUN] + list(a), cwd=R, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired: return 99, 'TIMEOUT after %d s' % timeout
    return p.returncode, (p.stdout + p.stderr).strip()
d = json.load(open(D, encoding='utf-8-sig'))
for f in ('title', 'why', 'now', 'edits', 'check'):
    if not d.get(f): stop('field ' + f + ' is missing')
src = open(os.path.join(R, 'dark_raiders.html'), encoding='utf-8').read()
m = re.search(r"var VER='(\d+)\.(\d\d)';", src)
if not m: stop('no VER in the game')
prevN = int(m.group(1)) * 100 + int(m.group(2)); newN = prevN + 1
PV = '%d.%02d' % divmod(prevN, 100); V = '%d.%02d' % divmod(newN, 100)
s = src
for i, e in enumerate(d['edits'], 1):
    a = e['anchor'].replace('\r', ''); r = e['replacement'].replace('\r', '').replace('v16.xx', 'v' + V)
    if not ascii_ok(a) or not ascii_ok(r): stop('edit %d has a non-ASCII or control character' % i)
    if re.search(r"(?m)^'@", a) or re.search(r"(?m)^'@", r): stop("edit %d has a line starting with '@" % i)
    n = len(re.findall(pat(a), s))
    if n != 1: stop('edit %d anchor matched %d times: %s' % (i, n, a.split('\n')[0][:90]))
    s = re.sub(pat(a), lambda _m: r, s, count=1)
s = s.replace("var VER='" + PV + "';", "var VER='" + V + "';", 1)
nowpat = r"(?m)^  now:'v" + re.escape(PV) + r":.*$"
if len(re.findall(nowpat, s)) == 1:
    s = re.sub(nowpat, lambda _m: "  now:'v" + V + ": " + d['now'].replace("'", "\\'") + " Check " + V + " fails on v" + PV + "',", s, count=1)
chk = d['check'].replace('\r', '').replace("{v:'VER'", "{v:'" + V + "'").rstrip()
if not ascii_ok(chk): stop('the check has a non-ASCII character')
if not d['check'].lstrip().startswith("{v:'VER',what:"): stop("the check must start with {v:'VER',what:")
if not chk.endswith('}},'): stop('the check must end with }},')
fx = open(os.path.join(T, 'mkfixture.ps1'), encoding='utf-8').read()
anc = "  {v:'" + PV + "',what:"
if fx.count('\n' + anc) < 1: stop('the fixture has no check for v' + PV + ' to insert above')
i = fx.index('\n' + anc) + 1
fx = fx[:i] + chk + '\n' + fx[i:]
open(os.path.join(T, game), 'w', encoding='utf-8').write(s)
open(mk, 'w', encoding='utf-8').write(fx)
for srcf, dst in ((os.path.join(T, game), dry), (os.path.join(R, 'dark_raiders.html'), ctl)):
    p = subprocess.run(['pwsh', '-NoProfile', '-File', mk, '-Root', R, '-Src', srcf, '-Dst', os.path.join(T, dst)], capture_output=True, text=True, timeout=600)
    if not os.path.exists(os.path.join(T, dst)): stop('fixture build failed: ' + (p.stdout + p.stderr)[-600:])
print('draft %s as v%s on v%s: %d edits applied' % (key, V, PV, len(d['edits'])))
rc, o = node('parse', dry)
print('parse: ' + o.splitlines()[0] if o else 'parse: (no output)')
if rc: stop('parse: ' + o[:1500])
rc, o = node('check', dry, V, '2'); print('dry check:\n' + o[:3000])
if rc: stop('the new check does not pass twice on the drafted build')
rc, o = node('check', ctl, V, '1'); print('control check:\n' + o[:1500])
if not re.search(r'(?m)^run 1: FAIL', o): stop('the new check did not FAIL on the current build')
rc1, o1 = node('recent', dry, 'skipnewest', '80'); rc2, o2 = node('recent', ctl, 'skipnewest', '80')
try:
    j1 = json.loads(o1.strip().splitlines()[-1]); j2 = json.loads(o2.strip().splitlines()[-1])
except Exception: stop('recent run unreadable: dry=' + o1[-400:] + ' ctl=' + o2[-400:])
if 'TIMEOUT' in j1 or 'TIMEOUT' in j2: stop('recent run timed out')
reg = {k: v for k, v in j1.items() if k not in j2}
print('recent: %d new failures in the newest 80 checks (%d fail on both)' % (len(reg), len([k for k in j1 if k in j2])))
for k, v in reg.items(): print('  REGRESS ' + k + ': ' + v)
if reg: stop('an older check fails on the drafted build')
rc, o = node('verify', dry); print('verify: ' + o[-600:])
if '"ents":{"0":85,"1":374}' not in o or '"containers":{"0":165,"1":593}' not in o: stop('the seed 4242 fingerprint moved')
js = '\n;\n'.join(re.findall(r'<script\b[^>]*>([\s\S]*?)</script>', s))
open('/tmp/gd-' + key + '.js', 'w', encoding='utf-8').write(js)
p = subprocess.run(['node', '--check', '/tmp/gd-' + key + '.js'], capture_output=True, text=True)
os.remove('/tmp/gd-' + key + '.js')
if p.returncode: stop('node --check: ' + p.stderr[:800])
print('GATE PASS ' + key + ' (as v' + V + ' on v' + PV + ')'); cleanup()
