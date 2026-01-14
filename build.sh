#!/bin/bash
# Build script for sht project using MSYS2/MinGW

export PATH=/mingw64/bin:$PATH
cd /c/dev/sht

echo "Building sht..."

# Create directories
mkdir -p build bin

# Compile source files
echo "Compiling src/main.c..."
gcc -Wall -Wextra -O2 -std=c11 -I/mingw64/include -c src/main.c -o build/main.o

echo "Compiling src/ui.c..."
gcc -Wall -Wextra -O2 -std=c11 -I/mingw64/include -c src/ui.c -o build/ui.o

# Link
echo "Linking..."
gcc build/main.o build/ui.o -o bin/sht.exe -L/mingw64/lib -lnotcurses -lnotcurses-core -lnotcurses-ffi

# Automatically copy ALL DLL dependencies
echo ""
echo "=========================================="
echo "Copying ALL required DLLs..."
echo "=========================================="

# Get list of all DLL dependencies from ldd, extract paths, and copy them
echo "Analyzing dependencies with ldd..."
ldd ./bin/sht.exe 2>&1 | grep -E '=> /\S+\.dll' | awk '{print $3}' | sort -u | while read dll_path; do
    if [ -n "$dll_path" ] && [ -f "$dll_path" ]; then
        dll_name=$(basename "$dll_path")
        echo "  Copying: $dll_name"
        cp "$dll_path" bin/
    fi
done

# Also copy DLLs from Windows system loader errors if any were mentioned
echo ""
echo "Adding commonly missed DLLs..."
for dll in libgnutls-30.dll librtmp-1.dll libgme.dll libmodplug-1.dll \
           libmp3lame-0.dll libopus-0.dll libvorbis-0.dll libvorbisenc-2.dll \
           libtheora-0.dll libspeex-1.dll libopenjp2-7.dll \
           libpng16-16.dll libjpeg-8.dll libtiff-6.dll \
           zlib1.dll libfreetype-6.dll libharfbuzz-2.dll \
           libfontconfig-1.dll libexpat-1.dll libpcre-1.dll \
           libpango-1.0-0.dll libpangocairo-1.0-0.dll \
           libpangoft2-1.0-0.dll libglib-2.0-0.dll \
           libpixman-1-0.dll libgdk-3-0.dll libatk-1.0-0.dll \
           libintl-8.dll; do
    src_path="/c/msys64/mingw64/bin/$dll"
    if [ -f "$src_path" ]; then
        echo "  Copying: $dll"
        cp "$src_path" bin/
    fi
done

echo ""
echo "=========================================="
echo "Build complete!"
echo "=========================================="
echo ""
echo "Total DLLs copied:"
ls bin/*.dll 2>/dev/null | wc -l
echo ""
echo "Total size:"
du -sh bin/
echo ""
echo "Executable ready:"
ls -lh bin/sht.exe
