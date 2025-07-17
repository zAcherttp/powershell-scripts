# PowerShell Scripts Collection 🚀

A curated collection of useful PowerShell scripts generated with AI to automate various Windows administration and utility tasks.

## Repository Structure

This repository follows modular development practices with each script organized in its own dedicated folder:

```text
PowerShell/
├── {script_name}/
│   ├── script.ps1
│   ├── README.md
│   ├── todo.md
│   └── completed.md
├── README.md
```

## 🛠️ Development Philosophy

This repository emphasizes:

- **Modular Organization**: Each script in its own folder with complete documentation
- **Task-Driven Development**: Using todo.md and completed.md for progress tracking
- **Interactive Design**: Scripts prioritize user interaction and real-time feedback
- **Quality Standards**: Comprehensive error handling, testing, and documentation

## 🚀 Quick Start

1. **Clone the repository**:

   ```powershell
   git clone <repository-url>
   cd Powershell
   ```

2. **Navigate to a script folder**:

   ```powershell
   cd clean-web-dev-directories
   # or
   cd check-installed-programs
   ```

3. **Read the script's README.md** for detailed usage instructions

4. **Run with appropriate permissions**:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\script-name.ps1
   ```

## 📋 Prerequisites

- Windows PowerShell 5.1 or PowerShell Core 7.x
- Execution policy configured to allow script execution
- Administrator privileges (required for some scripts)

## 📖 Documentation

- **Script-specific documentation**: See individual README.md files in each script folder
- **Development guidelines**: See `guide.instructions.md`
- **Task tracking**: Each script folder contains todo.md and completed.md files

## 🤖 AI-Generated & Enhanced

These scripts are generated using AI with focus on:

- PowerShell best practices and modern patterns
- Robust error handling and user experience
- Comprehensive testing and validation
- Clear documentation and maintainability

## 🤝 Contributing

When contributing:

1. Follow the patterns established in `guide.instructions.md`
2. Create new scripts in dedicated folders with complete documentation
3. Maintain todo.md and completed.md for task tracking
4. Ensure scripts are interactive and user-friendly

## ⚠️ Important Notes

- **Always test scripts** in non-production environments first
- **Review code** before execution
- **Backup important data** before running system-modifying scripts
- Scripts are provided as-is for educational and utility purposes

---

**PowerShell Versions**: 5.1 / 7.x  
**Windows Compatibility**: Windows 10/11
