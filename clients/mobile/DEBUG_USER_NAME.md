# 🐛 Debug: User Name Not Showing

## Issue
Home screen shows "Welcome User" instead of actual user's first name.

## Debugging Steps

### 1. Check What's in Storage

Add this temporary debug code to HomeController:

```dart
void debugStorage() {
  Logger.logInfo('=== STORAGE DEBUG ===');
  Logger.logInfo('userDataKey: ${_storage.read(AppConstants.userDataKey)}');
  Logger.logInfo('accessToken exists: ${_storage.read(AppConstants.accessTokenKey) != null}');
  Logger.logInfo('userEmail: ${_storage.read(AppConstants.userEmailKey)}');
  Logger.logInfo('isLoggedIn: ${_storage.read(AppConstants.isLoggedInKey)}');
  Logger.logInfo('===================');
}
```

Call it in onInit():
```dart
@override
void onInit() {
  super.onInit();
  debugStorage(); // Add this
  _loadUserData();
}
```

### 2. Check Console Logs

When you run the app and navigate to home screen, you should see logs like:

```
✅ Good Output:
[INFO] Reading user data from storage: {firstName: John, lastName: Doe, email: student@example.com, ...}
[INFO] User data type: _InternalLinkedHashMap<String, dynamic>
[INFO] Extracted: firstName=John, lastName=Doe, email=student@example.com
[INFO] User name set to: John

❌ Bad Output (Problem):
[INFO] Reading user data from storage: null
[INFO] Trying fallback load...
[INFO] Fallback: userName set to student
```

### 3. Common Issues & Solutions

#### Issue A: userData is null
**Cause**: Data not saved during login

**Solution**: Check if login response contains firstName:

```dart
// In SignInController after successful login:
Logger.logInfo('Login response: ${response.firstName} ${response.lastName}');
```

If this shows empty, the backend isn't returning firstName/lastName.

**Fix**: Check backend API response includes these fields.

---

#### Issue B: userData exists but firstName is empty
**Cause**: Backend returns empty firstName

**Solution**: 
1. Check backend User model includes firstName/lastName
2. Verify database has these fields populated
3. Ensure API response serializes these fields

---

#### Issue C: Type conversion issue
**Cause**: userData is Map<dynamic, dynamic> instead of Map<String, dynamic>

**Solution**: Already fixed in updated HomeController with:
```dart
final data = userData is Map ? Map<String, dynamic>.from(userData) : null;
```

---

#### Issue D: Timing issue
**Cause**: HomeController loads before data is saved

**Solution**: Already fixed with onReady() hook:
```dart
@override
void onReady() {
  super.onReady();
  if (userName.value == 'User') {
    _loadUserData(); // Reload if still default
  }
}
```

---

### 4. Manual Test

You can manually check storage using Flutter DevTools:

1. Run app with: `flutter run`
2. Open Flutter DevTools
3. Go to "Logging" tab
4. Look for our Logger messages
5. Or use "Memory" tab → search for GetStorage

---

### 5. Force Clear & Retry

If data seems corrupted:

```dart
// Add this to SignInController before login:
await Get.find<GetStorage>().remove(AppConstants.userDataKey);
```

This will force fresh data save on next login.

---

### 6. Test Backend Response

Test the API directly:

```bash
curl -X POST http://localhost:8888/user-management-service/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"student@example.com","password":"Password123!"}'
```

Expected response should include:
```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "email": "student@example.com",
  "firstName": "John",          ← Must be present
  "lastName": "Doe",            ← Must be present
  "role": "STUDENT",
  "isVerified": true
}
```

If firstName/lastName are missing in API response:
→ **Backend issue**: Update AuthResponse in backend to include these fields

---

### 7. Quick Fixes

#### Quick Fix 1: Use email as name temporarily
```dart
// In HomeController._loadUserData(), change:
userName.value = firstName.isNotEmpty ? firstName : email.split('@')[0];
```

This will show email username if firstName is empty.

---

#### Quick Fix 2: Add default test data
```dart
// In DependencyInjection.init(), add:
if (GetStorage().read(AppConstants.userDataKey) == null) {
  GetStorage().write(AppConstants.userDataKey, {
    'firstName': 'Test',
    'lastName': 'User',
    'email': 'test@example.com',
    'role': 'STUDENT',
  });
}
```

---

### 8. Verify Storage Keys Match

Ensure constants are correct:

```dart
// In app_constants.dart:
static const String userDataKey = 'user_data';  ← Check this matches
static const String userEmailKey = 'user_email';
```

And in auth_repository_impl.dart:
```dart
await _storage.write(AppConstants.userDataKey, response.toJson());  ← Using same key
```

---

### 9. Check AuthResponse.toJson()

Verify the toJson() method includes firstName:

```dart
// In auth_response.dart:
Map<String, dynamic> toJson() {
  return {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'email': email,
    'firstName': firstName,      ← Must be here
    'lastName': lastName,        ← Must be here
    'role': role,
    'isVerified': isVerified,
  };
}
```

---

### 10. Enable Verbose Logging

Run with verbose logging:

```bash
flutter run --verbose
```

Look for these specific logs:
- "Auth data saved successfully"
- "User data loaded: John Doe"
- "User name set to: John"

---

## Resolution Checklist

- [ ] Backend returns firstName/lastName in login response
- [ ] AuthResponse.toJson() includes firstName/lastName
- [ ] Data is saved to storage after login
- [ ] HomeController reads from correct storage key
- [ ] Type conversion handles Map properly
- [ ] Logs show correct data extraction
- [ ] UI updates with actual name

---

## Expected Flow

```
1. User logs in
   → API returns: {firstName: "John", ...}
   
2. AuthResponse.fromJson() parses it
   → response.firstName = "John"
   
3. Repository saves it
   → storage.write('user_data', {firstName: "John", ...})
   
4. HomeController reads it
   → userData = {firstName: "John", ...}
   
5. Extract firstName
   → userName.value = "John"
   
6. UI displays it
   → "Welcome John" ✅
```

If any step fails, trace back to find where it broke.

---

## Still Not Working?

Share these logs:
1. Login response from backend
2. Console logs from HomeController
3. Storage debug output

This will help identify the exact issue.

