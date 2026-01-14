cmake_minimum_required(VERSION 3.15)
project(sht C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -O2")

# Use MinGW compiler
set(CMAKE_C_COMPILER "C:/msys64/mingw64/bin/gcc.exe")
set(CMAKE_CXX_COMPILER "C:/msys64/mingw64/bin/g++.exe")

# Set paths for MSYS2/MinGW
set(MSYS_ROOT "C:/msys64/mingw64")
set(CMAKE_PREFIX_PATH ${MSYS_ROOT})

# Source files
set(SOURCES
    src/main.c
    src/ui.c
)

# Create executable
add_executable(sht ${SOURCES})

# Link against notcurses
target_include_directories(sht PRIVATE "${MSYS_ROOT}/include")
target_link_libraries(sht
    ${MSYS_ROOT}/lib/libnotcurses.a
    ${MSYS_ROOT}/lib/libnotcurses-core.a
    ${MSYS_ROOT}/lib/libnotcurses-ffi.dll.a
)

# Copy DLLs after build
add_custom_command(TARGET sht POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${MSYS_ROOT}/bin
        $<TARGET_FILE_DIR:sht>
    COMMAND ${CMAKE_COMMAND} -E remove_directory
        $<TARGET_FILE_DIR:sht>/lib
    COMMAND ${CMAKE_COMMAND} -E remove_directory
        $<TARGET_FILE_DIR:sht>/include
)
