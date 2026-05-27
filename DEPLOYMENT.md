# 🚀 Deployment Guide

This guide covers deploying the Link Server (Telegram APK Download Server) to various platforms including Render, Docker, and traditional VPS.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Render Deployment](#render-deployment)
- [Docker Deployment](#docker-deployment)
- [VPS Deployment](#vps-deployment)
- [Environment Variables](#environment-variables)
- [Production Configuration](#production-configuration)
- [Monitoring & Health Checks](#monitoring--health-checks)

## 🚀 Quick Start

### Local Development
```bash
# Clone the repository
git clone <your-repo-url>
cd link-server

# Install dependencies
npm install

# Copy environment file
cp env.example .env

# Start development server
npm run dev
```

### Production Quick Deploy
```bash
# Set production environment
export NODE_ENV=production
export HOST=0.0.0.0
export PORT=80

# Start production server
npm run prod
```

## 🌐 Render Deployment

### Automatic Deployment (Recommended)

1. **Fork/Clone this repository** to your GitHub account

2. **Connect to Render:**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository

3. **Configure Service:**
   - **Name:** `link-server`
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Plan:** Choose based on your needs (Starter/Standard/Pro)

4. **Set Environment Variables:**
   ```
   NODE_ENV=production
   HOST=0.0.0.0
   MAX_FILE_SIZE=104857600
   RATE_LIMIT_MAX=50
   REQUIRE_DEVICE_REGISTRATION=true
   IOS_APP_STORE_URL=https://apps.apple.com/app/id123456789
   ANDROID_PLAY_STORE_URL=https://play.google.com/store/apps/details?id=com.yourapp
   CORS_ORIGINS=https://yourdomain.com
   ```

5. **Deploy:** Click "Create Web Service"

### Manual Deployment with render.yaml

1. **Add render.yaml** to your repository (already included)
2. **Connect repository** to Render
3. **Render will automatically** detect and use the configuration

### Custom Domain Setup

1. **In Render Dashboard:**
   - Go to your service → Settings → Custom Domains
   - Add your domain (e.g., `api.yourdomain.com`)

2. **Update DNS:**
   - Add CNAME record: `api` → `your-service.onrender.com`

3. **Update CORS:**
   ```
   CORS_ORIGINS=https://yourdomain.com,https://api.yourdomain.com
   ```

## 🐳 Docker Deployment

### Single Container

```bash
# Build image
docker build -t link-server .

# Run container
docker run -d \
  --name link-server \
  -p 80:3000 \
  -e NODE_ENV=production \
  -e HOST=0.0.0.0 \
  -e PORT=3000 \
  -v $(pwd)/uploads:/app/uploads \
  link-server
```

### Docker Compose (Recommended)

```bash
# Development
docker-compose up -d

# Production with Nginx
docker-compose --profile production up -d
```

### Docker Compose Configuration

The `docker-compose.yml` includes:
- **App Container:** Node.js application
- **Nginx Container:** Reverse proxy with SSL termination
- **Volume Mounts:** Persistent storage for uploads
- **Health Checks:** Automatic container monitoring

## 🖥️ VPS Deployment

### Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2

# Install Nginx (optional)
sudo apt install nginx -y
```

### Application Setup

```bash
# Clone repository
git clone <your-repo-url>
cd link-server

# Install dependencies
npm ci --only=production

# Copy and configure environment
cp env.example .env
nano .env  # Edit configuration

# Create uploads directory
mkdir -p uploads
chmod 755 uploads

# Test the application
npm run prod
```

### PM2 Process Management

```bash
# Start with PM2
pm2 start server.js --name "link-server" --env production

# Save PM2 configuration
pm2 save

# Setup auto-start on boot
pm2 startup
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp $HOME

# Monitor
pm2 status
pm2 logs link-server
pm2 monit
```

### Nginx Configuration (Optional)

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/link-server
```

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/link-server /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### SSL with Certbot

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔧 Environment Variables

### Required Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `NODE_ENV` | Environment mode | `development` | `production` |
| `HOST` | Server host | `localhost` | `0.0.0.0` |
| `PORT` | Server port | `3000` | `80` |

### Update Management

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `MAX_FILE_SIZE` | Max upload size (bytes) | `104857600` | `104857600` |
| `RATE_LIMIT_MAX` | Requests per window | `100` | `50` |
| `RATE_LIMIT_WINDOW` | Rate limit window (ms) | `900000` | `900000` |
| `REQUIRE_DEVICE_REGISTRATION` | Require device registration | `false` | `true` |
| `ENABLE_ANALYTICS` | Enable analytics tracking | `true` | `true` |

### App Store Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `IOS_APP_STORE_URL` | iOS App Store URL | `https://apps.apple.com/app/id123456789` |
| `ANDROID_PLAY_STORE_URL` | Android Play Store URL | `https://play.google.com/store/apps/details?id=com.yourapp` |
| `IOS_APP_STORE_ID` | iOS App Store ID | `123456789` |

### Security Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `CORS_ORIGINS` | Allowed CORS origins | `https://yourdomain.com,https://api.yourdomain.com` |
| `TRUSTED_PROXIES` | Trusted proxy networks | `10.0.0.0/8,172.16.0.0/12` |

## 🔒 Production Configuration

### Security Checklist

- ✅ **Environment Variables:** Set all required environment variables
- ✅ **CORS Origins:** Restrict to your domains only
- ✅ **Rate Limiting:** Enable stricter rate limits
- ✅ **Device Registration:** Require device registration
- ✅ **HTTPS:** Use SSL/TLS certificates
- ✅ **Firewall:** Configure firewall rules
- ✅ **Updates:** Keep dependencies updated

### Performance Optimization

```bash
# PM2 Cluster Mode (VPS)
pm2 start server.js --name "link-server" -i max --env production

# Memory monitoring
pm2 install pm2-server-monit
```

### File Upload Limits

```javascript
// Nginx configuration
client_max_body_size 100M;

// Express configuration (already set)
app.use(express.json({ limit: '10mb' }));
```

## 📊 Monitoring & Health Checks

### Health Check Endpoint

```bash
# Check application health
curl http://your-domain.com/health

# Expected response
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600,
  "environment": "production",
  "version": "1.0.0"
}
```

### Monitoring Commands

```bash
# PM2 monitoring
pm2 status
pm2 logs link-server --lines 100
pm2 monit

# Docker monitoring
docker stats link-server
docker logs link-server --tail 100

# System monitoring
htop
df -h
free -h
```

### Log Management

```bash
# PM2 log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

# Docker log limits
docker run --log-opt max-size=10m --log-opt max-file=3 ...
```

## 🚨 Troubleshooting

### Common Issues

1. **Port Already in Use:**
   ```bash
   sudo lsof -i :80
   sudo kill -9 <PID>
   ```

2. **Permission Denied (Port 80):**
   ```bash
   # Use port 3000 and proxy with Nginx
   # Or run with sudo (not recommended)
   ```

3. **File Upload Fails:**
   ```bash
   # Check disk space
   df -h
   
   # Check permissions
   ls -la uploads/
   chmod 755 uploads/
   ```

4. **High Memory Usage:**
   ```bash
   # Monitor with PM2
   pm2 monit
   
   # Restart if needed
   pm2 restart link-server
   ```

### Debug Mode

```bash
# Enable debug logging
DEBUG=* npm start

# PM2 with debug
pm2 start server.js --name "link-server-debug" --env development
```

## 📞 Support

For deployment issues:
1. Check the [health endpoint](#health-check-endpoint)
2. Review application logs
3. Verify environment variables
4. Check firewall and network settings

## 🔄 Updates

### Application Updates

```bash
# Pull latest code
git pull origin main

# Install dependencies
npm ci --only=production

# Restart application
pm2 restart link-server

# Or with Docker
docker-compose pull && docker-compose up -d
```

### Zero-Downtime Updates (PM2)

```bash
# Reload without downtime
pm2 reload link-server

# Or graceful restart
pm2 gracefulReload link-server
```
