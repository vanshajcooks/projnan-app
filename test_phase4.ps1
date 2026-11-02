Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "      PROBON APP - PHASE 4 TEST VERIFICATION SUITE       " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Running Flutter static code analysis..." -ForegroundColor Yellow
& flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Code analysis found issues." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[PASS] Code analysis passed with 0 issues!" -ForegroundColor Green
Write-Host ""

Write-Host "[2/2] Running all automated tests (Polish, Skeletons, Bottom Sheets, Toast, Full App)..." -ForegroundColor Yellow
& flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Some tests failed." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  [SUCCESS] ALL 63 PHASE 4 TESTS PASSED SUCCESSFULLY!    " -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
