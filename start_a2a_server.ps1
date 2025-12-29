#!/usr/bin/env pwsh
<#
.SYNOPSIS
Start the A2A Product Manager server
.DESCRIPTION
Activates the Python virtual environment and starts the A2A application server
#>

# Set the working directory
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcDir = Join-Path $projectRoot "src"
$pythonExe = Join-Path $projectRoot "venv_short\Scripts\python.exe"

# Change to src directory
Set-Location $srcDir

Write-Host "Starting Zava A2A Product Manager..." -ForegroundColor Green
Write-Host "Python: $pythonExe" -ForegroundColor Cyan
Write-Host "Working Directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server will be available at: http://localhost:8001" -ForegroundColor Yellow
Write-Host "Agent Card: http://localhost:8001/agent-card" -ForegroundColor Yellow
Write-Host "Health Check: http://localhost:8001/health" -ForegroundColor Yellow
Write-Host ""

# Run the application
& $pythonExe -u a2a\main.py
