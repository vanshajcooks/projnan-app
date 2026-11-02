@echo off
echo =========================================================
echo     PROBON APP - PHASE 9 WEEKLY ARENA & GAMIFICATION     
echo =========================================================
echo.

set FLUTTER_CMD=flutter
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    if exist "C:\flutter\flutter\bin\flutter.bat" (
        set FLUTTER_CMD=C:\flutter\flutter\bin\flutter.bat
    ) else if exist "C:\flutter\flutter_windows_3.27.1-stable\flutter\bin\flutter.bat" (
        set FLUTTER_CMD=C:\flutter\flutter_windows_3.27.1-stable\flutter\bin\flutter.bat
    )
)

echo [1/2] Running Flutter static code analysis...
call %FLUTTER_CMD% analyze
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Static code analysis failed!
    exit /b %ERRORLEVEL%
)
echo [PASS] Code analysis passed with 0 issues!
echo.

echo [2/2] Running all automated tests (102 tests across all features)...
call %FLUTTER_CMD% test
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Some tests failed!
    exit /b %ERRORLEVEL%
)
echo [PASS] All 102 automated tests passed!
echo.

echo =========================================================
echo   [SUCCESS] PHASE 9 VERIFICATION COMPLETED SUCCESSFULLY!  
echo =========================================================
exit /b 0
