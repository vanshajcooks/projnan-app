@echo off
echo =========================================================
echo       PROBON APP - PHASE 1 TEST VERIFICATION SUITE
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

echo [2/2] Running automated test suite (Network, Storage, Models, UI)...
call flutter test
if %errorlevel% neq 0 (
    echo [ERROR] Some tests failed.
    exit /b %errorlevel%
)
echo.
echo =========================================================
echo   [SUCCESS] ALL PHASE 1 TESTS PASSED SUCCESSFULLY!
echo =========================================================
pause
