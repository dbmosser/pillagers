#!/usr/bin/env python3
# ramwatch.py : keeps checking the main PC's memory while it works. 11-02 night: a bad stick cost the island a day and could damage files without an
# error, and the 3 sticks left in have only had a quick test on part of their 48 GB. Once an hour, 3 workers at low priority fill spare memory with known
# values for 2 minutes and read them back (the FnP chat's ramcheck2.py method). Each round gets different physical memory, so coverage grows over a night.
# The Fortnite island keeps first call: with the editor open this is one worker on at most 6 GB and leaves 14 GB free; otherwise it leaves 8. It sits out while Fortnite itself runs.
# A bad spot goes to console/alarms.md, which wakes the CEO chat. Log: %LOCALAPPDATA%\PillagersRamwatch\ramwatch.log
import ctypes, mmap, multiprocessing as mp, os, subprocess, sys, time
GB = 2**30; MB = 2**20
SECS, WORKERS, EVERY = 120, 3, 3600
ALARMS = r"C:\claudecode\dark raiders\tools\handoff\console\alarms.md"
LOG = os.path.join(os.environ.get("LOCALAPPDATA", r"C:\Users\User1\AppData\Local"), "PillagersRamwatch", "ramwatch.log")

def worker(gb, secs, q):
    k = ctypes.windll.kernel32
    k.SetPriorityClass(k.GetCurrentProcess(), 0x4000)
    size = int(gb * GB); m = mmap.mmap(-1, size)
    buf = (ctypes.c_char * size).from_buffer(m); a = ctypes.addressof(buf)
    crt = ctypes.cdll.msvcrt
    crt.memcmp.argtypes = (ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t); crt.memcmp.restype = ctypes.c_int
    crt.memset.argtypes = (ctypes.c_void_p, ctypes.c_int, ctypes.c_size_t); crt.memset.restype = ctypes.c_void_p
    end = time.time() + secs; passes = 0; bad = {}
    while time.time() < end:
        for pat in (0xAA, 0x55, 0x00, 0xFF, 0xCC, 0x33):
            crt.memset(a, pat, size)
            if crt.memcmp(a, a + 1, size - 1) == 0 and m[0] == pat:
                continue
            for o in range(0, size, MB):
                c = m[o:o + MB]
                if c.count(pat) == len(c):
                    continue
                for j, b in enumerate(c):
                    if b != pat:
                        bad[(o + j, b ^ pat)] = bad.get((o + j, b ^ pat), 0) + 1
        passes += 1
    del buf; m.close()
    q.put((passes, len(bad), [(o, format(x, "08b"), v) for (o, x), v in sorted(bad.items(), key=lambda i: -i[1])[:4]]))

class MS(ctypes.Structure):
    _fields_ = [("len", ctypes.c_ulong), ("load", ctypes.c_ulong), ("tp", ctypes.c_ulonglong), ("ap", ctypes.c_ulonglong),
                ("tf", ctypes.c_ulonglong), ("af", ctypes.c_ulonglong), ("tv", ctypes.c_ulonglong), ("av", ctypes.c_ulonglong), ("x", ctypes.c_ulonglong)]
def free_gb():
    s = MS(); s.len = ctypes.sizeof(MS); ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(s)); return min(s.ap, s.av) / GB
def running(name):
    out = subprocess.run(["tasklist", "/FO", "CSV", "/NH"], capture_output=True, text=True, errors="replace").stdout
    return name.lower() in out.lower()
def log(line):
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    with open(LOG, "a", encoding="ascii", errors="replace") as f:
        f.write(time.strftime("%m-%d %H:%M ") + line + "\n")

def round_once(total):
    if running("FortniteClient-Win64-Shipping"):
        log("sat out: Fortnite is running"); return total
    keep = 14 if running("UnrealEditor") else 8
    use = free_gb() - keep
    if use < 3:
        log("sat out: %.1f GB free, keeping %d" % (free_gb(), keep)); return total
    workers = 1 if keep == 14 else WORKERS  # the editor is open: FnP comes first, so far less load on the memory bus
    use = min(use, 6) if keep == 14 else use
    each = round(use / workers, 2)
    q = mp.Queue(); ps = [mp.Process(target=worker, args=(each, SECS, q)) for _ in range(workers)]
    [p.start() for p in ps]; res = [q.get() for _ in ps]; [p.join() for p in ps]
    total += each * workers
    n = sum(r[1] for r in res)
    log("%.1f GB for %d s, %d bad spots, %.0f GB tested since start" % (each * workers, SECS, n, total))
    if n:
        spots = [s for r in res for s in r[2]][:4]
        with open(ALARMS, "a", encoding="ascii", errors="replace") as f:
            f.write("- %s MAIN PC MEMORY: ramwatch found %d bad spots in %.1f GB, first %s. Saving through this can damage files; tell him at once.\n" % (time.strftime("%m-%d %H:%M"), n, each * workers, spots))
    return total

if __name__ == "__main__":
    time.sleep(int(sys.argv[1]) if len(sys.argv) > 1 else 0)
    total = 0.0
    while True:
        total = round_once(total)
        time.sleep(EVERY)
