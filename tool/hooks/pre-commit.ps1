# PowerShell pre-commit check script for tax_code_flutter
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🚀 [Pre-commit] Starting pre-commit quality checks..." -ForegroundColor Cyan
Write-Host ""

Write-Host "🎨 1/4 Checking Dart code formatting..." -ForegroundColor Yellow
dart format --output=none --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "  ✓ Dart formatting check passed." -ForegroundColor Green

Write-Host "🔤 2/4 Checking ARB files alphabetical ordering..." -ForegroundColor Yellow
dart run tool/arb_tool.dart check
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "  ✓ ARB files ordering check passed." -ForegroundColor Green

Write-Host "🔍 3/4 Validating ARB files (strict rules)..." -ForegroundColor Yellow
dart run tool/arb_tool.dart validate
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "  ✓ ARB validation check passed." -ForegroundColor Green

Write-Host "⚙️  4/5 Ensuring Firebase options stubs exist..." -ForegroundColor Yellow
dart run tool/setup_ci_stubs.dart | Out-Null

Write-Host "🛡️  5/5 Running Flutter analyze (--fatal-infos)..." -ForegroundColor Yellow
flutter analyze --fatal-infos
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "  ✓ Flutter analyze passed with 0 issues." -ForegroundColor Green

Write-Host ""
Write-Host "✅ [Pre-commit] All pre-commit quality checks passed successfully!" -ForegroundColor Green
Write-Host ""
