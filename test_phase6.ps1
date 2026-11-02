Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "      PROBON APP - PHASE 6 CREATION & CLASSES SUITE      " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

$flutterCmd = "flutter"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\flutter\flutter\bin\flutter.bat") {
        $flutterCmd = "C:\flutter\flutter\bin\flutter.bat"
    } elseif (Test-Path "C:\flutter\flutter_windows_3.27.1-stable\flutter\bin\flutter.bat") {
        $flutterCmd = "C:\flutter\flutter_windows_3.27.1-stable\flutter\bin\flutter.bat"
    }
}

Write-Host "[1/2] Running Flutter static code analysis..." -ForegroundColor Yellow
& $flutterCmd analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Code analysis found issues." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[PASS] Code analysis passed with 0 issues!" -ForegroundColor Green
Write-Host ""

Write-Host "[2/2] Running all automated tests (72 tests across all features)..." -ForegroundColor Yellow
& $flutterCmd test
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Some tests failed." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[PASS] All 72 automated tests passed!" -ForegroundColor Green
Write-Host ""

Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  [SUCCESS] PHASE 6 VERIFICATION COMPLETED SUCCESSFULLY!  " -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
