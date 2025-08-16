@echo off
echo ================================================
echo Setting up Claude Code Docker environment...
echo ================================================

REM Step 0: Clean up any existing containers with the same name
echo [0/3] Cleaning up existing containers...
docker stop claude-code-dev 2>nul
docker rm claude-code-dev 2>nul

REM Step 1: Build the Docker image
echo [1/3] Building Docker image...
docker-compose build

if %errorlevel% neq 0 (
    echo ERROR: Failed to build Docker image
    pause
    exit /b 1
)

REM Ensure .claude.json exists (Windows equivalent of Unix 'touch')
if not exist ".claude.json" (
    type nul > ".claude.json"
)

REM Step 2: Start the container in detached mode
echo [2/3] Starting container in detached mode...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ERROR: Failed to start container
    pause
    exit /b 1
)

REM Step 3: Enter the container
echo.
echo [3/3] Setup complete! Entering container...
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
docker exec -it claude-code-dev bash

REM After exiting the container
echo.
echo ================================================
echo You've exited the Claude Code container.
echo The container is still running in the background.
echo.
echo To re-enter: docker exec -it claude-code-dev bash
echo To stop: docker-compose down
echo ================================================
pause