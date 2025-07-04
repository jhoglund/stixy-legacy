#!/bin/bash

# Docker development helper script for Stixy Legacy Rails 2.1 app

set -e

case "$1" in
  "build")
    echo "Building Docker images..."
    docker-compose build --no-cache
    ;;
  
  "up")
    echo "Starting services..."
    docker-compose up -d
    echo "Services started. Web app available at http://localhost:3000"
    ;;
  
  "down")
    echo "Stopping services..."
    docker-compose down
    ;;
  
  "logs")
    service=${2:-web}
    echo "Following logs for $service..."
    docker-compose logs -f $service
    ;;
  
  "shell")
    echo "Opening shell in web container..."
    docker-compose exec web /bin/bash
    ;;
  
  "db-shell")
    echo "Opening MySQL shell..."
    docker-compose exec db mysql -u mysql -ppassw0rd stixy_dev
    ;;
  
  "restart")
    echo "Restarting services..."
    docker-compose restart
    ;;
  
  "clean")
    echo "Cleaning up Docker resources..."
    docker-compose down -v
    docker system prune -f
    ;;
  
  "reset")
    echo "Resetting everything (WARNING: This will delete all data)..."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      docker-compose down -v
      docker system prune -f
      docker volume prune -f
      echo "Reset complete. Run '$0 build' then '$0 up' to start fresh."
    fi
    ;;
  
  "status")
    echo "Service status:"
    docker-compose ps
    ;;
  
  "help"|*)
    echo "Stixy Legacy Docker Development Helper"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  build     - Build Docker images"
    echo "  up        - Start all services"
    echo "  down      - Stop all services"
    echo "  logs      - Follow logs (optional: service name)"
    echo "  shell     - Open shell in web container"
    echo "  db-shell  - Open MySQL shell"
    echo "  restart   - Restart all services"
    echo "  status    - Show service status"
    echo "  clean     - Clean up Docker resources"
    echo "  reset     - Reset everything (WARNING: deletes data)"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 up"
    echo "  $0 logs web"
    echo "  $0 shell"
    ;;
esac 