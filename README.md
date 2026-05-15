[README.md](https://github.com/user-attachments/files/27805101/README.md)
# C-Drive Cleanup

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that scans and cleans junk files on Windows C drive to free up disk space.

## Features

Scans **8 categories** of redundant files and reports reclaimable space before any deletion:

| # | Category | Location |
|---|----------|----------|
| 1 | System Temp | `C:\Windows\Temp` |
| 2 | User Temp | `%TEMP%` |
| 3 | Windows Prefetch | `C:\Windows\Prefetch` |
| 4 | Windows Update Cache | `C:\Windows\SoftwareDistribution\Download` |
| 5 | Thumbnail Cache | `%LOCALAPPDATA%\Microsoft\Windows\Explorer` |
| 6 | Recycle Bin | `$Recycle.Bin` |
| 7 | Crash Dumps | `%LOCALAPPDATA%\CrashDumps` |
| 8 | Browser Cache (Chrome/Edge) | Browser cache directories |

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/c-drive-cleanup-skill.git ~/.claude/skills/c-drive-cleanup
```

Or manually copy the folder to your Claude Code skills directory:

```
~/.claude/skills/c-drive-cleanup/
```

## Usage

In Claude Code, just say:

- "清理 C 盘"
- "Clean up my C drive"
- "释放磁盘空间"

Claude will **scan first**, show you a report with sizes, and only clean after your confirmation.

## How It Works

1. **Scan** (`scan.ps1`) - Analyzes all 8 categories and reports sizes as JSON
2. **Review** - Claude presents a summary table; you choose what to clean
3. **Clean** (`cleanup.ps1`) - Deletes files in selected categories, skips locked files

## Requirements

- Windows 10 / 11
- PowerShell 5.1+
- Standard user permissions (no admin required for most cleanup)

## Safety

- **Never deletes without user confirmation**
- Skips locked / in-use files automatically
- Never touches `C:\Windows\System32`, `C:\Program Files`, or user documents

## License

MIT
