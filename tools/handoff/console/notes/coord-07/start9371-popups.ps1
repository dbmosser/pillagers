# coord-07: the same headless Chrome as tools\cdp.ps1 -Start (same flags), on port 9371, plus --disable-popup-blocking so the
# game's own window.open for player 2 is allowed (what uishots.ps1 adds for recipes with "popups": true).
$exe='C:\Program Files\Google\Chrome\Application\chrome.exe'
$Profile="$env:TEMP\pillagers-cdp9371"
$a='--headless=new --window-size=1920,1080 --force-device-scale-factor=1 --remote-debugging-port=9371 --user-data-dir="'+$Profile+'" --no-first-run --no-default-browser-check --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows --autoplay-policy=no-user-gesture-required --disable-popup-blocking about:blank'
Start-Process -FilePath $exe -ArgumentList $a | Out-Null
for($i=0;$i -lt 40;$i++){ try{ Invoke-RestMethod "http://127.0.0.1:9371/json/version" -TimeoutSec 2 | Out-Null; Write-Output "browser up on 9371 (popups allowed)"; exit 0 }catch{ Start-Sleep -Milliseconds 250 } }
Write-Output 'browser did not start'; exit 1
