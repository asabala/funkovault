$ErrorActionPreference = 'Stop'

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][scriptblock]$Command
    )

    Write-Host $Label
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path 'pubspec.yaml')) {
    throw 'Run validate_fix65.ps1 from the Flutter repository root.'
}

Invoke-Checked 'Formatting LiveLens sources/tests...' {
    dart format lib/atlas/live_sniffer test/atlas/live_sniffer
}

Invoke-Checked 'Running LiveLens + Scanner 6A tracking tests...' {
    flutter test test/atlas/live_sniffer test/atlas/scan/continuous test/atlas/scan/tracking
}

Invoke-Checked 'Running analyzer...' {
    flutter analyze --no-pub
}

$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host 'Compiling Android Kotlin...'
Push-Location android
try {
    & .\gradlew.bat :app:compileDebugKotlin
    if ($LASTEXITCODE -ne 0) {
        throw "Android Kotlin compile failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

Invoke-Checked 'Checking diff whitespace...' {
    git diff --check
}

Write-Host 'Fix 6.5 validation completed successfully.'
