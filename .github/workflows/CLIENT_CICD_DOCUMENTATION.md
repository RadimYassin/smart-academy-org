# Client Applications CI/CD Documentation

## Overview

Smart Academy now has comprehensive CI/CD pipelines for both client applications:

1. **Flutter Mobile CI/CD** ([flutter-ci.yml](file:///d:/smart-academy-org/.github/workflows/flutter-ci.yml))
2. **Microfrontends CI/CD** ([microfrontends-ci.yml](file:///d:/smart-academy-org/.github/workflows/microfrontends-ci.yml))

---

## 📱 Flutter Mobile CI/CD

### Workflow File
[`.github/workflows/flutter-ci.yml`](file:///d:/smart-academy-org/.github/workflows/flutter-ci.yml)

### Triggers
- Push to `main`/`master` (only when `clients/mobile/**` changes)
- Pull requests to `main`/`master` (only when `clients/mobile/**` changes)
- Manual workflow dispatch

### Pipeline Stages

#### 1. **Analyze & Test**
- Runs `flutter analyze` for static code analysis
- Executes unit tests with `flutter test --coverage`
- Uploads coverage reports as artifacts

#### 2. **Build Android**
- Builds debug APK
- Builds release App Bundle (AAB)
- Uploads APK and AAB as artifacts

#### 3. **Build Web**
- Builds Progressive Web App
- Creates optimized production bundle
- Uploads web build as artifact

#### 4. **Build Windows** (Optional)
- Runs only on `main` branch or manual dispatch
- Builds Windows desktop application
- Uploads Windows executable as artifact

#### 5. **Build Linux** (Optional)
- Runs only on `main` branch or manual dispatch
- Builds Linux desktop application
- Uploads Linux bundle as artifact

### Artifacts Generated
- `coverage-report` - Test coverage data
- `android-apk` - Android debug APK
- `android-bundle` - Android release AAB
- `web-build` - Web application files
- `windows-build` - Windows executable (conditional)
- `linux-build` - Linux bundle (conditional)

### Required Setup
None - workflow uses only public runners and Flutter tooling.

### Optional Setup (for signed Android builds)
Add these secrets to GitHub repository:
- `ANDROID_KEYSTORE_BASE64` - Base64 encoded keystore
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password

---

## 🎨 Microfrontends CI/CD

### Workflow File
[`.github/workflows/microfrontends-ci.yml`](file:///d:/smart-academy-org/.github/workflows/microfrontends-ci.yml)

### Triggers
- Push to `main`/`master` (only when `clients/microfrontends/**` changes)
- Pull requests to `main`/`master` (only when `clients/microfrontends/**` changes)
- Manual workflow dispatch

### Pipeline Stages

#### 1. **Build & Test** (Matrix strategy)
Runs in parallel for all 4 microfrontends:
- **shell** (port 5001)
- **auth** (port 5002)
- **dashboard** (port 5003)
- **courses** (port 5004)

**Steps per microfrontend:**
- Install dependencies with `npm ci`
- Run ESLint for code quality
- Build production bundle with `npm run build`
- Upload build artifacts

#### 2. **Build Docker Images** (Matrix strategy)
For each microfrontend:
- Uses production Dockerfile (`Dockerfile.prod`)
- Multi-stage build (build + nginx)
- Tags: `latest` and `git-sha`
- Leverages GitHub Actions cache
- Saves images as artifacts for security scanning

#### 3. **Trivy Security Scan** (Matrix strategy)
For each Docker image:
- Scans for vulnerabilities (CRITICAL, HIGH, MEDIUM, LOW)
- Uploads SARIF to GitHub Security tab
- Generates human-readable reports
- Uploads reports as artifacts

#### 4. **Publish to Docker Hub** (Matrix strategy)
Only on `main` or `master` branch:
- Loads Docker images from artifacts
- Tags with `latest` and commit SHA
- Pushes to Docker Hub
- Uses existing secrets

### Artifacts Generated

**Per microfrontend:**
- `build-{name}` - Production bundle (dist folder)
- `docker-image-{name}` - Docker image tar file (temporary)
- `trivy-report-{name}` - Security scan report

### Required Secrets
These secrets should already exist (from servers CI/CD):
- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token

---

## 🐳 Production Dockerfiles

Each microfrontend now has a production-optimized Dockerfile:

### Location
- `clients/microfrontends/shell/Dockerfile.prod`
- `clients/microfrontends/auth/Dockerfile.prod`
- `clients/microfrontends/dashboard/Dockerfile.prod`
- `clients/microfrontends/courses/Dockerfile.prod`

### Multi-Stage Build

**Stage 1: Builder**
```dockerfile
FROM node:18-alpine AS builder
# Install dependencies with npm ci
# Build production bundle with npm run build
```

**Stage 2: Production**
```dockerfile
FROM nginx:alpine
# Copy nginx configuration
# Copy built files from builder
# Expose port 80
# Health check endpoint
```

### Benefits
- ✅ Smaller image size (only production files, no build tools)
- ✅ Nginx for optimal performance
- ✅ Gzip compression enabled
- ✅ Security headers configured
- ✅ SPA routing support
- ✅ Health check endpoint at `/health`
- ✅ Static asset caching (1 year for immutable files)

---

## 🚀 How to Use

### Testing Workflows Locally

#### Build Flutter Mobile
```bash
cd d:\smart-academy-org\clients\mobile

# Run tests
flutter test

# Analyze code
flutter analyze

# Build Android APK
flutter build apk --debug

# Build Web
flutter build web
```

#### Build Microfrontends
```bash
# Build shell
cd d:\smart-academy-org\clients\microfrontends\shell
npm install
npm run build

# Build auth
cd d:\smart-academy-org\clients\microfrontends\auth
npm install
npm run build

# Test production Docker build
docker build -t smart-academy-shell:test -f Dockerfile.prod .
docker run -p 8080:80 smart-academy-shell:test
# Open http://localhost:8080
```

### Triggering Workflows

#### Automatic Trigger
Make changes to client code and push:
```bash
# Make a change in mobile
echo "// test" >> clients/mobile/lib/main.dart
git add clients/mobile/
git commit -m "feat: Update mobile app"
git push
# ✅ Flutter CI workflow triggers

# Make a change in microfrontends
echo "// test" >> clients/microfrontends/shell/src/main.tsx
git add clients/microfrontends/
git commit -m "feat: Update shell"
git push
# ✅ Microfrontends CI workflow triggers
```

#### Manual Trigger
1. Go to GitHub → Actions tab
2. Select workflow (Flutter CI or Microfrontends CI)
3. Click "Run workflow"
4. Choose branch
5. Click "Run workflow" button

### Downloading Artifacts

1. Go to GitHub Actions
2. Click on a completed workflow run
3. Scroll to "Artifacts" section
4. Download desired artifacts (APK, web build, Docker images, etc.)

### Deploying Docker Images

After successful push to `main`, images are available on Docker Hub:

```bash
# Pull images
docker pull <your-dockerhub-username>/smart-academy-shell:latest
docker pull <your-dockerhub-username>/smart-academy-auth:latest
docker pull <your-dockerhub-username>/smart-academy-dashboard:latest
docker pull <your-dockerhub-username>/smart-academy-courses:latest

# Run locally
docker run -d -p 5001:80 <username>/smart-academy-shell:latest
docker run -d -p 5002:80 <username>/smart-academy-auth:latest
docker run -d -p 5003:80 <username>/smart-academy-dashboard:latest
docker run -d -p 5004:80 <username>/smart-academy-courses:latest
```

---

## 📊 Workflow Status

### View Workflow Runs
- GitHub → Actions tab
- Filter by workflow name
- View details, logs, and artifacts

### Workflow Badges
Add to your README.md:

```markdown
![Flutter CI](https://github.com/<owner>/<repo>/actions/workflows/flutter-ci.yml/badge.svg)
![Microfrontends CI](https://github.com/<owner>/<repo>/actions/workflows/microfrontends-ci.yml/badge.svg)
```

---

## 🔧 Troubleshooting

### Flutter Workflow Issues

**Issue:** Tests fail
- Check test logs in workflow
- Run locally: `flutter test`
- Fix failing tests and push again

**Issue:** Android build fails
- Ensure `pubspec.yaml` is correct
- Check Gradle configuration in `android/`

### Microfrontends Workflow Issues

**Issue:** Build fails
- Check ESLint errors in logs
- Run locally: `npm run lint` and `npm run build`
- Fix errors and push again

**Issue:** Docker build fails
- Ensure `Dockerfile.prod` exists
- Test locally: `docker build -f Dockerfile.prod .`

**Issue:** Docker Hub push fails (403)
- Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
- Check Docker Hub token has push permissions

---

## 🎯 Next Steps

### Flutter Mobile
- [ ] Add iOS build (requires macOS runner - paid)
- [ ] Integrate with App Store Connect for automatic deployment
- [ ] Add automated Play Store deployment with Fastlane
- [ ] Add automated versioning

### Web Microfrontends
- [ ] Add automated deployment to hosting (Vercel, Netlify, AWS)
- [ ] Add Lighthouse CI for performance monitoring
- [ ] Add visual regression testing (Percy, Chromatic)
- [ ] Add E2E tests (Playwright, Cypress)

### Both
- [ ] Add Slack/Discord notifications on failures
- [ ] Add PR preview deployments
- [ ] Add semantic versioning automation
- [ ] Add changelog generation

---

## 📚 Related Documentation

- [DevSecOps Pipeline (Servers)](file:///d:/smart-academy-org/.github/workflows/devsecops.yml)
- [Pipeline Documentation](file:///d:/smart-academy-org/.github/workflows/PIPELINE_DOCUMENTATION.md)
- [Secrets Setup Guide](file:///d:/smart-academy-org/.github/workflows/SECRETS_SETUP_GUIDE.md)
- [Implementation Plan](file:///C:/Users/ROG/.gemini/antigravity/brain/1854feb9-9ff8-4d32-9993-a120f8365f85/implementation_plan.md)
