# 🐳 Docker Installation Guide

This guide will help you install Docker on your system to run the Link Server application.

## 🖥️ Windows Installation

### Step 1: System Requirements
- **Windows 10/11** (64-bit) Pro, Enterprise, or Education
- **WSL 2** (Windows Subsystem for Linux 2)
- **Hyper-V** support
- At least **4GB RAM**

### Step 2: Install Docker Desktop

#### Method 1: Download from Docker Website (Recommended)
1. Go to [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)
2. Click **"Download Docker Desktop for Windows"**
3. Run the installer (`Docker Desktop Installer.exe`)
4. Follow the installation wizard
5. **Enable WSL 2** when prompted
6. Restart your computer when installation completes

#### Method 2: Using Winget (Windows Package Manager)
```powershell
# Install using Windows Package Manager
winget install Docker.DockerDesktop
```

#### Method 3: Using Chocolatey
```powershell
# Install Chocolatey first (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Docker Desktop
choco install docker-desktop
```

### Step 3: Configure Docker Desktop
1. **Start Docker Desktop** from the Start menu
2. **Accept the license agreement**
3. **Sign in** to Docker Hub (optional but recommended)
4. **Configure settings**:
   - **Resources → Memory**: Allocate at least 4GB
   - **Resources → Disk**: Ensure sufficient disk space
   - **General → Use WSL 2**: Enable this option

### Step 4: Verify Installation
```powershell
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Test Docker installation
docker run hello-world
```

## 🐧 Linux Installation

### Ubuntu/Debian
```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker compose version
```

### CentOS/RHEL/Fedora
```bash
# Install required packages
sudo yum install -y yum-utils

# Add Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker compose version
```

## 🍎 macOS Installation

### Step 1: System Requirements
- **macOS 10.15** or newer
- At least **4GB RAM**
- **VirtualBox** prior to version 4.3.30 must be uninstalled

### Step 2: Install Docker Desktop

#### Method 1: Download from Docker Website
1. Go to [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/)
2. Download the appropriate version:
   - **Intel Chip**: Docker Desktop for Mac with Intel chip
   - **Apple Silicon**: Docker Desktop for Mac with Apple chip
3. Open the `.dmg` file and drag Docker to Applications
4. Launch Docker from Applications folder

#### Method 2: Using Homebrew
```bash
# Install using Homebrew
brew install --cask docker

# Or using Homebrew Cask
brew cask install docker
```

### Step 3: Verify Installation
```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Test Docker installation
docker run hello-world
```

## 🔧 Post-Installation Setup

### Configure Docker Resources

#### Windows/Mac (Docker Desktop)
1. **Open Docker Desktop**
2. **Go to Settings** (gear icon)
3. **Resources**:
   - **Memory**: Allocate 4-8GB for Link Server
   - **CPU**: Allocate 2-4 cores
   - **Disk**: Ensure 10GB+ available space
4. **Apply & Restart**

#### Linux
```bash
# Check Docker system info
docker system info

# Configure Docker daemon (optional)
sudo nano /etc/docker/daemon.json
```

Example `daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

### Enable Docker Compose V2 (if needed)
```bash
# Linux: Install Docker Compose V2
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

## ✅ Verification Checklist

Run these commands to verify your Docker installation:

```bash
# 1. Check Docker version
docker --version
# Expected: Docker version 20.10.x or newer

# 2. Check Docker Compose version
docker-compose --version
# Expected: Docker Compose version 2.x.x or newer

# 3. Check Docker system info
docker system info
# Should show running Docker daemon

# 4. Test Docker functionality
docker run hello-world
# Should download and run hello-world container

# 5. Test Docker Compose
docker-compose --help
# Should show Docker Compose help

# 6. Check available disk space
docker system df
# Should show Docker disk usage
```

## 🚨 Troubleshooting

### Common Issues

#### Windows Issues

**1. WSL 2 Installation Required**
```powershell
# Enable WSL 2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart computer, then set WSL 2 as default
wsl --set-default-version 2
```

**2. Hyper-V Not Enabled**
```powershell
# Enable Hyper-V (requires restart)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

**3. Docker Desktop Won't Start**
- Check Windows version compatibility
- Ensure virtualization is enabled in BIOS
- Try running as administrator
- Check Windows Event Logs

#### Linux Issues

**1. Permission Denied**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker
```

**2. Docker Daemon Not Running**
```bash
# Start Docker service
sudo systemctl start docker

# Enable auto-start
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

**3. Storage Issues**
```bash
# Clean up Docker resources
docker system prune -f

# Check disk usage
docker system df

# Remove unused images
docker image prune -f
```

#### macOS Issues

**1. Docker Desktop Won't Start**
- Check macOS version compatibility
- Ensure sufficient disk space
- Try resetting Docker Desktop to factory defaults
- Check Activity Monitor for conflicting processes

**2. Performance Issues**
- Allocate more resources in Docker Desktop settings
- Enable file sharing for project directories
- Use Docker Desktop's built-in Kubernetes (if needed)

## 🎯 Next Steps

After successful Docker installation:

1. **Clone the Link Server repository**:
   ```bash
   git clone <repository-url>
   cd link-server
   ```

2. **Run the Docker setup**:
   ```bash
   # Linux/Mac
   ./docker-setup.sh

   # Windows
   docker-setup.bat
   ```

3. **Follow the [Docker Setup Guide](DOCKER_SETUP.md)** for application-specific configuration

## 📚 Additional Resources

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)

## 🆘 Getting Help

If you encounter issues:

1. **Check Docker Documentation**: [docs.docker.com](https://docs.docker.com/)
2. **Docker Community Forums**: [forums.docker.com](https://forums.docker.com/)
3. **Stack Overflow**: Search for Docker-related questions
4. **GitHub Issues**: Check the Link Server repository issues

---

**Important**: Make sure to restart your computer after installing Docker Desktop on Windows to ensure all components are properly initialized.
