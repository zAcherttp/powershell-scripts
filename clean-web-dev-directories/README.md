# Clean Web Development Directories

A comprehensive PowerShell tool for cleaning web development directories by removing node_modules, build outputs, and cache files with dynamic progress tracking and user-friendly interface.

## 🎯 Purpose

This script helps web developers reclaim disk space by safely removing:

- `node_modules` directories (npm/yarn dependencies)
- Build output directories (`build`, `dist`, `.next`, `.nuxt`, `out`)
- Optional cache directories (`.cache`, `.temp`, `.tmp`, `tmp`, `cache`)

## ✨ Key Features

- **Dynamic Progress Tracking**: Real-time progress bars with size calculation and speed monitoring
- **Interactive Interface**: User-friendly prompts and confirmations for safety
- **Safe Preview Mode**: `-WhatIf` parameter to preview what would be deleted
- **Colorized Output**: Enhanced readability with color-coded messages
- **Comprehensive Error Handling**: Graceful handling of permission issues and locked files
- **Size Calculation**: Pre-calculates directory sizes for accurate progress reporting
- **Multiple Directory Types**: Supports various web development artifacts

## 📋 Parameters

| Parameter      | Type   | Default  | Description                                                         |
| -------------- | ------ | -------- | ------------------------------------------------------------------- |
| `Path`         | String | `e:\web` | Root directory to scan for cleanup                                  |
| `Force`        | Switch | False    | Skip confirmation prompts                                           |
| `WhatIf`       | Switch | False    | Preview mode - show what would be deleted without actually deleting |
| `IncludeCache` | Switch | False    | Also clean cache directories                                        |

## 🚀 Usage Examples

### Basic Usage

```powershell
# Clean default web directory with prompts
.\Clean-WebDevDirectories.ps1
```

### Advanced Usage

```powershell
# Clean specific directory without prompts
.\Clean-WebDevDirectories.ps1 -Path "C:\Projects" -Force

# Preview what would be cleaned (safe mode)
.\Clean-WebDevDirectories.ps1 -WhatIf

# Clean with cache directories included
.\Clean-WebDevDirectories.ps1 -IncludeCache -Force

# Test on specific path with preview
.\Clean-WebDevDirectories.ps1 -Path "D:\Development" -WhatIf -IncludeCache
```

## 🛡️ Safety Features

- **Smart Exclusions**:
  - Excludes nested `node_modules` within other `node_modules`
  - Excludes build directories inside `node_modules`
- **Confirmation Prompts**: Always asks for confirmation unless `-Force` is used
- **Detailed Logging**: Shows exactly what's being removed
- **WhatIf Support**: Safe preview mode to test before actual deletion
- **Error Recovery**: Continues operation even if some directories can't be deleted

## 📊 Output Information

The script provides detailed information including:

- Number of directories found and cleaned
- Total disk space reclaimed
- Processing speed (MB/s)
- Real-time progress updates
- Summary report of all operations

## ⚡ Performance

- Efficiently handles large directory structures
- Pre-calculates sizes for accurate progress reporting
- Optimized directory traversal algorithms
- Real-time speed calculation and ETA

## 🔧 Requirements

- Windows PowerShell 5.1 or PowerShell Core 7.x
- No special permissions required
- Works on any drive accessible to the user

## 📝 Examples of Cleaned Directories

### Node.js Projects

- `node_modules/` - Package dependencies
- `build/`, `dist/` - Build outputs
- `.next/` - Next.js build cache
- `out/` - Static export output

### Cache Directories (with -IncludeCache)

- `.cache/` - Various build caches
- `.temp/`, `.tmp/`, `tmp/` - Temporary files
- `cache/` - Application caches

## 🐛 Troubleshooting

**Permission Errors**: Run PowerShell as Administrator if encountering permission issues with system directories.

**Locked Files**: The script will skip locked files and continue with other directories.

**Large Directories**: For very large `node_modules` directories, the initial size calculation may take a moment.

## 📈 Development Status

This script is actively maintained with ongoing enhancements tracked in `todo.md` and `completed.md`. See these files for:

- Current development tasks
- Completed features and improvements
- Future enhancement plans

## 🔗 Related Files

- `todo.md` - Current development tasks and future enhancements
- `completed.md` - Development history and completed features
- `Clean-WebDevDirectories.ps1` - Main script file
