One step INSIDE THE VM window (about a minute), so you can play today's builds on the main PC and your notes reach me: right-click the Start button, choose "Terminal (Admin)", click Yes, paste this line and press Enter:
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1
It adds one rule that lets only the main PC reach the game in the VM. Then play at http://localhost:8802/dark_raiders.html on the main PC as usual.
Second, smaller step (any time, restarts your daily itch backup): in the same window paste this line, press Enter, then paste your itch.io API key when it asks (itch.io, Settings, API keys); it stays hidden:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" itch
