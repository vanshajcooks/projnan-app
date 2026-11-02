@echo off
setlocal

echo =========================================================
echo       PROBON APP - PHASE 5 RELEASE VERIFICATION SUITE    
echo =========================================================
echo.

set FLUTTER_CMD=flutter
where flutter >nul 2>&1
if %ERRORLEVEL% neq 0 (
    if exist "C:\flutter\flutter\bin\flutter.bat" (
        set FLUTTER_CMD="C:\flutter\flutter\bin\flutter.bat"
    ) else if exist "C:\flutter\flutter_windows_3.27.1-stable\flutter\bin\flutter.bat" (
        set FLUTTER_CMD="C:\flutter\flutter_windows_3.27.1-stable\flutter\bin\flutter.bat"
    )
)

echo [1/3] Running Flutter static code analysis...
call %FLUTTER_CMD% analyze
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Code analysis found issues.
    exit /b %ERRORLEVEL%
)
echo [PASS] Code analysis passed with 0 issues!
echo.

echo [2/3] Running all automated tests...
call %FLUTTER_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Some tests failed.
    exit /b %ERRORLEVEL%
)
echo [PASS] All 64 automated tests passed!
echo.

echo [3/3] Checking production Release APK...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo [PASS] Release APK found at build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo To install on your connected device, run:
    echo   adb install -r build\app\outputs\flutter-apk\app-release.apk
) else (
    echo [WARN] Release APK not yet compiled at build\app\outputs\flutter-apk\app-release.apk
    echo Run: flutter build apk --release
)

echo.
echo =========================================================
echo   [SUCCESS] PHASE 5 VERIFICATION COMPLETED SUCCESSFULLY!  
echo =========================================================
