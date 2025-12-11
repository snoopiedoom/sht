#!/usr/bin/env bash
set -e

TOOLCHAIN_FILE=toolchain-mingw.cmake

cat > $TOOLCHAIN_FILE <<EOF
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_SYSTEM_PROCESSOR x86_64)

SET(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
SET(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
SET(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

SET(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF

git clone https://github.com/dankamongmen/notcurses.git
cd notcurses

rm -rf build-win
mkdir build-win
cd build-win

cmake .. \
  -G "Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=../$TOOLCHAIN_FILE \
  -DUSE_PANDOC=OFF \
  -DUSE_DOXYGEN=OFF \
  -DUSE_FFMPEG=OFF \
  -DUSE_MULTIMEDIA=none \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/x86_64-w64-mingw32

make -j"$(nproc)"
make install

echo "Windows build done. DLLs + libs are in /usr/x86_64-w64-mingw32"