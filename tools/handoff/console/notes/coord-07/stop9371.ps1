Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match 'remote-debugging-port=9371(\s|$)' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
