@echo off
title n8n Service Starter

REM Change to the n8n directory
set "N8N_DIR=D:\projects\dcc\n8n\dcc-n8n"

if not exist "%N8N_DIR%" (
    echo Error: n8n directory does not exist at %N8N_DIR%
    echo Please make sure n8n is installed in the expected location.
    pause
    exit /b 1
)

echo Checking if n8n is already running...
netstat -an | findstr :5678 >nul
if %errorlevel% == 0 (
    echo.
    echo Warning: Port 5678 is already in use, n8n might already be running.
    echo Checking the process on port 5678...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5678 ^| findstr LISTENING') do set PID=%%a
    if defined PID (
        echo Found process with PID: %PID%
        tasklist /FI "PID eq %PID%" 2>nul | findstr /i node >nul
        if %errorlevel% == 0 (
            echo The process with PID %PID% is a Node.js process (likely n8n).
            echo n8n appears to be already running on port 5678.
            echo Visit http://localhost:5678 to access n8n.
            echo.
            echo If you want to restart n8n, please stop the current instance first.
            echo You can use: taskkill /PID %PID% /F
            pause
            exit /b 0
        )
    )
)

echo Changing to n8n directory: %N8N_DIR%
cd /d "%N8N_DIR%"

echo Installing dependencies...
call pnpm install
if %errorlevel% neq 0 (
    echo Error: Failed to install dependencies
    pause
    exit /b 1
)

echo Building n8n...
npx turbo build
if %errorlevel% neq 0 (
    echo Error: Failed to build n8n
    pause
    exit /b 1
)

echo Starting n8n service...
start "n8n Service" cmd /c "cd /d %N8N_DIR%\packages\cli && node bin/n8n & echo n8n started. Press any key to close... & pause >nul"

echo.
Waiting for n8n to start...
timeout /t 10 /nobreak >nul

REM Verify that n8n has started successfully
netstat -an | findstr :5678 >nul
if %errorlevel% == 0 (
    echo.
    echo ==========================================
    echo    SUCCESS: n8n is now running!
    echo    Access n8n at: http://localhost:5678
    echo ==========================================
    echo.
) else (
    echo.
    echo Warning: n8n may not have started correctly. 
    echo Please check the n8n console window for details.
    echo.
)

echo n8n service started in a new window.
echo Visit http://localhost:5678 to access n8n.
pause