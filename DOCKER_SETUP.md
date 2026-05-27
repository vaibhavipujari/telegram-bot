# 🐳 Docker Setup Guide for Link Server

This guide will help you set up and run the Link Server application using Docker.

## 📋 Prerequisites

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** (usually included with Docker Desktop)
- **Git** (to clone the repository)

### Installation Links
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/)
- [Docker Engine for Linux](https://docs.docker.com/engine/install/)

## 🚀 Quick Start

### Option 1: Using Setup Scripts (Recommended)

#### For Linux/Mac:
```bash
# Make the script executable
chmod +x docker-setup.sh

# Run interactive setup
./docker-setup.sh

# Or use direct commands
./docker-setup.sh dev    # Development mode
./docker-setup.sh prod   # Production mode
```

#### For Windows:
```cmd
# Run the batch script
docker-setup.bat

# Or use direct commands
docker-setup.bat dev     # Development mode
docker-setup.bat prod    # Production mode
```

### Option 2: Manual Setup

#### 1. Setup Environment
```bash
# Copy environment template
cp env.example .env

# Edit the .env file with your configuration
nano .env  # or use your preferred editor
```

#### 2. Create Required Directories
```bash
mkdir -p uploads
```

#### 3. Run the Application

**Development Mode:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d
```

**Production Mode:**
```bash
docker-compose up --build -d
```

**Production with Nginx:**
```bash
docker-compose --profile production up --build -d
```

## 🔧 Configuration

### Environment Variables

The application uses the following environment variables:

#### **Authentication Configuration**
```env
ADMIN_USERNAME=admin@brighthex.in
ADMIN_PASSWORD=your-secure-password
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=24h
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=900000
```

#### **Database Configuration**
```env
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/database
MONGODB_DB_NAME=linkserver
```

#### **Application Configuration**
```env
NODE_ENV=production
HOST=0.0.0.0
PORT=3000
MAX_FILE_SIZE=104857600
RATE_LIMIT_MAX=50
REQUIRE_DEVICE_REGISTRATION=true
```

### 🔒 Security Considerations

#### For Production:
1. **Change Default Passwords**: Update `ADMIN_PASSWORD` with a strong password
2. **Generate Strong JWT Secret**: Use a long, random string for `JWT_SECRET`
3. **Use Hashed Passwords**: For production, use bcrypt hashed passwords
4. **Configure CORS**: Set specific domains in `CORS_ORIGINS`
5. **Enable HTTPS**: Configure SSL certificates with Nginx

#### Password Hashing:
```bash
# Generate bcrypt hash for production
node -e "console.log(require('bcrypt').hashSync('your-password', 12))"
```

## 🏗️ Docker Architecture

### Multi-Stage Dockerfile

The Dockerfile uses multi-stage builds for optimization:

- **Base Stage**: Common setup for all environments
- **Development Stage**: Includes dev dependencies and nodemon
- **Production Dependencies**: Only production npm packages
- **Production Stage**: Optimized for production with security hardening

### Docker Compose Configurations

#### **docker-compose.yml** (Production)
- Production environment variables
- Stricter rate limiting
- Security-focused configuration
- Optional Nginx reverse proxy

#### **docker-compose.dev.yml** (Development Override)
- Development environment variables
- Live code reloading
- Relaxed rate limiting
- Debug logging enabled

## 📱 Access Points

Once running, access the application at:

### Development Mode
- **Main App**: http://localhost:3000
- **Admin Login**: http://localhost:3000/login
- **Dashboard**: http://localhost:3000/dashboard
- **Upload Manager**: http://localhost:3000/upload
- **Channel Manager**: http://localhost:3000/channels
- **Health Check**: http://localhost:3000/health

### Production Mode
- **With Nginx**: http://localhost (port 80)
- **Direct**: http://localhost:3000

## 🛠️ Management Commands

### Container Management
```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f link-server

# Stop services
docker-compose down

# Restart services
docker-compose restart

# Rebuild and restart
docker-compose up --build -d
```

### Database Operations
```bash
# Access MongoDB (if using local instance)
docker-compose exec mongodb mongo

# Backup uploads volume
docker run --rm -v link-server_apk_storage:/data -v $(pwd):/backup alpine tar czf /backup/uploads-backup.tar.gz /data

# Restore uploads volume
docker run --rm -v link-server_apk_storage:/data -v $(pwd):/backup alpine tar xzf /backup/uploads-backup.tar.gz -C /
```

### Maintenance
```bash
# Update application
git pull
docker-compose up --build -d

# Clean up unused Docker resources
docker system prune -f

# Remove all containers and volumes (DESTRUCTIVE)
docker-compose down -v --remove-orphans
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using port 3000
lsof -i :3000  # Linux/Mac
netstat -ano | findstr :3000  # Windows

# Use different port
docker-compose up -d --scale link-server=0
docker-compose run -p 3001:3000 link-server
```

#### 2. Permission Issues (Linux)
```bash
# Fix upload directory permissions
sudo chown -R 1001:1001 uploads/

# Or run with current user
docker-compose run --user $(id -u):$(id -g) link-server
```

#### 3. MongoDB Connection Issues
- Verify `MONGODB_URI` in `.env` file
- Check network connectivity
- Ensure MongoDB Atlas IP whitelist includes your IP

#### 4. Build Failures
```bash
# Clean build cache
docker builder prune -f

# Rebuild without cache
docker-compose build --no-cache

# Check Docker disk space
docker system df
```

### Debugging

#### Enable Debug Logging
```bash
# Development mode with debug
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# View detailed logs
docker-compose logs -f link-server
```

#### Access Container Shell
```bash
# Access running container
docker-compose exec link-server sh

# Run new container for debugging
docker-compose run --rm link-server sh
```

#### Health Check
```bash
# Check application health
curl http://localhost:3000/health

# Or using Docker
docker-compose exec link-server wget -qO- http://localhost:3000/health
```

## 📊 Monitoring

### Container Stats
```bash
# Real-time container stats
docker stats

# Specific container stats
docker stats link-server-app
```

### Application Metrics
- **Health Endpoint**: `/health` - Application health status
- **Stats Endpoint**: `/api/stats` - Download statistics
- **Analytics**: `/api/analytics/updates` - Update analytics

### Log Analysis
```bash
# Follow logs with timestamps
docker-compose logs -f -t link-server

# Search logs
docker-compose logs link-server | grep ERROR

# Export logs
docker-compose logs --no-color link-server > app.log
```

## 🚀 Production Deployment

### With Nginx Reverse Proxy
```bash
# Start with Nginx
docker-compose --profile production up -d

# Configure SSL (add to nginx.conf)
# - SSL certificates
# - HTTPS redirects
# - Security headers
```

### Environment Checklist
- [ ] Strong admin password set
- [ ] JWT secret configured
- [ ] CORS origins restricted
- [ ] Rate limiting configured
- [ ] MongoDB connection secured
- [ ] SSL certificates installed
- [ ] Firewall configured
- [ ] Backup strategy implemented

### Scaling
```bash
# Scale application instances
docker-compose up -d --scale link-server=3

# Use load balancer (Nginx, HAProxy, etc.)
# Configure session affinity if needed
```

## 📝 Backup & Recovery

### Backup Strategy
```bash
# Backup uploads
docker run --rm -v link-server_apk_storage:/data -v $(pwd):/backup alpine tar czf /backup/uploads-$(date +%Y%m%d).tar.gz /data

# Backup configuration
cp .env .env.backup
cp docker-compose.yml docker-compose.yml.backup
```

### Recovery
```bash
# Restore uploads
docker run --rm -v link-server_apk_storage:/data -v $(pwd):/backup alpine tar xzf /backup/uploads-20240101.tar.gz -C /

# Restore configuration
cp .env.backup .env
docker-compose up -d
```

## 🆘 Support

If you encounter issues:

1. Check the [troubleshooting section](#troubleshooting)
2. Review Docker and application logs
3. Verify environment configuration
4. Check system resources (disk, memory, network)

### Useful Commands for Support
```bash
# System information
docker version
docker-compose version
docker system info

# Application status
docker-compose ps
docker-compose logs --tail=50 link-server

# Resource usage
docker stats --no-stream
df -h  # Disk usage
```

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)

Happy containerizing! 🐳