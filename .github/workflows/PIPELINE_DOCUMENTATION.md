# DevSecOps CI/CD Pipeline Documentation

## 📋 Overview

This document explains the production-ready DevSecOps CI/CD pipeline implemented for the Smart Academy Platform using GitHub Actions. The pipeline implements **Shift-Left Security** principles by integrating security at every stage of the software delivery lifecycle.

---

## 🔄 Pipeline Stages

### **Stage 1: Build & Test** ✅

**Purpose**: Compile and test all Spring Boot microservices to ensure code quality.

**What Happens**:
- Checks out source code with full Git history
- Sets up Java 17 (Eclipse Temurin distribution)
- Caches Maven dependencies for faster builds
- Builds 4 microservices:
  - User Management Service (with tests)
  - Course Management Service (with tests)
  - Gateway Service
  - Eureka Server
- Uploads JAR artifacts for 7-day retention

**Security Features**:
- Read-only permissions for `GITHUB_TOKEN`
- Dependency caching to prevent supply chain attacks
- Build reproducibility

**Failure Conditions**:
- Maven build errors
- Unit test failures
- Compilation errors

---

### **Stage 2: SAST - SonarCloud Analysis** 🔍

**Purpose**: Static Application Security Testing to detect security vulnerabilities, bugs, and code smells in source code.

**What Happens**:
- Scans Java source code for security issues
- Checks against OWASP Top 10 security rules
- Analyzes code quality, maintainability, and test coverage
- Enforces Quality Gate requirements
- Uploads results to SonarCloud dashboard

**Security Features**:
- Detects security hotspots and vulnerabilities
- Identifies hard-coded secrets
- Checks for SQL injection, XSS, and other OWASP risks
- Continuous quality monitoring

**Failure Conditions**:
- Quality Gate failure (configurable in SonarCloud)
- Code coverage below threshold
- Security rating below required level
- Critical bugs or vulnerabilities

**How to Read Results**:
1. Visit https://sonarcloud.io
2. Navigate to your organization
3. Select the project (e.g., `smart-academy-user-management`)
4. Review:
   - **Bugs**: Logic errors that could cause failures
   - **Vulnerabilities**: Security issues (CRITICAL to INFO)
   - **Security Hotspots**: Security-sensitive code requiring review
   - **Code Smells**: Maintainability issues
   - **Coverage**: Test coverage percentage

---

### **Stage 3: SCA - OWASP Dependency Check** 📦

**Purpose**: Software Composition Analysis to detect known vulnerabilities in third-party dependencies.

**What Happens**:
- Scans `pom.xml` and all Maven dependencies
- Checks against National Vulnerability Database (NVD)
- Identifies CVEs (Common Vulnerabilities and Exposures)
- Generates HTML and JSON reports
- Uploads reports as artifacts (30-day retention)

**Security Features**:
- Detects vulnerable dependencies
- Identifies outdated libraries
- Provides CVE details and remediation advice
- CVSS score-based risk assessment

**Failure Conditions**:
- CVSS score ≥ 7 (HIGH or CRITICAL)
- Note: Currently set to `continue-on-error: true` for informational purposes

**How to Read Results**:
1. Go to GitHub Actions run
2. Download `dependency-check-reports` artifact
3. Open HTML report in browser
4. Review:
   - **Dependency**: Library with vulnerability
   - **CVE**: Vulnerability identifier
   - **CVSS Score**: Severity (0-10)
   - **Description**: Vulnerability details
   - **Recommendation**: How to fix (usually upgrade)

---

### **Stage 4: Build Docker Images** 🐳

**Purpose**: Create containerized versions of all microservices.

**What Happens**:
- Uses matrix strategy to build 4 images in parallel
- Leverages Docker Buildx for efficient builds
- Implements layer caching for faster builds
- Tags images with:
  - `latest`: Always points to most recent build
  - `<commit-sha>`: Immutable, traceable version
- Saves images as artifacts for next stage

