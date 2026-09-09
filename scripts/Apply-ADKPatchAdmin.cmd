@echo off
setlocal EnableExtensions

if "%~1"=="" (
  echo Usage: Apply-ADKPatchAdmin.cmd ^<patch-root^>
  exit /b 2
)

set "PATCHROOT=%~1"
set "LOGROOT=%~dp0..\output\adk-patch-logs"
if not exist "%LOGROOT%" mkdir "%LOGROOT%"

set "FOUND=0"
for /r "%PATCHROOT%" %%I in (*.msp) do (
  set "FOUND=1"
  echo Applying %%~nxI
  start "ADK patch" /wait msiexec.exe /qn /norestart /l* "%LOGROOT%\%%~nI.log" /p "%%~fI"
  if errorlevel 1 exit /b 1
)

if "%FOUND%"=="0" (
  echo No MSP files found under "%PATCHROOT%".
  exit /b 3
)

echo ADK patch application finished.
exit /b 0
