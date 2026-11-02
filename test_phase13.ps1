Write-Host "Running Phase 13 Verification Suite (Milestone Progression, Reset Password, Task Search, Project Settings)..." -ForegroundColor Cyan
Set-Location "C:\Projects\Probon App"

Write-Host "1. Running static analyzer..." -ForegroundColor Yellow
& "C:\flutter\flutter\bin\flutter.bat" analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "Static analysis failed!" -ForegroundColor Red
    exit 1
}

Write-Host "2. Running 129+ automated tests..." -ForegroundColor Yellow
& "C:\flutter\flutter\bin\flutter.bat" test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Phase 13 Verification Passed Successfully (129+ Tests Passing, 0 Analyzer Issues)!" -ForegroundColor Green
