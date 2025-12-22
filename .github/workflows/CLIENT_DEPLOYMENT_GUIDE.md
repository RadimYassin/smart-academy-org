# Quick Start: Client CI/CD Deployment

## 📋 Overview

This guide shows you how to deploy the Smart Academy client applications using the new CI/CD pipelines.

---

## 🚀 Quick Deploy - Microfrontends (Web)

### Prerequisites
- Docker installed locally
- Access to Docker Hub (or other registry)
- GitHub secrets configured:
  - `DOCKERHUB_USERNAME`
  - `DOCKERHUB_TOKEN`

### One-Command Deploy

```bash
# 1. Push to main branch (triggers automatic CI/CD)
git checkout main
git pull
git push

# 2. Wait for GitHub Actions to complete (~5-10 minutes)
# Check: https://github.com/<owner>/<repo>/actions

# 3. Images are automatically pushed to Docker Hub

# 4. Deploy using docker-compose
cd d:\smart-academy-org\clients\microfrontends
docker-compose -f docker-compose.prod.yml up -d
```

### Production docker-compose.yml

Create `clients/microfrontends/docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  shell:
    image: ${DOCKERHUB_USERNAME}/smart-academy-shell:latest
    ports:
      - "5001:80"
    restart: unless-stopped
    networks:
      - microfrontend-network

  auth:
    image: ${DOCKERHUB_USERNAME}/smart-academy-auth:latest
    ports:
      - "5002:80"
    restart: unless-stopped
    networks:
      - microfrontend-network

  dashboard:
    image: ${DOCKERHUB_USERNAME}/smart-academy-dashboard:latest
    ports:
      - "5003:80"
    restart: unless-stopped
    networks:
      - microfrontend-network

  courses:
    image: ${DOCKERHUB_USERNAME}/smart-academy-courses:latest
    ports:
      - "5004:80"
    restart: unless-stopped
    networks:
      - microfrontend-network

networks:
  microfrontend-network:
    driver: bridge
```

**Deploy:**
```bash
export DOCKERHUB_USERNAME=your-username
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

**Access:**
- Shell: http://localhost:5001
- Auth: http://localhost:5002
- Dashboard: http://localhost:5003
- Courses: http://localhost:5004

---

## 📱 Quick Deploy - Flutter Mobile

### Android APK

**Option 1: Download from GitHub Actions**
1. Go to: https://github.com/<owner>/<repo>/actions/workflows/flutter-ci.yml
2. Click latest successful run
3. Download `android-apk` artifact
4. Extract ZIP
5. Install APK on Android device:
   ```bash
   adb install app-debug.apk
   ```

**Option 2: Build Locally**
```bash
cd d:\smart-academy-org\clients\mobile
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### Web App

**Download from GitHub Actions:**
1. Download `web-build` artifact
2. Extract to web server directory
3. Serve with any static server:
   ```bash
   # Using Python
   python -m http.server 8080
   
   # Using Node.js http-server
   npx http-server build/web -p 8080
   
   # Using Nginx (production)
   # Copy to /var/www/html/
   ```

**Or build locally:**
```bash
cd d:\smart-academy-org\clients\mobile
flutter build web --release
# Output: build/web/
```

---

## 🔄 Automatic Deployment Workflow

### Step-by-Step

1. **Make Changes**
   ```bash
   # Mobile changes
   cd d:\smart-academy-org\clients\mobile
   # ... edit code ...
   
   # OR web changes
   cd d:\smart-academy-org\clients\microfrontends\shell
   # ... edit code ...
   ```

2. **Commit & Push**
   ```bash
   git add .
   git commit -m "feat: Your change description"
   git push origin main
   ```

3. **CI/CD Triggers Automatically**
   - GitHub Actions detects path changes
   - Runs appropriate workflow (Flutter or Microfrontends)
   - Builds, tests, and scans
   - Pushes Docker images (for web, on main branch)

4. **Deploy**
   ```bash
   # For web microfrontends
   cd d:\smart-academy-org\clients\microfrontends
   docker-compose -f docker-compose.prod.yml pull
   docker-compose -f docker-compose.prod.yml up -d
   ```

---

## 🌐 Deploy to Cloud Platforms

### Deploy Flutter Web to Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build
cd d:\smart-academy-org\clients\mobile
flutter build web

# Deploy
netlify deploy --dir=build/web --prod
```

### Deploy Flutter Web to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (first time only)
cd d:\smart-academy-org\clients\mobile
firebase init hosting
# Set public directory to: build/web

# Build
flutter build web

# Deploy
firebase deploy --only hosting
```

### Deploy Microfrontends to AWS ECS

1. **Tag images for ECR:**
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
   
   docker tag <dockerhub-user>/smart-academy-shell:latest <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/smart-academy-shell:latest
   docker push <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/smart-academy-shell:latest
   ```

2. **Update ECS service:**
   ```bash
   aws ecs update-service --cluster smart-academy --service shell --force-new-deployment
   ```

---

## ✅ Verification Checklist

### After Deployment

**Web Microfrontends:**
- [ ] All 4 services are running: `docker ps`
- [ ] Shell accessible at port 5001
- [ ] Auth accessible at port 5002
- [ ] Dashboard accessible at port 5003
- [ ] Courses accessible at port 5004
- [ ] Health checks pass: `curl http://localhost:5001/health`
- [ ] No console errors in browser

**Flutter Mobile:**
- [ ] APK installs without errors
- [ ] App launches successfully
- [ ] Login works
- [ ] Navigation functions
- [ ] API calls succeed

**Flutter Web:**
- [ ] Site loads in browser
- [ ] No console errors
- [ ] Responsive on mobile/tablet/desktop
- [ ] Routing works (browser back/forward)

---

## 🐛 Troubleshooting

### Web: Container won't start
```bash
# Check logs
docker logs <container-id>

# Check if port is already in use
netstat -ano | findstr :5001

# Restart container
docker restart <container-id>
```

### Web: 404 errors on routes
- Ensure nginx.conf has `try_files $uri $uri/ /index.html;`
- Rebuild Docker image: `docker build -f Dockerfile.prod -t test .`

### Mobile: APK won't install
- Enable "Install from unknown sources" on Android
- Check minimum SDK version in `android/app/build.gradle`

### Mobile: White screen on launch
- Check console for JavaScript errors
- Verify API endpoints are reachable
- Check CORS configuration on backend

---

## 📞 Support

For issues:
1. Check [CLIENT_CICD_DOCUMENTATION.md](file:///d:/smart-academy-org/.github/workflows/CLIENT_CICD_DOCUMENTATION.md)
2. Review GitHub Actions logs
3. Check Docker container logs: `docker logs <container>`
4. Verify secrets are configured correctly

---

**Last Updated:** 2025-12-22
