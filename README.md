# 📱 Link Server - Telegram APK Download & Update Management

A comprehensive Node.js server for managing APK downloads through Telegram channels with advanced update management APIs. Perfect for distributing mobile app updates with analytics, device tracking, and automated deployment.

## ✨ Features

### 📱 **APK Distribution**
- **Multi-Channel Support** - Manage multiple Telegram channels
- **Unique Download Links** - Generate secure, trackable download URLs
- **Channel Management** - Enable/disable channels, track downloads
- **File Upload** - Web interface for APK uploads with metadata

### 🔄 **Update Management APIs**
- **Version Checking** - Automatic version comparison and update detection
- **OTA Updates** - Over-the-air update support for React Native/Expo apps
- **Store Updates** - App Store and Play Store update management
- **Device Registration** - Track and manage registered devices
- **Analytics Tracking** - Comprehensive update event analytics
- **Push Notifications** - Update notification system

### 🔒 **Security & Performance**
- **Rate Limiting** - Configurable API rate limits
- **Input Sanitization** - XSS prevention and validation
- **Device Validation** - Optional device registration requirements
- **CORS Configuration** - Flexible cross-origin resource sharing
- **Production Ready** - Security headers and proxy support

### 📊 **Analytics & Monitoring**
- **Download Analytics** - Track downloads per channel and device
- **Update Events** - Monitor update installations and failures
- **Device Metrics** - Platform, version, and activity tracking
- **Health Monitoring** - Built-in health check endpoints

## 🚀 Quick Start

### Development Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd link-server

# Install dependencies
npm install

# Copy environment configuration
cp env.example .env

# Start development server
npm run dev
```

Visit `http://localhost:3000` to access the web interface.

### Production Deployment

```bash
# Set production environment
export NODE_ENV=production
export HOST=0.0.0.0
export PORT=80

# Start production server
npm run prod
```

## 🌐 Deployment Options

### 🎯 **Render (Recommended)**
One-click deployment with automatic scaling and SSL.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

See [DEPLOYMENT.md](DEPLOYMENT.md#render-deployment) for detailed instructions.

### 🐳 **Docker**
```bash
# Quick start with Docker Compose
docker-compose up -d

# Production with Nginx
docker-compose --profile production up -d
```

### 🖥️ **VPS/Server**
```bash
# Install PM2 for process management
npm install -g pm2

# Start with PM2
pm2 start server.js --name "link-server" --env production
```

## 📋 API Endpoints

### 🔄 **Update Management APIs**

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/check-version` | Check for app updates |
| `GET` | `/api/updates/:platform` | Get update metadata |
| `GET` | `/api/updates/download/:platform` | Download update file |
| `POST` | `/api/updates/register` | Register device for updates |
| `POST` | `/api/analytics/update` | Track update events |
| `GET` | `/api/analytics/updates` | Get update analytics |
| `POST` | `/api/notifications/update` | Send update notifications |
| `GET` | `/api/devices` | Get registered devices |

### 📱 **Channel Management APIs**

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check endpoint |
| `GET` | `/api/stats` | Get download statistics |
| `GET` | `/api/channels` | Get all channels |
| `POST` | `/api/channels` | Add new channel |
| `PUT` | `/api/channels/:token/toggle` | Toggle channel status |
| `DELETE` | `/api/channels/:token` | Delete channel |
| `POST` | `/upload` | Upload new APK |
| `GET` | `/d/:token` | Download APK with token |

## 🔧 Configuration

### Environment Variables

```bash
# Server Configuration
NODE_ENV=production
HOST=0.0.0.0
PORT=80

# Update Management
MAX_FILE_SIZE=104857600
RATE_LIMIT_MAX=50
REQUIRE_DEVICE_REGISTRATION=true

# App Store URLs
IOS_APP_STORE_URL=https://apps.apple.com/app/id123456789
ANDROID_PLAY_STORE_URL=https://play.google.com/store/apps/details?id=com.yourapp

# Security
CORS_ORIGINS=https://yourdomain.com
```

See [DEPLOYMENT.md](DEPLOYMENT.md#environment-variables) for complete configuration options.

## 📱 UpdateService Integration

This server is designed to work seamlessly with the React Native UpdateService:

```javascript
// UpdateService configuration
const updateService = UpdateService.getInstance();

// Check for updates
const updateInfo = await updateService.checkForUpdates();

// Download and install
if (updateInfo.isAvailable) {
  await updateService.downloadAndInstallUpdate();
}
```

### API Integration Examples

```javascript
// Check version
const response = await fetch('/api/check-version', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    platform: 'android',
    currentVersion: '1.0.0',
    bundleId: 'com.yourapp',
    deviceId: 'unique-device-id'
  })
});

// Register device
await fetch('/api/updates/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    deviceId: 'unique-device-id',
    platform: 'android',
    appVersion: '1.0.0',
    osVersion: '13',
    deviceModel: 'Pixel 7'
  })
});
```

## 📊 Analytics & Monitoring

### Health Check
```bash
curl http://your-domain.com/health
```

### Analytics Dashboard
Access comprehensive analytics through the web interface or API:
- Download statistics per channel
- Update event tracking
- Device registration metrics
- Platform distribution

## 🔒 Security Features

- **Rate Limiting** - Prevent API abuse
- **Input Sanitization** - XSS and injection prevention
- **CORS Protection** - Configurable origin restrictions
- **Security Headers** - Production-ready security headers
- **Device Validation** - Optional device registration
- **File Validation** - APK file type and size limits

## 🛠️ Development

### Project Structure
```
link-server/
├── server.js              # Main application file
├── package.json           # Dependencies and scripts
├── render.yaml           # Render deployment config
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Docker Compose setup
├── nginx.conf            # Nginx configuration
├── env.example           # Environment variables template
├── DEPLOYMENT.md         # Deployment guide
└── uploads/              # APK file storage
```

### Development Scripts
```bash
npm run dev          # Start development server with nodemon
npm run prod         # Start production server
npm run docker:build # Build Docker image
npm run docker:run   # Run Docker container
```

## 📖 Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide
- **[API Documentation](#api-endpoints)** - API reference
- **[Configuration Guide](#configuration)** - Environment setup

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/link-server/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/link-server/discussions)
- **Documentation:** [DEPLOYMENT.md](DEPLOYMENT.md)

## 🎯 Use Cases

- **Mobile App Distribution** - Distribute APKs through Telegram
- **Beta Testing** - Manage beta app distributions
- **Enterprise Apps** - Internal app distribution system
- **Update Management** - Automated app update system
- **Analytics Platform** - Track app downloads and updates

---

**Made with ❤️ for the mobile development community**
#   a p k - l i n k - s e r v e r  
 "# Telegram-mangment-system" 
"# telegram-bot" 
