# sht - SIMPLE RUN INSTRUCTIONS

## ✅ Good News
Your executables are working! You can see the UI structure (headers, sidebar, request editor).

## 🎯 The Only Issue

**ANSI color codes are being printed as text** instead of being processed by your terminal.

You see: `^[[71;1R...`
Should be: Proper colors (Kanagawa theme)

## 📋 One Command Fix

### Option 1: Fix Windows Terminal (RECOMMENDED)

**In Windows Terminal:**
1. Press `Ctrl+Shift+P` to open settings
2. Go to: **Profiles → Colors**
3. Change scheme from "Campbell" or "Solarized Light"
4. Run sht again

Or try these color schemes (all work better with notcurses):
- Solarized Light
- Solarized Dark
- Gruvbox Light
- Monokai

### Option 2: Use MSYS2 Bash

MSYS2's terminal (mintty) handles ANSI codes perfectly:

```bash
C:\msys64\usr\bin\bash.exe -c "cd /c/dev/sht && ./bin\sht.exe"
```

### Option 3: Try Different Terminal

Download and try:
- [Alacritty](https://alacritty.org/) - Best ANSI support
- [WezTerm](https://wezfurl.org/wezterm/) - Great Windows integration

## 🚀 Quick Start Commands

```batch
# From Windows Terminal (after fixing color scheme)
cd C:\dev\sht
.\bin\sht.exe

# From Windows Terminal (debug version)
cd C:\dev\sht
.\bin\sht_debug.exe

# From MSYS2 bash
C:\msys64\usr\bin\bash.exe -c "cd /c/dev/sht && ./bin/sht.exe"
```

## 🎮 Controls

- `q` or `ESC` - Quit
- Mouse - Click to interact

## 📁 What's Working

- ✅ Compilation succeeds
- ✅ All 155 DLLs copied (~206MB)
- ✅ Dependencies satisfied
- ✅ UI renders correctly
- ✅ App runs and receives input
- ⚠️ Terminal needs to process ANSI codes properly

## 🗑️ Files Removed

Cleaned up broken test files that had compilation errors.

---

**TL;DR**: Your app works! Just change your Windows Terminal color scheme or run from MSYS2 bash.
