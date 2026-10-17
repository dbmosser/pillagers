' open.vbs : opens PILLAGERS DEV, the live dashboard, in its own window (2026-10-17). Starts the dashboard server first if it is
' not answering. The desktop shortcut "Pillagers Dev" runs this.
Set sh = CreateObject("WScript.Shell")
ok = False
On Error Resume Next
Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
x.setTimeouts 1000, 1000, 1000, 1000
x.Open "GET", "http://127.0.0.1:8820/api", False
x.Send
If Err.Number = 0 Then
  If x.Status = 200 Then ok = True
End If
Err.Clear
On Error GoTo 0
If Not ok Then
  sh.Run "cmd /c cd /d ""C:\claudecode\dark raiders\tools\devdash"" && node server.mjs", 0, False
  WScript.Sleep 2000
End If
sh.Run """C:\Program Files\Google\Chrome\Application\chrome.exe"" --app=http://127.0.0.1:8820 --window-size=1400,950", 1, False
