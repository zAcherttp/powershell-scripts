# Windows Program Inventory Script
# This script lists all installed programs and their installation paths
# and generates a report with drive selection options.

# Function to display drive selection menu
function Show-DriveSelectionMenu {
    Write-Host "`n=== DRIVE SELECTION MENU ===" -ForegroundColor Cyan
    Write-Host "Choose which drive(s) to analyze for installed programs:" -ForegroundColor White
    
    # Get available drives
    $drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Sort-Object DeviceID
    
    $driveOptions = @()
    $index = 1
    
    foreach ($drive in $drives) {
        $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
        $totalSpaceGB = [math]::Round($drive.Size / 1GB, 2)
        Write-Host "$index`: $($drive.DeviceID) ($totalSpaceGB GB total, $freeSpaceGB GB free)" -ForegroundColor Yellow
        $driveOptions += $drive.DeviceID
        $index++
    }
    
    Write-Host "A: All drives" -ForegroundColor Green
    Write-Host "`nEnter your choice (number or 'A' for all): " -ForegroundColor White -NoNewline
    
    return $driveOptions
}

# Show drive selection menu and get user choice
$availableDrives = Show-DriveSelectionMenu
$userChoice = Read-Host

# Process user selection
$selectedDrives = @()
if ($userChoice.ToUpper() -eq "A") {
    $selectedDrives = $availableDrives
    Write-Host "`nSelected: All drives ($($selectedDrives -join ', '))" -ForegroundColor Green
} elseif ($userChoice -match '^\d+$' -and [int]$userChoice -ge 1 -and [int]$userChoice -le $availableDrives.Count) {
    $selectedDrives = @($availableDrives[[int]$userChoice - 1])
    Write-Host "`nSelected: $($selectedDrives[0])" -ForegroundColor Green
} else {
    Write-Host "`nInvalid selection. Defaulting to all drives." -ForegroundColor Red
    $selectedDrives = $availableDrives
}

# Set output file paths with drive info
$driveInfo = if ($selectedDrives.Count -eq $availableDrives.Count) { "AllDrives" } else { ($selectedDrives -replace ':', '') -join '_' }
$outputFile = "$env:USERPROFILE\Desktop\InstalledPrograms_$driveInfo.txt"
$csvOutputFile = "$env:USERPROFILE\Desktop\InstalledPrograms_$driveInfo.csv"

Write-Host "`nScanning installed programs on selected drive(s)..." -ForegroundColor Green

# Function to calculate drive sizes with progress
function Get-DriveAnalysis {
    param([string[]]$Drives)
    
    Write-Host "`n=== DRIVE ANALYSIS ===" -ForegroundColor Cyan
    $driveInfo = @()
    $totalScanned = 0
    
    foreach ($drive in $Drives) {
        Write-Progress -Activity "Analyzing Drives" -Status "Scanning drive $drive..." -PercentComplete (($Drives.IndexOf($drive) / $Drives.Count) * 100)
        
        try {
            $driveObj = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $drive }
            if ($driveObj) {
                $totalGB = [math]::Round($driveObj.Size / 1GB, 2)
                $freeGB = [math]::Round($driveObj.FreeSpace / 1GB, 2)
                $usedGB = $totalGB - $freeGB
                
                $driveInfo += [PSCustomObject]@{
                    Drive = $drive
                    TotalGB = $totalGB
                    UsedGB = $usedGB
                    FreeGB = $freeGB
                    PercentUsed = [math]::Round(($usedGB / $totalGB) * 100, 1)
                }
                
                $totalScanned += $totalGB
                Write-Host "Drive $drive`: $usedGB GB used / $totalGB GB total ($([math]::Round(($usedGB / $totalGB) * 100, 1))% used)" -ForegroundColor White
            }
        }
        catch {
            Write-Warning "Could not analyze drive $drive"
        }
    }
    
    Write-Progress -Activity "Analyzing Drives" -Completed
    Write-Host "Total drive space being scanned: $([math]::Round($totalScanned, 2)) GB" -ForegroundColor Yellow
    Write-Host ""
    
    return $driveInfo
}

# Analyze selected drives
$driveAnalysis = Get-DriveAnalysis -Drives $selectedDrives

# Initialize arrays to store program information
$allPrograms = @()

