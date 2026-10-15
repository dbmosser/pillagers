' runner-start.vbs (2026-10-15, his RULE NUMBER ONE: work on the game 24 hours a day). Started every 15 minutes by the Windows
' scheduled task "Pillagers runner". It starts tools\nightly.sh hidden (no window). nightly.sh exits at once when another copy is alive
' (its heartbeat file is under 10 minutes old), so only one runner ever runs. To stop it for good: schtasks /Delete /TN "Pillagers runner" /F
Set sh = CreateObject("WScript.Shell")
sh.Run """C:\Program Files\Git\bin\bash.exe"" ""/c/claudecode/dark raiders/tools/nightly.sh""", 0, False
