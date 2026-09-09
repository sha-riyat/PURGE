@echo off
setlocal
set "PURGE_ROOT=%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PURGE_ROOT%scripts\Run-PurgeAdmin.ps1"
set "PURGE_EXIT=%ERRORLEVEL%"
echo.
echo PURGE termine avec le code %PURGE_EXIT%.
pause
exit /b %PURGE_EXIT%
