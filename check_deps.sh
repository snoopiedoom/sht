#!/bin/bash
# Dependency checker for sht.exe
# Run this to check if all DLLs are available before running

echo "=========================================="
echo "Checking sht.exe dependencies..."
echo "=========================================="
echo ""

cd /c/dev/sht

if [ ! -f "./bin/sht.exe" ]; then
    echo "ERROR: sht.exe not found!"
    echo "Run ./build.sh first"
    exit 1
fi

echo "Running ldd to check all dependencies..."
echo ""

# Find all DLL dependencies
missing_dlls=$(ldd ./bin/sht.exe 2>&1 | grep -i "not found")

if [ -n "$missing_dlls" ]; then
    echo "❌ MISSING DLLS DETECTED:"
    echo "$missing_dlls" | sed 's/^/  /'
    echo ""
    echo "Fix: Run ./build.sh to copy missing DLLs"
    exit 1
else
    echo "✅ All dependencies satisfied!"
    echo ""
    echo "DLL files in bin/:"
    ls bin/*.dll | wc -l
    echo ""
    echo "Total size:"
    du -sh bin/
    echo ""
    echo "=========================================="
    echo "sht.exe is ready to run!"
    echo "=========================================="
    echo ""
    echo "Run from Windows Terminal:"
    echo "  cd C:\\\\dev\\\\sht"
    echo "  .\\\\bin\\\\sht.exe"
    exit 0
fi
