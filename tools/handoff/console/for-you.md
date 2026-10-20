Two small steps, any time:

1. On the MAIN PC, one more time (about a minute). Your earlier runs worked, but they put in the version from before 5 PM, which has no note copying. Press Windows+R, paste this, press Enter, then click Yes. I can see from the VM when it is live, so no need to tell me:
%LOCALAPPDATA%\PillagersBridge\share\night-memory-setup.cmd

2. In the VM window (restarts your daily itch backup): right-click Start, choose "Terminal", paste this line, press Enter, then paste your itch.io API key when it asks (itch.io, Settings, API keys); it stays hidden:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" itch
