Two small steps, any time:

1. On the MAIN PC (about a minute), so the notes you save in the game reach me again: press Windows+R, paste this and press Enter, then click Yes (the same as this morning; it adds the note copying):
%LOCALAPPDATA%\PillagersBridge\share\night-memory-setup.cmd

2. In the VM window (restarts your daily itch backup): right-click Start, choose "Terminal", paste this line, press Enter, then paste your itch.io API key when it asks (itch.io, Settings, API keys); it stays hidden:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" itch
