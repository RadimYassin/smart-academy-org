# GitHub Secrets Setup Guide

## 📋 Overview

This guide explains how to configure the required GitHub Secrets for the DevSecOps CI/CD pipeline. These secrets are **essential** for the pipeline to function correctly.

---

## 🔑 Required Secrets

The pipeline requires **3 secrets**:

| Secret Name | Purpose | Used By |
|-------------|---------|---------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | Docker image tagging & publishing |
| `DOCKERHUB_TOKEN` | Docker Hub access token | Docker Hub authentication |
| `SONAR_TOKEN` | SonarCloud authentication | SonarCloud SAST analysis |

---

## 🐳 Docker Hub Configuration

### **Step 1: Create Docker Hub Account**

If you don't have one:
1. Go to https://hub.docker.com/signup
2. Create a free account
3. Verify your email address

### **Step 2: Create Access Token**

> [!IMPORTANT]
> Never use your Docker Hub password in CI/CD. Always use access tokens.

1. Log in to Docker Hub
2. Click your username (top-right) → **Account Settings**
3. Navigate to **Security** tab
4. Click **New Access Token**
5. Configure:
   - **Description**: `GitHub Actions - Smart Academy`
   - **Access permissions**: **Read, Write, Delete**
6. Click **Generate**
7. **Copy the token immediately** (you won't see it again!)

### **Step 3: Add to GitHub Secrets**

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add first secret:
   - **Name**: `DOCKERHUB_USERNAME`
   - **Value**: Your Docker Hub username (e.g., `johnsmith`)
5. Click **Add secret**
6. Click **New repository secret** again
7. Add second secret:
   - **Name**: `DOCKERHUB_TOKEN`
   - **Value**: Paste the access token from Step 2
8. Click **Add secret**

---

## ☁️ SonarCloud Configuration

### **Step 1: Create SonarCloud Account**

1. Go to https://sonarcloud.io
2. Click **Log in** (top-right)
3. Choose **GitHub** authentication
4. Authorize SonarCloud to access your GitHub account

### **Step 2: Create Organization**

1. After login, click **+** (top-right) → **Create new organization**
2. Choose:
   - **GitHub**: Import from GitHub (recommended)
   - OR **Manual**: Create manually
3. If using GitHub import:
   - Select your GitHub account/organization
   - Choose a **key** (e.g., `smart-academy-org`)
   - Choose plan: **Free** for public repos
4. Click **Create Organization**

### **Step 3: Import Projects**

1. In your SonarCloud organization
2. Click **+** → **Analyze new project**
3. Select your repository: `RadimYassin/smart-academy-org`
4. Click **Set Up**
5. Choose **GitHub Actions** as analysis method
6. SonarCloud will show setup instructions (you already have the workflow!)

### **Step 4: Generate Authentication Token**

1. Click your profile icon (top-right) → **My Account**
2. Navigate to **Security** tab
3. Under **Generate Tokens**:
   - **Name**: `GitHub Actions - Smart Academy`
   - **Type**: **User Token**
   - **Expires in**: **No expiration** (or 90 days if preferred)
4. Click **Generate**
5. **Copy the token immediately** (you won't see it again!)

### **Step 5: Add to GitHub Secrets**

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add secret:
   - **Name**: `SONAR_TOKEN`
   - **Value**: Paste the token from Step 4
5. Click **Add secret**

### **Step 6: Update Workflow File**

⚠️ **Important**: You need to update the SonarCloud organization in the workflow file.

1. Open `.github/workflows/devsecops.yml`
2. Find these lines (appears twice):
   ```yaml
   -Dsonar.organization=YOUR_SONARCLOUD_ORG
   ```
3. Replace `YOUR_SONARCLOUD_ORG` with your organization key from Step 2
4. Example:
   ```yaml
   -Dsonar.organization=smart-academy-org
   ```
5. Commit and push the changes

---

## ✅ Verify Configuration

### **Check Secrets**

1. Go to GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. You should see:
   - ✅ `DOCKERHUB_USERNAME`
   - ✅ `DOCKERHUB_TOKEN`
   - ✅ `SONAR_TOKEN`
3. Values are hidden (shows only "Updated X days ago")

### **Test Pipeline**

1. Make a small change to your repository (e.g., update README)
2. Commit and push to `main` branch
3. Go to **Actions** tab
4. Watch the pipeline run
5. Verify each stage:
   - ✅ Build & Test
   - ✅ SonarCloud (check for authentication success)
   - ✅ OWASP Dependency Check
   - ✅ Build Docker Images (check for correct username in tags)
   - ✅ Trivy Scan
   - ✅ Publish to Docker Hub (check for authentication success)

### **Verify Docker Hub**

1. Go to https://hub.docker.com/repositories
2. After successful pipeline run, you should see 4 repositories:
   - `smart-academy-user-management`
   - `smart-academy-course-management`
   - `smart-academy-gateway`
   - `smart-academy-eureka-server`
3. Each should have 2 tags: `latest` and `<commit-sha>`

### **Verify SonarCloud**

1. Go to https://sonarcloud.io
2. Navigate to your organization
3. You should see projects for analyzed services
4. Click on a project to view analysis results

---

## 🔒 Security Best Practices

### **DO**
- ✅ Use access tokens instead of passwords
- ✅ Set token expiration where possible
- ✅ Use descriptive token names
- ✅ Regularly rotate tokens (every 90 days)
- ✅ Limit token permissions to minimum required
- ✅ Delete unused tokens immediately

### **DON'T**
- ❌ Never commit secrets to source code
- ❌ Don't share secrets via email or chat
- ❌ Don't use the same token across multiple projects
- ❌ Don't store secrets in plain text files
- ❌ Don't use account passwords in CI/CD

---

## 🔄 Rotate Secrets (Best Practice)

### **Rotate Docker Hub Token (Every 90 days)**

1. Create new token in Docker Hub (same steps as above)
2. Update `DOCKERHUB_TOKEN` in GitHub Secrets
3. Previous token automatically invalidated

### **Rotate SonarCloud Token (Every 90 days)**

1. Generate new token in SonarCloud
2. Update `SONAR_TOKEN` in GitHub Secrets
3. Revoke old token in SonarCloud Security settings

---

## ❓ Troubleshooting

### **Issue**: Pipeline fails with "Error: Username and password required"
**Solution**: 
- Check `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` exist and are spelled correctly (case-sensitive)

### **Issue**: SonarCloud fails with "Error: Invalid or missing token"
**Solution**:
- Verify `SONAR_TOKEN` exists and is valid
- Check token hasn't expired
- Ensure token has analysis permissions

### **Issue**: Docker Hub push fails with "denied: repository does not exist"
**Solution**:
- Repositories are auto-created on first push for public images
- For private repos, create manually in Docker Hub first
- Verify `DOCKERHUB_USERNAME` matches your actual username

### **Issue**: Secret not updating in pipeline
**Solution**:
- Secrets are loaded at workflow start
- Re-run the workflow after updating secrets
- Clear Actions cache if issue persists

---

## 📞 Support

If you encounter issues:

1. **GitHub Actions**: Check Actions tab for detailed error messages
2. **Docker Hub**: https://hub.docker.com/support
3. **SonarCloud**: https://community.sonarsource.com/
4. **GitHub Secrets**: https://docs.github.com/en/actions/security-guides/encrypted-secrets

---

**Last Updated**: December 2025  
**Version**: 1.0
