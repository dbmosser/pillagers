One small step (any time, restarts your daily itch backup): in the VM window right-click Start, choose "Terminal", paste this line, press Enter, then paste your itch.io API key when it asks (itch.io, Settings, API keys); it stays hidden:
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" itch
