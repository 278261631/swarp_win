# FindCFITSIO.cmake
# Find the CFITSIO library
#
# This module defines:
#  CFITSIO_FOUND - system has CFITSIO
#  CFITSIO_INCLUDE_DIR - the CFITSIO include directory
#  CFITSIO_LIBRARIES - Link these to use CFITSIO
#  CFITSIO_VERSION - version of CFITSIO found

# Find include directory
find_path(CFITSIO_INCLUDE_DIR
    NAMES fitsio.h
    PATHS
        ${CFITSIO_ROOT}
        $ENV{CFITSIO_ROOT}
        /usr/local
        /usr
        C:/cfitsio
        C:/Program\ Files/cfitsio
        C:/Program\ Files\ \(x86\)/cfitsio
    PATH_SUFFIXES
        include
        include/cfitsio
        cfitsio
    DOC "CFITSIO include directory"
)

# Find library
find_library(CFITSIO_LIBRARY
    NAMES cfitsio libcfitsio
    PATHS
        ${CFITSIO_ROOT}
        $ENV{CFITSIO_ROOT}
        /usr/local
        /usr
        C:/cfitsio
        C:/Program\ Files/cfitsio
        C:/Program\ Files\ \(x86\)/cfitsio
    PATH_SUFFIXES
        lib
        lib64
        bin
    DOC "CFITSIO library"
)

# Try to get version from fitsio.h
if(CFITSIO_INCLUDE_DIR)
    file(STRINGS "${CFITSIO_INCLUDE_DIR}/fitsio.h" CFITSIO_VERSION_LINE
        REGEX "^#define[ \t]+CFITSIO_VERSION[ \t]+[0-9]+\\.[0-9]+")
    if(CFITSIO_VERSION_LINE)
        string(REGEX REPLACE "^#define[ \t]+CFITSIO_VERSION[ \t]+([0-9]+\\.[0-9]+).*" "\\1"
            CFITSIO_VERSION "${CFITSIO_VERSION_LINE}")
    endif()
endif()

# Handle standard arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CFITSIO
    REQUIRED_VARS CFITSIO_LIBRARY CFITSIO_INCLUDE_DIR
    VERSION_VAR CFITSIO_VERSION
)

# Set output variables
if(CFITSIO_FOUND)
    set(CFITSIO_LIBRARIES ${CFITSIO_LIBRARY})
    set(CFITSIO_INCLUDE_DIRS ${CFITSIO_INCLUDE_DIR})
    
    # Create imported target
    if(NOT TARGET CFITSIO::CFITSIO)
        add_library(CFITSIO::CFITSIO UNKNOWN IMPORTED)
        set_target_properties(CFITSIO::CFITSIO PROPERTIES
            IMPORTED_LOCATION "${CFITSIO_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${CFITSIO_INCLUDE_DIR}"
        )
    endif()
endif()

# Mark variables as advanced
mark_as_advanced(
    CFITSIO_INCLUDE_DIR
    CFITSIO_LIBRARY
)

