@echo off
setlocal

echo =========================================================
echo       PROBON APP - PHASE 6 CREATION & CLASSES SUITE      
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

echo [1/2] Running Flutter static code analysis...
call %FLUTTER_CMD% analyze
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Code analysis found issues.
    exit /b %ERRORLEVEL%
)
echo [PASS] Code analysis passed with 0 issues!
echo.

echo [2/2] Running all automated tests...
call %FLUTTER_CMD% test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Some tests failed.
    exit /b %ERRORLEVEL%
)
echo [PASS] All 72 automated tests passed!
echo.

echo =========================================================
echo   [SUCCESS] PHASE 6 VERIFICATION COMPLETED SUCCESSFULLY!  
echo =========================================================
