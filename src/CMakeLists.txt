# CMakeLists.txt for SWarp main executable

# Add subdirectories for libraries
add_subdirectory(fits)
add_subdirectory(wcs)

# Source files for swarp executable
set(SWARP_SOURCES
    back.c
    coadd.c
    data.c
    dgeo.c
    field.c
    fitswcs.c
    header.c
    interpolate.c
    main.c
    makeit.c
    misc.c
    prefs.c
    projapprox.c
    resample.c
    threads.c
    weight.c
    xml.c
)

# Header files
set(SWARP_HEADERS
    back.h
    coadd.h
    data.h
    define.h
    dgeo.h
    field.h
    fitswcs.h
    globals.h
    header.h
    interpolate.h
    key.h
    misc.h
    preflist.h
    prefs.h
    projapprox.h
    resample.h
    threads.h
    types.h
    wcscelsys.h
    weight.h
    xml.h
)

# Create executable
add_executable(swarp ${SWARP_SOURCES} ${SWARP_HEADERS})

# Link libraries
target_link_libraries(swarp PRIVATE
    fits
    wcs_c
    ${EXTRA_LIBS}
)

# Include directories
target_include_directories(swarp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/fits
    ${CMAKE_CURRENT_SOURCE_DIR}/wcs
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_BINARY_DIR}
)

# Set executable properties
set_target_properties(swarp PROPERTIES
    OUTPUT_NAME "swarp"
)

# Windows-specific settings
if(WIN32)
    # Add Windows-specific definitions
    target_compile_definitions(swarp PRIVATE
        _CRT_SECURE_NO_WARNINGS
        _CRT_NONSTDC_NO_DEPRECATE
    )

    # Link Windows socket library if needed
    target_link_libraries(swarp PRIVATE ws2_32)

    # Copy necessary DLL files for MSYS2/MinGW
    message(STATUS "Configuring DLL copy for Windows build...")

    # Try to copy DLLs from common MSYS2 locations
    set(MSYS2_PATHS
        "C:/msys64/usr/bin"
        "/usr/bin"
    )

    # Required DLLs
    set(REQUIRED_DLLS
        "msys-2.0.dll"
        "msys-gcc_s-seh-1.dll"
    )

    # Add custom command to copy DLLs after build
    foreach(DLL_NAME ${REQUIRED_DLLS})
        foreach(MSYS2_PATH ${MSYS2_PATHS})
            if(EXISTS "${MSYS2_PATH}/${DLL_NAME}")
                message(STATUS "Will copy ${DLL_NAME} from ${MSYS2_PATH}")
                add_custom_command(TARGET swarp POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${MSYS2_PATH}/${DLL_NAME}"
                        "$<TARGET_FILE_DIR:swarp>/${DLL_NAME}"
                    COMMENT "Copying ${DLL_NAME}"
                    VERBATIM
                )
                break()
            endif()
        endforeach()
    endforeach()

    # Add a message after build
    add_custom_command(TARGET swarp POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "========================================="
        COMMAND ${CMAKE_COMMAND} -E echo "Build complete!"
        COMMAND ${CMAKE_COMMAND} -E echo "If DLLs were not copied automatically,"
        COMMAND ${CMAKE_COMMAND} -E echo "run: bash copy_dlls.sh"
        COMMAND ${CMAKE_COMMAND} -E echo "or:  copy_dlls.bat"
        COMMAND ${CMAKE_COMMAND} -E echo "========================================="
        VERBATIM
    )
endif()

