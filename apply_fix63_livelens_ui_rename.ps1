$ErrorActionPreference = 'Stop'

$targets = @(
    'lib/screens/scanner/scan_screen.dart',
    'lib/screens/scanner/atlas_live_sniffer_screen.dart'
)

$replacements = [ordered]@{
    'Android Live Sniffer' = 'Atlas LiveLens'
    'Atlas Live Sniffer'   = 'Atlas LiveLens'
    'Start Live Sniffer'   = 'Start LiveLens'
    'ATLAS LIVE'           = 'ATLAS LIVELENS'
}

foreach ($path in $targets) {
    if (-not (Test-Path $path)) {
        Write-Warning "Fix 6.3 UI rename skipped missing file: $path"
        continue
    }

    $before = Get-Content -Raw -LiteralPath $path
    $after = $before
    foreach ($entry in $replacements.GetEnumerator()) {
        $after = $after.Replace($entry.Key, $entry.Value)
    }

    if ($after -ne $before) {
        Set-Content -LiteralPath $path -Value $after -NoNewline -Encoding utf8
        Write-Host "Updated LiveLens labels in $path"
    } else {
        Write-Host "No old Live Sniffer labels found in $path"
    }
}

Write-Host 'Fix 6.3 LiveLens UI rename pass complete.'
