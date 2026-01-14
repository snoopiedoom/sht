# ===========================
# Build config
# ===========================
# Use MSYS2 bash for building
MSYS_BASH = C:/msys64/usr/bin/bash.exe

SRC_DIR := src
BIN_DIR := bin

TARGET := $(BIN_DIR)/sht.exe
TARGET_DEBUG := $(BIN_DIR)/sht_debug.exe

.PHONY: all clean run distclean help rebuild debug test

all:
	$(MSYS_BASH) build.sh

# Alternative build with minimal logging and different mouse mode
debug:
	@echo Building debug version...
	$(MSYS_BASH) -c "export PATH=/mingw64/bin:$$PATH && cd /c/dev/sht && \
	  mkdir -p build bin && \
	  gcc -Wall -Wextra -O2 -std=c11 -I/mingw64/include -c src/main_noalt.c -o build/main_noalt.o && \
	  gcc build/main_noalt.o build/ui.o -o bin/sht_debug.exe -L/mingw64/lib -lnotcurses -lnotcurses-core -lnotcurses-ffi && \
	  echo 'Debug build complete: bin/sht_debug.exe'"

# Test terminal capabilities
test:
	$(MSYS_BASH) test_terminal.sh

rebuild: clean all

run: all
	@echo Running sht...
	$(MSYS_BASH) -c "cd /c/dev/sht && ./bin/sht.exe"

clean:
	if exist build rmdir /S /Q build
	if exist bin rmdir /S /Q bin

distclean: clean
	if exist deps rmdir /S /Q deps
	if exist dist rmdir /S /Q dist

help:
	@echo sht - Simple HTTP TUI
	@echo.
	@echo Targets:
	@echo   all     - Build executable and copy DLLs
	@echo   debug   - Build debug version (reduced logging, different mouse mode)
	@echo   test    - Test terminal capabilities
	@echo   rebuild - Clean and build from scratch
	@echo   clean   - Remove build artifacts
	@echo   help    - Show this message
	@echo.
	@echo Run from Windows Terminal:
	@echo   .\bin\sht.exe
