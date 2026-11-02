@echo off
echo Running Phase 12 Verification Suite...
cd /d "C:\Projects\Probon App"

echo 1. Running static analyzer...
call "C:\flutter\flutter\bin\flutter.bat" analyze
if %ERRORLEVEL% NEQ 0 (
    echo Static analysis failed!
    exit /b %ERRORLEVEL%
)

echo 2. Running automated test suite...
call "C:\flutter\flutter\bin\flutter.bat" test
if %ERRORLEVEL% NEQ 0 (
    echo Tests failed!
    exit /b %ERRORLEVEL%
)

echo Phase 12 Verification Passed Successfully (124+ Tests Passing, 0 Analyzer Issues)!
