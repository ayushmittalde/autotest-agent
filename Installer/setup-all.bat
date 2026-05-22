@echo off
setlocal enabledelayedexpansion

REM Usage:
REM   setup-all.bat [targetRoot]
REM Example:
REM   setup-all.bat D:\rpexplore

set "DEFAULT_TARGET_ROOT=D:\rpexplore"
set "TARGET_ROOT=%~1"
if "%TARGET_ROOT%"=="" (
  set /p "TARGET_ROOT=Enter installation folder path [ Default Path: !DEFAULT_TARGET_ROOT! ]: "
  if "!TARGET_ROOT!"=="" set "TARGET_ROOT=!DEFAULT_TARGET_ROOT!"
)

set "SCRIPT_DIR=%~dp0"
set "POPUP_TITLE=AutoGPT Unified Setup"
echo ==========================================
echo Unified Setup: AutoGPT + Testing Repo
echo Target root: %TARGET_ROOT%
echo ==========================================
echo.

call :show_popup "Please ensure Docker engine is already running before proceeding !" Information

call "%SCRIPT_DIR%setup-autogpt-runtime.bat" "%TARGET_ROOT%"
if errorlevel 1 (
  echo [ERROR] AutoGPT runtime setup failed.
  call :show_popup "Installation failed. AutoGPT runtime setup failed." Error
  exit /b 1
)

call "%SCRIPT_DIR%setup-testing-repo.bat" "%TARGET_ROOT%"
if errorlevel 1 (
  echo [ERROR] Testing repository setup failed.
  call :show_popup "Installation failed. Testing repository setup failed." Error
  exit /b 1
)

set "TEST_DIR=%TARGET_ROOT%\autogpt_agent_testcodegen"
if not exist "%TEST_DIR%" (
  echo [ERROR] Testing repository folder not found: %TEST_DIR%
  call :show_popup "Installation failed. Testing repository folder was not found." Error
  exit /b 1
)

echo [INFO] Running smoke test against localhost:3000...
pushd "%TEST_DIR%"
call npx playwright test AutoGPT/tests/title.spec.ts --project=chromium --reporter=list
set "SMOKE_EXIT=%ERRORLEVEL%"
popd

if not "%SMOKE_EXIT%"=="0" (
  echo [ERROR] Smoke test failed with code %SMOKE_EXIT%.
  call :show_popup "Installation failed. Smoke test failed with code %SMOKE_EXIT%." Error
  exit /b %SMOKE_EXIT%
)

echo [SUCCESS] Unified setup completed and smoke test passed.
echo [SUCCESS] Healthy signal: localhost:3000 reachable and title.spec.ts passed.
call :show_popup "Installation complete. Runtime is healthy and smoke test passed." Information
exit /b 0

:show_popup
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [void][System.Windows.Forms.MessageBox]::Show('%~1','%POPUP_TITLE%',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::%~2)" >nul 2>nul
exit /b 0
