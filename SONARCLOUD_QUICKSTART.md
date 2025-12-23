# SonarCloud Quick Start

## 🚀 Quick Setup (5 minutes)

### Step 1: Create SonarCloud Account
1. Go to https://sonarcloud.io
2. Sign in with GitHub
3. Create organization: `smart-academy-org`

### Step 2: Create Projects
Create 4 projects with these exact keys:
- `smart-academy-shell`
- `smart-academy-auth`
- `smart-academy-dashboard`
- `smart-academy-courses`

### Step 3: Get Token
1. SonarCloud → My Account → Security
2. Generate token: `GitHub Actions - Smart Academy`
3. Copy the token

### Step 4: Add GitHub Secrets
Repository → Settings → Secrets → Actions:
- `SONAR_TOKEN` = `<your-token>`
- `SONAR_ORGANIZATION` = `smart-academy-org`

### Step 5: Push & Verify
```bash
git add .
git commit -m "feat: add SonarCloud integration"
git push
```

✅ **Done!** Check your SonarCloud dashboard.

---

## 📊 What You Get

- ✅ Code Quality Analysis (bugs, code smells)
- ✅ Security Vulnerability Detection  
- ✅ Test Coverage Tracking (from Vitest)
- ✅ Quality Gates (blocks bad code)

---

## 📍 Dashboards

- Shell: https://sonarcloud.io/dashboard?id=smart-academy-shell
- Auth: https://sonarcloud.io/dashboard?id=smart-academy-auth
- Dashboard: https://sonarcloud.io/dashboard?id=smart-academy-dashboard
- Courses: https://sonarcloud.io/dashboard?id=smart-academy-courses

---

## 📖 Full Documentation

See [SONARCLOUD_SETUP.md](./SONARCLOUD_SETUP.md) for detailed instructions.

---

**Cost:** FREE for public repositories! ✨
