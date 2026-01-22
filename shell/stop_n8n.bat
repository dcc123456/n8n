@echo off
echo Stopping n8n service...
taskkill /f /im "node.exe" /fi "WINDOWTITLE eq *n8n*"
taskkill /f /pid "n8n" 2>nul
taskkill /f /im node.exe /fi "COMMANDLINE eq *n8n*"
net stop n8n 2>nul

REM Kill any processes using port 5678
netstat -ano | findstr :5678 > temp_pid.txt
for /f "tokens=5" %%a in ('type temp_pid.txt ^| findstr LISTENING') do (
    taskkill /f /pid %%a 2>nul
)
del temp_pid.txt 2>nul

echo n8n service stopped.
pause