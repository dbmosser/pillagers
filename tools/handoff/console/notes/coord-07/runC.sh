# coord-07 run C: the 2 player demo, both windows sampled at the same time. usage: bash runC.sh THROTTLE REPEATS
. "/c/claudecode/dark raiders/tools/handoff/console/notes/coord-07/c7.sh"
D="/c/claudecode/dark raiders/tools/handoff/console/notes/coord-07"
T=$1; N=${2:-3}
RST="__gx('try{ if(arcadeBenched()) arcadeUnbench(); }catch(e){} ARCADE.ownAt=Date.now(); DRS.scale=1;DRS.applied=1;DRS.q=0;gfxqApply();DRS.slowT=0;DRS.fastT=0;DRS.bounce=0;DRS.upAt=0;DRS.last=0;DRS.ema=0;DRS.said=0;DRS.moves=0;1')+' '+__c7.calib()+' raid '+!!(__state()&&__state().player&&!__state().over)"
for r in $(seq 1 $N); do
  FREE=$(powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)" | tr -d '\r')
  R1=$(c7 "netslot=A" 0 30 "$RST"); R2=$(c7 "p2=1" 0 30 "$RST")
  sleep 1
  c7 "netslot=A" $T 120 "__c7.sample({label:'C-t$T-r$r-p1',arc:true})" > "$D/raw-C-t$T-r$r-p1.tmp" &
  c7 "p2=1" $T 120 "__c7.sample({label:'C-t$T-r$r-p2',move:false,arc:true,drift:220})" > "$D/raw-C-t$T-r$r-p2.tmp" &
  wait
  FREE2=$(powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,2)" | tr -d '\r')
  for w in p1 p2; do
    R=$R1; [ $w = p2 ] && R=$R2
    { echo "{\"run\":\"C-t$T-r$r-$w\",\"free_gb\":$FREE,\"free_gb_end\":$FREE2,\"reset_and_unthrottled_calib\":\"$R\",\"sample\":"; cat "$D/raw-C-t$T-r$r-$w.tmp"; echo "}"; } > "$D/raw-C-t$T-r$r-$w.json"; rm -f "$D/raw-C-t$T-r$r-$w.tmp"; echo "wrote C-t$T-r$r-$w"
  done
  sleep 3
done
