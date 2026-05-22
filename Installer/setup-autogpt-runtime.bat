@echo off
setlocal enabledelayedexpansion

REM Usage:
REM   setup-autogpt-runtime.bat [targetRoot]
REM Example:
REM   setup-autogpt-runtime.bat D:\rpexplore

set "DEFAULT_TARGET_ROOT=D:\rpexplore"
set "TARGET_ROOT=%~1"
if "%TARGET_ROOT%"=="" (
  set /p "TARGET_ROOT=Enter installation folder path [!DEFAULT_TARGET_ROOT!]: "
  if "!TARGET_ROOT!"=="" set "TARGET_ROOT=!DEFAULT_TARGET_ROOT!"
)

set "AUTOGPT_REPO_URL=https://github.com/ayushmittalde/autogpt_codebase_rp.git"
set "AUTOGPT_DIR=%TARGET_ROOT%\autogpt_codebase_rp"
set "PLATFORM_DIR=%AUTOGPT_DIR%\autogpt_platform"

echo ==========================================
echo AutoGPT Runtime Setup (Windows)
echo Target root: %TARGET_ROOT%
echo ==========================================
echo.

REM Basic prerequisite checks
where git >nul 2>nul || (echo [ERROR] git not found in PATH.& exit /b 1)
where docker >nul 2>nul || (echo [ERROR] docker not found in PATH.& exit /b 1)
where powershell >nul 2>nul || (echo [ERROR] powershell not found in PATH.& exit /b 1)

REM Ensure Docker daemon is running
docker info >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker daemon is not running.
  echo Start Docker Desktop and retry.
  exit /b 1
)

REM Check free space on C: and D: (best effort)
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive C).Free/1GB,2)"') do set "C_FREE_GB=%%A"
for /f %%A in ('powershell -NoProfile -Command "if (Get-PSDrive D -ErrorAction SilentlyContinue) {[math]::Round((Get-PSDrive D).Free/1GB,2)} else {0}"') do set "D_FREE_GB=%%A"
echo [INFO] Free space - C: %C_FREE_GB% GB, D: %D_FREE_GB% GB

if not exist "%TARGET_ROOT%" (
  echo [INFO] Creating target root: %TARGET_ROOT%
  mkdir "%TARGET_ROOT%" || (echo [ERROR] Failed to create target root.& exit /b 1)
)

if not exist "%AUTOGPT_DIR%\.git" (
  echo [INFO] Cloning AutoGPT repository...
  git clone "%AUTOGPT_REPO_URL%" "%AUTOGPT_DIR%" || (echo [ERROR] Clone failed.& exit /b 1)
) else (
  echo [INFO] AutoGPT repository already exists. Pulling latest changes...
  pushd "%AUTOGPT_DIR%"
  git pull --ff-only || (echo [WARN] git pull failed, continuing with existing checkout.)
  popd
)

if not exist "%PLATFORM_DIR%" (
  echo [ERROR] Platform directory not found: %PLATFORM_DIR%
  exit /b 1
)

echo [INFO] Checking if AutoGPT frontend is already reachable...
powershell -NoProfile -Command "try { $r=Invoke-WebRequest -Uri 'http://localhost:3000' -UseBasicParsing -TimeoutSec 5; if ($r.StatusCode -eq 200) { exit 0 } else { exit 2 } } catch { exit 3 }"
if errorlevel 1 goto START_COMPOSE
echo [INFO] localhost:3000 is already reachable. Reusing running stack.
goto VERIFY_READY

:START_COMPOSE
echo [INFO] Starting AutoGPT services with Docker Compose (non-interactive)...
if not exist "%PLATFORM_DIR%\logs" mkdir "%PLATFORM_DIR%\logs"
pushd "%PLATFORM_DIR%"
docker compose up -d > "%PLATFORM_DIR%\logs\docker_setup.log" 2>&1
set "COMPOSE_EXIT=%ERRORLEVEL%"
popd
if not "%COMPOSE_EXIT%"=="0" (
  echo [ERROR] Docker compose returned non-zero exit code: %COMPOSE_EXIT%
  echo [HINT] Check logs under %PLATFORM_DIR%\logs
  exit /b %COMPOSE_EXIT%
)

:VERIFY_READY

echo [INFO] Verifying localhost:3000 availability...
powershell -NoProfile -Command "try { $r=Invoke-WebRequest -Uri 'http://localhost:3000' -UseBasicParsing -TimeoutSec 20; if ($r.StatusCode -eq 200) { exit 0 } else { exit 2 } } catch { exit 3 }"
if errorlevel 1 goto FRONTEND_FAIL

echo [SUCCESS] AutoGPT runtime setup completed and localhost:3000 is reachable.
exit /b 0

:FRONTEND_FAIL
echo [ERROR] AutoGPT frontend check failed (http://localhost:3000 not ready).
exit /b 1
