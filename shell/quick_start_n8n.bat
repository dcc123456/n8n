@echo off
echo.
echo ==========================================
echo    Quick Start n8n Service
echo ==========================================
echo.

REM Check if we're in the correct directory
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

echo.
echo Installing dependencies...
call pnpm install
if %errorlevel% neq 0 (
    echo Error: Failed to install dependencies with pnpm
    pause
    exit /b 1
)

echo.
echo Building n8n...
npx turbo build
if %errorlevel% neq 0 (
    echo Error: Failed to build n8n with turbo
    pause
    exit /b 1
)

echo.
echo Starting n8n service in a new window...
start "n8n Service" cmd /c "cd /d %N8N_DIR%\packages\cli && node bin/n8n & echo n8n started. Press any key to close... & pause >nul"

echo.
echo Waiting for n8n to start...
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
    echo To stop n8n, close the n8n service window or run:
    echo taskkill /IM node.exe /F
    echo.
) else (
    echo.
    echo Warning: n8n may not have started correctly. 
    echo Please check the n8n console window for details.
    echo.
)

pause
echo ========================================
echo     Quick Start n8n Service
echo ========================================
echo.

REM 设置n8n目录路径
set N8N_DIR=D:\projects\dcc\n8n\dcc-n8n
set CLI_DIR=%N8N_DIR%\packages\cli

echo Checking if n8n directory exists...
if not exist "%N8N_DIR%" (
    echo Error: n8n directory does not exist at %N8N_DIR%
    echo Please make sure the path is correct.
    pause
    exit /b 1
)

echo Changing to n8n directory: %N8N_DIR%
cd /d "%N8N_DIR%"

echo.
echo Checking if dependencies are installed...
if not exist "node_modules" (
    echo Installing dependencies...
    pnpm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        pause
        exit /b %errorlevel%
    )
    echo Dependencies installed successfully.
)

echo.
echo Checking if n8n is built...
if not exist "%CLI_DIR%\dist" (
    echo Building n8n...
    npx turbo build
    if %errorlevel% neq 0 (
        echo Error: Failed to build n8n
        pause
        exit /b %errorlevel%
    )
    echo n8n built successfully.
)

echo.
echo Checking if port 5678 is available...
netstat -an | findstr :5678 >nul
if %errorlevel% equ 0 (
    echo Warning: Port 5678 is already in use.
    echo Attempting to stop existing n8n process...
    taskkill /f /fi "WINDOWTITLE eq *n8n*" 2>nul
    taskkill /f /im node.exe /fi "COMMANDLINE eq *n8n*" 2>nul
    
    REM Wait a moment for the process to terminate
    timeout /t 3 /nobreak >nul
    
    REM Check again
    netstat -an | findstr :5678 >nul
    if %errorlevel% equ 0 (
        echo Error: Port 5678 is still in use. Please close the application using this port.
        pause
        exit /b 1
    )
)

echo.
echo Starting n8n service...
cd "%CLI_DIR%"
start "n8n-service" cmd /c "node bin/n8n && pause"

echo.
echo Waiting for n8n to start...
timeout /t 5 /nobreak >nul

REM Check if n8n is running on port 5678
netstat -an | findstr :5678 >nul
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo     n8n Service Started Successfully!
    echo     Access at: http://localhost:5678
    echo ========================================
    echo.
    echo Waiting for n8n to be fully ready...
    timeout /t 10 /nobreak >nul
    echo n8n should now be accessible at http://localhost:5678
    echo.
    echo Press any key to exit...
    pause >nul
) else (
    echo.
    echo Warning: n8n may not have started correctly.
    echo Please check the n8n console window for details.
    echo.
    pause
)