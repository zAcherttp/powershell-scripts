<#
.SYNOPSIS
    Cleans up web development directories by removing node_modules, build outputs, and cache directories.

.DESCRIPTION
    This script recursively searches through a specified web development directory and removes:
    - All node_modules directories (npm/yarn dependencies)
    - Build output directories (build, dist, .next, .nuxt, out)
    - Cache and temporary directories (.cache, .temp, .tmp, tmp, cache)
    
    The script provides progress feedback and a summary of cleaned directories and disk space freed.

.PARAMETER Path
    The root path to search for web development directories. Defaults to "e:\web".

.PARAMETER WhatIf
    Shows what would be deleted without actually deleting anything.

.PARAMETER Force
    Bypasses confirmation prompts and proceeds with deletion.

.PARAMETER IncludeCache
    Also removes cache and temporary directories. Default is $true.

.EXAMPLE
    .\Clean-WebDevDirectories.ps1
    
    Cleans up the default e:\web directory with confirmation prompts.

.EXAMPLE
    .\Clean-WebDevDirectories.ps1 -Path "C:\Projects" -Force
    
    Cleans up C:\Projects directory without confirmation prompts.

.EXAMPLE
    .\Clean-WebDevDirectories.ps1 -WhatIf
    
    Shows what would be cleaned without actually deleting anything.

.NOTES
    Author: AI Generated PowerShell Script
    Version: 1.0
    Created: July 18, 2025
    
    WARNING: This script permanently deletes files and directories. Use with caution!
    It's recommended to run with -WhatIf first to see what will be deleted.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = "e:\web",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeCache
)

