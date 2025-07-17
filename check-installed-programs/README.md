# Check Installed Programs

A comprehensive Windows program inventory tool that scans registry, Windows Store apps, and WMI for installed programs with drive analysis and dynamic progress tracking.

## 🎯 Purpose

This script provides a complete inventory of installed programs on Windows systems by scanning multiple sources:

- Windows Registry (installed programs)
- Windows Store applications
- WMI (Windows Management Instrumentation) queries
- Drive space analysis with detailed reporting

## ✨ Key Features

- **Multi-Source Scanning**: Comprehensive program detection from registry, Windows Store, and WMI
- **Drive Analysis**: Shows GB scanned per drive with usage percentages
- **Progress Tracking**: Real-time progress bars for all scanning operations
- **Speed Monitoring**: WMI scanning includes speed calculation (programs/sec)
- **Interactive Drive Selection**: Choose specific drives for targeted scanning
- **Duplicate Removal**: Consolidates information and removes duplicate entries
- **Multiple Export Formats**: Generates both text and CSV reports
- **Comprehensive Error Handling**: Graceful handling of inaccessible drives and registry keys

## 📊 Output Reports

The script generates detailed reports in multiple formats:

### Text Report

- **Location**: `%USERPROFILE%\Desktop\InstalledPrograms.txt`
- **Contains**: Human-readable program list with details
- **Features**: Organized by publisher, includes program counts

### CSV Report

- **Location**: `%USERPROFILE%\Desktop\InstalledPrograms.csv`
- **Contains**: Structured data for analysis
- **Fields**: Program Name, Publisher, Version, Install Date, Location

## 🚀 Usage

### Basic Usage

```powershell
# Run with interactive drive selection
.\check_installed_programs.ps1
```

### What You'll See

1. **Drive Selection Menu**: Choose which drives to scan
2. **Registry Scanning**: Progress through multiple registry paths
3. **Windows Store Apps**: Enumerate installed store applications
4. **WMI Detection**: Scan with speed tracking (programs/sec)
5. **Drive Analysis**: Real-time GB scanned reporting
6. **Final Reports**: Generated on desktop with summary

## 📈 Progress Information

The script provides real-time feedback including:

- Registry paths being scanned with progress indicators
- Windows Store app enumeration progress
- WMI scanning speed (programs detected per second)
- Drive space analysis showing GB processed per drive
- Total programs found and processing time

## 🔧 Requirements

- Windows PowerShell 5.1 or PowerShell Core 7.x
- No special administrator privileges required
- Access to system registry (standard user permissions)
- May take several minutes for complete WMI queries

## 📋 Detected Program Sources

### Registry Scanning

- `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`
- `HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`
- User-specific program installations

### Windows Store Apps

- Modern UWP applications
- Windows Store installations
- System apps and user-installed apps

### WMI Queries

- Win32_Product class
- Additional program detection methods
- System-level program information

## 📊 Report Contents

### Program Information Collected

- **Program Name**: Full application name
- **Publisher**: Software vendor/company
- **Version**: Software version number
- **Install Date**: When the program was installed
- **Install Location**: Program installation path
- **Size**: Program size (when available)

### Summary Statistics

- Total number of programs found
- Programs organized by publisher
- Drive space analysis results
- Scanning performance metrics

## ⚡ Performance Features

- **Drive Selection**: Target specific drives to improve scan speed
- **Progress Indicators**: Real-time feedback on scanning progress
- **Speed Calculation**: Monitor WMI query performance
- **Memory Efficient**: Optimized for systems with many installed programs
- **Error Recovery**: Continues scanning even if some sources fail

## 🐛 Troubleshooting

**Slow WMI Scanning**: WMI queries can be slow on systems with many programs. The script shows progress and speed to indicate it's working.

**Missing Programs**: Some programs may not appear in all scanning methods. The script uses multiple sources to maximize detection.

**Permission Issues**: Standard user permissions are sufficient. Administrator rights not required.

**Drive Access**: If certain drives are inaccessible, the script will skip them and continue.

## 📈 Development Status

This script is actively maintained with ongoing enhancements tracked in `todo.md` and `completed.md`. Current development focuses on:

- Program size estimation and analysis
- Usage tracking and recommendations
- Enhanced filtering and search capabilities
- Performance optimizations

## 🔗 Related Files

- `todo.md` - Current development tasks and future enhancements
- `completed.md` - Development history and completed features
- `check_installed_programs.ps1` - Main script file

## 💡 Use Cases

- **System Auditing**: Complete inventory of installed software
- **License Management**: Track software installations across systems
- **Cleanup Planning**: Identify unused or duplicate programs
- **Migration Planning**: Document software before system changes
- **Compliance Reporting**: Generate software inventory reports
