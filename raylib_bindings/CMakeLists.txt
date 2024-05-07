cmake_minimum_required(VERSION 3.0)
project(raylib_bindings VERSION 1.0.0 LANGUAGES C)

# Specify the C standard
set(CMAKE_C_STANDARD 11) # changed from C99 to C11

# Create a shared library from your source files
add_library(raylib_bindings SHARED bindings.c)

set_target_properties(raylib_bindings PROPERTIES
                      PUBLIC_HEADER bindings.h
                      VERSION ${PROJECT_VERSION}
                      SOVERSION 1
                      LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib
)

# Specify installation rules (optional)
install(TARGETS raylib_bindings
    LIBRARY DESTINATION ${PROJECT_SOURCE_DIR}/lib
)
