# 🚀 Quick Start: Testing Login Integration

## Step 1: Start Backend Services

```bash
cd servers
docker-compose up -d
```

Wait 30 seconds for all services to start.

**Verify services are running:**
```bash
docker-compose ps
```

All services should show "Up" status.

---

## Step 2: Create Test User (Optional)

If you don't have a user account, create one via API:

```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "Password123!",
    "firstName": "John",
    "lastName": "Doe",
    "role": "STUDENT"
  }'
```

Or use the mobile app's Sign Up flow!

---

## Step 3: Configure Mobile App for Android Emulator

**IMPORTANT:** If using Android emulator, update the base URL:

Open `lib/core/constants/app_constants.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8888';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8888';

// For Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.XXX:8888';
```

---

## Step 4: Run Mobile App

```bash
cd clients/mobile
flutter pub get
flutter run
```

---

## Step 5: Test Login

1. **Navigate through app:**
   - Splash Screen (auto-navigates)
   - Onboarding (3 pages, swipe or skip)
   - Welcome Screen
   - Tap "Sign In"

2. **Enter credentials:**
   - Email: `student@example.com`
   - Password: `Password123!`

3. **Tap "Sign In" button**

4. **Watch for:**
   - ✅ Loading indicator on button
   - ✅ Success message: "Welcome Back! Hello John Doe"
   - ✅ Navigation to Dashboard

---

## 🎉 Success Indicators

✅ **Login Successful:**
- Green snackbar appears
- Dashboard screen loads
- User data saved to storage

❌ **Login Failed:**
- Red snackbar with error message
- Button returns to normal state
- User stays on sign in screen

---

## 🐛 Common Issues

### "Network error"
- **Solution:** Check backend is running: `docker-compose ps`
- **For Android Emulator:** Use `10.0.2.2:8888` instead of `localhost:8888`

### "Invalid email or password"
- **Solution:** Verify user exists or create new account
- **Check:** User is not deleted in database

### App crashes
- **Solution:** Run `flutter clean && flutter pub get`
- **Check:** All dependencies installed

---

## 📱 Platform-Specific URLs

| Platform | Base URL |
|----------|----------|
| Android Emulator | `http://10.0.2.2:8888` |
| iOS Simulator | `http://localhost:8888` |
| Physical Device | `http://YOUR_COMPUTER_IP:8888` |

To find your computer's IP:
- **Mac/Linux:** `ifconfig | grep inet`
- **Windows:** `ipconfig`

---

## 🔍 Debugging

### View Logs:
```bash
# Mobile app logs (in separate terminal)
flutter run --verbose

# Backend logs
docker-compose logs -f user-management
```

### Check API Directly:
```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"student@example.com","password":"Password123!"}'
```

Expected response:
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "email": "student@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "STUDENT",
  "isVerified": true
}
```

---

## ✅ Complete!

You're all set! The login integration is working end-to-end.

**Next:** Integrate registration, email verification, and course APIs!

See `LOGIN_API_INTEGRATION.md` for detailed documentation.

