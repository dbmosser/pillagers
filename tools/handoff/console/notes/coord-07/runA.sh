# coord-07 run A: one player ordinary raid. usage: bash runA.sh THROTTLE REPEATS
. "/c/claudecode/dark raiders/tools/handoff/console/notes/coord-07/c7.sh"
D="/c/claudecode/dark raiders/tools/handoff/console/notes/coord-07"
T=$1; N=${2:-3}
c7 8809/fixture 0 30 "$C7LOAD" >/dev/null
for r in $(seq 1 $N); do
  F="$D/raw-A-t$T-r$r.json"
  echo "{\"run\":\"A-t$T-r$r\",\"start\":\"$(date +%H:%M:%S)\",\"free_gb\":$(powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)" | tr -d '\r'),\"unthrottled_calib_ms\":$(c7 8809/fixture 0 30 "__c7.calib()")," > "$F"
  echo "\"deploy\":$(c7 8809/fixture 0 60 "__c7.deploy(4242,1920,1080)")," >> "$F"
  sleep 2
  echo "\"sample\":$(c7 8809/fixture $T 120 "__c7.sample({label:'A-t$T-r$r'})")," >> "$F"
  echo "\"end\":\"$(c7 8809/fixture 0 30 "__c7.end()")\",\"free_gb_end\":$(powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)" | tr -d '\r')}" >> "$F"
  python -c "import json,sys; d=json.load(open(sys.argv[1])); s=d['sample']; print(d['run'], 'gap', s['gap'], 'busy', s['busy_ms'], 'gfxw', s['gfx_window'], 'q', s['drs_end']['gfxScaleNow'], s['drs_end']['q'], 'moves', s['drs_end']['moves'], 'cal', d['unthrottled_calib_ms'], s['calib_ms'], 'moved', s['moved_px'], 'free', d['free_gb'], d['free_gb_end'])" "$F" || cat "$F"
  sleep 3
done
