#!/bin/bash
# Build notcurses from source WITHOUT FFmpeg/multimedia support
# This results in a much smaller dependency tree

set -e

echo "=========================================="
echo "Building minimal notcurses (no FFmpeg)"
echo "=========================================="
echo ""

# Check if notcurses source exists
if [ ! -d "deps/notcurses" ]; then
    echo "ERROR: notcurses source not found in deps/notcurses"
    echo "The notcurses submodule should already exist"
    exit 1
fi

cd deps/notcurses

# Create build directory
rm -rf build-minimal
mkdir -p build-minimal
cd build-minimal

echo "Configuring notcurses (no FFmpeg, no multimedia)..."
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/c/dev/sht/notcurses-minimal \
    -DUSE_FFMPEG=OFF \
    -DUSE_MULTIMEDIA=none \
    -DUSE_DOXYGEN=OFF \
    -DUSE_PANDOC=OFF \
    -DNCURSES=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_SHARED=ON \
    ..

echo ""
echo "Building notcurses (this may take several minutes)..."
make -j$(nproc)

echo ""
echo "Installing to notcurses-minimal..."
make install

echo ""
echo "=========================================="
echo "Minimal notcurses build complete!"
echo "=========================================="
echo ""
echo "Installed to: /c/dev/sht/notcurses-minimal"
echo ""
echo "DLLs copied:"
ls -lh /c/dev/sht/notcurses-minimal/bin/*.dll 2>/dev/null | awk '{print $9, $5}'
echo ""
echo "Now update build.sh to use this minimal notcurses build"
