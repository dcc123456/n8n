# PowerShell script to manage n8n service

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "status")]
    [string]$Action
)

$n8nPort = 5678
$n8nPath = "D:\projects\dcc\n8n\dcc-n8n"
$cliPath = Join-Path $n8nPath "packages\cli"

function Start-N8n {
    Write-Host "Starting n8n service..." -ForegroundColor Green
    
    # Check if n8n directory exists
    if (!(Test-Path $n8nPath)) {
        Write-Error "n8n directory does not exist: $n8nPath"
        return
    }
    
    # Change to n8n directory
    Set-Location $n8nPath
    
    # Check if dependencies are installed
    if (!(Test-Path "node_modules")) {
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        $result = pnpm install
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install dependencies"
            return
        }
    }
    
    # Check if built
    if (!(Test-Path "$cliPath\dist")) {
        Write-Host "Building n8n..." -ForegroundColor Yellow
        $result = npx turbo build
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to build n8n"
            return
        }
    }
    
    # Check if port is available
    $portCheck = Get-NetTCPConnection -LocalPort $n8nPort -ErrorAction SilentlyContinue
    if ($portCheck) {
        Write-Warning "Port $n8nPort is already in use by process with PID $($portCheck.OwningProcess)"
        return
    }
    
    # Start n8n in a new window
    Set-Location $cliPath
    Start-Process -FilePath "node" -ArgumentList "bin/n8n" -WorkingDirectory $cliPath
    
    # Wait a moment for the process to start
    Start-Sleep -Seconds 3
    
    # Verify that the process is running
    $portCheck = Get-NetTCPConnection -LocalPort $n8nPort -ErrorAction SilentlyContinue
    if ($portCheck) {
        Write-Host "n8n service started successfully on http://localhost:$n8nPort" -ForegroundColor Green
        Write-Host "Waiting for n8n to be fully ready..." -ForegroundColor Cyan
        Start-Sleep -Seconds 10
        Write-Host "n8n should now be accessible at http://localhost:$n8nPort" -ForegroundColor Green
    } else {
        Write-Warning "n8n may not have started correctly. Please check the console window."
    }
}

function Stop-N8n {
    Write-Host "Stopping n8n service..." -ForegroundColor Red
    
    # Find and kill processes using port 5678
    $portConnections = Get-NetTCPConnection -LocalPort $n8nPort -ErrorAction SilentlyContinue
    if ($portConnections) {
        foreach ($conn in $portConnections) {
            $procId = $conn.OwningProcess
            Write-Host "Terminating process with PID: $procId" -ForegroundColor Yellow
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Also kill any node processes that might be n8n
    $nodeProcesses = Get-Process node -ErrorAction SilentlyContinue | Where-Object { 
        $_.MainWindowTitle -like "*n8n*" -or 
        $_.Path -like "*n8n*" -or
        ($_.CommandLine -and $_.CommandLine -like "*n8n*") 
    }
    
    foreach ($proc in $nodeProcesses) {
        Write-Host "Terminating node process with PID: $($proc.Id)" -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "n8n service stopped." -ForegroundColor Green
}

function Get-N8nStatus {
    $portConnections = Get-NetTCPConnection -LocalPort $n8nPort -ErrorAction SilentlyContinue
    if ($portConnections) {
        Write-Host "n8n is running on port $n8nPort" -ForegroundColor Green
        foreach ($conn in $portConnections) {
            Write-Host "  Process ID: $($conn.OwningProcess)" -ForegroundColor Green
            $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($proc) {
                Write-Host "  Process Name: $($proc.ProcessName)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "n8n is not running on port $n8nPort" -ForegroundColor Red
    }
}

switch ($Action) {
    "start" { Start-N8n }
    "stop" { Stop-N8n }
    "status" { Get-N8nStatus }
}