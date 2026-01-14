#!/bin/bash
# Terminal capabilities test for sht

echo "=========================================="
echo "Terminal Capabilities Test"
echo "=========================================="
echo ""

echo "Current environment:"
echo "  SHELL: $SHELL"
echo "  TERM: $TERM"
echo "  COLUMNS: $COLUMNS"
echo "  LINES: $LINES"
echo ""

echo "Checking Windows Terminal features..."
echo ""

# Check if we're on Windows
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "✓ Running on Windows (MSYS/MinGW)"
else
    echo "✓ Not on Windows (WSL/Linux)"
fi

# Check for sht executable
if [ -f "bin/sht.exe" ]; then
    echo ""
    echo "✓ sht.exe found"
    ls -lh bin/sht.exe | awk '{print "  Size: " $5}'
else
    echo "✗ sht.exe not found - run build.sh first"
    exit 1
fi

echo ""
echo "=========================================="
echo "Recommendations for running sht:"
echo "=========================================="
echo ""
echo "1. Use Windows Terminal (recommended):"
echo "   - Supports ANSI escape sequences"
echo "   - Supports mouse events"
echo "   - Supports 256 colors"
echo ""
echo "2. If seeing mouse position text:"
echo "   - Your terminal may not support mouse sequences"
echo "   - Try: launch.bat or launch.sh"
echo "   - These set proper TERM environment"
echo ""
echo "3. If seeing garbled output:"
echo "   - Make sure terminal supports UTF-8"
echo "   - Try: set LANG=C.UTF-8"
echo "   - Check terminal color profile is set correctly"
echo ""
echo "4. Recommended launch methods:"
echo "   a. launch.bat    - Sets TERM, launches from Windows"
echo "   b. launch.sh     - Sets TERM, launches from MSYS2 bash"
echo "   c. run_verbose.bat - Checks dependencies first"
echo ""
echo "=========================================="
