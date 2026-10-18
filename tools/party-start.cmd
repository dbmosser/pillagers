@echo off
rem One click: starts everything again after the party. See party-day-stop-list.md on the Desktop (dark raiders folder).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0party-start.ps1" %*
echo.
pause
