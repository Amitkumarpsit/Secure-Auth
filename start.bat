@echo off
REM Quick Start Script for Secure Auth Application (Windows)
REM This script helps you get started quickly

echo.
echo 🚀 Secure Auth Application - Quick Start
echo ========================================
echo.

REM Check if .env exists
if not exist .env (
    echo ⚠️  .env file not found!
    echo 📝 Creating .env from .env.example...
    copy .env.example .env
    echo ✅ .env file created. Please edit it with your Supabase credentials.
    echo.
    echo Required environment variables:
    echo   - VITE_SUPABASE_URL
    echo   - VITE_SUPABASE_ANON_KEY
    echo   - SUPABASE_URL
    echo   - SUPABASE_KEY
    echo   - JWT_SECRET
    echo.
    pause
)

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

echo ✅ Docker and Docker Compose are installed
echo.

REM Ask user for deployment method
echo Choose deployment method:
echo 1^) Docker Compose ^(Recommended^)
echo 2^) Local Development ^(npm^)
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo 🐳 Starting application with Docker Compose...
    docker-compose up --build -d
    
    echo.
    echo ⏳ Waiting for services to start...
    timeout /t 10 /nobreak >nul
    
    echo.
    echo ✅ Application started!
    echo.
    echo 📱 Access your application:
    echo    Frontend: http://localhost:3000
    echo    Backend:  http://localhost:3001
    echo.
    echo 📊 View logs:
    echo    docker-compose logs -f
    echo.
    echo 🛑 Stop application:
    echo    docker-compose down
    
) else if "%choice%"=="2" (
    echo.
    echo 🔧 Setting up local development environment...
    
    REM Check if Node.js is installed
    node --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Node.js is not installed. Please install Node.js 20+ first.
        pause
        exit /b 1
    )
    
    echo ✅ Node.js is installed
    
    REM Set up backend
    echo.
    echo 📦 Installing backend dependencies...
    cd backend
    if not exist .env (
        copy .env.example .env
        echo ✅ Backend .env created. Please edit it with your credentials.
    )
    call npm install
    
    REM Set up frontend
    echo.
    echo 📦 Installing frontend dependencies...
    cd ..\frontend
    if not exist .env (
        copy .env.example .env
        echo ✅ Frontend .env created. Please edit it with your credentials.
    )
    call npm install
    
    echo.
    echo ✅ Dependencies installed!
    echo.
    echo 🚀 To start the application:
    echo.
    echo Terminal 1 ^(Backend^):
    echo   cd backend
    echo   npm run start:dev
    echo.
    echo Terminal 2 ^(Frontend^):
    echo   cd frontend
    echo   npm run dev
    echo.
    echo 📱 Then access:
    echo    Frontend: http://localhost:5173
    echo    Backend:  http://localhost:3001
    
    cd ..
) else (
    echo Invalid choice. Please run the script again.
    pause
    exit /b 1
)

echo.
echo 📖 For more information, see README.md and DEPLOYMENT.md
echo.
pause
