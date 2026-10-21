Tonight, to play the newest build on the MAIN PC (about a minute):

1. Right-click Start, choose "Terminal", paste this line and press Enter (it fetches the newest build into your party copy):
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Prepare

2. When it says done, paste this line and press Enter (it serves the copy):
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Start
   If it says port 8802 is already in use (your old play server came back), paste this line first, then step 2 again:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1" -Yes

3. Open http://localhost:8802/dark_raiders.html in Chrome. Your notes (the in-game note key) reach me on their own.

Any time, in the VM window (restarts your daily itch backup): right-click Start, choose "Terminal", paste this line, press Enter, then paste your itch.io API key when it asks (itch.io, Settings, API keys); it stays hidden:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" itch