# Function to get programs from registry with drive filtering
function Get-InstalledPrograms {
    param([string[]]$FilterDrives)
    
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $programs = @()
    $totalPaths = $registryPaths.Count
    $processedPaths = 0
    
    Write-Host "Scanning registry locations for installed programs..." -ForegroundColor Yellow
    
    foreach ($path in $registryPaths) {
        $processedPaths++
        $percent = [math]::Round($processedPaths / $totalPaths * 100, 1)
        Write-Progress -Activity "Scanning Registry" -Status "Processing registry path $processedPaths of $totalPaths" -PercentComplete $percent
        
        try {
            $items = Get-ItemProperty $path -ErrorAction SilentlyContinue
            $itemCount = 0
            $totalItems = $items.Count
            
            foreach ($item in $items) {
                $itemCount++
                if ($itemCount % 50 -eq 0) {
                    Write-Progress -Activity "Scanning Registry" -Status "Processing $itemCount of $totalItems entries in current path" -PercentComplete ([math]::Round($itemCount / $totalItems * 100, 1))
                }
                
                if ($item.DisplayName -and $item.DisplayName -notmatch "^(KB|Security Update|Update for|Hotfix)") {
                    # Filter by drive if InstallLocation is available
                    $includeProgram = $true
                    if ($item.InstallLocation -and $FilterDrives.Count -gt 0) {
                        $programDrive = ($item.InstallLocation -split ':')[0] + ':'
                        $includeProgram = $programDrive -in $FilterDrives
                    }
                    
                    if ($includeProgram) {
                        $programs += [PSCustomObject]@{
                            Name = $item.DisplayName
                            Version = $item.DisplayVersion
                            Publisher = $item.Publisher
                            InstallLocation = $item.InstallLocation
                            InstallDate = $item.InstallDate
                            Size = $item.EstimatedSize
                            UninstallString = $item.UninstallString
                            Source = "Registry"
                        }
                    }
                }
            }
        }
        catch {
            Write-Warning "Could not access registry path: $path"
        }
    }
    
    Write-Progress -Activity "Scanning Registry" -Completed
    return $programs
}

# Function to get Windows Store apps with drive filtering
function Get-WindowsStoreApps {
    param([string[]]$FilterDrives)
    
    Write-Host "Scanning Windows Store apps..." -ForegroundColor Yellow
    
    try {
        $allStoreApps = Get-AppxPackage | Where-Object { $_.SignatureKind -eq "Store" }
        $storeApps = @()
        $appCount = 0
        $totalApps = $allStoreApps.Count
        
        foreach ($app in $allStoreApps) {
            $appCount++
            if ($appCount % 10 -eq 0) {
                $percent = [math]::Round($appCount / $totalApps * 100, 1)
                Write-Progress -Activity "Scanning Windows Store Apps" -Status "Processing $appCount of $totalApps apps" -PercentComplete $percent
            }
            
            # Filter by drive if InstallLocation is available
            $includeApp = $true
            if ($app.InstallLocation -and $FilterDrives.Count -gt 0) {
                $appDrive = ($app.InstallLocation -split ':')[0] + ':'
                $includeApp = $appDrive -in $FilterDrives
            }
            
            if ($includeApp) {
                $storeApps += [PSCustomObject]@{
                    Name = $app.Name
                    Version = $app.Version
                    Publisher = $app.Publisher
                    InstallLocation = $app.InstallLocation
                    InstallDate = ""
                    Size = ""
                    UninstallString = "Windows Store App"
                    Source = "Windows Store"
                }
            }
        }
        
        Write-Progress -Activity "Scanning Windows Store Apps" -Completed
        return $storeApps
    }
    catch {
        Write-Warning "Could not retrieve Windows Store apps"
        return @()
    }
}

# Function to get programs from Programs and Features with drive filtering
function Get-ProgramsAndFeatures {
    param([string[]]$FilterDrives)
    
    Write-Host "Scanning via WMI (this may take a while)..." -ForegroundColor Yellow
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $allWmiPrograms = Get-WmiObject -Class Win32_Product
        $programs = @()
        $programCount = 0
        $totalPrograms = $allWmiPrograms.Count
        
        foreach ($wmiProgram in $allWmiPrograms) {
            $programCount++
            $elapsedSeconds = $stopwatch.Elapsed.TotalSeconds
            $speed = if ($elapsedSeconds -gt 0) { $programCount / $elapsedSeconds } else { 0 }
            
            if ($programCount % 5 -eq 0) {
                $percent = [math]::Round($programCount / $totalPrograms * 100, 1)
                $statusText = "Processing $programCount of $totalPrograms programs ($([math]::Round($speed, 1)) programs/sec)"
                Write-Progress -Activity "Scanning WMI Programs" -Status $statusText -PercentComplete $percent
            }
            
            # Filter by drive if InstallLocation is available
            $includeProgram = $true
            if ($wmiProgram.InstallLocation -and $FilterDrives.Count -gt 0) {
                $programDrive = ($wmiProgram.InstallLocation -split ':')[0] + ':'
                $includeProgram = $programDrive -in $FilterDrives
            }
            
            if ($includeProgram) {
                $programs += [PSCustomObject]@{
                    Name = $wmiProgram.Name
                    Version = $wmiProgram.Version
                    Publisher = $wmiProgram.Vendor
                    InstallLocation = $wmiProgram.InstallLocation
                    InstallDate = $wmiProgram.InstallDate
                    Size = ""
                    UninstallString = "WMI"
                    Source = "Win32_Product"
                }
            }
        }
        
        Write-Progress -Activity "Scanning WMI Programs" -Completed
        $stopwatch.Stop()
        return $programs
    }
    catch {
        Write-Warning "Could not retrieve programs via WMI"
        return @()
    }
}

