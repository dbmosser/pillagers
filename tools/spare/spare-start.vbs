' spare-start.vbs (2026-10-20): starts tools\spare\spare-runner.ps1 hidden (no window). Run by the task "Pillagers spare runner" that
' tools\spare\spare-setup.ps1 makes on the SPARE PC (at sign-in and every 15 minutes). The runner exits at once when another copy is alive.
' To stop it for good: powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\spare\spare-setup.ps1" -Remove
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\claudecode\dark raiders\tools\spare\spare-runner.ps1""", 0, False
