# Docker Hub Publishing Security

## 🔐 Overview

This document explains how Docker Hub image publishing is secured in the DevSecOps pipeline, implementing multiple security gates to ensure only verified, vulnerability-free images reach production.

---

## 🛡️ Multi-Layer Security Gates

The pipeline implements **defense-in-depth** with 5 security layers before any image is published to Docker Hub:

```
┌─────────────────────────────────────────────────────┐
│  1. Build & Test (Unit Tests, Integration Tests)   │
└────────────────┬────────────────────────────────────┘
                 │ PASS ✓
                 ▼
┌─────────────────────────────────────────────────────┐
│  2. SAST - SonarCloud (Source Code Vulnerabilities) │
└────────────────┬────────────────────────────────────┘
                 │ PASS ✓
                 ▼
┌─────────────────────────────────────────────────────┐
│  3. SCA - OWASP (Dependency Vulnerabilities)        │
└────────────────┬────────────────────────────────────┘
                 │ INFORMATIONAL
                 ▼
┌─────────────────────────────────────────────────────┐
│  4. Docker Image Build (Multi-stage, Minimal)       │
└────────────────┬────────────────────────────────────┘
                 │ SUCCESS ✓
                 ▼
┌─────────────────────────────────────────────────────┐
│  5. Trivy Scan (Container Vulnerabilities)          │
│     - NO HIGH or CRITICAL vulnerabilities           │
└────────────────┬────────────────────────────────────┘
                 │ PASS ✓ (BLOCKING)
                 ▼
┌─────────────────────────────────────────────────────┐
│  ✅ PUBLISH TO DOCKER HUB                           │
└─────────────────────────────────────────────────────┘
```

---

## 🚧 Security Gate 1: Build & Test

**Purpose**: Ensure code compiles and passes all tests

**Blocking**: ✅ Yes - Pipeline stops if tests fail

**What It Prevents**:
- Broken code from being containerized
- Regression bugs reaching production
- Incomplete features being deployed

**Configuration**:
```yaml
needs: []  # First stage, no dependencies
```

---

## 🔍 Security Gate 2: SAST (SonarCloud)

**Purpose**: Detect source code vulnerabilities and security hotspots

**Blocking**: ✅ Yes - Fails if Quality Gate not met

**What It Prevents**:
- OWASP Top 10 vulnerabilities (SQL Injection, XSS, etc.)
- Hard-coded secrets
- Insecure cryptographic practices
- Authentication/authorization flaws

**Configuration**:
```yaml
needs: build-and-test
-Dsonar.qualitygate.wait=true  # Blocks if gate fails
```

**Quality Gate Criteria** (configurable in SonarCloud):
- Security Rating: A or B
- No new critical bugs
- Code coverage ≥ 80% (recommended)
- No security hotspots unreviewed

---

## 📦 Security Gate 3: SCA (OWASP Dependency-Check)

**Purpose**: Identify vulnerabilities in third-party libraries

**Blocking**: ⚠️ Informational only (continue-on-error: true)

**What It Detects**:
- Known CVEs in Maven dependencies
- Outdated libraries with security issues
- Vulnerable transitive dependencies

**Why Not Blocking**:
- Many CVEs may not apply to your usage
- Allows team to review and prioritize fixes
- Prevents false positives from blocking deployments

**Configuration**:
```yaml
needs: build-and-test
args: --failOnCVSS 7
continue-on-error: true  # Informational gate
```

**Future Enhancement**: Can be made blocking by removing `continue-on-error: true`

---

## 🐳 Security Gate 4: Docker Image Build

**Purpose**: Create secure, minimal container images

**Blocking**: ✅ Yes - Fails if build errors

**Security Features**:
- **Multi-stage builds**: Excludes build tools from final image
- **Alpine Linux base**: Minimal attack surface (~5MB vs ~200MB)
- **Non-root user**: Containers run as non-privileged user (future enhancement)
- **No secrets in layers**: All secrets via environment variables

