$ErrorActionPreference = "SilentlyContinue"
$logPath = "C:\Users\MSI-PC\.claude\skills\c-drive-cleanup\cleanup_result.txt"

# Clean C:\Windows\Temp
$freed = 0
$skipped = 0
$path = "C:\Windows\Temp"

$files = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer }

foreach ($file in $files) {
    try {
        $freed += $file.Length
        Remove-Item -Path $file.FullName -Force -ErrorAction Stop
    } catch {
        $skipped++
    }
}

# Remove empty directories
Get-ChildItem -Path $path -Recurse -Directory -Force -ErrorAction SilentlyContinue |
    Sort-Object { $_.FullName.Length } -Descending |
    ForEach-Object {
        try {
            if ((Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
            }
        } catch {}
    }

$freedMB = [math]::Round($freed / 1MB, 2)
$result = "DONE: freed $freedMB MB, skipped $skipped locked files"
$result | Out-File -FilePath $logPath -Encoding utf8
Write-Host $result
