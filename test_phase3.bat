@echo off
echo =========================================================
echo       PROBON APP - PHASE 3 TEST VERIFICATION SUITE
echo =========================================================
echo.

echo [1/2] Running Flutter static code analysis...
call flutter analyze
if %errorlevel% neq 0 (
    echo [ERROR] Flutter analyze found issues.
    exit /b %errorlevel%
)
echo [PASS] Code analysis passed with zero issues!
echo.

echo [2/2] Running all automated tests (Dashboard, Projects, Tasks, Profile, Auth)...
call flutter test
if %errorlevel% neq 0 (
    echo [ERROR] Some tests failed.
    exit /b %errorlevel%
)
echo.
echo =========================================================
echo   [SUCCESS] ALL 55 PHASE 3 TESTS PASSED SUCCESSFULLY!
echo =========================================================
pause
