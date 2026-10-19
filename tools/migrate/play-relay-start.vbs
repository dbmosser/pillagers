' play-relay-start.vbs : started at every logon by the Startup shortcut "Play relay (VM)" (made by host-play-relay.ps1 -Install).
' It runs host-play-relay.ps1 -Start -AtLogon with no window at all. That script starts the relay only when host-stopped.txt says the main PC
' has been switched over, and does nothing otherwise. To remove the shortcut: host-play-relay.ps1 -Uninstall.
' ASCII only.
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
here = fso.GetParentFolderName(WScript.ScriptFullName)
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & here & "\host-play-relay.ps1"" -Start -AtLogon", 0, False
