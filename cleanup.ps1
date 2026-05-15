param(
    [Parameter(Mandatory=$true)]
    [string]$Categories,

    [switch]$Force
)

$ErrorActionPreference = "SilentlyContinue"
$categoryIds = $Categories -split "," | ForEach-Object { $_.Trim() }

$results = @()
$totalFreed = 0

function Clear-Directory {
    param([string]$Path)
    $freed = 0
    if (-not (Test-Path $Path)) {
        return @{ freed = 0; skipped = 0; errors = 0 }
    }
    $skipped = 0
    $errors = 0
    $files = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        if ($file.PSIsContainer) { continue }
        try {
            $size = $file.Length
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            $freed += $size
        } catch {
            if ($_.Exception.Message -like "*being used*" -or $_.Exception.Message -like "*denied*") {
                $skipped++
            } else {
                $errors++
            }
        }
    }
    # Remove empty directories
    try {
        Get-ChildItem -Path $Path -Recurse -Directory -Force -ErrorAction SilentlyContinue |
            Sort-Object { $_.FullName.Length } -Descending |
            ForEach-Object {
                try {
                    if ((Get-ChildItem -Path $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                    }
                } catch {}
            }
    } catch {}
    return @{ freed = [math]::Round($freed / 1MB, 2); skipped = $skipped; errors = $errors }
}

function Clear-RecycleBin {
    $freed = 0
    $skipped = 0
    $binPath = "C:\`$Recycle.Bin"
    if (-not (Test-Path $binPath)) {
        return @{ freed = 0; skipped = 0; errors = 0 }
    }
    $files = Get-ChildItem -Path $binPath -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        if ($file.PSIsContainer) { continue }
        try {
            $size = $file.Length
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            $freed += $size
        } catch {
            $skipped++
        }
    }
    return @{ freed = [math]::Round($freed / 1MB, 2); skipped = $skipped; errors = 0 }
}

foreach ($id in $categoryIds) {
    switch ($id) {
        "1" {
            $r = Clear-Directory -Path "$env:SystemRoot\Temp"
            $results += [PSCustomObject]@{ id=1; name="System Temp"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "2" {
            $r = Clear-Directory -Path "$env:TEMP"
            $results += [PSCustomObject]@{ id=2; name="User Temp"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "3" {
            $r = Clear-Directory -Path "$env:SystemRoot\Prefetch"
            $results += [PSCustomObject]@{ id=3; name="Windows Prefetch"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "4" {
            $r = Clear-Directory -Path "$env:SystemRoot\SoftwareDistribution\Download"
            $results += [PSCustomObject]@{ id=4; name="Windows Update Cache"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "5" {
            $r = Clear-Directory -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
            $results += [PSCustomObject]@{ id=5; name="Thumbnail Cache"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "6" {
            $r = Clear-RecycleBin
            $results += [PSCustomObject]@{ id=6; name="Recycle Bin"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "7" {
            $r = Clear-Directory -Path "$env:LOCALAPPDATA\CrashDumps"
            $results += [PSCustomObject]@{ id=7; name="Crash Dumps"; freedMB=$r.freed; skipped=$r.skipped; errors=$r.errors }
            $totalFreed += $r.freed
        }
        "8" {
            $chrome = Clear-Directory -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
            $edge = Clear-Directory -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
            $totalCache = [math]::Round($chrome.freed + $edge.freed, 2)
            $results += [PSCustomObject]@{ id=8; name="Browser Cache"; freedMB=$totalCache; skipped=$chrome.skipped+$edge.skipped; errors=$chrome.errors+$edge.errors }
            $totalFreed += $totalCache
        }
    }
}

$totalFreed = [math]::Round($totalFreed, 2)
$output = @{
    totalFreedMB = $totalFreed
    results = $results
}

$output | ConvertTo-Json -Depth 3
