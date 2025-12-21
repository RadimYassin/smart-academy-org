# CI/ CD Test Integration - Quick Reference

## ✅ What's Been Integrated

### 1. JaCoCo Code Coverage
**Files Modified:**
- `servers/Cour-Management/pom.xml` - Added JaCoCo plugin
- `servers/User-Management/pom.xml` - Added JaCoCo plugin
- `.github/workflows/devsecops.yml` - Added coverage generation

**Configuration:**
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <!-- Minimum 50% code coverage required -->
</plugin>
```

### 2. Pipeline Enhancements
**Added Steps:**
- ✅ Generate coverage reports after tests
- ✅ Upload test results as artifacts (30 days retention)
- ✅ Upload coverage reports as artifacts (30 days retention)
- ✅ Display test summary in GitHub Actions

## 📊 How to Use

### View Coverage Locally
```bash
# Run tests with coverage
cd servers/Cour-Management
mvn clean test

# Generate coverage report
mvn jacoco:report

# Open report in browser
start target/site/jacoco/index.html
```

### View Coverage in Pipeline
1. Go to GitHub Actions run
2. Download "coverage-reports" artifact
3. Extract and open `index.html`

### Coverage Reports Location
- **Local:** `target/site/jacoco/index.html`
- **Pipeline Artifacts:** Download from Actions tab

## 📈 Coverage Thresholds

| Metric | Minimum | Goal |
|--------|---------|------|
| Line Coverage | 50% | 70%+ |
| Branch Coverage | Tracked | 60%+ |
| Class Coverage | Tracked | 80%+ |

## 🎯 Next Steps

1. ✅ **Monitor Coverage** - Check reports after each run
2. ✅ **Improve Coverage** - Add tests for uncovered code
3. ⏳ **Optional:** Add Codecov integration for trending
4. ⏳ **Optional:** Generate coverage badges for README

## 📝 Commands

```bash
# Test both services
mvn clean test  # Run tests
mvn jacoco:report  # Generate coverage
mvn jacoco:check  # Verify coverage thresholds

# View coverage
# Windows
start target/site/jacoco/index.html

# Linux/Mac
open target/site/jacoco/index.html
```

## 🔍 Understanding Coverage Report

### Main Metrics:
- **Lines Covered** - Number of executed code lines
- **Branches Covered** - If/else decision points tested
- **Complexity** - Code complexity coverage
- **Methods** - Number of tested methods

### Color Coding:
- 🟢 **Green:** Well covered (\u003e80%)
- 🟡 **Yellow:** Partially covered (50-80%)
- 🔴 **Red:** Poorly covered (\u003c50%)

---

**Status:** ✅ JaCoCo integrated and working  
**Pipeline:** ✅ Enhanced with test/coverage reporting  
**Ready for:** Production use
