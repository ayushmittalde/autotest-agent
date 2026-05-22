@echo off
setlocal enabledelayedexpansion

REM Usage:
REM   setup-testing-repo.bat [targetRoot]
REM Example:
REM   setup-testing-repo.bat D:\rpexplore

set "DEFAULT_TARGET_ROOT=D:\rpexplore"
set "TARGET_ROOT=%~1"
if "%TARGET_ROOT%"=="" (
  set /p "TARGET_ROOT=Enter installation folder path [!DEFAULT_TARGET_ROOT!]: "
  if "!TARGET_ROOT!"=="" set "TARGET_ROOT=!DEFAULT_TARGET_ROOT!"
)

set "TEST_REPO_URL=https://github.com/ayushmittalde/autogpt_agent_testcodegen.git"
set "TEST_DIR=%TARGET_ROOT%\autogpt_agent_testcodegen"

echo ==========================================
echo Testing Repository Setup (Windows)
echo Target root: %TARGET_ROOT%
echo ==========================================
echo.

where git >nul 2>nul || (echo [ERROR] git not found in PATH.& exit /b 1)
where npm >nul 2>nul || (echo [ERROR] npm not found in PATH.& exit /b 1)
where npx >nul 2>nul || (echo [ERROR] npx not found in PATH.& exit /b 1)

if not exist "%TARGET_ROOT%" (
  echo [INFO] Creating target root: %TARGET_ROOT%
  mkdir "%TARGET_ROOT%" || (echo [ERROR] Failed to create target root.& exit /b 1)
)

if not exist "%TEST_DIR%\.git" (
  echo [INFO] Cloning testing repository...
  git clone "%TEST_REPO_URL%" "%TEST_DIR%" || (echo [ERROR] Clone failed.& exit /b 1)
) else (
  echo [INFO] Testing repository already exists. Pulling latest changes...
  pushd "%TEST_DIR%"
  git pull --ff-only || (echo [WARN] git pull failed, continuing with existing checkout.)
  popd
)

pushd "%TEST_DIR%"

echo [INFO] Installing npm dependencies...
call npm install
if errorlevel 1 goto NPM_FAIL

echo [INFO] Installing Playwright Chromium browser...
call npx playwright install chromium
if errorlevel 1 goto BROWSER_FAIL

echo [INFO] Verifying Playwright CLI from project dependencies...
call npx playwright --version >nul 2>nul
if errorlevel 1 goto CLI_WARN
echo [INFO] Playwright CLI is available via npx.
goto DONE

:CLI_WARN
echo [WARN] Playwright CLI not available. Try: npm install @playwright/cli@latest then npx playwright --version 

:DONE

popd
echo [SUCCESS] Testing repository setup completed.
exit /b 0

:NPM_FAIL
echo [ERROR] npm install failed.
popd
exit /b 1

:BROWSER_FAIL
echo [ERROR] playwright chromium install failed.
popd
exit /b 1
