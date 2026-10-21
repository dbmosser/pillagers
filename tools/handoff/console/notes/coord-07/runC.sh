# coord-07 run C: the 2 player demo, both windows sampled at the same time. usage: bash runC.sh THROTTLE REPEATS
. "/c/claudecode/dark raiders/tools/handoff/console/notes/coord-07/c7.sh"
D="/c/claudecode/dark raiders/tools/handoff/console/notes/coord-07"
T=$1; N=${2:-3}
RST="__gx('DRS.scale=1;DRS.applied=1;DRS.q=0;gfxqApply();DRS.slowT=0;DRS.fastT=0;DRS.bounce=0;DRS.upAt=0;DRS.last=0;DRS.ema=0;DRS.said=0;DRS.moves=0;1')+' '+__c7.calib()+' raid '+!!(__state()&&__state().player&&!__state().over)"
for r in $(seq 1 $N); do
  FREE=$(powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)" | tr -d '\r')
  R1=$(c7 "netslot=A" 0 30 "$RST"); R2=$(c7 "p2=1" 0 30 "$RST")
  sleep 1
  c7 "netslot=A" $T 120 "__c7.sample({label:'C-t$T-r$r-p1'})" > "$D/raw-C-t$T-r$r-p1.tmp" &
  c7 "p2=1" $T 120 "__c7.sample({label:'C-t$T-r$r-p2',move:false})" > "$D/raw-C-t$T-r$r-p2.tmp" &
  wait
  FREE2=$(powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)" | tr -d '\r')
  for w in p1 p2; do
    R=$R1; [ $w = p2 ] && R=$R2
    { echo "{\"run\":\"C-t$T-r$r-$w\",\"free_gb\":$FREE,\"free_gb_end\":$FREE2,\"reset_and_unthrottled_calib\":\"$R\",\"sample\":"; cat "$D/raw-C-t$T-r$r-$w.tmp"; echo "}"; } > "$D/raw-C-t$T-r$r-$w.json"; rm -f "$D/raw-C-t$T-r$r-$w.tmp"
    python -c "import json,sys; d=json.load(open(sys.argv[1])); s=d['sample']; print(d['run'], 'gap', s['gap'], 'busy', s['busy_ms'], 'gfxw', s['gfx_window'], 'q', s['drs_end']['gfxScaleNow'], s['drs_end']['q'], 'moves', s['drs_end']['moves'], 'cal', d['reset_and_unthrottled_calib'], s['calib_ms'], 'moved', s['moved_px'], 'lost', s['raid_lost'], 'free', d['free_gb'], d['free_gb_end'], s['canvases'])" "$D/raw-C-t$T-r$r-$w.json" || cat "$D/raw-C-t$T-r$r-$w.json"
  done
  sleep 3
done
