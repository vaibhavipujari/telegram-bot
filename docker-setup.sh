#!/bin/bash

# Link Server Docker Setup Script
# This script helps you set up and run the Link Server using Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Function to create environment file if it doesn't exist
setup_env() {
    if [ ! -f ".env" ]; then
        print_status "Creating .env file from template..."
        cp env.example .env
        print_warning "Please edit .env file with your configuration before running the application"
        print_warning "Important: Change the default admin password and JWT secret!"
    else
        print_success ".env file already exists"
    fi
}

# Function to create uploads directory
setup_directories() {
    print_status "Setting up directories..."
    mkdir -p uploads
    touch uploads/.gitkeep
    print_success "Directories created"
}

# Function to build Docker images
build_images() {
    print_status "Building Docker images..."
    
    # Build production image
    docker build --target production -t link-server:latest .
    
    # Build development image
    docker build --target development -t link-server:dev .
    
    print_success "Docker images built successfully"
}

# Function to run in development mode
run_development() {
    print_status "Starting Link Server in development mode..."
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d
    
    print_success "Development server started!"
    print_status "Access the application at: http://localhost:3000"
    print_status "Admin login: http://localhost:3000/login"
    print_status "Dashboard: http://localhost:3000/dashboard"
    print_status "Upload Manager: http://localhost:3000/upload"
    print_status "Channel Manager: http://localhost:3000/channels"
    
    echo ""
    print_status "To view logs: docker-compose logs -f"
    print_status "To stop: docker-compose down"
}

# Function to run in production mode
run_production() {
    print_status "Starting Link Server in production mode..."
    docker-compose up --build -d
    
    print_success "Production server started!"
    print_status "Access the application at: http://localhost:3000"
    
    echo ""
    print_status "To view logs: docker-compose logs -f"
    print_status "To stop: docker-compose down"
}

# Function to run with Nginx (production with reverse proxy)
run_with_nginx() {
    print_status "Starting Link Server with Nginx reverse proxy..."
    docker-compose --profile production up --build -d
    
    print_success "Production server with Nginx started!"
    print_status "Access the application at: http://localhost"
    
    echo ""
    print_status "To view logs: docker-compose logs -f"
    print_status "To stop: docker-compose --profile production down"
}

# Function to stop all services
stop_services() {
    print_status "Stopping all services..."
    docker-compose down
    docker-compose --profile production down 2>/dev/null || true
    print_success "All services stopped"
}

# Function to clean up Docker resources
cleanup() {
    print_status "Cleaning up Docker resources..."
    
    # Stop and remove containers
    docker-compose down --remove-orphans
    docker-compose --profile production down --remove-orphans 2>/dev/null || true
    
    # Remove images
    docker rmi link-server:latest link-server:dev 2>/dev/null || true
    
    # Remove unused volumes (be careful with this)
    read -p "Do you want to remove Docker volumes? This will delete uploaded files! (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
        print_warning "Docker volumes removed"
    fi
    
    # Remove unused networks
    docker network prune -f
    
    print_success "Cleanup completed"
}

# Function to show logs
show_logs() {
    print_status "Showing application logs..."
    docker-compose logs -f link-server
}

# Function to show status
show_status() {
    print_status "Docker containers status:"
    docker-compose ps
    
    echo ""
    print_status "Docker images:"
    docker images | grep -E "(link-server|nginx)"
    
    echo ""
    print_status "Docker volumes:"
    docker volume ls | grep link-server
}

# Function to generate password hash
generate_password_hash() {
    read -s -p "Enter password to hash: " password
    echo ""
    
    # Use Node.js to generate bcrypt hash
    hash=$(docker run --rm -i node:18-alpine node -e "
        const bcrypt = require('crypto');
        const password = '$password';
        console.log('Plain text for development: ' + password);
        console.log('For production, use a proper bcrypt hash generator');
    ")
    
    echo "Password: $password"
    print_warning "Remember to use a proper bcrypt hash for production!"
}

# Main menu
show_menu() {
    echo ""
    echo "==================================="
    echo "   Link Server Docker Setup"
    echo "==================================="
    echo "1. Setup (create directories and .env)"
    echo "2. Build Docker images"
    echo "3. Run in Development mode"
    echo "4. Run in Production mode"
    echo "5. Run with Nginx (Production + Reverse Proxy)"
    echo "6. Stop all services"
    echo "7. Show logs"
    echo "8. Show status"
    echo "9. Cleanup Docker resources"
    echo "10. Generate password hash"
    echo "0. Exit"
    echo "==================================="
}

# Main script logic
main() {
    print_status "Link Server Docker Setup Script"
    
    # Check Docker installation
    check_docker
    
    # Show menu if no arguments provided
    if [ $# -eq 0 ]; then
        while true; do
            show_menu
            read -p "Choose an option (0-10): " choice
            
            case $choice in
                1)
                    setup_env
                    setup_directories
                    ;;
                2)
                    build_images
                    ;;
                3)
                    setup_env
                    setup_directories
                    run_development
                    ;;
                4)
                    setup_env
                    setup_directories
                    run_production
                    ;;
                5)
                    setup_env
                    setup_directories
                    run_with_nginx
                    ;;
                6)
                    stop_services
                    ;;
                7)
                    show_logs
                    ;;
                8)
                    show_status
                    ;;
                9)
                    cleanup
                    ;;
                10)
                    generate_password_hash
                    ;;
                0)
                    print_success "Goodbye!"
                    exit 0
                    ;;
                *)
                    print_error "Invalid option. Please choose 0-10."
                    ;;
            esac
            
            echo ""
            read -p "Press Enter to continue..."
        done
    fi
    
    # Handle command line arguments
    case "$1" in
        "setup")
            setup_env
            setup_directories
            ;;
        "build")
            build_images
            ;;
        "dev")
            setup_env
            setup_directories
            run_development
            ;;
        "prod")
            setup_env
            setup_directories
            run_production
            ;;
        "nginx")
            setup_env
            setup_directories
            run_with_nginx
            ;;
        "stop")
            stop_services
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            echo "Usage: $0 {setup|build|dev|prod|nginx|stop|logs|status|cleanup}"
            echo "Or run without arguments for interactive menu"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
