$ErrorActionPreference = 'Stop'

$targets = @(
    'lib/screens/scanner/scan_screen.dart',
    'lib/screens/scanner/atlas_live_sniffer_screen.dart'
)

foreach ($path in $targets) {
    if (-not (Test-Path $path)) {
        Write-Warning "Fix 6.5 UI rename skipped missing file: $path"
        continue
    }

    $before = Get-Content -Raw -LiteralPath $path
    $after = $before
    $after = $after.Replace('Android Live Sniffer', 'Atlas LiveLens')
    $after = $after.Replace('Atlas Live Sniffer', 'Atlas LiveLens')
    $after = $after.Replace('Start Live Sniffer', 'Start LiveLens')
    $after = $after -replace 'ATLAS LIVE(?!LENS)', 'ATLAS LIVELENS'

    if ($after -ne $before) {
        Set-Content -LiteralPath $path -Value $after -NoNewline -Encoding utf8
        Write-Host "Updated LiveLens labels in $path"
    } else {
        Write-Host "No old Live Sniffer labels found in $path"
    }
}

Write-Host 'Fix 6.5 LiveLens UI rename pass complete.'
