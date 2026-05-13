#!/bin/bash

# Deployment script for CrudMvcApp
# This script handles Docker-based deployment using docker-compose

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-crudmvcapp}
DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME:-crudmvcapp}
DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG:-latest}
ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT:-Production}
COMPOSE_FILE="docker-compose.yml"

# Logging function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    log_info "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    log_info "Docker is installed and running."
}

# Check if docker-compose is available
check_docker_compose() {
    log_info "Checking Docker Compose..."
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        log_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    log_info "Docker Compose is available."
}

# Stop and remove existing containers
stop_existing_containers() {
    log_info "Stopping existing containers..."
    if [ -f "$COMPOSE_FILE" ]; then
        $COMPOSE_CMD down || true
    else
        if docker ps -a --format '{{.Names}}' | grep -q "^${DOCKER_CONTAINER_NAME}$"; then
            log_info "Stopping container: ${DOCKER_CONTAINER_NAME}"
            docker stop ${DOCKER_CONTAINER_NAME} || true
            docker rm ${DOCKER_CONTAINER_NAME} || true
        fi
    fi
    log_info "Existing containers stopped."
}

# Remove old images (optional cleanup)
cleanup_old_images() {
    log_warn "Cleaning up old Docker images..."
    # Keep only the latest 2 images
    docker images ${DOCKER_IMAGE_NAME} --format "{{.ID}}" | tail -n +3 | xargs -r docker rmi -f || true
    log_info "Cleanup completed."
}

# Build Docker image if not exists
build_image_if_needed() {
    log_info "Checking if Docker image exists..."
    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}$"; then
        log_info "Building Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
        docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
        log_info "Docker image built successfully."
    else
        log_info "Docker image already exists: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
    fi
}

# Deploy using docker-compose
deploy_with_compose() {
    log_info "Deploying with Docker Compose..."
    
    # Export environment variables for docker-compose
    export ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT}
    export DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME}
    export DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}
    
    # Update docker-compose.yml with the correct image tag
    if [ -f "$COMPOSE_FILE" ]; then
        log_info "Starting services with docker-compose..."
        $COMPOSE_CMD up -d --build
        
        log_info "Waiting for services to be healthy..."
        sleep 5
        
        # Check if container is running
        if docker ps --format '{{.Names}}' | grep -q "${DOCKER_CONTAINER_NAME}"; then
            log_info "Container is running."
        else
            log_error "Container failed to start."
            $COMPOSE_CMD logs
            exit 1
        fi
    else
        log_error "docker-compose.yml not found."
        exit 1
    fi
}

# Deploy using docker run (fallback)
deploy_with_docker_run() {
    log_info "Deploying with Docker run..."
    
    docker run -d \
        --name ${DOCKER_CONTAINER_NAME} \
        --restart unless-stopped \
        -p 8080:8080 \
        -p 8081:8081 \
        -e ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT} \
        -e ASPNETCORE_URLS=http://+:8080 \
        ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    
    log_info "Container started: ${DOCKER_CONTAINER_NAME}"
}

# Health check
health_check() {
    log_info "Performing health check..."
    max_attempts=30
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -f -s http://localhost:8080 > /dev/null 2>&1; then
            log_info "Application is healthy and responding."
            return 0
        fi
        attempt=$((attempt + 1))
        log_info "Waiting for application to be ready... (attempt $attempt/$max_attempts)"
        sleep 2
    done
    
    log_error "Health check failed. Application is not responding."
    return 1
}

# Show deployment information
show_deployment_info() {
    log_info "=== Deployment Information ==="
    echo "Container Name: ${DOCKER_CONTAINER_NAME}"
    echo "Image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
    echo "Environment: ${ASPNETCORE_ENVIRONMENT}"
    echo "Application URL: http://localhost:8080"
    echo ""
    log_info "Container Status:"
    docker ps --filter "name=${DOCKER_CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    log_info "To view logs, run: docker logs -f ${DOCKER_CONTAINER_NAME}"
    log_info "To stop, run: docker stop ${DOCKER_CONTAINER_NAME}"
}

# Main deployment flow
main() {
    log_info "Starting deployment process..."
    log_info "Environment: ${ASPNETCORE_ENVIRONMENT}"
    log_info "Image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
    
    check_docker
    check_docker_compose
    stop_existing_containers
    build_image_if_needed
    
    if [ -f "$COMPOSE_FILE" ]; then
        deploy_with_compose
    else
        log_warn "docker-compose.yml not found, using docker run instead."
        deploy_with_docker_run
    fi
    
    if health_check; then
        show_deployment_info
        log_info "Deployment completed successfully!"
    else
        log_error "Deployment completed but health check failed."
        log_info "Checking container logs..."
        docker logs ${DOCKER_CONTAINER_NAME} || $COMPOSE_CMD logs
        exit 1
    fi
}

# Run main function
main "$@"
