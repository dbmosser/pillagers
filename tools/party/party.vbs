' party.vbs : the desktop shortcut "Pillagers Party" runs this (2026-10-18, his order: a one click shortcut that opens both party windows full screen).
' It only starts tools\party\party.ps1 without a console window. Everything it does is in party.ps1 and party.cfg.
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\claudecode\dark raiders\tools\party\party.ps1""", 0, False
