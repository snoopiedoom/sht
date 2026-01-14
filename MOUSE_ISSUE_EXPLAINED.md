# Mouse Issue Explanation and Solutions

## Problem
User reports seeing mouse position text printed to terminal instead of mouse cursor movement:

```
insert_path:491:added fixed 0x00000091 91 as 2
insert_path:491:added fixed 0x00000065 65 as 3
```

This text fills the terminal when mouse is moved, making the TUI unusable.

## Root Cause Analysis

### 1. What's Happening

The text shown (`insert_path`, `inputctx_add_input_escape`, etc.) is **notcurses internal trace output**. This means notcurses is working, but:

1. **Mouse escape sequences are being echoed as text** instead of being processed
2. OR notcurses is in verbose mode (NCLOGLEVEL_TRACE) and terminal isn't interpreting the output

### 2. Why This Occurs

**Terminal Types That Cause This:**
- Legacy cmd.exe window (not Windows Terminal app)
- PowerShell legacy console
- Terminals that don't support xterm-style mouse reporting

**How Mouse Should Work:**
```
Application sends: ESC [ < M ; Ps ; Ps '   (mouse escape sequence)
Terminal processes: Updates cursor/mouse position
Result: Smooth mouse interaction
```

**What's Happening:**
```
Application sends: ESC [ < M ; Ps ; Ps '
Terminal echoes: ESC [ < M ; Ps ; Ps '   (printed as text!)
Result: Garbled text on screen
```

### 3. Notcurses Logging

Standard build uses `NCLOGLEVEL_TRACE` which shows lots of internal messages. These are normally sent to stderr, but if:
- Terminal doesn't support separate streams
- Or logging is misdirected
- Then trace output appears on screen

## Solutions

### Solution 1: Use Windows Terminal (RECOMMENDED)

Windows Terminal properly handles:
- ANSI escape sequences (colors, cursor movement)
- xterm-style mouse reporting
- UTF-8 encoding

**How to use:**
1. Install Windows Terminal from Microsoft Store
2. Open it (it replaces cmd.exe)
3. Set default profile to PowerShell
4. Run: `cd C:\dev\sht && .\bin\sht.exe`

### Solution 2: Debug Build

Try the debug build which:
- Uses `NCLOGLEVEL_ERROR` (minimal logging)
- Uses different mouse mode (`NCMICE_BUTTON_EVENT` only)
- Tries alternate screen mode off

**How to build:**
```bash
cd sht
make debug
```

**How to run:**
```batch
.\launch_debug.bat
```

### Solution 3: Proper Launcher

Use `launch.bat` or `launch.sh` which sets:
- `TERM=xterm-256color` (tells terminal we need ANSI support)
- `COLORTERM=truecolor` (enables color support)

**Run from Windows Terminal:**
```batch
cd C:\dev\sht
.\launch.bat
```

### Solution 4: Check Windows Terminal Settings

Press `Ctrl+Shift+P` in Windows Terminal:
1. Search: "Open Settings"
2. Or "Terminal Color Scheme"
3. Check: "Use legacy console" is **OFF**
4. Check: Color scheme is not "Legacy"

### Solution 5: Test Terminal Capabilities

Run the test script to see what your terminal supports:
```bash
cd sht
make test
```

This will report:
- TERM variable
- Color support
- Window size
- Suggested fixes

## Technical Details

### What Notcurses Needs

For mouse events to work properly, notcurses needs:

1. **Terminal in application mode** (not raw keyboard mode)
2. **Mouse reporting enabled** (ESC [ ? 1000h or similar)
3. **Terminal accepts xterm-style mouse sequences**
4. **UTF-8 encoding** (for 256+ colors)

### Notcurses Flags in Code

**Standard build (main.c):**
```c
opts.loglevel = NCLOGLEVEL_TRACE;        // Verbose logging
opts.flags = NCOPTION_SUPPRESS_BANNERS   // Hide notcurses banner
             | NCOPTION_DRAIN_INPUT          // Clear input queue
             | NCOPTION_PRESERVE_CURSOR;     // Restore cursor on exit

notcurses_mice_enable(nc, NCMICE_ALL_EVENTS);  // All mouse events
```

**Debug build (main_noalt.c):**
```c
opts.loglevel = NCLOGLEVEL_ERROR;         // Minimal logging
opts.flags = NCOPTION_SUPPRESS_BANNERS
             | NCOPTION_DRAIN_INPUT
             | NCOPTION_PRESERVE_CURSOR
             | NCOPTION_NO_ALTERNATE_SCREEN; // Try alternate mode off

notcurses_mice_enable(nc, NCMICE_BUTTON_EVENT);  // Button events only
```

### Escape Sequences Explained

**Mouse Position Report:**
```
ESC [ < Py ; Px ; Pw '  (where Py,Px,Pw are Y,X coords)
```

**Mouse Button Press:**
```
ESC [ < 0 ; Pb ; Pr ; M '  (where Pb,Pr are button codes)
```

If terminal doesn't recognize these, it prints them as literal text.

## Diagnostic Steps

If mouse text still appears after trying above solutions:

1. **Identify your terminal:**
   ```
   echo $TERM
   ```
   Should be: `xterm-256color`, `xterm-color`, or similar
   NOT: `dumb`, `unknown`, or `cygwin` (if on Windows)

2. **Check mouse support:**
   - In Windows Terminal, try moving mouse in other apps (neovim, etc.)
   - If mouse works in other apps, it's sht configuration
   - If mouse doesn't work in any app, it's terminal setup

3. **Try minimal test:**
   ```bash
   # Create simple TUI that just reports mouse position
   # See if mouse escape sequences work at all
   ```

4. **Alternative terminals:**
   - Alacritty (https://alacritty.org/)
   - WezTerm (https://wezfurl.org/wezterm/)
   - Kitty (https://sw.kovidgoyal.net/kitty/)

## Summary

| Issue | Cause | Solution |
|-------|--------|----------|
| Mouse text printed | Terminal not handling mouse sequences | Use Windows Terminal + proper launcher |
| Verbose trace output | NCLOGLEVEL_TRACE | Use debug build (NCLOGLEVEL_ERROR) |
| Garbled output | Terminal doesn't support ANSI | Use Windows Terminal or modern terminal |
| App won't start | Missing DLLs or wrong terminal | Run `check_deps.sh` + use proper terminal |

## Quick Reference

**Recommended Launch (in order to try):**
1. `.\launch_debug.bat` - Debug build with TERM set
2. `.\launch.bat` - Standard build with TERM set
3. `.\run_verbose.bat` - Check dependencies first
4. `C:\msys64\usr\bin\bash.exe -c "cd /c/dev/sht && ./bin/sht.exe"` - MSYS2 fallback

**All require: Windows Terminal (not legacy cmd/PowerShell)**
