# 🧪 Login Integration - Test Scenarios

## ✅ Pre-Test Setup

### 1. Start Backend Services
```bash
cd servers
docker-compose up -d
docker-compose ps  # Verify all services are "Up"
```

### 2. Configure Mobile App
Check `lib/core/constants/app_constants.dart`:
- Android Emulator: `http://10.0.2.2:8888`
- iOS Simulator: `http://localhost:8888`
- Physical Device: `http://YOUR_IP:8888`

### 3. Run Mobile App
```bash
cd clients/mobile
flutter pub get
flutter run
```

---

## 🎯 Test Scenarios

### Scenario 1: Successful Login ✅

**Prerequisites:**
- User exists in database
- User is verified
- Correct credentials

**Steps:**
1. Navigate: Splash → Onboarding → Welcome → Sign In
2. Enter Email: `student@example.com`
3. Enter Password: `Password123!`
4. Tap "Sign In" button

**Expected Result:**
- ✅ Loading indicator appears on button
- ✅ Button is disabled during loading
- ✅ Green snackbar appears: "Welcome Back! Hello John Doe"
- ✅ Navigate to Dashboard screen
- ✅ Tokens saved in storage
- ✅ isLoggedIn = true

**Verification:**
```dart
// Check storage in Flutter DevTools
GetStorage().read('access_token') != null
GetStorage().read('is_logged_in') == true
```

---

### Scenario 2: Invalid Password ❌

**Steps:**
1. Enter Email: `student@example.com`
2. Enter Password: `WrongPassword123`
3. Tap "Sign In"

**Expected Result:**
- ❌ Red snackbar: "Invalid email or password"
- ❌ Button returns to normal state
- ❌ Stay on Sign In screen
- ❌ No tokens saved

---

### Scenario 3: User Not Found ❌

**Steps:**
1. Enter Email: `nonexistent@example.com`
2. Enter Password: `Password123!`
3. Tap "Sign In"

**Expected Result:**
- ❌ Red snackbar: "User not found"
- ❌ Stay on Sign In screen

---

### Scenario 4: Empty Email ❌

**Steps:**
1. Leave Email field empty
2. Enter Password: `Password123!`
3. Tap "Sign In"

**Expected Result:**
- ❌ Validation error: "Email is required"
- ❌ No API call made

---

### Scenario 5: Invalid Email Format ❌

**Steps:**
1. Enter Email: `invalidemail.com`
2. Enter Password: `Password123!`
3. Tap "Sign In"

**Expected Result:**
- ❌ Validation error: "Please enter a valid email"
- ❌ No API call made

---

### Scenario 6: Short Password ❌

**Steps:**
1. Enter Email: `student@example.com`
2. Enter Password: `12345`
3. Tap "Sign In"

**Expected Result:**
- ❌ Validation error: "Password must be at least 6 characters"
- ❌ No API call made

---

### Scenario 7: Network Error ❌

**Prerequisites:**
- Backend services stopped

**Steps:**
1. Stop backend: `docker-compose down`
2. Try to login with valid credentials

**Expected Result:**
- ❌ Red snackbar: "Network error. Please check your connection."
- ❌ Stay on Sign In screen

---

### Scenario 8: Server Error ❌

**Prerequisites:**
- Backend returns 500 error

**Expected Result:**
- ❌ Red snackbar with error message
- ❌ Stay on Sign In screen

---

### Scenario 9: Token Auto-Refresh ✅

**Prerequisites:**
- User is logged in
- Access token expired (wait 24 hours or manually expire)

**Steps:**
1. Make API call to protected endpoint
2. Token expired (401 response)

**Expected Result:**
- ✅ AuthInterceptor catches 401
- ✅ Refresh token is called automatically
- ✅ New tokens saved
- ✅ Original request retried
- ✅ Success!

---

### Scenario 10: Logout ✅

**Steps:**
1. Login successfully
2. Navigate to Profile
3. Tap "Logout" button

**Expected Result:**
- ✅ All tokens cleared from storage
- ✅ isLoggedIn = false
- ✅ Navigate to Welcome screen

---

## 🔍 Debug Checklist

### If Login Fails:

1. **Check Backend:**
```bash
curl http://localhost:8888/user-management-service/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"student@example.com","password":"Password123!"}'
```

2. **Check Mobile Logs:**
```bash
flutter run --verbose
```

3. **Check Storage:**
- Open Flutter DevTools
- Go to Storage tab
- Check GetStorage contents

4. **Check API Client:**
- Verify base URL is correct
- Check if PrettyDioLogger is showing requests
- Verify interceptors are working

---

## 📊 Test Results Template

| Scenario | Status | Notes |
|----------|--------|-------|
| Successful Login | ✅ | - |
| Invalid Password | ✅ | - |
| User Not Found | ✅ | - |
| Empty Email | ✅ | - |
| Invalid Email Format | ✅ | - |
| Short Password | ✅ | - |
| Network Error | ✅ | - |
| Server Error | ✅ | - |
| Token Auto-Refresh | ✅ | - |
| Logout | ✅ | - |

---

## 🎯 Performance Metrics

Target metrics:
- Login response time: < 2 seconds
- UI feedback: < 100ms
- Navigation: < 300ms

---

## 📱 Device Testing

Test on multiple devices:
- [ ] Android Emulator (API 30+)
- [ ] iOS Simulator (iOS 14+)
- [ ] Physical Android device
- [ ] Physical iOS device
- [ ] Web browser

---

## 🔐 Security Testing

- [ ] Password is not visible in logs
- [ ] Token is not logged in console
- [ ] HTTPS is used for all requests
- [ ] Token is stored securely
- [ ] Sensitive data not cached

---

## ♿ Accessibility Testing

- [ ] Screen reader works
- [ ] Keyboard navigation works
- [ ] Color contrast is sufficient
- [ ] Font sizes are readable
- [ ] Touch targets are large enough

---

## 🎨 UI/UX Testing

- [ ] Loading state is clear
- [ ] Error messages are helpful
- [ ] Success feedback is visible
- [ ] Animations are smooth
- [ ] Forms are easy to use

---

## 🚀 Quick Test Command

Create a test user and login:

```bash
# 1. Create user
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "firstName": "Test",
    "lastName": "User",
    "role": "STUDENT"
  }'

# 2. Test login
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

---

## ✅ Sign-Off Checklist

Before marking as complete:
- [ ] All test scenarios passed
- [ ] No console errors
- [ ] No linting warnings
- [ ] Performance is acceptable
- [ ] UI/UX is polished
- [ ] Documentation is complete
- [ ] Code is reviewed
- [ ] Ready for production

---

**Testing Status:** 🟢 Ready to Test

**Last Updated:** 2024

**Tester:** _______________

**Date:** _______________

