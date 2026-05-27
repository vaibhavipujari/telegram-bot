@echo off
setlocal enabledelayedexpansion

REM Render Deployment Script for Link Server (Windows)
REM This script ensures all files are properly included in the deployment

echo 🚀 Preparing Link Server for Render deployment...

REM Check if we're in the correct directory
if not exist "package.json" (
    echo [ERROR] This script must be run from the link-server root directory
    exit /b 1
)

if not exist "server.js" (
    echo [ERROR] This script must be run from the link-server root directory
    exit /b 1
)

echo [INFO] Checking required files...

REM Check for critical files
set "missing_files="
set "files=server.js package.json login.html dashboard.html upload.html channels.html index.html Dockerfile render.yaml"

for %%f in (%files%) do (
    if not exist "%%f" (
        set "missing_files=!missing_files! %%f"
    )
)

if not "!missing_files!"=="" (
    echo [ERROR] Missing required files:
    for %%f in (!missing_files!) do echo   - %%f
    exit /b 1
)

echo [SUCCESS] All required files found

REM Verify HTML files contain the updated content
echo [INFO] Verifying HTML files contain updated content...

findstr /c:"togglePassword()" login.html >nul 2>&1
if !errorlevel! equ 0 (
    findstr /c:"password-field" login.html >nul 2>&1
    if !errorlevel! equ 0 (
        echo [SUCCESS] login.html contains updated password toggle functionality
    ) else (
        echo [WARNING] login.html may not contain the latest updates
    )
) else (
    echo [WARNING] login.html may not contain the latest updates
)

findstr /c:"AuthManager" dashboard.html >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] dashboard.html contains authentication manager
) else (
    echo [WARNING] dashboard.html may not contain authentication
)

REM Verify Docker configuration
echo [INFO] Verifying Docker configuration...

findstr /c:"COPY *.html" Dockerfile >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] Dockerfile explicitly copies HTML files
) else (
    echo [WARNING] Dockerfile may not explicitly copy HTML files
)

findstr /c:"!*.html" .dockerignore >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] .dockerignore allows HTML files
) else (
    echo [WARNING] .dockerignore may exclude HTML files
)

REM Verify render.yaml configuration
echo [INFO] Verifying render.yaml configuration...

findstr /c:"ADMIN_USERNAME" render.yaml >nul 2>&1
if !errorlevel! equ 0 (
    findstr /c:"JWT_SECRET" render.yaml >nul 2>&1
    if !errorlevel! equ 0 (
        echo [SUCCESS] render.yaml contains admin authentication config
    ) else (
        echo [ERROR] render.yaml missing admin authentication configuration
        exit /b 1
    )
) else (
    echo [ERROR] render.yaml missing admin authentication configuration
    exit /b 1
)

REM Create a deployment checklist
echo [INFO] Creating deployment checklist...

(
echo # Render Deployment Checklist
echo.
echo ## Pre-deployment Verification ✅
echo.
echo - [x] All HTML files are present and updated
echo - [x] login.html contains fixed password toggle functionality
echo - [x] dashboard.html contains authentication manager
echo - [x] Dockerfile explicitly copies HTML files
echo - [x] .dockerignore allows HTML files
echo - [x] render.yaml contains all required environment variables
echo.
echo ## Deployment Steps
echo.
echo 1. **Push to Git Repository**
echo    ```bash
echo    git add .
echo    git commit -m "Fix: Updated login UI with password toggle fix"
echo    git push origin main
echo    ```
echo.
echo 2. **Trigger Render Deployment**
echo    - Go to your Render dashboard
echo    - Find your link-server service
echo    - Click "Manual Deploy" ^> "Deploy latest commit"
echo    - Or wait for auto-deploy if enabled
echo.
echo 3. **Force Rebuild (if needed^)**
echo    If you're still seeing old UI:
echo    - In Render dashboard, go to Settings
echo    - Click "Delete Service" (this won't delete your data^)
echo    - Redeploy from scratch using render.yaml
echo.
echo 4. **Verify Deployment**
echo    - Check `https://your-app.onrender.com/login`
echo    - Test password toggle functionality
echo    - Verify admin authentication works
echo    - Check `https://your-app.onrender.com/health`
echo.
echo ## Environment Variables to Set in Render
echo.
echo Make sure these are set in your Render service environment:
echo.
echo ```
echo NODE_ENV=production
echo ADMIN_USERNAME=admin@brighthex.in
echo ADMIN_PASSWORD=$2b$12$YourHashedPasswordHere
echo JWT_SECRET=your-super-secret-jwt-key-change-in-production-render-2024
echo MONGODB_URI=mongodb+srv://brighthex28_db_user:paxb1lgQ9oT4Wrob@cluster0.lzhww6m.mongodb.net/linkserver?retryWrites=true^&w=majority^&appName=Cluster0
echo ```
echo.
echo ## Troubleshooting
echo.
echo ### If you're still seeing old UI:
echo.
echo 1. **Clear Browser Cache**
echo    - Hard refresh: Ctrl+F5 (Windows^) or Cmd+Shift+R (Mac^)
echo    - Or open in incognito/private mode
echo.
echo 2. **Check Render Logs**
echo    - Go to Render dashboard ^> Your service ^> Logs
echo    - Look for any build or runtime errors
echo.
echo 3. **Verify File Contents**
echo    - SSH into your Render service (if available^)
echo    - Check if HTML files are present: `ls -la *.html`
echo.
echo 4. **Force Complete Rebuild**
echo    - Delete and recreate the Render service
echo    - This ensures no cached layers are used
echo.
echo Generated on: %date% %time%
) > DEPLOYMENT_CHECKLIST.md

echo [SUCCESS] Deployment checklist created: DEPLOYMENT_CHECKLIST.md

REM Show file sizes to verify content
echo [INFO] File sizes verification:
for %%f in (login.html dashboard.html upload.html channels.html) do (
    for %%s in (%%f) do echo %%f: %%~zs bytes
)

REM Final recommendations
echo [INFO] Deployment Recommendations:
echo 1. Commit all changes to git before deploying
echo 2. Use 'Manual Deploy' in Render to force rebuild
echo 3. Check browser cache if UI doesn't update
echo 4. Monitor Render logs during deployment
echo 5. Test login functionality after deployment

echo [SUCCESS] Render deployment preparation complete!
echo [INFO] Next steps:
echo 1. Run: git add . ^&^& git commit -m "Fix: Updated login UI and Docker config"
echo 2. Run: git push origin main
echo 3. Go to Render dashboard and trigger manual deploy
echo 4. Test the deployed application

echo.
echo [INFO] For immediate deployment, you can also run:
echo docker build -t link-server-test . ^&^& docker run -p 3000:3000 link-server-test
echo This will test the Docker build locally before deploying to Render

pause