**Services Built**:
1. `smart-academy-user-management`
2. `smart-academy-course-management`
3. `smart-academy-gateway`
4. `smart-academy-eureka-server`

**Security Features**:
- Multi-stage builds (defined in Dockerfiles)
- Minimal Alpine Linux base images
- Read-only permissions
- No secrets in images

**Failure Conditions**:
- Dockerfile syntax errors
- Build context issues
- Out of memory errors

---

### **Stage 5: Container Security - Trivy Scan** 🛡️

**Purpose**: Scan Docker images for vulnerabilities in OS packages and application dependencies.

**What Happens**:
- Downloads built Docker images from artifacts
- Scans each image for:
  - OS package vulnerabilities
  - Application dependency vulnerabilities
  - Misconfigurations
- Generates SARIF format for GitHub Security
- Creates HTML reports for detailed analysis
- **Fails pipeline** on HIGH or CRITICAL vulnerabilities

**Security Features**:
- Comprehensive vulnerability database
- Multi-layer scanning (OS + app)
- SARIF integration with GitHub Security tab
- Severity-based filtering

**Failure Conditions**:
- Any HIGH severity vulnerability
- Any CRITICAL severity vulnerability
- Exit code: 1 (blocking)

**How to Read Results**:
1. **GitHub Security Tab**:
   - Go to repository → Security → Code scanning
   - View Trivy alerts by severity
   - See affected packages and remediation

2. **HTML Report** (Artifacts):
   - Download `trivy-report-<service>` from Actions
   - Open in browser
   - Review:
     - **Vulnerability ID**: CVE number
     - **Package**: Affected package and version
     - **Severity**: CRITICAL, HIGH, MEDIUM, LOW
     - **Fixed Version**: Upgrade target
     - **Description**: Vulnerability details

---

### **Stage 6: Publish to Docker Hub** 🚀

**Purpose**: Push secure, scanned Docker images to Docker Hub for deployment.

**What Happens**:
- **Only runs** if all security scans pass
- **Only runs** on push to `main` or `master` branch
- Downloads verified images from artifacts
- Authenticates to Docker Hub securely
- Pushes both tags (`latest` and commit SHA)
- Logs out for security

**Security Features**:
- Conditional execution (security gate)
- Secure authentication with tokens (not passwords)
- Automatic logout
- Least-privilege permissions
- Only pushes verified images

**Images Published**:
```
<dockerhub-username>/smart-academy-user-management:latest
<dockerhub-username>/smart-academy-user-management:<commit-sha>
<dockerhub-username>/smart-academy-course-management:latest
<dockerhub-username>/smart-academy-course-management:<commit-sha>
<dockerhub-username>/smart-academy-gateway:latest
<dockerhub-username>/smart-academy-gateway:<commit-sha>
<dockerhub-username>/smart-academy-eureka-server:latest
<dockerhub-username>/smart-academy-eureka-server:<commit-sha>
```

**Failure Conditions**:
- Docker Hub authentication failure
- Network issues
- Rate limiting
- Missing secrets

---

## 🔐 Security Best Practices Implemented

### 1. **No Secrets in Source Code**
- All credentials stored in GitHub Secrets
- Environment variables for sensitive data
- `.env` files in `.gitignore`

### 2. **Least-Privilege Permissions**
```yaml
permissions:
  contents: read          # Most jobs: read-only
  security-events: write  # Trivy: write security events only
```

### 3. **Shift-Left Security**
- Security checks early in pipeline
- Fast feedback on vulnerabilities
- Prevent vulnerable code from reaching production

### 4. **Defense in Depth**
- Multiple security layers:
  - SAST (source code)
  - SCA (dependencies)
  - Container scanning (runtime environment)

### 5. **Fail-Fast Approach**
- Pipeline stops on critical issues
- No vulnerable images published
- Quality gates enforced

### 6. **Audit Trail**
- Commit SHA tagging for traceability
- Artifact retention
- Security scan history in GitHub

### 7. **Supply Chain Security**
- Dependency caching verification
- Known vulnerability scanning
- Image signing (future enhancement)

---

