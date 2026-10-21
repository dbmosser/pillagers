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

On the SPARE PC, once (about 20 minutes, most of it waiting). It then tests every new build by itself. Right-click Start, choose "Terminal".
Paste ONE line at a time and press Enter after each. If Windows asks "do you want to allow this app to make changes", click Yes. If a line
asks you to agree to terms, type Y.

1. Installs Git (free):
winget install --id Git.Git -e

2. Installs Node (free):
winget install --id OpenJS.NodeJS.LTS -e

3. Only if Chrome is not on that PC yet:
winget install --id Google.Chrome -e

4. Close the Terminal and open a new one (so it finds the new programs). This downloads the game:
git clone --depth 1 https://github.com/dbmosser/pillagers.git "C:\claudecode\dark raiders"

5. This sets it up. When a GitHub sign-in window opens, sign in and allow it. Wait for the green DONE line:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\spare\spare-setup.ps1"

After that: leave it on and signed in. If it ever restarts, just sign in. To stop it for good, run step 5 again with -Remove at the end.
