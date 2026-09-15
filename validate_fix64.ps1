$ErrorActionPreference = 'Stop'

if (-not (Test-Path 'pubspec.yaml')) {
    throw 'Run validate_fix64.ps1 from the Flutter repository root.'
}

Write-Host 'Formatting LiveLens sources/tests...'
dart format lib/atlas/live_sniffer test/atlas/live_sniffer

Write-Host 'Running LiveLens + Scanner 6A tracking tests...'
flutter test test/atlas/live_sniffer test/atlas/scan/continuous test/atlas/scan/tracking

Write-Host 'Running analyzer...'
flutter analyze --no-pub

$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host 'Compiling Android Kotlin...'
Push-Location android
try {
    .\gradlew.bat :app:compileDebugKotlin
} finally {
    Pop-Location
}

Write-Host 'Checking diff whitespace...'
git diff --check

Write-Host 'Fix 6.4 validation completed successfully.'