**Example Dockerfile Security**:
```dockerfile
# Stage 1: Build (not in final image)
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime (final image)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**What It Prevents**:
- Bloated images with unnecessary tools
- Source code in production images
- Build dependencies in runtime

---

## 🛡️ Security Gate 5: Trivy Container Scan (CRITICAL)

**Purpose**: Final security check before publishing

**Blocking**: ✅ YES - **Most Critical Gate**

**What It Scans**:
1. **OS Packages**: Alpine Linux packages (apk)
2. **Application Dependencies**: Java JARs inside container
3. **Misconfigurations**: Docker best practices
4. **Secrets**: Hard-coded credentials (if any)

**Blocking Configuration**:
```yaml
needs: build-docker-images
severity: 'CRITICAL,HIGH'
exit-code: '1'  # ⚠️ BLOCKS pipeline on HIGH/CRITICAL
```

**Severity Levels**:
| Severity | Blocks Pipeline | Description |
|----------|----------------|-------------|
| CRITICAL | ✅ Yes | Exploitable, severe impact |
| HIGH | ✅ Yes | Serious security risk |
| MEDIUM | ❌ No | Moderate risk, review recommended |
| LOW | ❌ No | Minor risk, informational |

**What It Prevents**:
- Unpatched OS vulnerabilities
- Vulnerable application libraries
- Known exploits in container
- Insecure container configurations

---

## 🚀 Publishing Stage: Docker Hub

**Purpose**: Push verified images to Docker Hub

**Security Features**:

### 1. **Conditional Execution**
```yaml
needs: trivy-scan  # ⚠️ Only runs if Trivy passes
if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master')
```

**What This Means**:
- ✅ **Runs**: On push to main/master branch
- ❌ **Skips**: On pull requests (images built but not published)
- ❌ **Skips**: If any security scan fails

### 2. **Secure Authentication**
```yaml
- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}  # Access token, not password
```

**Security Best Practices**:
- Uses access tokens (revocable, limited permissions)
- Never uses account password
- Secrets stored in GitHub Secrets (encrypted)
- Automatic logout after push

### 3. **Dual Tagging Strategy**
```yaml
tags: |
  ${{ secrets.DOCKERHUB_USERNAME }}/smart-academy-user-management:latest
  ${{ secrets.DOCKERHUB_USERNAME }}/smart-academy-user-management:${{ github.sha }}
```

**Benefits**:
- **`latest`**: Convenient for development
- **`<commit-sha>`**: Immutable, traceable to specific commit
- Enables rollback to any previous version
- Audit trail for compliance

### 4. **Automatic Logout**
```yaml
- name: Logout from Docker Hub
  if: always()  # Even if push fails
  run: docker logout
```

**Why Important**:
- Prevents credential leakage
- Cleans up runner environment
- Best practice for CI/CD security

---

## 🔄 Publishing Decision Flow

```
┌──────────────────────────┐
│ Trigger: Push to main    │
└───────────┬──────────────┘
            │
            ▼
┌──────────────────────────┐
│ All tests passed? ───────┼─── NO ──→ ❌ STOP
└───────────┬──────────────┘
            │ YES
            ▼
┌──────────────────────────┐
│ SonarCloud passed? ──────┼─── NO ──→ ❌ STOP
└───────────┬──────────────┘
            │ YES
            ▼
┌──────────────────────────┐
│ Docker build success? ───┼─── NO ──→ ❌ STOP
└───────────┬──────────────┘
            │ YES
            ▼
┌──────────────────────────┐
│ Trivy scan passed? ──────┼─── NO ──→ ❌ STOP (CRITICAL)
│ (No HIGH/CRITICAL)       │
└───────────┬──────────────┘
            │ YES
            ▼