## 🎯 Pipeline Triggers

The pipeline runs on:

| Trigger | Behavior |
|---------|----------|
| **Push to main/master** | Full pipeline + Docker Hub publish |
| **Pull Request** | Full pipeline, no Docker Hub publish |
| **Manual (workflow_dispatch)** | Full pipeline + Docker Hub publish (if on main/master) |

---

## 📊 Understanding Pipeline Results

### ✅ **Successful Run**
All stages green → Images published to Docker Hub

### ❌ **Failed Run - Examples**

**Build Failure** (Stage 1):
```
Cause: Compilation error, test failure
Action: Fix code, commit, push
```

**SonarCloud Failure** (Stage 2):
```
Cause: Quality Gate not met
Action: Review SonarCloud dashboard, address issues
```

**Trivy Failure** (Stage 5):
```
Cause: HIGH/CRITICAL vulnerability in image
Action: Update base image or vulnerable packages
```

**Docker Hub Failure** (Stage 6):
```
Cause: Missing secrets or authentication issue
Action: Verify GitHub Secrets configuration
```

---

## 🔧 Troubleshooting

### **Issue**: SonarCloud scan fails with "Quality Gate Failed"
**Solution**:
1. Visit SonarCloud dashboard
2. Review failed conditions (coverage, bugs, vulnerabilities)
3. Fix issues in code
4. Push changes

### **Issue**: OWASP Dependency Check takes too long
**Solution**:
- First run downloads NVD database (slow)
- Subsequent runs use cache (fast)
- This is expected behavior

### **Issue**: Trivy finds vulnerability in Alpine Linux
**Solution**:
1. Check if fixed version available
2. Update Dockerfile base image version
3. If no fix available, consider suppression with justification

### **Issue**: Docker Hub push fails with "denied"
**Solution**:
1. Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` in GitHub Secrets
2. Ensure token has push permissions
3. Check Docker Hub repository exists

### **Issue**: Workflow doesn't trigger on push
**Solution**:
1. Verify branch name matches trigger (`main` or `master`)
2. Check `.github/workflows/devsecops.yml` exists in repository
3. Review GitHub Actions tab for errors

---

## 📈 Metrics and Reports

### **Available Reports**

| Report | Location | Retention |
|--------|----------|-----------|
| **Build Artifacts** | Actions → Artifacts | 7 days |
| **Dependency Check** | Actions → Artifacts | 30 days |
| **Trivy Scans** | Actions → Artifacts + Security tab | 30 days |
| **SonarCloud** | https://sonarcloud.io | Permanent |

### **Key Metrics to Monitor**

1. **Pipeline Success Rate**: % of successful runs
2. **Mean Time to Fix**: Time from vulnerability detection to fix
3. **Vulnerability Trend**: Number of vulnerabilities over time
4. **Code Coverage**: Test coverage percentage
5. **Build Time**: Pipeline execution duration

---

## 🚀 Next Steps

### **Enhancements** (Future)
1. **Image Signing**: Sign Docker images with Cosign
2. **SBOM Generation**: Create Software Bill of Materials
3. **Runtime Security**: Implement Falco or similar
4. **Compliance Scanning**: Add CIS benchmarks
5. **Performance Testing**: Integrate JMeter or Gatling
6. **Deploy Automation**: Add Kubernetes deployment stage

### **Maintenance**
1. **Weekly**: Review security scan results
2. **Monthly**: Update vulnerable dependencies
3. **Quarterly**: Review and update security policies
4. **Annual**: Security audit and penetration testing

---

## 📚 Additional Resources

- **SonarCloud**: https://sonarcloud.io/documentation
- **OWASP Dependency-Check**: https://owasp.org/www-project-dependency-check/
- **Trivy**: https://aquasecurity.github.io/trivy/
- **GitHub Actions**: https://docs.github.com/en/actions
- **Docker Hub**: https://docs.docker.com/docker-hub/

---

**Last Updated**: December 2025  
**Pipeline Version**: 1.0  
**Maintained By**: DevSecOps Team
