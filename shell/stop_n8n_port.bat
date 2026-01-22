@echo off
echo Stopping any process using port 5678...

REM Find and kill process using port 5678
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :5678') do (
    echo Killing process with PID: %%a
    taskkill /f /pid %%a
)

echo Port 5678 should now be free.
echo n8n service stopped.
pause