┌──────────────────────────┐
│ ✅ PUBLISH TO DOCKER HUB │
└──────────────────────────┘
```

---

## 📊 Example Scenarios

### ✅ **Scenario 1: Clean Build**
```
1. Build & Test: ✅ PASS
2. SonarCloud: ✅ PASS (Quality Gate met)
3. Dependency Check: ✅ PASS (No HIGH vulnerabilities)
4. Docker Build: ✅ SUCCESS
5. Trivy: ✅ PASS (No HIGH/CRITICAL)
6. Result: Images published to Docker Hub
```

### ❌ **Scenario 2: Vulnerable Dependency**
```
1. Build & Test: ✅ PASS
2. SonarCloud: ✅ PASS
3. Dependency Check: ⚠️ WARNING (CVE-2023-1234, CVSS 8.5)
4. Docker Build: ✅ SUCCESS
5. Trivy: ❌ FAIL (HIGH: CVE-2023-1234 in log4j-core)
6. Result: Pipeline BLOCKED, images NOT published
```

**Developer Action Required**:
1. Review Trivy report
2. Update vulnerable dependency in `pom.xml`
3. Rebuild and re-scan
4. Push fix → Pipeline reruns

### ❌ **Scenario 3: Code Quality Issue**
```
1. Build & Test: ✅ PASS
2. SonarCloud: ❌ FAIL (Security Rating: E - SQL Injection found)
3. Result: Pipeline STOPPED, subsequent stages skipped
```

**Developer Action Required**:
1. Review SonarCloud dashboard
2. Fix SQL injection vulnerability
3. Push fix → Pipeline reruns

---

## 🔐 Additional Security Measures

### **Least-Privilege Permissions**
```yaml
permissions:
  contents: read  # Read-only access to repository
  # No write permissions unless absolutely necessary
```

### **Dependency Integrity**
- All GitHub Actions pinned to major versions (`@v4`)
- Future enhancement: Pin to commit SHAs for supply chain security

### **Secrets Management**
- All credentials in GitHub Secrets (encrypted at rest)
- Never logged in workflow output
- Auto-redacted if accidentally printed

### **Network Security**
- Docker Hub access over HTTPS only
- TLS verification enabled
- No custom Docker registries without approval

---

## 📈 Compliance & Audit

### **Traceability**
Every published image can be traced back to:
- Exact commit SHA
- Pipeline run number
- Security scan results
- Developer who triggered the build

### **Audit Questions**:
1. **What vulnerabilities were present?** → Check Trivy/OWASP artifacts
2. **Who approved the deployment?** → GitHub commit author
3. **When was it deployed?** → Docker Hub push timestamp
4. **What tests ran?** → GitHub Actions logs

### **Retention**:
- Docker images: Indefinite (manual cleanup)
- Security reports: 30 days (GitHub artifacts)
- Pipeline logs: 90 days (GitHub default)
- SonarCloud history: Permanent

---

## 🚀 Future Enhancements

### **1. Image Signing (Cosign)**
```yaml
- name: Sign Docker Image
  uses: sigstore/cosign-installer@main
- run: cosign sign --key cosign.key $IMAGE
```
**Benefit**: Cryptographic proof of image authenticity

### **2. SBOM Generation**
```yaml
- name: Generate SBOM
  uses: aquasecurity/trivy-action@master
  with:
    format: 'cyclonedx'
    output: 'sbom.json'
```
**Benefit**: Complete inventory of all components

### **3. Policy Enforcement (OPA)**
```yaml
- name: Policy Check
  uses: open-policy-agent/opa-action@main
  with:
    policy: security-policy.rego
```
**Benefit**: Enforce organizational security policies

### **4. Runtime Scanning**
- Continuous scanning in production
- Real-time vulnerability alerts
- Automatic patching workflows

---

## ✅ Summary

The Docker Hub publishing process is secured through:

1. ✅ **5 Security Gates** - Multi-layer defense
2. ✅ **Blocking Gates** - Trivy stops vulnerable images
3. ✅ **Secure Authentication** - Access tokens, no passwords
4. ✅ **Conditional Publishing** - Only from main branch
5. ✅ **Immutable Tags** - Commit SHA for traceability
6. ✅ **Least Privilege** - Minimal permissions
7. ✅ **Audit Trail** - Full traceability

**Result**: Only secure, tested, vulnerability-free images reach Docker Hub.

---

**Last Updated**: December 2025  
**Review Date**: Quarterly  
**Owner**: DevSecOps Team
