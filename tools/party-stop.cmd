@echo off
rem One click: stops everything that runs in the background for developing Pillagers. See party-day-stop-list.md on the Desktop (dark raiders folder).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0party-stop.ps1" %*
echo.
pause
