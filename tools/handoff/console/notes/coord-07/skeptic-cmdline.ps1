Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match 'remote-debugging-port=9371(\s|$)' } | Select-Object -First 1 -ExpandProperty CommandLine
