@echo off
echo ================================================
echo Setting up Claude Code Docker environment...
echo ================================================

REM Step 0: Generate a deterministic container name based on this directory
for /f %%i in ('powershell -NoProfile -Command "$p=(Resolve-Path ""%~dp0"").Path;$h=[System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($p));$hex=[System.BitConverter]::ToString($h).Replace('-','').ToLower();$hex.Substring(0,12)"') do set "CLAUDE_CONTAINER_NAME=claude-code-dev-%%i"
echo [0/4] Preparing container %CLAUDE_CONTAINER_NAME%...

REM Step 1: Build the Docker image
echo [1/4] Building Docker image...
docker-compose build

if %errorlevel% neq 0 (
    echo ERROR: Failed to build Docker image
    pause
    exit /b 1
)

REM Ensure .claude.json exists (Windows equivalent of Unix 'touch')
if not exist ".claude.json" (
    echo {} > ".claude.json"
)

REM Step 2: Start the container in detached mode
echo [2/4] Starting container in detached mode...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ERROR: Failed to start container
    pause
    exit /b 1
)

REM Step 3: Wait for firewall initialization
echo [3/4] Waiting for firewall to initialize...
:wait_firewall
docker exec %CLAUDE_CONTAINER_NAME% bash -c "test -f /tmp/firewall.ready" >nul 2>&1
if %errorlevel% neq 0 (
    timeout /t 1 >nul
    goto wait_firewall
)

REM Step 4: Enter the container
echo.
echo [4/4] Setup complete! Entering container...
echo.
echo IMPORTANT: Run 'claude-code auth' to set up your API key
echo Your repository root is available at /workspace
echo.
echo ================================================
echo Quick commands inside the container:
echo   claude-code auth          - Set up API key
echo   claude-code --help        - Show help
echo   cd /workspace            - Go to repository root
echo   exit                     - Leave container
echo ================================================
echo.

REM Enter the container interactively
docker exec -it %CLAUDE_CONTAINER_NAME% bash

REM After exiting the container
echo.
echo ================================================
echo You've exited the Claude Code container.
echo The container is still running in the background.
echo.
echo To re-enter: docker exec -it %CLAUDE_CONTAINER_NAME% bash
echo To stop: docker stop %CLAUDE_CONTAINER_NAME%
echo ================================================
pause
