# CMakeLists.txt for libwcs_c

# Source files for libwcs_c
set(LIBWCS_SOURCES
    cel.c
    lin.c
    poly.c
    proj.c
    sph.c
    tnx.c
    wcs.c
    wcstrig.c
)

# Header files
set(LIBWCS_HEADERS
    cel.h
    lin.h
    poly.h
    proj.h
    sph.h
    tnx.h
    wcs.h
    wcsmath.h
    wcstrig.h
)

# Create static library
add_library(wcs_c STATIC ${LIBWCS_SOURCES} ${LIBWCS_HEADERS})

# Set include directories for this library
target_include_directories(wcs_c PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Set library properties
set_target_properties(wcs_c PROPERTIES
    OUTPUT_NAME "wcs_c"
    POSITION_INDEPENDENT_CODE ON
)

# Link math library if needed
if(MATH_LIBRARY)
    target_link_libraries(wcs_c PRIVATE ${MATH_LIBRARY})
endif()

