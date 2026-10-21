Tonight, to play the newest build on the MAIN PC (about a minute). Right-click Start, choose "Terminal". Paste ONE line at a time and press Enter after each.

1. Only when I say a new build is out (it fetches it into your party copy; last done for v33.17):
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Prepare

2. Every time (it stops the VM relay that sits on the game port; it comes back by itself at your next sign-in):
Get-NetTCPConnection -State Listen -LocalPort 8802,8799 -ErrorAction SilentlyContinue | ForEach-Object { Get-Process -Id $_.OwningProcess } | Where-Object ProcessName -eq node | Stop-Process -Force
   If it says "access is denied", open "Terminal (Admin)" instead, paste the same line there, then come back to the first window.

3. Every time (it serves the copy):
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Start

4. Open http://localhost:8802/dark_raiders.html in Chrome. Your notes (the in-game note key) reach me on their own.

Any time, in the VM window (restarts your daily itch backup): right-click Start, choose "Terminal", paste this line, press Enter, then paste your itch.io API key when it asks (itch.io, Settings, API keys); it stays hidden:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" itch
