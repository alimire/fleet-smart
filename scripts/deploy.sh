#!/bin/bash

set -e

echo "🚀 Starting Fleet Smart deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    print_status "Docker installed successfully"
else
    print_status "Docker is already installed"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_status "Docker Compose installed successfully"
fi

# Stop existing containers if running
print_status "Stopping existing containers..."
sudo docker-compose down || true

# Remove old images to ensure fresh build
print_status "Cleaning up old images..."
sudo docker system prune -f || true

# Build and start containers
print_status "Building and starting Fleet Smart containers..."
sudo docker-compose up -d --build

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Check container status
print_status "Checking container status..."
sudo docker-compose ps

# Test if Odoo is responding
print_status "Testing Odoo connectivity..."
for i in {1..10}; do
    if curl -f http://localhost:8069 > /dev/null 2>&1; then
        print_status "✅ Fleet Smart is running successfully!"
        print_status "🌐 Access your app at: http://$(curl -s ifconfig.me):8069"
        break
    else
        print_warning "Waiting for Odoo to start... (attempt $i/10)"
        sleep 10
    fi
done

# Show logs if something went wrong
if ! curl -f http://localhost:8069 > /dev/null 2>&1; then
    print_error "❌ Fleet Smart failed to start properly"
    print_error "Container logs:"
    sudo docker-compose logs --tail=20
    exit 1
fi

print_status "🎉 Deployment completed successfully!"
print_status "📋 Next steps:"
print_status "   1. Access Odoo at http://$(curl -s ifconfig.me):8069"
print_status "   2. Create a database"
print_status "   3. Install the Fleet Smart app"
print_status "   4. Start managing your EV fleet!"