# Windows Program Inventory Script
# This script lists all installed programs and their installation paths
# and generates a report.

# Set output file path
$outputFile = "$env:USERPROFILE\Desktop\InstalledPrograms.txt"
$csvOutputFile = "$env:USERPROFILE\Desktop\InstalledPrograms.csv"

Write-Host "Scanning installed programs..." -ForegroundColor Green

# Initialize arrays to store program information
$allPrograms = @()

# Function to get programs from registry
function Get-InstalledPrograms {
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $programs = @()
    
    foreach ($path in $registryPaths) {
        try {
            $items = Get-ItemProperty $path -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                if ($item.DisplayName -and $item.DisplayName -notmatch "^(KB|Security Update|Update for|Hotfix)") {
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
        catch {
            Write-Warning "Could not access registry path: $path"
        }
    }
    
    return $programs
}

# Function to get Windows Store apps
function Get-WindowsStoreApps {
    try {
        $storeApps = Get-AppxPackage | Where-Object { $_.SignatureKind -eq "Store" } | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Version = $_.Version
                Publisher = $_.Publisher
                InstallLocation = $_.InstallLocation
                InstallDate = ""
                Size = ""
                UninstallString = "Windows Store App"
                Source = "Windows Store"
            }
        }
        return $storeApps
    }
    catch {
        Write-Warning "Could not retrieve Windows Store apps"
        return @()
    }
}

# Function to get programs from Programs and Features
function Get-ProgramsAndFeatures {
    try {
        $programs = Get-WmiObject -Class Win32_Product | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Version = $_.Version
                Publisher = $_.Vendor
                InstallLocation = $_.InstallLocation
                InstallDate = $_.InstallDate
                Size = ""
                UninstallString = "WMI"
                Source = "Win32_Product"
            }
        }
        return $programs
    }
    catch {
        Write-Warning "Could not retrieve programs via WMI"
        return @()
    }
}

Write-Host "Getting programs from registry..." -ForegroundColor Yellow
$registryPrograms = Get-InstalledPrograms

Write-Host "Getting Windows Store apps..." -ForegroundColor Yellow
$storeApps = Get-WindowsStoreApps

Write-Host "Getting programs via WMI (this may take a while)..." -ForegroundColor Yellow
$wmiPrograms = Get-ProgramsAndFeatures

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
$textReport = @"
=== INSTALLED PROGRAMS INVENTORY ===
Generated on: $(Get-Date)
Total Programs Found: $($uniquePrograms.Count)

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
Write-Host "`nPrograms by drive summary:" -ForegroundColor Yellow

# Display quick summary
$uniquePrograms | Where-Object { $_.InstallLocation } | 
Group-Object { ($_.InstallLocation -split ':')[0] + ':' } | 
Sort-Object Name | ForEach-Object {
    Write-Host "  $($_.Name) - $($_.Count) programs" -ForegroundColor White
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")