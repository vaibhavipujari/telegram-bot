@echo off
setlocal enabledelayedexpansion

:: Link Server Docker Setup Script for Windows
:: This script helps you set up and run the Link Server using Docker on Windows

title Link Server Docker Setup

:: Colors (limited in Windows batch)
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

:: Function to check if Docker is installed
:check_docker
echo %INFO% Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/desktop/windows/
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker Compose is not installed. Please install Docker Compose first.
    echo Visit: https://docs.docker.com/compose/install/
    pause
    exit /b 1
)

echo %SUCCESS% Docker and Docker Compose are installed
goto :eof

:: Function to create environment file if it doesn't exist
:setup_env
if not exist ".env" (
    echo %INFO% Creating .env file from template...
    copy env.example .env >nul
    echo %WARNING% Please edit .env file with your configuration before running the application
    echo %WARNING% Important: Change the default admin password and JWT secret!
) else (
    echo %SUCCESS% .env file already exists
)
goto :eof

:: Function to create uploads directory
:setup_directories
echo %INFO% Setting up directories...
if not exist "uploads" mkdir uploads
if not exist "uploads\.gitkeep" echo. > uploads\.gitkeep
echo %SUCCESS% Directories created
goto :eof

:: Function to build Docker images
:build_images
echo %INFO% Building Docker images...

:: Build production image
docker build --target production -t link-server:latest .
if errorlevel 1 (
    echo %ERROR% Failed to build production image
    pause
    exit /b 1
)

:: Build development image
docker build --target development -t link-server:dev .
if errorlevel 1 (
    echo %ERROR% Failed to build development image
    pause
    exit /b 1
)

echo %SUCCESS% Docker images built successfully
goto :eof

:: Function to run in development mode
:run_development
echo %INFO% Starting Link Server in development mode...
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d
if errorlevel 1 (
    echo %ERROR% Failed to start development server
    pause
    exit /b 1
)

echo %SUCCESS% Development server started!
echo %INFO% Access the application at: http://localhost:3000
echo %INFO% Admin login: http://localhost:3000/login
echo %INFO% Dashboard: http://localhost:3000/dashboard
echo %INFO% Upload Manager: http://localhost:3000/upload
echo %INFO% Channel Manager: http://localhost:3000/channels
echo.
echo %INFO% To view logs: docker-compose logs -f
echo %INFO% To stop: docker-compose down
goto :eof

:: Function to run in production mode
:run_production
echo %INFO% Starting Link Server in production mode...
docker-compose up --build -d
if errorlevel 1 (
    echo %ERROR% Failed to start production server
    pause
    exit /b 1
)

echo %SUCCESS% Production server started!
echo %INFO% Access the application at: http://localhost:3000
echo.
echo %INFO% To view logs: docker-compose logs -f
echo %INFO% To stop: docker-compose down
goto :eof

:: Function to run with Nginx
:run_with_nginx
echo %INFO% Starting Link Server with Nginx reverse proxy...
docker-compose --profile production up --build -d
if errorlevel 1 (
    echo %ERROR% Failed to start server with Nginx
    pause
    exit /b 1
)

echo %SUCCESS% Production server with Nginx started!
echo %INFO% Access the application at: http://localhost
echo.
echo %INFO% To view logs: docker-compose logs -f
echo %INFO% To stop: docker-compose --profile production down
goto :eof

:: Function to stop all services
:stop_services
echo %INFO% Stopping all services...
docker-compose down
docker-compose --profile production down 2>nul
echo %SUCCESS% All services stopped
goto :eof

:: Function to show logs
:show_logs
echo %INFO% Showing application logs...
docker-compose logs -f link-server
goto :eof

:: Function to show status
:show_status
echo %INFO% Docker containers status:
docker-compose ps
echo.
echo %INFO% Docker images:
docker images | findstr "link-server nginx"
echo.
echo %INFO% Docker volumes:
docker volume ls | findstr "link-server"
goto :eof

:: Function to cleanup
:cleanup
echo %INFO% Cleaning up Docker resources...

:: Stop and remove containers
docker-compose down --remove-orphans
docker-compose --profile production down --remove-orphans 2>nul

:: Remove images
docker rmi link-server:latest link-server:dev 2>nul

:: Ask about volumes
set /p "remove_volumes=Do you want to remove Docker volumes? This will delete uploaded files! (y/N): "
if /i "!remove_volumes!"=="y" (
    docker volume prune -f
    echo %WARNING% Docker volumes removed
)

:: Remove unused networks
docker network prune -f

echo %SUCCESS% Cleanup completed
goto :eof

:: Main menu
:show_menu
echo.
echo ===================================
echo    Link Server Docker Setup
echo ===================================
echo 1. Setup (create directories and .env)
echo 2. Build Docker images
echo 3. Run in Development mode
echo 4. Run in Production mode
echo 5. Run with Nginx (Production + Reverse Proxy)
echo 6. Stop all services
echo 7. Show logs
echo 8. Show status
echo 9. Cleanup Docker resources
echo 0. Exit
echo ===================================
goto :eof

:: Main script
:main
echo %INFO% Link Server Docker Setup Script for Windows

:: Check Docker installation
call :check_docker

:: Handle command line arguments
if "%1"=="setup" (
    call :setup_env
    call :setup_directories
    goto :end
)
if "%1"=="build" (
    call :build_images
    goto :end
)
if "%1"=="dev" (
    call :setup_env
    call :setup_directories
    call :run_development
    goto :end
)
if "%1"=="prod" (
    call :setup_env
    call :setup_directories
    call :run_production
    goto :end
)
if "%1"=="nginx" (
    call :setup_env
    call :setup_directories
    call :run_with_nginx
    goto :end
)
if "%1"=="stop" (
    call :stop_services
    goto :end
)
if "%1"=="logs" (
    call :show_logs
    goto :end
)
if "%1"=="status" (
    call :show_status
    goto :end
)
if "%1"=="cleanup" (
    call :cleanup
    goto :end
)

:: Show interactive menu if no arguments
:menu_loop
call :show_menu
set /p "choice=Choose an option (0-9): "

if "%choice%"=="1" (
    call :setup_env
    call :setup_directories
) else if "%choice%"=="2" (
    call :build_images
) else if "%choice%"=="3" (
    call :setup_env
    call :setup_directories
    call :run_development
) else if "%choice%"=="4" (
    call :setup_env
    call :setup_directories
    call :run_production
) else if "%choice%"=="5" (
    call :setup_env
    call :setup_directories
    call :run_with_nginx
) else if "%choice%"=="6" (
    call :stop_services
) else if "%choice%"=="7" (
    call :show_logs
) else if "%choice%"=="8" (
    call :show_status
) else if "%choice%"=="9" (
    call :cleanup
) else if "%choice%"=="0" (
    echo %SUCCESS% Goodbye!
    goto :end
) else (
    echo %ERROR% Invalid option. Please choose 0-9.
)

echo.
pause
goto :menu_loop

:end
pause
exit /b 0

:: Start main function
call :main %*
