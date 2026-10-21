# coord-07 helper: c7 MATCH THROTTLE TIMEOUT EXPR  -> one cdp.ps1 call on port 9371
c7(){ powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:/claudecode/dark raiders/tools/cdp.ps1" -Port 9371 -Match "$1" -Throttle "$2" -TimeoutSec "$3" -Expr "$4"; }
C7LOAD="fetch('/handoff/console/notes/coord-07/meas.js?'+Date.now()).then(function(r){return r.text();}).then(function(t){return (0,eval)(t);})"