# Color functions for better output
function Write-ColorText {
    param(
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Text
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-ColorText "=" * 60 -Color Cyan
    Write-ColorText "  $Title" -Color Yellow
    Write-ColorText "=" * 60 -Color Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-ColorText "✅ $Message" -Color Green
}

function Write-Warning {
    param([string]$Message)
    Write-ColorText "⚠️  $Message" -Color Yellow
}

function Write-Error {
    param([string]$Message)
    Write-ColorText "❌ $Message" -Color Red
}

function Write-Info {
    param([string]$Message)
    Write-ColorText "ℹ️  $Message" -Color Cyan
}

# Function to format file size
function Format-FileSize {
    param([long]$Size)
    
    if ($Size -gt 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    }
    elseif ($Size -gt 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    }
    elseif ($Size -gt 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    }
    else {
        return "$Size bytes"
    }
}

# Function to get directory size
function Get-DirectorySize {
    param([string]$DirectoryPath)
    
    try {
        $size = (Get-ChildItem -Path $DirectoryPath -Recurse -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum
        return $size
    }
    catch {
        return 0
    }
}

# Function to find directories by name
function Find-DirectoriesByName {
    param(
        [string]$RootPath,
        [string[]]$DirectoryNames,
        [string]$ExcludePattern = $null
    )
    
    $foundDirectories = @()
    
    try {
        $allDirectories = Get-ChildItem -Path $RootPath -Recurse -Directory -ErrorAction SilentlyContinue
        
        foreach ($dir in $allDirectories) {
            if ($DirectoryNames -contains $dir.Name) {
                if ($ExcludePattern -and $dir.FullName -like $ExcludePattern) {
                    continue
                }
                $foundDirectories += $dir
            }
        }
    }
    catch {
        Write-Warning "Error searching in path: $RootPath"
    }
    
    return $foundDirectories
}

# Function to remove directories with progress
function Remove-DirectoriesWithProgress {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [array]$Directories,
        [string]$Type
    )
    
    $totalCount = $Directories.Count
    $removedCount = 0
    $totalSizeFreed = 0
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    if ($totalCount -eq 0) {
        Write-Info "No $Type directories found."
        return @{ RemovedCount = 0; SizeFreed = 0 }
    }
    
    Write-Info "Found $totalCount $Type directories to clean..."
    
    # Pre-calculate sizes for better progress reporting
    Write-Host "Calculating directory sizes..." -ForegroundColor Gray
    $directorySizes = @{}
    $totalSize = 0
    
    for ($i = 0; $i -lt $Directories.Count; $i++) {
        $dir = $Directories[$i]
        $dirSize = Get-DirectorySize -DirectoryPath $dir.FullName
        $directorySizes[$dir.FullName] = $dirSize
        $totalSize += $dirSize
        
        $percent = [math]::Round(($i + 1) / $totalCount * 100, 1)
        Write-Progress -Activity "Calculating sizes for $Type directories" -Status "Processing $($i + 1) of $totalCount" -PercentComplete $percent
    }
    Write-Progress -Activity "Calculating sizes" -Completed
    
    foreach ($dir in $Directories) {
        $dirSize = $directorySizes[$dir.FullName]
        $currentPercent = if ($totalCount -gt 0) { [math]::Round($removedCount / $totalCount * 100, 1) } else { 0 }
        $elapsedSeconds = $stopwatch.Elapsed.TotalSeconds
        $speed = if ($elapsedSeconds -gt 0) { $totalSizeFreed / $elapsedSeconds } else { 0 }
        
        $progressStatus = "Removed $removedCount of $totalCount directories [$(Format-FileSize $totalSizeFreed) of $(Format-FileSize $totalSize) ($(Format-FileSize $speed)/s)]"
        Write-Progress -Activity "Cleaning $Type directories" -Status $progressStatus -PercentComplete $currentPercent
        
        if ($PSCmdlet.ShouldProcess($dir.FullName, "Remove Directory")) {
            try {
                Write-Host "Removing: $($dir.FullName)" -ForegroundColor Gray
                Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction Stop
                $removedCount++
                $totalSizeFreed += $dirSize
            }
            catch {
                Write-Error "Failed to remove: $($dir.FullName) - $($_.Exception.Message)"
            }
        }
    }
    
    Write-Progress -Activity "Cleaning $Type directories" -Completed
    $stopwatch.Stop()
    
    return @{ 
        RemovedCount = $removedCount
        SizeFreed = $totalSizeFreed
    }
}

# Main script execution
try {
    Write-Header "Web Development Directory Cleanup Tool"
    
    # Validate path
    if (-not (Test-Path -Path $Path)) {
        Write-Error "Path does not exist: $Path"
        exit 1
    }
    
    Write-Info "Scanning directory: $Path"
    
    # Get initial directory size
    $initialSize = Get-DirectorySize -DirectoryPath $Path
    Write-Info "Initial directory size: $(Format-FileSize $initialSize)"
    
    # Define directory types to clean
    $nodeModulesNames = @("node_modules")
    $buildDirectoryNames = @("build", "dist", ".next", ".nuxt", "out")
    $cacheDirectoryNames = @(".cache", ".temp", ".tmp", "tmp", "cache")
    
    # Find directories
    Write-Header "Scanning for directories to clean..."
    
    Write-Info "Searching for node_modules directories..."
    $nodeModulesDirs = Find-DirectoriesByName -RootPath $Path -DirectoryNames $nodeModulesNames -ExcludePattern "*node_modules*node_modules*"
    
    Write-Info "Searching for build output directories..."
    $buildDirs = Find-DirectoriesByName -RootPath $Path -DirectoryNames $buildDirectoryNames -ExcludePattern "*node_modules*"
    
    if ($IncludeCache.IsPresent) {
        Write-Info "Searching for cache directories..."
        $cacheDirs = Find-DirectoriesByName -RootPath $Path -DirectoryNames $cacheDirectoryNames -ExcludePattern "*node_modules*"
    }
    else {
        $cacheDirs = @()
    }
    
    # Summary of what will be cleaned
    Write-Header "Cleanup Summary"
    Write-Info "node_modules directories found: $($nodeModulesDirs.Count)"
    Write-Info "Build output directories found: $($buildDirs.Count)"
    if ($IncludeCache.IsPresent) {
        Write-Info "Cache directories found: $($cacheDirs.Count)"
    }
    
    $totalDirectories = $nodeModulesDirs.Count + $buildDirs.Count + $cacheDirs.Count
    
    if ($totalDirectories -eq 0) {
        Write-Success "No directories found to clean!"
        exit 0
    }
    
    # Confirmation prompt (unless -Force is used)
    if (-not $Force -and -not $WhatIfPreference) {
        Write-Warning "This will permanently delete $totalDirectories directories."
        $confirmation = Read-Host "Do you want to continue? (y/N)"
        if ($confirmation -notmatch '^[yY]') {
            Write-Info "Operation cancelled by user."
            exit 0
        }
    }
    
    # Start cleanup
    Write-Header "Starting Cleanup Process"
    
    $results = @{
        NodeModules = @{ RemovedCount = 0; SizeFreed = 0 }
        BuildDirs = @{ RemovedCount = 0; SizeFreed = 0 }
        CacheDirs = @{ RemovedCount = 0; SizeFreed = 0 }
    }
    
    # Clean node_modules directories
    if ($nodeModulesDirs.Count -gt 0) {
        Write-Info "Cleaning node_modules directories..."
        $results.NodeModules = Remove-DirectoriesWithProgress -Directories $nodeModulesDirs -Type "node_modules"
    }
    
    # Clean build directories
    if ($buildDirs.Count -gt 0) {
        Write-Info "Cleaning build output directories..."
        $results.BuildDirs = Remove-DirectoriesWithProgress -Directories $buildDirs -Type "build output"
    }
    
    # Clean cache directories
    if ($cacheDirs.Count -gt 0 -and $IncludeCache.IsPresent) {
        Write-Info "Cleaning cache directories..."
        $results.CacheDirs = Remove-DirectoriesWithProgress -Directories $cacheDirs -Type "cache"
    }
    
    # Final summary
    Write-Header "Cleanup Complete!"
    
    $totalRemoved = $results.NodeModules.RemovedCount + $results.BuildDirs.RemovedCount + $results.CacheDirs.RemovedCount
    $totalSizeFreed = $results.NodeModules.SizeFreed + $results.BuildDirs.SizeFreed + $results.CacheDirs.SizeFreed
    
    Write-Success "Directories cleaned:"
    Write-Host "  • node_modules: $($results.NodeModules.RemovedCount) directories" -ForegroundColor White
    Write-Host "  • Build outputs: $($results.BuildDirs.RemovedCount) directories" -ForegroundColor White
    if ($IncludeCache.IsPresent) {
        Write-Host "  • Cache dirs: $($results.CacheDirs.RemovedCount) directories" -ForegroundColor White
    }
    
    Write-Success "Total directories removed: $totalRemoved"
    Write-Success "Estimated disk space freed: $(Format-FileSize $totalSizeFreed)"
    
    # Get final directory size
    $finalSize = Get-DirectorySize -DirectoryPath $Path
    $actualSizeFreed = $initialSize - $finalSize
    
    Write-Info "Directory size before: $(Format-FileSize $initialSize)"
    Write-Info "Directory size after: $(Format-FileSize $finalSize)"
    Write-Success "Actual disk space freed: $(Format-FileSize $actualSizeFreed)"
    
    Write-ColorText "`n🎉 Your web development projects are now clean and ready for fresh installs!" -Color Green
}
catch {
    Write-Error "An error occurred during cleanup: $($_.Exception.Message)"
    exit 1
}
