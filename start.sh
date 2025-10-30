#!/bin/bash

# Quick Start Script for Secure Auth Application
# This script helps you get started quickly

echo "🚀 Secure Auth Application - Quick Start"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it with your Supabase credentials."
    echo ""
    echo "Required environment variables:"
    echo "  - VITE_SUPABASE_URL"
    echo "  - VITE_SUPABASE_ANON_KEY"
    echo "  - SUPABASE_URL"
    echo "  - SUPABASE_KEY"
    echo "  - JWT_SECRET"
    echo ""
    read -p "Press Enter after you've updated the .env file..."
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Ask user for deployment method
echo "Choose deployment method:"
echo "1) Docker Compose (Recommended)"
echo "2) Local Development (npm)"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" = "1" ]; then
    echo ""
    echo "🐳 Starting application with Docker Compose..."
    docker-compose up --build -d
    
    echo ""
    echo "⏳ Waiting for services to start..."
    sleep 10
    
    echo ""
    echo "✅ Application started!"
    echo ""
    echo "📱 Access your application:"
    echo "   Frontend: http://localhost:3000"
    echo "   Backend:  http://localhost:3001"
    echo ""
    echo "📊 View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 Stop application:"
    echo "   docker-compose down"
    
elif [ "$choice" = "2" ]; then
    echo ""
    echo "🔧 Setting up local development environment..."
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed. Please install Node.js 20+ first."
        exit 1
    fi
    
    echo "✅ Node.js is installed ($(node --version))"
    
    # Set up backend
    echo ""
    echo "📦 Installing backend dependencies..."
    cd backend
    if [ ! -f .env ]; then
        cp .env.example .env
        echo "✅ Backend .env created. Please edit it with your credentials."
    fi
    npm install
    
    # Set up frontend
    echo ""
    echo "📦 Installing frontend dependencies..."
    cd ../frontend
    if [ ! -f .env ]; then
        cp .env.example .env
        echo "✅ Frontend .env created. Please edit it with your credentials."
    fi
    npm install
    
    echo ""
    echo "✅ Dependencies installed!"
    echo ""
    echo "🚀 To start the application:"
    echo ""
    echo "Terminal 1 (Backend):"
    echo "  cd backend"
    echo "  npm run start:dev"
    echo ""
    echo "Terminal 2 (Frontend):"
    echo "  cd frontend"
    echo "  npm run dev"
    echo ""
    echo "📱 Then access:"
    echo "   Frontend: http://localhost:5173"
    echo "   Backend:  http://localhost:3001"
    
    cd ..
else
    echo "Invalid choice. Please run the script again."
    exit 1
fi

echo ""
echo "📖 For more information, see README.md and DEPLOYMENT.md"
echo ""
