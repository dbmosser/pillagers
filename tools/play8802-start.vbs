' play8802-start.vbs (11-08, owner's item 6: "make sure something restarts 8802 after a PC restart"). Run hidden at every sign-in by the
' Windows task "Pillagers 8802 at sign-in" on the main PC. It runs tools\start-servers.ps1 -PlayOnly on the party copy 8802 serves;
' a port that already answers is left alone. Log: %LOCALAPPDATA%\PillagersPlay\start-8802.log (last run only).
' Backup: the "Main PC idle tests" runner (spare-runner.ps1 Ensure-Play) starts it if nothing answered for 2+ minutes.
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
d = sh.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\PillagersPlay"
If Not fso.FolderExists(d) Then fso.CreateFolder(d)
sh.Run "cmd /c powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\claudecode\dark raiders\tools\start-servers.ps1"" -Root ""C:\claudecode\pillagers-party"" -PlayOnly > """ & d & "\start-8802.log"" 2>&1", 0, False
