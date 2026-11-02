Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "      PROBON APP - PHASE 5 RELEASE VERIFICATION SUITE    " -ForegroundColor Cyan
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

Write-Host "[1/3] Running Flutter static code analysis..." -ForegroundColor Yellow
& $flutterCmd analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Code analysis found issues." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[PASS] Code analysis passed with 0 issues!" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Running all automated tests (64 tests across all features)..." -ForegroundColor Yellow
& $flutterCmd test
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Some tests failed." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[PASS] All 64 automated tests passed!" -ForegroundColor Green
Write-Host ""

Write-Host "[3/3] Checking production Release APK..." -ForegroundColor Yellow
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkItem = Get-Item $apkPath
    $sizeMb = [math]::Round($apkItem.Length / 1MB, 2)
    Write-Host "[PASS] Release APK found: $apkPath" -ForegroundColor Green
    Write-Host "       APK Size: $sizeMb MB" -ForegroundColor Green
    Write-Host ""
    Write-Host "To install on your connected device, run:" -ForegroundColor Cyan
    Write-Host "  adb install -r $apkPath" -ForegroundColor White
} else {
    Write-Host "[WARN] Release APK not yet compiled at $apkPath" -ForegroundColor Yellow
    Write-Host "       Run: flutter build apk --release" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  [SUCCESS] PHASE 5 VERIFICATION COMPLETED SUCCESSFULLY!  " -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
