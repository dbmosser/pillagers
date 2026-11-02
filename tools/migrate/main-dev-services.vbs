' main-dev-services.vbs : the "Pillagers dev services" task on the main PC (11-02), at sign-in. Starts the dashboard server 8820 hidden, and nothing else:
' 8802 and the collector belong to the party copy there, so tools\start-servers.ps1 never runs on this PC. It waits while console\STOP stands (the VM's
' dashboard pushes to the same share until the VM is dark). A dashboard that already answers makes a second one exit; nightly.sh also starts it.
Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FileExists("C:\claudecode\dark raiders\tools\handoff\console\STOP") Then
  Set sh = CreateObject("WScript.Shell")
  sh.Environment("PROCESS")("CLAUDE_CONFIG_DIR") = sh.ExpandEnvironmentStrings("%USERPROFILE%") & "\.claude-pillagers"
  sh.Run "cmd /c cd /d ""C:\claudecode\dark raiders\tools\devdash"" && node server.mjs", 0, False
End If
