# ===========================
# Build config
# ===========================
CC      ?= clang
CSTD    ?= -std=c11
CFLAGS  ?= -Wall -Wextra -O2 $(CSTD)
LDFLAGS ?=

SRC_DIR := src
OBJ_DIR := build
BIN_DIR := bin

TARGET  := $(BIN_DIR)/simple-http-tui

SRC := $(SRC_DIR)/main.c \
       $(SRC_DIR)/ui.c

OBJ := $(SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

# notcurses pkgconfig (Linux build)
CFLAGS  += $(shell pkg-config --cflags notcurses 2>/dev/null)
LDFLAGS += $(shell pkg-config --libs notcurses 2>/dev/null)

.PHONY: all clean run linux windows notcurses-win

# ===========================
# Default build
# ===========================
all: $(TARGET)

$(TARGET): $(OBJ)
	@mkdir -p $(BIN_DIR)
	$(CC) $(OBJ) -o $@ $(LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	$(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) toolchain-mingw.cmake deps

# ===========================
# Linux build
# ===========================
linux:
	$(MAKE) clean
	$(MAKE) CC=clang TARGET=$(BIN_DIR)/simple-http-tui

# ===========================
# Windows cross-build (WSL)
# ===========================
MINGW_PREFIX   := /usr/x86_64-w64-mingw32
MINGW_CC       := x86_64-w64-mingw32-gcc
MINGW_CXX      := x86_64-w64-mingw32-g++
MINGW_RC       := x86_64-w64-mingw32-windres
TOOLCHAIN_FILE := toolchain-mingw.cmake
NOTCURSES_DIR  := deps/notcurses
NOTCURSES_BUILD:= $(NOTCURSES_DIR)/build-win

# Toolchain file
$(TOOLCHAIN_FILE):
	@echo "Generating MinGW toolchain file..."
	@mkdir -p deps
	@cat > $(TOOLCHAIN_FILE) <<EOF
SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_SYSTEM_PROCESSOR x86_64)
SET(CMAKE_C_COMPILER $(MINGW_CC))
SET(CMAKE_CXX_COMPILER $(MINGW_CXX))
SET(CMAKE_RC_COMPILER $(MINGW_RC))
SET(CMAKE_FIND_ROOT_PATH $(MINGW_PREFIX))
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF

# Clone notcurses
$(NOTCURSES_DIR):
	@git clone https://github.com/dankamongmen/notcurses.git $(NOTCURSES_DIR)

# Build notcurses for Windows
notcurses-win: $(TOOLCHAIN_FILE) $(NOTCURSES_DIR)
	@echo "Building notcurses (Windows)..."
	@rm -rf $(NOTCURSES_BUILD)
	@mkdir -p $(NOTCURSES_BUILD)
	@cd $(NOTCURSES_BUILD) && cmake .. \
		-DCMAKE_TOOLCHAIN_FILE=../../$(TOOLCHAIN_FILE) \
		-DUSE_PANDOC=OFF \
		-DUSE_DOXYGEN=OFF \
		-DUSE_FFMPEG=OFF \
		-DUSE_MULTIMEDIA=none \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$(MINGW_PREFIX)
	@cd $(NOTCURSES_BUILD) && make -j$$(nproc)
	@cd $(NOTCURSES_BUILD) && make install
	@echo "Done."

# Windows build
windows: notcurses-win
	@echo "Building Windows executable..."
	$(MAKE) clean
	$(MAKE) CC=$(MINGW_CC) \
		CFLAGS="-I$(MINGW_PREFIX)/include -O2 -std=c11" \
		LDFLAGS="-L$(MINGW_PREFIX)/lib -lnotcurses-core -lnotcurses -static" \
		TARGET=$(BIN_DIR)/simple-http-tui.exe

# ===========================
# Windows packaging
# ===========================
PACKAGE_DIR := dist/win
PACKAGE_ZIP := dist/simple-http-tui-win.zip

package-win: windows
	@echo "Packaging Windows build..."
	@rm -rf $(PACKAGE_DIR)
	@mkdir -p $(PACKAGE_DIR)

	# Copy executable
	@cp bin/simple-http-tui.exe $(PACKAGE_DIR)

	# Copy required MinGW DLLs
	@cp /usr/x86_64-w64-mingw32/bin/libgcc_s_seh-1.dll $(PACKAGE_DIR) || true
	@cp /usr/x86_64-w64-mingw32/bin/libstdc++-6.dll $(PACKAGE_DIR) || true
	@cp /usr/x86_64-w64-mingw32/bin/libwinpthread-1.dll $(PACKAGE_DIR) || true

	# Copy notcurses DLLs (if present)
	@cp /usr/x86_64-w64-mingw32/bin/notcurses.dll $(PACKAGE_DIR) || true
	@cp /usr/x86_64-w64-mingw32/bin/notcurses-core.dll $(PACKAGE_DIR) || true
	@cp /usr/x86_64-w64-mingw32/bin/libdeflate.dll $(PACKAGE_DIR) || true
	@cp /usr/x86_64-w64-mingw32/bin/zlib1.dll $(PACKAGE_DIR) || true

	# Create zip
	@rm -f $(PACKAGE_ZIP)
	@cd dist && zip -r simple-http-tui-win.zip win
	@echo "Done. Output: $(PACKAGE_ZIP)"