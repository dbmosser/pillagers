#!/usr/bin/env python3
# flipscan.py : looks for damage from the main PC's bad memory (found 11-02 21:35 by the FnP chat: single bits 5 and 7 wrong at fixed spots).
# A bad bit in a file we write shows up as a changed line that differs from the line it replaced by exactly ONE BIT, or as a byte that is not
# valid text. No editor makes that kind of change except by accident, so it is worth a look; digits next to each other (0 and 1, 2 and 3) also
# differ by one bit, so those are only counted, not reported. Reads only. Prints CLEAN or a line per hit.
# python flipscan.py [commits back, default 40] [file ...]
import subprocess, sys
REPO = r"C:\claudecode\dark raiders"
n = sys.argv[1] if len(sys.argv) > 1 else "40"
files = sys.argv[2:] or ["dark_raiders.html", "tools/mkfixture.ps1"]

def onebit(a, b):
    if len(a) != len(b):
        return None
    d = [i for i in range(len(a)) if a[i] != b[i]]
    if len(d) != 1:
        return None
    i = d[0]
    x = a[i] ^ b[i]
    return i if x & (x - 1) == 0 else None

hits = 0; digits = 0; pairs = 0; commits = 0
for f in files:
    out = subprocess.run(["git", "-C", REPO, "log", "-n", n, "-p", "--unified=0", "--no-color", "--format=COMMIT %h %s", "--", f],
                         capture_output=True).stdout
    c = b"?"; old = []; new = []
    def flush():
        global hits, digits, pairs
        if old and len(old) == len(new):
            for a, b in zip(old, new):
                pairs += 1
                i = onebit(a, b)
                if i is None:
                    continue
                if chr(a[i]).isdigit() and chr(b[i]).isdigit():
                    digits += 1
                    continue
                hits += 1
                s = max(0, i - 40)
                print("LOOK %s %s byte %d: %r became %r in ...%s" % (f, c.decode("latin1")[:60], i, chr(a[i]), chr(b[i]), a[s:i + 40].decode("latin1").strip()))
        old.clear(); new.clear()
    for l in out.split(b"\n"):
        if l.startswith(b"COMMIT "):
            flush(); c = l[7:]; commits += 1
        elif l.startswith(b"@@"):
            flush()
        elif l.startswith(b"---") or l.startswith(b"+++"):
            continue
        elif l.startswith(b"-"):
            old.append(l[1:].rstrip(b"\r"))
        elif l.startswith(b"+"):
            new.append(l[1:].rstrip(b"\r"))
    flush()
    try:
        cur = open(REPO + "\\" + f.replace("/", "\\"), "rb").read()
        cur.decode("utf-8")
    except UnicodeDecodeError as e:
        hits += 1
        print("LOOK %s now has a byte that is not valid text at %d: %r" % (f, e.start, cur[max(0, e.start - 40):e.start + 40]))
    if b"\0" in cur:
        hits += 1
        print("LOOK %s now has a zero byte at %d" % (f, cur.index(b"\0")))
print(("CLEAN" if not hits else "%d TO LOOK AT" % hits) + ": %d commits, %d changed line pairs, %d digit-only changes passed" % (commits, pairs, digits))
