# CMakeLists.txt for libfits

# Source files for libfits
set(LIBFITS_SOURCES
    fitsbody.c
    fitscat.c
    fitscheck.c
    fitscleanup.c
    fitsconv.c
    fitshead.c
    fitskey.c
    fitsmisc.c
    fitsread.c
    fitstab.c
    fitsutil.c
    fitswrite.c
)

# Header files
set(LIBFITS_HEADERS
    fitscat_defs.h
    fitscat.h
)

# Create static library
add_library(fits STATIC ${LIBFITS_SOURCES} ${LIBFITS_HEADERS})

# Set include directories for this library
target_include_directories(fits PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Link CFITSIO if available
if(USE_CFITSIO AND CFITSIO_FOUND)
    target_include_directories(fits PRIVATE ${CFITSIO_INCLUDE_DIR})
endif()

# Set library properties
set_target_properties(fits PROPERTIES
    OUTPUT_NAME "fits"
    POSITION_INDEPENDENT_CODE ON
)

