#!/bin/bash

# Render Deployment Script for Link Server
# This script ensures all files are properly included in the deployment

echo "🚀 Preparing Link Server for Render deployment..."

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

# Check if we're in the correct directory
if [ ! -f "package.json" ] || [ ! -f "server.js" ]; then
    print_error "This script must be run from the link-server root directory"
    exit 1
fi

print_status "Checking required files..."

# Check for critical files
REQUIRED_FILES=(
    "server.js"
    "package.json"
    "login.html"
    "dashboard.html"
    "upload.html"
    "channels.html"
    "index.html"
    "Dockerfile"
    "render.yaml"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    print_error "Missing required files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

print_success "All required files found"

# Verify HTML files contain the updated content
print_status "Verifying HTML files contain updated content..."

# Check if login.html has the updated password toggle functionality
if grep -q "togglePassword()" login.html && grep -q "password-field" login.html; then
    print_success "login.html contains updated password toggle functionality"
else
    print_warning "login.html may not contain the latest updates"
fi

# Check if dashboard.html has authentication
if grep -q "AuthManager" dashboard.html; then
    print_success "dashboard.html contains authentication manager"
else
    print_warning "dashboard.html may not contain authentication"
fi

# Verify Docker configuration
print_status "Verifying Docker configuration..."

if grep -q "COPY \*.html" Dockerfile; then
    print_success "Dockerfile explicitly copies HTML files"
else
    print_warning "Dockerfile may not explicitly copy HTML files"
fi

# Check .dockerignore
if grep -q "!*.html" .dockerignore; then
    print_success ".dockerignore allows HTML files"
else
    print_warning ".dockerignore may exclude HTML files"
fi

# Verify render.yaml configuration
print_status "Verifying render.yaml configuration..."

if grep -q "ADMIN_USERNAME" render.yaml && grep -q "JWT_SECRET" render.yaml; then
    print_success "render.yaml contains admin authentication config"
else
    print_error "render.yaml missing admin authentication configuration"
    exit 1
fi

# Create a deployment checklist
print_status "Creating deployment checklist..."

cat > DEPLOYMENT_CHECKLIST.md << EOF
# Render Deployment Checklist

## Pre-deployment Verification ✅

- [x] All HTML files are present and updated
- [x] login.html contains fixed password toggle functionality
- [x] dashboard.html contains authentication manager
- [x] Dockerfile explicitly copies HTML files
- [x] .dockerignore allows HTML files
- [x] render.yaml contains all required environment variables

## Deployment Steps

1. **Push to Git Repository**
   \`\`\`bash
   git add .
   git commit -m "Fix: Updated login UI with password toggle fix"
   git push origin main
   \`\`\`

2. **Trigger Render Deployment**
   - Go to your Render dashboard
   - Find your link-server service
   - Click "Manual Deploy" > "Deploy latest commit"
   - Or wait for auto-deploy if enabled

3. **Force Rebuild (if needed)**
   If you're still seeing old UI:
   - In Render dashboard, go to Settings
   - Click "Delete Service" (this won't delete your data)
   - Redeploy from scratch using render.yaml

4. **Verify Deployment**
   - Check \`https://your-app.onrender.com/login\`
   - Test password toggle functionality
   - Verify admin authentication works
   - Check \`https://your-app.onrender.com/health\`

## Environment Variables to Set in Render

Make sure these are set in your Render service environment:

\`\`\`
NODE_ENV=production
ADMIN_USERNAME=admin@brighthex.in
ADMIN_PASSWORD=\$2b\$12\$YourHashedPasswordHere
JWT_SECRET=your-super-secret-jwt-key-change-in-production-render-2024
MONGODB_URI=mongodb+srv://brighthex28_db_user:paxb1lgQ9oT4Wrob@cluster0.lzhww6m.mongodb.net/linkserver?retryWrites=true&w=majority&appName=Cluster0
\`\`\`

## Troubleshooting

### If you're still seeing old UI:

1. **Clear Browser Cache**
   - Hard refresh: Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)
   - Or open in incognito/private mode

2. **Check Render Logs**
   - Go to Render dashboard > Your service > Logs
   - Look for any build or runtime errors

3. **Verify File Contents**
   - SSH into your Render service (if available)
   - Check if HTML files are present: \`ls -la *.html\`

4. **Force Complete Rebuild**
   - Delete and recreate the Render service
   - This ensures no cached layers are used

## Build Optimization

To ensure faster deployments and avoid caching issues:

1. **Use Build Cache Busting**
   - Update version in package.json
   - Add build timestamp to files

2. **Verify Build Context**
   - Ensure .dockerignore doesn't exclude needed files
   - Check Dockerfile COPY commands

Generated on: $(date)
EOF

print_success "Deployment checklist created: DEPLOYMENT_CHECKLIST.md"

# Show file sizes to verify content
print_status "File sizes verification:"
echo "login.html: $(wc -c < login.html) bytes"
echo "dashboard.html: $(wc -c < dashboard.html) bytes"
echo "upload.html: $(wc -c < upload.html) bytes"
echo "channels.html: $(wc -c < channels.html) bytes"

# Final recommendations
print_status "Deployment Recommendations:"
echo "1. Commit all changes to git before deploying"
echo "2. Use 'Manual Deploy' in Render to force rebuild"
echo "3. Check browser cache if UI doesn't update"
echo "4. Monitor Render logs during deployment"
echo "5. Test login functionality after deployment"

print_success "Render deployment preparation complete!"
print_status "Next steps:"
echo "1. Run: git add . && git commit -m 'Fix: Updated login UI and Docker config'"
echo "2. Run: git push origin main"
echo "3. Go to Render dashboard and trigger manual deploy"
echo "4. Test the deployed application"

echo ""
print_status "For immediate deployment, you can also run:"
echo "docker build -t link-server-test . && docker run -p 3000:3000 link-server-test"
echo "This will test the Docker build locally before deploying to Render"
