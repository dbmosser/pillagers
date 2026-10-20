@echo off
rem night-memory-setup.cmd : double-click to set up the VM's night memory, its weekly safety checkpoint and "light while gaming" (Windows asks for administrator rights; click Yes).
rem "night-memory-setup.cmd undo" takes it all away again, "night-memory-setup.cmd status" only shows what is set up.
set "ARG=-Install"
if /i "%~1"=="undo" set "ARG=-Undo"
if /i "%~1"=="status" set "ARG=-Status"
net session >nul 2>&1
if errorlevel 1 (
  if "%~1"=="" (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  ) else (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%~1' -Verb RunAs"
  )
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0host-night-memory.ps1" %ARG%
echo.
pause
