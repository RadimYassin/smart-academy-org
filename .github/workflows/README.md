# DevSecOps Pipeline - Quick Start Guide

## 🚀 5-Minute Setup

Follow these steps to activate the DevSecOps CI/CD pipeline for your Smart Academy Platform.

---

## Prerequisites

- ✅ GitHub account with repository access
- ✅ Docker Hub account (create free at https://hub.docker.com)
- ✅ SonarCloud account (create free at https://sonarcloud.io)

---

## Step 1: Configure SonarCloud (3 minutes)

### 1.1 Create Account
1. Go to https://sonarcloud.io
2. Click "Log in" → Choose "GitHub"
3. Authorize SonarCloud

### 1.2 Create Organization
1. Click **+** → "Create new organization"
2. Choose "Import from GitHub"
3. Select your GitHub account
4. Enter organization key (e.g., `smart-academy-org`)
5. Choose "Free plan"

### 1.3 Generate Token
1. Profile icon → "My Account" → "Security"
2. Generate token name: `GitHub Actions`
3. **Copy the token** (save for Step 3)

### 1.4 Update Workflow
1. Open `.github/workflows/devsecops.yml`
2. Find (appears twice): `-Dsonar.organization=YOUR_SONARCLOUD_ORG`
3. Replace with your org key: `-Dsonar.organization=smart-academy-org`
4. Save and commit

---

## Step 2: Configure Docker Hub (2 minutes)

### 2.1 Create Access Token
1. Log in to https://hub.docker.com
2. Username (top-right) → "Account Settings" → "Security"
3. Click "New Access Token"
4. Description: `GitHub Actions`
5. Permissions: **Read, Write, Delete**
6. Click "Generate"
7. **Copy the token** (save for Step 3)

---

## Step 3: Add GitHub Secrets (2 minutes)

1. Go to your GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"** and add:

| Name | Value |
|------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Token from Step 2.1 |
| `SONAR_TOKEN` | Token from Step 1.3 |

---

## Step 4: Trigger Pipeline

### Option A: Push to Main
```bash
git add .
git commit -m "feat: enable DevSecOps pipeline"
git push origin main
```

### Option B: Manual Trigger
1. Go to **Actions** tab
2. Select "DevSecOps CI/CD Pipeline"
3. Click "Run workflow"

---

## Step 5: Monitor Pipeline

1. Go to **Actions** tab in GitHub
2. Click on the running workflow
3. Watch the stages execute:
   - 🔨 Build & Test (~3-5 min)
   - 🔍 SonarCloud SAST (~2-3 min)
   - 📦 OWASP Dependency Check (~5-10 min first run)
   - 🐳 Build Docker Images (~5-7 min)
   - 🛡️ Trivy Container Scan (~2-3 min)
   - 🚀 Publish to Docker Hub (~1-2 min)

**First run**: ~20-30 minutes (NVD database download)  
**Subsequent runs**: ~10-15 minutes (cached)

---

## ✅ Verify Success

### Check Pipeline
All stages should be ✅ green

### Check Docker Hub
1. Go to https://hub.docker.com/repositories
2. You should see 4 repositories:
   - `smart-academy-user-management`
   - `smart-academy-course-management`
   - `smart-academy-gateway`
   - `smart-academy-eureka-server`
3. Each with 2 tags: `latest` and `<commit-sha>`

### Check SonarCloud
1. Go to https://sonarcloud.io
2. Navigate to your organization
3. View analysis results for each service

---

## 🎯 What Happens on Each Push

```
Push to main
    ↓
Build & Test (Maven)
    ↓
Security Scans (SonarCloud, OWASP, Trivy)
    ↓
Docker Images Built & Scanned
    ↓
If all security checks pass ✅
    ↓
Images Published to Docker Hub 🚀
```

---

## 📚 Next Steps

- **Review Security Scans**: Check SonarCloud and Trivy reports
- **Fix Vulnerabilities**: Address any HIGH/CRITICAL findings
- **Customize Quality Gates**: Adjust SonarCloud settings
- **Read Full Docs**: See `PIPELINE_DOCUMENTATION.md`

---

## ❓ Troubleshooting

### Pipeline fails at SonarCloud
- ✅ Check `SONAR_TOKEN` is correct
- ✅ Verify organization name in workflow matches SonarCloud

### Pipeline fails at Docker Hub
- ✅ Check `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`
- ✅ Ensure token has write permissions

### Trivy blocks pipeline
- ✅ Review Trivy report in artifacts
- ✅ Update vulnerable packages in Dockerfiles
- ✅ Rebuild and push

---

## 📞 Support

- **Detailed Docs**: `.github/workflows/PIPELINE_DOCUMENTATION.md`
- **Secrets Setup**: `.github/workflows/SECRETS_SETUP_GUIDE.md`
- **Docker Security**: `.github/workflows/DOCKER_HUB_SECURITY.md`

---

**Estimated Setup Time**: 5-7 minutes  
**First Pipeline Run**: 20-30 minutes  
**Subsequent Runs**: 10-15 minutes

🎉 **You're ready to go!** The pipeline will now automatically run on every push to main.