Write-Host "Getting programs from registry..." -ForegroundColor Yellow
$registryPrograms = Get-InstalledPrograms -FilterDrives $selectedDrives

Write-Host "Getting Windows Store apps..." -ForegroundColor Yellow
$storeApps = Get-WindowsStoreApps -FilterDrives $selectedDrives

Write-Host "Getting programs via WMI (this may take a while)..." -ForegroundColor Yellow
$wmiPrograms = Get-ProgramsAndFeatures -FilterDrives $selectedDrives

# Combine all programs
$allPrograms = $registryPrograms + $storeApps + $wmiPrograms

# Remove duplicates and sort
$uniquePrograms = $allPrograms | Sort-Object Name | Group-Object Name | ForEach-Object {
    # Take the entry with the most complete information
    $_.Group | Sort-Object { 
        ($_.InstallLocation -ne $null -and $_.InstallLocation -ne "") + 
        ($_.Version -ne $null -and $_.Version -ne "") + 
        ($_.Publisher -ne $null -and $_.Publisher -ne "")
    } -Descending | Select-Object -First 1
}

# Generate text report
$selectedDrivesList = $selectedDrives -join ', '
$driveAnalysisText = $driveAnalysis | ForEach-Object {
    "Drive $($_.Drive): $($_.UsedGB) GB used / $($_.TotalGB) GB total ($($_.PercentUsed)% used)"
} | Out-String

$textReport = @"
=== INSTALLED PROGRAMS INVENTORY ===
Generated on: $(Get-Date)
Selected Drive(s): $selectedDrivesList
Total Programs Found: $($uniquePrograms.Count)

=== DRIVE ANALYSIS ===
$driveAnalysisText

$(foreach ($program in $uniquePrograms) {
    "Program: $($program.Name)"
    "Version: $($program.Version)"
    "Publisher: $($program.Publisher)"
    "Install Location: $($program.InstallLocation)"
    "Install Date: $($program.InstallDate)"
    "Source: $($program.Source)"
    "----------------------------------------"
})

=== PROGRAMS BY DRIVE ===
$(
    $uniquePrograms | Where-Object { $_.InstallLocation } | 
    Group-Object { ($_.InstallLocation -split ':')[0] + ':' } | 
    Sort-Object Name | ForEach-Object {
        "Drive $($_.Name) - $($_.Count) programs"
        $_.Group | Sort-Object Name | ForEach-Object {
            "  - $($_.Name) ($($_.InstallLocation))"
        }
        ""
    }
)

=== SUMMARY BY PUBLISHER ===
$(
    $uniquePrograms | Where-Object { $_.Publisher } | 
    Group-Object Publisher | 
    Sort-Object Count -Descending | 
    Select-Object -First 20 | ForEach-Object {
        "$($_.Name): $($_.Count) programs"
    }
)
"@

# Save text report
$textReport | Out-File -FilePath $outputFile -Encoding UTF8

# Save CSV report
$uniquePrograms | Export-Csv -Path $csvOutputFile -NoTypeInformation -Encoding UTF8

Write-Host "`nReports generated successfully!" -ForegroundColor Green
Write-Host "Text report: $outputFile" -ForegroundColor Cyan
Write-Host "CSV report: $csvOutputFile" -ForegroundColor Cyan

Write-Host "`nDrive analysis summary:" -ForegroundColor Yellow
foreach ($drive in $driveAnalysis) {
    Write-Host "  $($drive.Drive) - $($drive.UsedGB) GB used / $($drive.TotalGB) GB total ($($drive.PercentUsed)% used)" -ForegroundColor White
}

Write-Host "`nPrograms by drive summary (selected drives: $selectedDrivesList):" -ForegroundColor Yellow

# Display quick summary
$uniquePrograms | Where-Object { $_.InstallLocation } | 
Group-Object { ($_.InstallLocation -split ':')[0] + ':' } | 
Sort-Object Name | ForEach-Object {
    Write-Host "  $($_.Name) - $($_.Count) programs" -ForegroundColor White
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")