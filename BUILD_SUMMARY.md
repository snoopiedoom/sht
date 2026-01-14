# SHT Build Summary

## Project Status: ✅ WORKING

The `sht` (Simple HTTP TUI) project in the `sht/` folder has been successfully configured to build and run on Windows.

## Build Method

The project uses **MSYS2/MinGW** for building, not standard Windows toolchain.

### Prerequisites
- MSYS2 installed at `C:\msys64`
- notcurses package installed: `mingw-w64-x86_64-notcurses` (version 3.0.17)

### Build Commands

**Option 1: Using Makefile (recommended)**
```bash
cd sht
./build.sh
```

**Option 2: Direct build script**
```bash
cd sht
/c/msys64/usr/bin/bash.exe build.sh
```

## Build Output

After successful build, following files are created in `bin/`:

### Executable
- `sht.exe` (128KB) - The main HTTP TUI application

### Required DLLs
All 25 DLLs are automatically copied to `bin/` by the build script:

**Runtime Libraries** (3 files, 2.6MB):
- `libgcc_s_seh-1.dll` (147KB)
- `libstdc++-6.dll` (2.4MB)
- `libwinpthread-1.dll` (64KB)

**Notcurses Libraries** (4 files, 755KB):
- `libnotcurses-3.dll` (58KB)
- `libnotcurses-core-3.dll` (587KB)
- `libnotcurses-ffi-3.dll` (82KB)
- `libnotcurses++-3.dll` (28KB)

**FFmpeg Libraries** (6 files, 32.3MB):
- `avutil-60.dll` (1.3MB)
- `avcodec-62.dll` (20MB)
- `avdevice-62.dll` (172KB)
- `avformat-62.dll` (2.8MB)
- `avfilter-11.dll` (6.3MB)
- `swscale-9.dll` (1.9MB)

**Additional Dependencies** (12 files, 16.6MB):

Video/Codec Libraries (2 files, 9.7MB):
- `libaom.dll` (9.3MB) - AV1 video codec
- `libbluray-3.dll` (363KB) - Blu-ray disc support

Compression/Encoding (3 files, 1.3MB):
- `libbz2-1.dll` (99KB) - bzip2 compression
- `libdeflate.dll` (97KB) - deflate compression
- `libiconv-2.dll` (1.1MB) - Character encoding

Graphics/Canvas (5 files, 2.4MB):
- `libcaca-0.dll` (842KB) - ASCII art library
- `libcaca++-0.dll` (57KB) - CACA C++ bindings
- `libcairo-2.dll` (1.2MB) - 2D graphics library
- `libcairo-gobject-2.dll` (35KB) - Cairo GObject integration
- `libcairo-script-interpreter-2.dll` (171KB) - Cairo scripting

Text/Unicode (2 files, 2.7MB):
- `libncursesw6.dll` (531KB) - Ncurses wide character support
- `libunistring-5.dll` (2.2MB) - Unicode string library

**Total**: 25 DLLs, ~51MB

## Running the Application

The application requires a terminal that supports:
- ANSI escape sequences
- Mouse events
- True-color support

### Recommended Terminals
- **Windows Terminal** (recommended)
- **mintty** (MSYS2 default)
- **Alacritty**
- **WezTerm**

### How to Run

```bash
# Option 1: From MSYS2 shell
cd C:\dev\sht\bin
./sht.exe

# Option 2: From Windows Terminal with MSYS2 bash
C:\msys64\usr\bin\bash.exe -c "cd /c/dev/sht && ./bin/sht.exe"

# Option 3: From WSL (current session)
/c/msys64/usr/bin/bash.exe -c "cd /c/dev/sht && ./bin/sht.exe"
```

**NOTE**: Standard cmd.exe or PowerShell will NOT work properly as they don't support the required terminal features.

## Application Controls

- `q` / `ESC` - Quit the application
- `Mouse` - Click to interact with UI

## Technical Details

### Build System
- **Compiler**: MinGW GCC 15.2.0 (MSYS2)
- **C Standard**: C11
- **C Flags**: `-Wall -Wextra -O2 -std=c11`
- **Linker Flags**: `-L/mingw64/lib -lnotcurses -lnotcurses-core -lnotcurses-ffi`

### Dependencies
- **notcurses 3.0.17**: TUI library for modern terminal emulators
- **MinGW Runtime**: libgcc_s_seh-1, libstdc++-6
- **POSIX Threads**: libwinpthread-1

### Architecture
- Target: `x86_64-w64-mingw32`
- Thread model: posix
- Build type: Release (optimized)

## Troubleshooting

### Build fails with "gcc: command not found"
**Cause**: PATH not set correctly in build script context
**Solution**: Run `build.sh` directly with full bash path:
```bash
cd sht
/c/msys64/usr/bin/bash.exe build.sh
```

### Application shows error about missing DLLs
**Cause**: Some DLL dependencies are missing from bin/ directory
**Errors**: "DLL was not found" (avutil, avcodec, libaom, libbluray, libcairo, libcaca, libncursesw, libunistring, etc.)
**Solution**: All 25 required DLLs are now automatically copied by `build.sh`. Run it again:
```bash
cd sht
./build.sh
```
**Total required DLLs**: 25 files totaling ~51MB

**Categories**:
- Runtime (3): libgcc_s_seh-1, libstdc++-6, libwinpthread-1
- Notcurses (4): libnotcurses-3, libnotcurses-core-3, libnotcurses-ffi-3, libnotcurses++-3
- FFmpeg (6): avutil-60, avcodec-62, avdevice-62, avformat-62, avfilter-11, swscale-9
- Video/Codec (2): libaom, libbluray-3
- Compression (3): libbz2-1, libdeflate, libiconv-2
- Graphics (5): libcaca-0, libcaca++-0, libcairo-2, libcairo-gobject-2, libcairo-script-interpreter-2
- Text (2): libncursesw6, libunistring-5

### Application won't start or shows garbled output
**Cause**: Terminal doesn't support required features (ANSI codes, mouse events, true-color)
**Solution**: Use Windows Terminal (recommended), mintty (MSYS2), or Alacritty instead of legacy cmd.exe/PowerShell windows.

### Missing DLL errors
**Cause**: Not all 25 DLLs are in same directory as executable
**Solution**: Run `build.sh` which copies all required DLLs to `bin/`
**Verification**: Check you have 25 DLLs:
```bash
cd sht
ls bin/*.dll | wc -l  # Should output: 25
du -sh bin/  # Should output: ~51M
```

## Files Changed

1. **Makefile** - Updated to use MSYS2 bash for building
2. **build.sh** - Created new build script using MSYS2/MinGW
3. **README** - Updated with Windows build instructions
4. **CMakeLists.txt** - Created (not used, for reference)
5. **BUILD_SUMMARY.md** - This file

## Next Steps

The project is now fully functional. To develop further:

1. Add HTTP client functionality (curl/libcurl)
2. Implement request editor UI
3. Add collection management
4. Add history support
5. Add environment variable management

All these features are already scaffolded in the current UI code.
