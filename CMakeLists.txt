cmake_minimum_required(VERSION 3.15)
project(SWarp VERSION 2.42.0 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Options
option(USE_THREADS "Enable multithreading support" ON)
option(USE_CFITSIO "Enable CFITSIO support for compressed FITS files" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Add module path for finding packages
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Platform-specific settings
if(WIN32)
    # Windows-specific settings
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
    
    # Use static runtime on Windows for better portability
    if(MSVC)
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    endif()
endif()

# Find required libraries
find_library(MATH_LIBRARY m)
if(MATH_LIBRARY)
    set(EXTRA_LIBS ${EXTRA_LIBS} ${MATH_LIBRARY})
endif()

# Find CFITSIO
if(USE_CFITSIO)
    find_package(CFITSIO)
    if(CFITSIO_FOUND)
        message(STATUS "CFITSIO found: ${CFITSIO_LIBRARIES}")
        add_definitions(-DHAVE_CFITSIO)
        include_directories(${CFITSIO_INCLUDE_DIR})
        set(EXTRA_LIBS ${EXTRA_LIBS} ${CFITSIO_LIBRARIES})
    else()
        message(WARNING "CFITSIO not found. Building without CFITSIO support.")
        set(USE_CFITSIO OFF)
    endif()
endif()

# Find Threads
if(USE_THREADS)
    find_package(Threads)
    if(Threads_FOUND)
        message(STATUS "Threads found")
        add_definitions(-DUSE_THREADS)
        add_definitions(-DTHREADS_NMAX=1024)
        set(EXTRA_LIBS ${EXTRA_LIBS} ${CMAKE_THREAD_LIBS_INIT})
    else()
        message(WARNING "Threads not found. Building without threading support.")
        set(USE_THREADS OFF)
    endif()
endif()

# Check for headers
include(CheckIncludeFile)
check_include_file(malloc.h HAVE_MALLOC_H)
check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(sys/mman.h HAVE_SYS_MMAN_H)

# Check for functions
include(CheckFunctionExists)
check_function_exists(mmap HAVE_MMAP)
check_function_exists(getenv HAVE_GETENV)
check_function_exists(gethostname HAVE_GETHOSTNAME)
check_function_exists(memcpy HAVE_MEMCPY)
check_function_exists(memmove HAVE_MEMMOVE)
check_function_exists(memset HAVE_MEMSET)
check_function_exists(strstr HAVE_STRSTR)
check_function_exists(atexit HAVE_ATEXIT)
check_function_exists(getrlimit HAVE_GETRLIMIT)
check_function_exists(isnan HAVE_ISNAN)

# Check for math functions
set(CMAKE_REQUIRED_LIBRARIES m)
check_function_exists(cosd HAVE_COSD)
check_function_exists(sind HAVE_SIND)
check_function_exists(tand HAVE_TAND)
check_function_exists(acosd HAVE_ACOSD)
check_function_exists(asind HAVE_ASIND)
check_function_exists(atand HAVE_ATAND)
check_function_exists(atan2d HAVE_ATAN2D)
check_function_exists(sincos HAVE_SINCOS)

# Check for types
include(CheckTypeSize)
check_type_size("long long" LONG_LONG)
if(HAVE_LONG_LONG)
    set(HAVE_LONG_LONG_INT 1)
endif()

check_type_size("unsigned long long" UNSIGNED_LONG_LONG)
if(HAVE_UNSIGNED_LONG_LONG)
    set(HAVE_UNSIGNED_LONG_LONG_INT 1)
endif()

# Generate config.h
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/config.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/config.h"
)

# Include directories
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/fits
    ${CMAKE_CURRENT_SOURCE_DIR}/src/wcs
)

# Add subdirectories
add_subdirectory(src)

# Installation
install(TARGETS swarp
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Install XSL file
install(FILES xsl/swarp.xsl
    DESTINATION share/swarp
)

# Print configuration summary
message(STATUS "")
message(STATUS "SWarp Configuration Summary:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  Threading support: ${USE_THREADS}")
message(STATUS "  CFITSIO support: ${USE_CFITSIO}")
if(USE_CFITSIO AND CFITSIO_FOUND)
    message(STATUS "  CFITSIO include: ${CFITSIO_INCLUDE_DIR}")
    message(STATUS "  CFITSIO library: ${CFITSIO_LIBRARIES}")
endif()
message(STATUS "")

