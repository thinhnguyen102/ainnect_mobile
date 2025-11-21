# 🚨 Common Issues & Solutions

## 1. ❌ Appium Server Not Running

### Error:
```
Error: Failed to create session.
Unable to connect to "http://localhost:4723/wd/hub"
```

### Solution:
```cmd
# Terminal 1 - Start Appium
cd appium-tests
start-appium.bat

# Wait for this message:
# "Appium REST http interface listener started on 0.0.0.0:4723"
```

## 2. ❌ No Android Device

### Error:
```
No Android device/emulator detected!
```

### Solution:

#### Option A: Start Emulator
```cmd
# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd <name>

# Example:
emulator -avd Pixel_5_API_33
```

#### Option B: Connect Real Device
1. Enable Developer Options on phone
2. Enable USB Debugging
3. Connect via USB
4. Accept debugging prompt on phone
5. Verify: `adb devices`

## 3. ❌ APK Not Found

### Error:
```
Staging APK not found!
```

### Solution:
```cmd
cd appium-tests
build-staging-apk.bat
```

## 4. ❌ Appium Not Installed

### Error:
```
'appium' is not recognized as an internal or external command
```

### Solution:
```cmd
cd appium-tests
install-appium.bat
```

## 5. ❌ Port 4723 Already in Use

### Error:
```
EADDRINUSE: address already in use :::4723
```

### Solution:
```cmd
# Find process using port 4723
netstat -ano | findstr :4723

# Kill the process (replace <PID> with actual PID)
taskkill /PID <PID> /F

# Or restart computer
```

## 6. ❌ ADB Not Found

### Error:
```
'adb' is not recognized as an internal or external command
```

### Solution:
1. Install Android Studio or Android Command Line Tools
2. Add to PATH:
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`
3. Restart terminal
4. Verify: `adb --version`

## 7. ❌ Test Timeout

### Error:
```
Error: Timeout of 120000ms exceeded
```

### Solution:

#### Option A: Increase timeout
Edit test file:
```javascript
this.timeout(300000); // 5 minutes
```

#### Option B: Check app/network
- App may be slow to start
- Network requests timing out
- Check staging server is online

## 8. ❌ Element Not Found

### Error:
```
An element could not be located on the page using the given search parameters
```

### Solution:
- App UI may have changed
- Locators need updating
- Run visual demo to see what's happening:
  ```cmd
  npm run test:demo
  ```

## 9. ❌ Permission Denied (Screenshots)

### Error:
```
EACCES: permission denied, mkdir 'screenshots'
```

### Solution:
```cmd
# Create directories manually
mkdir screenshots
mkdir reports
mkdir test-data
```

## 10. ❌ npm install Fails

### Error:
```
npm ERR! code EINTEGRITY
```

### Solution:
```cmd
# Clear cache and reinstall
npm cache clean --force
del package-lock.json
rmdir /s /q node_modules
npm install
```

## 🔍 Diagnostic Commands

### Check Everything:
```cmd
check-system.bat
```

### Check Appium Status:
```cmd
curl http://localhost:4723/wd/hub/status
```

### Check Android Devices:
```cmd
adb devices
```

### Check APK:
```cmd
check-apk.bat
```

### View ADB Logs:
```cmd
adb logcat
```

### View Appium Logs:
Check console where `start-appium.bat` is running

## 📋 Pre-Test Checklist

Before running tests, ensure:
- [ ] ✅ Appium server running (`start-appium.bat`)
- [ ] ✅ Android emulator/device connected (`adb devices`)
- [ ] ✅ Staging APK built and exists
- [ ] ✅ Dependencies installed (`npm install`)
- [ ] ✅ Directories created (screenshots, reports)

## 🆘 Still Having Issues?

### 1. Run full system check:
```cmd
check-system.bat
```

### 2. Check test output screenshots:
```cmd
explorer screenshots
```

### 3. Run visual demo to see what's happening:
```cmd
npm run test:demo
```

### 4. Check logs:
- Appium server console
- `adb logcat`
- Test console output

### 5. Try clean setup:
```cmd
# Clean everything
rmdir /s /q node_modules
del package-lock.json

# Reinstall
setup.bat

# Rebuild APK
build-staging-apk.bat
```
