# Deployment Guide

This document provides instructions for deploying CrudMvcApp using GitHub Actions workflows and deployment scripts.

## Quick Start

### Automatic Deployment (CI/CD)
- Push to `main` branch → Automatic build, test, and deploy
- Pull requests → Build and test only (no deployment)

### Manual Deployment
1. Go to GitHub Actions tab
2. Select "Manual Deployment" workflow
3. Click "Run workflow"
4. Choose environment and version
5. Execute

## Workflows Overview

### 1. CI/CD Pipeline (`ci-cd.yml`)
**Purpose**: Automated CI/CD for main branch

**Triggers:**
- Push to `main` branch
- Pull requests to `main` branch
- Manual trigger

**Process:**
1. Build and test .NET application
2. Build Docker image
3. Deploy (only on `main` branch, not PRs)

### 2. Manual Deployment (`deploy.yml`)
**Purpose**: On-demand deployments with environment selection

**Features:**
- Choose environment (production/staging)
- Specify version/tag
- Full control over deployment timing

### 3. Self-Hosted Runner Deployment (`self-hosted-deploy.yml`)
**Purpose**: Deploy using self-hosted GitHub runners

**Use Cases:**
- Deploy to on-premises servers
- Deploy to private infrastructure
- Custom deployment environments

## Deployment Script

Location: `scripts/deploy.sh`

**Capabilities:**
- ✅ Docker and Docker Compose validation
- ✅ Container lifecycle management
- ✅ Health checks
- ✅ Automatic cleanup
- ✅ Detailed logging with colors
- ✅ Error handling

**Usage:**
```bash
# Basic deployment
./scripts/deploy.sh

# With custom environment variables
DOCKER_IMAGE_TAG=v1.0.0 ASPNETCORE_ENVIRONMENT=Production ./scripts/deploy.sh
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOCKER_IMAGE_NAME` | `crudmvcapp` | Docker image name |
| `DOCKER_CONTAINER_NAME` | `crudmvcapp` | Container name |
| `DOCKER_IMAGE_TAG` | `latest` | Image version/tag |
| `ASPNETCORE_ENVIRONMENT` | `Production` | .NET environment |

## Setup for Self-Hosted Runners

### Prerequisites
1. Install Docker:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

2. Install Docker Compose:
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. Install .NET SDK (for building):
   ```bash
   # Follow instructions at https://dotnet.microsoft.com/download
   ```

4. Register GitHub Runner:
   - Go to repository Settings → Actions → Runners
   - Click "New self-hosted runner"
   - Follow the setup instructions

### Runner Configuration
- Runner should have Docker daemon running
- User should have permissions to run Docker commands
- Ports 8080 and 8081 should be available

## Deployment Process

### Step-by-Step

1. **Build Phase**
   - Restore NuGet packages
   - Build .NET application
   - Run tests (if any)

2. **Docker Phase**
   - Build Docker image
   - Tag image with version
   - Cache layers for faster builds

3. **Deploy Phase**
   - Stop existing containers
   - Start new containers
   - Perform health checks
   - Verify deployment

### Health Checks

The deployment script performs health checks:
- Waits up to 60 seconds for application to start
- Checks HTTP endpoint (http://localhost:8080)
- Verifies container is running
- Shows deployment status

## Monitoring

### View Logs
```bash
# Container logs
docker logs -f crudmvcapp

# Docker Compose logs
docker-compose logs -f
```

### Check Status
```bash
# Container status
docker ps --filter "name=crudmvcapp"

# Health check
curl http://localhost:8080
```

### Stop Application
```bash
# Using Docker Compose
docker-compose down

# Using Docker
docker stop crudmvcapp
docker rm crudmvcapp
```

## Troubleshooting

### Workflow Fails at Build Step
- Check .NET SDK version matches project requirements
- Verify all dependencies are available
- Review build logs in GitHub Actions

### Docker Build Fails
- Ensure Dockerfile is correct
- Check Docker daemon is running
- Verify disk space is available

### Deployment Fails
- Check if ports 8080/8081 are already in use
- Review container logs: `docker logs crudmvcapp`
- Verify environment variables are set correctly
- Check Docker Compose configuration

### Health Check Fails
- Review application logs for startup errors
- Verify ASPNETCORE_URLS is configured correctly
- Check if application is binding to correct port
- Ensure database/required services are available

## Best Practices

1. **Versioning**: Use semantic versioning for Docker image tags
2. **Environments**: Separate staging and production deployments
3. **Testing**: Always test in staging before production
4. **Monitoring**: Set up logging and monitoring for production
5. **Backup**: Backup data before major deployments
6. **Rollback**: Keep previous image versions for quick rollback

## Rollback Procedure

If deployment fails or issues occur:

1. **Stop current container:**
   ```bash
   docker stop crudmvcapp
   ```

2. **Start previous version:**
   ```bash
   docker run -d --name crudmvcapp \
     -p 8080:8080 \
     -e ASPNETCORE_ENVIRONMENT=Production \
     crudmvcapp:previous-version
   ```

3. **Or use Docker Compose with specific tag:**
   ```bash
   DOCKER_IMAGE_TAG=previous-version docker-compose up -d
   ```

## Security Considerations

- Never commit secrets or tokens to repository
- Use GitHub Secrets for sensitive data
- Regularly update Docker images and dependencies
- Use least-privilege principle for runners
- Enable Docker content trust for production

## Support

For issues or questions:
- Check workflow logs in GitHub Actions
- Review deployment script logs
- Consult application logs
- Check Docker and system logs
