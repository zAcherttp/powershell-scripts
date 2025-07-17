# PowerShell Scripts Collection 🚀

A curated collection of useful PowerShell scripts generated with AI assistance to automate various Windows administration and utility tasks.

## 📋 Table of Contents

- [Scripts Overview](#scripts-overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Descriptions](#script-descriptions)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)

## 📦 Scripts Overview

This repository contains PowerShell scripts designed to help with:

- System administration
- File management
- Windows utilities
- Automation tasks
- System monitoring and reporting

## 🔧 Prerequisites

- Windows PowerShell 5.1 or PowerShell Core 7.x
- Administrator privileges (required for some scripts)
- Execution policy set to allow script execution:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## 🚀 Usage

1. Clone this repository:

   ```powershell
   git clone <repository-url>
   cd Powershell
   ```

2. Review the script you want to use before execution
3. Run scripts with appropriate permissions:
   ```powershell
   .\script-name.ps1
   ```

## 📝 Script Descriptions

### `check_installed_programs.ps1`

**Purpose**: Comprehensive Windows program inventory tool

**Features**:

- Scans Windows registry for installed programs
- Retrieves Windows Store apps
- Uses WMI for additional program detection
- Generates both text and CSV reports
- Provides summary by drive and publisher
- Removes duplicates and consolidates information

**Output**:

- Text report: `%USERPROFILE%\Desktop\InstalledPrograms.txt`
- CSV report: `%USERPROFILE%\Desktop\InstalledPrograms.csv`

**Usage**:

```powershell
.\check_installed_programs.ps1
```

**Requirements**:

- No special permissions required
- May take several minutes to complete due to WMI queries

---

## 🤖 AI Generation

These scripts were generated and refined using AI assistance to ensure:

- Best practices in PowerShell scripting
- Error handling and robustness
- Comprehensive functionality
- Clear documentation and comments

## ⚠️ Disclaimer

- **Test First**: Always test scripts in a non-production environment first
- **Review Code**: Examine script contents before execution
- **Backup Data**: Create backups before running scripts that modify system settings
- **Admin Rights**: Some scripts may require administrator privileges
- **Use at Your Own Risk**: While these scripts are designed to be safe, use them at your own discretion

## 🤝 Contributing

Feel free to:

- Report issues or bugs
- Suggest improvements
- Add new useful scripts
- Improve documentation

## 📄 License

This collection is provided as-is for educational and utility purposes. Please review and understand each script before use in production environments.

## 🏷️ Tags

`powershell` `windows` `automation` `scripts` `admin-tools` `system-utilities` `ai-generated`

---

**Last Updated**: July 2025  
**PowerShell Version Tested**: 5.1 / 7.x  
**Windows Version Tested**: Windows 10/11
