# SonarCloud Setup Guide for Smart Academy

## Overview
SonarCloud is now integrated into the CI/CD pipeline for all 4 microfrontends to provide:
- **Code Quality Analysis** - Detect bugs, code smells, and maintain code quality
- **Security Scanning** - Identify security vulnerabilities and hotspots
- **Test Coverage Tracking** - Monitor and visualize test coverage over time
- **Quality Gates** - Enforce quality standards before merging

---

## Setup Instructions

### 1. Create SonarCloud Account

1. Go to [SonarCloud.io](https://sonarcloud.io)
2. Sign in with your GitHub account
3. Click "**Analyze new project**"

### 2. Create Organization

1. Click "**+ Create new organization**"
2. Choose your GitHub organization or create a new one
3. Set organization key: `smart-academy-org` (must match the config)
4. Make it **public** (free for open source) or **private** (paid)

### 3. Import Projects

For each microfrontend, create a new project:

**Shell Microfrontend:**
- Project key: `smart-academy-shell`
- Display name: `Smart Academy - Shell`

**Auth Microfrontend:**
- Project key: `smart-academy-auth`
- Display name: `Smart Academy - Auth`

**Dashboard Microfrontend:**
- Project key: `smart-academy-dashboard`
- Display name: `Smart Academy - Dashboard`

**Courses Microfrontend:**
- Project key: `smart-academy-courses`
- Display name: `Smart Academy - Courses`

### 4. Get SonarCloud Token

1. Go to **My Account** → **Security**
2. Generate a new token:
   - Name: `GitHub Actions - Smart Academy`
   - Type: `User Token`
   - Expiration: `No expiration` or `90 days`
3. **Copy the token** (you'll need it for GitHub Secrets)

### 5. Configure GitHub Secrets

Add these secrets to your GitHub repository:

**Go to:** Repository → Settings → Secrets and variables → Actions → New repository secret

**Add two secrets:**

1. **SONAR_TOKEN**
   - Value: `<your-sonarcloud-token>`
   
2. **SONAR_ORGANIZATION**
   - Value: `smart-academy-org`

### 6. Verify Configuration

After setting up secrets, push a commit to trigger the pipeline:

```bash
git add .
git commit -m "feat: integrate SonarCloud analysis"
git push origin main
```

The pipeline will now:
1. Run tests
2. Generate coverage
3. Upload to SonarCloud
4. Display quality gate status

---

## SonarCloud Dashboard

After the first successful run, you can access your dashboards:

- **Shell**: https://sonarcloud.io/dashboard?id=smart-academy-shell
- **Auth**: https://sonarcloud.io/dashboard?id=smart-academy-auth
- **Dashboard**: https://sonarcloud.io/dashboard?id=smart-academy-dashboard
- **Courses**: https://sonarcloud.io/dashboard?id=smart-academy-courses

---

## Quality Gates

The default quality gate requires:
- ✅ **No new bugs** on new code
- ✅ **No new vulnerabilities** on new code
- ✅ **Coverage on new code** ≥ 80%
- ✅ **Duplicated lines on new code** ≤ 3%
- ✅ **Maintainability rating** ≥ A

You can customize these in SonarCloud → Quality Gates.

---

## Configuration Files

Each microfrontend has a `sonar-project.properties` file:

```
clients/microfrontends/
├── shell/sonar-project.properties
├── auth/sonar-project.properties
├── dashboard/sonar-project.properties
└── courses/sonar-project.properties
```

### Key Configuration Options:

**Source Directories:**
```properties
sonar.sources=src
sonar.tests=src
```

**Test Detection:**
```properties
sonar.test.inclusions=**/*.test.ts,**/*.test.tsx,**/__tests__/**
```

**Exclusions:**
```properties
sonar.exclusions=**/*.test.ts,**/*.test.tsx,**/__tests__/**,**/node_modules/**,**/dist/**,**/coverage/**
```

**Coverage:**
```properties
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

---

## Viewing Results

### In GitHub Actions

After each run, you'll see:
- ✅ SonarCloud analysis status in the workflow
- 📊 Quality gate pass/fail status
- 🔗 Link to detailed SonarCloud report

### In SonarCloud

Navigate to your project dashboard to see:
- **Overview** - Overall health and quality gate status
- **Issues** - Bugs, vulnerabilities, code smells
- **Measures** - Coverage, duplication, complexity metrics
- **Code** - Browse source code with annotations
- **Activity** - Historical trends and analysis history

---

## Badge Integration

Add SonarCloud badges to your README:

**Quality Gate:**
```markdown
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=smart-academy-shell&metric=alert_status)](https://sonarcloud.io/dashboard?id=smart-academy-shell)
```

**Coverage:**
```markdown
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=smart-academy-shell&metric=coverage)](https://sonarcloud.io/dashboard?id=smart-academy-shell)
```

**Bugs:**
```markdown
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=smart-academy-shell&metric=bugs)](https://sonarcloud.io/dashboard?id=smart-academy-shell)
```

---

## Troubleshooting

### Analysis Fails

**Check:**
1. ✅ `SONAR_TOKEN` secret is set correctly
2. ✅ `SONAR_ORGANIZATION` matches your organization key
3. ✅ Project keys match between workflow and SonarCloud
4. ✅ Coverage files are generated (`coverage/lcov.info` exists)

### No Coverage Data

**Ensure:**
1. Tests run successfully before SonarCloud scan
2. `npm run test:coverage` generates `coverage/lcov.info`
3. Coverage path matches in `sonar-project.properties`

### Quality Gate Fails

**Common reasons:**
- New bugs or vulnerabilities introduced
- Test coverage below threshold (80%)
- Too many code smells or duplications
- Security hotspots not reviewed

**Fix by:**
- Review and fix reported issues
- Add more tests to increase coverage
- Refactor duplicated code
- Address security concerns

---

## Best Practices

### 1. Monitor Quality Gates
- Don't merge PRs that fail quality gates
- Address issues promptly

### 2. Maintain Coverage
- Keep coverage above 80% for new code
- Write tests for new features

### 3. Review Security Issues
- Address security hotspots
- Follow SonarCloud security recommendations

### 4. Reduce Technical Debt
- Regularly review and fix code smells
- Refactor complex methods (cyclomatic complexity > 10)

### 5. Track Trends
- Monitor historical trends in SonarCloud
- Set goals for improvement

---

## Cost

- **Open Source / Public repositories**: FREE ✅
- **Private repositories**: Paid plans starting at $10/month

For open source projects, SonarCloud offers unlimited analysis for free!

---

## Support

- 📚 [SonarCloud Documentation](https://docs.sonarcloud.io/)
- 💬 [Community Forum](https://community.sonarsource.com/)
- 🐛 [Issue Tracker](https://github.com/SonarSource/sonarcloud-github-action/issues)

---

Happy analyzing! 📊✨
